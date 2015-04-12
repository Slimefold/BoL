if myHero.charName ~= "KogMaw" then return end
class 'KogMaw'
class "ScriptUpdate"
getDivine = false
getVP=false

if VIP_USER and FileExist(LIB_PATH .. "/DivinePred.lua") then 
	require "DivinePred" 
	dp = DivinePred()
	getDivine = true
	
end

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
	if getVP then
		CheckSxOrbWalk()
	end
	
	if FileExist(LIB_PATH .. "/VPrediction.lua") and FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
		SAC = false
		SX = false
		print("<font color=\"#DF7401\"><b>KogMaw (BETA): </b></font><font color=\"#D7DF01\">Waiting for any OrbWalk authentification</b></font>")
		DelayAction(function()	
			CustomOnLoad()
		end, 10)
	end
end

function CheckScriptUpdate()
	local ToUpdate = {}
    ToUpdate.Version = 1.01
    ToUpdate.UseHttps = true
	ToUpdate.Name = "KogMaw"
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/AMBER17/BoL/master/KogMaw.version"
    ToUpdate.ScriptPath =  "/AMBER17/BoL/master/KogMaw.lua"
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
		getVP = true
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
		SAC = true
		print("<font color=\"#DF7401\"><b>KogMaw (BETA): </b></font><font color=\"#D7DF01\">SAC Detected & Loaded</b></font>")
	else 
		SX = true
		require "SxOrbWalk"
	end
	KogMaw()
end

function KogMaw:__init()
	self:myMenu()
	self:myVariables()
	AddTickCallback(function() self:OnTick() end)
	AddDrawCallback(function() self:OnDraw() end)
	AddCastSpellCallback (function(iSpell,startPos,endPos,targetUnit) self:OnCastSpell(iSpell,startPos,endPos,targetUnit) end)
	AddMsgCallback(function(Msg,Key) self:OnWndMsg(Msg,Key) end)
	AddApplyBuffCallback(function(unit,source,buff) self:OnApplyBuff(unit,source,buff) end)
end

function KogMaw:OnDraw()
	if not myHero.dead then
		if ValidTarget(self.Target) then 
			DrawText3D("Current Target",self.Target.x-100, self.Target.y-50, self.Target.z, 20, 0xFFFFFF00)
			DrawCircle(self.Target.x, self.Target.y, self.Target.z, 150, ARGB(255, 255, 0, 0))
		end
		if self.Spells.Q.Ready() and self.Settings.draw.drawQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, self.Spells.Q.Range, ARGB(125, 0 , 0 ,255))
		end
		if self.Spells.E.Ready() and self.Settings.draw.drawE then
			DrawCircle(myHero.x, myHero.y, myHero.z, self.Spells.E.Range, ARGB(125, 0 , 0 ,255))
		end
		if self.Spells.R.Ready() and self.Settings.draw.drawR then
			DrawCircle(myHero.x, myHero.y, myHero.z, self.Spells.R.Range, ARGB(125, 0 , 0 ,255))
		end
	end
end

function KogMaw:myVariables()
	self.TargetSelector = TargetSelector(TARGET_LOW_HP, 1900, DAMAGE_PHYSICAL, false, true)
	self.Spells = {
		Q = { Range = self.Settings.spells.Qspells.qRange, Width = 70, Delay = 0.4, Speed = 900, TS = 0, Ready = function() return myHero:CanUseSpell(0) == 0 end,},
		W = { Ready = function() return myHero:CanUseSpell(1) == 0 end,},
		E = { Range = self.Settings.spells.Espells.eRange, Width = 120, Delay = 0.5, Speed = 800, TS = 0, Ready = function() return myHero:CanUseSpell(2) == 0 end,},
		R = { Range = 1200 , Ranget = {1200,1500,1800} , Width = 65, Delay = 0.6, Speed = 900, TS = 0, Ready = function() return myHero:CanUseSpell(3) == 0 end,},
	}
	
	self.isPassive = false
	self.lastR = 0 
	self.AA = 0
	self.aaRange = myHero.range + myHero.boundingRadius + self.AA
	self.wUsed = false
	self.lastW = 0
	
	if myHero:GetSpellData(_R).level == 3 then self.Spells.R.Range = self.Spells.R.Ranget[3] end
	self.SkillShotR = CircleSS(self.Spells.R.Speed,self.Spells.R.Range,self.Spells.R.Width,self.Spells.R.Delay, math.huge)
	self.SkillShotQ = LineSS(self.Spells.Q.Speed,self.Spells.Q.Range,self.Spells.Q.Width,self.Spells.Q.Delay, 0)
	self.SkillShotE = LineSS(self.Spells.E.Speed,self.Spells.E.Range,self.Spells.E.Width,self.Spells.E.Delay, math.huge)
