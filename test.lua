function Update()
ScriptUpdate(
    1.1, -- local Version
    true, -- Using HTTPS (true) or HTTP (false). Github is always true
    'raw.githubusercontent.com',
    "/Superx321/BoL/master/common/SxOrbWalk.Version",
    "/Superx321/BoL/master/common/SxOrbWalk.lua",
    LIB_PATH.."/SxOrbWalk_Test.lua",
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
