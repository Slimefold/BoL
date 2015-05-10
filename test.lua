function Update()
ScriptUpdate(
    1.1, -- local Version
    true, -- Using HTTPS (true) or HTTP (false). Github is always true
    'raw.githubusercontent.com',
    "/AMBER17/BoL/master/test.version",
    "/AMBER17/BoL/master/test.lua",
    SCRIPT_PATH.."/" .. GetCurrentEnv().FILE_NAME,
    function(NewVersion,OldVersion) print("<font color=\"#FF794C\"><b>SxOrbWalk: </b></font> <font color=\"#FFDFBF\">Updated to "..NewVersion..". </b></font>") end,
    function() print("<font color=\"#FF794C\"><b>SxOrbWalk: </b></font> <font color=\"#FFDFBF\">No Updates Found</b></font>") end,
    function(NewVersion) print("<font color=\"#FF794C\"><b>SxOrbWalk: </b></font> <font color=\"#FFDFBF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>") end,
    function() print("<font color=\"#FF794C\"><b>SxOrbWalk: </b></font> <font color=\"#FFDFBF\">Error while Downloading. Please try again.</b></font>") end,
    function(DownloadStatus) if DownloadStatus ~= 'Downloading Script (100%)' and DownloadStatus ~= 'Downloading VersionInfo (100%)' then DrawText('Download Status: '..(DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF)) end end
)
end


function OnLoad()
	Update()
end

--Works