end

function KogMaw:myMenu()
	self.Settings = scriptConfig("KogMaw", "Aurora Scripters™")
	
		self.Settings:addSubMenu("["..myHero.charName.."] - Combo Settings (SBTW)", "combo")
			self.Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			self.Settings.combo:addParam("info", "", SCRIPT_PARAM_INFO, "")
			self.Settings.combo:addParam("comboType", "0 = ADC | 1 = AP MID" , SCRIPT_PARAM_SLICE, 0, 0, 1, 0)
			self.Settings.combo:addParam("info", "", SCRIPT_PARAM_INFO, "")
			self.Settings.combo:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
			self.Settings.combo:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true)
			self.Settings.combo:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)
			self.Settings.combo:addParam("useR", "Use (R)", SCRIPT_PARAM_ONOFF, true)	
		
		self.Settings:addSubMenu("["..myHero.charName.."] - Harass Settings", "harass")
			self.Settings.harass:addParam("harassKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 67)
			self.Settings.harass:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
			self.Settings.harass:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)
			self.Settings.harass:addParam("useR", "Use (R)", SCRIPT_PARAM_ONOFF, true)
			
		self.Settings:addSubMenu("["..myHero.charName.."] - KillSteal Settings", "killsteal")
			self.Settings.killsteal:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
			self.Settings.killsteal:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)
			self.Settings.killsteal:addParam("useR", "Use (R)", SCRIPT_PARAM_ONOFF, true)
			
		self.Settings:addSubMenu("["..myHero.charName.."] - Misc Settings", "misc")	
			self.Settings.misc:addParam("useP", "Use Auto Passive (BETA)", SCRIPT_PARAM_ONOFF, true)
			
		self.Settings:addSubMenu("["..myHero.charName.."] - Spells Settings", "spells")
			self.Settings.spells:addSubMenu("["..myHero.charName.."] - (Q) Spells", "Qspells")
				self.Settings.spells.Qspells:addParam("qRange", "(Q) Max Range" , SCRIPT_PARAM_SLICE, 950, 700, 950, 0)
				self.Settings.spells.Qspells:addParam("minRange", "(Q) Min Range" , SCRIPT_PARAM_SLICE, 0, 0, 700, 0)
			self.Settings.spells:addSubMenu("["..myHero.charName.."] - (W) Spells", "Wspells")
				self.Settings.spells.Wspells:addParam("info1", " 0 = Only use if Target out of range", SCRIPT_PARAM_INFO, "")
				self.Settings.spells.Wspells:addParam("info2", " 1 = Use for Increase Damage", SCRIPT_PARAM_INFO, "")
				self.Settings.spells.Wspells:addParam("wType", "Choose your (W) type", SCRIPT_PARAM_SLICE, 1, 0, 1, 0)
			self.Settings.spells:addSubMenu("["..myHero.charName.."] - (E) Spells", "Espells")
				self.Settings.spells.Espells:addParam("eRange", "(E) Max Range" , SCRIPT_PARAM_SLICE, 1200, 900, 1200, 0)
				self.Settings.spells.Espells:addParam("minRange", "(E) Min Range" , SCRIPT_PARAM_SLICE, 0, 0, 900, 0)
			self.Settings.spells:addSubMenu("["..myHero.charName.."] - (R) Spells", "Rspells")
				self.Settings.spells.Rspells:addParam("time", "Time Between Each Cast" , SCRIPT_PARAM_SLICE, 0, 0, 2, 1)
				
		self.Settings:addSubMenu("["..myHero.charName.."] - Draw Settings", "draw")
			self.Settings.draw:addParam("drawQ", "Draw (Q) Range", SCRIPT_PARAM_ONOFF, true)
			self.Settings.draw:addParam("drawE", "Draw (W) Range", SCRIPT_PARAM_ONOFF, true)
			self.Settings.draw:addParam("drawR", "Draw (E) Range", SCRIPT_PARAM_ONOFF, true)
				
		self.Settings:addSubMenu("["..myHero.charName.."] - Prediction Settings", "prediction")
			self.Settings.prediction:addParam("predictionType", "0 = VPred | 1 = DP" , SCRIPT_PARAM_SLICE, 0, 0, 1, 0)
			self.Settings.prediction:addParam("info", "-> DivinePred have a better prediction", SCRIPT_PARAM_INFO, "")
		
		self.Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
			if SX then
				SxOrb:LoadToMenu(self.Settings.Orbwalking)
			elseif SAC then
				self.Settings.Orbwalking:addParam("info", "SAC Detected & Loaded", SCRIPT_PARAM_INFO, "")
			end
			
		self.TargetSelector.name = "["..myHero.charName.."]"
			self.Settings:addTS(self.TargetSelector)
	end

