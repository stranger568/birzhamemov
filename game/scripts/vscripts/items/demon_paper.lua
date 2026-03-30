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

function modifier_item_demon_paper:DeclareFunctions()
	return 	
	{
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE,
		MODIFIER_PROPERTY_ALWAYS_ETHEREAL_ATTACK,
	}
end

function modifier_item_demon_paper:GetModifierProcAttack_BonusDamage_Pure( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_demon_paper")[1] ~= self then return end
	local proc_chance = self:GetAbility():GetSpecialValueFor("proc_chance")
	local pure_dmg = self:GetAbility():GetSpecialValueFor("pure_dmg")
	if self:GetParent():HasModifier("modifier_item_demon_paper_active") then 
		proc_chance = self:GetAbility():GetSpecialValueFor("active_proc_chance")
	end
	if self:GetParent():HasModifier("modifier_item_demon_paper_active") then 
		pure_dmg = self:GetAbility():GetSpecialValueFor("pure_dmg") + self:GetAbility():GetSpecialValueFor("active_pure_dmg")
	end
	if RollPercentage(proc_chance) then
		params.target:EmitSound("DOTA_Item.HotD.Activate")
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_PURE_DAMAGE , params.target, params.original_damage + (params.original_damage / 100 * pure_dmg), nil)
		return pure_dmg
	end
	return 0
end

function modifier_item_demon_paper:GetAllowEtherealAttack()
    return 1
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

function modifier_item_demon_paper_active:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_item_demon_paper_active:OnAttackLanded(params)
	if not IsServer() then return end 
	if params.attacker ~= self:GetParent() then return end 
	if params.target == self:GetParent() then return end
	local parent_hp = self:GetParent():GetMaxHealth()
	local hp_loss = parent_hp * (self:GetAbility():GetSpecialValueFor("hp_loss") / 100)
	if self:GetParent():GetHealth() > hp_loss then
		self:GetParent():SetHealth(self:GetParent():GetHealth() - hp_loss)
	else
		self:GetParent():SetHealth(1)
	end
end