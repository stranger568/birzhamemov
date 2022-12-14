LinkLuaModifier( "modifier_Bukin_HatTrickLeatherBall_scepter", "abilities/heroes/bukin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Bukin_HatTrickLeatherBall_thinker", "abilities/heroes/bukin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Bukin_HatTrickLeatherBall_debuff", "abilities/heroes/bukin.lua", LUA_MODIFIER_MOTION_NONE )

Bukin_HatTrickLeatherBall = class({})

function Bukin_HatTrickLeatherBall:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Bukin_HatTrickLeatherBall:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Bukin_HatTrickLeatherBall:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Bukin_HatTrickLeatherBall:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_birzha_bukin_8") then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED
    end
    return DOTA_ABILITY_BEHAVIOR_POINT
end

function Bukin_HatTrickLeatherBall:GetCastPoint()
    if self:GetCaster():HasTalent("special_bonus_birzha_bukin_8") then 
        return 0
    else 
        return self.BaseClass.GetCastPoint( self )
    end
end

function Bukin_HatTrickLeatherBall:GetCastAnimation()
    if self:GetCaster():HasTalent("special_bonus_birzha_bukin_8") then 
        return 
    else 
        return ACT_DOTA_CAST_ABILITY_1
    end
end

function Bukin_HatTrickLeatherBall:GetChannelTime()
    if self:GetCaster():HasTalent("special_bonus_birzha_bukin_8") then
        return self:GetSpecialValueFor("channel_time_talent")
    end
    return self.BaseClass.GetChannelTime(self)
end

function Bukin_HatTrickLeatherBall:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local direction = (target_loc - caster_loc):Normalized()

    if target_loc == caster_loc then
        direction = caster:GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end

    self.direction = direction

    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_bukin_1")

    if self:GetCaster():HasTalent("special_bonus_birzha_bukin_8") then
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.1)
        self:GetCaster():SetForwardVector( direction )
        self:GetCaster():FaceTowards(target_loc)
        return
    end

    self:LaunchBall(damage)
end

function Bukin_HatTrickLeatherBall:OnChannelFinish(Interrupt)
    if not IsServer() then return end
    if not self:GetCaster():IsAlive() then return end

    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.3)
    self:GetCaster():Stop()

    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_bukin_1")

    if not Interrupt then
        damage = damage * self:GetSpecialValueFor("damage_multiple_talent")
    end

    self:LaunchBall(damage)
end

function Bukin_HatTrickLeatherBall:LaunchBall(damage)
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/bukin/bukin_ball.vpcf",
        vSpawnOrigin        = self:GetCaster():GetAbsOrigin(),
        fDistance           = 1800,
        fStartRadius        = 175,
        fEndRadius          = 175,
        Source              = self:GetCaster(),
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(self.direction.x,self.direction.y,0) * 1500,
        bProvidesVision     = false,
        ExtraData           = { damage = damage }
    }
    local proj = ProjectileManager:CreateLinearProjectile(projectile)

    if self:GetCaster():HasScepter() then
        local unit = CreateUnitByName("npc_dota_companion", self:GetCaster():GetAbsOrigin(), false, nil, nil, self:GetCaster():GetTeamNumber())
        if unit then
            unit:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("fire_duration_scepter") + 0.5})
            unit:AddNewModifier(self:GetCaster(), self, "modifier_Bukin_HatTrickLeatherBall_scepter", {duration = self:GetSpecialValueFor("fire_duration_scepter") + 0.5, proj = proj})
        end
    end
    self:GetCaster():EmitSound("bukinball")
end

function Bukin_HatTrickLeatherBall:OnProjectileHit_ExtraData(target, location, table)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local knockback_duration = self:GetSpecialValueFor("knockback_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_bukin_2")
    if target then
        target:AddNewModifier( caster, self, "modifier_Bukin_HatTrickLeatherBall_debuff", {duration = knockback_duration * (1 - target:GetStatusResistance())})
        ApplyDamage({victim = target, attacker = caster, ability = self, damage = table.damage, damage_type = DAMAGE_TYPE_MAGICAL})
    end
