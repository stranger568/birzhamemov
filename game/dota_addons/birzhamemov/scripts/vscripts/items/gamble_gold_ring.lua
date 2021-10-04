item_gamble_gold_ring = class({})

LinkLuaModifier("modifier_item_gamble_gold_ring", "items/gamble_gold_ring", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_gamble_gold_ring_2", "items/gamble_gold_ring", LUA_MODIFIER_MOTION_NONE)

function item_gamble_gold_ring:GetIntrinsicModifierName()
	if self:GetCaster():HasModifier("modifier_item_gamble_gold_ring_2") then return end
    return "modifier_item_gamble_gold_ring"
end

function item_gamble_gold_ring:OnSpellStart()
	if self:GetCaster():HasModifier("modifier_item_gamble_gold_ring_2") then return end
	local int_min = self:GetSpecialValueFor("int_min")
	local int_max = self:GetSpecialValueFor("int_max")
	local str_min = self:GetSpecialValueFor("str_min")
	local str_max = self:GetSpecialValueFor("str_max")
	local agi_min = self:GetSpecialValueFor("agi_min")
	local agi_max = self:GetSpecialValueFor("agi_max")
	local dmg_min = self:GetSpecialValueFor("dmg_min")
	local dmg_max = self:GetSpecialValueFor("dmg_max")
	local attack_speed_min = self:GetSpecialValueFor("attack_speed_min")
	local attack_speed_max = self:GetSpecialValueFor("attack_speed_max")
	local movespeed_min = self:GetSpecialValueFor("movespeed_min")
	local movespeed_max = self:GetSpecialValueFor("movespeed_max")
	local armor_min = self:GetSpecialValueFor("armor_min")
	local armor_max = self:GetSpecialValueFor("armor_max")
	local magresist_min = self:GetSpecialValueFor("magresist_min")
	local magresist_max = self:GetSpecialValueFor("magresist_max")
	local health_min = self:GetSpecialValueFor("health_min")
	local health_max = self:GetSpecialValueFor("health_max")
	local mana_min = self:GetSpecialValueFor("mana_min")
	local mana_max = self:GetSpecialValueFor("mana_max")
	local hpregen_min = self:GetSpecialValueFor("hpregen_min")
	local hpregen_max = self:GetSpecialValueFor("hpregen_max")
	local manaregen_min = self:GetSpecialValueFor("manaregen_min")
	local manaregen_max = self:GetSpecialValueFor("manaregen_max")
	local magdmg_min = self:GetSpecialValueFor("magdmg_min")
	local magdmg_max = self:GetSpecialValueFor("magdmg_max")
	if 1 >= RandomInt(1, 100) then
		self.strength = int_min
		self.agility =	str_min
		self.intellect = agi_min
		self.damage = dmg_min
		self.attack_speed =	attack_speed_min
		self.movespeed = movespeed_min
		self.armor = armor_min
		self.mag_resist =	magresist_min
		self.hp_regen =	hpregen_min
		self.mana_regen = manaregen_min
		self.mag_damage = magdmg_min
		self:GetCaster():EmitSound("CasinoLucky")
	elseif 1 >= RandomInt(1, 100) then
		self.strength = int_max
		self.agility =	str_max
		self.intellect = agi_max
		self.damage = dmg_max
		self.attack_speed =	attack_speed_max
		self.movespeed = movespeed_max
		self.armor = armor_max
		self.mag_resist =	magresist_max
		self.hp_regen =	hpregen_max
		self.mana_regen = manaregen_max
		self.mag_damage = magdmg_max
		self:GetCaster():EmitSound("CasinoLucky")
	else
		self.strength = RandomInt(int_min, int_max)
		self.agility =	RandomInt(str_min, str_max)
		self.intellect = RandomInt(agi_min, agi_max)
		self.damage = RandomInt(dmg_min, dmg_max)
		self.attack_speed =	RandomInt(attack_speed_min, attack_speed_max)
		self.movespeed = RandomInt(movespeed_min, movespeed_max)
		self.armor = RandomInt(armor_min, armor_max)
		self.mag_resist =	RandomInt(magresist_min, magresist_max)
		self.hp_regen =	RandomInt(hpregen_min, hpregen_max)
		self.mana_regen = RandomInt(manaregen_min, manaregen_max)
		self.mag_damage = RandomInt(magdmg_min, magdmg_max)
		self:GetCaster():EmitSound("CasinoRandom")
	end

	local bonuses = {
		"lifesteal",
		"cooldown",
		"evasion",
		"all_stats",
		"resist",
		"incoming"
	}


	self.two_bonus_int = 0
	self.two_bonus = "none"

	if 5 >= RandomInt(1, 100) then
		self.two_bonus = bonuses[RandomInt(1, #bonuses)]
	end

	if self.two_bonus == "lifesteal" then
		self.two_bonus_int = self:GetSpecialValueFor("lifesteal")
	elseif self.two_bonus == "cooldown" then
		self.two_bonus_int = self:GetSpecialValueFor("cooldown")
	elseif self.two_bonus == "evasion" then
		self.two_bonus_int = self:GetSpecialValueFor("evasion")
	elseif self.two_bonus == "all_stats" then
		self.two_bonus_int = self:GetSpecialValueFor("all_stats")
	elseif self.two_bonus == "resist" then
		self.two_bonus_int = self:GetSpecialValueFor("resist")
	elseif self.two_bonus == "incoming" then
		self.two_bonus_int = self:GetSpecialValueFor("incoming")
	end

	CustomNetTables:SetTableValue('gamble_item', tostring(self:GetCaster():GetPlayerID()), {
	str = self.strength,
	agi = self.agility,
	int = self.intellect,
	damage = self.damage,
	attack_speed = self.attack_speed,
	movespeed = self.movespeed,
	armor = self.armor,
	mag_resist = self.mag_resist,
	hp_regen = self.hp_regen,
	mana_regen = self.mana_regen,
	mag_damage = self.mag_damage,
	two_bonus = self.two_bonus,
	two_bonus_int = self.two_bonus_int
})
	self:GetCaster():CalculateStatBonus(true)
end

item_gamble_gold_ring_2 = class({})

function item_gamble_gold_ring_2:GetIntrinsicModifierName()
    return "modifier_item_gamble_gold_ring_2"
end

function item_gamble_gold_ring_2:OnSpellStart()
	if self:GetCaster():FindAllModifiersByName("modifier_item_gamble_gold_ring_2")[1]:GetAbility() ~= self then return end 
	local int_min = self:GetSpecialValueFor("int_min")
	local int_max = self:GetSpecialValueFor("int_max")
	local str_min = self:GetSpecialValueFor("str_min")
	local str_max = self:GetSpecialValueFor("str_max")
	local agi_min = self:GetSpecialValueFor("agi_min")
	local agi_max = self:GetSpecialValueFor("agi_max")
	local dmg_min = self:GetSpecialValueFor("dmg_min")
	local dmg_max = self:GetSpecialValueFor("dmg_max")
	local attack_speed_min = self:GetSpecialValueFor("attack_speed_min")
	local attack_speed_max = self:GetSpecialValueFor("attack_speed_max")
	local movespeed_min = self:GetSpecialValueFor("movespeed_min")
	local movespeed_max = self:GetSpecialValueFor("movespeed_max")
	local armor_min = self:GetSpecialValueFor("armor_min")
	local armor_max = self:GetSpecialValueFor("armor_max")
	local magresist_min = self:GetSpecialValueFor("magresist_min")
	local magresist_max = self:GetSpecialValueFor("magresist_max")
	local health_min = self:GetSpecialValueFor("health_min")
	local health_max = self:GetSpecialValueFor("health_max")
	local mana_min = self:GetSpecialValueFor("mana_min")
	local mana_max = self:GetSpecialValueFor("mana_max")
	local hpregen_min = self:GetSpecialValueFor("hpregen_min")
	local hpregen_max = self:GetSpecialValueFor("hpregen_max")
	local manaregen_min = self:GetSpecialValueFor("manaregen_min")
	local manaregen_max = self:GetSpecialValueFor("manaregen_max")
	local magdmg_min = self:GetSpecialValueFor("magdmg_min")
	local magdmg_max = self:GetSpecialValueFor("magdmg_max")

	if 1 >= RandomInt(1, 100) then
		self.strength = int_min
		self.agility =	str_min
		self.intellect = agi_min
		self.damage = dmg_min
		self.attack_speed =	attack_speed_min
		self.movespeed = movespeed_min
		self.armor = armor_min
		self.mag_resist =	magresist_min
		self.hp_regen =	hpregen_min
		self.mana_regen = manaregen_min
		self.mag_damage = magdmg_min
		self:GetCaster():EmitSound("CasinoLucky")
	elseif 1 >= RandomInt(1, 100) then
		self.strength = int_max
		self.agility =	str_max
		self.intellect = agi_max
		self.damage = dmg_max
		self.attack_speed =	attack_speed_max
		self.movespeed = movespeed_max
		self.armor = armor_max
		self.mag_resist =	magresist_max
		self.hp_regen =	hpregen_max
		self.mana_regen = manaregen_max
		self.mag_damage = magdmg_max
		self:GetCaster():EmitSound("CasinoLucky")
	else
		self.strength = RandomInt(int_min, int_max)
		self.agility =	RandomInt(str_min, str_max)
		self.intellect = RandomInt(agi_min, agi_max)
		self.damage = RandomInt(dmg_min, dmg_max)
		self.attack_speed =	RandomInt(attack_speed_min, attack_speed_max)
		self.movespeed = RandomInt(movespeed_min, movespeed_max)
		self.armor = RandomInt(armor_min, armor_max)
		self.mag_resist =	RandomInt(magresist_min, magresist_max)
		self.hp_regen =	RandomInt(hpregen_min, hpregen_max)
		self.mana_regen = RandomInt(manaregen_min, manaregen_max)
		self.mag_damage = RandomInt(magdmg_min, magdmg_max)
		self:GetCaster():EmitSound("CasinoRandom")
	end

	local bonuses = {
		"lifesteal",
		"cooldown",
		"evasion",
		"all_stats",
		"resist",
		"incoming"
	}


	self.two_bonus_int = 0
	self.two_bonus = "none"

	if 5 >= RandomInt(1, 100) then
		self.two_bonus = bonuses[RandomInt(1, #bonuses)]
	end

	if self.two_bonus == "lifesteal" then
		self.two_bonus_int = self:GetSpecialValueFor("lifesteal")
	elseif self.two_bonus == "cooldown" then
		self.two_bonus_int = self:GetSpecialValueFor("cooldown")
	elseif self.two_bonus == "evasion" then
		self.two_bonus_int = self:GetSpecialValueFor("evasion")
	elseif self.two_bonus == "all_stats" then
		self.two_bonus_int = self:GetSpecialValueFor("all_stats")
	elseif self.two_bonus == "resist" then
		self.two_bonus_int = self:GetSpecialValueFor("resist")
	elseif self.two_bonus == "incoming" then
		self.two_bonus_int = self:GetSpecialValueFor("incoming")
	end

	CustomNetTables:SetTableValue('gamble_item', tostring(self:GetCaster():GetPlayerID()), {
	str = self.strength,
	agi = self.agility,
	int = self.intellect,
	damage = self.damage,
	attack_speed = self.attack_speed,
	movespeed = self.movespeed,
	armor = self.armor,
	mag_resist = self.mag_resist,
	hp_regen = self.hp_regen,
	mana_regen = self.mana_regen,
	mag_damage = self.mag_damage,
	two_bonus = self.two_bonus,
	two_bonus_int = self.two_bonus_int
})
	self:GetCaster():CalculateStatBonus(true)
end

modifier_item_gamble_gold_ring = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self)
        return {
        	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        	MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        	MODIFIER_PROPERTY_EVASION_CONSTANT,
        	MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        	MODIFIER_PROPERTY_BONUSDAMAGEOUTGOING_PERCENTAGE,
        	MODIFIER_EVENT_ON_ATTACK_LANDED,
        	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, 
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT ,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, 
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, 
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, 
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, 
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        }
    end,
})

function modifier_item_gamble_gold_ring:OnCreated()
	if not IsServer() then return end
	local Player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
    CustomGameEventManager:Send_ServerToPlayer(Player, "RingTrue", {} )
end

function modifier_item_gamble_gold_ring:OnDestroy()
	if not IsServer() then return end
	local Player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
    CustomGameEventManager:Send_ServerToPlayer(Player, "RingFalse", {} )
	   CustomNetTables:SetTableValue('gamble_item', tostring(self:GetCaster():GetPlayerID()), {
		str = 0,
		agi = 0,
		int = 0,
		damage = 0,
		attack_speed = 0,
		movespeed = 0,
		armor = 0,
		mag_resist = 0,
		hp_regen = 0,
		mana_regen = 0,
		mag_damage = 0,
		two_bonus = 0,
		two_bonus_int = 0
	})
end

function modifier_item_gamble_gold_ring:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "all_stats" and self:GetParent():GetPrimaryAttribute() == 0 then
			return self:GetAbility().two_bonus_int + self:GetAbility().strength
		end
		return self:GetAbility().strength
	end
end

function modifier_item_gamble_gold_ring:GetModifierBonusStats_Agility()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "all_stats" and self:GetParent():GetPrimaryAttribute() == 1 then
			return self:GetAbility().two_bonus_int + self:GetAbility().agility
		end
		return self:GetAbility().agility
	end
end

function modifier_item_gamble_gold_ring:GetModifierBonusStats_Intellect()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "all_stats" and self:GetParent():GetPrimaryAttribute() == 2 then
			return self:GetAbility().two_bonus_int + self:GetAbility().intellect
		end
		return self:GetAbility().intellect
	end
end

function modifier_item_gamble_gold_ring:GetModifierPercentageCooldown()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "cooldown" then
			return self:GetAbility().two_bonus_int
		end
	end
end

function modifier_item_gamble_gold_ring:GetModifierEvasion_Constant()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "evasion" then
			return self:GetAbility().two_bonus_int
		end
	end
end

function modifier_item_gamble_gold_ring:GetModifierStatusResistanceStacking()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "resist" then
			return self:GetAbility().two_bonus_int
		end
	end
end

function modifier_item_gamble_gold_ring:GetModifierBonusDamageOutgoing_Percentage()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "incoming" then
			return self:GetAbility().two_bonus_int
		end
	end
end

function modifier_item_gamble_gold_ring:OnAttackLanded(params)
	if self:GetAbility() then
		if params.attacker == self:GetParent() then
			if self:GetAbility().two_bonus == "lifesteal" then
				self:GetParent():Heal(params.damage/100*self:GetAbility().two_bonus_int, self:GetAbility())
			end
		end	
	end
end

function modifier_item_gamble_gold_ring:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then
		return self:GetAbility().damage
	end
end

function modifier_item_gamble_gold_ring:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then
		return self:GetAbility().attack_speed
	end
end

function modifier_item_gamble_gold_ring:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then
		return self:GetAbility().movespeed
	end
end

function modifier_item_gamble_gold_ring:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then
		return self:GetAbility().armor
	end
end

function modifier_item_gamble_gold_ring:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then
		return self:GetAbility().mag_resist
	end
end

function modifier_item_gamble_gold_ring:GetModifierConstantHealthRegen()
	if self:GetAbility() then
		return self:GetAbility().hp_regen
	end
end

function modifier_item_gamble_gold_ring:GetModifierConstantManaRegen()
	if self:GetAbility() then
		return self:GetAbility().mana_regen
	end
end

function modifier_item_gamble_gold_ring:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then
		return self:GetAbility().mag_damage
	end
end

modifier_item_gamble_gold_ring_2 = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self)
        return {
        	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        	MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        	MODIFIER_PROPERTY_EVASION_CONSTANT,
        	MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        	MODIFIER_PROPERTY_BONUSDAMAGEOUTGOING_PERCENTAGE,
        	MODIFIER_EVENT_ON_ATTACK_LANDED,
        	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, 
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT ,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, 
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, 
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, 
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, 
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        }
    end,
})

