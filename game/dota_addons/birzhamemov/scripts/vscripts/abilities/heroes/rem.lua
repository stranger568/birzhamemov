LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_jump_strike_buff", "abilities/heroes/rem.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_jump_strike", "abilities/heroes/rem.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Rem_StrikeJump = class({})

function Rem_StrikeJump:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function Rem_StrikeJump:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Rem_StrikeJump:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Rem_StrikeJump:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Rem_StrikeJump:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_jump_strike_buff", {})
    self:GetCaster():EmitSound("Hero_Batrider.Firefly.Cast")
    local casterLoc = self:GetCaster():GetAbsOrigin()
    local point = self:GetCursorPosition() 
    local speed = 1800
    local destroy_radius = 100
    local vision_radius = 1000
    local distance = 0
    local intervals_per_second = speed / destroy_radius
    local forwardVec = ( point - casterLoc ):Normalized()
    self.position = self:GetCaster():GetAbsOrigin()
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
    self:GetCaster():SetDayTimeVisionRange( vision_radius )
    self:GetCaster():SetNightTimeVisionRange( vision_radius )
    Timers:CreateTimer( function()
        distance = distance + speed / intervals_per_second
        self.position = self.position + forwardVec * ( speed / intervals_per_second )
        FindClearSpaceForUnit( self:GetCaster(), self.position, false )
        if ( point - self.position ):Length2D() <= speed / intervals_per_second then
            self:GetCaster():RemoveModifierByName("modifier_jump_strike_buff")
            return nil
        else
            return 1 / intervals_per_second
        end
    end)
end

modifier_jump_strike_buff = class({})

function modifier_jump_strike_buff:IsHidden()
    return true
end

function modifier_jump_strike_buff:CheckState()
    local funcs = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return funcs
end

function modifier_jump_strike_buff:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_jump_strike", {duration = 0.5})
end

modifier_jump_strike = class({})

function modifier_jump_strike:IsHidden()
    return true
end

function modifier_jump_strike:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_EarthShaker.EchoSlam")
    local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_rem_2")
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    local bashpoint = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 450
    local particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_egset.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, Vector(bashpoint.x,bashpoint.y,bashpoint.z))
    ParticleManager:SetParticleControl(particle, 1, Vector(250,250,bashpoint.z))
    ParticleManager:SetParticleControl(particle, 2, Vector(bashpoint.x,bashpoint.y,bashpoint.z))
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), bashpoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

    if self:GetCaster():HasTalent("special_bonus_birzha_rem_1") then
        units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), bashpoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    end

    for i,enemy in ipairs(units) do
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned_purge", {duration = stun_duration})
    end 
end

LinkLuaModifier( "modifier_rem_morgenshtern", "abilities/heroes/rem.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

rem_morgenshtern = class({})

function rem_morgenshtern:GetAOERadius()
    return self:GetSpecialValueFor( "latch_radius" )
end

function rem_morgenshtern:GetCooldown(level)
    if self:GetCaster():HasScepter() then 
        return self:GetSpecialValueFor("cooldown_scepter")
    else
        return self.BaseClass.GetCooldown(self, level)
    end
end

function rem_morgenshtern:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function rem_morgenshtern:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function rem_morgenshtern:OnAbilityPhaseStart()
    if not IsServer() then return end
    
    self:GetCaster():StartGesture(ACT_DOTA_RATTLETRAP_HOOKSHOT_START)
    
    return true
end

function rem_morgenshtern:OnSpellStart()
    if not IsServer() then return end

    if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
        self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
    end

    self:GetCaster():EmitSound("Hero_Rattletrap.Hookshot.Fire")
    self.direction = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized()
    self.direction.z = 0
    
    local hookshot_duration = (self:GetSpecialValueFor("cast_range") / self:GetSpecialValueFor("speed")) * 2
    local hookshot_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControlEnt(hookshot_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(hookshot_particle, 1, self:GetCaster():GetAbsOrigin() + self.direction * self:GetSpecialValueFor("cast_range"))
    ParticleManager:SetParticleControl(hookshot_particle, 2, Vector(self:GetSpecialValueFor("speed"), 0, 0))
    ParticleManager:SetParticleControl(hookshot_particle, 3, Vector(hookshot_duration, 0, 0))
    
    local linear_projectile = {
        Ability             = self,
        vSpawnOrigin        = self:GetCaster():GetAbsOrigin(),
        fDistance           = self:GetSpecialValueFor("cast_range"),
        fStartRadius        = self:GetSpecialValueFor("latch_radius"),
        fEndRadius          = self:GetSpecialValueFor("latch_radius"),
        Source              = self:GetCaster(),
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit        = true,
        vVelocity           = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("speed"),
        bProvidesVision     = false,
        ExtraData           = {hookshot_particle = hookshot_particle}
    }
    self.razor_wind = {}
    self.projectile = ProjectileManager:CreateLinearProjectile(linear_projectile)   
end


function rem_morgenshtern:OnProjectileThink_ExtraData(vLocation, ExtraData)
    if not IsServer() then return end
    
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), vLocation, nil, self:GetSpecialValueFor("razor_wind_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    
    for _, enemy in pairs(enemies) do
        local distance_vector = enemy:GetAbsOrigin() - vLocation
        
        if distance_vector:Length2D() > self:GetSpecialValueFor("latch_radius") and math.abs(math.abs(AngleDiff(VectorToAngles(distance_vector).y, VectorToAngles(self.direction).y)) - 90) <= 30 and not self.razor_wind[enemy:GetEntityIndex()] then
            enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = 0.1}):SetDuration(0.1, true)
            
            local damageTable = {
                victim          = enemy,
                damage          = self:GetSpecialValueFor("damage"),
                damage_type     = DAMAGE_TYPE_MAGICAL,
                damage_flags    = DOTA_DAMAGE_FLAG_NONE,
                attacker        = self:GetCaster(),
                ability         = self
            }
        
            ApplyDamage(damageTable)
            self.razor_wind[enemy:GetEntityIndex()] = true
        end
    end
