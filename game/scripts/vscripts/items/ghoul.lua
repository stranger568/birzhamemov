LinkLuaModifier( "modifier_item_ghoul", "items/ghoul", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_ghoul_buff", "items/ghoul", LUA_MODIFIER_MOTION_NONE )

item_ghoul = class({})

function item_ghoul:GetIntrinsicModifierName()
    return "modifier_item_ghoul"
end

function item_ghoul:OnToggle()
    local caster = self:GetCaster()
    local toggle = self:GetToggleState()
    if not IsServer() then return end
    caster:EmitSound("")
    if toggle then
        self:EndCooldown()
        self.modifier = caster:AddNewModifier( caster, self, "modifier_item_ghoul_buff", {} )
    else
        local mod = self:GetCaster():FindModifierByName("modifier_item_ghoul_buff")
        if mod then
            mod:Destroy()
            self:UseResources(false, false, true)
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
	return {
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_EVENT_ON_HERO_KILLED,
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_item_ghoul:OnHeroKilled(params)
    if params.attacker == self:GetParent() then
        if params.target == self:GetParent() then return end
        if params.target:HasModifier("modifier_item_ghoul") or params.target:GetUnitName() == "npc_dota_hero_life_stealer" then
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

function modifier_item_ghoul:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            local lifesteal = (self:GetAbility():GetSpecialValueFor("lifesteal_active")) / 100
            self:GetParent():Heal(params.damage * lifesteal, self:GetAbility())
        end
    end
end

modifier_item_ghoul_buff = class({})

function modifier_item_ghoul_buff:IsPurgable()
    return false
end

function modifier_item_ghoul_buff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
    self:OnIntervalThink()
end

function modifier_item_ghoul_buff:OnIntervalThink()
    if not IsServer() then return end
    --ApplyDamage({victim = self:GetParent(), attacker = self:GetParent(), damage = self:GetAbility():GetSpecialValueFor("damage_per_second_active"), damage_type = DAMAGE_TYPE_PURE, flag = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS, ability = self:GetAbility()})
    self:GetParent():SetHealth(math.max( self:GetParent():GetHealth() - 100, 1))
end

function modifier_item_ghoul_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_HERO_KILLED,

    }
end

function modifier_item_ghoul_buff:GetModifierPreAttack_BonusDamage()
    local stacks = self:GetAbility():GetSpecialValueFor("damage_per_charge") * self:GetAbility():GetCurrentCharges()
    return self:GetAbility():GetSpecialValueFor("bonus_damage_active") + stacks
end

function modifier_item_ghoul_buff:GetModifierSpellAmplify_Percentage()
    local stacks = self:GetAbility():GetSpecialValueFor("magic_damage_per_charge") * self:GetAbility():GetCurrentCharges()
    return self:GetAbility():GetSpecialValueFor("spell_amplify_active") + stacks
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

function modifier_item_ghoul_buff:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            local stacks = self:GetAbility():GetSpecialValueFor("lifesteal_per_charge") * self:GetAbility():GetCurrentCharges()
            local lifesteal = (self:GetAbility():GetSpecialValueFor("lifesteal_active")+stacks) / 100
            print(lifesteal, "no_spell")
            self:GetParent():Heal(params.damage * lifesteal, self:GetAbility())
        end
    end
end

function modifier_item_ghoul_buff:OnTakeDamage(params)
    if params.attacker == self:GetParent() then
        if params.unit == self:GetParent() then return end
        if not self:GetParent():IsHero() then return end
        if params.inflictor == nil then return end

        local no_magic_heal = {
            "azazin_gayaura",
            "Dio_Za_Warudo",
            "Felix_WaterShield",
            "haku_help",
            "Kurumi_Zafkiel",
            "item_birzha_blade_mail",
            "item_nimbus_lapteva",
            "polnaref_return",
            "polnaref_stand",
            "item_cuirass_2"
        }

        for _, ability_no in pairs(no_magic_heal) do
            if params.inflictor:GetAbilityName() == ability_no then
                return
            end
        end

        local stacks = self:GetAbility():GetSpecialValueFor("spell_lifesteal_per_charge") * self:GetAbility():GetCurrentCharges()
        local lifesteal = (self:GetAbility():GetSpecialValueFor("magic_lifesteal_active")+stacks) / 100
        self:GetParent():Heal(params.damage * lifesteal, self:GetAbility())
        local octarine = ParticleManager:CreateParticle( "particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:ReleaseParticleIndex( octarine )
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
        if RollPercentage(10) and not self:GetParent():IsIllusion() then
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