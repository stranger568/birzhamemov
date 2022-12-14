LinkLuaModifier( "modifier_item_podorozhnik", "items/podorozhnik", LUA_MODIFIER_MOTION_NONE )

item_podorozhnik = class({})

function item_podorozhnik:GetIntrinsicModifierName() 
    return "modifier_item_podorozhnik"
end

modifier_item_podorozhnik = class({})

function modifier_item_podorozhnik:IsHidden() return true end
function modifier_item_podorozhnik:IsPurgable() return false end
function modifier_item_podorozhnik:IsPurgeException() return false end
function modifier_item_podorozhnik:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_podorozhnik:Custom_AllHealAmplify_Percentage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_heal_pct")
end

LinkLuaModifier( "modifier_item_birzha_holy_locket", "items/podorozhnik", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_birzha_holy_locket_aura", "items/podorozhnik", LUA_MODIFIER_MOTION_NONE )

item_birzha_holy_locket = class({})

function item_birzha_holy_locket:GetIntrinsicModifierName() 
    return "modifier_item_birzha_holy_locket"
end

function item_birzha_holy_locket:OnAbilityPhaseStart() 
    if not IsServer() then return end
    if self:GetCurrentCharges() <= 0 then
    	return false
    end
    return true
end

function item_birzha_holy_locket:OnSpellStart() 
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local bonus_charge = self:GetSpecialValueFor("regen_per_charge")


    local bonus_heal_mana = self:GetCurrentCharges()*bonus_charge

    if target == self:GetCaster() then
        bonus_heal_mana = bonus_heal_mana / 2
    end

    target:Heal(bonus_heal_mana, self)
    target:GiveMana(bonus_heal_mana)

    self:SetCurrentCharges(0)
  	local particle = ParticleManager:CreateParticle("particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl( particle, 0, target:GetAbsOrigin() )
end

modifier_item_birzha_holy_locket = class({})

function modifier_item_birzha_holy_locket:IsHidden() return true end
function modifier_item_birzha_holy_locket:IsPurgable() return false end
function modifier_item_birzha_holy_locket:IsPurgeException() return false end
function modifier_item_birzha_holy_locket:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_birzha_holy_locket:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("charge_cooldown"))
end

function modifier_item_birzha_holy_locket:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_birzha_holy_locket")[1] ~= self then return end
    if self:GetAbility():GetCurrentCharges() < self:GetAbility():GetSpecialValueFor("max_charges") then
    	self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges() + 1)
    	if self:GetAbility():GetCurrentCharges() > self:GetAbility():GetSpecialValueFor("max_charges") then
    		self:GetAbility():SetCurrentCharges(self:GetAbility():GetSpecialValueFor("max_charges"))
    	end
    end
end

function modifier_item_birzha_holy_locket:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS
    }
end

function modifier_item_birzha_holy_locket:Custom_AllHealAmplify_Percentage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_heal_pct")
end

function modifier_item_birzha_holy_locket:GetModifierHealthBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('health')
end

function modifier_item_birzha_holy_locket:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_str')
end

function modifier_item_birzha_holy_locket:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_agi')
end

function modifier_item_birzha_holy_locket:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_int')
end

function modifier_item_birzha_holy_locket:IsAura()
    return true
end

function modifier_item_birzha_holy_locket:GetModifierAura()
    return "modifier_item_birzha_holy_locket_aura"
end

function modifier_item_birzha_holy_locket:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_item_birzha_holy_locket:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_birzha_holy_locket:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_item_birzha_holy_locket:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_item_birzha_holy_locket_aura = class({})

function modifier_item_birzha_holy_locket_aura:IsHidden() return true end
function modifier_item_birzha_holy_locket_aura:IsPurgable() return false end
function modifier_item_birzha_holy_locket_aura:IsPurgeException() return false end
function modifier_item_birzha_holy_locket_aura:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_birzha_holy_locket_aura:DeclareFunctions()
    return  
    {
    	MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
end

function modifier_item_birzha_holy_locket_aura:OnAbilityExecuted( params )
    if IsServer() then
        local hAbility = params.ability

        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
            return 0
        end

        if hAbility:IsToggle() then
            return 0
        end

    	if self:GetAbility():GetCurrentCharges() < self:GetAbility():GetSpecialValueFor("max_charges") then
    		self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges() + 1)
    		if self:GetAbility():GetCurrentCharges() > self:GetAbility():GetSpecialValueFor("max_charges") then
    			self:GetAbility():SetCurrentCharges(self:GetAbility():GetSpecialValueFor("max_charges"))
    		end
    	end
    end    
