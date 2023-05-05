LinkLuaModifier("modifier_item_bloodthorn_arena", "items/item_bloodthorn", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bloodthorn_arena_silence", "items/item_bloodthorn", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bloodthorn_arena_crit", "items/item_bloodthorn", LUA_MODIFIER_MOTION_NONE)

item_bloodthorn_2 = class({})

function item_bloodthorn_2:GetIntrinsicModifierName()
	return "modifier_item_bloodthorn_arena"
end

function item_bloodthorn_2:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	target:TriggerSpellReflect(self)
	target:EmitSound("DOTA_Item.Orchid.Activate")
	target:AddNewModifier(self:GetCaster(), self, "modifier_item_bloodthorn_arena_silence", {duration = self:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
	target:Purge(true, false, false, false, false)
	if self:GetCaster():GetUnitName() == "npc_dota_hero_void_spirit" then
        self:GetCaster():EmitSound("van_orchid")
    end
end

modifier_item_bloodthorn_arena = class({})

function modifier_item_bloodthorn_arena:IsHidden() return true end
function modifier_item_bloodthorn_arena:IsPurgable() return false end
function modifier_item_bloodthorn_arena:IsPurgeException() return false end
function modifier_item_bloodthorn_arena:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_bloodthorn_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, 
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_item_bloodthorn_arena:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_bloodthorn_arena:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_bloodthorn_arena:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_regenhp")
end

function modifier_item_bloodthorn_arena:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_bloodthorn_arena:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_bloodthorn_arena:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_bloodthorn_arena:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_regenmana")
end

function modifier_item_bloodthorn_arena:OnAttackLanded(params)
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if params.target:IsMagicImmune() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_bloodthorn_arena")[1] ~= self then return end

    local target = params.target

	local manaburn_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(manaburn_pfx, 0, target:GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex(manaburn_pfx)

	local manaBurn = self:GetAbility():GetSpecialValueFor("mana_per_hit")
	local manaDamage = self:GetAbility():GetSpecialValueFor("damage_per_burn")

	local damageTable = {}
	damageTable.attacker = self:GetParent()
	damageTable.victim = target
	damageTable.damage_type = DAMAGE_TYPE_PHYSICAL
	damageTable.ability = self:GetAbility()

	if(target:GetMana() >= manaBurn) then
		damageTable.damage = manaBurn * manaDamage
		if not self:GetParent():IsIllusion() then
			target:Script_ReduceMana(manaBurn, self:GetAbility())
		else
			target:Script_ReduceMana(self:GetAbility():GetSpecialValueFor("mana_per_hit_illusion"), self:GetAbility())
		end
	else
		damageTable.damage = target:GetMana() * manaDamage
		if not self:GetParent():IsIllusion() then
			target:Script_ReduceMana(manaBurn, self:GetAbility())
		else
			target:Script_ReduceMana(self:GetAbility():GetSpecialValueFor("mana_per_hit_illusion"), self:GetAbility())
		end
	end

	ApplyDamage(damageTable)
end

modifier_item_bloodthorn_arena_silence = class({})

function modifier_item_bloodthorn_arena_silence:GetEffectName()
	return "particles/items2_fx/orchid.vpcf"
end

function modifier_item_bloodthorn_arena_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_bloodthorn_arena_silence:CheckState()
	return 
	{
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_EVADE_DISABLED] = true,
	}
end

function modifier_item_bloodthorn_arena_silence:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_item_bloodthorn_arena_silence:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("crit_active")
end

function modifier_item_bloodthorn_arena_silence:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("slow_movespeed")
end

function modifier_item_bloodthorn_arena_silence:OnCreated()
	if IsServer() then
		self.damage = 0
		self:StartIntervalThink(0.2)
		local overhead_particle = ParticleManager:CreateParticle("particles/items4_fx/nullifier_mute.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddParticle(overhead_particle, false, false, -1, false, false)
	end
end

function modifier_item_bloodthorn_arena_silence:OnIntervalThink()
	if IsServer() then
		self:GetParent():Purge(true, false, false, false, false)
	end
end

function modifier_item_bloodthorn_arena_silence:GetStatusEffectName()
	return "particles/status_fx/status_effect_nullifier.vpcf"
end

function modifier_item_bloodthorn_arena_silence:OnTakeDamage(params)
	if not IsServer() then return end
	if params.unit ~= self:GetParent() then return end
	ParticleManager:SetParticleControl(ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.unit), 1, Vector(params.damage))
	self.damage = self.damage + params.damage
end

function modifier_item_bloodthorn_arena_silence:OnAttackStart(params)
	if not IsServer() then return end
	if params.target ~= self:GetParent() then return end
	params.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_bloodthorn_arena_crit", {duration = 1.5})
end

function modifier_item_bloodthorn_arena_silence:OnDestroy()
	if not IsServer() then return end
	if not self:GetAbility() then return end
	local damage = self.damage * self:GetAbility():GetSpecialValueFor("damage_pct") * 0.01
	ParticleManager:SetParticleControl(ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent()), 1, Vector(damage))
	if damage > 0 then
		ApplyDamage({ attacker = self:GetCaster(), victim = self:GetParent(), damage = damage, damage_type = self:GetAbility():GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability = self:GetAbility() })
	end
end

modifier_item_bloodthorn_arena_crit = class({})

function modifier_item_bloodthorn_arena_crit:IsHidden() return true end
function modifier_item_bloodthorn_arena_crit:IsPurgable() return false end

function modifier_item_bloodthorn_arena_crit:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_item_bloodthorn_arena_crit:GetModifierPreAttack_CriticalStrike(params)
	if params.target == self:GetCaster() and params.target:HasModifier("modifier_item_bloodthorn_arena_silence") then
		return self:GetAbility():GetSpecialValueFor("crit_active")
	else
        self:Destroy()
	end
end

function modifier_item_bloodthorn_arena_crit:OnAttackLanded(params)
	if params.attacker ~= self:GetParent() then return end
	params.attacker:RemoveModifierByName("modifier_item_bloodthorn_arena_crit")
end