end

modifier_Bukin_HatTrickLeatherBall_debuff = class({})

function modifier_Bukin_HatTrickLeatherBall_debuff:OnCreated()
    if not IsServer() then return end
    local knockback =
    {
        knockback_duration = 0.25 * (1 - self:GetParent():GetStatusResistance()),
        duration = 0.25 * (1 - self:GetParent():GetStatusResistance()),
        knockback_distance = 0,
        knockback_height = 50,
    }
    self:GetParent():RemoveModifierByName("modifier_knockback")
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_knockback", knockback)
end

function modifier_Bukin_HatTrickLeatherBall_debuff:CheckState()
    return 
    {
        [MODIFIER_STATE_STUNNED] = true
    }
end

function modifier_Bukin_HatTrickLeatherBall_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_Bukin_HatTrickLeatherBall_debuff:GetOverrideAnimation( params )
    return ACT_DOTA_DISABLED
end

function modifier_Bukin_HatTrickLeatherBall_debuff:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_Bukin_HatTrickLeatherBall_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_Bukin_HatTrickLeatherBall_debuff:OnDestroy()
    if not IsServer() then return end
    if not self:GetParent():IsAlive() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    local modifier = self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_disarmed", {duration = duration * (1 - self:GetParent():GetStatusResistance())})
    if modifier then
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_inner_fire_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
        modifier:AddParticle(particle, false, false, -1, false, true)
    end
end

modifier_Bukin_HatTrickLeatherBall_scepter = class({})

function modifier_Bukin_HatTrickLeatherBall_scepter:IsHidden()
    return true
end

function modifier_Bukin_HatTrickLeatherBall_scepter:IsPurgable()
    return false
end

function modifier_Bukin_HatTrickLeatherBall_scepter:RemoveOnDeath()
    return false
end

function modifier_Bukin_HatTrickLeatherBall_scepter:OnCreated(data)
    if not IsServer() then return end
    self.projectile = data.proj
    self.damage_spots = {}
    self.damaged_enemies    = {}
    self.counter            = 0
    self.think_interval     = 0.1
    self.time_to_tick       = 0.1
    self.count = 0
    local damage = self:GetAbility():GetSpecialValueFor('fire_damage_scepter')
    self.damage_table       = {
        victim          = nil,
        damage          = damage * 0.1,
        damage_type     = DAMAGE_TYPE_MAGICAL,
        damage_flags    = DOTA_DAMAGE_FLAG_NONE,
        attacker        = self:GetCaster(),
        ability         = self:GetAbility()
    }

    self:StartIntervalThink(0.1)
end

function modifier_Bukin_HatTrickLeatherBall_scepter:OnIntervalThink()
    if not IsServer() then return end
    if self.projectile then
        local proj_loc = ProjectileManager:GetLinearProjectileLocation(self.projectile)
        if proj_loc then
            self:GetParent():SetAbsOrigin(proj_loc)
        end
    end
    self.counter    = self.counter + self.think_interval
    if self.count < 11 then
        table.insert(self.damage_spots, self:GetParent():GetAbsOrigin())
    end
    if self.counter >= 0.1 then
        if self.count < 11 then
            self.count = self.count + 1
            local thinker = CreateModifierThinker(self:GetParent(), self:GetAbility(), "modifier_Bukin_HatTrickLeatherBall_thinker", {duration = self:GetRemainingTime()}, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
        end
        for damage_spot = 1, #self.damage_spots do
            self.enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.damage_spots[damage_spot], nil, 75, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
            for _, enemy in pairs(self.enemies) do
                if not self.damaged_enemies[enemy] then
                    self.damage_table.victim = enemy
                    ApplyDamage(self.damage_table)
                    self.damaged_enemies[enemy] = true
                end
            end
        end
        self.counter = 0
        self.damaged_enemies = {}
    end
    if self:GetElapsedTime() < 0.1 then
        self.time_to_tick = 0.4
    else
        self.time_to_tick = 0.5
    end
end

function modifier_Bukin_HatTrickLeatherBall_scepter:CheckState()
    local state = 
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    }

    return state
