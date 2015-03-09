class 'Xerath'

function OnLoad()
	if myHero.charName ~= "Xerath" then return end
	require("VPrediction")
	require("SxOrbWalk")
	Xerath()
end

function Xerath:__init()
	print("Load")
	
	self.Champ = { } 
	
	local myEnemyTable = GetEnemyHeroes()
	
	for i, enemy in pairs(myEnemyTable) do 
		self.Champ[i] = enemy.charName
	end
	
	self:myMenu()
	VP = VPrediction()
	HookPackets()
	self.TargetSelector = TargetSelector(TARGET_MOST_AD, 1500, DAMAGE_MAGICAL, false, true)
	
	
	self.Spells = {
		Q = { Range = 740,	Ranget = {740, 1400}, Width = 100, Delay = 0.6, Speed = math.huge, TS = 0, Ready = function() return myHero:CanUseSpell(0) == 0 end,},
		W = { Range = 1000, Width = 150, Delay = 0.5, Speed = math.huge, TS = 0, Ready = function() return myHero:CanUseSpell(1) == 0 end,},
		E = { Range = 1100, Width = 60, Delay = 0, Speed = 1400, TS = 0, Ready = function() return myHero:CanUseSpell(2) == 0 end,},
		R = { Range = 3000, Ranget = {3000, 4200, 5400}, Width = 175, Delay = 0.85, Speed = math.huge, TS = 0, Ready = function() return myHero:CanUseSpell(3) == 0 end,},
	}
	
	self.qTime = {
		startT = 0,
		endT = 0,
		charging = false
	}
	self.qTime[3] = false
	
	self.rTime = {
		startT = 0,
		endT = 0,
		process = false,
		nbR = 0,
		startCharge = false
	}
	self.rTime[5] = false
	self.rTime[4] = 0
	self.CanMove = true
	
	self.BlockNextAction = false
	self.Block_iActions = {2, 3, 10}
	
	AddTickCallback(function() self:OnTick() end)
	AddMsgCallback(function(Msg,Key) self:OnWndMsg(Msg,Key) end)
	AddDrawCallback(function() self:OnDraw() end)
	AddProcessSpellCallback(function(unit,spell) self:OnProcessSpell(unit, spell) end)
	AddIssueOrderCallback(function(Unit,iAction,targetPos,targetUnit) self:OnIssueOrder(Unit,iAction,targetPos,targetUnit) end)
	AddSendPacketCallback(function(p) self:OnSendPacket(p) end)
	AddCastSpellCallback(function(a,b,c,d) self:OnCastSpell(a,b,c,d) end)
	
end

function Xerath:OnTick()
	
	--[[ TARGET SELECTOR ]] --
	self.TargetSelector:update()
	self.Target = self:GetCustomTarget(self.Spells.R.Range)
	-------------------------------------------
	-------------------------------------------
	if myHero:GetSpellData(3).level ~= 0 then 
		self.Spells.R.Range = self.Spells.R.Ranget[myHero.level >= 6 and myHero:GetSpellData(3).level or 1]
	end
	--[[ CALCUL Q RANGE ]] --
	if self.qTime[3] == false then
		self.Spells.Q.Range = 740
	end
	
	self:calcQ()
	self:calcR()
	
	
	-------------------------------------------
	-------------------------------------------
	self.comboKey = self.Settings.combo.comboKey
	if self.comboKey then
		self:Combo(self.Target)
	end
end

function Xerath:OnDraw()
	if not myHero.dead then	
		if ValidTarget(self.Target) then 
			DrawText3D("Current Target",self.Target.x-100, self.Target.y-50, self.Target.z, 20, 0xFFFFFF00)
			DrawCircle(self.Target.x, self.Target.y, self.Target.z, 150, ARGB(255, 255, 0, 0))
		end
		if self.Spells.Q.Ready() then
			DrawCircle(myHero.x, myHero.y, myHero.z, self.Spells.Q.Range, ARGB(255, 0 , 255 ,0))
		end
		if self.Spells.W.Ready() then
			DrawCircle(myHero.x, myHero.y, myHero.z, self.Spells.W.Range, ARGB(255, 0 , 255 ,0))
		end
		if self.Spells.E.Ready() then
			DrawCircle(myHero.x, myHero.y, myHero.z, self.Spells.E.Range, ARGB(255, 0 , 255 ,0))
		end
		if self.Spells.R.Ready() then
			DrawCircle(myHero.x, myHero.y, myHero.z, self.Spells.R.Range, ARGB(255, 0 , 255 ,0))
		end
	end
end

