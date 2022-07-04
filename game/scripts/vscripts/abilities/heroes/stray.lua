LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_stray_rat_poison_debuff", "abilities/heroes/stray", LUA_MODIFIER_MOTION_NONE)


stray_rat_poison = class({})

function stray_rat_poison:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function stray_rat_poison:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function stray_rat_poison:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function stray_rat_poison:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb( self ) then return end
    self:GetCaster():EmitSound("StrayOne")
    self:GetCaster():EmitSound("Hero_Winter_Wyvern.SplinterBlast.Cast")

    local info = {
        EffectName = "particles/stray/stray_rat_poison.vpcf",
        Dodgeable = true,
        Ability = self,
        ProvidesVision = true,
        VisionRadius = 600,
        bVisibleToEnemies = true,
        iMoveSpeed = 1000,
        Source = self:GetCaster(),
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        Target = self:GetCursorTarget(),
        bReplaceExisting = false,
    }
    ProjectileManager:CreateTrackingProjectile(info)
end

function stray_rat_poison:OnProjectileHit(target,_)
    if target ~= nil and target:IsAlive() then
        local duration = self:GetSpecialValueFor( "duration" )
        local damage = self:GetSpecialValueFor( "damage" )

        if self:GetCaster():HasScepter() then
            damage = damage + self:GetCaster():GetIntellect() * self:GetSpecialValueFor("int_multiplier")
        end

        target:AddNewModifier(self:GetCaster(), self, "modifier_stray_rat_poison_debuff", {duration = duration * (1 - target:GetStatusResistance())})
        target:EmitSound("GypsyDebosh")
        ApplyDamage({attacker = self:GetCaster(), victim = target, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
        target:EmitSound("Hero_Winter_Wyvern.SplinterBlast.Target");
    end
end

modifier_stray_rat_poison_debuff = class({})

function modifier_stray_rat_poison_debuff:IsHidden()
    return false
end

function modifier_stray_rat_poison_debuff:IsPurgable()
    return false
end

function modifier_stray_rat_poison_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
    self.slow_hit_particle = ParticleManager:CreateParticle("particles/stray/stray_rat_poison_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent());
    ParticleManager:SetParticleControl(self.slow_hit_particle, 0, self:GetParent():GetAbsOrigin());
end

function modifier_stray_rat_poison_debuff:OnDestroy() 
    if IsServer() then 
        if self.slow_hit_particle then
            ParticleManager:DestroyParticle(self.slow_hit_particle, false)
        end
    end
end

function modifier_stray_rat_poison_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage_think = self:GetAbility():GetSpecialValueFor( "damage_think" )
    if self:GetParent():HasModifier("modifier_stray_shveps_debuff") then
        damage_think = damage_think + 100
    end
    ApplyDamage({attacker = self:GetCaster(), victim = self:GetParent(), ability = self:GetAbility(), damage = damage_think, damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_stray_rat_poison_debuff:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
    return decFuncs
end

function modifier_stray_rat_poison_debuff:GetModifierMoveSpeedBonus_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "move_slow" )
end

LinkLuaModifier("modifier_stray_rat", "abilities/heroes/stray.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_stray_rat_damage", "abilities/heroes/stray.lua", LUA_MODIFIER_MOTION_NONE)

stray_rat = class({})

function stray_rat:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function stray_rat:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target) + self:GetCaster():FindTalentValue("special_bonus_birzha_stray_1")
end

function stray_rat:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function stray_rat:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local direction = (point-self:GetCaster():GetOrigin())
    local dist = math.max( math.min( 1000+self:GetCaster():FindTalentValue("special_bonus_birzha_stray_1"), direction:Length2D() ), 200 )
    direction.z = 0
    direction = direction:Normalized()
    local target_pos = GetGroundPosition( self:GetCaster():GetOrigin() + direction*dist, nil )
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_stray_rat", {
        duration    = math.min((point - self:GetCaster():GetAbsOrigin()):Length2D(), self:GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster() )) / 3000,
        x           = point.x,
        y           = point.y,
        z           = point.z
    })
    self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_2, 3 )
    local effect_cast = ParticleManager:CreateParticle(  "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, target_pos )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_VoidSpirit.AstralStep.Start", self:GetCaster() )
    self:GetCaster():EmitSound("StrayTwo")
    EmitSoundOnLocationWithCaster( target_pos, "Hero_VoidSpirit.AstralStep.End", self:GetCaster() )
