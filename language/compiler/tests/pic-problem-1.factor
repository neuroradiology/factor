USING: kernel sequences prettyprint memory tools.test ;
IN: compiler.tests.pic-problem-1

TUPLE: x ;

M: x length drop 0 ;

INSTANCE: x sequence

COMPILE< gc COMPILE>

CONSTANT: blah T{ x }

[ T{ x } ] [ blah ] unit-test