function Xerath:OnProcessSpell(unit, spell)
	--[[ CALCUL Q RANGE ]] --
	if unit.isMe and spell.name == "XerathArcanopulseChargeUp" then
		self.qTime[3] = true
		self.qTime[1] = os.clock()
		self.qTime[2] = self.qTime[1] + 3
		self.Spells.Q.Range = 740
	end
	
	if unit.isMe and spell.name == "xeratharcanopulse2" then 
		self.qTime[3] = false
	end
	-------------------------------------------
	-------------------------------------------
	
	if unit.isMe and spell.name == "XerathLocusOfPower2" then
		self.rTime[4] = 0
		self.rTime[3] = true
		self.rTime[1] = os.clock()
		self.rTime[2] = self.rTime[1] + 10
	end
	
	if unit.isMe and spell.name == "xerathlocuspulse" then
		self.rTime[4] = self.rTime[4] + 1
		if self.rTime[4] == 3 then
			self.rTime[3] = false
		end
	end
end

function Xerath:calcQ()
	if (self.qTime[3] == nil and self.qTime[2] == nil) then return end
	if self.qTime[3] == false then return end
	local osc = os.clock()
	self.qTime[3] = (osc - self.qTime[2]) < 3 --if the difference is less 3 we still charge, else not <--inverted: if the diff GReater then 3, the spell didnt casted
	
	if self.qTime[3] then --if we charge
		self.Spells.Q.Range = math.min(self.Spells.Q.Ranget[1] + (self.Spells.Q.Ranget[2] - self.Spells.Q.Ranget[1]) * ((osc - self.qTime[1]) / 1.5), self.Spells.Q.Ranget[2])
	else
		self.Spells.Q.Range = 740
		self.qTime[3] = false
	end	
end

function Xerath:calcR()
	if self.rTime[2] == nil then return end
	local osc = os.clock()
	self.rTime[1] = (osc - self.rTime[2]) < 0
	self.time = osc - self.rTime[2]
	if self.rTime[3] and self.rTime[1] then
		self.CanMove = false
	else
		self.rTime[3] = false
		self.CanMove = true
		self.rTime[4] = 0
		self.rTime[2] = nil
	end	
	
end

function Xerath:Combo(unit)
	-- self:CastQ(unit)
	if ValidTarget(unit) then
		self:CastW(unit)
		self:CastE(unit)
	end
	self:CastR()
end


function Xerath:CastQ(unit)
	self.CastPosition,  self.HitChance,  self.Position = VP:GetLineCastPosition(unit, self.Spells.Q.Delay, self.Spells.Q.Width, self.Spells.Q.Range, self.Spells.Q.Speed, myHero, false)	
	if GetDistance(unit) <= 1400 and self.Spells.Q.Ready() then
		if self.qTime[3] == false then
			CastSpell(_Q, self.CastPosition.x, self.CastPosition.z)
		end
		if GetDistance(unit) < (self.Spells.Q.Range ) then
			self.CastPosition,  self.HitChance,  self.Position = VP:GetLineCastPosition(unit, self.Spells.Q.Delay, self.Spells.Q.Width, self.Spells.Q.Range, self.Spells.Q.Speed, myHero, false)	
			CastSpell2(_Q, DXD3VECTOR3(self.CastPosition.x, self.CastPosition.z , self.CastPosition.y))
		end	
	end
end

function Xerath:CastW(unit)
	self.CastPosition, self.HitChance = VP:GetCircularCastPosition(unit, self.Spells.W.Delay, self.Spells.W.Width, self.Spells.W.Range, self.Spells.W.Speed, myHero, false)
	if GetDistance(unit) <= self.Spells.W.Range and self.Spells.W.Ready() then
		CastSpell(_W, self.CastPosition.x, self.CastPosition.z)
	end
end

function Xerath:CastE(unit)
	self.CastPosition, self.HitChance = VP:GetLineCastPosition(unit, self.Spells.E.Delay, self.Spells.E.Width, self.Spells.E.Range, self.Spells.E.Speed, myHero, true)
	if GetDistance(unit) <= self.Spells.E.Range and self.Spells.E.Ready() then
		if self.HitChance >= 1 then 
			CastSpell(_E, self.CastPosition.x, self.CastPosition.z)
		end
	end
end

