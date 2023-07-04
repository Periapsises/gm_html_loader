local htmlFileCache = {}
local responseCallbacks = {}

local function getHTMLFileContentsAsync( fileName, callback )
    if htmlFileCache[fileName] then
        return htmlFileCache[fileName]
    end

    net.Start( "HTMLLoader_GetHTMLFileContents" )
    net.WriteString( fileName )
    net.SendToServer()

    responseCallbacks[fileName] = callback
end

local function onHTMLFileContentsDelivered()
    local fileName = net.ReadString()
    local compressedLength = net.ReadUInt( 32 )

    if compressedLength == 0 then
        print( "[HTML Loader] A server error occured when fetching \"" .. fileName .. "\"!" )
        return
    end

    local compressed = net.ReadData( compressedLength )

    local fileContents = util.Decompress( compressed )
    if not fileContents then
        print( "[HTML Loader] Received invalid file contents for \"" .. fileName .. "\"!" )
        return
    end

    htmlFileCache[fileName] = fileContents

    local callback = responseCallbacks[fileName]
    if callback then
        callback( fileName, fileContents )
        responseCallbacks[fileName] = nil
    end
end

net.Receive( "HTMLLoader_GetHTMLFileContents", onHTMLFileContentsDelivered )

local function patchDHTMLPanel()
    local dhtmlControls = vgui.GetControlTable( "DHTML" )

    function dhtmlControls:OpenFile( fileName )
        local contents = getHTMLFileContentsAsync( fileName, function( fileName, contents )
            if not contents then return end
            self:SetHTML( contents )
        end )
    end

    hook.Remove( "InitPostEntity", "PatchDHTMLPanel" )
end

hook.Add( "InitPostEntity", "PatchDHTMLPanel", patchDHTMLPanel )