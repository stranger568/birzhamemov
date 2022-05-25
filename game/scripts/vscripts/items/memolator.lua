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

function modifier_item_memolator:IsHidden()		return true end
function modifier_item_memolator:IsPurgable()		return false end
function modifier_item_memolator:RemoveOnDeath()	return false end

function modifier_item_memolator:DeclareFunctions()
	return {
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

function modifier_item_memolator:OnAttackLanded(keys)
    if keys.attacker == self:GetParent() then
        if keys.target:IsOther() then
            return nil
        end
        if self:GetParent():IsIllusion() then
            return nil
        end
        if self:GetParent():HasItemInInventory("item_memolator2") or self:GetParent():HasItemInInventory("item_memolator3") then
            return nil
        end
        local duration = self:GetAbility():GetSpecialValueFor("duration")
        keys.target:EmitSound("Item_Desolator.Target")
        local modifiers = {
            "modifier_item_memolator_debuff_2",
            "modifier_item_memolator_debuff_3",
        }
        for _, modifier in pairs(modifiers) do
            local modifier_to_remove = keys.target:FindModifierByName(modifier)
            if modifier_to_remove and not modifier_to_remove:IsNull() then
                modifier_to_remove:Destroy()
            end
        end
        local maximum_armor = self:GetAbility():GetSpecialValueFor("coruprion_armor")
        local modifier_active = keys.target:FindModifierByName("modifier_item_memolator_debuff")
        if modifier_active then
            if modifier_active:GetStackCount() < maximum_armor then
                keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff", {duration = duration})
                modifier_active:IncrementStackCount()
            end
        else
            keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff", {duration = duration})
        end
    end
end

LinkLuaModifier("modifier_item_memolator2", "items/memolator", LUA_MODIFIER_MOTION_NONE)

item_memolator2 = class({})

function item_memolator2:GetIntrinsicModifierName()
    return "modifier_item_memolator2"
end

modifier_item_memolator2 = class({})

function modifier_item_memolator2:IsHidden()     return true end
function modifier_item_memolator2:IsPurgable()       return false end
function modifier_item_memolator2:RemoveOnDeath()    return false end

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

function modifier_item_memolator2:OnAttackLanded(keys)
    if keys.attacker == self:GetParent() then
        if keys.target:IsOther() then
            return nil
        end
        if self:GetParent():IsIllusion() then
            return nil
        end
        if self:GetParent():HasItemInInventory("item_memolator3") then
            return nil
        end
        local duration = self:GetAbility():GetSpecialValueFor("duration")
        keys.target:EmitSound("Item_Desolator.Target")
        local modifiers = {
            "modifier_item_memolator_debuff",
            "modifier_item_memolator_debuff_3",
        }
        for _, modifier in pairs(modifiers) do
            local modifier_to_remove = keys.target:FindModifierByName(modifier)
            if modifier_to_remove and not modifier_to_remove:IsNull() then
                modifier_to_remove:Destroy()
            end
        end
        local maximum_armor = self:GetAbility():GetSpecialValueFor("coruprion_armor")
        local modifier_active = keys.target:FindModifierByName("modifier_item_memolator_debuff_2")
        if modifier_active then
            if modifier_active:GetStackCount() < maximum_armor then
                keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff_2", {duration = duration})
                if (modifier_active:GetStackCount()+2) > maximum_armor then
                    modifier_active:SetStackCount(maximum_armor)
                    return
                end
                modifier_active:SetStackCount(modifier_active:GetStackCount()+2)
            end
        else
            keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff_2", {duration = duration})
        end
    end
end

LinkLuaModifier("modifier_item_memolator3", "items/memolator", LUA_MODIFIER_MOTION_NONE)

item_memolator3 = class({})

function item_memolator3:GetIntrinsicModifierName()
    return "modifier_item_memolator3"
end

modifier_item_memolator3 = class({})

function modifier_item_memolator3:IsHidden()     return true end
function modifier_item_memolator3:IsPurgable()       return false end
function modifier_item_memolator3:RemoveOnDeath()    return false end

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

function modifier_item_memolator3:OnAttackRecord(keys)
    if keys.attacker == self:GetParent() then
        if keys.target:IsOther() then
            return nil
        end
        if self:GetParent():IsIllusion() then
            return nil
        end
        if self.critProc then
            self.critProc = false
        end
        self.chance_melee = self:GetAbility():GetSpecialValueFor("chance_melee")
        self.chance_range = self:GetAbility():GetSpecialValueFor("chance_range")
        if self:GetParent():HasItemInInventory("item_abyssal_blade") or self:GetParent():HasItemInInventory("item_basher") then
            return nil
        end
        if self:GetAbility():IsFullyCastable() then
            if self:GetParent():IsRangedAttacker() then
                if self.chance_range >= RandomInt(1, 100) then
                    self.critProc = true
                end
            else
                if self.chance_melee >= RandomInt(1, 100) then
                    self.critProc = true
                end
            end
        end
    end
end

function modifier_item_memolator3:OnAttackLanded(keys)
    if keys.attacker == self:GetParent() then
        if keys.target:IsOther() then
            return nil
        end
        if self:GetParent():IsIllusion() then
            return nil
        end
        local duration = self:GetAbility():GetSpecialValueFor("duration")
        keys.target:EmitSound("Item_Desolator.Target")
        local modifiers = {
            "modifier_item_memolator_debuff",
            "modifier_item_memolator_debuff_2",
        }
        for _, modifier in pairs(modifiers) do
            local modifier_to_remove = keys.target:FindModifierByName(modifier)
            if modifier_to_remove and not modifier_to_remove:IsNull() then
                modifier_to_remove:Destroy()
            end
        end
        local maximum_armor = self:GetAbility():GetSpecialValueFor("coruprion_armor")
        local modifier_active = keys.target:FindModifierByName("modifier_item_memolator_debuff_3")
        if modifier_active then
            if modifier_active:GetStackCount() < maximum_armor then
                keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff_3", {duration = duration})
                if (modifier_active:GetStackCount()+3) > maximum_armor then
                    modifier_active:SetStackCount(maximum_armor)
                    return
                end
                modifier_active:SetStackCount(modifier_active:GetStackCount()+3)
            end
        else
            keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_memolator_debuff_3", {duration = duration})
        end
        local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
        local damage = self:GetAbility():GetSpecialValueFor("bash_damage")
        if self.critProc then
            ApplyDamage({victim = keys.target, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self:GetAbility()})
            keys.target:EmitSound("DOTA_Item.SkullBasher")
            if self:GetParent():GetUnitName() == "npc_dota_hero_void_spirit" then
                self:GetParent():EmitSound("van_bash")
            end
            keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_birzha_bashed", {duration = stun_duration})
            self:GetAbility():UseResources(false, false, true)
            self.critProc = false
        end
    end
end

modifier_item_memolator_debuff = class({})

function modifier_item_memolator_debuff:IsPurgable() return false end

function modifier_item_memolator_debuff:OnCreated()
    self.base_corruption = 0
    self:SetStackCount(1)
    self.base_corruption = self:GetAbility():GetSpecialValueFor("base_coruprion_armor") * (-1)
end

function modifier_item_memolator_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_item_memolator_debuff:GetModifierPhysicalArmorBonus()
    return self:GetStackCount() * (-1) + self.base_corruption
end

function modifier_item_memolator_debuff:GetTexture()
    return "Items/memolator"
end

modifier_item_memolator_debuff_2 = class({})

function modifier_item_memolator_debuff_2:IsPurgable() return false end

function modifier_item_memolator_debuff_2:OnCreated()
    self.base_corruption = 0
    self:SetStackCount(2)
    self.base_corruption = self:GetAbility():GetSpecialValueFor("base_coruprion_armor") * (-1)
end

function modifier_item_memolator_debuff_2:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_item_memolator_debuff_2:GetModifierPhysicalArmorBonus()
    return self:GetStackCount() * (-1) + self.base_corruption
end

function modifier_item_memolator_debuff_2:GetTexture()
    return "Items/memolator2"
end

modifier_item_memolator_debuff_3 = class({})

function modifier_item_memolator_debuff_3:IsPurgable() return false end

function modifier_item_memolator_debuff_3:OnCreated()
    self.base_corruption = 0
    self:SetStackCount(3)
    self.base_corruption = self:GetAbility():GetSpecialValueFor("base_coruprion_armor") * (-1)
end

function modifier_item_memolator_debuff_3:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_item_memolator_debuff_3:GetModifierPhysicalArmorBonus()
    return self:GetStackCount() * (-1) + self.base_corruption
end

function modifier_item_memolator_debuff_3:GetTexture()
    return "Items/memolator3"
end