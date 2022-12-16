LinkLuaModifier( "modifier_item_mem_sange", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_sange_maim", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_sange_disarm", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "item_heavens_halberd_custom_sange_cooldown", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "item_manta_custom_yasha_cooldown", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE)

item_heavens_halberd_custom_sange_cooldown = class({})
function item_heavens_halberd_custom_sange_cooldown:IsHidden() return true end
function item_heavens_halberd_custom_sange_cooldown:IsPurgable() return false end
function item_heavens_halberd_custom_sange_cooldown:IsPurgeException() return false end
function item_heavens_halberd_custom_sange_cooldown:RemoveOnDeath() return false end

item_manta_custom_yasha_cooldown = class({})
function item_manta_custom_yasha_cooldown:IsHidden() return true end
function item_manta_custom_yasha_cooldown:IsPurgable() return false end
function item_manta_custom_yasha_cooldown:IsPurgeException() return false end
function item_manta_custom_yasha_cooldown:RemoveOnDeath() return false end

item_mem_sange = class({})

function item_mem_sange:GetIntrinsicModifierName()
	return "modifier_item_mem_sange" 
end

modifier_item_mem_sange = class({})

function modifier_item_mem_sange:IsHidden() return true end
function modifier_item_mem_sange:IsPurgable() return false end
function modifier_item_mem_sange:IsPurgeException() return false end
function modifier_item_mem_sange:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mem_sange:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_item_mem_sange:GetModifierStatusResistanceStacking()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("effect_resistance") 
end

function modifier_item_mem_sange:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_strength") 
end

function modifier_item_mem_sange:GetModifierHPRegenAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("health_regen_increase") 
end

function modifier_item_mem_sange:Custom_AllHealAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("health_regen_increase") 
end

function modifier_item_mem_sange:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_mem_sange")[1] ~= self then return end

	local priority_sword_modifiers = 
	{
		"modifier_item_heavens_halberd_custom",
		"modifier_item_mem_sange_yasha",
		"modifier_item_mem_sange_cheburek",
		"modifier_item_mem_chebureksword"
	}

	for _, sword_modifier in pairs(priority_sword_modifiers) do
		if self:GetParent():HasModifier(sword_modifier) then
			return nil
		end
	end

	SangeAttack(self:GetParent(), params.target, self:GetAbility(), "modifier_item_mem_sange_maim", "modifier_item_mem_sange_disarm")
end

function SangeAttack(attacker, target, ability, modifier_stacks, modifier_proc)
	if attacker:IsIllusion() then
		return 
	end

	if target:IsMagicImmune() then
		return 
	end

	local modifier_maim = target:AddNewModifier(attacker, ability, modifier_stacks, {duration = ability:GetSpecialValueFor("stack_duration") * (1 - target:GetStatusResistance())})

	if modifier_maim and modifier_maim:GetStackCount() < ability:GetSpecialValueFor("max_stacks") then
		modifier_maim:SetStackCount(modifier_maim:GetStackCount() + 1)
		target:EmitSound("mem.SangeStack")
	end

	if ability and ability:GetName() == "item_heavens_halberd_custom" then
		if not attacker:HasModifier("item_heavens_halberd_custom_sange_cooldown") then
			target:AddNewModifier(attacker, ability, modifier_proc, {duration = ability:GetSpecialValueFor("proc_duration_enemy") * (1 - target:GetStatusResistance())})
			attacker:AddNewModifier(attacker, ability, "item_heavens_halberd_custom_sange_cooldown", {duration = 5})
			target:EmitSound("mem.SangeProc")
		end
		return
	end

	if ability:IsCooldownReady() and RollPercentage(ability:GetSpecialValueFor("proc_chance")) then
		target:AddNewModifier(attacker, ability, modifier_proc, {duration = ability:GetSpecialValueFor("proc_duration_enemy") * (1 - target:GetStatusResistance())})
		target:EmitSound("mem.SangeProc")
		ability:UseResources(false, false, true)
	end
end

modifier_item_mem_sange_maim = class({})

function modifier_item_mem_sange_maim:GetTexture()
	return "item_mem_sange"
end

function modifier_item_mem_sange_maim:IsPurgable() return true end