end

modifier_stray_rat = class({})

function modifier_stray_rat:IsPurgable() return false end
function modifier_stray_rat:IsHidden() return true end
function modifier_stray_rat:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_stray_rat:IgnoreTenacity() return true end
function modifier_stray_rat:IsMotionController() return true end
function modifier_stray_rat:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_stray_rat:IsAura() return true end

function modifier_stray_rat:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_stray_rat:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_stray_rat:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_stray_rat:GetModifierAura()
    return "modifier_stray_rat_damage"
end

function modifier_stray_rat:GetAuraRadius()
    return 150
end

function modifier_stray_rat:GetEffectName()
    return "particles/units/heroes/hero_faceless_void/faceless_void_time_walk.vpcf" end

function modifier_stray_rat:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW end

function modifier_stray_rat:CheckState()
    return {
        [MODIFIER_STATE_STUNNED]            = true,
        [MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true
    }
end

function modifier_stray_rat:OnCreated(params)
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local position = GetGroundPosition(Vector(params.x, params.y, params.z), nil)
        local max_distance = self:GetAbility():GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster() )
        local distance = (caster:GetAbsOrigin() - position):Length2D()
        if distance > max_distance then distance = max_distance end
        self.velocity = 6000
        self.direction = (position - caster:GetAbsOrigin()):Normalized()
        self.distance_traveled = 0
        self.distance = distance
        self.frametime = FrameTime()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_stray_rat:OnIntervalThink()
    if not self:CheckMotionControllers() then
        if not self:IsNull() then
            self:Destroy()
        end
        return nil
    end
    self:HorizontalMotion(self:GetParent(), self.frametime)
end

function modifier_stray_rat:HorizontalMotion( me, dt )
    if IsServer() then
        if self.distance_traveled <= self.distance then
            self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self.direction * self.velocity * math.min(dt, self.distance - self.distance_traveled))
            self.distance_traveled = self.distance_traveled + self.velocity * math.min(dt, self.distance - self.distance_traveled)
        else
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

modifier_stray_rat_damage = class({})

function modifier_stray_rat_damage:IsPurgable() return false end
function modifier_stray_rat_damage:IsHidden() return true end

function modifier_stray_rat_damage:OnCreated()
    if IsServer() then
        local damage = self:GetAbility():GetSpecialValueFor("damage")
        if self:GetCaster():HasScepter() then
            damage = damage + self:GetCaster():GetIntellect() * self:GetAbility():GetSpecialValueFor("int_multiplier")
        end
        local damageTable = {victim = self:GetParent(),
                            attacker = self:GetCaster(),
                            damage = damage,
                            ability = self:GetAbility(),
                            damage_type = DAMAGE_TYPE_MAGICAL,
                            }
        ApplyDamage(damageTable)
        local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end


LinkLuaModifier("modifier_stray_kill_stealer", "abilities/heroes/stray", LUA_MODIFIER_MOTION_NONE)


stray_kill_stealer = class({})

function stray_kill_stealer:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function stray_kill_stealer:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function stray_kill_stealer:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function stray_kill_stealer:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local ability = self
        if target:TriggerSpellAbsorb(self) then return nil end
        caster:EmitSound("Hero_Necrolyte.ReapersScythe.Cast")
        target:EmitSound("Hero_Necrolyte.ReapersScythe.Target")
        local stun_duration = self:GetSpecialValueFor("duration")
        target:AddNewModifier(caster, self, "modifier_stray_kill_stealer", {duration = stun_duration})
        if self:GetCaster():HasShard() then
            Timers:CreateTimer(0.25, function()
                target:AddNewModifier(caster, ability, "modifier_stray_kill_stealer", {duration = stun_duration})
            end)
        end
    end
end

modifier_stray_kill_stealer = class({})

function modifier_stray_kill_stealer:IsPurgable() return false end
function modifier_stray_kill_stealer:IsHidden() return true end