end

modifier_Bukin_HatTrickLeatherBall_thinker = class({})

function modifier_Bukin_HatTrickLeatherBall_thinker:IsPurgable() return false end

function modifier_Bukin_HatTrickLeatherBall_thinker:OnCreated()
    if not IsServer() then return end
    local firefly = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_burning_army.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl( firefly, 0, self:GetParent():GetAbsOrigin() )
    self:AddParticle(firefly, false, false, -1, false, false)
end

Bukin_Spears = class({})

LinkLuaModifier( "modifier_Bukin_Spears", "abilities/heroes/bukin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Bukin_Spears_shard", "abilities/heroes/bukin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Bukin_Spears_debuff", "abilities/heroes/bukin.lua", LUA_MODIFIER_MOTION_NONE )

function Bukin_Spears:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_PASSIVE
    if self:GetCaster():HasShard() then
        behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return behavior
end

function Bukin_Spears:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Bukin_Spears_shard", {duration = self:GetSpecialValueFor("duration_shard")})
    self:GetCaster():EmitSound("bukin_shard")
end

function Bukin_Spears:GetCooldown(iLevel)
    if self:GetCaster():HasShard() then
        return 20
    end
end

modifier_Bukin_Spears_shard = class({})

function modifier_Bukin_Spears_shard:IsPurgable() return false end

function modifier_Bukin_Spears_shard:GetEffectName()
    return "particles/econ/items/huskar/huskar_2021_immortal/huskar_2021_immortal_burning_spear_debuff.vpcf"
end

function modifier_Bukin_Spears_shard:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_Bukin_Spears = class({})

function Bukin_Spears:GetIntrinsicModifierName()
    return "modifier_Bukin_Spears"
end

function Bukin_Spears:GetProjectileName()
    return "particles/units/heroes/hero_huskar/huskar_burning_spear.vpcf"
end

function modifier_Bukin_Spears:IsHidden()
    return true
end

function modifier_Bukin_Spears:IsPurgable()
    return false
end

function modifier_Bukin_Spears:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK
    }

    return decFuncs
end