function modifier_item_mem_sange_maim:GetEffectName()
	return "particles/items2_fx/sange_maim.vpcf"
end

function modifier_item_mem_sange_maim:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_mem_sange_maim:OnCreated()
	self.maim_stack = self:GetAbility():GetSpecialValueFor("maim_stack")
end

function modifier_item_mem_sange_maim:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_item_mem_sange_maim:GetModifierAttackSpeedBonus_Constant()
	return self.maim_stack * self:GetStackCount() 
end

function modifier_item_mem_sange_maim:GetModifierMoveSpeedBonus_Percentage()
	return self.maim_stack * self:GetStackCount() 
end

modifier_item_mem_sange_disarm = class({})

function modifier_item_mem_sange_disarm:GetTexture()
	return "item_mem_sange"
end

function modifier_item_mem_sange_disarm:GetEffectName()
	return "particles/items2_fx/heavens_halberd.vpcf"
end

function modifier_item_mem_sange_disarm:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_mem_sange_disarm:CheckState()
	local states = 
	{
		[MODIFIER_STATE_DISARMED] = true,
	}
	return states
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

LinkLuaModifier( "modifier_item_mem_yasha", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_yasha_stacks", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_yasha_proc", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )

item_mem_yasha = class({})

function item_mem_yasha:GetIntrinsicModifierName()
	return "modifier_item_mem_yasha" 
end

modifier_item_mem_yasha = class({})

function modifier_item_mem_yasha:IsHidden() return true end
function modifier_item_mem_yasha:IsPurgable() return false end
function modifier_item_mem_yasha:IsPurgeException() return false end
function modifier_item_mem_yasha:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mem_yasha:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_item_mem_yasha:GetModifierAttackSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") 
end

function modifier_item_mem_yasha:GetModifierMoveSpeedBonus_Percentage_Unique()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_ms") 
end

function modifier_item_mem_yasha:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_agility") 
end

function modifier_item_mem_yasha:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_mem_yasha")[1] ~= self then return end

	local priority_sword_modifiers = 
	{
		"modifier_item_manta_custom_passive",
		"modifier_item_mem_sange_yasha",
		"modifier_item_mem_cheburek_yasha",
		"modifier_item_mem_chebureksword"
	}

	for _, sword_modifier in pairs(priority_sword_modifiers) do
		if self:GetParent():HasModifier(sword_modifier) then
			return nil
		end
	end

	YashaAttack(self:GetParent(), self:GetAbility(), "modifier_item_mem_yasha_stacks", "modifier_item_mem_yasha_proc")
end

function YashaAttack(attacker, ability, modifier_stacks, modifier_proc)
	local modifier_as = attacker:AddNewModifier(attacker, ability, modifier_stacks, {duration = ability:GetSpecialValueFor("stack_duration")})

	if modifier_as and modifier_as:GetStackCount() < ability:GetSpecialValueFor("max_stacks") then
		modifier_as:SetStackCount(modifier_as:GetStackCount() + 1)
		attacker:EmitSound("mem.YashaStack")
	end

	if attacker:IsIllusion() then
		return 
	end

	if ability and ability:GetName() == "item_manta_custom" then
		if not attacker:HasModifier("item_manta_custom_yasha_cooldown") then
			attacker:AddNewModifier(attacker, ability, modifier_proc, {duration = ability:GetSpecialValueFor("proc_duration_self")})
			attacker:EmitSound("mem.YashaProc")
			attacker:AddNewModifier(attacker, ability, "item_manta_custom_yasha_cooldown", {duration = 5})
		end
		return
	end

	if ability and ability:GetName() == "item_lostvane_custom" then
		if not attacker:HasModifier("item_manta_custom_yasha_cooldown") then
			attacker:AddNewModifier(attacker, ability, modifier_proc, {duration = ability:GetSpecialValueFor("proc_duration_self")})
			attacker:EmitSound("mem.YashaProc")
			attacker:AddNewModifier(attacker, ability, "item_manta_custom_yasha_cooldown", {duration = 5})
		end
		return
	end

	if ability:IsCooldownReady() and RollPercentage(ability:GetSpecialValueFor("proc_chance")) then
		attacker:AddNewModifier(attacker, ability, modifier_proc, {duration = ability:GetSpecialValueFor("proc_duration_self")})
		attacker:EmitSound("mem.YashaProc")
		ability:UseResources(false, false, true)
	end
