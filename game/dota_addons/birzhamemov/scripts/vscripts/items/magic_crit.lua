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
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_magic_crystalis:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_magic_crystalis:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
end

function modifier_item_magic_crystalis:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end


function modifier_item_magic_crystalis:OnTakeDamage(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() and params.damage_type == 2 and params.inflictor:GetName() ~= "Ricardo_KokosMaslo" then
        if RollPercentage(20) then
            if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION) ~= DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS) ~= DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS then
                local damage_visual = params.original_damage * 1.6
                local damage = damage_visual - params.original_damage
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
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_magic_daedalus:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_magic_daedalus:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
end

function modifier_item_magic_daedalus:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_magic_daedalus:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_magic_daedalus:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agi")
end

function modifier_item_magic_daedalus:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_item_magic_daedalus:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_magic_daedalus:OnTakeDamage(params)
    if not IsServer() then return end
    print(params.damage_type)
    if params.attacker == self:GetParent() and params.damage_type == 2 and params.inflictor:GetName() ~= "Ricardo_KokosMaslo" then
        if RollPercentage(25) then
            if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION) ~= DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS) ~= DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS then
                local damage_visual = params.original_damage * 2.25
                local damage = damage_visual - params.original_damage
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