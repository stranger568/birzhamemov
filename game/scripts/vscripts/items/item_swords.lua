LinkLuaModifier("modifier_item_mem_sange", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE)

item_mem_sange = class({})

function item_mem_sange:GetIntrinsicModifierName() 
	return "modifier_item_mem_sange" 
end

modifier_item_mem_sange = class({})
function modifier_item_mem_sange:IsHidden() return true end
function modifier_item_mem_sange:IsPurgable() return false end
function modifier_item_mem_sange:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mem_sange:OnCreated()
	if not IsServer() then return end
	if not self:GetAbility() or self:GetAbility():IsNull() then return end
	self.ability = self:GetAbility()
	self.mod = self:GetParent():AddNewModifier(self:GetParent(), self.ability, "modifier_item_sange", {})
end

function modifier_item_mem_sange:OnDestroy()
	if not IsServer() then return end
	if not self.mod or self.mod:IsNull() then return end
	self.mod:Destroy()
end

function modifier_item_mem_sange:DeclareFunctions()
	return	{
	   		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
   			MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	  		}
end

function modifier_item_mem_sange:GetModifierBonusStats_Strength() 
	return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_mem_sange:GetModifierHPRegenAmplify_Percentage()
	if self:GetParent():HasModifier("modifier_item_mem_sange_yasha") then return end
	if self:GetParent():HasModifier("modifier_item_mem_kaya_sange") then return end
	return self:GetAbility():GetSpecialValueFor("heal_amp")
end

function modifier_item_mem_sange:Custom_AllHealAmplify_Percentage()
	if self:GetParent():HasModifier("modifier_item_mem_sange_yasha") then return end
	if self:GetParent():HasModifier("modifier_item_mem_kaya_sange") then return end 
	return self:GetAbility():GetSpecialValueFor("heal_amp")
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_item_mem_yasha", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )

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
	}
	return funcs
end

function modifier_item_mem_yasha:GetModifierAttackSpeedBonus_Constant() 
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") 
end

function modifier_item_mem_yasha:GetModifierMoveSpeedBonus_Percentage_Unique()
	if self:GetParent():HasModifier("modifier_item_mem_sange_yasha") then return end
	if self:GetParent():HasModifier("modifier_item_mem_yasha_kaya") then return end
	return self:GetAbility():GetSpecialValueFor("bonus_ms") 
end

function modifier_item_mem_yasha:GetModifierBonusStats_Agility() 
	return self:GetAbility():GetSpecialValueFor("bonus_agility") 
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_item_mem_kaya", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )

item_mem_kaya = class({})

function item_mem_kaya:GetIntrinsicModifierName()
	return "modifier_item_mem_kaya" 
end

modifier_item_mem_kaya = class({})

function modifier_item_mem_kaya:IsHidden() return true end
function modifier_item_mem_kaya:IsPurgable() return false end
function modifier_item_mem_kaya:IsPurgeException() return false end
function modifier_item_mem_kaya:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mem_kaya:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
	}
	return funcs
end

function modifier_item_mem_kaya:GetModifierBonusStats_Intellect() 
	return self:GetAbility():GetSpecialValueFor("bonus_int") 
end

function modifier_item_mem_kaya:GetModifierSpellAmplify_Percentage()
	if self:GetParent():HasModifier("modifier_item_mem_kaya_sange") then return end
	if self:GetParent():HasModifier("modifier_item_mem_yasha_kaya") then return end
	return self:GetAbility():GetSpecialValueFor("spell_amplify") 
end

function modifier_item_mem_kaya:GetModifierMPRegenAmplify_Percentage()
	if self:GetParent():HasModifier("modifier_item_mem_kaya_sange") then return end
	if self:GetParent():HasModifier("modifier_item_mem_yasha_kaya") then return end
	return self:GetAbility():GetSpecialValueFor("mana_regen_increase")
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_item_mem_sange_yasha", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_sange_yasha_stacks", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_sange_yasha_damage", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )

item_mem_sange_yasha = class({})

function item_mem_sange_yasha:GetIntrinsicModifierName() 
	return "modifier_item_mem_sange_yasha" 
end

modifier_item_mem_sange_yasha = class({})
function modifier_item_mem_sange_yasha:IsHidden() return true end
function modifier_item_mem_sange_yasha:IsPurgable() return false end

