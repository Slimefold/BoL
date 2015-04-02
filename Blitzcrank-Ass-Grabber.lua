if myHero.charName ~= "Blitzcrank" then return end	

if VIP_USER and FileExist(LIB_PATH .. "/DivinePred.lua") then 
	require "DivinePred" 
	DP = DivinePred()
	myQ = SkillShot.PRESETS['RocketGrab']
end


class "ScriptUpdate"
function ScriptUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '3' or '4')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '3' or '4')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function ScriptUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('sx-bol.eu', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end

function ScriptUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function ScriptUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end

    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        local recv,sent,time = self.Socket:getstats()
        self.DownloadStatus = 'Downloading VersionInfo (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</size>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</s'..'ize>')-1)) + self.File:len()
        end
        self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*self.File:len(),2)..'%)'
    end
    if not (self.Receive or (#self.Snipped > 0)) and self.RecvStarted and self.Size and math.round(100/self.Size*self.File:len(),2) > 95 then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
        local ContentEnd, _ = self.File:find('</sc'..'ript>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = tonumber(self.File:sub(ContentStart + 1,ContentEnd-1))
            if self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
                self:CreateSocket(self.ScriptPath)
                self.DownloadStatus = 'Connect to Server for ScriptDownload'
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        end
        self.GotScriptVersion = true
    end
end

function ScriptUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        local recv,sent,time = self.Socket:getstats()
        self.DownloadStatus = 'Downloading Script (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1)) + self.File:len()
        end
        self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*self.File:len(),2)..'%)'
    end
    if not (self.Receive or (#self.Snipped > 0)) and self.RecvStarted and math.round(100/self.Size*self.File:len(),2) > 95 then
        self.DownloadStatus = 'Downloading Script (100%)'
        local HeaderEnd, ContentStart = self.File:find('<sc'..'ript>')
        local ContentEnd, _ = self.File:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            local f = io.open(self.SavePath,"w+b")
            f:write(self.File:sub(ContentStart + 1,ContentEnd-1))
            f:close()
            if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
            end
        end
        self.GotScriptUpdate = true
    end
end

function OnLoad()

	CheckScriptUpdate()
	CheckVPred()
	if FileExist(LIB_PATH .. "/VPrediction.lua") then
		CheckSxOrbWalk()
	end
	
	if FileExist(LIB_PATH .. "/VPrediction.lua") and FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
		DelayAction(function()	
			CustomOnLoad()
			AddMsgCallback(CustomOnWndMsg)
			AddApplyBuffCallback(CustomOnApplyBuff)
			AddDrawCallback(CustomOnDraw)		
			AddProcessSpellCallback(CustomOnProcessSpell)
			AddTickCallback(CustomOnTick)
			AddApplyBuffCallback(CustomOnApplyBuff)	
			AddUpdateBuffCallback(CustomOnUpdateBuff)		
		end, 6)
	end
end

function CheckScriptUpdate()
	local ToUpdate = {}
    ToUpdate.Version = 5.1
    ToUpdate.UseHttps = true
	ToUpdate.Name = "Blitzcrank-Ass-Grabber"
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/AMBER17/BoL/master/Blitzcrank-Ass-Grabber.version"
    ToUpdate.ScriptPath =  "/AMBER17/BoL/master/Blitzcrank-Ass-Grabber.lua"
    ToUpdate.SavePath = SCRIPT_PATH.."/" .. GetCurrentEnv().FILE_NAME
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") end
    ToUpdate.CallbackNoUpdate = function(OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">No Updates Found</b></font>") end
    ToUpdate.CallbackNewVersion = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>") end
    ToUpdate.CallbackError = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Error while Downloading. Please try again.</b></font>") end
    ScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	
end

function CheckVPred()
	if FileExist(LIB_PATH .. "/VPrediction.lua") then
		require("VPrediction")
		VP = VPrediction()
	else
		local ToUpdate = {}
		ToUpdate.Version = 0.0
		ToUpdate.UseHttps = true
		ToUpdate.Name = "VPrediction"
		ToUpdate.Host = "raw.githubusercontent.com"
		ToUpdate.VersionPath = "/SidaBoL/Scripts/master/Common/VPrediction.version"
		ToUpdate.ScriptPath =  "/SidaBoL/Scripts/master/Common/VPrediction.lua"
		ToUpdate.SavePath = LIB_PATH.."/VPrediction.lua"
		ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") end
		ToUpdate.CallbackNoUpdate = function(OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">No Updates Found</b></font>") end
		ToUpdate.CallbackNewVersion = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>") end
		ToUpdate.CallbackError = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Error while Downloading. Please try again.</b></font>") end
		ScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	end
end

function CheckSxOrbWalk()
	if not FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
		local ToUpdate = {}
		ToUpdate.Version = 0.0
		ToUpdate.UseHttps = true
		ToUpdate.Name = "SxOrbWalk"
		ToUpdate.Host = "raw.githubusercontent.com"
		ToUpdate.VersionPath = "/Superx321/BoL/master/common/SxOrbWalk.Version"
		ToUpdate.ScriptPath =  "/Superx321/BoL/master/common/SxOrbWalk.lua"
		ToUpdate.SavePath = LIB_PATH.."/SxOrbWalk.lua"
		ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") end
		ToUpdate.CallbackNoUpdate = function(OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">No Updates Found</b></font>") end
		ToUpdate.CallbackNewVersion = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>") end
		ToUpdate.CallbackError = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Error while Downloading. Please try again.</b></font>") end
		ScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	end
end

function CustomOnLoad()
	if _G.AutoCarry ~= nil then
		PrintChat("<font color=\"#DF7401\"><b>SAC: </b></font> <font color=\"#D7DF01\">Loaded</font>")
		SAC = true
		Sx = false
	else
		Sx = true
		SAC = false
		require "SxOrbWalk"
	end
	print("<font color=\"#DF7401\"><b>Blitzcrank Ass-Grabber:</b></font> <font color=\"#D7DF01\"> Thanks for using this Script ! Enjoy Your Game ! </font>")
	TargetSelector = TargetSelector(TARGET_MOST_AD, 1350, DAMAGE_MAGICAL, false, true)
	Variables()
	Menu()
end

function CustomOnTick()
	TargetSelector:update()
	Target = GetCustomTarget()
	if Sx then
		SxOrb:ForceTarget(Target)
	end
	if SAC then
		if _G.AutoCarry.Keys.AutoCarry then
			_G.AutoCarry.Orbwalker:Orbwalk(Target)
		end
	end
	manaShield = tostring(math.ceil(ManashieldStrength()))
	ComboKey = Settings.combo.comboKey
	autoComboKey = Settings.autoCombo.autoCombo
	Checks()
	KillSteall()
	if Target ~= nil then
		if ComboKey then
			Combo(Target)
		elseif autoComboKey then
			autoCombo(Target)
		end
	end
end

function CustomOnDraw()
	
	if Settings.drawstats.stats then
		UpdateWindow()
		if Settings.drawstats.pourcentage then
			DrawText("Percentage Grab done : " .. tostring(math.ceil(pourcentage)) .. "%" ,18, WINDOW_H * 0.02,WINDOW_W * 0.2, 0xff00ff00)
		end
		if Settings.drawstats.grabdone then
			DrawText("Grab Done : "..tostring(nbgrabwin),18, WINDOW_H * 0.02, WINDOW_W * 0.215, 0xff00ff00)
		end
		if Settings.drawstats.grabfail then
			DrawText("Grab Miss : "..tostring(missedgrab),18, WINDOW_H * 0.02, WINDOW_W * 0.230, 0xFFFF0000)
		end
		if Settings.drawstats.mana and manaShield ~= nil then
			DrawText("Passive's Shield : ".. tostring(math.ceil(manaShield)) .. "HP" ,18, WINDOW_H * 0.02, WINDOW_W * 0.245, 0xffffff00)
		end
	end
	if not myHero.dead and not Settings.drawing.mDraw then	
		if ValidTarget(Target) then 
			if Settings.drawing.text then 
				DrawText3D("Current Target",Target.x-100, Target.y-50, Target.z, 20, 0xFFFFFF00)
			end
			if Settings.drawing.targetcircle then 
				DrawCircle(Target.x, Target.y, Target.z, 150, RGB(Settings.drawing.qColor[2], Settings.drawing.qColor[3], Settings.drawing.qColor[4]))
			end
				
		end
		if SkillQ.ready then
			if ValidTarget(Target) and Settings.drawing.line then 
				local IsCollision = VP:CheckMinionCollision(Target, Target.pos,SkillQ.delay, SkillQ.width,Settings.combo.rangeQ, SkillQ.speed, myHero.pos,nil, true)
				DrawLine3D(myHero.x, myHero.y, myHero.z, Target.x, Target.y, Target.z, 5, IsCollision and ARGB(125, 255, 0,0) or ARGB(125, 0, 255,0))
			end
			if Settings.drawing.qDraw then 
				DrawCircle(myHero.x, myHero.y, myHero.z, Settings.combo.rangeQ, RGB(Settings.drawing.qColor[2], Settings.drawing.qColor[3], Settings.drawing.qColor[4]))
			end
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
	TargetSelector:update()	
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, 1500) and (Ignore == nil or (Ignore.networkID ~= SelectedTarget.networkID)) then
		return SelectedTarget
	end
	if TargetSelector.target and not TargetSelector.target.dead and TargetSelector.target.type == myHero.type then
		return TargetSelector.target
	else
		return nil
	end
end

function CustomOnWndMsg(Msg, Key)	
	
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

function ManashieldStrength()
 local ShieldStrength = myHero.mana*0.5
 return ShieldStrength
end

function CustomOnProcessSpell(unit, spell)
	
	if spell.name == "RocketGrab" and unit.isMe then
		nbgrabtotal=nbgrabtotal+1
		missedgrab = (nbgrabtotal-nbgrabwin)
		pourcentage =((nbgrabwin*100)/nbgrabtotal)
    end
end

function CustomOnUpdateBuff(unit, buff, stacks)
	if unit and not unit.isMe and buff.name == "rocketgrab2" and unit.type == myHero.type then
		nbgrabwin=nbgrabwin+ 1
		missedgrab = missedgrab - 1
		pourcentage =((nbgrabwin*100)/nbgrabtotal)
		if Settings.misc.autoE then
			CastAutoE(unit)
		end
	end
end

function KillSteall()
	
	for _, unit in pairs(GetEnemyHeroes()) do
		local health = unit.health
		local dmgR = getDmg("R", unit, myHero) + (myHero.ap)
		local dmgQ = getDmg("Q", unit, myHero) + (myHero.ap)
		if health < dmgQ*0.95 and Settings.killsteal.useQ and ValidTarget(unit) then
			CastQ(unit)
		elseif health < dmgR*0.95 and Settings.killsteal.useR and ValidTarget(unit) then
			CastR(unit)
		end
	 end
end

function autoCombo(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		if Settings.autoCombo.autoGrab then
			CastQ(unit)
		end
		if Settings.autoCombo.autoBump then
			CastE(unit)
		end
		if Settings.autoCombo.autoUlt then
			CastR(unit)
		end
	end
end

function Combo(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		if Settings.combo.useQ then
			CastQ(unit)
		end
		if Settings.combo.useW then
			CastW(unit)
		end
		if Settings.combo.useE then
			CastE(unit)
		end
		
		if Settings.combo.useR then 
			if not Settings.combo.useRafterE then
				CastR(unit)
			end
		end
		if Settings.combo.RifKilable then
			local dmgR = getDmg("R", unit, myHero) + (myHero.ap)
			if unit.health < dmgR*0.95 then
				CastR(unit)
			end
		end
	end
end

function CastQ(unit)
	if (unit.charName == Champ[1] and Settings.qSettings.champ1) or (unit.charName == Champ[2] and Settings.qSettings.champ2) or (unit.charName == Champ[3] and Settings.qSettings.champ3) or (unit.charName == Champ[4] and Settings.qSettings.champ4) or (unit.charName == Champ[5] and Settings.qSettings.champ5) then
		if unit ~= nil and GetDistance(unit) <= Settings.combo.rangeQ and SkillQ.ready then			
			if Settings.prediction.prediction == 1 and VIP_USER then
				local enemy = DPTarget(unit)
				local State, Position, perc = DP:predict(enemy, myQ)
				if State == SkillShot.STATUS.SUCCESS_HIT then 
					CastSpell(_Q, Position.x, Position.z)
				end
			else
				CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, SkillQ.delay, SkillQ.width,Settings.combo.rangeQ, SkillQ.speed, myHero, true)	
				if HitChance >= 2 then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
	end
end	

function CastW(unit)
local IsCollision = VP:CheckMinionCollision(unit, unit.pos,SkillQ.delay, SkillQ.width, Settings.combo.rangeQ, SkillQ.speed, myHero.pos,nil, true)
	if not IsCollision then
		if GetDistance(unit) <= Settings.combo.rangeQ + 250 and GetDistance(unit) >= Settings.combo.rangeQ and SkillW.ready and SkillQ.ready then
			CastSpell(_W)
		elseif GetDistance(unit) <= SkillE.range + 150 and SkillW.ready then
			CastSpell(_W)
		end
	end
end
	
function CastE(unit)
	if GetDistance(unit) <= SkillE.range and SkillE.ready then
		CastSpell(_E)
		myHero:Attack(unit)
	end	
end

function CastAutoE(unit)
	CastSpell(_E)
	myHero:Attack(unit)
end

function CastR(unit)
	if GetDistance(unit) <= SkillR.range and SkillR.ready then
		CastSpell(_R)
	end	
end

function Checks()
	SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
	SkillW.ready = (myHero:CanUseSpell(_W) == READY)
	SkillE.ready = (myHero:CanUseSpell(_E) == READY)
	SkillR.ready = (myHero:CanUseSpell(_R) == READY)

	 _G.DrawCircle = _G.oldDrawCircle 
	 
end

function Menu()
	Settings = scriptConfig("Blitzcrank: Ass-Grabber ", "AMBER")
	
	Settings:addSubMenu("["..myHero.charName.."] - Combo Settings (SBTW)", "combo")
		Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Settings.combo:addParam("useQ", "Use (Q) in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("rangeQ","Max Q Range for Grab", SCRIPT_PARAM_SLICE, 900, 600, 925, 0)
		Settings.combo:addParam("useW", "Use (W) in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("useE", "Use (E) in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("useR", "Use (R) in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("RifKilable", "Only (R) for KillSteal", SCRIPT_PARAM_ONOFF, false)
		Settings.combo:permaShow("comboKey")
		Settings.combo:permaShow("useR")
		Settings.combo:permaShow("RifKilable")
		
	Settings:addSubMenu("["..myHero.charName.."] - (Q) Settings", "qSettings")	
		if Champ[1] ~= nil then Settings.qSettings:addParam("champ1", "Use on "..Champ[1], SCRIPT_PARAM_ONOFF, true) end
		if Champ[2] ~= nil then Settings.qSettings:addParam("champ2", "Use on "..Champ[2], SCRIPT_PARAM_ONOFF, true) end
		if Champ[3] ~= nil then Settings.qSettings:addParam("champ3", "Use on "..Champ[3], SCRIPT_PARAM_ONOFF, true) end
		if Champ[4] ~= nil then Settings.qSettings:addParam("champ4", "Use on "..Champ[4], SCRIPT_PARAM_ONOFF, true) end
		if Champ[5] ~= nil then Settings.qSettings:addParam("champ5", "Use on "..Champ[5], SCRIPT_PARAM_ONOFF, true) end
		
	Settings:addSubMenu("["..myHero.charName.."] - AutoCombo Settings", "autoCombo")
		Settings.autoCombo:addParam("autoCombo", "Auto Combo State", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("T"))
		Settings.autoCombo:addParam("autoGrab", "Use (Q) in AutoCombo", SCRIPT_PARAM_ONOFF, true)
		Settings.autoCombo:addParam("autoBump", "Use (E) in AutoCombo", SCRIPT_PARAM_ONOFF, true)
		Settings.autoCombo:addParam("autoUlt", "Use (R) in AutoCombo", SCRIPT_PARAM_ONOFF, true)
		Settings.autoCombo:permaShow("autoCombo")
		
	Settings:addSubMenu("["..myHero.charName.."] - KillSteal", "killsteal")	
		Settings.killsteal:addParam("useQ", "Steal With (Q)", SCRIPT_PARAM_ONOFF, true)
		Settings.killsteal:addParam("useR", "Steal With (R)", SCRIPT_PARAM_ONOFF, true)
		Settings.killsteal:permaShow("useQ")
		Settings.killsteal:permaShow("useR")
	
	Settings:addSubMenu("["..myHero.charName.."] - Misc", "misc")
		Settings.misc:addParam("autoE", "Use (E) after a Successful Grab", SCRIPT_PARAM_ONOFF, true)
		Settings.misc:permaShow("autoE")
	
	Settings:addSubMenu("["..myHero.charName.."] - Prediction", "prediction")	
		Settings.prediction:addParam("prediction", "0: VPrediction | 1: DivinePred", SCRIPT_PARAM_SLICE, 0, 0, 1, 0)

	Settings:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing")	
		Settings.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		Settings.drawing:addParam("myHero", "Draw My Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("myColor", "Draw My Range Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("qDraw", "Draw "..SkillQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("qColor", "Draw "..SkillQ.name.." (Q) Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("rDraw", "Draw "..SkillR.name.." (R) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("rColor", "Draw "..SkillR.name.." (R) Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("text", "Draw Current Target", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("targetcircle", "Draw Circle On Target", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("line", "Draw (Q) Line Helper", SCRIPT_PARAM_ONOFF, true)
		
		
	Settings:addSubMenu("["..myHero.charName.."] - Draw Stats", "drawstats")
		Settings.drawstats:addParam("stats", "Show Stats & Passive's shield", SCRIPT_PARAM_ONOFF, true)
		Settings.drawstats:addParam("pourcentage", "Show Pourcentage", SCRIPT_PARAM_ONOFF, true)
		Settings.drawstats:addParam("grabdone", "Show Grab Done", SCRIPT_PARAM_ONOFF, true)
		Settings.drawstats:addParam("grabfail", "Show Grab Fail", SCRIPT_PARAM_ONOFF, true)
		Settings.drawstats:addParam("mana", "Show Passive's shield", SCRIPT_PARAM_ONOFF, true)
	

	
	TargetSelector.name = "Blitzcrank"
		Settings:addTS(TargetSelector)

	if Sx then
		Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
		SxOrb:LoadToMenu(Settings.Orbwalking)
	end
	
end

function Variables()
	SkillQ = { name = "Rocket Grab", range = 925, delay = 0.55, speed = math.huge, width = 80, ready = false }
	SkillW = { name = "Overdrive", range = nil, delay = 0.375, speed = math.huge, width = nil, ready = false }
	SkillE = { name = "Power Fist", range = 280, delay = nil, speed = nil, width = nil, ready = false }
	SkillR = { name = "Static Field", range = 590, delay = 0.5, speed = math.huge, angle = 80, ready = false }
	myEnemyTable = GetEnemyHeroes()
	Champ = { } 
	for i, enemy in pairs(myEnemyTable) do 
		Champ[i] = enemy.charName
	end
	
	nbgrabtotal= 0
	missedgrab = 0
	pourcentage = 0
	nbgrabwin = 0
	local ts
	local Target

	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
end

function DrawCircle2(x, y, z, radius, color)
  local vPos1 = Vector(x, y, z)
  local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
  local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
end

----- LINK SCRIPT STATUT ----- 
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("TGJHHMHFMMI")
