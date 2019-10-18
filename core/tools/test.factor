! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: test
USING: arrays errors hashtables tools io kernel math
memory namespaces parser prettyprint sequences strings words
vectors ;

: print-test ( input output -- )
    "----> Quotation: " write .
    "Expected output: " write . flush ;

: benchmark ( quot -- gctime runtime )
    millis >r gc-time >r call gc-time r> - millis r> - ;

: time ( quot -- )
    benchmark
    [ # " ms run / " % # " ms GC time" % ] "" make print flush ;

: unit-test ( output input -- )
    [
        [
            2dup print-test
            swap >r >r clear r> call
            datastack r> >vector assert=
        ] keep-datastack 2drop
    ] time ;

: unit-test-fails ( quot -- )
    [ f ] swap [ [ call t ] [ 2drop f ] recover ]
    curry unit-test ;

SYMBOL: failures

: failure failures [ ?push ] change ;

: test-handler ( name quot -- ? )
    catch [ dup error. 2array failure f ] [ t ] if* ;

: run-test ( path -- ? )
    [
        "=====> " write dup write "..." print flush
        [
            [ [ run-file ] with-scope ] keep
        ] assert-depth drop
    ] test-handler ;

: prepare-tests ( -- )
    failures off "temporary" forget-vocab ;

: passed.
    "Tests passed:" print . ;

: failed.
    "Tests failed:" print
    failures get [
        first2 swap write-pathname ": " write error.
    ] each ;

: run-tests ( seq -- )
    prepare-tests [ run-test ] subset terpri passed. failed. ;