function modifier_item_mem_sange_yasha:OnCreated()
	if not IsServer() then return end
	if not self:GetAbility() or self:GetAbility():IsNull() then return end
	self.mod = self:GetParent():AddNewModifier(self:GetCaster(), self.ability, "modifier_item_sange", {})
end

function modifier_item_mem_sange_yasha:OnDestroy()
	if not IsServer() then return end
	if not self.mod or self.mod:IsNull() then return end
	self.mod:Destroy()
end

function modifier_item_mem_sange_yasha:DeclareFunctions()
	return
{
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
    MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	MODIFIER_EVENT_ON_ATTACK_LANDED,
}
end

function modifier_item_mem_sange_yasha:GetModifierBonusStats_Strength() 
	return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_mem_sange_yasha:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agi")
end

function modifier_item_mem_sange_yasha:GetModifierStatusResistanceStacking() 
	return self:GetAbility():GetSpecialValueFor("status_bonus")
end

function modifier_item_mem_sange_yasha:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_item_mem_sange_yasha:GetModifierMoveSpeedBonus_Percentage() 
	if self:GetParent():HasModifier("modifier_item_mem_yasha_kaya") then return end
	return self:GetAbility():GetSpecialValueFor("move_bonus")
end

function modifier_item_mem_sange_yasha:GetModifierHPRegenAmplify_Percentage() 
	if self:GetParent():HasModifier("modifier_item_abyssal_blade") then return end
	if self:GetParent():HasModifier("modifier_item_mem_kaya_sange") then return end
	return self:GetAbility():GetSpecialValueFor("heal_amp")
end

function modifier_item_mem_sange_yasha:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_mem_sange_yasha")[1] ~= self then return end
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_mem_sange_yasha_stacks", {duration = self:GetAbility():GetSpecialValueFor("stacks_duration")})
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_mem_sange_yasha_damage", {duration = self:GetAbility():GetSpecialValueFor("stacks_duration")})
end

modifier_item_mem_sange_yasha_damage = class({})
function modifier_item_mem_sange_yasha_damage:IsPurgable() return true end

