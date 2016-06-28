! Copyright (C) 2013 Fred Alger
! Some parts Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators crypto.aes.utils
generalizations grouping kernel locals math math.bitwise
math.ranges memoize namespaces sequences sequences.private
sequences.unrolled ;
IN: crypto.aes

CONSTANT: AES_BLOCK_SIZE 16
! FIPS-197 AES
! input block, state, output block -- 4 32-bit words
CONSTANT: FIPS-197 {
    { 128 10 } ! aes-128 -- Key(4) Block(4) Rounds(10)
    { 192 12 } ! aes-192 -- Key(6) Block(4) Rounds(12)
    { 256 14 } ! aes-256 -- Key(8) Block(4) Rounds(14)
}

PRIVATE<

: (nrounds) ( byte-array -- rounds )
    length 8 * FIPS-197 at ;

: sbox ( -- array )
{
    0x63 0x7c 0x77 0x7b 0xf2 0x6b 0x6f 0xc5
    0x30 0x01 0x67 0x2b 0xfe 0xd7 0xab 0x76
    0xca 0x82 0xc9 0x7d 0xfa 0x59 0x47 0xf0
    0xad 0xd4 0xa2 0xaf 0x9c 0xa4 0x72 0xc0
    0xb7 0xfd 0x93 0x26 0x36 0x3f 0xf7 0xcc
    0x34 0xa5 0xe5 0xf1 0x71 0xd8 0x31 0x15
    0x04 0xc7 0x23 0xc3 0x18 0x96 0x05 0x9a
    0x07 0x12 0x80 0xe2 0xeb 0x27 0xb2 0x75
    0x09 0x83 0x2c 0x1a 0x1b 0x6e 0x5a 0xa0
    0x52 0x3b 0xd6 0xb3 0x29 0xe3 0x2f 0x84
    0x53 0xd1 0x00 0xed 0x20 0xfc 0xb1 0x5b
    0x6a 0xcb 0xbe 0x39 0x4a 0x4c 0x58 0xcf
    0xd0 0xef 0xaa 0xfb 0x43 0x4d 0x33 0x85
    0x45 0xf9 0x02 0x7f 0x50 0x3c 0x9f 0xa8
    0x51 0xa3 0x40 0x8f 0x92 0x9d 0x38 0xf5
    0xbc 0xb6 0xda 0x21 0x10 0xff 0xf3 0xd2
    0xcd 0x0c 0x13 0xec 0x5f 0x97 0x44 0x17
    0xc4 0xa7 0x7e 0x3d 0x64 0x5d 0x19 0x73
    0x60 0x81 0x4f 0xdc 0x22 0x2a 0x90 0x88
    0x46 0xee 0xb8 0x14 0xde 0x5e 0x0b 0xdb
    0xe0 0x32 0x3a 0x0a 0x49 0x06 0x24 0x5c
    0xc2 0xd3 0xac 0x62 0x91 0x95 0xe4 0x79
    0xe7 0xc8 0x37 0x6d 0x8d 0xd5 0x4e 0xa9
    0x6c 0x56 0xf4 0xea 0x65 0x7a 0xae 0x08
    0xba 0x78 0x25 0x2e 0x1c 0xa6 0xb4 0xc6
    0xe8 0xdd 0x74 0x1f 0x4b 0xbd 0x8b 0x8a
    0x70 0x3e 0xb5 0x66 0x48 0x03 0xf6 0x0e
    0x61 0x35 0x57 0xb9 0x86 0xc1 0x1d 0x9e
    0xe1 0xf8 0x98 0x11 0x69 0xd9 0x8e 0x94
    0x9b 0x1e 0x87 0xe9 0xce 0x55 0x28 0xdf
    0x8c 0xa1 0x89 0x0d 0xbf 0xe6 0x42 0x68
    0x41 0x99 0x2d 0x0f 0xb0 0x54 0xbb 0x16
} ;

: inv-sbox ( -- array )
    256 0 <array>
    dup 256 [ dup sbox nth rot set-nth ] with each-integer ;

