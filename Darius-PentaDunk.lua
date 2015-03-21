if myHero.charName ~= "Darius" then return end 

local  DariusPentaDunk_Version = 1.5

class "SxUpdate"
function SxUpdate:__init(LocalVersion, Host, VersionPath, ScriptPath, SavePath, Callback)
    self.Callback = Callback
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = VersionPath
    self.ScriptPath = ScriptPath
    self.SavePath = SavePath
    self.LuaSocket = require("socket")
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function SxUpdate:GetOnlineVersion()
    if not self.OnlineVersion and not self.VersionSocket then
        self.VersionSocket = self.LuaSocket.connect("sx-bol.eu", 80)
        self.VersionSocket:send("GET /BoL/TCPUpdater/GetScript.php?script="..self.Host..self.VersionPath.."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
    end

    if not self.OnlineVersion and self.VersionSocket then
        self.VersionSocket:settimeout(0, 'b')
        self.VersionSocket:settimeout(99999999, 't')
        self.VersionReceive, self.VersionStatus = self.VersionSocket:receive('*a')
    end

    if not self.OnlineVersion and self.VersionSocket and self.VersionStatus ~= 'timeout' then
        if self.VersionReceive then
            self.OnlineVersion = tonumber(string.sub(self.VersionReceive, string.find(self.VersionReceive, "<bols".."cript>")+11, string.find(self.VersionReceive, "</bols".."cript>")-1))
        else
            print('AutoUpdate Failed')
            self.OnlineVersion = 0
        end
        self:DownloadUpdate()
    end
end

function SxUpdate:DownloadUpdate()
    if self.OnlineVersion > self.LocalVersion then
        self.ScriptSocket = self.LuaSocket.connect("sx-bol.eu", 80)
        self.ScriptSocket:send("GET /BoL/TCPUpdater/GetScript.php?script="..self.Host..self.ScriptPath.."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
        self.ScriptReceive, self.ScriptStatus = self.ScriptSocket:receive('*a')
        self.ScriptRAW = string.sub(self.ScriptReceive, string.find(self.ScriptReceive, "<bols".."cript>")+11, string.find(self.ScriptReceive, "</bols".."cript>")-1)
        local ScriptFileOpen = io.open(self.SavePath, "w+")
        ScriptFileOpen:write(self.ScriptRAW)
        ScriptFileOpen:close()
    end

    if type(self.Callback) == 'function' then
        self.Callback(self.OnlineVersion)
    end
end

local ForceReload = false
SxUpdate(DariusPentaDunk_Version,
	"raw.githubusercontent.com",
	"/AMBER17/BoL/master/Darius-PentaDunk.version",
	"/AMBER17/BoL/master/Darius-PentaDunk.lua",
	SCRIPT_PATH.."/" .. GetCurrentEnv().FILE_NAME,
	function(NewVersion) if NewVersion > DariusPentaDunk_Version then print("<font color=\"#F0Ff8d\"><b>Darius PentaDunk : </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true else print("<font color=\"#F0Ff8d\"><b>Darius PentaDunk : </b></font> <font color=\"#FF0F0F\">You have the Latest Version</b></font>") end 
end)
	
if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
	require("SxOrbWalk")
else
	SxUpdate(0,
		"raw.githubusercontent.com",
		"/Superx321/BoL/master/common/SxOrbWalk.Version",
		"/Superx321/BoL/master/common/SxOrbWalk.lua",
		LIB_PATH.."/SxOrbWalk.lua",
		function(NewVersion) if NewVersion > 0 then print("<font color=\"#F0Ff8d\"><b>SxOrbWalk: </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true end 
	end)
end
	
if FileExist(LIB_PATH .. "/VPrediction.lua") then
	require("VPrediction")
	VP = VPrediction()
	if VP.version >= 3 then	
		SxUpdate(0,
			"raw.githubusercontent.com",
			"/SidaBoL/Scripts/blob/master/Common/VPrediction.version",
			"/SidaBoL/Scripts/blob/master/Common/VPrediction.lua",
			LIB_PATH.."/VPrediction.lua",
			function(NewVersion) if NewVersion > 0 then print("<font color=\"#F0Ff8d\"><b>VPrediction: </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true end 
		end)
	end
else
	SxUpdate(0,
		"raw.githubusercontent.com",
		"/SidaBoL/Scripts/blob/master/Common/VPrediction.version",
		"/SidaBoL/Scripts/blob/master/Common/VPrediction.lua",
		LIB_PATH.."/VPrediction.lua",
		function(NewVersion) if NewVersion > 0 then print("<font color=\"#F0Ff8d\"><b>VPrediction: </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true end 
	end)
end

function OnLoad()
	print("<b><font color=\"#FF001E\">| Darius PentaDunk|</font></b><font color=\"#FF980F\"> Have a Good Game </font><font color=\"#FF001E\">| AMBER |</font>")
	TargetSelector = TargetSelector(TARGET_LOW_HP , 600, DAMAGE_PHYSICAL, false, true)
	Variables()
	Menu()
end

function OnTick()

	ComboKey = Settings.combo.comboKey	
	TargetSelector:update()
	Target = GetCustomTarget()
	SxOrb:ForceTarget(Target)
	
	if Target ~= nil then
		if ComboKey then
			Combo(Target)
		end
	end
	Checks()
	KillSteal()
	CastAutoE()
end

function Checks()
	SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
	SkillW.ready = (myHero:CanUseSpell(_W) == READY)
	SkillE.ready = (myHero:CanUseSpell(_E) == READY)
	SkillR.ready = (myHero:CanUseSpell(_R) == READY)

	 _G.DrawCircle = _G.oldDrawCircle 
	 
end

function Variables()
	SkillQ = { name = "Decimate", range = 420, delay = 0.2, speed = math.huge, width = 410, ready = false }
	SkillW = { name = "Crippling Strike", range = 145, delay = 0.2, speed = math.huge, width = nil, ready = false }
	SkillE = { name = "Apprehend", range = 540 , delay = 0.2, speed = math.huge, width = 10, ready = false }
	SkillR = { name = "Noxian Guillotine", range = 480, delay = 0.2, speed = math.huge, width = nil, ready = false }
	
	DariusP = 0

	VP = VPrediction()
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	
end


function DrawCircle2(x, y, z, radius, color)
  local vPos1 = Vector(x, y, z)
  local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
  local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
end

function OnDraw()

	if not myHero.dead and not Settings.drawing.mDraw then	
		if ValidTarget(Target) then 
			if Settings.drawing.text then 
				DrawText3D("Current Target",Target.x-100, Target.y-50, Target.z, 20, 0xFFFFFF00)
			end
			if Settings.drawing.targetcircle then 
				DrawCircle(Target.x, Target.y, Target.z, 150, RGB(Settings.drawing.qColor[2], Settings.drawing.qColor[3], Settings.drawing.qColor[4]))
			end
		end
	
	
		if SkillQ.ready and Settings.drawing.qDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, RGB(Settings.drawing.qColor[2], Settings.drawing.qColor[3], Settings.drawing.qColor[4]))
		end
		
		if SkillE.ready and Settings.drawing.eDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, RGB(Settings.drawing.eColor[2], Settings.drawing.eColor[3], Settings.drawing.eColor[4]))
		end
		
		if SkillR.ready and Settings.drawing.rDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillR.range, RGB(Settings.drawing.rColor[2], Settings.drawing.rColor[3], Settings.drawing.rColor[4]))
		end
		
		if Settings.drawing.myHero then
			DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range, RGB(Settings.drawing.myColor[2], Settings.drawing.myColor[3], Settings.drawing.myColor[4]))
		end
	end
end

function GetCustomTarget()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, 1000) and (Ignore == nil or (Ignore.networkID ~= SelectedTarget.networkID)) then
		return SelectedTarget
	end
	TargetSelector:update()	
	if TargetSelector.target and not TargetSelector.target.dead and TargetSelector.target.type == myHero.type then
		return TargetSelector.target
	else
		return nil
	end