function KogMaw:OnCastSpell(iSpell,startPos,endPos,targetUnit)
	if iSpell == 1 then
		if myHero:GetSpellData(_W).level == 1 then self.AA = 130 end
		if myHero:GetSpellData(_W).level == 2 then self.AA = 150 end
		if myHero:GetSpellData(_W).level == 3 then self.AA = 170 end
		if myHero:GetSpellData(_W).level == 4 then self.AA = 190 end
		if myHero:GetSpellData(_W).level == 5 then self.AA = 210 end
		self.wUsed = true
		self.lastW = os.clock()
	end
end

function KogMaw:OnApplyBuff(unit,source,buff)
	if buff and source.isMe and buff.name == "kogmawicathiansurprise" then
		self.isPassive = true
	end
end

function KogMaw:calcW()
	if os.clock() - self.lastW > 8 then 
		self.AA = 0
		self.wUsed = false
	end
end

function KogMaw:rangeAA()
	self.aaRange = myHero.range + myHero.boundingRadius + self.AA
end

function KogMaw:rangeR()
	if myHero:GetSpellData(_R).level == 1 then self.Spells.R.Range = self.Spells.R.Ranget[1] end
	if myHero:GetSpellData(_R).level == 2 then self.Spells.R.Range = self.Spells.R.Ranget[2] end
	if myHero:GetSpellData(_R).level == 3 then self.Spells.R.Range = self.Spells.R.Ranget[3] end
end

function KogMaw:GetBonusRange()
	local range = 0 
	if myHero:GetSpellData(_W).level == 1 then range = 130 end
	if myHero:GetSpellData(_W).level == 2 then range = 150 end
	if myHero:GetSpellData(_W).level == 3 then range = 170 end
	if myHero:GetSpellData(_W).level == 4 then range = 190 end
	if myHero:GetSpellData(_W).level == 5 then range = 210 end
	return range
end

function KogMaw:OnWndMsg(Msg,Key)
	if Msg == WM_LBUTTONDOWN then
		self.minD = 0
		self.Target = nil
		for i, unit in ipairs(GetEnemyHeroes()) do
			if ValidTarget(unit) then
				if GetDistance(unit, mousePos) <= self.minD or self.Target == nil then
					self.minD = GetDistance(unit, mousePos)
					self.Target = unit
				end
			end
		end

		if self.Target and self.minD < 115 then
			if self.SelectedTarget and self.Target.charName == self.SelectedTarget.charName then
				self.SelectedTarget = nil
			else
				self.Selecte
