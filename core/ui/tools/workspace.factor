! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-workspace
USING: help arrays compiler gadgets gadgets-books
gadgets-browser gadgets-buttons gadgets-help
gadgets-listener gadgets-presentations gadgets-walker generic
kernel math modules scratchpad sequences syntax words io
namespaces hashtables gadgets-scrolling gadgets-panes
gadgets-messages gadgets-theme errors models ;

C: tool ( gadget -- tool )
    {
        {
            [ dup dup class tool 2array <toolbar> ]
            f
            f
            @top
        }
        {
            f
            set-tool-gadget
            f
            @center
        }
    } make-frame* ;

M: tool focusable-child* tool-gadget ;

M: tool call-tool* tool-gadget call-tool* ;

M: tool tool-scroller tool-gadget tool-scroller ;

M: tool tool-help tool-gadget tool-help ;

: help-window ( topic -- )
    [ [ help ] make-pane <scroller> ] keep
    article-title open-window ;

: tool-help-window ( tool -- )
    tool-help [ help-window ] when* ;

tool "toolbar" {
    { "Tool help" T{ key-down f f "F1" } [ tool-help-window ] }
} define-commands

: workspace-tabs
    {
        { "Listener" <listener-gadget> }
        { "Messages" <messages> }
        { "Definitions" <browser> } 
        { "Documentation" <help-gadget> }
        { "Walker" <walker-gadget> }
    } ;

: <workspace-tabs> ( workspace -- tabs )
    workspace-book control-model
    workspace-tabs dup length [ swap first 2array ] 2map
    <radio-box> ;

: <workspace-book> ( -- gadget )
    workspace-tabs 1 <column> [ execute <tool> ] map <book> ;

M: workspace pref-dim* drop { 550 650 } ;

: hide-popup ( workspace -- )
    dup workspace-popup unparent
    f over set-workspace-popup
    request-focus ;

: show-popup ( gadget workspace -- )
    dup hide-popup
    2dup set-workspace-popup
    dupd add-gadget
    dup popup-theme
    request-focus ;

: show-titled-popup ( workspace gadget title -- )
    [ find-workspace hide-popup ] <closable-gadget>
    swap show-popup ;

: popup-dim ( workspace -- dim )
    rect-dim first2 4 /i 2array ;

: popup-loc ( workspace -- loc )
    dup rect-dim
    over popup-dim v-
    swap rect-loc v+ ;

: layout-popup ( workspace gadget -- )
    over popup-dim over set-gadget-dim
    swap popup-loc swap set-rect-loc ;

: debugger-popup ( error workspace -- )
    swap dup compute-restarts
    [ find-workspace hide-popup ] <debugger>
    "Error" show-titled-popup ;

C: workspace ( -- workspace )
    [ debugger-popup ] over set-workspace-error-hook
    {
        { [ <workspace-book> ] set-workspace-book f @center }
        { [ gadget get <workspace-tabs> ] f f @top }
        { [ gadget get { workspace } <toolbar> ] f f @bottom }
    } make-frame* ;

M: workspace layout*
    dup delegate layout*
    dup workspace-book swap workspace-popup dup
    [ layout-popup ] [ 2drop ] if ;

M: workspace children-on nip gadget-children ;

M: workspace focusable-child* workspace-book ;

: workspace-window ( -- workspace )
    <workspace> dup "Factor workspace" open-window
    listener-gadget get-tool start-listener ;

: tool-window ( class -- ) workspace-window show-tool 2drop ;

M: workspace tool-scroller ( workspace -- scroller )
    workspace-book current-page tool-scroller ;

: tool-scroll-up ( workspace -- )
    tool-scroller [ scroll-up-page ] when* ;

: tool-scroll-down ( workspace -- )
    tool-scroller [ scroll-down-page ] when* ;

[ workspace-window drop ] ui-hook set-global

workspace "scrolling" {
    { "Scroll up" T{ key-down f { C+ } "PAGE_UP" } [ tool-scroll-up ] }
    { "Scroll down" T{ key-down f { C+ } "PAGE_DOWN" } [ tool-scroll-down ] }
} define-commands

workspace "tool-switch" {
    { "Hide popup" T{ key-down f f "ESCAPE" } [ hide-popup ] }
    { "Listener" T{ key-down f f "F2" } [ listener-gadget select-tool ] }
    { "Messages" T{ key-down f f "F3" } [ messages select-tool ] }
    { "Definitions" T{ key-down f f "F4" } [ browser select-tool ] }
    { "Documentation" T{ key-down f f "F5" } [ help-gadget select-tool ] }
    { "Walker" T{ key-down f f "F6" } [ walker-gadget select-tool ] }
} define-commands

workspace "tool-window" {
    { "New listener" T{ key-down f { S+ } "F2" } [ listener-gadget tool-window ] }
    { "New definitions" T{ key-down f { S+ } "F3" } [ browser tool-window ] }
    { "New documentation" T{ key-down f { S+ } "F4" } [ help-gadget tool-window ] }
} define-commands

workspace "workflow" {
    { "Reload changed sources" T{ key-down f f "F8" } [ drop [ reload-modules ] call-listener ] }
    { "Recompile changed words" T{ key-down f { S+ } "F8" } [ drop [ recompile ] call-listener ] }
} define-commands