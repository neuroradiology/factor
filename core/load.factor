PROVIDE: core
{ +files+ {
    "version.factor"

    "generic/early-generic.factor"

    "kernel.factor"

    "math/math.factor"
    "math/integer.factor"
    "math/ratio.factor"
    "math/libm.factor"
    "math/float.factor"
    "math/complex.factor"

    "collections/sequences.factor"
    "collections/growable.factor"
    "collections/virtual-sequences.factor"
    "collections/sequence-combinators.factor"
    "collections/arrays.factor"
    "collections/sequences-epilogue.factor"
    "collections/strings.factor"
    "collections/sbuf.factor"
    "collections/vectors.factor"
    "collections/hashtables.factor"
    "collections/namespaces.factor"
    "collections/slicing.factor"
    "collections/sequence-sort.factor"
    "collections/flatten.factor"
    "collections/queues.factor"
    "collections/graphs.factor"

    "quotations.factor"

    "math/random.factor"
    "math/constants.factor"
    "math/pow.factor"
    "math/trig-hyp.factor"
    "math/arc-trig-hyp.factor"
    "math/vectors.factor"
    "math/parse-numbers.factor"

    "definitions.factor"
    "words.factor"
    "effects.factor"
    "continuations.factor"
    "errors.factor"
    
    "io/styles.factor"
    "io/stream.factor"
    "io/duplex-stream.factor"
    "io/stdio.factor"
    "io/null-stream.factor"
    "io/nested-style.factor"
    "io/lines.factor"
    "io/plain-stream.factor"
    "io/string-streams.factor"
    "io/c-streams.factor"
    "io/files.factor"
    "io/binary.factor"

    "syntax/early-parser.factor"

    "generic/classes.factor"
    "generic/generic.factor"
    "generic/methods.factor"
    "generic/standard-combination.factor"
    "generic/slots.factor"
    "generic/math-combination.factor"
    "generic/tuple.factor"
    
    "compiler/alien/aliens.factor"
    
    "prettyprint/core.factor"
    "prettyprint/sections.factor"
    "prettyprint/backend.factor"
    "prettyprint/frontend.factor"
    "prettyprint/describe.factor"

    "syntax/parser.factor"
    "syntax/parse-stream.factor"

    "debugger.factor"
    "listener.factor"
    
    "threads.factor"
    "io/server.factor"

    "cli.factor"
    "modules.factor"
    "syntax/parse-syntax.factor"

    "bootstrap/init.factor"

} }
{ +tests+ {
    "test/binary.factor"
    "test/collections/hashtables.factor"
    "test/collections/namespaces.factor"
    "test/collections/queues.factor"
    "test/collections/sbuf.factor"
    "test/collections/sequences.factor"
    "test/collections/strings.factor"
    "test/collections/vectors.factor"
    "test/combinators.factor"
    "test/continuations.factor"
    "test/errors.factor"
    "test/generic.factor"
    "test/init.factor"
    "test/io/io.factor"
    "test/io/nested-style.factor"
    "test/kernel.factor"
    "test/math/bitops.factor"
    "test/math/complex.factor"
    "test/math/float.factor"
    "test/math/integer.factor"
    "test/math/irrational.factor"
    "test/math/math-combinators.factor"
    "test/math/random.factor"
    "test/math/rational.factor"
    "test/parse-number.factor"
    "test/parser.factor"
    "test/parsing-word.factor"
    "test/prettyprint.factor"
    "test/random.factor"
    "test/redefine.factor"
    "test/threads.factor"
    "test/tuple.factor"
    "test/words.factor"
} } ;