end

modifier_item_mem_yasha_stacks = class({})

function modifier_item_mem_yasha_stacks:GetTexture()
	return "item_mem_yasha"
end

function modifier_item_mem_yasha_stacks:GetEffectName()
	return "particles/item/swords/yasha_buff.vpcf"
end

function modifier_item_mem_yasha_stacks:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_mem_yasha_stacks:OnCreated()
	self.as_stack = self:GetAbility():GetSpecialValueFor("as_stack")
end

function modifier_item_mem_yasha_stacks:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_item_mem_yasha_stacks:GetModifierAttackSpeedBonus_Constant()
	return self.as_stack * self:GetStackCount() 
end

modifier_item_mem_yasha_proc = class({})

function modifier_item_mem_yasha_proc:GetTexture()
	return "item_mem_yasha"
end

function modifier_item_mem_yasha_proc:GetEffectName()
	return "particles/item/swords/yasha_proc.vpcf"
end

function modifier_item_mem_yasha_proc:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_mem_yasha_proc:OnCreated()
	self.proc_ms = self:GetAbility():GetSpecialValueFor("proc_ms")
end

function modifier_item_mem_yasha_proc:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_item_mem_yasha_proc:GetModifierMoveSpeedBonus_Percentage()
	return self.proc_ms 
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

LinkLuaModifier( "modifier_item_mem_cheburek", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_cheburek_amp", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_cheburek_silence", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )

item_mem_cheburek = class({})

function item_mem_cheburek:GetIntrinsicModifierName()
	return "modifier_item_mem_cheburek" 
end

modifier_item_mem_cheburek = class({})

function modifier_item_mem_cheburek:IsHidden() return true end
function modifier_item_mem_cheburek:IsPurgable() return false end
function modifier_item_mem_cheburek:IsPurgeException() return false end
function modifier_item_mem_cheburek:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mem_cheburek:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_item_mem_cheburek:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_int") 
end

function modifier_item_mem_cheburek:GetModifierSpellAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("spell_amplify") 
end

function modifier_item_mem_cheburek:GetModifierMPRegenAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("mana_regen_increase")
end

function modifier_item_mem_cheburek:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_mem_cheburek")[1] ~= self then return end

	local priority_sword_modifiers = {
		"modifier_item_mem_sange_cheburek",
		"modifier_item_mem_cheburek_yasha",
		"modifier_item_mem_chebureksword"
	}
	for _, sword_modifier in pairs(priority_sword_modifiers) do
		if self:GetParent():HasModifier(sword_modifier) then
			return nil
		end
	end

	CheburekAttack(self:GetParent(), params.target, self:GetAbility(), "modifier_item_mem_cheburek_amp", "modifier_item_mem_cheburek_silence")
end

function CheburekAttack(attacker, target, ability, modifier_stacks, modifier_proc)
	if attacker:IsIllusion() then
		return 
	end

	if target:IsMagicImmune() then
		return 
	end

	local modifier_amp = target:AddNewModifier(attacker, ability, modifier_stacks, {duration = ability:GetSpecialValueFor("stack_duration") * (1 - target:GetStatusResistance())})

	if modifier_amp and modifier_amp:GetStackCount() < ability:GetSpecialValueFor("max_stacks") then
		modifier_amp:SetStackCount(modifier_amp:GetStackCount() + 1)
		target:EmitSound("mem.cheburekStack")
	end

	if ability:IsCooldownReady() and RollPercentage(ability:GetSpecialValueFor("proc_chance")) then
		target:AddNewModifier(attacker, ability, modifier_proc, {duration = ability:GetSpecialValueFor("proc_duration_enemy") * (1 - target:GetStatusResistance())})
		target:EmitSound("mem.cheburekProc")
		ability:UseResources(false, false, true)
	end
end

modifier_item_mem_cheburek_amp = class({})

function modifier_item_mem_cheburek_amp:GetTexture()
	return "item_mem_cheburek"
end

function modifier_item_mem_cheburek_amp:GetEffectName()
	return "particles/item/swords/azura_debuff.vpcf"
end

