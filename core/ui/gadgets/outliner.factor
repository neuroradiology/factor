! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-outliners
USING: arrays gadgets gadgets-borders gadgets-buttons
gadgets-labels gadgets-theme generic io kernel
math opengl sequences styles namespaces ;

TUPLE: guide color ;

M: guide draw-interior
    guide-color gl-color
    rect-dim dup first 2 /i 0 2array origin get v+
    swap first2 >r 2 /i r> 2array origin get v+ gl-line ;

: guide-theme ( gadget -- )
    T{ guide f { 0.5 0.5 0.5 1.0 } } swap set-gadget-interior ;

: <guide-gadget> ( -- gadget )
    <gadget> dup guide-theme ;

TUPLE: outliner quot ;

: find-outliner ( gadget -- outliner )
    [ outliner? ] find-parent ;

: <expand-arrow> ( ? -- gadget )
    arrow-right arrow-down ? { 0.5 0.5 0.5 1.0 } swap
    <polygon-gadget> <default-border> ;

DEFER: set-outliner-expanded?

: <expand-button> ( ? -- button )
    #! If true, the button expands, otherwise it collapses.
    dup [ swap find-outliner set-outliner-expanded? ] curry
    >r <expand-arrow> r> <button> ;

: setup-expand ( expanded? outliner -- )
    >r not <expand-button> r> @top-left grid-add ;

: setup-center ( expanded? outliner -- )
    [
        swap [ outliner-quot call ] [ drop <gadget> ] if
    ] keep @center grid-add ;

: setup-guide ( expanded? outliner -- )
    >r [ <guide-gadget> ] [ <gadget> ] if r> @left grid-add ;

: set-outliner-expanded? ( ? outliner -- )
    2dup setup-expand 2dup setup-center setup-guide ;

C: outliner ( gadget quot -- gadget )
    dup delegate>frame
    [ set-outliner-quot ] keep
    [ >r 1array make-shelf r> @top grid-add ] keep
    f over set-outliner-expanded? ;