function modifier_stray_kill_stealer:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_stray_kill_stealer:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local target = self:GetParent()
        self.ability = self:GetAbility()
        self.damage = self.ability:GetSpecialValueFor("damage")
        self.damage_per_health = self.ability:GetSpecialValueFor("damage_per_health") + self:GetCaster():FindTalentValue("special_bonus_birzha_stray_2")

        local stun_fx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_stunned.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
        self:AddParticle(stun_fx, false, false, -1, false, false)
        local scythe_fx = ParticleManager:CreateParticle("particles/stray/stray_thirt.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControlEnt(scythe_fx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(scythe_fx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(scythe_fx, 60, Vector(252,1,1));
        ParticleManager:ReleaseParticleIndex(scythe_fx)
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_stray_kill_stealer:OnRefresh()
    if IsServer() then
        local caster = self:GetCaster()
        local target = self:GetParent()
        self.ability = self:GetAbility()
        self.damage = self.ability:GetSpecialValueFor("damage")
        self.damage_per_health = self.ability:GetSpecialValueFor("damage_per_health")

        local stun_fx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_stunned.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
        self:AddParticle(stun_fx, false, false, -1, false, false)
        local scythe_fx = ParticleManager:CreateParticle("particles/stray/stray_thirt.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControlEnt(scythe_fx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(scythe_fx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(scythe_fx, 60, Vector(252,1,1));
        ParticleManager:ReleaseParticleIndex(scythe_fx)
    end
end

function modifier_stray_kill_stealer:OnIntervalThink()
    if IsServer() then
        local health_enemy = self:GetParent():GetHealth()
        local max_health_enemy = self:GetParent():GetMaxHealth() * self.damage_per_health / 100
        if health_enemy <= max_health_enemy then
            self.die = true
        else
            self.die = false
        end
    end
end

function modifier_stray_kill_stealer:GetEffectName()
    return "particles/stray/rat_effect.vpcf"
end

function modifier_stray_kill_stealer:StatusEffectPriority()
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_stray_kill_stealer:GetPriority()
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_stray_kill_stealer:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_stray_kill_stealer:CheckState()
    local state =
        {
            [MODIFIER_STATE_STUNNED] = true
        }
    return state
end

function modifier_stray_kill_stealer:OnDestroy()
    if IsServer() then
        local caster = self:GetCaster()
        local target = self:GetParent()
        target:AddNewModifier(caster, self:GetAbility(), "modifier_birzha_stunned", {duration=FrameTime()})
        if target:IsAlive() and self.ability and self.die then
            local actually_dmg = ApplyDamage({attacker = caster, victim = target, ability = self.ability, damage = 100000, damage_type = DAMAGE_TYPE_PURE})
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, actually_dmg, nil)
            self:GetCaster():EmitSound("StrayProc")
            return
        end
        if target:IsAlive() and self.ability then
            local actually_dmg = ApplyDamage({attacker = caster, victim = target, ability = self.ability, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, actually_dmg, nil)
            self:GetCaster():EmitSound("StrayFail")
        end
    end
end



















LinkLuaModifier("modifier_stray_donate_music", "abilities/heroes/stray", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_donate_music_two", "abilities/heroes/stray", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_donate_music_three", "abilities/heroes/stray", LUA_MODIFIER_MOTION_NONE)

stray_donate_music = class({})

function stray_donate_music:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function stray_donate_music:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function stray_donate_music:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")

    local modifiers = {
        "modifier_stray_donate_music",
        "modifier_stray_donate_music_two",
        "modifier_stray_donate_music_three",
    }

    self:GetCaster():RemoveModifierByName("modifier_stray_donate_music")
    self:GetCaster():RemoveModifierByName("modifier_stray_donate_music_two")
    self:GetCaster():RemoveModifierByName("modifier_stray_donate_music_three")
    if self:GetCaster():HasTalent("special_bonus_birzha_stray_3") then
        self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_stray_donate_music", { duration = duration } )
        self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_stray_donate_music_two", { duration = duration } )
        self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_stray_donate_music_three", { duration = duration } )
        if self:GetCaster():HasTalent("special_bonus_birzha_stray_3") then
            self:GetCaster():EmitSound("StrayWow")
        end
    else
        local modifier_active = modifiers[RandomInt(1, #modifiers)]
        self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, modifier_active, { duration = duration } )
    end  
end

modifier_stray_donate_music = class({})

function modifier_stray_donate_music:IsPurgable() return false end
function modifier_stray_donate_music:IsHidden() return false end

function modifier_stray_donate_music:OnCreated()
    self.radius = 200
    self.interval = 0.5
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_Rattletrap.Battery_Assault")
    if not self:GetCaster():HasTalent("special_bonus_birzha_stray_3") then
        self:GetParent():EmitSound("StrayUltimateone")
    end
    self:OnIntervalThink()
    self:StartIntervalThink(self.interval)
end

function modifier_stray_donate_music:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damageone")
    self:GetParent():EmitSound("Hero_Rattletrap.Battery_Assault_Launch")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_battery_assault.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:ReleaseParticleIndex(particle)
    local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_battery_shrapnel.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
    if #enemies >= 1 then
        enemies[1]:EmitSound("Hero_Rattletrap.Battery_Assault_Impact")
        ParticleManager:SetParticleControl(particle2, 1, enemies[1]:GetAbsOrigin())
            local damageTable = {
                victim          = enemies[1],
                damage          = damage,
                damage_type     = DAMAGE_TYPE_MAGICAL,
                damage_flags    = DOTA_DAMAGE_FLAG_NONE,
                attacker        = self:GetCaster(),
                ability         = self:GetAbility()
            }

            ApplyDamage(damageTable)
        
            enemies[1]:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = 0.1})
    else
        ParticleManager:SetParticleControl(particle2, 1, self:GetParent():GetAbsOrigin() + RandomVector(RandomInt(0, 128)))
    end
    
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_stray_donate_music:OnDestroy()
    if not IsServer() then return end
    
    self:GetParent():StopSound("Hero_Rattletrap.Battery_Assault")
    self:GetParent():StopSound("StrayUltimateone")
    if self:GetCaster():HasTalent("special_bonus_birzha_stray_3") then
        self:GetCaster():StopSound("StrayWow")
    end
end

function modifier_stray_donate_music:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,}
    return decFuncs