18a9
dTarget = self.Target
			end
		end
	end
end

function KogMaw:GetCustomTarget()
	if self.SelectedTarget ~= nil and ValidTarget(self.SelectedTarget, 2000) and (Ignore == nil or (Ignore.networkID ~= self.SelectedTarget.networkID)) and GetDistance(self.SelectedTarget) < 1800 then
		return self.SelectedTarget
	end
	if self.TargetSelector.target and not self.TargetSelector.target.dead and self.TargetSelector.target.type == myHero.type then
		return self.TargetSelector.target
	else
		return nil
	end
end

function KogMaw:OnTick()
	if self.isPassive and self.Settings.misc.useP then
		self:usePassive()
	else
	
		if SAC then
			if _G.AutoCarry.Keys.AutoCarry then
				_G.AutoCarry.Orbwalker:Orbwalk(self.Target)
			end
		elseif SX then
			SxOrb:ForceTarget(self.Target) 
		end
		
		self.comboKey = self.Settings.combo.comboKey
		self.harassKey = self.Settings.harass.harassKey
		self:rangeAA()
		self:KillSteal()
		if self.wUsed then self:calcW() end
		if myHero:GetSpellData(_R).level ~= 3 then self:rangeR() end
		self.TargetSelector:update()
		self.Target = self:GetCustomTarget()
		if self.comboKey then self:Combo(self.Target)
		elseif self.harassKey then self:Harass(self.Target) end
	end
end

function KogMaw:Combo(unit)
	if ValidTarget(unit) then
		if self.Settings.combo.useQ then self:CastQ(unit) end
		if self.Settings.combo.useW then self:CastW(unit) end
		if self.Settings.combo.useE then self:CastE(unit) end
		if self.Settings.combo.useR then self:CastR(unit) end
	end
end

function KogMaw:CastQ(unit)
	if self.Spells.Q.Ready() and GetDistance(unit) <= self.Spells.Q.Range + 100 and GetDistance(unit) > self.Settings.spells.Qspells.minRange then
		if self.Settings.prediction.predictionType == 1 then
			local target = DPTarget(unit)
			self.state , self.hitpos, self.perc = dp:predict(target, self.SkillShotQ,2, nil)
			if self.state == "Will hit target" then
				CastSpell(_Q , self.hitpos.x , self.hitpos.z)
			end
		else
			self.CastPosition,  self.HitChance, self.Position = VP:GetLineCastPosition(unit, self.Spells.Q.Delay, self.Spells.Q.Width, self.Spells.Q.Range, self.Spells.Q.Speed, myHero, false)
			CastSpell(_Q, self.CastPosition.x , self.CastPosition.z)
		end
	end
end

function KogMaw:CastW(unit)
	if self.Settings.spells.Wspells.wType == 0 then
		if self.Spells.W.Ready() and GetDistance(unit) <= self.aaRange + self:GetBonusRange() then
			CastSpell(_W)
		end
	else
		if self.Spells.W.Ready() and GetDistance(unit) <= self.aaRange + self:GetBonusRange() and GetDistance(unit) > self.aaRange then
			CastSpell(_W)
		end
	end
end

function KogMaw:CastE(unit)
	if self.Spells.E.Ready() and GetDistance(unit) <= self.Spells.E.Range + 100 and GetDistance(unit) > self.Settings.spells.Espells.minRange then
		if self.Settings.prediction.predictionType == 1 then
			local target = DPTarget(unit)
			self.state , self.hitpos, self.perc = dp:predict(target, self.SkillShotE,2, nil)
			if self.state == "Will hit target" then
				CastSpell(_E , self.hitpos.x , self.hitpos.z)
			end
		else
			self.CastPosition,  self.HitChance, self.Position = VP:GetLineCastPosition(unit, self.Spells.E.Delay, self.Spells.E.Width, self.Spells.E.Range, self.Spells.E.Speed, myHero, false)
			CastSpell(_E, self.CastPosition.x , self.CastPosition.z)
		end
	end