function modifier_item_mem_sange_yasha_damage:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_item_mem_sange_yasha_damage:OnIntervalThink()
    if not IsServer() then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_item_mem_sange_yasha_stacks")
	if #modifier >= self:GetAbility():GetSpecialValueFor("max_stacks") then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("max_stacks"))
	else
    	self:SetStackCount(#modifier)
	end
	if not self:GetParent():HasModifier("modifier_item_mem_sange_yasha") then 
		self:Destroy()
	end
end

function modifier_item_mem_sange_yasha_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end

function modifier_item_mem_sange_yasha_damage:GetModifierDamageOutgoing_Percentage() 
	return self:GetAbility():GetSpecialValueFor("stacks_bonus_dmg") * self:GetStackCount()
end

function modifier_item_mem_sange_yasha_damage:GetEffectName() return "particles/item/swords/yasha_buff.vpcf" end
function modifier_item_mem_sange_yasha_damage:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

modifier_item_mem_sange_yasha_stacks = class({})
function modifier_item_mem_sange_yasha_stacks:IsHidden() return true end
function modifier_item_mem_sange_yasha_stacks:IsPurgable() return true end
function modifier_item_mem_sange_yasha_stacks:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_item_mem_kaya_sange", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_kaya_sange_stacks", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_kaya_sange_damage", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )

item_mem_kaya_sange = class({})

function item_mem_kaya_sange:GetIntrinsicModifierName() 
	return "modifier_item_mem_kaya_sange" 
end

modifier_item_mem_kaya_sange = class({})
function modifier_item_mem_kaya_sange:IsHidden() return true end
function modifier_item_mem_kaya_sange:IsPurgable() return false end

function modifier_item_mem_kaya_sange:OnCreated()
	if not IsServer() then return end
	if not self:GetAbility() or self:GetAbility():IsNull() then return end
	self.damage_incom = 0
	self.mod = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_sange", {})
end

function modifier_item_mem_kaya_sange:OnDestroy()
	if not IsServer() then return end
	if not self.mod or self.mod:IsNull() then return end
	self.mod:Destroy()
end

function modifier_item_mem_kaya_sange:DeclareFunctions()
	return {
	    	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
    		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
			MODIFIER_EVENT_ON_TAKEDAMAGE, 
			}
end

function modifier_item_mem_kaya_sange:GetModifierBonusStats_Strength() 
	return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_mem_kaya_sange:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_int")
end

function modifier_item_mem_kaya_sange:GetModifierPercentageManacostStacking()
	return self:GetAbility():GetSpecialValueFor("mana_reduce_amp")
end

function modifier_item_mem_kaya_sange:GetModifierSpellAmplify_Percentage()
	if self:GetParent():HasModifier("modifier_item_mem_yasha_kaya") then return end 
	return self:GetAbility():GetSpecialValueFor("spell_damage")
end

function modifier_item_mem_kaya_sange:GetModifierMPRegenAmplify_Percentage()
	if self:GetParent():HasModifier("modifier_item_mem_yasha_kaya") then return end 	
	return self:GetAbility():GetSpecialValueFor("regen_amp")
end

function modifier_item_mem_kaya_sange:GetModifierHPRegenAmplify_Percentage()
	if self:GetParent():HasModifier("modifier_item_abyssal_blade") then return end
	return self:GetAbility():GetSpecialValueFor("heal_amp")
end

function modifier_item_mem_kaya_sange:OnTakeDamage(params)
	if not IsServer() then return end
	if params.unit ~= self:GetParent() then return end
    if self:GetParent():IsIllusion() then return end
    if not self:GetParent():IsAlive() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_mem_kaya_sange")[1] ~= self then return end
	self.damage_incom = self.damage_incom + params.damage
	print(self.damage_incom)
	if self.damage_incom >= self:GetAbility():GetSpecialValueFor("damage_for_stack") then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_mem_kaya_sange_stacks", {duration = self:GetAbility():GetSpecialValueFor("stacks_duration")})
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_mem_kaya_sange_damage", {duration = self:GetAbility():GetSpecialValueFor("stacks_duration")})
		self.damage_incom = 0
	end
end

modifier_item_mem_kaya_sange_damage = class({})
function modifier_item_mem_kaya_sange_damage:IsPurgable() return true end

function modifier_item_mem_kaya_sange_damage:OnCreated()
	if not IsServer() then return end 
    self:StartIntervalThink(FrameTime())
end

function modifier_item_mem_kaya_sange_damage:OnIntervalThink()
    if not IsServer() then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_item_mem_kaya_sange_stacks")
	if #modifier >= self:GetAbility():GetSpecialValueFor("max_stacks") then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("max_stacks"))
	else
    	self:SetStackCount(#modifier)
	end
	if not self:GetParent():HasModifier("modifier_item_mem_kaya_sange") then 
		self:Destroy()
	end
end

function modifier_item_mem_kaya_sange_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_item_mem_kaya_sange_damage:GetModifierIncomingDamage_Percentage() 
	return self:GetAbility():GetSpecialValueFor("stacks_incoming_dmg")
end

function modifier_item_mem_kaya_sange_damage:GetEffectName() return "particles/items2_fx/sange_maim.vpcf" end
function modifier_item_mem_kaya_sange_damage:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

modifier_item_mem_kaya_sange_stacks = class({})
function modifier_item_mem_kaya_sange_stacks:IsHidden() return true end
function modifier_item_mem_kaya_sange_stacks:IsPurgable() return true end
function modifier_item_mem_kaya_sange_stacks:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_item_mem_yasha_kaya", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_yasha_kaya_stacks", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mem_yasha_kaya_spells", "items/item_swords.lua", LUA_MODIFIER_MOTION_NONE )

item_mem_yasha_kaya = class({})

function item_mem_yasha_kaya:GetIntrinsicModifierName()
	return "modifier_item_mem_yasha_kaya" 
end

modifier_item_mem_yasha_kaya = class({})

function modifier_item_mem_yasha_kaya:IsHidden() return self:GetStackCount() == 0 end
function modifier_item_mem_yasha_kaya:IsPurgable() return false end
function modifier_item_mem_yasha_kaya:IsPurgeException() return false end
function modifier_item_mem_yasha_kaya:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mem_yasha_kaya:OnCreated()
	if not IsServer() then return end
    if not self:GetAbility() or self:GetAbility():IsNull() then return end
	self.bonus_spell_amp = self:GetAbility():GetSpecialValueFor("bonus_spell_amp")
	self.mana_restoration_amp = self:GetAbility():GetSpecialValueFor("mana_restoration_amp")
	self.stacks_duration = self:GetAbility():GetSpecialValueFor("stacks_duration")
	
	self.useless =
    {
        ["aang_quas"] = true,
        ["aang_wex"] = true,
        ["aang_exort"] = true,
        ["aang_invoke"] = true,
        ["kakashi_quas"] = true,
        ["kakashi_wex"] = true,
        ["kakashi_exort"] = true,
        ["kakashi_invoke"] = true,
        ["mum_change_hook_style"] = true,
    }

	if self:GetParent():FindAllModifiersByName("modifier_item_mem_yasha_kaya")[1] ~= self or self:GetParent():HasItemInInventory("item_mem_kaya") then
        self.spell_amp = 0
        self.mana_restoration_amp = 0
    end

	self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(FrameTime())
end

function modifier_item_mem_yasha_kaya:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_mem_yasha_kaya")[1] ~= self or self:GetParent():HasItemInInventory("item_mem_kaya") then
        self.bonus_spell_amp = 0
        self.mana_restoration_amp = 0
    else
        self.mana_restoration_amp = self:GetAbility():GetSpecialValueFor("mana_restoration_amp")
        self.bonus_spell_amp = self:GetAbility():GetSpecialValueFor("bonus_spell_amp")
    end
	if not self:GetParent():HasModifier("modifier_item_mem_yasha_kaya") then 
		self:Destroy()
	end
    self:SendBuffRefreshToClients()
end

function modifier_item_mem_yasha_kaya:AddCustomTransmitterData()
    self.data = self.data or {}
    self.data.mana_restoration_amp   = self.mana_restoration_amp or 0
    self.data.bonus_spell_amp = self.bonus_spell_amp or 0
    return self.data
end

function modifier_item_mem_yasha_kaya:HandleCustomTransmitterData( data )
    self.mana_restoration_amp = data.mana_restoration_amp
    self.bonus_spell_amp = data.bonus_spell_amp
end

function modifier_item_mem_yasha_kaya:DeclareFunctions()
	return 	{
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE ,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
			MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
			}
end

function modifier_item_mem_yasha_kaya:GetModifierBonusStats_Agility() 
	return self:GetAbility():GetSpecialValueFor("bonus_agi") 
end 

function modifier_item_mem_yasha_kaya:GetModifierBonusStats_Intellect() 
	return self:GetAbility():GetSpecialValueFor("bonus_int") 
end

function modifier_item_mem_yasha_kaya:GetModifierAttackSpeedBonus_Constant() 
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") 
end

function modifier_item_mem_yasha_kaya:GetModifierMoveSpeedBonus_Percentage_Unique() 
	return self:GetAbility():GetSpecialValueFor("bonus_movespeed") 
end

function modifier_item_mem_yasha_kaya:GetModifierPercentageCasttime() 
	return self:GetAbility():GetSpecialValueFor("spell_speed_amp") 
end

function modifier_item_mem_yasha_kaya:GetModifierMPRegenAmplify_Percentage() 
	return self.mana_restoration_amp 
end

function modifier_item_mem_yasha_kaya:GetModifierSpellAmplify_Percentage() 
	return self.bonus_spell_amp 
end

function modifier_item_mem_yasha_kaya:OnAbilityFullyCast(params)
	if not IsServer() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_mem_yasha_kaya")[1] ~= self then return end
	local hAbility = params.ability
    if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
        return 0
    end
    if hAbility:IsToggle() or hAbility:IsItem() then
        return 0
    end
    if self.useless[hAbility:GetAbilityName()] then
        return 0
    end
    if hAbility:GetCooldown(hAbility:GetLevel()) <= 0 then
        return 0
    end
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_mem_yasha_kaya_stacks", {duration = self.stacks_duration})
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_mem_yasha_kaya_spells", {duration = self.stacks_duration})
end

modifier_item_mem_yasha_kaya_spells = class({})
function modifier_item_mem_yasha_kaya_spells:IsPurgable() return true end

function modifier_item_mem_yasha_kaya_spells:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_item_mem_yasha_kaya_spells:OnIntervalThink()
    if not IsServer() then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_item_mem_yasha_kaya_stacks")
	if #modifier >= self:GetAbility():GetSpecialValueFor("max_stacks") then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("max_stacks"))
	else
    	self:SetStackCount(#modifier)
	end
end

function modifier_item_mem_yasha_kaya_spells:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_item_mem_yasha_kaya_spells:GetModifierSpellAmplify_Percentage() 
	return self:GetAbility():GetSpecialValueFor("stacks_spell_amp") * self:GetStackCount()
end

function modifier_item_mem_yasha_kaya_spells:GetEffectName() return "particles/item/swords/azura_debuff.vpcf" end
function modifier_item_mem_yasha_kaya_spells:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

modifier_item_mem_yasha_kaya_stacks = class({})
function modifier_item_mem_yasha_kaya_stacks:IsHidden() return true end
function modifier_item_mem_yasha_kaya_stacks:IsPurgable() return true end
function modifier_item_mem_yasha_kaya_stacks:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("vision_radius"), 1, true)

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

function item_lostvane_custom:CreateIllusion(count, damage, inc_damage)
    for i=1, count do
	    local illusions = BirzhaCreateIllusion(self:GetCaster(), self:GetCaster(), 
	    {
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
	    	illusion.manta = true
    		illusion:RemoveGesture(ACT_DOTA_SPAWN)
	    end
    end
end

modifier_item_lostvane_custom_custom_passive = class({})

function modifier_item_lostvane_custom_custom_passive:IsHidden() return true end
function modifier_item_lostvane_custom_custom_passive:IsPurgable() return false end
function modifier_item_lostvane_custom_custom_passive:IsPurgeException() return false end
function modifier_item_lostvane_custom_custom_passive:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_lostvane_custom_custom_passive:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
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
 
function modifier_item_lostvane_custom_custom_passive:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_lostvane_custom_custom_passive:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_evasion")
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
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_item_lostvane_custom_custom_passive:GetAuraEntityReject(target)
	if target:IsIllusion() and not target:HasModifier("modifier_item_lostvane_custom_custom_flaso") then
		return false
	else
		return true
	end
end

modifier_item_lostvane_custom_custom_passive_aura = class({})

function modifier_item_lostvane_custom_custom_passive_aura:OnCreated()
	if not IsServer() then return end
	self.damage = self:GetCaster():GetAttackDamage() / 100 * self:GetAbility():GetSpecialValueFor("illusion_damage_pasisve")
end

function modifier_item_lostvane_custom_custom_passive_aura:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
    }
end

function modifier_item_lostvane_custom_custom_passive_aura:GetModifierBaseAttack_BonusDamage()
    return self.damage
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

    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("vision_radius"), 1, true)

    local illusion_duration = self:GetAbility():GetSpecialValueFor("illusion_duration")
	local illusion_out_damage_one = self:GetAbility():GetSpecialValueFor("illusion_out_damage_one") - 100
	local illusion_in_damage_one = self:GetAbility():GetSpecialValueFor("illusion_in_damage_one") - 100
	local illusion_out_damage_two = self:GetAbility():GetSpecialValueFor("illusion_out_damage_two") - 100
	local illusion_in_damage_two = self:GetAbility():GetSpecialValueFor("illusion_in_damage_two") - 100
	local illusion_out_damage_three = self:GetAbility():GetSpecialValueFor("illusion_out_damage_three") - 100
	local illusion_in_damage_three = self:GetAbility():GetSpecialValueFor("illusion_in_damage_three") - 100
	local illusion_out_damage_four = self:GetAbility():GetSpecialValueFor("illusion_out_damage_four") - 100
	local illusion_in_damage_four = self:GetAbility():GetSpecialValueFor("illusion_in_damage_four") - 100

	local caster = self:GetCaster()
	local ability = self:GetAbility()

	Timers:CreateTimer(0, function()
		ability:CreateIllusion(1, illusion_out_damage_one, illusion_in_damage_one)
		ability:CreateIllusion(1, illusion_out_damage_two, illusion_in_damage_two)
		ability:CreateIllusion(1, illusion_out_damage_three, illusion_in_damage_three)
	end)
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