end

LinkLuaModifier( "modifier_item_medkit", "items/podorozhnik", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_medkit_aura", "items/podorozhnik", LUA_MODIFIER_MOTION_NONE )

item_medkit = class({})

function item_medkit:GetIntrinsicModifierName() 
    return "modifier_item_medkit"
end

function item_medkit:OnAbilityPhaseStart() 
    if not IsServer() then return end
    if self:GetCurrentCharges() <= 0 then
    	return false
    end
    return true
end

function item_medkit:OnSpellStart() 
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local bonus_charge = self:GetSpecialValueFor("regen_per_charge")

    local bonus_heal_mana = self:GetCurrentCharges()*bonus_charge

    if target == self:GetCaster() then
        bonus_heal_mana = bonus_heal_mana / 2
    end

    target:Heal(bonus_heal_mana, self)
    target:GiveMana(bonus_heal_mana)
    self:SetCurrentCharges(0)
  	local particle = ParticleManager:CreateParticle("particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl( particle, 0, target:GetAbsOrigin() )
    self:GetCaster():EmitSound("medkit_use")
end

modifier_item_medkit = class({})

function modifier_item_medkit:IsHidden() return true end
function modifier_item_medkit:IsPurgable() return false end
function modifier_item_medkit:IsPurgeException() return false end
function modifier_item_medkit:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_medkit:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("charge_cooldown"))
end

function modifier_item_medkit:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_medkit")[1] ~= self then return end
    if self:GetAbility():GetCurrentCharges() < self:GetAbility():GetSpecialValueFor("max_charges") then
    	self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges() + 1)
    	if self:GetAbility():GetCurrentCharges() > self:GetAbility():GetSpecialValueFor("max_charges") then
    		self:GetAbility():SetCurrentCharges(self:GetAbility():GetSpecialValueFor("max_charges"))
    	end
    end
end

function modifier_item_medkit:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    	MODIFIER_PROPERTY_HEALTH_BONUS,
    	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    	MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end

function modifier_item_medkit:Custom_AllHealAmplify_Percentage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_heal_pct")
end

function modifier_item_medkit:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_str')
end

function modifier_item_medkit:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_agi')
end

function modifier_item_medkit:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_int')
end

function modifier_item_medkit:GetModifierHealthBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_hp')
end

function modifier_item_medkit:GetModifierConstantHealthRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_hp_regen')
end

function modifier_item_medkit:GetModifierConstantManaRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_mana_regen')
end

function modifier_item_medkit:IsAura()
    return true
end

function modifier_item_medkit:GetModifierAura()
    return "modifier_item_medkit_aura"
end

function modifier_item_medkit:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_item_medkit:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_medkit:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_item_medkit:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_item_medkit_aura = class({})

function modifier_item_medkit_aura:IsHidden() return true end
function modifier_item_medkit_aura:IsPurgable() return false end
function modifier_item_medkit_aura:IsPurgeException() return false end
function modifier_item_medkit_aura:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_medkit_aura:DeclareFunctions()
    return  
    {
    	MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
end

function modifier_item_medkit_aura:OnAbilityExecuted( params )
    if IsServer() then
        local hAbility = params.ability
        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
            return 0
        end

        if hAbility:IsToggle() then
            return 0
        end

    	if self:GetAbility():GetCurrentCharges() < self:GetAbility():GetSpecialValueFor("max_charges") then
    		self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges() + 1)
    		if self:GetAbility():GetCurrentCharges() > self:GetAbility():GetSpecialValueFor("max_charges") then
    			self:GetAbility():SetCurrentCharges(self:GetAbility():GetSpecialValueFor("max_charges"))
    		end
    	end
    end    
end
