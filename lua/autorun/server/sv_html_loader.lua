util.AddNetworkString( "HTMLLoader_GetHTMLFileContents" )

local htmlFileCache = {}

local function sendHTMLFileContents( ply, fileName, fileContents )
    net.Start( "HTMLLoader_GetHTMLFileContents" )

    local compressed = util.Compress( fileContents )
    local compressedLength = #compressed

    net.WriteString( fileName )
    net.WriteUInt( compressedLength, 32 )
    net.WriteData( compressed, compressedLength )

    net.Send( ply )
end

local function sendError( ply, fileName )
    net.Start( "HTMLLoader_GetHTMLFileContents" )
    net.WriteString( fileName )
    net.WriteUInt( 0, 32 )
    net.Send( ply )
end

local function compileHTMLFile( filePath )
    local fileContents = file.Read( filePath, "LUA" )
    if not fileContents then return end

    -- Replace <scripts> for which the src is not an http(s):// or an asset:// with the contents of the file pointed to by the src
    fileContents = fileContents:gsub( "(<script src=\".-\"></script>)", function( script )
        local src = script:match( "src=\"(.-)\"" )
        if src:StartsWith( "http://" ) or src:StartsWith( "https://" ) or src:StartsWith( "asset://" ) then
            return script
        end

        local srcFilePath = "html/includes/" .. src .. ".lua"
        if not file.Exists( srcFilePath, "LUA" ) then
            print( "[HTML Loader] File \"" .. src .. "\" doesn't exist!" )
            return script
        end

        local srcFileContents = file.Read( srcFilePath, "LUA" )
        if not srcFileContents then
            print( "[HTML Loader] File \"" .. src .. "\" couldn't be read!" )
            return script
        end

        return "<script>\n" .. srcFileContents .. "\n</script>"
    end )

    -- Replace <links> for which the href is not an http(s):// or an asset:// with the contents of the file pointed to by the href
    fileContents = fileContents:gsub( "(<link.-href=\".-\">)", function( link )
        local href = link:match( "href=\"(.-)\"" )
        if href:StartsWith( "http://" ) or href:StartsWith( "https://" ) or href:StartsWith( "asset://" ) then
            return link
        end

        local hrefFilePath = "html/includes/" .. href .. ".lua"
        if not file.Exists( hrefFilePath, "LUA" ) then
            print( "[HTML Loader] File \"" .. href .. "\" doesn't exist!" )
            return link
        end

        local hrefFileContents = file.Read( hrefFilePath, "LUA" )
        if not hrefFileContents then
            print( "[HTML Loader] File \"" .. href .. "\" couldn't be read!" )
            return link
        end

        return "<style>\n" .. hrefFileContents .. "\n</style>"
    end )

    return fileContents
end

local function onClientRequestsHTMLContents( _, ply )
    local fileName = net.ReadString()

    if not fileName or fileName == "" then
        print( "[HTML Loader] Player \"" .. ply:Nick() .. "\" requested an empty file name!" )
        sendError( ply, fileName )
        return
    end

    if not ( fileName:EndsWith( ".html" ) or fileName:EndsWith( ".js" ) or fileName:EndsWith( ".css" ) ) then
        print( "[HTML Loader] Player \"" .. ply:Nick() .. "\" requested a file that doesn't end with .html, .js or .css!" )
        sendError( ply, fileName )
        return
    end

    if htmlFileCache[fileName] then
        sendHTMLFileContents( ply, fileName, htmlFileCache[fileName] )
        return
    end

    local filePath = "html/includes/" .. fileName .. ".lua"
    if not file.Exists( filePath, "LUA" ) then
        print( "[HTML Loader] Player \"" .. ply:Nick() .. "\" requested a file that doesn't exist!" )
        sendError( ply, fileName )
        return
    end

    local fileContents = compileHTMLFile( filePath )
    if not fileContents then
        print( "[HTML Loader] Player \"" .. ply:Nick() .. "\" requested a file that couldn't be read!" )
        sendError( ply, fileName )
        return
    end

    htmlFileCache[fileName] = fileContents
    sendHTMLFileContents( ply, fileName, fileContents )
end

net.Receive( "HTMLLoader_GetHTMLFileContents", onClientRequestsHTMLContents )