function Xerath:CastR()
	self.newTarget = self:GetLowestHero()
	if self.newTarget ~= nil and self.Spells.R.Ready() then
		self.tempDmg = getDmg("R", self.newTarget, myHero) 
		self.rDmg = (self.tempDmg) * (3 - self.rTime[4])
		if self.newTarget.health <= (self.rDmg * 0.95) then
			if (self.newTarget.charName == self.Champ[1] and self.Settings.ulti.champ1) or (self.newTarget.charName == self.Champ[2] and self.Settings.ulti.champ2) or (self.newTarget.charName == self.Champ[3] and self.Settings.ulti.champ3) or (self.newTarget.charName == self.Champ[4] and self.Settings.ulti.champ4) or self.newTarget.charName == self.Champ[5] and self.Settings.ulti.champ5 then 
				self.CastPosition, self.HitChance = VP:GetCircularCastPosition(self.newTarget, self.Spells.R.Delay, self.Spells.R.Width, self.Spells.R.Range, self.Spells.R.Speed, myHero, false)
				if GetDistance(self.newTarget) <= self.Spells.R.Range and self.Spells.R.Ready() then
					CastSpell(_R, self.CastPosition.x, self.CastPosition.z)
				end	
			end
		elseif self.CanMove == false then
			if self.newTarget ~= nil then
				self.CastPosition, self.HitChance = VP:GetCircularCastPosition(self.newTarget, self.Spells.R.Delay, self.Spells.R.Width, self.Spells.R.Range, self.Spells.R.Speed, myHero, false)
				CastSpell(_R, self.CastPosition.x, self.CastPosition.z)
			else
				self.rTime[3] = false
				self.CanMove = true
			end
		end
	end
end

function Xerath:GetLowestHero()
	local LowestHero, LowestHP = nil, 1000000
	for _, unit in pairs(GetEnemyHeroes()) do
		if GetDistance(unit) <= self.Spells.R.Range then 
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

function Xerath:CheckR(unit)
	self.tempDmg = getDmg("R", self.Target, myHero) 
	self.rDmg = (self.tempDmg) * (3 - self.rTime[4])
	if unit.health <= self.rDmg * 0.95 then
		if GetDistance(unit) <= self.Spells.R.Range and self.Spells.R.Ready() then
			self.launchR = true
		end
	end
end

function Xerath:myMenu()
	self.Settings = scriptConfig("Xerath", "AMBER")
	self.Settings:addSubMenu("["..myHero.charName.."] - Combo Settings (SBTW)", "combo")
		self.Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		self.Settings.combo:addParam("useQ", "Use (Q) in Combo", SCRIPT_PARAM_ONOFF, true)
		self.Settings.combo:addParam("useW", "Use (W) in Combo", SCRIPT_PARAM_ONOFF, true)
		self.Settings.combo:addParam("useE", "Use (E) in Combo", SCRIPT_PARAM_ONOFF, true)
		
	self.Settings:addSubMenu("["..myHero.charName.."] - (R) Settings", "ulti")
		self.Settings.ulti:addParam("useR", "Use (R) if Killable", SCRIPT_PARAM_ONOFF, true)
		self.Settings.ulti:addParam("champ1", "Use on "..self.Champ[1], SCRIPT_PARAM_ONOFF, true)
		self.Settings.ulti:addParam("champ2", "Use on "..self.Champ[2], SCRIPT_PARAM_ONOFF, true)
		self.Settings.ulti:addParam("champ3", "Use on "..self.Champ[3], SCRIPT_PARAM_ONOFF, true)
		self.Settings.ulti:addParam("champ4", "Use on "..self.Champ[4], SCRIPT_PARAM_ONOFF, true)
		self.Settings.ulti:addParam("champ5", "Use on "..self.Champ[5], SCRIPT_PARAM_ONOFF, true)
		
		self.Settings.combo:permaShow("comboKey")
		self.Settings.combo:permaShow("useR")
		
		self.Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
		SxOrb:LoadToMenu(self.Settings.Orbwalking)
end

function Xerath:GetCustomTarget(range)

	if self.SelectedTarget ~= nil and ValidTarget(self.SelectedTarget, range) and (Ignore == nil or (Ignore.networkID ~= self.SelectedTarget.networkID)) then
		return self.SelectedTarget
	end
	if self.TargetSelector.target and not self.TargetSelector.target.dead and self.TargetSelector.target.type == myHero.type then
		return self.TargetSelector.target
	else
		return nil
	end
	
end

function Xerath:OnWndMsg(Msg, Key)	
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
				self.SelectedTarget = self.Target
			end
		end
	end
end

function Xerath:OnCastSpell(iSpell, startPos, endPos, targetUnit)
--print("OnCastSpell: " .. iSpell)
	if iSpell == 3 and not self.CanMove then
		self.BlockNextAction = true
	end
end

function Xerath:OnIssueOrder(Unit,iAction,targetPos,targetUnit)
	--print("OnIssueOrder: " .. tostring(self.CanMove))
	if self.CanMove then return end
	--------------------------------------------------------------------------------------------
	--print("work1")
	if Unit.isMe and table.contains(self.Block_iActions, iAction) then
		--print("Work2")
		self.BlockNextAction = true
	end
	--------------------------------------------------------------------------------------------
end

function Xerath:OnSendPacket(p)
	if not self.BlockNextAction then return end
	if p.header == 0x00B5 then p:Block() end
	self.BlockNextAction = false
end
