! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: assembler errors kernel kernel-internals math namespaces ;

! OS X uses a different ABI. The stack must be 16-byte aligned.

: stack-increment \ stack-reserve get 16 align 16 + 2 cells - ;

: %prologue ( n -- )
    EBP PUSH
    EBP ESP MOV
    \ stack-reserve set stack-reg stack-increment SUB ;

: align-sub ( n -- )
    dup 16 align swap - ESP swap SUB ;

: align-add ( n -- )
    16 align ESP swap ADD ;

: with-aligned-stack ( n quot -- )
    swap dup align-sub slip align-add ; inline

: struct-ptr/size ( n size func -- )
    EAX ESP MOV ! Save stack pointer
    >r >r EAX swap ADD r> r> ! Add n
    8 [
        ! Push struct size
        >r PUSH r>
        ! Push destination address
        EAX PUSH
        ! Copy the struct to the stack
        f %alien-invoke
    ] with-aligned-stack ;

: %unbox-struct ( n size -- )
    "unbox_value_struct" struct-ptr/size ;

: %unbox ( n reg-class func -- )
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    store-return-reg ;

: %box-pair ( -- )
    #! Box an 8-byte struct returned in EAX:EDX.
    #! Why did Apple have to make things so complex?
    #! Just use objc_msgSend_stret for all structs... jesus.
    8 [
        EDX PUSH
        EAX PUSH
        "box_value_pair" f %alien-invoke
    ] with-aligned-stack ;

: %box-struct ( n size -- )
    over [
        >r stack-increment + 2 cells + r>
        "box_value_struct" struct-ptr/size 
    ] [
        nip 8 = [
            "Cannot %box-struct which is not 8 bytes." throw
        ] unless
        %box-pair
    ] if ;

: box@ ( n reg-class -- stack@ )
    #! Used for callbacks; we want to box the values given to
    #! us by the C function caller. Computes stack location of
    #! nth parameter; note that we must go back one more stack
    #! frame, since %box sets one up to call the one-arg boxer
    #! function. The size of this stack frame so far depends on
    #! the reg-class of the boxer's arg.
    16 swap reg-size - + stack-increment + 2 cells + ;

: (%box) ( n reg-class -- )
    #! If n is f, push the return register onto the stack; we
    #! are boxing a return value of a C function. If n is an
    #! integer, push [ESP+n] on the stack; we are boxing a
    #! parameter being passed to a callback from C.
    over [ [ box@ ] keep [ load-return-reg ] keep ] [ nip ] if
    push-return-reg ;

: %box ( n reg-class func -- )
    over reg-size [
        >r (%box) r> f %alien-invoke
    ] with-aligned-stack ;

: %alien-callback ( quot -- )
    4 [
        EAX load-indirect
        EAX PUSH
        "run_callback" f %alien-invoke
    ] with-aligned-stack ;

: align-callback-value ( reg-class -- reg n )
    ESP 16 rot reg-size - ;
    
: %callback-value ( reg-class func -- )
    ! Call the unboxer
    f %alien-invoke
    dup align-callback-value SUB
    ! Save return register
    dup push-return-reg
    ! Restore data/call/retain stacks
    "unnest_stacks" f %alien-invoke
    ! Restore return register
    dup pop-return-reg
    align-callback-value ADD ;

: %cleanup ( n -- ) drop ;