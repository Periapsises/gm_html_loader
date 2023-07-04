local string_len, string_find, string_sub, string_match = string.len, string.find, string.sub, string.match

local htmlFilesLocation = "html/includes/"

local function AddCSLuaFilesRecursive( path )
    local files, folders = file.Find( path .. "*", "LUA" )

    for _, file in ipairs( files ) do
        if string.EndsWith( file, ".lua" ) then
            AddCSLuaFile( path .. file )
        end
    end

    for _, folder in ipairs( folders ) do
        AddCSLuaFilesRecursive( path .. folder .. "/" )
    end
end

AddCSLuaFilesRecursive( htmlFilesLocation )

------------------------------------------------------------
-- Client
if SERVER then return end

local patchHookName = "InitPostEntity"
local patchHookIdentifier = "PatchDHTMLPanel"

local function sourceIsValid( src )
    return src and not ( string.StartsWith( src, "asset" ) or string.StartsWith( src, "http" ) )
end

local function replaceJavascript( html )
    local position = 1
    while position < string_len( html ) do
        local start, end_ = string_find( html, "<script.-</script>", position )

        if not start then break end

        local script = string_sub( html, start, end_ )
        local src = string_match( script, 'src="([^"]+)"' )

        if sourceIsValid( src ) then
            local scriptPath = string_match( src, "([^/]+)$" )
            local scriptContent = "<script>\n" .. file.Read( htmlFilesLocation .. scriptPath .. ".lua", "LUA" ) .. "\n</script>"

            html = string_sub( html, 1, start - 1 ) .. scriptContent .. string_sub( html, end_ + 1 )
            position = start + string_len( scriptContent )
        else
            position = end_ + 1
        end
    end

    return html
end

local function replaceStyle( html )
    local position = 1
    while position < string_len( html ) do
        local start, end_ = string_find( html, "<link.->", position )

        if not start then break end

        local link = string_sub( html, start, end_ )
        local href = string_match( link, 'href="([^"]+)"' )

        if sourceIsValid( href ) then
            local linkPath = string_match( href, "([^/]+)$" )
            local linkContent = "<style>\n" .. file.Read( htmlFilesLocation .. linkPath .. ".lua", "LUA" ) .. "\n</style>"

            html = string_sub( html, 1, start - 1 ) .. linkContent .. string_sub( html, end_ + 1 )
            position = start + string_len( linkContent )
        else
            position = end_ + 1
        end
    end

    return html
end

local function patchDHTMLPanel()
    local DHTML = vgui.GetControlTable( "DHTML" )

    function DHTML:OpenFile( fileName )
        local fullPath = htmlFilesLocation .. fileName .. ".lua"

        if not file.Exists( fullPath, "LUA" ) then
            ErrorNoHalt( "Could not find HTML file: " .. fileName )
            return
        end

        local html = file.Read( fullPath, "LUA" )
        html = replaceJavascript( html )
        html = replaceStyle( html )

        self:SetHTML( html )
    end

    hook.Remove( patchHookName, patchHookIdentifier )
end

hook.Add( patchHookName, patchHookIdentifier, patchDHTMLPanel )
