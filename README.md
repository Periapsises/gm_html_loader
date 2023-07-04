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

## Javascript and CSS substitution

When loading an HTML file, imported scripts and stylesheets will automatically be fetched and substituted within the HTML file.  
The only exception is for paths that are `http:`, `https:` and `asset:`.

For example
 - lua/html/includes/index.html.lua
```html
<html>
  <body>
    <script src="index.js"></script>
  </body>
</html>
```
 - lua/html/includes/index.js.lua
```js
console.log( 'Hello, world!" )
```
Will be converted into:
```html
<html>
  <body>
<script>
console.log( 'Hello, world!" )
</script>
  </body>
</html>
```

## A quick tip

The contents of those HTML files disguised as Lua does not contain any Lua syntax. 
Therefore a useful setting for those using Visual Studio Code is to add a custom extension to set the proper language automatically.  
In VSCode, the following setting adds syntax highlighting for these kinds of files:
```json
"files.associations": {
  "*.html.lua": "html",
  "*.js.lua": "javascript"
  "*.css.lua": "css"
}
```