end

function modifier_stray_donate_music:GetModifierStatusResistanceStacking( params )
    return self:GetAbility():GetSpecialValueFor( "resistone" )
end


modifier_stray_donate_music_two = class({})

function modifier_stray_donate_music_two:IsPurgable() return false end
function modifier_stray_donate_music_two:IsHidden() return false end

function modifier_stray_donate_music_two:OnCreated()
    if not IsServer() then return end
    if not self:GetCaster():HasTalent("special_bonus_birzha_stray_3") then
        self:GetParent():EmitSound("StrayUltimatetwo")
    end
end

function modifier_stray_donate_music_two:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT

    }
end

function modifier_stray_donate_music_two:OnAttackLanded( keys )
    if IsServer() then
        local attacker = self:GetParent()

        if attacker ~= keys.attacker then
            return
        end

        if attacker:IsIllusion() then
            return
        end

        local target = keys.target
        if attacker:GetTeam() == target:GetTeam() then
            return
        end 
        if target:IsOther() then
            return nil
        end

        local duration = self:GetAbility():GetSpecialValueFor("bashduration")
        local chance = self:GetAbility():GetSpecialValueFor("bashchance")
        local random = RandomInt(1, 100)

        if random <= chance then    
            target:AddNewModifier(attacker, nil, "modifier_birzha_bashed", {duration = duration})
        end
    end
end

function modifier_stray_donate_music_two:GetModifierConstantHealthRegen( params )
    return self:GetAbility():GetSpecialValueFor( "healthregen" )
end

function modifier_stray_donate_music_two:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("StrayUltimatetwo")
    if self:GetCaster():HasTalent("special_bonus_birzha_stray_3") then
        self:GetCaster():StopSound("StrayWow")
    end
end



modifier_stray_donate_music_three = class({})

function modifier_stray_donate_music_three:IsPurgable() return false end
function modifier_stray_donate_music_three:IsHidden() return false end

function modifier_stray_donate_music_three:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(0)
    if not self:GetCaster():HasTalent("special_bonus_birzha_stray_3") then
        self:GetParent():EmitSound("StrayUltimatethree")
    end
end


function modifier_stray_donate_music_three:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE

    }

    return funcs
end

function modifier_stray_donate_music_three:GetModifierPreAttack_CriticalStrike( params )
    local stack_count = self:GetAbility():GetSpecialValueFor("stacks")
    local crit = self:GetAbility():GetSpecialValueFor("critical")
    if not IsServer() then return end
    if params.target:IsOther() then
        return nil
    end

    if self:GetStackCount() >= stack_count then
        self:SetStackCount(0)
        return crit
    end

    self:SetStackCount(self:GetStackCount() + 1)
    return 0