end

function OnWndMsg(Msg, Key)	

	if Msg == WM_LBUTTONDOWN then
		local minD = 0
		local Target = nil
		for i, unit in ipairs(GetEnemyHeroes()) do
			if ValidTarget(unit) then
				if GetDistance(unit, mousePos) <= minD or Target == nil then
					minD = GetDistance(unit, mousePos)
					Target = unit
				end
			end
		end

		if Target and minD < 115 then
			if SelectedTarget and Target.charName == SelectedTarget.charName then
				SelectedTarget = nil
			else
				SelectedTarget = Target
			end
		end
	end
end


function Combo(unit)

	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		
		if Settings.combo.UseQ then
			CastQ(unit)
		end
		if Settings.combo.UseW then
			CastW(unit)
		end
		if Settings.combo.UseE then
			CastE(unit)
		end
		if Settings.combo.UseR then
			CastR(unit)
		end
	end
end

function KillSteal(unit)
	for _, unit in pairs(GetEnemyHeroes()) do
		if ValidTarget(unit) then
			if GetDistance(unit) <= SkillR.range and SkillR.ready then
				local health = unit.health
				local dmgQ = getDmg("Q", unit, myHero)
				local dmgR = getDmg("R", unit, myHero)
				dmgR = dmgR + (dmgR*(0.2*DariusP))
				if Settings.KillSteal.UseQ then 
					if health < dmgQ*0.95 and ValidTarget(unit) then
						Packet("S_CAST", {spellId = _Q, targetNetworkId = unit.networkID}):send()
					end
				end
				if Settings.KillSteal.UseR then
					if health < dmgR*0.95 and ValidTarget(unit) then
						Packet("S_CAST", {spellId = _R, targetNetworkId = unit.networkID}):send()
					end
				end
			end
		end
	end
