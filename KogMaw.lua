if myHero.charName ~= "KogMaw" then return end
class 'KogMaw'
getDivine = false
getVP = false

function OnLoad()
	assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("OBECIIDHDHH") 
	if VIP_USER and FileExist(LIB_PATH .. "/DivinePred.lua") then 
		require "DivinePred" 
		dp = DivinePred()
		getDivine = true
	end
	if FileExist(LIB_PATH .. "/VPrediction.lua") then 
		require "VPrediction" 
		VP = VPrediction()
		getVP = true
	end
	if (getVP or getDivine) and FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
		SAC = false
		SX = false
		print("<font color=\"#DF7401\"><b>Aurora's KogMaw (BETA): </b></font><font color=\"#D7DF01\">Waiting for any OrbWalk authentification</b></font>")
		DelayAction(function()	
			CustomOnLoad()
		end, 10)
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
	print("<font color=\"#DF7401\"><b>Aurora's KogMaw (BETA): </b></font><font color=\"#D7DF01\">Script Loaded ! This script dont have autoupdate ! Check by yourself on the forum if a new version available</b></font>")
	self:myVariables()
	self:myMenu()
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
		Q = { Range = 1000, Width = 70, Delay = 0.4, Speed = 900, TS = 0, Ready = function() return myHero:CanUseSpell(0) == 0 end,},
		W = { Ready = function() return myHero:CanUseSpell(1) == 0 end,},
		E = { Range = 1200, Width = 120, Delay = 0.5, Speed = 800, TS = 0, Ready = function() return myHero:CanUseSpell(2) == 0 end,},
		R = { Range = 1200 , Ranget = {1200,1500,1800} , Width = 65, Delay = 0.6, Speed = 900, TS = 0, Ready = function() return myHero:CanUseSpell(3) == 0 end,},
	}
	
	self.isPassive = false
	self.lastR = 0 
	self.AA = 0
	self.aaRange = myHero.range + myHero.boundingRadius + self.AA
	self.wUsed = false
	self.lastW = 0
	
	if myHero:GetSpellData(_R).level == 3 then self.Spells.R.Range = self.Spells.R.Ranget[3] end
	if getDivine then
		self.SkillShotR = CircleSS(self.Spells.R.Speed,self.Spells.R.Range,self.Spells.R.Width,self.Spells.R.Delay, math.huge)
		self.SkillShotQ = LineSS(self.Spells.Q.Speed,self.Spells.Q.Range,self.Spells.Q.Width,self.Spells.Q.Delay, 0)
		self.SkillShotE = LineSS(self.Spells.E.Speed,self.Spells.E.Range,self.Spells.E.Width,self.Spells.E.Delay, math.huge)
	end
end

function KogMaw:myMenu()
	self.Settings = scriptConfig("KogMaw", "Aurora Scriptersâ?¢")
	
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
			if getDivine then
				self.Settings.prediction:addParam("predictionType", "0 = VPred | 1 = DP" , SCRIPT_PARAM_SLICE, 1, 0, 1, 0)
			else
				self.Settings.prediction:addParam("predictionType", "0 = VPred | 1 = DP" , SCRIPT_PARAM_SLICE, 0, 0, 1, 0)
			end
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
				self.SelectedTarget = self.Target
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
	if self.Spells.Q.Ready() and GetDistance(unit) <= self.Settings.spells.Qspells.qRange and GetDistance(unit) > self.Settings.spells.Qspells.minRange then
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
	if self.Settings.spells.Wspells.wType == 1 then
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
	if self.Spells.E.Ready() and GetDistance(unit) <= self.Settings.spells.Espells.eRange and GetDistance(unit) > self.Settings.spells.Espells.minRange then
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
