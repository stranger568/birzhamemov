LinkLuaModifier( "modifier_item_magic_crystalis", "items/magic_crit", LUA_MODIFIER_MOTION_NONE )

item_magic_crystalis = class({})

function item_magic_crystalis:GetIntrinsicModifierName() 
    return "modifier_item_magic_crystalis"
end

modifier_item_magic_crystalis = class({})

function modifier_item_magic_crystalis:IsHidden()
    return true
end

function modifier_item_magic_crystalis:IsPurgable()
    return false
end

function modifier_item_magic_crystalis:DeclareFunctions()
return  {
            MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
            MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
            MODIFIER_EVENT_ON_TAKEDAMAGE
        }
end

function modifier_item_magic_crystalis:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_magic_crystalis:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_intellect")
    end
end

function modifier_item_magic_crystalis:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
    end
end

function modifier_item_magic_crystalis:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_intellect")
    end
end

function modifier_item_magic_crystalis:OnTakeDamage(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() and params.damage_type == 2 and params.inflictor:GetName() ~= "Ricardo_KokosMaslo" and params.damage > 100 then
        if self:GetParent():HasModifier("modifier_item_magic_daedalus") then return end
        if RollPercentage(20) then
            if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION) ~= DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS) ~= DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS then
                local damage_visual = params.damage * 1.25
                local damage = damage_visual - params.damage
                local digits = string.len( math.floor( damage_visual ) ) + 1
                local numParticle = ParticleManager:CreateParticle( "particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.unit )
                ParticleManager:SetParticleControl( numParticle, 1, Vector( 0, damage_visual, 4 ) )
                ParticleManager:SetParticleControl( numParticle, 2, Vector( 2, digits, 0 ) )
                ParticleManager:SetParticleControl( numParticle, 3, Vector( 204, 0, 255 ) )
                params.unit:EmitSound("DOTA_Item.HotD.Activate")
                local damageTable = {victim = params.unit,
                attacker = self:GetCaster(),
                damage = damage,
                ability = params.inflictor,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
                }
                ApplyDamage(damageTable)
            end
        end
    end
end

LinkLuaModifier( "modifier_item_magic_daedalus", "items/magic_crit", LUA_MODIFIER_MOTION_NONE )

item_magic_daedalus = class({})

function item_magic_daedalus:GetIntrinsicModifierName() 
    return "modifier_item_magic_daedalus"
end

modifier_item_magic_daedalus = class({})

function modifier_item_magic_daedalus:IsHidden()
    return true
end

function modifier_item_magic_daedalus:IsPurgable()
    return false
end

function modifier_item_magic_daedalus:DeclareFunctions()
return  {
            MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
            MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, 
            MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
            MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
            MODIFIER_PROPERTY_HEALTH_BONUS,
            MODIFIER_PROPERTY_MANA_BONUS,
            MODIFIER_EVENT_ON_TAKEDAMAGE,
        }
end

function modifier_item_magic_daedalus:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_magic_daedalus:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
    end
end

function modifier_item_magic_daedalus:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
    end
end

function modifier_item_magic_daedalus:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_intellect")
    end
end

function modifier_item_magic_daedalus:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_str")
    end
end

function modifier_item_magic_daedalus:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_agi")
    end
end

function modifier_item_magic_daedalus:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_hp")
    end
end

function modifier_item_magic_daedalus:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_mana")
    end
end

function modifier_item_magic_daedalus:OnTakeDamage(params)
    if not IsServer() then return end
    print(params.damage_type)
    if params.attacker == self:GetParent() and params.damage_type == 2 and params.inflictor:GetName() ~= "Ricardo_KokosMaslo" and params.damage > 100 then
        if RollPercentage(25) then
            if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION) ~= DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS) ~= DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS then
                local damage_visual = params.damage * 1.5
                local damage = damage_visual - params.damage
                local digits = string.len( math.floor( damage_visual ) ) + 1
                local numParticle = ParticleManager:CreateParticle( "particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.unit )
                ParticleManager:SetParticleControl( numParticle, 1, Vector( 0, damage_visual, 4 ) )
                ParticleManager:SetParticleControl( numParticle, 2, Vector( 2, digits, 0 ) )
                ParticleManager:SetParticleControl( numParticle, 3, Vector( 204, 0, 255 ) )
                params.unit:EmitSound("DOTA_Item.HotD.Activate")
                local damageTable = {victim = params.unit,
                attacker = self:GetCaster(),
                damage = damage,
                ability = params.inflictor,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
                }
                ApplyDamage(damageTable)
            end
        end
    end
end