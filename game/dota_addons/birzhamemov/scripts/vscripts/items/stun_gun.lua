LinkLuaModifier( "modifier_item_stun_gun", "items/stun_gun", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_stun_gun_haste", "items/stun_gun", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_stun_gun_debuff_slow", "items/stun_gun", LUA_MODIFIER_MOTION_NONE )

item_stun_gun = class({})

function item_stun_gun:GetIntrinsicModifierName() 
	return "modifier_item_stun_gun"
end

modifier_item_stun_gun = class({})

function modifier_item_stun_gun:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	self.strength = self:GetAbility():GetSpecialValueFor("bonus_strength")
	self.intellect = self:GetAbility():GetSpecialValueFor("bonus_int")
	self.mana_regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_stun_gun:IsHidden()
	return true
end

function modifier_item_stun_gun:IsPurgable()
    return false
end

function modifier_item_stun_gun:DeclareFunctions()
return 	{
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_EVENT_ON_ATTACK,
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		}
end

function modifier_item_stun_gun:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_stun_gun:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_item_stun_gun:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_item_stun_gun:GetModifierBonusStats_Intellect()
	return self.intellect
end

function modifier_item_stun_gun:GetModifierConstantManaRegen()
	return self.mana_regen
end

function modifier_item_stun_gun:OnAttackLanded( keys )
	if IsServer() then
		local attacker = self:GetParent()

		if attacker ~= keys.attacker then
			return
		end

		if attacker:IsIllusion() then
			return
		end

		local target = keys.target
		if attacker:GetTeam() == target:GetTeam() then
			return
		end	

		local ability = self:GetAbility()
		local chance = ability:GetSpecialValueFor("chance")
		if chance >= RandomInt(1, 100) then
			LaunchLightning(attacker, target, ability, 200, 650)
		end

		if attacker:IsRangedAttacker() then return end
		if ability:IsFullyCastable() then
			ability:UseResources(false,false,true)
			LaunchLightning(attacker, target, ability, 200, 650)
			attacker:AddNewModifier(attacker, ability, "modifier_item_stun_gun_haste", {duration = 1})
		end
	end
end

function modifier_item_stun_gun:GetModifierPreAttack_CriticalStrike(params)
	if self:GetParent():IsIllusion() then
		return
	end
	local chance = self:GetAbility():GetSpecialValueFor("chance")
	if self:GetAbility():IsFullyCastable() and (not self:GetCaster():IsRangedAttacker()) then
		chance = 100
	end
	if chance >= RandomInt(1, 100) then
		return 200
	end
end

modifier_item_stun_gun_haste = class({})

function modifier_item_stun_gun_haste:IsHidden()
 	return true
end

function modifier_item_stun_gun_haste:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_EVENT_ON_ATTACK
		}
	return decFuns
end

function modifier_item_stun_gun_haste:OnAttack(keys)
	if self:GetParent() == keys.attacker then
		keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_stun_gun_debuff_slow", {duration = 0.8})
		self:Destroy()
	end
end

function modifier_item_stun_gun_haste:GetModifierAttackSpeedBonus_Constant()
	return 999999
end

modifier_item_stun_gun_debuff_slow = class({})

function modifier_item_stun_gun_debuff_slow:IsDebuff()
 	return true
end

function modifier_item_stun_gun_debuff_slow:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
		}
	return decFuns
end

function modifier_item_stun_gun_debuff_slow:GetModifierMoveSpeedBonus_Percentage()
	return -100
end

function LaunchLightning(caster, target, ability, damage, bounce_radius)
	local targets_hit = { target }
	local search_sources = { target	}

	if caster:HasItemInInventory("item_maelstrom") or caster:HasItemInInventory("item_mjollnir") then
		return
	end
	if caster:GetUnitName() == "npc_dota_hero_void_spirit" then
		caster:EmitSound("van_stungun")
	end
	caster:EmitSound("Item.Maelstrom.Chain_Lightning")
	target:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
	ZapThem(caster, ability, caster, target, damage)
	while #search_sources > 0 do
		for potential_source_index, potential_source in pairs(search_sources) do
			local nearby_enemies = FindUnitsInRadius(caster:GetTeamNumber(), potential_source:GetAbsOrigin(), nil, bounce_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
			for _, potential_target in pairs(nearby_enemies) do
				local already_hit = false
				for _, hit_target in pairs(targets_hit) do
					if potential_target == hit_target then
						already_hit = true
						break
					end
				end
				if not already_hit then
					ZapThem(caster, ability, potential_source, potential_target, damage)
					targets_hit[#targets_hit+1] = potential_target
					search_sources[#search_sources+1] = potential_target
				end
			end
			table.remove(search_sources, potential_source_index)
		end
	end
end

function ZapThem(caster, ability, source, target, damage)
	local particle = "particles/econ/events/ti7/maelstorm_ti7.vpcf"

	local bounce_pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, source)
	ParticleManager:SetParticleControlEnt(bounce_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(bounce_pfx, 1, source, PATTACH_POINT_FOLLOW, "attach_hitloc", source:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(bounce_pfx, 2, Vector(1, 1, 1))
	ParticleManager:ReleaseParticleIndex(bounce_pfx)

	if not caster:IsHero() then caster = caster:GetOwner() end

	if caster:GetPrimaryAttribute() == 0 then
		damage = damage + (caster:GetStrength() * 0.75)
	end

	if caster:GetPrimaryAttribute() == 1 then
		damage = damage + (caster:GetAgility() * 0.75)
	end

	if caster:GetPrimaryAttribute() == 2 then
		damage = damage + (caster:GetIntellect() * 0.75)
	end

	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
end