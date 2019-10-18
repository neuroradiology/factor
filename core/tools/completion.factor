! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: completion
USING: kernel arrays sequences math namespaces strings io ;

! Simple fuzzy search.

: fuzzy ( full short -- indices )
    0 swap >array [ swap pick index* [ 1+ ] keep ] map 2nip
    -1 over member? [ drop f ] when ;

: (runs) ( n i seq -- )
    2dup length < [
        3dup nth [
            number= [
                >r >r 1+ r> r>
            ] [
                split-next,
                rot drop [ nth 1+ ] 2keep
            ] if >r 1+ r>
        ] keep split, (runs)
    ] [
        3drop
    ] if ;

: runs ( seq -- seq )
    [
        split-next,
        dup first 0 rot (runs)
    ] { } make ;

: score-1 ( i full -- n )
    {
        { [ over zero? ] [ 2drop 10 ] }
        { [ 2dup length 1- = ] [ 2drop 4 ] }
        { [ 2dup >r 1- r> nth Letter? not ] [ 2drop 10 ] }
        { [ 2dup >r 1+ r> nth Letter? not ] [ 2drop 4 ] }
        { [ t ] [ 2drop 1 ] }
    } cond ;

: score ( full fuzzy -- n )
    dup [
        [ [ length ] 2apply - 15 swap [-] 3 / ] 2keep
        runs [
            [ swap score-1 ] map-with dup supremum swap length *
        ] map-with sum +
    ] [
        2drop 0
    ] if ;

: rank-completions ( results -- newresults )
    #! Discard results in the low 33%
    sort-keys <reversed>
    [ 0 [ first max ] reduce 3 / ] keep
    [ first < ] subset-with
    [ second ] map ;

: complete ( full short -- score )
    #! Match forwards and backwards, see which one has the
    #! highest score.
    [ dupd fuzzy score ] 2keep
    [ <reversed> ] 2apply
    dupd fuzzy score max ;

: completion ( str quot obj -- pair )
    #! pair is { obj score }
    [ swap call swap complete ] keep 2array ; inline

: completions ( str quot candidates -- seq )
    pick empty? [
        2nip
    ] [
        [ >r 2dup r> completion ] map 2nip rank-completions
    ] if ; inline

: string-completions ( str strs -- seq )
    f swap completions ;