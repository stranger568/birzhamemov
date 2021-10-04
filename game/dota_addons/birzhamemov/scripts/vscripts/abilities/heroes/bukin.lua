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

function Bukin_HatTrickLeatherBall:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,caster)
    local direction = (target_loc - caster_loc):Normalized()
    if target_loc == caster_loc then
        direction = caster:GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/bukin/bukin_ball.vpcf",
        vSpawnOrigin        = caster_loc,
        fDistance           = 3200,
        fStartRadius        = 175,
        fEndRadius          = 175,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 1500,
        bProvidesVision     = false,
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    caster:EmitSound("bukinball")
end

function Bukin_HatTrickLeatherBall:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor('damage')
    local duration = self:GetSpecialValueFor('duration')
    local knockback_duration = self:GetSpecialValueFor('knockback_duration')
    if target then
        target:AddNewModifier( caster, self, "modifier_disarmed", {duration = duration * (1 - target:GetStatusResistance())})
        ApplyDamage({victim = target, attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
        local knockback =
        {
            knockback_duration = knockback_duration,
            duration = knockback_duration,
            knockback_distance = 0,
            knockback_height = 50,
        }
        target:RemoveModifierByName("modifier_knockback")
        target:AddNewModifier(caster, self, "modifier_knockback", knockback)
    end
end

Bukin_Spears = class({})

LinkLuaModifier( "modifier_Bukin_Spears", "abilities/heroes/bukin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Bukin_Spears_debuff", "abilities/heroes/bukin.lua", LUA_MODIFIER_MOTION_NONE )

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
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if target:IsOther() then
            return nil
        end
        if target:IsBoss() then return end
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        local damageTable = {
            victim = self:GetCaster(),
            attacker = self:GetCaster(),
            damage = self:GetAbility():GetSpecialValueFor("health_cost"),
            damage_type = DAMAGE_TYPE_PURE,
            ability = self,
            damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
        }
        ApplyDamage(damageTable)
        parent:EmitSound("Hero_Huskar.Burning_Spear.Cast")
    end
end

function modifier_Bukin_Spears:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if target:IsOther() then
            return nil
        end
        if target:IsBoss() then return end
        if target:HasModifier("modifier_Bukin_Spears_debuff") then
           target:FindModifierByName("modifier_Bukin_Spears_debuff"):IncrementStackCount()
           target:FindModifierByName("modifier_Bukin_Spears_debuff"):SetDuration(duration, true)
        else
            target:AddNewModifier( parent, self:GetAbility(), "modifier_Bukin_Spears_debuff", { duration = duration } )
        end
        target:EmitSound("Hero_Huskar.Burning_Spear")
    end
end

modifier_Bukin_Spears_debuff = class({})

function modifier_Bukin_Spears_debuff:IsPurgable()
    return true
end

function modifier_Bukin_Spears_debuff:OnCreated()
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_bukin_1")
    self:IncrementStackCount()
    self.damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    }
    if self:GetCaster():HasTalent("special_bonus_birzha_bukin_3") then
        self.damageTable.damage_type = DAMAGE_TYPE_PURE
    end
    self:StartIntervalThink( 1 )
end

function modifier_Bukin_Spears_debuff:OnIntervalThink()
    self.damageTable.damage = self:GetStackCount() * self.damage
    ApplyDamage( self.damageTable )
end

function modifier_Bukin_Spears_debuff:GetEffectName()
    return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_Bukin_Spears_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

Bukin_Rage = class({})

LinkLuaModifier( "modifier_Bukin_Rage", "abilities/heroes/bukin.lua", LUA_MODIFIER_MOTION_NONE )

function Bukin_Rage:GetIntrinsicModifierName()
    return "modifier_Bukin_Rage"
end

modifier_Bukin_Rage = class({})

function modifier_Bukin_Rage:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Bukin_Rage:OnCreated()
    self.attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus_per_stack" )
    self.movespeed = self:GetAbility():GetSpecialValueFor( "movespeed" )
    if IsServer() then
        self:SetStackCount( 1 )
        self:GetParent():CalculateStatBonus(true)
        self:StartIntervalThink(0.1)
    end
end

function modifier_Bukin_Rage:OnIntervalThink()
    if IsServer() then
    
        local caster = self:GetParent()
        local oldStackCount = self:GetStackCount()
        local health_perc = caster:GetHealthPercent()/100
        local newStackCount = 1
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
    self.attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus_per_stack" )
    self.movespeed = self:GetAbility():GetSpecialValueFor( "movespeed" )
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
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_MODEL_SCALE 
    }

    return funcs
end

function modifier_Bukin_Rage:GetModifierModelScale()
    return self.model_scale
end

