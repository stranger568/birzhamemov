LinkLuaModifier( "modifier_item_gunbai_uchiha", "items/gunbai_uchiha", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_yasha_stacks", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_yasha_proc", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )

item_gunbai_uchiha = class({})

function item_gunbai_uchiha:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():EmitSound("Item.LotusOrb.Target")
	local duration = self:GetSpecialValueFor("active_duration")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_lotus_orb_active", {duration = duration})
end

function item_gunbai_uchiha:GetIntrinsicModifierName() 
    return "modifier_item_gunbai_uchiha"
end

modifier_item_gunbai_uchiha = class({})

function modifier_item_gunbai_uchiha:IsHidden() return true end
function modifier_item_gunbai_uchiha:IsPurgable() return false end
function modifier_item_gunbai_uchiha:IsPurgeException() return false end
function modifier_item_gunbai_uchiha:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_gunbai_uchiha:OnCreated()
    self.attack_record = {}
    self.chance = self:GetAbility():GetSpecialValueFor("proc_chance")
    self.crit_multiplier = self:GetAbility():GetSpecialValueFor("crit_multiplier")
end

function modifier_item_gunbai_uchiha:DeclareFunctions()
	return  
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
    }
end

function modifier_item_gunbai_uchiha:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor('bonus_armor')
	end
end

function modifier_item_gunbai_uchiha:GetModifierConstantHealthRegen()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
	end
end

function modifier_item_gunbai_uchiha:GetModifierConstantManaRegen()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
	end
end

function modifier_item_gunbai_uchiha:GetModifierManaBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_mana")
	end
end

function modifier_item_gunbai_uchiha:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor('bonus_damage')
	end
end

function modifier_item_gunbai_uchiha:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end
end

function modifier_item_gunbai_uchiha:GetModifierBonusStats_Agility()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_agility")
	end
end

function modifier_item_gunbai_uchiha:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_ms")
	end
end

function modifier_item_gunbai_uchiha:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if params.attacker:IsIllusion() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_gunbai_uchiha")[1] ~= self then return end

	local attacker = params.attacker
	local target = params.target

	local no_any_items = true

	local priority_sword_modifiers = 
	{
		"modifier_item_mem_sange_yasha",
		"modifier_item_mem_cheburek_yasha",
		"modifier_item_mem_chebureksword"
	}
	for _, sword_modifier in pairs(priority_sword_modifiers) do
		if self:GetParent():HasModifier(sword_modifier) then
			no_any_items = false
		end
	end

	if no_any_items then
		local modifier_as = attacker:AddNewModifier(attacker, self:GetAbility(), "modifier_item_mem_yasha_stacks", {duration = self:GetAbility():GetSpecialValueFor("stack_duration")})
		if modifier_as and modifier_as:GetStackCount() < self:GetAbility():GetSpecialValueFor("max_stacks") then
			modifier_as:SetStackCount(modifier_as:GetStackCount() + 1)
			attacker:EmitSound("mem.YashaStack")
		end
	end

	if self.attack_record[params.record] ~= nil then
		attacker:AddNewModifier(attacker, self:GetAbility(), "modifier_item_mem_yasha_proc", {duration = self:GetAbility():GetSpecialValueFor("proc_duration_self")})
		attacker:EmitSound("mem.YashaProc")		
	end
end

function modifier_item_gunbai_uchiha:GetModifierPreAttack_CriticalStrike(params)
	if self:GetParent():IsIllusion() then return end
	if RollPercentage(self.chance) then
		self.attack_record[params.record] = true
		return self.crit_multiplier
	end
end