LinkLuaModifier( "modifier_item_demon_paper", "items/demon_paper", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_demon_paper_active", "items/demon_paper", LUA_MODIFIER_MOTION_NONE )

item_demon_paper = class({})

function item_demon_paper:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_demon_paper_active", {duration = duration})
	EmitSoundOn("DOTA_Item.Satanic.Activate", self:GetCaster())
	EmitSoundOn("Hero_DoomBringer.Doom", self:GetCaster())
end

function item_demon_paper:GetIntrinsicModifierName() 
	return "modifier_item_demon_paper"
end

modifier_item_demon_paper = class({})

function modifier_item_demon_paper:IsHidden()
	return true
end

function modifier_item_demon_paper:IsPurgable()
    return false
end

function modifier_item_demon_paper:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_demon_paper:OnCreated()
	self.bonus_strength = self:GetAbility():GetSpecialValueFor("bonus_strength")
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.bonus_hp_regen = self:GetAbility():GetSpecialValueFor("bonus_hp_regen")
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	self.bonus_lifesteal = self:GetAbility():GetSpecialValueFor("bonus_lifesteal")
	self.bonus_resist = self:GetAbility():GetSpecialValueFor("bonus_resist")
end

function modifier_item_demon_paper:DeclareFunctions()
return 	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		}
end

function modifier_item_demon_paper:GetModifierBonusStats_Strength()
	return self.bonus_strength
end

function modifier_item_demon_paper:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_item_demon_paper:GetModifierStatusResistanceStacking()
	return self.bonus_resist
end

function modifier_item_demon_paper:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            local lifesteal = self:GetAbility():GetSpecialValueFor("bonus_lifesteal") / 100
            self:GetParent():Heal(params.damage * lifesteal, self:GetAbility())
        end
    end
end

modifier_item_demon_paper_active = class({})

function modifier_item_demon_paper_active:GetEffectName()
	return "particles/items2_fx/satanic_buff.vpcf"
end

function modifier_item_demon_paper_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_demon_paper_active:OnCreated()
	if not IsServer() then return end
	self.Effect = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_staff_glory/warlock_upheaval_hellborn_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.Effect, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.Effect, 1, self:GetParent():GetAbsOrigin())
end

function modifier_item_demon_paper_active:OnDestroy()
	if not IsServer() then return end
	StopSoundOn("Hero_DoomBringer.Doom", self:GetParent())
	ParticleManager:DestroyParticle(self.Effect, false)
end

function modifier_item_demon_paper_active:DeclareFunctions()
return 	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE
		}
end

function modifier_item_demon_paper_active:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            local lifesteal = self:GetAbility():GetSpecialValueFor("bonus_lifesteal_active") / 100
            self:GetParent():Heal(params.damage * lifesteal, self:GetAbility())
        end
    end
end

function modifier_item_demon_paper_active:OnTakeDamage(params)
    if IsServer() then
        if params.attacker == self:GetParent() or params.unit == self:GetParent() then
            if params.damage_type == 1 then
            	if params.attacker:HasModifier("modifier_item_birzha_blade_mail_active") or params.unit:HasModifier("modifier_item_birzha_blade_mail_active") then return end
            	ApplyDamage({attacker = params.attacker, victim = params.unit, ability = params.ability, damage = params.original_damage, damage_type = DAMAGE_TYPE_PURE, damage_flag = DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR})
            end
        end
    end
end