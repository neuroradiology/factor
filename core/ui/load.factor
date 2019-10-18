REQUIRES: core/ui/opengl core/ui/freetype ;

PROVIDE: core/ui
{ +files+ {
    "timers.factor"
    "models.factor"
    "backend.factor"
    "gadgets.factor"
    "layouts.factor"
    "hierarchy.factor"
    "gadgets/grids.factor"
    "gadgets/frames.factor"
    "world.factor"
    "text.factor"
    "paint.factor"
    "gestures.factor"
    "commands.factor"
    "gadgets/controls.factor"
    "gadgets/grid-lines.factor"
    "gadgets/theme.factor"
    "gadgets/labels.factor"
    "gadgets/borders.factor"
    "gadgets/menus.factor"
    "gadgets/buttons.factor"
    "gadgets/sliders.factor"
    "gadgets/viewports.factor"
    "gadgets/scrolling.factor"
    "gadgets/tracks.factor"
    "gadgets/incremental.factor"
    "gadgets/paragraphs.factor"
    "gadgets/outliner.factor"
    "gadgets/presentations.factor"
    "gadgets/lists.factor"
    "gadgets/panes.factor"
    "gadgets/labelled-gadget.factor"
    "gadgets/books.factor"
    "text/document.factor"
    "text/elements.factor"
    "text/editor.factor"
    "text/commands.factor"
    "windows.factor"
    "debugger.factor"
    "ui.factor"
    "backend.facts"
    "commands.facts"
    "debugger.facts"
    "gadgets.facts"
    "gestures.facts"
    "hierarchy.facts"
    "layouts.facts"
    "models.facts"
    "paint.facts"
    "text.facts"
    "timers.facts"
    "ui.facts"
    "world.facts"
    "windows.facts"
    "gadgets/books.facts"
    "gadgets/borders.facts"
    "gadgets/buttons.facts"
    "gadgets/controls.facts"
    "gadgets/frames.facts"
    "gadgets/grid-lines.facts"
    "gadgets/grids.facts"
    "gadgets/incremental.facts"
    "gadgets/labelled-gadget.facts"
    "gadgets/labels.facts"
    "gadgets/lists.facts"
    "gadgets/menus.facts"
    "gadgets/outliner.facts"
    "gadgets/panes.facts"
    "gadgets/presentations.facts"
    "gadgets/scrolling.facts"
    "gadgets/sliders.facts"
    "gadgets/tracks.facts"
    "gadgets/viewports.facts"
    "text/document.facts"
    "text/editor.facts"
    "text/elements.facts"
} }
{ +tests+ {
    "test/editor.factor"
    "test/gadgets.factor"
    "test/models.factor"
    "test/document.factor"
    "test/lists.factor"
    "test/rectangles.factor"
    "test/commands.factor"
    "test/panes.factor"
    "test/presentations.factor"
    "test/scrolling.factor"
    "test/search.factor"
    "test/sliders.factor"
} } ;