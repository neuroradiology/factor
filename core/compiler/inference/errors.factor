! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: kernel generic errors sequences prettyprint io words
arrays ;

M: inference-error error.
    dup inference-error-rstate 0 <column> >array
    dup empty? [ "Word: " write dup peek . ] unless
    swap delegate error. "Nesting: " write . ;

M: inference-error error-help drop f ;

M: unbalanced-branches-error error.
    "Unbalanced branches:" print
    dup unbalanced-branches-error-out
    swap unbalanced-branches-error-in
    [ pprint bl length . ] 2each ;

M: literal-expected summary
    drop "Literal value expected" ;

M: too-many->r summary
    drop
    "Quotation pushes elements on retain stack without popping them" ;

M: too-many-r> summary
    drop
    "Quotation pops retain stack elements which it did not push" ;

M: too-many-n> summary
    drop
    "Quotation pops name stack elements which it did not push" ;

M: unbalanced-namestacks error.
    "Unbalanced name stack usage." print
    "Make sure occurrences of >n/n> are consistent across branches." print ;

M: no-effect error.
    "The word " write
    no-effect-word pprint
    " does not have a stack effect" print ;

M: recursive-declare-error error.
    "The recursive word " write
    recursive-declare-error-word pprint
    " must declare a stack effect" print ;

M: effect-error error.
    "Stack effects of the word " write
    dup effect-error-word pprint
    " do not match." print
    "Declared: " write
    dup effect-error-word stack-effect effect>string .
    "Inferred: " write effect-error-effect effect>string . ;