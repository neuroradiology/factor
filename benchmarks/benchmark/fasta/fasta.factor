! Based on http://shootout.alioth.debian.org/gp4/benchmark.php?test=fasta&lang=java&id=2
USING: assocs benchmark.reverse-complement byte-arrays fry io
io.encodings.ascii io.files locals kernel math sequences
sequences.private specialized-arrays strings typed alien.data ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:double
IN: benchmark.fasta

CONSTANT: IM 139968
CONSTANT: IA 3877
CONSTANT: IC 29573
CONSTANT: initial-seed 42
CONSTANT: line-length 60

: next-fasta-random ( seed -- seed n )
    IA * IC + IM mod dup IM /f ; inline

CONSTANT: ALU "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGGGAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGACCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAATACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCAGCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGGAGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCCAGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"

CONSTANT: IUB
    {
        { char: a 0.27 }
        { char: c 0.12 }
        { char: g 0.12 }
        { char: t 0.27 }

        { char: B 0.02 }
        { char: D 0.02 }
        { char: H 0.02 }
        { char: K 0.02 }
        { char: M 0.02 }
        { char: N 0.02 }
        { char: R 0.02 }
        { char: S 0.02 }
        { char: V 0.02 }
        { char: W 0.02 }
        { char: Y 0.02 }
    }

CONSTANT: homo-sapiens
    {
        { char: a 0.3029549426680 }
        { char: c 0.1979883004921 }
        { char: g 0.1975473066391 }
        { char: t 0.3015094502008 }
    }

TYPED: make-cumulative ( freq -- chars: byte-array floats: double-array )
    [ keys >byte-array ]
    [ values c:double >c-array 0.0 [ + ] accumulate* ] bi ;

:: select-random ( seed chars floats -- seed elt )
    seed next-fasta-random floats [ <= ] with find drop chars nth-unsafe ; inline

TYPED: make-random-fasta ( seed: float len: fixnum chars: byte-array floats: double-array -- seed: float )
    $[ _ _ select-random ] "" replicate-as print ;

: write-description ( desc id -- )
    ">" write write bl print ;

:: split-lines ( n quot -- )
    n line-length /mod
    [ [ line-length quot call ] times ] dip
    quot unless-zero ; inline

TYPED: write-random-fasta ( seed: float n: fixnum chars: byte-array floats: double-array desc id -- seed: float )
    write-description
    $[ _ _ make-random-fasta ] split-lines ;

TYPED:: make-repeat-fasta ( k: fixnum len: fixnum alu: string -- k': fixnum )
    alu length set: kn
    len iota [ k + kn mod alu nth-unsafe ] "" map-as print
    k len + ;

: write-repeat-fasta ( n alu desc id -- )
    write-description
    let[
        set: alu
        0 set: k!
        |[ len | k len alu make-repeat-fasta k! ] split-lines
    ] ;

: fasta ( n out -- )
    homo-sapiens make-cumulative
    IUB make-cumulative
    let[
        set: ( n out IUB-chars IUB-floats homo-sapiens-chars homo-sapiens-floats )
        initial-seed set: seed

        out ascii [
            n 2 * ALU "Homo sapiens alu" "ONE" write-repeat-fasta

            initial-seed

            n 3 * homo-sapiens-chars homo-sapiens-floats
            "IUB ambiguity codes" "TWO" write-random-fasta

            n 5 * IUB-chars IUB-floats
            "Homo sapiens frequency" "THREE" write-random-fasta

            drop
        ] with-file-writer
    ] ;

: fasta-benchmark ( -- ) 2500000 reverse-complement-in fasta ;

MAIN: fasta-benchmark
