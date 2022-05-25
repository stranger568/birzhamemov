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
	target:TriggerSpellReflect(self)
	target:AddNewModifier(self:GetCaster(), self, "modifier_item_birzha_diffusal_blade_2_debuff", {duration = duration})
	target:Purge(true, false, false, false, true)
end

modifier_item_birzha_diffusal_blade_2 = class({})

function modifier_item_birzha_diffusal_blade_2:IsHidden()		return true end
function modifier_item_birzha_diffusal_blade_2:IsPurgable()		return false end
function modifier_item_birzha_diffusal_blade_2:RemoveOnDeath()	return false end

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

function modifier_item_birzha_diffusal_blade_2:OnAttackLanded(keys)
    if keys.attacker == self:GetParent() then
    	local target = keys.target
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

		if not target:IsMagicImmune() then
			if(target:GetMana() >= manaBurn) then
				damageTable.damage = manaBurn * manaDamage
				if not self:GetParent():IsIllusion() then
					target:ReduceMana(manaBurn)
				else
					target:ReduceMana(25)
				end
			else
				damageTable.damage = target:GetMana() * manaDamage
				if not self:GetParent():IsIllusion() then
					target:ReduceMana(manaBurn)
				else
					target:ReduceMana(25)
				end
			end

			ApplyDamage(damageTable)
		end
    end
end

modifier_item_birzha_diffusal_blade_2_debuff = class({
	IsDebuff =            function() return true end,
	GetEffectAttachType = function() return PATTACH_OVERHEAD_FOLLOW end,
	GetEffectName =       function() return "particles/items4_fx/nullifier_mute_debuff.vpcf" end,
})

function modifier_item_birzha_diffusal_blade_2_debuff:GetTexture()
  	return "items/diff2"
end

function modifier_item_birzha_diffusal_blade_2_debuff:OnCreated()
    self.mv = self:GetAbility():GetSpecialValueFor("slow_movespeed")
end

function modifier_item_birzha_diffusal_blade_2_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_item_birzha_diffusal_blade_2_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.mv
end

function modifier_item_birzha_diffusal_blade_2_debuff:CheckState()
	return {
		[MODIFIER_STATE_MUTED] = true,
	}
end