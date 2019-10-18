! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math-internals
USING: errors generic kernel kernel-internals math ;

: (rect>) ( x y -- z )
    dup zero? [ drop ] [ <complex> ] if ; inline

IN: math

UNION: number real complex ;

M: real real ;
M: real imaginary drop 0 ;

M: number equal? number= ;

: rect> ( x y -- z )
    over real? over real? and [
        (rect>)
    ] [
        "Complex number must have real components" throw
    ] if ; inline

: >rect ( z -- x y ) dup real swap imaginary ; inline

: >float-rect ( z -- x y )
    >rect swap >float swap >float ; inline

: conjugate ( z -- z* ) >rect neg rect> ; inline

: arg ( z -- arg ) >float-rect swap fatan2 ; inline

: >polar ( z -- abs arg )
    >float-rect [ [ sq ] 2apply + fsqrt ] 2keep swap fatan2 ;
    inline

: cis ( arg -- z ) dup fcos swap fsin rect> ; inline

: polar> ( abs arg -- z ) cis * ; inline

M: complex absq >rect [ sq ] 2apply + ;

IN: math-internals

: 2>rect ( x y -- xr yr xi yi )
    [ [ real ] 2apply ] 2keep [ imaginary ] 2apply ; inline

M: complex number=
    2>rect number= [ number= ] [ 2drop f ] if ;

: *re ( x y -- xr*yr xi*ri ) 2>rect * >r * r> ; inline
: *im ( x y -- xi*yr xr*yi ) 2>rect >r * swap r> * ; inline

M: complex + 2>rect + >r + r> (rect>) ;
M: complex - 2>rect - >r - r> (rect>) ;
M: complex * 2dup *re - -rot *im + (rect>) ;

: complex/ ( x y -- r i m )
    #! r = xr*yr+xi*yi, i = xi*yr-xr*yi, m = yr*yr+yi*yi
    dup absq >r 2dup *re + -rot *im - r> ; inline

M: complex / complex/ tuck / >r / r> (rect>) ;

M: complex abs absq >float fsqrt ;

M: complex hashcode
    >rect >fixnum swap >fixnum bitxor ;