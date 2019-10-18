USE: kernel

PROVIDE: libs/calendar
{ +files+ {
    { "os-unix.factor" [ unix? ] }
    { "os-win32.factor" [ windows? ] }
    "calendar.factor"
} }
{ +tests+ { "test/calendar.factor" } } ;