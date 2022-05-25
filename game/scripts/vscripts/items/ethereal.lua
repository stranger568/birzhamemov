LinkLuaModifier("modifier_item_ethereal_blade_custom", "items/ethereal.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ethereal_blade_ethereal_custom", "items/ethereal.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ethereal_blade_slow_custom", "items/ethereal.lua", LUA_MODIFIER_MOTION_NONE)

item_ethereal_blade_custom                    = class({})
modifier_item_ethereal_blade_custom           = class({})
modifier_item_ethereal_blade_ethereal_custom  = class({})
modifier_item_ethereal_blade_slow_custom      = class({})

function item_ethereal_blade_custom:GetIntrinsicModifierName()
    return "modifier_item_ethereal_blade_custom"
end

function item_ethereal_blade_custom:OnSpellStart()
    self.caster     = self:GetCaster()
    self.blast_movement_slow        =   self:GetSpecialValueFor("blast_movement_slow")
    self.duration                   =   self:GetSpecialValueFor("duration")
    self.blast_agility_multiplier   =   self:GetSpecialValueFor("blast_agility_multiplier")
    self.blast_damage_base          =   self:GetSpecialValueFor("blast_damage_base")
    self.projectile_speed           =   self:GetSpecialValueFor("projectile_speed")
    if not IsServer() then return end
    local target            = self:GetCursorTarget()
    self.caster:EmitSound("DOTA_Item.EtherealBlade.Activate")
    local projectile =
            {
                Target              = target,
                Source              = self.caster,
                Ability             = self,
                EffectName          = "particles/items_fx/ethereal_blade.vpcf",
                iMoveSpeed          = self.projectile_speed,
                vSourceLoc          = caster_location,
                bDrawsOnMinimap     = false,
                bDodgeable          = true,
                bIsAttack           = false,
                bVisibleToEnemies   = true,
                bReplaceExisting    = false,
                flExpireTime        = GameRules:GetGameTime() + 20,
                bProvidesVision     = false,
            }
            
        ProjectileManager:CreateTrackingProjectile(projectile)
end

function item_ethereal_blade_custom:OnProjectileHit(target, location)
    if not IsServer() then return end
    if target and not target:IsMagicImmune() then
        if target:TriggerSpellAbsorb(self) then return nil end
        target:EmitSound("DOTA_Item.EtherealBlade.Target")
        
        if target:GetTeam() == self.caster:GetTeam() then
            target:AddNewModifier(self.caster, self, "modifier_item_ethereal_blade_ethereal_custom", {duration = self.duration})
        else
            target:AddNewModifier(self.caster, self, "modifier_item_ethereal_blade_ethereal_custom", {duration = self.duration * (1 - target:GetStatusResistance())})
            local damageTable = {
                victim          = target,
                damage          = self.caster:GetPrimaryStatValue() * self.blast_agility_multiplier + self.blast_damage_base,
                damage_type     = DAMAGE_TYPE_MAGICAL,
                damage_flags    = DOTA_DAMAGE_FLAG_NONE,
                attacker        = self.caster,
                ability         = self
            }                 
            ApplyDamage(damageTable)
            if target:IsAlive() then
                target:AddNewModifier(self.caster, self, "modifier_item_ethereal_blade_slow_custom", {duration = self.duration * (1 - target:GetStatusResistance())})
            end
        end
    end
end

function modifier_item_ethereal_blade_ethereal_custom:GetStatusEffectName()
    return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_item_ethereal_blade_ethereal_custom:GetTexture()
    return "item_ethereal_blade"
end

function modifier_item_ethereal_blade_ethereal_custom:OnCreated()
    self.ability                    = self:GetAbility()
    self.caster                     = self:GetCaster()
    self.parent                     = self:GetParent()
    self.ethereal_damage_bonus      = self.ability:GetSpecialValueFor("ethereal_damage_bonus")
end

function modifier_item_ethereal_blade_ethereal_custom:OnRefresh()
    self:OnCreated()
end

function modifier_item_ethereal_blade_ethereal_custom:CheckState()
    local state = {
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true
    }
    
    return state
end

function modifier_item_ethereal_blade_ethereal_custom:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
    }
    
    return decFuncs
end

function modifier_item_ethereal_blade_ethereal_custom:GetModifierMagicalResistanceDecrepifyUnique()
    return self.ethereal_damage_bonus
end

function modifier_item_ethereal_blade_ethereal_custom:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_item_ethereal_blade_slow_custom:OnCreated()
    self.blast_movement_slow = self:GetAbility():GetSpecialValueFor("blast_movement_slow")
end

function modifier_item_ethereal_blade_slow_custom:OnRefresh()
    self:OnCreated()
end

function modifier_item_ethereal_blade_slow_custom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_item_ethereal_blade_slow_custom:GetModifierMoveSpeedBonus_Percentage()
    return self.blast_movement_slow
end

function modifier_item_ethereal_blade_slow_custom:GetTexture()
    return "item_ethereal_blade"
end

function modifier_item_ethereal_blade_custom:IsHidden()       return true end
function modifier_item_ethereal_blade_custom:IsPurgable()     return false end
function modifier_item_ethereal_blade_custom:RemoveOnDeath()  return false end

function modifier_item_ethereal_blade_custom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
end

function modifier_item_ethereal_blade_custom:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_strength")
    end
end

function modifier_item_ethereal_blade_custom:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_agility")
    end
end

function modifier_item_ethereal_blade_custom:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_intellect")
    end
end