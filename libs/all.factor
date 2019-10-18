USING: kernel modules words ;

REQUIRES: libs/alien libs/base64 libs/basic-authentication libs/cairo
libs/calendar libs/concurrency libs/coroutines libs/crypto
libs/dlists libs/emacs libs/farkup libs/fjsc libs/furnace libs/gap-buffer
libs/hardware-info libs/http libs/httpd libs/http-client
libs/jedit libs/jni libs/json libs/levenshtein 
libs/lazy-lists libs/match libs/math libs/parser-combinators
libs/porter-stemmer libs/postgresql libs/process
libs/sequences libs/serialize libs/shuffle
libs/slate libs/splay-trees libs/sqlite libs/textmate
libs/topology libs/units libs/usb libs/vars libs/vim libs/xml
libs/xml-rpc libs/yahoo ;

"x11" vocab [
    "libs/x11" require
] when

"cocoa" vocab [
    "libs/cocoa-callbacks" require
] when

PROVIDE: libs/all ;