function modifier_item_mem_cheburek_amp:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_mem_cheburek_amp:OnCreated()
	self.magical_resistance = self:GetAbility():GetSpecialValueFor("amp_stack")
end

function modifier_item_mem_cheburek_amp:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
	return funcs
end

function modifier_item_mem_cheburek_amp:GetModifierMagicalResistanceBonus()
	return self.magical_resistance * self:GetStackCount() 
end

modifier_item_mem_cheburek_silence = class({})

function modifier_item_mem_cheburek_silence:GetTexture()
	return "item_mem_cheburek"
end

function modifier_item_mem_cheburek_silence:GetEffectName()
	return "particles/item/swords/azura_proc.vpcf"
end

function modifier_item_mem_cheburek_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_mem_cheburek_silence:CheckState()
	local states = 
	{
		[MODIFIER_STATE_SILENCED] = true,
	}
	return states
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

LinkLuaModifier( "modifier_item_mem_sange_yasha", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )

item_mem_sange_yasha = class({})

function item_mem_sange_yasha:GetIntrinsicModifierName()
	return "modifier_item_mem_sange_yasha" 
end

modifier_item_mem_sange_yasha = class({})

function modifier_item_mem_sange_yasha:IsHidden() return true end
function modifier_item_mem_sange_yasha:IsPurgable() return false end
function modifier_item_mem_sange_yasha:IsPurgeException() return false end
function modifier_item_mem_sange_yasha:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mem_sange_yasha:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_item_mem_sange_yasha:GetModifierStatusResistanceStacking()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("effect_resistance") 
end

function modifier_item_mem_sange_yasha:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_strength") 
end

function modifier_item_mem_sange_yasha:GetModifierHPRegenAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("health_regen_increase") 
end

function modifier_item_mem_sange_yasha:Custom_AllHealAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("health_regen_increase") 
end

function modifier_item_mem_sange_yasha:GetModifierAttackSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") 
end

function modifier_item_mem_sange_yasha:GetModifierMoveSpeedBonus_Percentage_Unique()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_ms") 
end

function modifier_item_mem_sange_yasha:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_agility") 
end

function modifier_item_mem_sange_yasha:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_mem_sange_yasha")[1] ~= self then return end

	local priority_sword_modifiers = 
	{
		"modifier_item_mem_chebureksword"
	}

	for _, sword_modifier in pairs(priority_sword_modifiers) do
		if self:GetParent():HasModifier(sword_modifier) then
			return nil
		end
	end

	SangeAttack(self:GetParent(), params.target, self:GetAbility(), "modifier_item_mem_sange_maim", "modifier_item_mem_sange_disarm")
	YashaAttack(self:GetParent(), self:GetAbility(), "modifier_item_mem_yasha_stacks", "modifier_item_mem_yasha_proc")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

LinkLuaModifier( "modifier_item_mem_chebureksword", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )

item_mem_chebureksword = class({})

function item_mem_chebureksword:GetIntrinsicModifierName()
	return "modifier_item_mem_chebureksword" 
end

modifier_item_mem_chebureksword = class({})

function modifier_item_mem_chebureksword:IsHidden() return true end
function modifier_item_mem_chebureksword:IsPurgable() return false end
function modifier_item_mem_chebureksword:IsPurgeException() return false end
function modifier_item_mem_chebureksword:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mem_chebureksword:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_item_mem_chebureksword:GetModifierStatusResistanceStacking()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("effect_resistance") 
end

function modifier_item_mem_chebureksword:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_strength") 
end

function modifier_item_mem_chebureksword:GetModifierHPRegenAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("health_regen_increase") 
end

function modifier_item_mem_chebureksword:Custom_AllHealAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("health_regen_increase") 
end

function modifier_item_mem_chebureksword:GetModifierAttackSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") 
end

function modifier_item_mem_chebureksword:GetModifierMoveSpeedBonus_Percentage_Unique()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_ms") 
end

function modifier_item_mem_chebureksword:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_agility") 
end

function modifier_item_mem_chebureksword:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_int") 
end

function modifier_item_mem_chebureksword:GetModifierSpellAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("spell_amplify") 
end

function modifier_item_mem_chebureksword:GetModifierMPRegenAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("mana_regen_increase")
end

