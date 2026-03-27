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

function modifier_item_demon_paper:DeclareFunctions()
	return 	
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
end

function modifier_item_demon_paper:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_demon_paper:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack")
end

function modifier_item_demon_paper:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_int")
end

function modifier_item_demon_paper:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
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
	local stacks = self:GetAbility():GetSpecialValueFor("stacks")
	local particle = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_staff_glory/warlock_upheaval_hellborn_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, self:GetParent():GetAbsOrigin())
	self:AddParticle(particle, false, false, -1, false, false)
	self:SetStackCount(stacks)
end

function modifier_item_demon_paper_active:OnRefresh()
	if not IsServer() then return end
	local stacks = self:GetAbility():GetSpecialValueFor("stacks")
	local particle = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_staff_glory/warlock_upheaval_hellborn_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, self:GetParent():GetAbsOrigin())
	self:AddParticle(particle, false, false, -1, false, false)
	self:SetStackCount(stacks)
end

function modifier_item_demon_paper_active:DeclareFunctions()
	return 	
	{
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ALWAYS_ETHEREAL_ATTACK,
	}
end

function modifier_item_demon_paper_active:GetModifierTotalDamageOutgoing_Percentage( params )
	if not IsServer() then return end
	if params.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return 0 end
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

	self:DecrementStackCount()
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end

	return -1000
end

function modifier_item_demon_paper_active:GetAllowEtherealAttack()
    return 1
end