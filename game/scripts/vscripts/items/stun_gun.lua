LinkLuaModifier( "modifier_item_stun_gun", "items/stun_gun", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_stun_gun_haste", "items/stun_gun", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_stun_gun_debuff_slow", "items/stun_gun", LUA_MODIFIER_MOTION_NONE )

item_stun_gun = class({})

function item_stun_gun:GetIntrinsicModifierName() 
	return "modifier_item_stun_gun"
end

modifier_item_stun_gun = class({})

function modifier_item_stun_gun:IsHidden() return true end
function modifier_item_stun_gun:IsPurgable() return false end
function modifier_item_stun_gun:IsPurgeException() return false end
function modifier_item_stun_gun:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_stun_gun:OnCreated()
	self.attack_record = {}
end

function modifier_item_stun_gun:DeclareFunctions()
	return 	
	{
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
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_stun_gun:GetModifierAttackSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_stun_gun:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_stun_gun:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_int")
end

function modifier_item_stun_gun:GetModifierConstantManaRegen()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_stun_gun:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if params.attacker:IsIllusion() then return end
	if params.attacker:GetUnitName() == "npc_palnoref_chariot_illusion" then return end
	if params.attacker:GetUnitName() == "npc_palnoref_chariot_illusion_2" then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_stun_gun")[1] ~= self then return end

	local chance = self:GetAbility():GetSpecialValueFor("chance")

	if params.no_attack_cooldown then
		local chance = self:GetAbility():GetSpecialValueFor("chance")
		if self:GetAbility():IsFullyCastable() and (not self:GetCaster():IsRangedAttacker()) then
			chance = self:GetAbility():GetSpecialValueFor("maximum_chance_tooltip")
		end
		if RollPercentage(chance) then
			self.attack_record[params.record] = true
		end
	end

	if self.attack_record[params.record] ~= nil then
		if not params.attacker:IsRangedAttacker() then
			if self:GetAbility():IsFullyCastable() then
				self:GetAbility():UseResources(false,false,false,true)
				params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_stun_gun_haste", {duration = 1})
			end
		end
		LaunchLightning(params.attacker, params.target, self:GetAbility(), self:GetAbility():GetSpecialValueFor("damage"), self:GetAbility():GetSpecialValueFor("radius"))
	end
end

function modifier_item_stun_gun:GetModifierPreAttack_CriticalStrike(params)
	if self:GetParent():IsIllusion() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_stun_gun")[1] ~= self then return end

	local chance = self:GetAbility():GetSpecialValueFor("chance")

	if self:GetAbility():IsFullyCastable() and (not self:GetCaster():IsRangedAttacker()) then
		chance = self:GetAbility():GetSpecialValueFor("maximum_chance_tooltip")
	end

	if RollPercentage(chance) then
		self.attack_record[params.record] = true
		return self:GetAbility():GetSpecialValueFor("crit")
	end
end

modifier_item_stun_gun_haste = class({})

function modifier_item_stun_gun_haste:IsHidden()
 	return true
end

function modifier_item_stun_gun_haste:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK
	}
end

function modifier_item_stun_gun_haste:OnAttack(params)
	if params.attacker ~= self:GetParent() then return end
	if not params.target:IsWard() then
		params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_stun_gun_debuff_slow", {duration = 0.8})
	end
    self:Destroy()
end

function modifier_item_stun_gun_haste:GetModifierAttackSpeedBonus_Constant()
	return 999999
end

modifier_item_stun_gun_debuff_slow = class({})

function modifier_item_stun_gun_debuff_slow:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_item_stun_gun_debuff_slow:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("enemy_slow")
end

function LaunchLightning(caster, target, ability, damage, bounce_radius)
	if caster:IsNull() then return end

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
		if caster:IsNull() then return end
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

	if caster:IsRealHero() then
		if caster:GetPrimaryAttribute() == 0 then
			damage = damage + (caster:GetStrength() * ability:GetSpecialValueFor("attribute_mult"))
		end

		if caster:GetPrimaryAttribute() == 1 then
			damage = damage + (caster:GetAgility() * ability:GetSpecialValueFor("attribute_mult"))
		end

		if caster:GetPrimaryAttribute() == 2 then
			damage = damage + (caster:GetIntellect() * ability:GetSpecialValueFor("attribute_mult"))
		end
	end
	
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
end