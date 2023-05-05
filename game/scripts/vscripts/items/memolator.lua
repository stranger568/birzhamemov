LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier("modifier_item_memolator", "items/memolator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_memolator_debuff", "items/memolator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_memolator_debuff_2", "items/memolator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_memolator_debuff_3", "items/memolator", LUA_MODIFIER_MOTION_NONE)

item_memolator = class({})

function item_memolator:GetIntrinsicModifierName()
	return "modifier_item_memolator"
end

modifier_item_memolator = class({})

function modifier_item_memolator:IsHidden() return true end
function modifier_item_memolator:IsPurgable() return false end
function modifier_item_memolator:IsPurgeException() return false end
function modifier_item_memolator:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_memolator:DeclareFunctions()
	return 
    {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end

function modifier_item_memolator:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_memolator:GetModifierProjectileName()
    return "particles/items_fx/desolator_projectile.vpcf"
end

function modifier_item_memolator:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_memolator")[1] ~= self then return end
    if self:GetParent():IsIllusion() then return end
    if self:GetParent():HasModifier("modifier_item_memolator2") then return end
    if self:GetParent():HasModifier("modifier_item_memolator3") then return end

    local coruprion_armor_max = self:GetAbility():GetSpecialValueFor("coruprion_armor_max")
    local curption_per_attack = self:GetAbility():GetSpecialValueFor("curption_per_attack")
    local base_coruprion_armor = self:GetAbility():GetSpecialValueFor("base_coruprion_armor")
    local duration = self:GetAbility():GetSpecialValueFor("duration")

    local modifier_active = params.target:FindModifierByName("modifier_item_memolator_debuff")

    if modifier_active then
        if modifier_active:GetStackCount() + curption_per_attack < coruprion_armor_max then
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff", {duration = duration})
            modifier_active:SetStackCount(modifier_active:GetStackCount() + curption_per_attack)
        else
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff_3", {duration = duration})
            modifier_active:SetStackCount(coruprion_armor_max)
        end
    else
        local modifier = params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff", {duration = duration})
        if modifier then
            modifier:SetStackCount(base_coruprion_armor)
        end
    end

    params.target:EmitSound("Item_Desolator.Target")
end

LinkLuaModifier("modifier_item_memolator2", "items/memolator", LUA_MODIFIER_MOTION_NONE)

item_memolator2 = class({})

function item_memolator2:GetIntrinsicModifierName()
    return "modifier_item_memolator2"
end

modifier_item_memolator2 = class({})

function modifier_item_memolator2:IsHidden() return true end
function modifier_item_memolator2:IsPurgable() return false end
function modifier_item_memolator2:IsPurgeException() return false end
function modifier_item_memolator2:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_memolator2:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
    }
end

function modifier_item_memolator2:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_memolator2:GetModifierProjectileName()
    return "particles/memolator2/desolator_projectile.vpcf"
end

function modifier_item_memolator2:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_memolator2")[1] ~= self then return end
    if self:GetParent():IsIllusion() then return end
    if self:GetParent():HasModifier("modifier_item_memolator3") then return end

    local coruprion_armor_max = self:GetAbility():GetSpecialValueFor("coruprion_armor_max")
    local curption_per_attack = self:GetAbility():GetSpecialValueFor("curption_per_attack")
    local base_coruprion_armor = self:GetAbility():GetSpecialValueFor("base_coruprion_armor")
    local duration = self:GetAbility():GetSpecialValueFor("duration")

    local modifier_active = params.target:FindModifierByName("modifier_item_memolator_debuff_2")

    if modifier_active then
        if modifier_active:GetStackCount() + curption_per_attack < coruprion_armor_max then
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff_2", {duration = duration})
            modifier_active:SetStackCount(modifier_active:GetStackCount() + curption_per_attack)
        else
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff_3", {duration = duration})
            modifier_active:SetStackCount(coruprion_armor_max)
        end
    else
        local modifier = params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff_2", {duration = duration})
        if modifier then
            modifier:SetStackCount(base_coruprion_armor)
        end
    end

    params.target:EmitSound("Item_Desolator.Target")
end

LinkLuaModifier("modifier_item_memolator3", "items/memolator", LUA_MODIFIER_MOTION_NONE)

item_memolator3 = class({})

function item_memolator3:GetIntrinsicModifierName()
    return "modifier_item_memolator3"
end