function modifier_Bukin_Spears:OnAttack( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end

    if params.attacker:IsIllusion() then return end

    if params.attacker:PassivesDisabled() then return end

    ApplyDamage({ victim = params.attacker, attacker = params.attacker, damage = self:GetAbility():GetSpecialValueFor("health_cost"), damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility(), damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS })

    params.attacker:EmitSound("Hero_Huskar.Burning_Spear.Cast")
end

function modifier_Bukin_Spears:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end

    if self:GetCaster():HasTalent("special_bonus_birzha_bukin_5") then
        if params.attacker:IsIllusion() and not params.attacker:HasModifier("modifier_bukin_clubnogirls") then return end
    else
        if params.attacker:IsIllusion() then return end
    end

    if params.attacker:PassivesDisabled() then return end

    local stack = 1

    if params.attacker:HasModifier("modifier_Bukin_Spears_shard") then
        stack = self:GetAbility():GetSpecialValueFor("multiple_shard")
    end

    local duration = self:GetAbility():GetSpecialValueFor("duration")

    local modifier = params.target:FindModifierByName("modifier_Bukin_Spears_debuff")
    if modifier then
        params.target:AddNewModifier( params.attacker, self:GetAbility(), "modifier_Bukin_Spears_debuff", { duration = duration } )
        modifier:SetStackCount(modifier:GetStackCount() + stack)
    else
        modifier = params.target:AddNewModifier( params.attacker, self:GetAbility(), "modifier_Bukin_Spears_debuff", { duration = duration } )
        modifier:SetStackCount(stack)
    end

    params.target:EmitSound("Hero_Huskar.Burning_Spear")
end

modifier_Bukin_Spears_debuff = class({})

function modifier_Bukin_Spears_debuff:IsPurgable()
    return true
end

function modifier_Bukin_Spears_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink( 1 )
end

function modifier_Bukin_Spears_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_bukin_3")
    local damageTable = { victim = self:GetParent(), attacker = self:GetCaster(), damage = damage * self:GetStackCount(), damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() }
    
    if self:GetCaster():HasTalent("special_bonus_birzha_bukin_6") then
       damageTable.damage_type = DAMAGE_TYPE_PURE
    end

    ApplyDamage( damageTable )
end

function modifier_Bukin_Spears_debuff:GetEffectName()
    return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_Bukin_Spears_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_Bukin_Rage", "abilities/heroes/bukin.lua", LUA_MODIFIER_MOTION_NONE )

Bukin_Rage = class({})

function Bukin_Rage:GetIntrinsicModifierName()
    return "modifier_Bukin_Rage"
end

modifier_Bukin_Rage = class({})

function modifier_Bukin_Rage:IsHidden() return self:GetStackCount() == 0 end
function modifier_Bukin_Rage:IsPurgable() return false end

function modifier_Bukin_Rage:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Bukin_Rage:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_Bukin_Rage:OnIntervalThink()
    if IsServer() then
    
        local caster = self:GetParent()
        local oldStackCount = self:GetStackCount()
        local health_perc = caster:GetHealthPercent()/100
        local newStackCount = 0
        local hurt_health_ceiling = self:GetAbility():GetSpecialValueFor("hurt_health_ceiling")
        local hurt_health_floor = self:GetAbility():GetSpecialValueFor("hurt_health_floor")
        local hurt_health_step = self:GetAbility():GetSpecialValueFor("hurt_health_step")
        local model_size = self:GetAbility():GetSpecialValueFor("model_size_per_stack")
        self.model_scale = 0

        for current_health=hurt_health_ceiling, hurt_health_floor, -hurt_health_step do
            if health_perc <= current_health then

                newStackCount = newStackCount+1
            else
                break
            end
        end
       

        local difference = newStackCount - oldStackCount

        if difference ~= 0 then
            self.model_scale = difference*model_size
            self:SetStackCount( newStackCount )
            self:ForceRefresh()
        end
        
    end
end

function modifier_Bukin_Rage:OnRefresh()
    if IsServer() then
        local StackCount = self:GetStackCount()
        local caster = self:GetParent()
        self:GetParent():CalculateStatBonus(true)
    end
end

function modifier_Bukin_Rage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_MODEL_SCALE 
    }

    return funcs
end

function modifier_Bukin_Rage:GetModifierModelScale()
    return self.model_scale
end

