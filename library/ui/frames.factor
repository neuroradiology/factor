! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sequences vectors ;

! A frame arranges gadgets in a 3x3 grid, where the center
! gadgets gets left-over space.
TUPLE: frame grid ;

: <frame-grid> { { f f f } { f f f } { f f f } } [ clone ] map ;

C: frame ( -- frame )
    <gadget> over set-delegate <frame-grid> over set-frame-grid ;

: frame-child ( frame i j -- gadget ) rot frame-grid nth nth ;

: set-frame-child ( gadget frame i j -- )
    3dup frame-child unparent
    >r >r 2dup add-gadget r> r>
    rot frame-grid nth set-nth ;

: add-center ( gadget frame -- ) 1 1 set-frame-child ;
: add-left   ( gadget frame -- ) 0 1 set-frame-child ;
: add-right  ( gadget frame -- ) 2 1 set-frame-child ;
: add-top    ( gadget frame -- ) 1 0 set-frame-child ;
: add-bottom ( gadget frame -- ) 1 2 set-frame-child ;

: reduce-grid ( grid -- seq )
    [ { 0 0 0 } [ vmax ] reduce ] map ;

: frame-pref-dim ( grid -- dim )
    reduce-grid { 0 0 0 } [ v+ ] reduce ;

: pref-dim-grid ( grid -- grid )
    [ [ [ pref-dim ] [ { 0 0 0 } ] ifte* ] map ] map ;

M: frame pref-dim ( frame -- dim )
    frame-grid pref-dim-grid
    dup frame-pref-dim first
    swap flip frame-pref-dim second
    0 3vector ;

: frame-layout ( horiz vert -- grid )
    [ swap [ swap 0 3vector ] map-with ] map-with ;

: do-grid ( dim-grid gadget-grid quot -- )
    -rot [ [ pick call ] 2each ] 2each drop ;

: position-grid ( gadgets horiz vert -- )
    >r 0 [ + ] accumulate r> 0 [ + ] accumulate
    frame-layout swap [ set-rect-loc ] do-grid ;

: resize-grid ( gadgets horiz vert -- )
    frame-layout swap [ set-gadget-dim ] do-grid ;

M: frame layout* ( frame -- dim )
    frame-grid dup pref-dim-grid
    dup reduce-grid [ first ] map
    swap flip reduce-grid [ second ] map
    3dup position-grid resize-grid ;
