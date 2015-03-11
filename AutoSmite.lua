	--[[
          _    _ _______ ____     _____ __  __ _____ _______ ______                          
     /\  | |  | |__   __/ __ \   / ____|  \/  |_   _|__   __|  ____|                         
    /  \ | |  | |  | | | |  | | | (___ | \  / | | |    | |  | |__                            
   / /\ \| |  | |  | | | |  | |  \___ \| |\/| | | |    | |  |  __|                           
  / ____ \ |__| |  | | | |__| |  ____) | |  | |_| |_   | |  | |____                          
 /_/    \_\____/_ _|_|  \____/ _|_____/|_|  |_|_____|  |_|__|______|_  _______        _____  
     /\   |  \/  |  _ \|  ____|  __ \    ___    | |    |_   _| \ | | |/ /  __ \ /\   |  __ \ 
    /  \  | \  / | |_) | |__  | |__) |  ( _ )   | |      | | |  \| | ' /| |__) /  \  | |  | |
   / /\ \ | |\/| |  _ <|  __| |  _  /   / _ \/\ | |      | | | . ` |  < |  ___/ /\ \ | |  | |
  / ____ \| |  | | |_) | |____| | \ \  | (_>  < | |____ _| |_| |\  | . \| |  / ____ \| |__| |
 /_/    \_\_|  |_|____/|______|_|  \_\  \___/\/ |______|_____|_| \_|_|\_\_| /_/    \_\_____/ 
                                                                                             
                                                                                             
]]

local AutoSmite_Version = 4.1

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
SxUpdate(AutoSmite_Version,
	"raw.githubusercontent.com",
	"/AMBER17/BoL/master/AutoSmite.version",
	"/AMBER17/BoL/master/AutoSmite.lua",
	SCRIPT_PATH.."/" .. GetCurrentEnv().FILE_NAME,
	function(NewVersion) if NewVersion > AutoSmite_Version then print("<font color=\"#F0Ff8d\"><b>AutoSmite : </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true else print("<font color=\"#F0Ff8d\"><b>AutoSmite: </b></font> <font color=\"#FF0F0F\">You have the Latest Version</b></font>") end 
end)

class 'MinionSmiteManager'
class 'Chogath'
class 'Nunu'
class 'Volibear'
class 'Smite'
class 'Shaco'
class 'Olaf'

function OnLoad()
	if ForceReload then return end
	MinionSmiteManager()
	assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))() ScriptStatus("OBECFFGFDFE") 
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
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--[[		MINION MANAGER		]]
--------------------------------------------------------------------------
--------------------------------------------------------------------------

function MinionSmiteManager:__init()
	self.Smite = { name = "summonersmite", range = 550, slot = nil, ready = false }
	self.smiteSlot = self:foundSmite()
	if not self.smiteSlot then return end
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
		if GetDistance(self.isMinion) <= 1200 then
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
	self.smiteSlot = self.MyOwnMinionSmiteManager:foundSmite()
	if not self.smiteSlot then return end
	self.MyOwnMinionSmiteManager:Menu()
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
	if not myHero.dead and self.smiteReady and _G.myMenu.settings.Smite then
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
	self.smiteSlot = self.MyOwnMinionSmiteManager:foundSmite()
	if not self.smiteSlot then return end
	self.MyOwnMinionSmiteManager:Menu()
	_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
	_G.myMenu.settings:addParam("useR","Use (R)", SCRIPT_PARAM_ONOFF, true)
	_G.myMenu.settings:permaShow("useR")
	self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	self.spell = 1000 + (0.7*myHero.ap)
	self.smiteDamage = nil
	self.rReady = nil
	self.smiteReady = nil
	AddTickCallback(function() self:OnTick() end)
	AddDrawCallback(function() self:OnDraw() end)
end

function Chogath:OnDraw()
	if not myHero.dead and _G.myMenu.settings.Smite then
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
	self.smiteSlot = self.MyOwnMinionSmiteManager:foundSmite()
	if not self.smiteSlot then return end
	self.MyOwnMinionSmiteManager:Menu()
	_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
	_G.myMenu.settings:addParam("useQ","Use (Q)", SCRIPT_PARAM_ONOFF, true)
	_G.myMenu.settings:permaShow("useQ")
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
	if not myHero.dead and _G.myMenu.settings.Smite then
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
	self.smiteSlot = self.MyOwnMinionSmiteManager:foundSmite()
	if not self.smiteSlot then return end
	self.MyOwnMinionSmiteManager:Menu()
	_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
	_G.myMenu.settings:addParam("useW","Use (W)", SCRIPT_PARAM_ONOFF, true)
	_G.myMenu.settings:permaShow("useW")
	self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	self.spell = nil
	self.smiteDamage = nil
	self.wReady = nil
	self.smiteReady = nil
	AddTickCallback(function() self:OnTick() end)
	AddDrawCallback(function() self:OnDraw() end)
end

function Volibear:OnDraw()
	if not myHero.dead and _G.myMenu.settings.Smite then
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
	self.smiteSlot = self.MyOwnMinionSmiteManager:foundSmite()
	if not self.smiteSlot then return end
	self.MyOwnMinionSmiteManager:Menu()
	_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
	_G.myMenu.settings:addParam("useE","Use (E)", SCRIPT_PARAM_ONOFF, true)
	self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	self.spell = nil
	self.smiteDamage = nil
	self.eReady = nil
	self.smiteReady = nil
	AddTickCallback(function() self:OnTick() end)
	AddDrawCallback(function() self:OnDraw() end)
end

function Shaco:OnDraw()
	if not myHero.dead and _G.myMenu.settings.Smite then
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
	self.smiteSlot = self.MyOwnMinionSmiteManager:foundSmite()
	if not self.smiteSlot then return end
	self.MyOwnMinionSmiteManager:Menu()
	_G.myMenu.settings:addParam("info", "----------------------------------------", SCRIPT_PARAM_INFO, "")
	_G.myMenu.settings:addParam("useE","Use (E)", SCRIPT_PARAM_ONOFF, true)
	_G.myMenu.settings:addParam("smiteFirst","Finish Minion With (E) for Passive", SCRIPT_PARAM_ONOFF, true)
	_G.myMenu.settings:addParam("info", "On = Smite then (E) | Off = (E) then Smite", SCRIPT_PARAM_INFO, "")
	_G.myMenu.settings:permaShow("useE")
	_G.myMenu.settings:permaShow("smiteFirst")
	self.smite = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
	self.spell = nil
	self.smiteDamage = nil
	self.eReady = nil
	self.smiteReady = nil
	AddTickCallback(function() self:OnTick() end)
	AddDrawCallback(function() self:OnDraw() end)
end

function Olaf:OnDraw()

	if not myHero.dead and _G.myMenu.settings.Smite then
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
						DrawText3D("SMITABLE (E + SMITE)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
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
						DrawText3D("SMITABLE (E)",self.minion.x, self.minion.y+450, self.minion.z, 24, 0xff00ff00)
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