function modifier_Bukin_Rage:GetModifierAttackSpeedBonus_Constant ( params )
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor( "attack_speed_bonus_per_stack" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_bukin_4"))
end

function modifier_Bukin_Rage:GetModifierMoveSpeedBonus_Constant ( params )
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor( "movespeed" )
end

function modifier_Bukin_Rage:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if params.inflictor == nil and not self:GetParent():IsIllusion() and not self:GetParent():PassivesDisabled() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local heal = ((self:GetAbility():GetSpecialValueFor("lifesteal") / 100) * self:GetStackCount()) * params.damage
        self:GetParent():Heal(heal, nil)
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

LinkLuaModifier("modifier_bukin_clubnogirls","abilities/heroes/bukin.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bukin_clubnogirls_thinker","abilities/heroes/bukin.lua",LUA_MODIFIER_MOTION_NONE)

bukin_clubnogirls = class({})

function bukin_clubnogirls:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
end

function bukin_clubnogirls:GetAOERadius()
    if self:GetCaster():HasTalent("special_bonus_birzha_bukin_7") then
        return (self:GetSpecialValueFor("radius") * 2) + 50
    end
    return self:GetSpecialValueFor("radius") + 50
end

function bukin_clubnogirls:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function bukin_clubnogirls:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function bukin_clubnogirls:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function bukin_clubnogirls:OnSpellStart()
    if not IsServer() then return end
    local cursor_pos = self:GetCaster():GetCursorPosition()
    local num = self:GetSpecialValueFor("count")
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetSpecialValueFor("damage") - 100
    local hero_vector = GetGroundPosition(cursor_pos + Vector(0, radius, 0), nil)
    local hero_vector_talent = GetGroundPosition(cursor_pos + Vector(0, radius*2, 0), nil)
    local ability = self
    local caster = self:GetCaster()

    self:GetCaster():EmitSound("bezbab")

    for hero = 1, num do
        Timers:CreateTimer(0.10 * hero, function()
            local t = BirzhaCreateIllusion( caster, caster, {duration=duration - (0.10 * hero),outgoing_damage=damage}, 1, 100, false, false ) 
            for k, v in pairs(t) do
                v:RemoveDonate()
                v:SetAbsOrigin(hero_vector)
                v:AddNewModifier(caster, ability, "modifier_bukin_clubnogirls", {})
            end
            hero_vector = RotatePosition(cursor_pos, QAngle(0, 360 / num, 0), hero_vector)
            hero_vector = GetGroundPosition(hero_vector, nil)
        end)
    end

    if self:GetCaster():HasTalent("special_bonus_birzha_bukin_7") then
        for hero = 1, num do
            Timers:CreateTimer(0.20 * hero, function()
                local t = BirzhaCreateIllusion( caster, caster, {duration=duration - (0.20 * hero),outgoing_damage=damage}, 1, 100, false, false ) 
                for k, v in pairs(t) do
                    v:RemoveDonate()
                    v:SetAbsOrigin(hero_vector_talent)
                    v:AddNewModifier(caster, ability, "modifier_bukin_clubnogirls", {})
                end
                hero_vector_talent = RotatePosition(cursor_pos, QAngle(0, 360 / num, 0), hero_vector_talent)
                hero_vector_talent = GetGroundPosition(hero_vector_talent, nil)
            end)
        end
    end

    if self:GetCaster():HasTalent("special_bonus_birzha_bukin_7") then
        CreateModifierThinker(self:GetCaster(), self, "modifier_bukin_clubnogirls_thinker", {duration = duration, radius = radius * 2}, cursor_pos, self:GetCaster():GetTeamNumber(), false)
    else
        CreateModifierThinker(self:GetCaster(), self, "modifier_bukin_clubnogirls_thinker", {duration = duration, radius = radius}, cursor_pos, self:GetCaster():GetTeamNumber(), false)
    end
end

modifier_bukin_clubnogirls_thinker = class({})

function modifier_bukin_clubnogirls_thinker:OnCreated(kv)
    if not IsServer() then return end
    local radius = kv.radius
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_furarmy_ring.vpcf", PATTACH_POINT, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius+50,1,1))
    self:AddParticle(particle, false, false, -1, false, false)
end

modifier_bukin_clubnogirls = class({})

function modifier_bukin_clubnogirls:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_bukin_clubnogirls:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():GetAggroTarget() == nil then
        local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self:GetParent():Script_GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
        if #enemies > 0 then
            for enemy = 1, #enemies do
                if enemies[enemy] and enemies[enemy]:IsAlive() and not enemies[enemy]:IsAttackImmune() and not enemies[enemy]:IsInvulnerable() then
                    self:GetParent():MoveToTargetToAttack(enemies[enemy])
                    self:GetParent():SetAggroTarget(enemies[enemy])
                    break
                end
            end
        end
    end
end

function modifier_bukin_clubnogirls:IsHidden()
    return true
end

function modifier_bukin_clubnogirls:CheckState()
    local state = 
    {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_CANNOT_MISS] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
    }
    return state
end

function modifier_bukin_clubnogirls:GetPriority() return 100000000 end
function modifier_bukin_clubnogirls:HeroEffectPriority() return 100000000 end
function modifier_bukin_clubnogirls:StatusEffectPriority() return 100000000 end

function modifier_bukin_clubnogirls:GetStatusEffectName()
    return "particles/status_fx/status_effect_phantom_lancer_illusion.vpcf"
end