end


function CastQ(unit)
	if GetDistance(unit) <= SkillQ.range and SkillQ.ready then
		Packet("S_CAST", {spellId = _Q}):send()
	end	
end	
	
function CastW(unit)
	if GetDistance(unit) <= 200 and SkillW.ready then
		Packet("S_CAST", {spellId = _W}):send()
	end
end


function CastE(unit)
	if GetDistance(unit) <= (SkillE.range-30) and GetDistance(unit) >= 200 and SkillE.ready then
		CastPosition,  HitChance,  Position = VP:GetConeAOECastPosition(unit, SkillE.delay, 40, SkillE.range, SkillE.speed, myHero, false)	
		if HitChance >= 2 then
			Packet("S_CAST", {spellId = _E, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
		end
	end
end




function CastR(unit)
if GetDistance(unit) <= SkillR.range and SkillR.ready then
	if ValidTarget(unit) then
		local health = unit.health
		local dmgR = getDmg("R", unit, myHero)
		dmgR = dmgR + (dmgR*(0.2*DariusP))
			if health < dmgR*0.95 and ValidTarget(unit) then
				Packet("S_CAST", {spellId = _R, targetNetworkId = unit.networkID}):send()
			end
		end
	end
end

function CastAutoE()
if SkillE.ready then
if Settings.AutoUlt.UseAutoE then
	for _, unit in pairs(GetEnemyHeroes()) do
			local rPos, HitChance, maxHit, Positions = VP:GetConeAOECastPosition(unit, SkillE.delay, 40, SkillE.range, SkillE.speed, myHero, false)	
			if ValidTarget(unit, SkillE.range) and rPos ~= nil and maxHit >= Settings.AutoUlt.ARX then
					Packet("S_CAST", {spellId = _E, fromX = rPos.x, fromY = rPos.z, toX = rPos.x, toY = rPos.z}):send()
			end
		end
	end
end
end




function Menu()
	Settings = scriptConfig("| | Darius | |", "AMBER")
	
	Settings:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Settings.combo:addParam("UseQ", "Use (Q) in combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("UseW", "Use (W) in combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("UseE", "Use (E) in combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("UseR", "Use (R) in combo", SCRIPT_PARAM_ONOFF, true)
		
	Settings:addSubMenu("["..myHero.charName.."] - KillSteal Settings", "KillSteal")
		Settings.KillSteal:addParam("UseQ", "Use (Q) for KS", SCRIPT_PARAM_ONOFF, true)
		Settings.KillSteal:addParam("UseR", "Use (R) for KS", SCRIPT_PARAM_ONOFF, true)
		
	Settings:addSubMenu("["..myHero.charName.."] - Auto E ", "AutoUlt")
		Settings.AutoUlt:addParam("UseAutoE", "Auto E if X unite", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("V"))
		Settings.AutoUlt:addParam("ARX", "X = ", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
		
	
	Settings:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing")	
		Settings.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		Settings.drawing:addParam("myHero", "Draw My Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("myColor", "Draw My Range Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("qDraw", "Draw "..SkillQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("qColor", "Draw "..SkillQ.name.." (Q) Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("eDraw", "Draw "..SkillE.name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("eColor", "Draw "..SkillE.name.." (E) Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("rDraw", "Draw "..SkillR.name.." (R) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("rColor", "Draw "..SkillR.name.." (R) Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("text", "Draw Current Target", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("targetcircle", "Draw Circle On Target", SCRIPT_PARAM_ONOFF, true)
		
		
	Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
		SxOrb:LoadToMenu(Settings.Orbwalking)
	
		Settings.combo:permaShow("comboKey")
		Settings.combo:permaShow("UseR")
		Settings.KillSteal:permaShow("UseQ")
		Settings.KillSteal:permaShow("UseR")
		Settings.AutoUlt:permaShow("UseAutoE")
	
	TargetSelector.name = "Darius"
	Settings:addTS(TargetSelector)
	
end

function OnApplyBuff(source, unit, buff)

	if buff.name=="dariushemo" and unit == Target and source.isMe then
		DariusP = 1
	end
	
end

function OnRemoveBuff(unit,buff)

	if buff.name=="dariushemo" and unit.type == myHero.type then
		DariusP = 0
	end
	
end



--[[OnUpdateBuff]]--
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQP9AAAACwAMAApAQIAKgMCACgDBgQqAwYIKAMKDCoDChAoAw4UKgMOGCgDEhwqAxIgKwESICkBFigrARYsKQEaMCsBGjQpAR44KwEePCkBIkArAQ5EKAMmRCkBJhArASZMKQEqUCsBKlQpAS5YKgEuXCgDMlwqAzJgKAM2ZCoDNmgoAzpsKgM6cCgDPnQqAz54KANCfCoDQoArA0I8KAECiCoDRogoA0qMKgNKkCgDTpQqA06YKANSnCkBUnwpATKkKANWpCkDViwrAVasKAFaCCkDWqArAVq0KAFeHCoDXrgoA2K8KgNiwCsDYiQqAVrIKgNmyCkDPswpAWrQKgFqdCgDbtQrA0rYKwFu3CkBcuAqAXJ4KwFyFCkBdugrAXbsKAF6xCgDHvAqASr0KwF6sCsBOvgoAUZIKQF+jCsBfvwpAYMAKgF7BCkBRmQrAV6oKAOHBCoDhwgoA4sMKQNLECsBaxQrA4MUKAGObCkDQxgrAY8cKQFvICoDkyApA08kKQGXKCgDkuwrAZcsKQGbMCsBmzQoAX68KwFnOCsDhzgrAZ88KwEGnCkBo0AqAaMkKAOnRCkDC0gqA6YwKwOLTCoBG1AqA6tQKAOW5CgDLzwrAwtUKgFucCkBr1grAa9cKwMvXCgDslgpAbIEKgOzKCsBIgwoA3dkKgGuzCkBh2gqA7doKwMzbCkBu3AoAZt0KQOTdCgDvxwpAb9MKwG/fCsBU4AoAyN4KgPDgCsDwqgqA58AKQHHiCoDJtwrAceMKQHLkCkBn5QrA8pMKAGfmCgDG5grA6KEKgPPcCsBAqAqA3ecKAHThCkDp6ArAdOkKAGq1CoBm6goA6KwKgO+rCkDB6gqAdaUKQNnhCkBtuQrA7r4KAPbrCkDD2ArA7OwKQHPnCoBF7QrA5LoKgHHZCgD37QqA9+4KwHfVCgB4xAqA+PAKQGrCCkBe6wqA4/EKQOPiCkD3ywoAedEKQPDyCoD57wqA9PMKQHT0CoBViQpA15QKQM7QCoD69AoA8ZAKwHruCgDaigpA9bgKwGmhCgD7jgrA9cwKAHquCkB78QqA4OkKwGr3CsB7pgpARNIKgFT4CgDr+ArAfPkKgHbeCgB9hgpA/b8KQHz7CsB26AoA8LQKANz7CgBtvAqAe/UKQFj8CoBu7ArA+PoKAGDzCkB+9gqAYv0KwP7kCsBP2AoA/r0KAPz1CoBHxgoAf8MKQPn3CkD/9gqASLAKAMqtCoB9/grAzfkKAMX8CoB/mgrAf+8KgHLwCsB52woAcqQKAFnyCoDf1goAbqAKgPz+CsBTmApAzc0KwPPfCsBt/wrAffoKAPXjQQBAAKUAAAAIgIAAHwCAAAEBAAADAAAAAACAQ0ADAAAAAAAAAEADAAAAAAAACEADAAAAAADgYkADAAAAAAAAEEADAAAAAAAAZEADAAAAAAAAFEADAAAAAABAWkADAAAAAAAAGEADAAAAAABAW0ADAAAAAAAAHEADAAAAAAAAXUADAAAAAAAAIEADAAAAAADAZEADAAAAAAAAIkADAAAAAAAANEADAAAAAAAAJEADAAAAAABgaUADAAAAAAAAJkADAAAAAAAAKEADAAAAAABAbUADAAAAAAAAKkADAAAAAAAgZUADAAAAAAAALEADAAAAAACAYkADAAAAAAAALkADAAAAAAAAXEADAAAAAAAAMEADAAAAAABAUkADAAAAAAAAMUADAAAAAABAbEADAAAAAAAAMkADAAAAAAAgYUADAAAAAAAAM0ADAAAAAADAbEADAAAAAAAAX0ADAAAAAAAANUADAAAAAAAANkADAAAAAADAYUADAAAAAAAAN0ADAAAAAADgbEADAAAAAAAAOEADAAAAAACAUkADAAAAAAAAOUADAAAAAADAXEADAAAAAAAAOkADAAAAAAAAO0ADAAAAAAAAXkADAAAAAAAAPEADAAAAAACAR0ADAAAAAAAAPUADAAAAAAAgYEADAAAAAAAAPkADAAAAAACgbkADAAAAAAAAP0ADAAAAAAAgbUADAAAAAAAAQEADAAAAAACgZ0ADAAAAAACAQEADAAAAAAAAU0ADAAAAAAAAQUADAAAAAACATkADAAAAAACAQUADAAAAAADga0ADAAAAAAAAQkADAAAAAADAVkADAAAAAACAQkADAAAAAAAAQ0ADAAAAAABAU0ADAAAAAACAVEADAAAAAAAAREADAAAAAACgb0ADAAAAAACAREADAAAAAADAVUADAAAAAAAARUADAAAAAABAUEADAAAAAACARUADAAAAAADAV0ADAAAAAAAARkADAAAAAACAbkADAAAAAACARkADAAAAAAAAR0ADAAAAAACAaUADAAAAAAAAYUADAAAAAAAASEADAAAAAACASEADAAAAAABgZ0ADAAAAAAAASUADAAAAAACASUADAAAAAAAASkADAAAAAACATUADAAAAAACASkADAAAAAAAAS0ADAAAAAACAZ0ADAAAAAACAS0ADAAAAAADAVEADAAAAAAAATEADAAAAAAAAa0ADAAAAAACATEADAAAAAAAATUADAAAAAAAAbkADAAAAAABAZEADAAAAAAAATkADAAAAAACAWUADAAAAAAAgaEADAAAAAAAAT0ADAAAAAACAT0ADAAAAAAAAVkADAAAAAAAAUEADAAAAAABAV0ADAAAAAABAXUADAAAAAACAUEADAAAAAACgakADAAAAAADAUEADAAAAAAAAUUADAAAAAABAUUADAAAAAABAX0ADAAAAAACAUUADAAAAAAAAY0ADAAAAAADAUUADAAAAAAAAUkADAAAAAABAZkADAAAAAABAVEADAAAAAADAUkADAAAAAABAWUADAAAAAACAU0ADAAAAAAAgbkADAAAAAADAU0ADAAAAAABga0ADAAAAAAAAVEADAAAAAAAAaUADAAAAAABAVkADAAAAAAAAVUADAAAAAADAX0ADAAAAAABAVUADAAAAAADAWUADAAAAAACAVUADAAAAAAAA8D8DAAAAAACga0ADAAAAAADAW0ADAAAAAACAVkADAAAAAACAZkADAAAAAABgZkADAAAAAAAAV0ADAAAAAABAWEADAAAAAACAYEADAAAAAACAV0ADAAAAAABAZUADAAAAAACAXEADAAAAAAAAWEADAAAAAAAAAAADAAAAAACAWEADAAAAAABgYEADAAAAAADAWEADAAAAAACgY0ADAAAAAAAAWUADAAAAAABgYkADAAAAAAAgYkADAAAAAACAYUADAAAAAAAAWkADAAAAAADAY0ADAAAAAACAWkADAAAAAADAWkADAAAAAACgYkADAAAAAAAAW0ADAAAAAABAY0ADAAAAAACAW0ADAAAAAABgaEADAAAAAACAY0ADAAAAAAAgZkADAAAAAABAXEADAAAAAAAgaUADAAAAAACgaUADAAAAAACAXUADAAAAAACAX0ADAAAAAADAXUADAAAAAABAXkADAAAAAACAXkADAAAAAADAXkADAAAAAADgZEADAAAAAADAakADAAAAAABgZEADAAAAAAAAYEADAAAAAADgbkADAAAAAABAbkADAAAAAABAYEADAAAAAAAga0ADAAAAAACAZEADAAAAAACgYEADAAAAAADAYEADAAAAAADgY0ADAAAAAADgYEADAAAAAACAakADAAAAAADgZkADAAAAAABAYUADAAAAAABgYUADAAAAAADgZ0ADAAAAAACgYUADAAAAAABgZUADAAAAAADgYUADAAAAAADgbUADAAAAAAAAYkADAAAAAACgbUADAAAAAABAYkADAAAAAABgb0ADAAAAAAAAZUADAAAAAADAYkADAAAAAADAbkADAAAAAAAgY0ADAAAAAABAZ0ADAAAAAAAgZ0ADAAAAAABgY0ADAAAAAAAgb0ADAAAAAABAaEADAAAAAAAgZEADAAAAAACgaEADAAAAAACgZEADAAAAAACAb0ADAAAAAADgaUADAAAAAABgakADAAAAAACAZUADAAAAAACgZkADAAAAAACgZUADAAAAAADAZUADAAAAAADgZUADAAAAAADAb0ADAAAAAAAAZkADAAAAAABAa0ADAAAAAADAZkADAAAAAACAbEADAAAAAAAAZ0ADAAAAAADAbUADAAAAAADAaEADAAAAAADgb0ADAAAAAADAZ0ADAAAAAAAAaEADAAAAAACAaEADAAAAAADgaEADAAAAAADgakADAAAAAABAaUADAAAAAAAgbEADAAAAAABAakADAAAAAABgbkADAAAAAADAaUADAAAAAAAAakADAAAAAAAgakADAAAAAAAAbUADAAAAAAAAb0ADAAAAAAAAbEADAAAAAACAa0ADAAAAAABAb0ADAAAAAADAa0ADAAAAAABgbEADAAAAAACgbEADAAAAAABgbUADAAAAAACAbUAEDQAAAE9uUmVjdlBhY2tldAABAAAAAwAAAAcAAAABAAYeAAAARwBAABhAwAAXQAaACsBAgUYAQQBMQMEAzIBBAN0AAAFdgAAACsBBgYwAQgCdgAABhoCAAApAQoHMgEIA3YAAARjAwgEXgAKABwHDAEZBQwBHAcMCGEABAhdAAYAHgcMARkFDAEeBwwJYQAECFwAAgAiAgIcfAIAAEAAAAAQHAAAAaGVhZGVyAAMAAAAAAIBDQAQEAAAAcG9zAAMAAAAAAAAAQAQLAAAAb2JqTWFuYWdlcgAEFQAAAEdldE9iamVjdEJ5TmV0d29ya0lkAAQIAAAARGVjb2RlRgADAAAAAAAAJkAECAAAAERlY29kZTEAAwAAAAAAADBABAgAAABEZWNvZGU0AAMAAOBUfzzkQQQFAAAAdHlwZQAEBwAAAG15SGVybwAEBQAAAHRlYW0ABAgAAABEYXJpdXNQAAAAAAACAAAAAAABABAAAABAb2JmdXNjYXRlZC5sdWEAHgAAAAQAAAAEAAAABAAAAAQAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAQAAAACAAAAYwAAAAAAHgAAAAIAAABkAAkAAAAdAAAAAwAAAF9hAA0AAAAdAAAAAwAAAGFhABAAAAAdAAAAAgAAAAUAAABfRU5WAAIAAABiAAEAAAABABAAAABAb2JmdXNjYXRlZC5sdWEA/QAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAAHAAAAAwAAAAcAAAABAAAAAgAAAGIA+QAAAP0AAAABAAAABQAAAF9FTlYA"), nil, "bt", _ENV))()

assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("REHFFLDJLGK") 
