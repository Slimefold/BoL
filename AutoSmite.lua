class 'MinionSmiteManager'
class 'Smite'
class 'Chogath'
class 'Nunu'
class 'Volibear'
class 'Shaco'
class 'Olaf'
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
	DelayAction(function()	
		MinionSmiteManager()
		assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("OBECFFGFDFE") 
		if myHero.charName == "Chogath" then
			Chogath()
			print("<font color=\"#F0Ff8d\"><b>AutoSmite: </b></font> <font color=\"#FF0F0F\">Successfully Load Chogath</b></font>")
		elseif myHero.charName == "Nunu" then
			Nunu()
			print("<font color=\"#F0Ff8d\"><b>AutoSmite: </b></font> <font color=\"#FF0F0F\">Successfully Load Nunu</b></font>")
		elseif myHero.charName == "Volibear" then
			Volibear()
			print("<font color=\"#F0Ff8d\"><b>AutoSmite: </b></font> <font color=\"#FF0F0F\">Successfully Load Volibear</b></font>")
		elseif myHero.charName == "Shaco" then
			Shaco()
			print("<font color=\"#F0Ff8d\"><b>AutoSmite: </b></font> <font color=\"#FF0F0F\">Successfully Load Shaco</b></font>")
		elseif myHero.charName == "Olaf" then
			Olaf()
			print("<font color=\"#F0Ff8d\"><b>AutoSmite: </b></font> <font color=\"#FF0F0F\">Successfully Load Olaf</b></font>")
		else
			Smite()
			print("<font color=\"#F0Ff8d\"><b>AutoSmite: </b></font> <font color=\"#FF0F0F\">Successfully Load</b></font>")
		end		
	end, 2)
end

function CheckScriptUpdate()
	local ToUpdate = {}
    ToUpdate.Version = 4.42
    ToUpdate.UseHttps = true
	ToUpdate.Name = "AutoSmite"
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/AMBER17/BoL/master/AutoSmite.version"
    ToUpdate.ScriptPath =  "/AMBER17/BoL/master/AutoSmite.lua"
    ToUpdate.SavePath = SCRIPT_PATH.."/" .. GetCurrentEnv().FILE_NAME
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") end
    ToUpdate.CallbackNoUpdate = function(OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">No Updates Found</b></font>") end
    ToUpdate.CallbackNewVersion = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>") end
    ToUpdate.CallbackError = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Error while Downloading. Please try again.</b></font>") end
    ScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--[[		MINION MANAGER		]]
--------------------------------------------------------------------------
--------------------------------------------------------------------------

