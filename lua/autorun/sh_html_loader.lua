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

if CLIENT then
    local patchHook = "InitPostEntity"
    local patcHookName = "PatchDHTMLPanel"

    local function patchDHTMLPanel()
        local DHTML = vgui.GetControlTable( "DHTML" )

        function DHTML:OpenFile( fileName )
            local fullPath = htmlFilesLocation .. fileName .. ".lua"

            if not file.Exists( path, "LUA" ) then
                ErrorNoHalt( "Could not find HTML file: " .. fileName )
                return
            end

            local html = file.Read( path, "LUA" )
            self:SetHTML( html )
        end

        hook.Remove( patchHook, patcHookName )
    end

    hook.Add( patchHook, patcHookName, patchDHTMLPanel )
end
