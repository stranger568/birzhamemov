LinkLuaModifier( "modifier_item_ghoul", "items/ghoul", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_ghoul_buff", "items/ghoul", LUA_MODIFIER_MOTION_NONE )

item_ghoul = class({})

function item_ghoul:GetIntrinsicModifierName()
    return "modifier_item_ghoul"
end

function item_ghoul:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_item_ghoul_buff") then
        return "items/ghoul"
    else
        return "items/ghoul_off"
    end
end

function item_ghoul:OnToggle()
    local caster = self:GetCaster()
    local toggle = self:GetToggleState()

    if not IsServer() then return end

    if toggle then
        self:EndCooldown()
        self.modifier = caster:AddNewModifier( caster, self, "modifier_item_ghoul_buff", {} )
        self:GetCaster():EmitSound("ghoul_mask")
    else
        local mod = self:GetCaster():FindModifierByName("modifier_item_ghoul_buff")
        if mod then
            mod:Destroy()
            self:UseResources(false, false, false, true)
        end
    end
end

modifier_item_ghoul = class({})

function modifier_item_ghoul:IsHidden() return true end

function modifier_item_ghoul:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_item_ghoul:IsPurgable()
    return false
end

function modifier_item_ghoul:OnDestroy()
    if not IsServer() then return end
    local mod = self:GetParent():FindModifierByName("modifier_item_ghoul_buff")
    if mod then
        mod:Destroy()
    end
end

function modifier_item_ghoul:DeclareFunctions()
	return 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_HERO_KILLED,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_item_ghoul:OnHeroKilled(params)
    if params.attacker == self:GetParent() then
        if params.target == self:GetParent() then return end
        if params.attacker:HasModifier("modifier_item_ghoul_buff") then
            self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges() + 1)
        end
    end
end

function modifier_item_ghoul:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_ghoul:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_ghoul:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_hp_regen")
end

function modifier_item_ghoul:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local heal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100 * params.damage
        self:GetParent():Heal(heal, self:GetAbility())

        local particle = "particles/generic_gameplay/generic_lifesteal.vpcf"

        if DonateShopIsItemBought(self:GetParent():GetPlayerOwnerID(), 195) or IsInToolsMode() then
            particle = "particles/ghoul_mask_lifesteal.vpcf"
        end

        local effect_cast = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        if DonateShopIsItemBought(self:GetParent():GetPlayerOwnerID(), 195) or IsInToolsMode() then
            ParticleManager:SetParticleControlEnt(effect_cast, 0, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
        end
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

modifier_item_ghoul_buff = class({})

function modifier_item_ghoul_buff:IsPurgable()
    return false
end

function modifier_item_ghoul_buff:OnCreated()
    if not IsServer() then return end

    if DonateShopIsItemBought(self:GetParent():GetPlayerOwnerID(), 195) or IsInToolsMode() then
        local particle = ParticleManager:CreateParticle( "particles/ghoul_mask_effect_bp.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        self:AddParticle(particle, false, false, -1, false, false)
    end

    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end

function modifier_item_ghoul_buff:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():SetHealth(math.max( self:GetParent():GetHealth() - (100 * 0.1), 1))
end

function modifier_item_ghoul_buff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_HERO_KILLED,
    }
end

function modifier_item_ghoul_buff:GetModifierPreAttack_BonusDamage()
    local stacks = self:GetAbility():GetSpecialValueFor("damage_per_charge") * self:GetAbility():GetCurrentCharges()
    return self:GetAbility():GetSpecialValueFor("bonus_damage_active") + stacks
end

function modifier_item_ghoul_buff:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("movespeed_active")
end

function modifier_item_ghoul_buff:GetModifierPercentageCasttime()
    return self:GetAbility():GetSpecialValueFor("cast_point_active")
end

function modifier_item_ghoul_buff:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_str_active")
end

function modifier_item_ghoul_buff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor_active")
end

function modifier_item_ghoul_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed_active")
end

function modifier_item_ghoul_buff:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end

    if params.inflictor == nil then
        if not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
            local stacks = self:GetAbility():GetSpecialValueFor("lifesteal_per_charge") * self:GetAbility():GetCurrentCharges()
            local lifesteal = (self:GetAbility():GetSpecialValueFor("lifesteal_active")+stacks) / 100
            self:GetParent():Heal(params.damage * lifesteal, self:GetAbility())
            local particle = "particles/generic_gameplay/generic_lifesteal.vpcf"

            if DonateShopIsItemBought(self:GetParent():GetPlayerOwnerID(), 195) or IsInToolsMode() then
                particle = "particles/ghoul_mask_lifesteal.vpcf"
            end
            local effect_cast = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN_FOLLOW, params.attacker )
            if DonateShopIsItemBought(self:GetParent():GetPlayerOwnerID(), 195) or IsInToolsMode() then
                ParticleManager:SetParticleControlEnt(effect_cast, 0, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
            end
            ParticleManager:ReleaseParticleIndex( effect_cast )
        end
    else
        if not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
            local bonus_percentage = 0
            for _, mod in pairs(self:GetParent():FindAllModifiers()) do
                if mod.GetModifierSpellLifestealRegenAmplify_Percentage and mod:GetModifierSpellLifestealRegenAmplify_Percentage() then
                    bonus_percentage = bonus_percentage + mod:GetModifierSpellLifestealRegenAmplify_Percentage()
                end
            end
            local stacks = self:GetAbility():GetSpecialValueFor("spell_lifesteal_per_charge") * self:GetAbility():GetCurrentCharges()
            local lifesteal = (self:GetAbility():GetSpecialValueFor("magic_lifesteal_active")+stacks) / 100
            local heal = params.damage * lifesteal
            heal = heal * (bonus_percentage / 100 + 1)
            self:GetParent():Heal(heal, self:GetAbility())
            local octarine = ParticleManager:CreateParticle( "particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
            ParticleManager:ReleaseParticleIndex( octarine )
        end
    end
end

function modifier_item_ghoul_buff:GetEffectName()
    return "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf" 
end

function modifier_item_ghoul_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_item_ghoul_buff:OnHeroKilled(params)
    if params.attacker == self:GetParent() then
        if params.target == self:GetParent() then return end
        if (RollPercentage(10) and not self:GetParent():IsIllusion()) or IsInToolsMode() then
            GameRules:GetGameModeEntity():SetPauseEnabled( true )
            PauseGame(true)
            GameRules:GetGameModeEntity():SetPauseEnabled( false )
            Timers:CreateTimer({
                useGameTime = false,
                endTime = 1,
                callback = function()
                        GameRules:GetGameModeEntity():SetPauseEnabled( true )
                        PauseGame(false)
                        GameRules:GetGameModeEntity():SetPauseEnabled( false )
                    return nil
                end
            })
        end
    end
end