modifier_item_memolator3 = class({})

function modifier_item_memolator3:IsHidden() return true end
function modifier_item_memolator3:IsPurgable() return false end
function modifier_item_memolator3:IsPurgeException() return false end
function modifier_item_memolator3:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_memolator3:OnCreated()
    if not IsServer() then return end
    self.critProc = false
end

function modifier_item_memolator3:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_EVENT_ON_ATTACK_RECORD,
    }
end

function modifier_item_memolator3:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_memolator3:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_strength")
    end
end

function modifier_item_memolator3:GetModifierProjectileName()
    return "particles/memolator3/memolator.vpcf"
end

function modifier_item_memolator3:OnAttackRecord(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if params.attacker:IsIllusion() then return end
    if self:GetParent():HasItemInInventory("item_abyssal_blade") or self:GetParent():HasItemInInventory("item_basher") then
        return nil
    end
    if self:GetParent():FindAllModifiersByName("modifier_item_memolator3")[1] ~= self then return end
    local chance_melee = self:GetAbility():GetSpecialValueFor("chance_melee")
    local chance_range = self:GetAbility():GetSpecialValueFor("chance_range")
    if self:GetAbility():IsFullyCastable() then
        if self:GetParent():IsRangedAttacker() then
            if RollPercentage( self:GetAbility():GetSpecialValueFor("chance_range") ) then
                self.critProc = true
            end
        else
            if RollPercentage( self:GetAbility():GetSpecialValueFor("chance_melee") ) then
                self.critProc = true
            end
        end
    end
end

function modifier_item_memolator3:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_memolator3")[1] ~= self then return end
    if self:GetParent():IsIllusion() then return end

    local coruprion_armor_max = self:GetAbility():GetSpecialValueFor("coruprion_armor_max")
    local curption_per_attack = self:GetAbility():GetSpecialValueFor("curption_per_attack")
    local base_coruprion_armor = self:GetAbility():GetSpecialValueFor("base_coruprion_armor")
    local duration = self:GetAbility():GetSpecialValueFor("duration")

    local modifier_active = params.target:FindModifierByName("modifier_item_memolator_debuff_3")

    if modifier_active then
        if modifier_active:GetStackCount() + curption_per_attack < coruprion_armor_max then
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff_3", {duration = duration})
            modifier_active:SetStackCount(modifier_active:GetStackCount() + curption_per_attack)
        else
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff_3", {duration = duration})
            modifier_active:SetStackCount(coruprion_armor_max)
        end
    else
        local modifier = params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff_3", {duration = duration})
        if modifier then
            modifier:SetStackCount(base_coruprion_armor)
        end
    end

    if self.critProc then
        local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")

        local damage = self:GetAbility():GetSpecialValueFor("bash_damage")

        ApplyDamage({victim = params.target, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self:GetAbility()})

        params.target:EmitSound("DOTA_Item.SkullBasher")

        if self:GetParent():GetUnitName() == "npc_dota_hero_void_spirit" then
            self:GetParent():EmitSound("van_bash")
        end

        params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_birzha_bashed", {duration = stun_duration})

        self:GetAbility():UseResources(false, false, false, true)

        self.critProc = false
    end

    params.target:EmitSound("Item_Desolator.Target")
end

modifier_item_memolator_debuff = class({})

function modifier_item_memolator_debuff:IsPurgable() return false end

function modifier_item_memolator_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_item_memolator_debuff:GetModifierPhysicalArmorBonus()
    return self:GetStackCount() * (-1)
end

function modifier_item_memolator_debuff:GetTexture()
    return "Items/memolator"
end

modifier_item_memolator_debuff_2 = class({})

function modifier_item_memolator_debuff_2:IsPurgable() return false end

function modifier_item_memolator_debuff_2:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_item_memolator_debuff_2:GetModifierPhysicalArmorBonus()
    return self:GetStackCount() * (-1)
end

function modifier_item_memolator_debuff_2:GetTexture()
    return "Items/memolator2"
end

modifier_item_memolator_debuff_3 = class({})

function modifier_item_memolator_debuff_3:IsPurgable() return false end

function modifier_item_memolator_debuff_3:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_item_memolator_debuff_3:GetModifierPhysicalArmorBonus()
    return self:GetStackCount() * (-1)
end

function modifier_item_memolator_debuff_3:GetTexture()
    return "Items/memolator3"
end