end

function rem_morgenshtern:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if not IsServer() then return end
    if hTarget then
        if hTarget ~= self:GetCaster() and not hTarget:IsCourier() then
            self:GetCaster():StopSound("Hero_Rattletrap.Hookshot.Fire")
            hTarget:EmitSound("Hero_Rattletrap.Hookshot.Impact")
            if (self:GetCaster():GetAbsOrigin() - hTarget:GetAbsOrigin()):Length2D() > self:GetSpecialValueFor("latch_radius") then
                self:GetCaster():EmitSound("Hero_Rattletrap.Hookshot.Retract")
            end
            ParticleManager:SetParticleControlEnt(ExtraData.hookshot_particle, 1, hTarget, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rem_morgenshtern", 
            {
                duration        = (self:GetSpecialValueFor("cast_range") + self:GetCaster():GetCastRangeBonus()) / self:GetSpecialValueFor("speed"),
                latch_radius    = self:GetSpecialValueFor("latch_radius"),
                stun_radius     = self:GetSpecialValueFor("stun_radius"),
                stun_duration   = self:GetSpecialValueFor("duration"),
                speed           = self:GetSpecialValueFor("speed"),
                damage          = self:GetSpecialValueFor("damage"),
                ent_index       = hTarget:GetEntityIndex(),
                particle        = ExtraData.hookshot_particle
            })
            ProjectileManager:DestroyLinearProjectile(self.projectile)
        
            if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
                if not hTarget:IsAlive() then return end
                hTarget:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = self:GetSpecialValueFor("duration")}):SetDuration(self:GetSpecialValueFor("duration"), true)
            end
        end
    else
        ParticleManager:SetParticleControl(ExtraData.hookshot_particle, 1, self:GetCaster():GetAbsOrigin())
    end
end

modifier_rem_morgenshtern = class({})

function modifier_rem_morgenshtern:IgnoreTenacity() return true end
function modifier_rem_morgenshtern:IsPurgable()     return false end
function modifier_rem_morgenshtern:IsHidden()     return true end

