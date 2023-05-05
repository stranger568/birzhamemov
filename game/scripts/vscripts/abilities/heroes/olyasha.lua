LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_olyasha_gasm", "abilities/heroes/olyasha", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_olyasha_gasm_passive", "abilities/heroes/olyasha", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

olyasha_gasm = class({}) 

function olyasha_gasm:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function olyasha_gasm:GetManaCost(level)
    if self:GetCaster():HasShard() then
        return 0
    end
    return self.BaseClass.GetManaCost(self, level)
end

function olyasha_gasm:GetIntrinsicModifierName()
    return "modifier_olyasha_gasm_passive"
end

function olyasha_gasm:OnSpellStart()
    if not IsServer() then return end       
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_olyasha_4")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_olyasha_gasm", {duration = duration})
    self:GetCaster():EmitSound("Hero_Clinkz.Strafe")
end

modifier_olyasha_gasm = class({})

function modifier_olyasha_gasm:IsHidden() return false end
function modifier_olyasha_gasm:IsPurgable() return true end

function modifier_olyasha_gasm:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_olyasha_gasm:OnIntervalThink()
    if not IsServer() then return end
    
    ProjectileManager:ProjectileDodge(self:GetParent())
end

function modifier_olyasha_gasm:GetEffectName()
    return "particles/units/heroes/hero_clinkz/clinkz_strafe_fire.vpcf"
end

function modifier_olyasha_gasm:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_olyasha_gasm:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,}

    return decFuncs
end

function modifier_olyasha_gasm:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end








modifier_olyasha_gasm_passive = class({})

function modifier_olyasha_gasm_passive:IsHidden() return true end
function modifier_olyasha_gasm_passive:IsPurgable() return false end

function modifier_olyasha_gasm_passive:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,}
    return decFuncs
end

function modifier_olyasha_gasm_passive:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed_passive")
end






LinkLuaModifier("modifier_olyasha_vzhuh", "abilities/heroes/olyasha", LUA_MODIFIER_MOTION_NONE)

Olyasha_Vzhuh = class({}) 

function Olyasha_Vzhuh:GetCooldown(level)
    return (self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_olyasha_3")) / ( self:GetCaster():GetCooldownReduction())
end

function Olyasha_Vzhuh:GetIntrinsicModifierName()
    return "modifier_olyasha_vzhuh"
end

modifier_olyasha_vzhuh = class({}) 

function modifier_olyasha_vzhuh:IsHidden()      return true end
function modifier_olyasha_vzhuh:IsPurgable()    return false end

function modifier_olyasha_vzhuh:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,
    }
end

function modifier_olyasha_vzhuh:OnAttack( keys )
    if not IsServer() then return end
    local attacker = self:GetParent()

    if attacker ~= keys.attacker then
        return
    end

    if attacker:PassivesDisabled() or attacker:IsIllusion() then
        return
    end

    local target = keys.target

    if attacker:GetTeam() == target:GetTeam() then
        return
    end 

    local split_shot_targets = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self:GetParent():Script_GetAttackRange()+50, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
    if self:GetAbility():IsFullyCastable() then
        for _,v in pairs(split_shot_targets) do
            local projectile_info = 
            {
                EffectName = "particles/econ/items/enchantress/enchantress_virgas/ench_impetus_virgas.vpcf",
                Ability = self:GetAbility(),
                vSpawnOrigin = self:GetParent():GetAbsOrigin(),
                Target = v,
                Source = self:GetParent(),
                bHasFrontalCone = false,
                iMoveSpeed = 1200,
                bReplaceExisting = false,
                bProvidesVision = true
            }
            ProjectileManager:CreateTrackingProjectile(projectile_info)                    
            self:GetAbility():UseResources(false,false,false,true)
            self:GetParent():EmitSound("Hero_Enchantress.Impetus")
        end
    end
end

function Olyasha_Vzhuh:OnProjectileHit( target, location )
    if not IsServer() then return end
    if target then
        local bonus_damage = self:GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_olyasha_1")
        local damage = bonus_damage + self:GetCaster():GetAttackDamage()
        ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
    end
    return true
end

LinkLuaModifier( "modifier_olyasha_love", "abilities/heroes/olyasha.lua", LUA_MODIFIER_MOTION_NONE )

Olyasha_love = class({})

function Olyasha_love:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Olyasha_love:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Olyasha_love:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Olyasha_love:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition() + 5
    local caster_loc = caster:GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,caster)
    local direction = (target_loc - caster_loc):Normalized()
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/olyasha/olyasha_love_smoke.vpcf",
        vSpawnOrigin        = caster_loc,
        fDistance           = 700,
        fStartRadius        = 175,
        fEndRadius          = 250,
        Source              = caster,
        bHasFrontalCone     = true,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 700,
        bProvidesVision     = true,
        iVisionRadius =     250,
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    caster:EmitSound("Hero_Windrunner.BlowYouAKiss")
    caster:EmitSound("ui_rollover_today")
end

function Olyasha_love:OnProjectileHit( target, location )
    if not IsServer() then return end
    if target then
        local duration = self:GetSpecialValueFor( "duration" )
        target:AddNewModifier(self:GetCaster(), self, "modifier_olyasha_love", {duration = duration * (1 - target:GetStatusResistance())})
    end
end

modifier_olyasha_love = class({}) 

function modifier_olyasha_love:IsPurgable()    return false end
function modifier_olyasha_love:IsPurgeException()    return true end

function modifier_olyasha_love:OnCreated(kv)
   if not IsServer() then return end
   self:StartIntervalThink(FrameTime())
   self.damage_tick = 0
   self.point = Vector(kv.x,kv.y,kv.z)
end

function modifier_olyasha_love:OnIntervalThink()
    if not IsServer() then return end
    self.damage_tick = self.damage_tick + FrameTime()
    if self.damage_tick >= 0.5 then
        local damage = self:GetAbility():GetSpecialValueFor('damage') + self:GetCaster():FindTalentValue("special_bonus_birzha_olyasha_2")
        ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage * 0.5, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
        self.damage_tick = 0
    end

    if self:GetCaster():HasScepter() then
        local unit_location = self:GetParent():GetAbsOrigin()
        local vector_distance = self:GetCaster():GetAbsOrigin() - unit_location
        vector_distance.z = 0
        local distance = (vector_distance):Length2D()
        local direction = (vector_distance):Normalized()
        self:GetParent():SetForwardVector(direction)

        local pull = 6
        if distance > 6 then
            self:GetParent():SetAbsOrigin(unit_location + direction * pull)
        else
            self:GetParent():SetAbsOrigin(unit_location)
        end
    end
end

function modifier_olyasha_love:OnDestroy()
    if not IsServer() then return end
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
end


function modifier_olyasha_love:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

function modifier_olyasha_love:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_olyasha_love:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_olyasha_love:GetOverrideAnimation( params )
    return ACT_DOTA_FLAIL
end

function modifier_olyasha_love:GetEffectName()
    return "particles/olyasha/olyasha_love_heart_debuff.vpcf"
end

function modifier_olyasha_love:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end