end

function modifier_stray_donate_music_three:GetModifierMoveSpeedBonus_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "bonusmovespeed" )
end

function modifier_stray_donate_music_three:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("StrayUltimatethree")
    if self:GetCaster():HasTalent("special_bonus_birzha_stray_3") then
        self:GetCaster():StopSound("StrayWow")
    end
end






LinkLuaModifier("modifier_stray_shveps_debuff", "abilities/heroes/stray", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_shveps_buff", "abilities/heroes/stray", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_shveps_thinker", "abilities/heroes/stray", LUA_MODIFIER_MOTION_NONE)

stray_shveps = class({})

function stray_shveps:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function stray_shveps:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function stray_shveps:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function stray_shveps:OnSpellStart()
    if not IsServer() then return end
    CreateModifierThinker(
        self:GetCaster(), -- player source
        self, -- ability source
        "modifier_stray_shveps_thinker", -- modifier name
        { duration = self:GetSpecialValueFor("duration") }, -- kv
        self:GetCursorPosition(),
        self:GetCaster():GetTeamNumber(),
        false
    )
    self:GetCaster():EmitSound("stray_scepter")
end

modifier_stray_shveps_thinker = class({})

function modifier_stray_shveps_thinker:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    if not IsServer() then return end
    self:StartIntervalThink( 0.5 )
    self:PlayEffects()
    EmitSoundOn("stray_shveps", self:GetParent())
end

function modifier_stray_shveps_thinker:OnDestroy( kv )
    if not IsServer() then return end
    StopSoundOn("stray_shveps", self:GetParent())
end

function modifier_stray_shveps_thinker:IsAura()
    return true
end

function modifier_stray_shveps_thinker:GetModifierAura()
    return "modifier_stray_shveps_buff"
end

function modifier_stray_shveps_thinker:GetAuraRadius()
    return self.radius
end

function modifier_stray_shveps_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_stray_shveps_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_stray_shveps_thinker:GetAuraSearchFlags()
    return 0
end

function modifier_stray_shveps_thinker:OnIntervalThink()
    if not IsServer() then return end
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
    for _, enemy in pairs(enemies) do
        if  not enemy:HasModifier("modifier_stray_shveps_debuff") or enemy:HasModifier("modifier_stray_rat_poison_debuff") then
            enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stray_shveps_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration")})
        end
    end   
end

modifier_stray_shveps_debuff = class({})

function modifier_stray_shveps_debuff:OnCreated( kv )
    local damage = self:GetAbility():GetSpecialValueFor( "damage" )
    self.magic_resist = self:GetAbility():GetSpecialValueFor( "magic_resistance" )
    if not IsServer() then return end
    self.damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
    }
    EmitSoundOn("stray_shveps", self:GetParent())
    self:StartIntervalThink( 0.5 )
end

function modifier_stray_shveps_debuff:OnRefresh( kv )
    local damage = self:GetAbility():GetSpecialValueFor( "damage" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.magic_resist = self:GetAbility():GetSpecialValueFor( "magic_resistance" )
end

function modifier_stray_shveps_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }

    return funcs
end

function modifier_stray_shveps_debuff:GetModifierMagicalResistanceBonus()
    return self.magic_resist
end

function modifier_stray_shveps_debuff:OnIntervalThink()
    ApplyDamage( self.damageTable )
end

function modifier_stray_shveps_debuff:GetEffectName()
    return "particles/stray/stray_shveps_debuff.vpcf"
end

function modifier_stray_shveps_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_stray_shveps_thinker:PlayEffects()
    local effect_cast = ParticleManager:CreateParticle( "particles/stray/stray_shveps_effect.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 1, 1 ) )
    self:AddParticle( effect_cast, false, false, -1, false, false  )
end

modifier_stray_shveps_buff = class({})

function modifier_stray_shveps_buff:IsHidden() return true end

function modifier_stray_shveps_buff:CheckState()
    if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then return end
    return {
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_stray_shveps_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end


function modifier_stray_shveps_buff:GetModifierConstantHealthRegen()
    if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then return end
    return self:GetAbility():GetSpecialValueFor("health_regeneration")
end