function modifier_item_mem_chebureksword:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_mem_chebureksword")[1] ~= self then return end

	SangeAttack(self:GetParent(), params.target, self:GetAbility(), "modifier_item_mem_sange_maim", "modifier_item_mem_sange_disarm")
	YashaAttack(self:GetParent(), self:GetAbility(), "modifier_item_mem_yasha_stacks", "modifier_item_mem_yasha_proc")
	CheburekAttack(self:GetParent(), params.target, self:GetAbility(), "modifier_item_mem_cheburek_amp", "modifier_item_mem_cheburek_silence")
end

LinkLuaModifier( "modifier_item_heavens_halberd_custom", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_heavens_halberd_custom_active", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )

item_heavens_halberd_custom = class({})

function item_heavens_halberd_custom:GetIntrinsicModifierName()
	return "modifier_item_heavens_halberd_custom"
end

function item_heavens_halberd_custom:OnSpellStart(keys)
	if not IsServer() then return end
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb(self) then return end

	local duration = self:GetSpecialValueFor("disarm_melee")

	if target:IsRangedAttacker() then
		duration = self:GetSpecialValueFor("disarm_range")
	end

	target:AddNewModifier(self:GetCaster(), self, "modifier_item_heavens_halberd_custom_active", {duration = duration})

	target:EmitSound("DOTA_Item.HeavensHalberd.Activate")
end

modifier_item_heavens_halberd_custom = class({})

function modifier_item_heavens_halberd_custom:IsHidden() return true end
function modifier_item_heavens_halberd_custom:IsPurgable() return false end
function modifier_item_heavens_halberd_custom:IsPurgeException() return false end
function modifier_item_heavens_halberd_custom:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_heavens_halberd_custom:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_item_heavens_halberd_custom:GetModifierStatusResistanceStacking()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("effect_resistance") 
end

function modifier_item_heavens_halberd_custom:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_strength") 
end

function modifier_item_heavens_halberd_custom:GetModifierHPRegenAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("health_regen_increase") 
end

function modifier_item_heavens_halberd_custom:Custom_AllHealAmplify_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("health_regen_increase") 
end

function modifier_item_heavens_halberd_custom:GetModifierEvasion_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_evasion") 
end

function modifier_item_heavens_halberd_custom:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_heavens_halberd_custom")[1] ~= self then return end

	local priority_sword_modifiers = 
	{
		"modifier_item_mem_sange_yasha",
		"modifier_item_mem_sange_cheburek",
		"modifier_item_mem_chebureksword"
	}

	for _, sword_modifier in pairs(priority_sword_modifiers) do
		if self:GetParent():HasModifier(sword_modifier) then
			return nil
		end
	end

	SangeAttack(self:GetParent(), params.target, self:GetAbility(), "modifier_item_mem_sange_maim", "modifier_item_mem_sange_disarm")
end

modifier_item_heavens_halberd_custom_active = class({})

function modifier_item_heavens_halberd_custom_active:IsPurgable() return false end

function modifier_item_heavens_halberd_custom_active:GetEffectName()
	return "particles/items2_fx/heavens_halberd.vpcf"
end

function modifier_item_heavens_halberd_custom_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_heavens_halberd_custom_active:CheckState()
	local states = 
	{
		[MODIFIER_STATE_DISARMED] = true,
	}
	return states
end






LinkLuaModifier("modifier_item_manta_custom_invulnerable", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_manta_custom_passive", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE)

item_manta_custom = class({})

function item_manta_custom:GetIntrinsicModifierName() 
	return "modifier_item_manta_custom_passive"
end

function item_manta_custom:OnSpellStart()
	if not IsServer() then return end
    self:GetCaster():EmitSound("DOTA_Item.Manta.Activate")
    self:GetCaster():Purge(false, true, false, false, false)
    if not self:GetCaster():IsRealHero() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_manta_custom_invulnerable", {duration = self:GetSpecialValueFor("invuln_duration")})
    ProjectileManager:ProjectileDodge(self:GetCaster())
end

modifier_item_manta_custom_passive = class({})

function modifier_item_manta_custom_passive:IsHidden() return true end
function modifier_item_manta_custom_passive:IsPurgable() return false end
function modifier_item_manta_custom_passive:IsPurgeException() return false end
function modifier_item_manta_custom_passive:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_manta_custom_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_item_manta_custom_passive:GetModifierAttackSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") 
end

function modifier_item_manta_custom_passive:GetModifierMoveSpeedBonus_Percentage_Unique()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_ms") 
end

function modifier_item_manta_custom_passive:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_agility") 
end

function modifier_item_manta_custom_passive:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_intellect") 
end

function modifier_item_manta_custom_passive:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_strength") 
end

function modifier_item_manta_custom_passive:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_manta_custom_passive")[1] ~= self then return end

	local priority_sword_modifiers = 
	{
		"modifier_item_lostvane_custom_custom_passive",
		"modifier_item_mem_sange_yasha",
		"modifier_item_mem_cheburek_yasha",
		"modifier_item_mem_chebureksword"
	}

	for _, sword_modifier in pairs(priority_sword_modifiers) do
		if self:GetParent():HasModifier(sword_modifier) then
			return nil
		end
	end

	YashaAttack(self:GetParent(), self:GetAbility(), "modifier_item_mem_yasha_stacks", "modifier_item_mem_yasha_proc")
end

modifier_item_manta_custom_invulnerable = class({})

function modifier_item_manta_custom_invulnerable:IsHidden()     return true end
function modifier_item_manta_custom_invulnerable:IsPurgable()   return false end

function modifier_item_manta_custom_invulnerable:GetEffectName()
    return "particles/items2_fx/manta_phase.vpcf"
end

function modifier_item_manta_custom_invulnerable:OnDestroy()
    if not IsServer() then return end
    if not self:GetParent():IsAlive() then return end
    if not self:GetAbility() then return end

    if self:GetParent() == self:GetCaster() then
        self:GetParent():Stop()
    end

    local all_illusions = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED  , FIND_ANY_ORDER, false) 

    for _,i in ipairs(all_illusions) do
        if i.manta and i.manta == true then 
            i:ForceKill(false)
        end
    end

	if self:GetCaster().lostvane_illusions ~= nil and self:GetCaster().lostvane_illusions[1] then
		self:GetCaster().lostvane_illusions[1]:ForceKill(false)
	end

	if self:GetCaster().lostvane_illusions ~= nil and self:GetCaster().lostvane_illusions[2] then
		self:GetCaster().lostvane_illusions[2]:ForceKill(false)
	end

    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("vision_radius"), 1, false)

    local damage = self:GetAbility():GetSpecialValueFor("images_do_damage_percent_melee")

    if self:GetParent():IsRangedAttacker() then     
        damage = self:GetAbility():GetSpecialValueFor("images_do_damage_percent_ranged")
    end

    local illusions = BirzhaCreateIllusion(self:GetCaster(), self:GetCaster(), {
        outgoing_damage = damage,
        incoming_damage = self:GetAbility():GetSpecialValueFor("images_take_damage_percent"),
        bounty_base     = self:GetCaster():GetLevel()*2, 
        bounty_growth   = nil,
        outgoing_damage_structure   = nil,
        outgoing_damage_roshan      = nil,
        duration        = self:GetAbility():GetSpecialValueFor("tooltip_illusion_duration")
    }, 
    self:GetAbility():GetSpecialValueFor("images_count"), 108, true, true)

    for _, illusion in pairs(illusions) do
    	illusion.manta = true
    	illusion:RemoveGesture(ACT_DOTA_SPAWN)
    end