function modifier_rem_morgenshtern:OnCreated(params)
    if not IsServer() then return end
    
    self.duration       = params.duration
    self.latch_radius   = params.latch_radius
    self.stun_radius    = params.stun_radius
    self.stun_duration  = params.stun_duration
    self.speed          = params.speed
    self.damage         = params.damage
    self.particle       = params.particle
    self.target         = EntIndexToHScript(params.ent_index)
    self.distance           = (self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
    self.enemies_hit    = {}
    
    if self:ApplyHorizontalMotionController() == false or (self:GetCaster():GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D() <= self.latch_radius then 
        self:Destroy()
        return
    end
end

function modifier_rem_morgenshtern:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
    self.distance  = (self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
    me:SetOrigin( me:GetOrigin() + self.distance * self.speed * dt )
    if (self:GetCaster():GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D() <= self.latch_radius then
        FindClearSpaceForUnit(self:GetParent(), self.target:GetAbsOrigin() - self.distance * (self:GetParent():GetHullRadius() + self.target:GetHullRadius()), true)
        self:Destroy()
    end
end

function modifier_rem_morgenshtern:OnHorizontalMotionInterrupted()
    self:Destroy()
end

function modifier_rem_morgenshtern:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController( self )
    self:GetCaster():StopSound("Hero_Rattletrap.Hookshot.Retract")
    self:GetCaster():EmitSound("Hero_Rattletrap.Hookshot.Damage")
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
    self:GetCaster():StartGesture(ACT_DOTA_RATTLETRAP_HOOKSHOT_END)
        local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.stun_radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    
    for _, unit in pairs(units) do
        if not unit:IsCourier() then
            if unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
                unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned_purge", {duration = self.stun_duration})
                if not unit:IsMagicImmune() then
                    local damageTable = {
                        victim          = unit,
                        damage          = self.damage,
                        damage_type     = DAMAGE_TYPE_MAGICAL,
                        damage_flags    = DOTA_DAMAGE_FLAG_NONE,
                        attacker        = self:GetCaster(),
                        ability         = self:GetAbility()
                    }
                    print("WTF GDE DAMGE", self.damage)
                    ApplyDamage(damageTable)
                end
                self.enemies_hit[unit:GetEntityIndex()] = true
            end
        end
    end
end

function modifier_rem_morgenshtern:CheckState()
    local state = {}
    if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() or self:GetParent() == self:GetCaster() then
        state = {
            [MODIFIER_STATE_SILENCED] = true,
            [MODIFIER_STATE_DISARMED] = true,
        }
    end
    return state
end

function modifier_rem_morgenshtern:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
    return funcs
end

function modifier_rem_morgenshtern:GetOverrideAnimation()
     return ACT_DOTA_RATTLETRAP_HOOKSHOT_LOOP
end

LinkLuaModifier("modifier_rem_bigboobs", "abilities/heroes/rem", LUA_MODIFIER_MOTION_NONE)

Rem_BigBoobs = class({}) 

function Rem_BigBoobs:GetIntrinsicModifierName()
    return "modifier_rem_bigboobs"
end

modifier_rem_bigboobs = class({})

function modifier_rem_bigboobs:IsHidden()
    return true
end

function modifier_rem_bigboobs:IsPurgable()
    return false
end

function modifier_rem_bigboobs:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
    }

    return decFuncs
end

function modifier_rem_bigboobs:GetModifierBaseDamageOutgoing_Percentage()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_damage_pct')
end

LinkLuaModifier( "modifier_DemonicForm", "abilities/heroes/rem.lua", LUA_MODIFIER_MOTION_NONE )

Rem_DemonicForm = class({})

function Rem_DemonicForm:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Rem_DemonicForm:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Rem_DemonicForm:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor('duration')
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_DemonicForm", {duration = duration})
    self:GetCaster():EmitSound("animerem")
end

modifier_DemonicForm = class({})

function modifier_DemonicForm:IsPurgable()  return false end
function modifier_DemonicForm:AllowIllusionDuplicate() return true end

function modifier_DemonicForm:OnCreated()
    if not IsServer() then return end
    self:GetAbility():SetActivated(false)
    self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end

function modifier_DemonicForm:OnDestroy()
    if not IsServer() then return end 
    self:GetCaster():StopSound("animerem")
    self:GetAbility():SetActivated(true)
    self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
end


function modifier_DemonicForm:CheckState()
    return {[MODIFIER_STATE_SILENCED] = true,}
end

function modifier_DemonicForm:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
    }

    return decFuncs
end

function modifier_DemonicForm:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_health')
end

function modifier_DemonicForm:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor('base_attack_time')
end

function modifier_DemonicForm:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor('bonus_range')
end

function modifier_DemonicForm:GetModifierModelChange()
    return "models/items/warlock/golem/hellsworn_golem/hellsworn_golem.vmdl"
end

function modifier_DemonicForm:GetModifierProjectileName()
    return "particles/units/heroes/hero_visage/visage_familiar_base_attack.vpcf"
end