function modifier_item_gamble_gold_ring_2:OnCreated()
	if not IsServer() then return end
	local Player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
    CustomGameEventManager:Send_ServerToPlayer(Player, "RingTrue", {} )
    self:StartIntervalThink(0.5)
end

function modifier_item_gamble_gold_ring_2:OnIntervalThink()
	if not IsServer() then return end
	local Player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
    CustomGameEventManager:Send_ServerToPlayer(Player, "RingTrue", {} )
end

function modifier_item_gamble_gold_ring_2:OnDestroy()
	if not IsServer() then return end
	self.two_bonus_int = 0
	self.two_bonus = "none"
	self.strength = 0
	self.agility =	0
	self.intellect = 0
	self.damage = 0
	self.attack_speed =	0
	self.movespeed = 0
	self.armor = 0
	self.mag_resist =	0
	self.hp_regen =	0
	self.mana_regen = 0
	self.mag_damage = 0
	local Player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
    CustomGameEventManager:Send_ServerToPlayer(Player, "RingFalse", {} )
	   CustomNetTables:SetTableValue('gamble_item', tostring(self:GetCaster():GetPlayerID()), {
		str = 0,
		agi = 0,
		int = 0,
		damage = 0,
		attack_speed = 0,
		movespeed = 0,
		armor = 0,
		mag_resist = 0,
		hp_regen = 0,
		mana_regen = 0,
		mag_damage = 0,
		two_bonus = 0,
		two_bonus_int = 0
	})
