# Garry's Mod HTML Loader
Custom HTML loader for DHTML Panels

## What is GM HTML Loader?

Since `.html` files cannot be uploaded to the workshop and therefore need some workaround to include in an addon, this dependency adds a custom method to the `DHTML` panel that lets developers load HTML from a file that can be uploaded to the workshop safely.

## How does it work?

Addon makers can create HTML file with a `.lua` extension under the `lua/html/includes/` path.  
These files will automatically be included and networked to clients and are then available to load and display on a DHTML.  
The function used to make this work is `DHTML:OpenFile( fileName )` where the `fileName` is the name of the file without the `lua/html/includes/` and `.lua` extension.

For instance if we created a file `lua/html/includes/index.html.lua` we could display it like so:
```lua
local frame = vgui.Create( "DFrame" )
frame:SetSize( ScrW() * 0.5, ScrH() * 0.5 )
frame:SetTitle( "My included HTML file!" )
frame:Center()
frame:MakePopup()

local html = vgui.Create( "DHTML", frame )
html:Dock( FILL )
html:OpenFile( "index.html" )
```

## A quick tip

The contents of those HTML files disguised as Lua is purely HTML syntax.  
Therefore a useful setting for those using Visual Studio Code is to add a custom extension to set the display to HTML automatically.  
By using a `.html.lua` extension, one can add the following setting to VSCode:
```json
"files.associations": {
  "*.html.lua": "html"
}
```
