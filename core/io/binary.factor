! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: kernel math sequences strings ;

: be> ( seq -- x ) 0 [ >r 8 shift r> bitor ] reduce ;
: le> ( seq -- x ) <reversed> be> ;

: nth-byte ( x n -- b ) -8 * shift HEX: ff bitand ;

: >le ( x n -- str ) [ nth-byte ] map-with >string ;
: >be ( x n -- str ) >le reverse ;