function modifier_Bukin_Rage:GetModifierAttackSpeedBonus_Constant ( params )
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self.attack_speed
end

function modifier_Bukin_Rage:GetModifierMoveSpeedBonus_Constant ( params )
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self.movespeed
end

function modifier_Bukin_Rage:OnAttackLanded(kv)
    if IsServer() then
        local attacker = kv.attacker
        local target = kv.target
        local damage = kv.damage
        self.lifesteal = self:GetAbility():GetSpecialValueFor( "lifesteal" ) / 100
        if self:GetParent() == attacker then
            if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
            attacker:Heal(damage * (self:GetStackCount() * self.lifesteal), self:GetAbility())
        end
    end
end

bukin_clubnogirls = class({})
LinkLuaModifier("modifier_bukin_clubnogirls","abilities/heroes/bukin.lua",LUA_MODIFIER_MOTION_NONE)

function bukin_clubnogirls:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
end

function bukin_clubnogirls:GetAOERadius()
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
    local damage = self:GetSpecialValueFor("damage_script")
    local hero_vector = GetGroundPosition(cursor_pos + Vector(0, radius, 0), nil)

    self:GetCaster():EmitSound("bezbab")
    if self.particle ~= nil then
        ParticleManager:DestroyParticle(self.particle,false)
    end
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_furarmy_ring.vpcf", PATTACH_POINT, self:GetCaster())
    ParticleManager:SetParticleControl(self.particle, 0, cursor_pos)
    ParticleManager:SetParticleControl(self.particle, 1, Vector(radius+50,1,1))
    Timers:CreateTimer(duration,function()
        ParticleManager:DestroyParticle(self.particle,false)
    end)

    for hero = 1, num do
        local t = CreateIllusions( self:GetCaster(), self:GetCaster(), {Duration=duration,outgoing_damage=damage}, 1, 1, true, false ) 
        for k, v in pairs(t) do
            v:RemoveDonate()
            v:SetAbsOrigin(hero_vector)
            v:AddNewModifier(self:GetCaster(), self, "modifier_bukin_clubnogirls", {})
        end
        hero_vector = RotatePosition(cursor_pos, QAngle(0, 360 / num, 0), hero_vector)
    end

   if self:GetCaster():HasTalent("special_bonus_birzha_bukin_2") then
        local cursor_pos = self:GetCaster():GetCursorPosition()
        local num = self:GetSpecialValueFor("count")
        local radius = self:GetSpecialValueFor("radius") * 2
        local duration = self:GetSpecialValueFor("duration")
        local damage = self:GetSpecialValueFor("damage")
        local hero_vector = GetGroundPosition(cursor_pos + Vector(0, radius, 0), nil)

        self:GetCaster():EmitSound("bezbab")
        if self.particle ~= nil then
            ParticleManager:DestroyParticle(self.particle,false)
        end
        self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_furarmy_ring.vpcf", PATTACH_POINT, self:GetCaster())
        ParticleManager:SetParticleControl(self.particle, 0, cursor_pos)
        ParticleManager:SetParticleControl(self.particle, 1, Vector(radius+50,1,1))
        Timers:CreateTimer(duration,function()
            ParticleManager:DestroyParticle(self.particle,false)
        end)

        for hero = 1, num do
            local t = CreateIllusions( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=damage}, 1, 1, true, false ) 
            for k, v in pairs(t) do
                v:RemoveModifierByName("modifier_birzha_premium")
                v:RemoveModifierByName("modifier_birzha_gob")
                v:RemoveModifierByName("modifier_birzha_vip")
                v:SetAbsOrigin(hero_vector)
                v:AddNewModifier(self:GetCaster(), self, "modifier_bukin_clubnogirls", {})
            end
            hero_vector = RotatePosition(cursor_pos, QAngle(0, 360 / num, 0), hero_vector)
        end
    end
end

modifier_bukin_clubnogirls = class({})

function modifier_bukin_clubnogirls:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_bukin_clubnogirls:OnIntervalThink()
    if not IsServer() then return end

    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        self:GetParent():GetOrigin(),
        nil,
        600,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        0,
        false
    )
    if #enemies > 0 then
        for enemy = 1, #enemies do
            if enemies[enemy] and enemies[enemy]:IsAlive() and not enemies[enemy]:IsAttackImmune() and not enemies[enemy]:IsInvulnerable() then
                self:GetParent():MoveToTargetToAttack(enemies[enemy])
            end
        end
    end
end

function modifier_bukin_clubnogirls:IsHidden()
    return true
end

function modifier_bukin_clubnogirls:CheckState()
    local state = {
    [MODIFIER_STATE_ROOTED] = true,
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_CANNOT_MISS] = true,
    [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }

    return state
end




