LinkLuaModifier( "modifier_item_demon_paper", "items/demon_paper", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_demon_paper_active", "items/demon_paper", LUA_MODIFIER_MOTION_NONE )

item_demon_paper = class({})

function item_demon_paper:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():Purge(false, true, false, false, false)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_demon_paper_active", {duration = duration})
	self:GetCaster():EmitSound("DOTA_Item.Satanic.Activate")
end

function item_demon_paper:GetIntrinsicModifierName() 
	return "modifier_item_demon_paper"
end

modifier_item_demon_paper = class({})

function modifier_item_demon_paper:IsHidden() return true end
function modifier_item_demon_paper:IsPurgable() return false end
function modifier_item_demon_paper:IsPurgeException() return false end
function modifier_item_demon_paper:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_demon_paper:OnCreated()
	if not IsServer() then return end
	self:GetParent():EmitSound("Hero_DoomBringer.Doom")
end

function modifier_item_demon_paper:DeclareFunctions()
	return 	
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_item_demon_paper:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_demon_paper:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_demon_paper:GetModifierStatusResistanceStacking()
	return self:GetAbility():GetSpecialValueFor("status_resistance")
end

function modifier_item_demon_paper:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local heal = self:GetAbility():GetSpecialValueFor("bonus_lifesteal") / 100 * params.damage
        self:GetParent():Heal(heal, self:GetAbility())
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

modifier_item_demon_paper_active = class({})

function modifier_item_demon_paper_active:GetTexture()
	return "items/demon_paper"
end

function modifier_item_demon_paper_active:GetEffectName()
	return "particles/items2_fx/satanic_buff.vpcf"
end

function modifier_item_demon_paper_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_demon_paper_active:OnCreated()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_staff_glory/warlock_upheaval_hellborn_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, self:GetParent():GetAbsOrigin())
	self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_item_demon_paper_active:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("Hero_DoomBringer.Doom")
end

function modifier_item_demon_paper_active:DeclareFunctions()
	return 	
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ALWAYS_ETHEREAL_ATTACK,
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
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        if params.damage_type == DAMAGE_TYPE_PHYSICAL then
        	ApplyDamage({attacker = params.attacker, victim = params.unit, ability = params.inflictor, damage = params.original_damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR + DOTA_DAMAGE_FLAG_REFLECTION })
        end
    end
end

function modifier_item_demon_paper_active:GetAllowEtherealAttack()
    return 1
end

function modifier_item_demon_paper_active:GetModifierTotalDamageOutgoing_Percentage( params )
	if params.damage_type ~= DAMAGE_TYPE_PHYSICAL then return 0 end

	local damageTable = 
	{
		victim = params.target,
		attacker = self:GetParent(),
		damage = params.original_damage,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flag = DOTA_DAMAGE_FLAG_MAGIC_AUTO_ATTACK + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
		ability = self:GetAbility()
	}

	ApplyDamage( damageTable )

	return -1000
end