end

function modifier_item_manta_custom_invulnerable:CheckState()
    return 
    {
        [MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]      = true,
        [MODIFIER_STATE_STUNNED]            = true,
        [MODIFIER_STATE_OUT_OF_GAME]        = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true
    }
end

LinkLuaModifier("modifier_item_lostvane_custom_custom_invulnerable", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_lostvane_custom_custom_passive", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_lostvane_custom_custom_flaso", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_lostvane_custom_custom_passive_aura", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE)

item_lostvane_custom = class({})

function item_lostvane_custom:GetIntrinsicModifierName() 
	return "modifier_item_lostvane_custom_custom_passive"
end

function item_lostvane_custom:OnSpellStart()
	if not IsServer() then return end
    self:GetCaster():EmitSound("lostvane_item")
    self:GetCaster():Purge(false, true, false, false, false)
    if not self:GetCaster():IsRealHero() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_lostvane_custom_custom_invulnerable", {duration = self:GetSpecialValueFor("invuln_duration")})
    ProjectileManager:ProjectileDodge(self:GetCaster())
end

modifier_item_lostvane_custom_custom_passive = class({})

function modifier_item_lostvane_custom_custom_passive:IsHidden() return true end
function modifier_item_lostvane_custom_custom_passive:IsPurgable() return false end
function modifier_item_lostvane_custom_custom_passive:IsPurgeException() return false end
function modifier_item_lostvane_custom_custom_passive:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_lostvane_custom_custom_passive:OnCreated()
	if not IsServer() then return end
	if self:GetCaster().lostvane_illusions == nil then
		self:GetCaster().lostvane_illusions = {}
	end
	self:StartIntervalThink(FrameTime())
end

function modifier_item_lostvane_custom_custom_passive:OnIntervalThink()
	if not IsServer() then return end
	for i = #self:GetCaster().lostvane_illusions, 1, -1 do
        if self:GetCaster().lostvane_illusions[i] ~= nil then
            if self:GetCaster().lostvane_illusions[i] and ( self:GetCaster().lostvane_illusions[i]:IsNull() or not self:GetCaster().lostvane_illusions[i]:IsAlive() ) then
                table.remove(self:GetCaster().lostvane_illusions, i)
            end
        end
    end
end

function modifier_item_lostvane_custom_custom_passive:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS_UNIQUE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_item_lostvane_custom_custom_passive:GetModifierAttackSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") 
end

function modifier_item_lostvane_custom_custom_passive:GetModifierMoveSpeedBonus_Percentage_Unique()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_ms") 
end

function modifier_item_lostvane_custom_custom_passive:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_agility") 
end

function modifier_item_lostvane_custom_custom_passive:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_intellect") 
end

function modifier_item_lostvane_custom_custom_passive:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_strength") 
end
 
function modifier_item_lostvane_custom_custom_passive:GetModifierAttackRangeBonusUnique()
    if not self:GetParent():IsRangedAttacker() then 
    	return self:GetAbility():GetSpecialValueFor("bonus_ranged_range")
    end
    return self:GetAbility():GetSpecialValueFor("bonus_melee_range")
end

function modifier_item_lostvane_custom_custom_passive:IsAura()
    return true
end

function modifier_item_lostvane_custom_custom_passive:GetModifierAura()
    return "modifier_item_lostvane_custom_custom_passive_aura"
end


function modifier_item_lostvane_custom_custom_passive:GetAuraRadius()
    return -1
end

function modifier_item_lostvane_custom_custom_passive:GetAuraDuration()
    return 1
end

function modifier_item_lostvane_custom_custom_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_lostvane_custom_custom_passive:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_lostvane_custom_custom_passive:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_item_lostvane_custom_custom_passive:GetAuraEntityReject(target)
	if target:IsIllusion() and not target:HasModifier("modifier_item_lostvane_custom_custom_flaso") then
		return false
	else
		return true
	end
end

modifier_item_lostvane_custom_custom_passive_aura = class({})

function modifier_item_lostvane_custom_custom_passive_aura:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_item_lostvane_custom_custom_passive_aura:GetModifierDamageOutgoing_Percentage()
	if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("illusion_damage_pasisve")
end

function modifier_item_lostvane_custom_custom_passive:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_lostvane_custom_custom_passive")[1] ~= self then return end

	local priority_sword_modifiers = 
	{
		"modifier_item_mem_sange_yasha",
		"modifier_item_mem_cheburek_yasha",
		"modifier_item_mem_chebureksword"
	}

	for _, sword_modifier in pairs(priority_sword_modifiers) do
		if self:GetParent():HasModifier(sword_modifier) then
			return nil
		end
	end

	YashaAttack(self:GetParent(), self:GetAbility(), "modifier_item_mem_yasha_stacks", "modifier_item_mem_yasha_proc")
end

modifier_item_lostvane_custom_custom_invulnerable = class({})

function modifier_item_lostvane_custom_custom_invulnerable:IsHidden()     return true end
function modifier_item_lostvane_custom_custom_invulnerable:IsPurgable()   return false end

function modifier_item_lostvane_custom_custom_invulnerable:GetEffectName()
    return "particles/items2_fx/manta_phase.vpcf"
end

function modifier_item_lostvane_custom_custom_invulnerable:OnDestroy()
    if not IsServer() then return end
    if not self:GetParent():IsAlive() then return end
    if not self:GetAbility() then return end

    if self:GetParent() == self:GetCaster() then
        self:GetParent():Stop()
    end

    local all_illusions = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED  , FIND_ANY_ORDER, false) 

    for _,i in ipairs(all_illusions) do
        if i.manta and i.manta == true then 
            i:ForceKill(false)
        end
    end

    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("vision_radius"), 1, false)

    local damage = self:GetAbility():GetSpecialValueFor("images_do_damage_percent_melee")

    if self:GetParent():IsRangedAttacker() then     
        damage = self:GetAbility():GetSpecialValueFor("images_do_damage_percent_ranged")
    end

    local illusion_duration = self:GetAbility():GetSpecialValueFor("illusion_duration")
	local illusion_out_damage_one = self:GetAbility():GetSpecialValueFor("illusion_out_damage_one") - 100
	local illusion_in_damage_one = self:GetAbility():GetSpecialValueFor("illusion_in_damage_one") - 100
	local illusion_out_damage_two = self:GetAbility():GetSpecialValueFor("illusion_out_damage_two") - 100
	local illusion_in_damage_two = self:GetAbility():GetSpecialValueFor("illusion_in_damage_two") - 100

	if #self:GetCaster().lostvane_illusions >= 4 then
		if self:GetCaster().lostvane_illusions[1] then
			self:GetCaster().lostvane_illusions[1]:ForceKill(false)
		end
		if self:GetCaster().lostvane_illusions[2] then
			self:GetCaster().lostvane_illusions[2]:ForceKill(false)
		end
	end

	local caster = self:GetCaster()
	local ability = self:GetAbility()

	Timers:CreateTimer(0, function()
		if #caster.lostvane_illusions == 3 then
			ability:CreateIllusion(1, illusion_out_damage_two, illusion_in_damage_two)
		elseif #caster.lostvane_illusions == 2 then
			ability:CreateIllusion(2, illusion_out_damage_two, illusion_in_damage_two)
		elseif #caster.lostvane_illusions == 1 then
			ability:CreateIllusion(1, illusion_in_damage_one, illusion_out_damage_one)
			ability:CreateIllusion(1, illusion_out_damage_two, illusion_in_damage_two)
		elseif #caster.lostvane_illusions == 0 then
			ability:CreateIllusion(2, illusion_out_damage_one, illusion_in_damage_one)
		end
	end)