! applies sbox to each byte of word
: subword ( word -- word' )
    [ gb0 sbox nth ] keep [ gb1 sbox nth ] keep
    [ gb2 sbox nth ] keep gb3 sbox nth >ui32 ;

! applies inverse sbox to each byte of word
: inv-subword ( word -- word' )
    [ gb0 inv-sbox nth ] keep [ gb1 inv-sbox nth ] keep
    [ gb2 inv-sbox nth ] keep gb3 inv-sbox nth >ui32 ;

: rotword ( n -- n ) 8 bitroll-32 ;

! round constants, 2^n over GF(2^8)
: rcon ( -- array )
    {
        0x00 0x01 0x02 0x04 0x08 0x10
        0x20 0x40 0x80 0x1b 0x36
    } ;

: (rcon-nth) ( n -- rcon[n] ) rcon nth 24 shift ;

! Galois field product related
: xtime ( x -- x' )
    [ 1 shift ]
    [ 0x80 bitand 0 = 0 0x1b ? ] bi bitxor 8 bits ;

! generate t-box
:: set-t ( T i -- )
    i sbox nth set: a1
    a1 xtime set: a2
    a1 a2 bitxor set: a3

    a3 a1 a1 a2 >ui32 i T set-nth
    a1 a1 a2 a3 >ui32 i 0x100 + T set-nth
    a1 a2 a3 a1 >ui32 i 0x200 + T set-nth
    a2 a3 a1 a1 >ui32 i 0x300 + T set-nth ;

MEMO:: t-table ( -- array )
    1024 0 <array>
    dup 256 [ set-t ] with each-integer ;

! generate inverse t-box
:: set-d ( D i -- )
    i inv-sbox nth set: a1
    a1 xtime set: a2
    a2 xtime set: a4
    a4 xtime set: a8
    a8 a1 bitxor set: a9
    a9 a2 bitxor set: ab
    a9 a4 bitxor set: ad
    a8 a4 a2 bitxor bitxor set: ae

    ab ad a9 ae >ui32 i D set-nth
    ad a9 ae ab >ui32 i 0x100 + D set-nth
    a9 ae ab ad >ui32 i 0x200 + D set-nth
    ae ab ad a9 >ui32 i 0x300 + D set-nth ;

MEMO:: d-table ( -- array )
    1024 0 <array>
    dup 256 [ set-d ] with each-integer ;


:: (transform) ( a0 a1 a2 a3 table -- word' )
  a0 a1 a2 a3
  [ 0x100 + ] [ 0x200 + ] [ 0x300 + ] tri*
  [ table nth ] 4 napply
  bitxor bitxor bitxor ; inline

: t-transform ( a0 a1 a2 a3 -- word' ) t-table (transform) ;
: d-transform ( a0 a1 a2 a3 -- word' ) d-table (transform) ;

! key schedule
! expands an 128/192/256 bit key into an 176/208/240 byte schedule

SYMBOL: aes-expand-inner
HOOK: key-expand-round aes-expand-inner  ( temp i -- temp' )

SINGLETON: aes-128-key
SINGLETON: aes-256-key

: (add-rcon) ( word rcon-ndx -- word' )
    (rcon-nth) [ rotword subword ] dip bitxor ;

M: aes-128-key key-expand-round ( temp i -- temp' )
    4 /mod 0 = swap and [ (add-rcon) ] when* ;

ERROR: aes-192-256-not-implemented ;
M: aes-256-key key-expand-round ( temp i -- temp' )
    aes-192-256-not-implemented ;

: (key-sched-round) ( output temp i -- output' )
    key-expand-round
    [ dup 4th-from-end ] dip bitxor suffix! ; inline

: (sched-interval) ( K Nr -- seq )
    [ length ] dip 1 + 4 * [a,b) ;    ! over the interval Nk...Nb(Nr + 1)

: (init-round) ( out -- out temp quot )
    [ ]
    [ last ]
    [
        length
        6 > [ aes-256-key ] [ aes-128-key ] if
    ] tri ;

! K -- input key (byte-array), Nr -- number of rounds
! output: sched, Nb(Nr+1) byte key schedule
: (expand-enc-key) ( K Nr -- sched )
    [ bytes>words ] dip
    [ drop (init-round) ]
    [ (sched-interval) ] 2bi
    [
        [ aes-expand-inner set ] dip
        [ (key-sched-round) dup last ] each
    ] with-scope
    drop ;

TUPLE: aes-state nrounds key state ;

: <aes> ( nrounds key state -- aes-state ) \ aes-state boa ;

! grabs the 4n...4(n+1) words of the key
: (key-at-nth-round) ( nth aes -- seq )
    [ 4 * dup 4 + ] [ key>> ] bi* <slice> ;

SYMBOL: aes-strategy
HOOK: (expand-key) aes-strategy ( K Nr -- sched )
HOOK: (first-round) aes-strategy ( aes -- aes' )
HOOK: (counter) aes-strategy ( nrounds -- seq )
HOOK: (round) aes-strategy ( state -- )
HOOK: (add-key) aes-strategy ( aes -- aes' )
HOOK: (final-round) aes-strategy ( aes -- aes' )

SINGLETON: aes-decrypt
SINGLETON: aes-encrypt


! rotates the 2nd row left by one element
! rotates the 3rd row left by two elements
! rotates the 4th row left by three elements
!
! Kind of ugly because the algorithm is specified and
! implemented in terms of columns. This approach is very
! efficient in terms of execution and only requires one new
! word to implement.
!
! The alternative is to split into arrays of bytes, transpose,
! rotate each row n times, transpose again, and then
! smash them back into 4-byte words.
:: (shift-rows) ( c0 c1 c2 c3 -- c0' c1' c2' c3' )
    c3 gb0   c2 gb1   c1 gb2   c0 gb3   >ui32   ! c0'
    c0 gb0   c3 gb1   c2 gb2   c1 gb3   >ui32   ! c1'
    c1 gb0   c0 gb1   c3 gb2   c2 gb3   >ui32   ! c2'
    c2 gb0   c1 gb1   c0 gb2   c3 gb3   >ui32 ; ! c3'

:: (unshift-rows) ( c0 c1 c2 c3 -- c0' c1' c2' c3' )
    c1 gb0   c2 gb1   c3 gb2   c0 gb3   >ui32   ! c0'
    c2 gb0   c3 gb1   c0 gb2   c1 gb3   >ui32   ! c1'
    c3 gb0   c0 gb1   c1 gb2   c2 gb3   >ui32   ! c2'
    c0 gb0   c1 gb1   c2 gb2   c3 gb3   >ui32 ; ! c3'

: (add-round-key) ( key state -- state' )
   4 [ bitxor ] unrolled-2map ;

: add-round-key ( aes n -- aes' )
    over (key-at-nth-round) swap
    [ (add-round-key) ] change-state ;

: add-final-round-key ( aes -- aes' )
    dup nrounds>> add-round-key ;

: add-first-round-key ( aes -- aes' )
    0 add-round-key ;

: aes-round ( state -- )
    dup first4-unsafe
    { [ first-diag t-transform ]
      [ second-diag t-transform ]
      [ third-diag t-transform ]
      [ fourth-diag t-transform ] } 4 ncleave
      set-first4-unsafe ;


: shift-rows ( state -- state' )
    first4 (shift-rows) 4array ;

: unshift-rows ( state -- state' )
    first4 (unshift-rows) 4array ;

: final-round ( state -- state' )
    4 [ subword ] unrolled-map shift-rows ;

: (do-round) ( aes -- aes' )
    [ state>> (round) ] keep ;

M: aes-encrypt (expand-key) (expand-enc-key) ;
M: aes-encrypt (first-round) add-first-round-key ;
M: aes-encrypt (counter) 0 swap (a,b) ;
M: aes-encrypt (round) aes-round ;
M: aes-encrypt (final-round) [ final-round ] change-state add-final-round-key ;

M:: aes-decrypt (expand-key) ( K Nr -- sched )
    K Nr (expand-enc-key) dup length set: key-length
    [
        [ 4 >= ] [ key-length 4 - < ] bi and
        [ subword ui32-rev> d-transform ]
        [ ] if
    ] map-index ;

M: aes-decrypt (first-round) ( aes -- aes' )
    add-final-round-key ;

M: aes-decrypt (counter) ( nrounds -- seq ) 0 swap (a,b) <reversed> ;
M: aes-decrypt (final-round) ( aes -- aes' )
    [ [ inv-subword ] map unshift-rows  ] change-state
    add-first-round-key ;

M: aes-decrypt (round) ( state -- )
    dup first4-unsafe
    { [ -first-diag d-transform ]
      [ -fourth-diag d-transform ]
      [ -third-diag d-transform ]
      [ -second-diag d-transform ] } 4 ncleave
      set-first4-unsafe ;


: (aes-crypt) ( aes -- aes' )
    (first-round) [
        dup nrounds>> (counter)
        [ [ (do-round) ] dip add-round-key drop ] with each
    ] keep
    (final-round) ;

: (aes-expand-key) ( key -- nrounds expanded-key )
    [ (nrounds) ] keep over (expand-key) ;

: (aes-crypt-block-inner) ( nrounds key block -- crypted-block )
    <aes> (aes-crypt) state>> ;

: (aes-crypt-block) ( key block -- output-block )
    [ (aes-expand-key) ] dip bytes>words (aes-crypt-block-inner) ;

PRIVATE>

: aes-encrypt-block ( key block -- output )
    [ aes-encrypt aes-strategy set (aes-crypt-block) ] with-scope
    [ ui32> 4array reverse ] map concat ;

: aes-decrypt-block ( key block -- output )
    [ aes-decrypt aes-strategy set (aes-crypt-block) ] with-scope
    [ ui32> 4array reverse ] map concat ;