function MinionSmiteManager:__init()
	
	self.MyMinionTable = { }
	self.Smite = { name = "summonersmite", range = 550, slot = nil, ready = false }
	
	for i = 0, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object and object.valid and not object.dead then
			self.MyMinionTable[#self.MyMinionTable + 1] = object
		end
	end
	
	AddTickCallback(function() self:OnTick() end)
	AddCreateObjCallback(function(minion) self:OnCreateObj(minion) end)
	AddDeleteObjCallback(function(minion) self:OnDeleteObj(minion) end)
	
end

function MinionSmiteManager:OnTick()
	if _G.myMenu.settings.Smite and _G.myMenu.killsteal.killsteal then
		self:killSteal()
	end
end

function MinionSmiteManager:ValidMinion(m)
	return (m and m ~= nil and m.type and not m.dead and m.name ~= "hiu" and m.name and m.type:lower():find("min") and not m.name:lower():find("camp") and m.team ~= myHero.team and m.charName and not m.name:find("OdinNeutralGuardian") and not m.name:find("OdinCenterRelic"))
end

function MinionSmiteManager:OnCreateObj(minion)
	if self:ValidMinion(minion) then 
    	self.MyMinionTable[#self.MyMinionTable + 1] = minion 
	end
end

function MinionSmiteManager:OnDeleteObj(minion)
  	if self.MyMinionTable ~= nil then
      for i, msg in pairs(self.MyMinionTable)  do 
          if msg.networkID == minion.networkID then
              table.remove(self.MyMinionTable, i)
          end
      end
    end
end

function MinionSmiteManager:foundSmite()
	if myHero:GetSpellData(SUMMONER_1).name:find(self.Smite.name) then
         self.Smite.slot = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find(self.Smite.name) then
        self.Smite.slot = SUMMONER_2
    end
	return self.Smite.slot
end

function MinionSmiteManager:smiteReady()
	self.Smite.ready = (self:foundSmite() ~= nil and myHero:CanUseSpell(self:foundSmite()) == READY )
	return self.Smite.ready
end

function MinionSmiteManager:killSteal()
	for _, unit in pairs(GetEnemyHeroes()) do
		self.health = unit.health
		self.smiteDmgOnChamp = 20 + (8 *myHero.level)
		if self.health < self.smiteDmgOnChamp * 0.95 and ValidTarget(unit) and GetDistance(unit) <= 550 then
			CastSpell(self:foundSmite(), unit)
		end	
	end
end

function MinionSmiteManager:CheckMinion()
	for i, minion in pairs(self.MyMinionTable) do
		self.isMinion = self.MyMinionTable[i]
		if GetDistance(self.isMinion) <= 1500 then
			if self:ValidMinion(self.isMinion) then
				if self.isMinion.name == "SRU_Murkwolf8.1.1" or self.isMinion.name == "SRU_Murkwolf2.1.1" then
					if _G.myMenu.settings.wolve then
						return self.isMinion
					end
				end		
				if self.isMinion.name == "SRU_Razorbeak3.1.1" or self.isMinion.name == "SRU_Razorbeak9.1.1" then
					if _G.myMenu.settings.ghost then
						return self.isMinion
					end
				end
				if self.isMinion.name == "SRU_Gromp14.1.1" or self.isMinion.name == "SRU_Gromp13.1.1" then
					if _G.myMenu.settings.gromp then
						return self.isMinion
					end
				end
				if self.isMinion.name == "SRU_Krug5.1.2" or self.isMinion.name == "SRU_Krug11.1.2" then
					if _G.myMenu.settings.golem then
						return self.isMinion
					end
				end
				if self.isMinion.name == "SRU_Red4.1.1" or self.isMinion.name == "SRU_Red10.1.1" then
					if _G.myMenu.settings.redBuff then
						return self.isMinion
					end
				end
				if self.isMinion.name == "SRU_Blue1.1.1" or self.isMinion.name == "SRU_Blue7.1.1" then
					if _G.myMenu.settings.blueBuff then
						return self.isMinion
					end
				end
				if self.isMinion.name == "SRU_Dragon6.1.1" then
					if _G.myMenu.settings.drake then
						return self.isMinion
					end
				end
				if self.isMinion.name == "SRU_Baron12.1.1" then
					if _G.myMenu.settings.nashor then
						return self.isMinion
					end
				end
			end
		end
	end
end

function MinionSmiteManager:Menu()
	_G.myMenu = scriptConfig("[AutoSmite] "..myHero.charName, "AMBER & Linkpad")
	_G.myMenu:addSubMenu("[AutoSmite] "..myHero.charName.." - settings", "settings")
		_G.myMenu.settings:addParam("Smite", "Use AutoSmite", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey("T"))
		_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
		_G.myMenu.settings:addParam("golem","Use On Golem ", SCRIPT_PARAM_ONOFF, false)
		_G.myMenu.settings:addParam("wolve","Use On Wolve ", SCRIPT_PARAM_ONOFF, false)
		_G.myMenu.settings:addParam("ghost","Use On Ghost ", SCRIPT_PARAM_ONOFF, false)
		_G.myMenu.settings:addParam("gromp","Use On Gromp ", SCRIPT_PARAM_ONOFF, false)
		_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
		_G.myMenu.settings:addParam("redBuff","Use On Red Buff ", SCRIPT_PARAM_ONOFF, true)
		_G.myMenu.settings:addParam("blueBuff", "Use On Blue Buff ", SCRIPT_PARAM_ONOFF, true)
		_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
		_G.myMenu.settings:addParam("drake", "Use On Drake ", SCRIPT_PARAM_ONOFF, true)
		_G.myMenu.settings:addParam("nashor" , "Use On Nashor " , SCRIPT_PARAM_ONOFF, true)
		_G.myMenu.settings:permaShow("Smite")
	_G.myMenu:addSubMenu("[AutoSmite] "..myHero.charName.." - Draw", "Draw")
		_G.myMenu.Draw:addParam("drawSmite" , "Draw Smite Range " , SCRIPT_PARAM_ONOFF, true)
		_G.myMenu.Draw:addParam("drawSmitable" , "Draw Dammage " , SCRIPT_PARAM_ONOFF, true)
	_G.myMenu:addSubMenu("[AutoSmite] "..myHero.charName.." - KillSteal", "killsteal")
		_G.myMenu.killsteal:addParam("killsteal" , "KillSteal With Chilling Smite" , SCRIPT_PARAM_ONOFF, true)
		_G.myMenu.killsteal:permaShow("killsteal")
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--[[ 			SMITE - NOT SUPPORTED CHAMP -			]]
--------------------------------------------------------------------------
--------------------------------------------------------------------------

function Smite:__init()
	self.MyOwnMinionSmiteManager = MinionSmiteManager()
	self.MyOwnMinionSmiteManager:Menu()
	self.smiteSlot = self.MyOwnMinionSmiteManager:foundSmite()
	self.smiteDamage = nil
	self.smiteReady = nil
	AddTickCallback(function() self:OnTick() end)
	AddDrawCallback(function() self:OnDraw() end)
end

function Smite:OnTick()
	self.smiteReady = self.MyOwnMinionSmiteManager:smiteReady()
	self.smiteDamage = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	if _G.myMenu.settings.Smite then
		self:CheckSmite()
	end
end

function Smite:CheckSmite()
	self.minion = self.MyOwnMinionSmiteManager:CheckMinion()
	if self.minion then
		if self.minion.health <= self.smiteDamage then 
			CastSpell(self.smiteSlot, self.minion)
		end
	end
end

function Smite:OnDraw()
	if not myHero.dead and self.smiteReady then
		if _G.myMenu.Draw.drawSmite then
			DrawCircle(myHero.x, myHero.y, myHero.z, 550, RGB(100, 44, 255))
		end
		if _G.myMenu.Draw.drawSmitable then
			self.minion = self.MyOwnMinionSmiteManager:CheckMinion()
			if self.minion and GetDistance(self.minion) <= 550 then
				self.drawDamage = self.minion.health - self.smiteDamage
				if self.minion.health > self.smiteDamage then
					DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
				else
					DrawText3D("SMITABLE (SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
				end
			end
		end
	end
end
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--[[ 			CHOGATH			]]
--------------------------------------------------------------------------
--------------------------------------------------------------------------

function Chogath:__init()
	self.MyOwnMinionSmiteManager = MinionSmiteManager()
	self.MyOwnMinionSmiteManager:Menu()
	_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
	_G.myMenu.settings:addParam("useR","Use (R)", SCRIPT_PARAM_ONOFF, true)
	_G.myMenu.settings:permaShow("useR")
	self.smiteSlot = self.MyOwnMinionSmiteManager:foundSmite()
	self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	self.spell = 1000 + (0.7*myHero.ap)
	self.smiteDamage = nil
	self.rReady = nil
	self.smiteReady = nil
	AddTickCallback(function() self:OnTick() end)
	AddDrawCallback(function() self:OnDraw() end)
end

function Chogath:OnDraw()
	if not myHero.dead then
		if _G.myMenu.Draw.drawSmite then 
			if self.rReady and _G.myMenu.settings.useR then
				DrawCircle(myHero.x, myHero.y, myHero.z, 350, RGB(100, 44, 255))
			end
			if self.smiteReady then
				DrawCircle(myHero.x, myHero.y, myHero.z, 550, RGB(100, 44, 255))
			end
		end
		if _G.myMenu.Draw.drawSmitable then
			self.minion = self.MyOwnMinionSmiteManager:CheckMinion()
			if self.minion and GetDistance(self.minion) <= 350 and _G.myMenu.settings.useR then 
				if self.smiteReady and self.rReady then
					self.smiteDamage = self.smite + self.spell
					self.drawDamage = self.minion.health - self.smiteDamage
					if self.minion.health > self.smiteDamage then
						DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
					else
						DrawText3D("SMITABLE (R + SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
					end
				elseif self.smiteReady and not self.rReady then
					self.drawDamage = self.minion.health - self.smite
					if self.minion.health > self.smite then
						DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
					else
						DrawText3D("SMITABLE (SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
					end
				elseif not self.smiteReady and self.rReady then
					self.drawDamage = self.minion.health - self.spell
					if self.minion.health > self.spell then
						DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
					else
						DrawText3D("SMITABLE (R)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
					end
				end
			elseif self.minion and GetDistance(self.minion) <= 550 and self.smiteReady then
				self.drawDamage = self.minion.health - self.smite
				if self.minion.health > self.smite then
					DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
				else
					DrawText3D("SMITABLE (SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
				end
			end
		end
	end
end

function Chogath:OnTick()
	self.smiteReady = self.MyOwnMinionSmiteManager:smiteReady()
	self.rReady = (myHero:CanUseSpell(_R) == READY)
	self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	self.spell = 1000 + (0.7*myHero.ap)
	if _G.myMenu.settings.Smite then
		self:CheckSmite()
	end
end

function Chogath:CheckSmite()
	self.minion = self.MyOwnMinionSmiteManager:CheckMinion()
	if self.minion then
		print(self.spell)
		if GetDistance(self.minion) <= 350 then
			if _G.myMenu.settings.useR then
				if self.rReady and self.smiteReady then
					self.smiteDamage = self.smite + self.spell
					if self.minion.health <= self.smiteDamage then 
						CastSpell(self.smiteSlot, self.minion)
						CastSpell(_R, self.minion)
					end
				elseif self.rReady and not self.smiteReady then
					self.smiteDamage = self.spell
					if self.minion.health <= self.smiteDamage then 
						CastSpell(_R, self.minion)
					end
				elseif not self.rReady and self.smiteReady then
					self.smiteDamage = self.smite
					if self.minion.health <= self.smiteDamage then 
						CastSpell(self.smiteSlot, self.minion)
					end
				end
			else
				self.smiteDamage = self.smite
				if self.minion.health <= self.smiteDamage and self.smiteReady then 
					CastSpell(self.smiteSlot, self.minion)
				end
			end
		elseif GetDistance(self.minion) <= 550 then
			self.smiteDamage = self.smite
			if self.minion.health <= self.smiteDamage then 
				CastSpell(self.smiteSlot, self.minion)
			end
		end
	end
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--[[ 			NUNU			]]
--------------------------------------------------------------------------
--------------------------------------------------------------------------

function Nunu:__init()
	self.MyOwnMinionSmiteManager = MinionSmiteManager()
	self.MyOwnMinionSmiteManager:Menu()
	_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
	_G.myMenu.settings:addParam("useQ","Use (Q)", SCRIPT_PARAM_ONOFF, true)
	_G.myMenu.settings:permaShow("useQ")
	self.smiteSlot = self.MyOwnMinionSmiteManager:foundSmite()
	self.smiteDamage = nil
	self.smiteReady = nil
	AddTickCallback(function() self:OnTick() end)
	AddDrawCallback(function() self:OnDraw() end)
end

function Nunu:OnTick()
	self.smiteReady = self.MyOwnMinionSmiteManager:smiteReady()
	self.qReady = (myHero:CanUseSpell(_Q) == READY)
	self.smiteDamage = nil
	self.spell = self:qDamage()
	if _G.myMenu.settings.Smite then
		self:CheckSmite()
	end
end

function Nunu:OnDraw()
	if not myHero.dead then
		if _G.myMenu.Draw.drawSmite and self.qReady and _G.myMenu.settings.useQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, 350, RGB(100, 44, 255))
		end
		if _G.myMenu.Draw.drawSmite and self.smiteReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, 550, RGB(100, 44, 255))
		end
		if _G.myMenu.Draw.drawSmitable then
			self.minion = self.MyOwnMinionSmiteManager:CheckMinion()
			if self.minion and GetDistance(self.minion) <= 350 then 
				if self.smiteReady and self.qReady then
					self.smiteDamage = self.smite + self:qDamage()
					self.drawDamage = self.minion.health - self.smiteDamage
					if self.minion.health > self.smiteDamage then
						DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
					else
						DrawText3D("SMITABLE (Q + SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
					end
				elseif self.smiteReady and not self.qReady then
					self.drawDamage = self.minion.health - self.smite
					if self.minion.health > self.smite then
						DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
					else
						DrawText3D("SMITABLE (SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
					end
				elseif not self.smiteReady and self.qReady then
					self.drawDamage = self.minion.health - self:qDamage()
					if self.minion.health > self:qDamage() then
						DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
					else
						DrawText3D("KILLABLE (Q)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
					end
				end
			elseif self.minion and GetDistance(self.minion) <= 550 then
				self.drawDamage = self.minion.health - self.smite
				if self.minion.health > self.smite then
					DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
				else
					DrawText3D("SMITABLE (SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
				end
			end
		end
	end
end

function Nunu:qDamage()
	self.qLevel = myHero:GetSpellData(_Q).level
	self.damage = nil

	if self.qLevel == 1 then
		self.damage = 400
	elseif self.qLevel == 2 then
		self.damage = 550
	elseif self.qLevel == 3 then
		self.damage = 700
	elseif self.qLevel == 4 then
		self.damage = 850
	elseif self.qLevel == 5 then
		self.damage = 1000
	end

	return self.damage
end

function Nunu:CheckSmite()
	self.minion = self.MyOwnMinionSmiteManager:CheckMinion()
	if self.minion then
		self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	
		if GetDistance(self.minion) <= 350 then
			if _G.myMenu.settings.useQ then
				if self.qReady and self.smiteReady then
					self.smiteDamage = self.smite + self.spell
					if self.minion.health <= self.smiteDamage then

						if self.smite > self.spell then
							CastSpell(_Q, self.minion)
							CastSpell(self.smiteSlot, self.minion)
						else
							CastSpell(self.smiteSlot, self.minion)
							CastSpell(_Q, self.minion)
						end
					end
				elseif self.qReady and not self.smiteReady then
					self.smiteDamage = self.spell
					if self.minion.health <= self.smiteDamage then 
						CastSpell(_Q, self.minion)
					end
				elseif not self.qReady and self.smiteReady then
					self.smiteDamage = self.smite
					if self.minion.health <= self.smiteDamage then 
						CastSpell(self.smiteSlot, self.minion)
					end
				end
			else
				self.smiteDamage = self.smite
				if self.minion.health <= self.smiteDamage and self.smiteReady then 
					CastSpell(self.smiteSlot, self.minion)
				end
			end
		elseif GetDistance(self.minion) <= 550 then
			self.smiteDamage = self.smite
			if self.minion.health <= self.smiteDamage and _G.myMenu.settings.Smite then 
				CastSpell(self.smiteSlot, self.minion)
			end
		end
	end
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--[[ 			VOLIBEAR			]]
--------------------------------------------------------------------------
--------------------------------------------------------------------------

function Volibear:__init()
	self.MyOwnMinionSmiteManager = MinionSmiteManager()
	self.MyOwnMinionSmiteManager:Menu()
	_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
	_G.myMenu.settings:addParam("useW","Use (W)", SCRIPT_PARAM_ONOFF, true)
	_G.myMenu.settings:permaShow("useW")
	self.smiteSlot = self.MyOwnMinionSmiteManager:foundSmite()
	self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	self.spell = nil
	self.smiteDamage = nil
	self.wReady = nil
	self.smiteReady = nil
	AddTickCallback(function() self:OnTick() end)
	AddDrawCallback(function() self:OnDraw() end)
end

function Volibear:OnDraw()
	if not myHero.dead then
		if _G.myMenu.Draw.drawSmite then 
			if self.wReady and _G.myMenu.settings.useW then
				DrawCircle(myHero.x, myHero.y, myHero.z, 350, RGB(100, 44, 255))
			end
			if self.smiteReady then
				DrawCircle(myHero.x, myHero.y, myHero.z, 550, RGB(100, 44, 255))
			end
		end
		if _G.myMenu.Draw.drawSmitable then
			self.minion = self.MyOwnMinionSmiteManager:CheckMinion()
			if self.minion and GetDistance(self.minion) <= 350 and _G.myMenu.settings.useW then 
				if self.smiteReady and self.wReady then
					self.smiteDamage = self.smite + self.spell
					self.drawDamage = self.minion.health - self.smiteDamage
					if self.minion.health > self.smiteDamage then
						DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
					else
						DrawText3D("SMITABLE (R + SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
					end
				elseif self.smiteReady and not self.wReady then
					self.drawDamage = self.minion.health - self.smite
					if self.minion.health > self.smite then
						DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
					else
						DrawText3D("SMITABLE (SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
					end
				elseif not self.smiteReady and self.wReady then
					self.drawDamage = self.minion.health - self.spell
					if self.minion.health > self.spell then
						DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
					else
						DrawText3D("SMITABLE (R)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
					end
				end
			elseif self.minion and GetDistance(self.minion) <= 550 and self.smiteReady then
				self.drawDamage = self.minion.health - self.smite
				if self.minion.health > self.smite then
					DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
				else
					DrawText3D("SMITABLE (SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
				end
			end
		end
	end
end

function Volibear:OnTick()
	self.smiteReady = self.MyOwnMinionSmiteManager:smiteReady()
	self.wReady = (myHero:CanUseSpell(_W) == READY)
	self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	if self.minion then
		self.spell = getDmg("W", self.minion, myHero) 
	end
	if _G.myMenu.settings.Smite then
		self:CheckSmite()
	end
end

function Volibear:CheckSmite()
	self.minion = self.MyOwnMinionSmiteManager:CheckMinion()
	if self.minion then
		if GetDistance(self.minion) <= 350 then
			if _G.myMenu.settings.useW then
				if self.wReady and self.smiteReady then
					self.smiteDamage = self.smite + self.spell
					if self.smite > self.spell then
						if self.minion.health - self.smite <= self.spell then 
							CastSpell(_W, self.minion)
						end
					end
					if self.spell > self.smite then
						if self.minion.health - self.spell <= self.smite then 
							CastSpell(self.smiteSlot, self.minion)
						end
					end
				elseif self.wReady and not self.smiteReady then
					self.smiteDamage = self.spell
					if self.minion.health <= self.smiteDamage then 
						CastSpell(_W, self.minion)
					end
				elseif not self.wReady and self.smiteReady then
					self.smiteDamage = self.smite
					if self.minion.health <= self.smiteDamage then 
						CastSpell(self.smiteSlot, self.minion)
					end
				end
			else
				self.smiteDamage = self.smite
				if self.minion.health <= self.smiteDamage and self.smiteReady then 
					CastSpell(self.smiteSlot, self.minion)
				end
			end
		elseif GetDistance(self.minion) <= 550 then
			self.smiteDamage = self.smite
			if self.minion.health <= self.smiteDamage then 
				CastSpell(self.smiteSlot, self.minion)
			end
		end
	end
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--[[ 			SHACO			]]
--------------------------------------------------------------------------
--------------------------------------------------------------------------

function Shaco:__init()
	self.MyOwnMinionSmiteManager = MinionSmiteManager()
	self.MyOwnMinionSmiteManager:Menu()
	_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
	_G.myMenu.settings:addParam("useE","Use (E)", SCRIPT_PARAM_ONOFF, true)
	self.smiteSlot = self.MyOwnMinionSmiteManager:foundSmite()
	self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	self.spell = nil
	self.smiteDamage = nil
	self.eReady = nil
	self.smiteReady = nil
	AddTickCallback(function() self:OnTick() end)
	AddDrawCallback(function() self:OnDraw() end)
end

function Shaco:OnDraw()
	if not myHero.dead then
		if _G.myMenu.Draw.drawSmite then 
			if self.eReady and _G.myMenu.settings.useE then
				DrawCircle(myHero.x, myHero.y, myHero.z, 625, RGB(100, 44, 255))
			end
			if self.smiteReady then
				DrawCircle(myHero.x, myHero.y, myHero.z, 550, RGB(100, 44, 255))
			end
		end
		if _G.myMenu.Draw.drawSmitable then
			self.minion = self.MyOwnMinionSmiteManager:CheckMinion()
			if self.minion then
				if GetDistance(self.minion) <= 625 and GetDistance(self.minion) > 550 then
					if _G.myMenu.settings.useE then
						if self.eReady then
							self.drawDamage = self.minion.health - self.spell
							if self.minion.health <= self.spell then 
								DrawText3D("SMITABLE (E)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
							else
								DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
							end
						end
					end
				elseif GetDistance(self.minion) <= 550 then
					if _G.myMenu.settings.useE then
						if self.eReady and self.smiteReady then
						self.drawDamage = self.minion.health - (self.spell + self.smite)
							if self.minion.health <= (self.spell - self.smite) then 
								DrawText3D("SMITABLE (E + SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
							else
								DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
							end
						elseif self.eReady and not self.smiteReady then
						self.drawDamage = self.minion.health - self.spell 
							if self.minion.health <= self.spell then
								DrawText3D("SMITABLE (E)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
							else
								DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
							end
						elseif not self.eReady and self.smiteReady then
						self.drawDamage = self.minion.health - self.smite 
							if self.minion.health <= self.smite then
								DrawText3D("SMITABLE (SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
							else
								DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
							end
						end
					else
						if self.smiteReady then
						elf.drawDamage = self.minion.health - self.smite 
							if self.minion.health <= self.smite then
								DrawText3D("SMITABLE (SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
							else
								DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
							end
						end
					end	
				end
			end
		end		
	end
end

function Shaco:OnTick()
	self.smiteReady = self.MyOwnMinionSmiteManager:smiteReady()
	self.eReady = (myHero:CanUseSpell(_E) == READY)
	self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	if self.minion then
		self.spell = getDmg("E", self.minion, myHero)
		print(self.spell)
	end
	if _G.myMenu.settings.Smite then
		self:CheckSmite()
	end
end

function Shaco:CheckSmite()
	self.minion = self.MyOwnMinionSmiteManager:CheckMinion()
	if self.minion then
		if GetDistance(self.minion) <= 625 and GetDistance(self.minion) > 550 then
			if _G.myMenu.settings.useE then
				if self.eReady then
					if self.minion.health <= self.spell then 
						CastSpell(_E, self.minion)
					end
				end
			end
		elseif GetDistance(self.minion) <= 550 then
			if _G.myMenu.settings.useE then
				if self.eReady and self.smiteReady then
					if self.smite > self.spell then
						if self.minion.health - self.smite <= self.spell then 
							CastSpell(_E, self.minion)
						end
					else
						if self.minion.health - self.spell <= self.smite then 
							CastSpell(self.smiteSlot, self.minion)
						end
					end
				elseif self.eReady and not self.smiteReady then
					if self.minion.health <= self.spell then 
						CastSpell(_E, self.minion)
					end
				elseif not self.eReady and self.smiteReady then
					if self.minion.health <= self.smite then 
						CastSpell(self.smiteSlot, self.minion)
					end
				end
			else
				if self.smiteReady then
					if self.minion.health <= self.smite then 
						CastSpell(self.smiteSlot, self.minion)
					end
				end
			end
		end
	end
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--[[ 			OLAF			]]
--------------------------------------------------------------------------
--------------------------------------------------------------------------

function Olaf:__init()
	self.MyOwnMinionSmiteManager = MinionSmiteManager()
	self.MyOwnMinionSmiteManager:Menu()
	_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
	_G.myMenu.settings:addParam("useE","Use (E)", SCRIPT_PARAM_ONOFF, true)
	_G.myMenu.settings:addParam("smiteFirst","Finish Minion With (E) for Passive", SCRIPT_PARAM_ONOFF, true)
	_G.myMenu.settings:addParam("info", "On = Smite then (E) | Off = (E) then Smite", SCRIPT_PARAM_INFO, "")
	_G.myMenu.settings:permaShow("useE")
	_G.myMenu.settings:permaShow("smiteFirst")
	self.smiteSlot = self.MyOwnMinionSmiteManager:foundSmite()
	self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	self.spell = nil
	self.smiteDamage = nil
	self.eReady = nil
	self.smiteReady = nil
	AddTickCallback(function() self:OnTick() end)
	AddDrawCallback(function() self:OnDraw() end)
end

function Olaf:OnDraw()
	if not myHero.dead then
		if _G.myMenu.Draw.drawSmite then 
			if self.eReady and _G.myMenu.settings.useE then
				DrawCircle(myHero.x, myHero.y, myHero.z, 350, RGB(100, 44, 255))
			end
			if self.smiteReady then
				DrawCircle(myHero.x, myHero.y, myHero.z, 550, RGB(100, 44, 255))
			end
		end
		if _G.myMenu.Draw.drawSmitable then
			self.minion = self.MyOwnMinionSmiteManager:CheckMinion()
			if self.minion and GetDistance(self.minion) <= 350 and _G.myMenu.settings.useE then 
				if self.smiteReady and self.eReady then
					self.smiteDamage = self.smite + self.spell
					self.drawDamage = self.minion.health - self.smiteDamage
					if self.minion.health > self.smiteDamage then
						DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
					else
						DrawText3D("SMITABLE (R + SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
					end
				elseif self.smiteReady and not self.eReady then
					self.drawDamage = self.minion.health - self.smite
					if self.minion.health > self.smite then
						DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
					else
						DrawText3D("SMITABLE (SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
					end
				elseif not self.smiteReady and self.eReady then
					self.drawDamage = self.minion.health - self.spell
					if self.minion.health > self.spell then
						DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
					else
						DrawText3D("SMITABLE (R)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
					end
				end
			elseif self.minion and GetDistance(self.minion) <= 550 and self.smiteReady then
				self.drawDamage = self.minion.health - self.smite
				if self.minion.health > self.smite then
					DrawText3D(tostring(math.ceil(self.drawDamage)),self.minion.x, self.minion.y+450, self.minion.z, 24, 0xFFFF0000)
				else
					DrawText3D("SMITABLE (SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
				end
			end
		end
	end
end

function Olaf:OnTick()
	self.smiteReady = self.MyOwnMinionSmiteManager:smiteReady()
	self.eReady = (myHero:CanUseSpell(_E) == READY)
	self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	if self.minion then
		self.spell = getDmg("E", self.minion, myHero) 
	end
	if _G.myMenu.settings.Smite then
		self:CheckSmite()
	end
end

function Olaf:CheckSmite()
	self.minion = self.MyOwnMinionSmiteManager:CheckMinion()
	if self.minion then
		if GetDistance(self.minion) <= 350 then
			if _G.myMenu.settings.useE then
				if self.eReady and self.smiteReady then
					self.smiteDamage = self.smite + self.spell
					if self.minion.health <= self.smiteDamage then 
						if _G.myMenu.settings.smiteFirst then
							CastSpell(self.smiteSlot, self.minion)
							CastSpell(_E, self.minion)
						else
							CastSpell(_E, self.minion)
						end
					end
					if self.spell > self.smite then
						if self.minion.health - self.spell <= self.smite then 
							CastSpell(self.smiteSlot, self.minion)
						end
					end
				elseif self.eReady and not self.smiteReady then
					self.smiteDamage = self.spell
					if self.minion.health <= self.smiteDamage then 
						CastSpell(_E, self.minion)
					end
				elseif not self.eReady and self.smiteReady then
					self.smiteDamage = self.smite
					if self.minion.health <= self.smiteDamage then 
						CastSpell(self.smiteSlot, self.minion)
					end
				end
			else
				self.smiteDamage = self.smite
				if self.minion.health <= self.smiteDamage and self.smiteReady then 
					CastSpell(self.smiteSlot, self.minion)
				end
			end
		elseif GetDistance(self.minion) <= 550 then
			self.smiteDamage = self.smite
			if self.minion.health <= self.smiteDamage then 
				CastSpell(self.smiteSlot, self.minion)
			end
		end
	end
end