end

function modifier_item_gamble_gold_ring_2:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "all_stats" and self:GetParent():GetPrimaryAttribute() == 0 then
			return self:GetAbility().two_bonus_int + self:GetAbility().strength
		end
		return self:GetAbility().strength
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierBonusStats_Agility()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "all_stats" and self:GetParent():GetPrimaryAttribute() == 1 then
			return self:GetAbility().two_bonus_int + self:GetAbility().agility
		end
		return self:GetAbility().agility
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierBonusStats_Intellect()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "all_stats" and self:GetParent():GetPrimaryAttribute() == 2 then
			return self:GetAbility().two_bonus_int + self:GetAbility().intellect
		end
		return self:GetAbility().intellect
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierPercentageCooldown()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "cooldown" then
			return self:GetAbility().two_bonus_int
		end
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierEvasion_Constant()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "evasion" then
			return self:GetAbility().two_bonus_int
		end
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierStatusResistanceStacking()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "resist" then
			return self:GetAbility().two_bonus_int
		end
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierBonusDamageOutgoing_Percentage()
	if self:GetAbility() then
		if self:GetAbility().two_bonus == "incoming" then
			return self:GetAbility().two_bonus_int
		end
	end
end

function modifier_item_gamble_gold_ring_2:OnAttackLanded(params)
	if self:GetAbility() then
		if params.attacker == self:GetParent() then
			if self:GetAbility().two_bonus == "lifesteal" then
				self:GetParent():Heal(params.damage/100*self:GetAbility().two_bonus_int, self:GetAbility())
			end
		end	
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then
		return self:GetAbility().damage
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then
		return self:GetAbility().attack_speed
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then
		return self:GetAbility().movespeed
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then
		return self:GetAbility().armor
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then
		return self:GetAbility().mag_resist
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierConstantHealthRegen()
	if self:GetAbility() then
		return self:GetAbility().hp_regen
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierConstantManaRegen()
	if self:GetAbility() then
		return self:GetAbility().mana_regen
	end
end

function modifier_item_gamble_gold_ring_2:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then
		return self:GetAbility().mag_damage
	end
end