end

function KogMaw:CastR(unit)
	if os.clock() - self.lastR > self.Settings.spells.Rspells.time then
		if self.Settings.combo.comboType == 1 then
			if self.Spells.R.Ready() and GetDistance(unit) <= self.Spells.R.Range + 100 then
				if self.Settings.prediction.predictionType == 1 then
					local target = DPTarget(unit)
					self.state , self.hitpos, self.perc = dp:predict(target, self.SkillShotR,2, nil)
					if self.state == "Will hit target" then
						CastSpell(_R , self.hitpos.x , self.hitpos.z)
						self.lastR = os.clock()
					end
				else
					self.CastPosition,  self.HitChance,  self.Position = VP:GetCircularCastPosition(unit, self.Spells.R.Delay, self.Spells.R.Width, self.Spells.R.Range, self.Spells.R.Speed, myHero, false)	
					if self.HitChance >= 2 then
						CastSpell(_R, self.CastPosition.x , self.CastPosition.z)
						self.lastR = os.clock()
					end
				end
			end 
		else
			if self.Spells.R.Ready() and GetDistance(unit) <= self.Spells.R.Range + 100 and GetDistance(unit) > self.aaRange then
				if self.Settings.prediction.predictionType == 1 then
					local target = DPTarget(unit)
					self.state , self.hitpos, self.perc = dp:predict(target, self.SkillShotR,2, nil)
					if self.state == "Will hit target" then
						CastSpell(_R , self.hitpos.x , self.hitpos.z)
						self.lastR = os.clock()
					end
				else
					self.CastPosition,  self.HitChance,  self.Position = VP:GetCircularCastPosition(unit, self.Spells.R.Delay, self.Spells.R.Width, self.Spells.R.Range, self.Spells.R.Speed, myHero, false)	
					if self.HitChance >= 2 then
						CastSpell(_R, self.CastPosition.x , self.CastPosition.z)
						self.lastR = os.clock()
					end
				end
			end 
		end
	end
end

function KogMaw:Harass(unit)
	if ValidTarget(unit) then
		if self.Settings.harass.useQ then self:CastQ(unit) end
		if self.Settings.harass.useE then self:CastE(unit) end
		if self.Settings.harass.useR then self:CastR(unit) end
	end
end

function KogMaw:KillSteal()
	for _, unit in pairs(GetEnemyHeroes()) do
		if ValidTarget(unit) then
			local qDmg = getDmg("Q", unit, myHero) * 0.95
			local eDmg = getDmg("E", unit, myHero) *0.95
			local rDmg = getDmg("R", unit, myHero) 
			if GetDistance(unit) <= self.Spells.R.Range then
				if unit.health <= qDmg and self.Settings.killsteal.useQ then
					self:CastQ(unit)
				end
				if unit.health <= eDmg and self.Settings.killsteal.useE then
					self:CastE(unit)
				end
				if unit.health <= rDmg and self.Settings.killsteal.useR then
					self:CastR(unit)
				end
			end
		end
	end
end

function KogMaw:usePassive()
	if myHero.dead then self.isPassive = false end
	local isUnit = self:GetLowestHero()
	if isUnit ~= nil then
		myHero:MoveTo(isUnit.x,isUnit.z)
	end
end

function KogMaw:GetLowestHero()
	local LowestHero, LowestHP = nil, 1000000
	for _, unit in pairs(GetEnemyHeroes()) do
		if GetDistance(unit) <= 800 then 
			if ValidTarget(unit) then
				if unit.health < LowestHP then
					LowestHero = unit
					LowestHP = unit.health
				end
			end
		end
	end
	return LowestHero
end
