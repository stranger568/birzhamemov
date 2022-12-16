LinkLuaModifier("modifier_item_birzha_diffusal_blade_2", "items/diffusal_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_birzha_diffusal_blade_2_debuff", "items/diffusal_blade", LUA_MODIFIER_MOTION_NONE)

item_birzha_diffusal_blade_2 = class({})

function item_birzha_diffusal_blade_2:GetIntrinsicModifierName()
	return "modifier_item_birzha_diffusal_blade_2"
end

function item_birzha_diffusal_blade_2:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	target:AddNewModifier(self:GetCaster(), self, "modifier_item_birzha_diffusal_blade_2_debuff", {duration = duration})
	target:Purge(true, false, false, false, false)
end

modifier_item_birzha_diffusal_blade_2 = class({})

function modifier_item_birzha_diffusal_blade_2:IsHidden() return true end
function modifier_item_birzha_diffusal_blade_2:IsPurgable() return false end
function modifier_item_birzha_diffusal_blade_2:IsPurgeException() return false end
function modifier_item_birzha_diffusal_blade_2:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_birzha_diffusal_blade_2:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_item_birzha_diffusal_blade_2:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("damage")
    end
end

function modifier_item_birzha_diffusal_blade_2:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("armor")
    end
end

function modifier_item_birzha_diffusal_blade_2:GetModifierConstantHealthRegen()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("regen")
    end
end

function modifier_item_birzha_diffusal_blade_2:GetModifierBonusStats_Agility()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("agility")
    end
end

function modifier_item_birzha_diffusal_blade_2:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("intellect")
    end
end

function modifier_item_birzha_diffusal_blade_2:OnAttackLanded(params)
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if params.target:IsMagicImmune() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_birzha_diffusal_blade_2")[1] ~= self then return end
	if self:GetParent():HasModifier("modifier_item_bloodthorn_arena") then return end
	
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
			target:ReduceMana(manaBurn)
		else
			target:ReduceMana(self:GetAbility():GetSpecialValueFor("mana_per_hit_illusion"))
		end
	else
		damageTable.damage = target:GetMana() * manaDamage
		if not self:GetParent():IsIllusion() then
			target:ReduceMana(manaBurn)
		else
			target:ReduceMana(self:GetAbility():GetSpecialValueFor("mana_per_hit_illusion"))
		end
	end

	ApplyDamage(damageTable)
end

modifier_item_birzha_diffusal_blade_2_debuff = class({})

function modifier_item_birzha_diffusal_blade_2_debuff:GetTexture()
  	return "items/diff2"
end

function modifier_item_birzha_diffusal_blade_2_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_item_birzha_diffusal_blade_2_debuff:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("slow_movespeed")
end

function modifier_item_birzha_diffusal_blade_2_debuff:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.2)
		local overhead_particle = ParticleManager:CreateParticle("particles/items4_fx/nullifier_mute.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddParticle(overhead_particle, false, false, -1, false, false)
	end
end

function modifier_item_birzha_diffusal_blade_2_debuff:OnIntervalThink()
	if IsServer() then
		self:GetParent():Purge(true, false, false, false, false)
	end
end

function modifier_item_birzha_diffusal_blade_2_debuff:GetEffectName()
	return "particles/items4_fx/nullifier_mute_debuff.vpcf"
end

function modifier_item_birzha_diffusal_blade_2_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_nullifier.vpcf"
end