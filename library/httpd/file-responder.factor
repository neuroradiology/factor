! Copyright (C) 2004,2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: file-responder
USING: html httpd kernel lists namespaces parser sequences
io strings ;

: serving-path ( filename -- filename )
    [ "" ] unless* "doc-root" get swap append ;

: file-response ( mime-type length -- )
    [
        number>string "Content-Length" swons ,
        "Content-Type" swons ,
    ] [ ] make "200 OK" response terpri ;

: serve-static ( filename mime-type -- )
    over file-length file-response  "method" get "head" = [
        drop
    ] [
        <file-reader> stdio get stream-copy
    ] ifte ;

: serve-file ( filename -- )
    dup mime-type dup "application/x-factor-server-page" = [
        drop run-file
    ] [
        serve-static
    ] ifte ;

: list-directory ( directory -- )
    serving-html
     "method" get "head" = [
        drop
    ] [
        "request" get [ directory. ] simple-html-document
    ] ifte ;

: serve-directory ( filename -- )
    "/" ?tail [
        dup "/index.html" append dup exists? [
            nip serve-file
        ] [
            drop list-directory
        ] ifte
    ] [
        drop directory-no/
    ] ifte ;

: serve-object ( filename -- )
    dup directory? [ serve-directory ] [ serve-file ] ifte ;

: file-responder ( filename -- )
    "doc-root" get [
        serving-path dup exists? [
            serve-object
        ] [
            drop "404 not found" httpd-error
        ] ifte
    ] [
        drop "404 doc-root not set" httpd-error
    ] ifte ;