end

function item_lostvane_custom:CreateIllusion(count, damage, inc_damage)
    for i=1, count do
	    local illusions = BirzhaCreateIllusion(self:GetCaster(), self:GetCaster(), {
	        outgoing_damage = damage,
	        incoming_damage = inc_damage,
	        bounty_base     = self:GetCaster():GetLevel()*2, 
	        bounty_growth   = nil,
	        outgoing_damage_structure   = nil,
	        outgoing_damage_roshan      = nil,
	        duration        = self:GetSpecialValueFor("illusion_duration")
	    }, 1, 108, true, true)

	    for _, illusion in pairs(illusions) do
	    	illusion:AddNewModifier(self:GetCaster(), self, "modifier_item_lostvane_custom_custom_flaso", {})
	    	illusion.lostvane = true
	    	illusion:RemoveGesture(ACT_DOTA_SPAWN)
	    	table.insert(self:GetCaster().lostvane_illusions, illusion)
	    end
    end
end

function modifier_item_lostvane_custom_custom_invulnerable:CheckState()
    return 
    {
        [MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]      = true,
        [MODIFIER_STATE_STUNNED]            = true,
        [MODIFIER_STATE_OUT_OF_GAME]        = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true
    }
end


modifier_item_lostvane_custom_custom_flaso = class({})
function modifier_item_lostvane_custom_custom_flaso:IsPurgable() return false end
function modifier_item_lostvane_custom_custom_flaso:IsHidden() return true end





































































































































































































