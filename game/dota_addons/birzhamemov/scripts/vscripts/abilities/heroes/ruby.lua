LinkLuaModifier( "modifier_Ruby_RoseStrike", "abilities/heroes/ruby.lua", LUA_MODIFIER_MOTION_NONE )

Ruby_Fade = class({})

function Ruby_Fade:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ruby_Fade:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ruby_Fade:OnSpellStart()
    if not IsServer() then return end
    self.duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invisible", {duration = self.duration})
    self:GetCaster():EmitSound("Hero_PhantomLancer.PhantomEdge")
    local illusion = CreateIllusions( self:GetCaster(), self:GetCaster(), {duration=self.duration,outgoing_damage=0,incoming_damage=0}, 1, 1, true, true ) 
    local ability = self:GetCaster():FindAbilityByName("Ruby_RoseStrike")
    for k, v in pairs(illusion) do
        v:AddNewModifier(self:GetCaster(), ability, "modifier_Ruby_RoseStrike", {})
    end
end

LinkLuaModifier( "modifier_Ruby_SilverEyes", "abilities/heroes/ruby.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ruby_SilverEyes_debuff", "abilities/heroes/ruby.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ruby_SilverEyes_petrified", "abilities/heroes/ruby.lua", LUA_MODIFIER_MOTION_NONE )

Ruby_SilverEyes = class({})

function Ruby_SilverEyes:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )
    self:GetCaster():EmitSound("rubysilver")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_Ruby_SilverEyes", { duration = duration } )
end

modifier_Ruby_SilverEyes = class({})

function modifier_Ruby_SilverEyes:IsPurgable()
    return false
end

function modifier_Ruby_SilverEyes:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.parent = self:GetParent()
    self.modifiers = {}
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_stone_gaze_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", Vector(0,0,0), true )
    self:AddParticle( particle, false, false, -1, false, false )
    self:StartIntervalThink( 0.1 )
    self:OnIntervalThink()
end

function modifier_Ruby_SilverEyes:OnDestroy()
    if not IsServer() then return end
    for modifier,_ in pairs(self.modifiers) do
        if not modifier:IsNull() then
            modifier:Destroy()
        end
    end
    StopSoundOn( "rubysilver", self:GetParent() )
end

function modifier_Ruby_SilverEyes:OnIntervalThink()
    local enemies = FindUnitsInRadius( self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    for _,enemy in pairs(enemies) do
        local modifier1 = enemy:FindModifierByNameAndCaster( "modifier_Ruby_SilverEyes_debuff", self.parent )
        local modifier2 = enemy:FindModifierByNameAndCaster( "modifier_Ruby_SilverEyes_petrified", self.parent )
        if (not modifier1) and (not modifier2) then
            local modifier = enemy:AddNewModifier( self.parent, self:GetAbility(), "modifier_Ruby_SilverEyes_debuff", { center_unit = self.parent:entindex(), } )
            self.modifiers[modifier] = true
        end
    end
end

modifier_Ruby_SilverEyes_debuff = class({})

function modifier_Ruby_SilverEyes_debuff:IsPurgable()
    return false
end

function modifier_Ruby_SilverEyes_debuff:OnCreated( kv )
    self.stun_duration = self:GetAbility():GetSpecialValueFor( "stone_duration" )
    self.face_duration = self:GetAbility():GetSpecialValueFor( "face_duration" )
    self.physical_bonus = self:GetAbility():GetSpecialValueFor( "bonus_physical_damage" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.stone_angle = 85
    self.parent = self:GetParent()
    self.facing = false
    self.counter = 0
    self.interval = 0.03
    if not IsServer() then return end
    self.center_unit = EntIndexToHScript( kv.center_unit )
    self:PlayEffects1()
    self:PlayEffects2()
    self:StartIntervalThink( self.interval )
    self:OnIntervalThink()
    self.face_true = true
end

function modifier_Ruby_SilverEyes_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    }

    return funcs
end

function modifier_Ruby_SilverEyes_debuff:GetModifierMoveSpeedBonus_Percentage()
    if self.facing then
        return -50
    end
end

function modifier_Ruby_SilverEyes_debuff:GetModifierTurnRate_Percentage()
    if self.facing then
        return -50
    end
end

function modifier_Ruby_SilverEyes_debuff:GetModifierAttackSpeedBonus_Constant()
    if self.facing then
        return -50
    end
end

function modifier_Ruby_SilverEyes_debuff:OnIntervalThink()
    local vector = self.center_unit:GetOrigin()-self.parent:GetOrigin()
    local center_angle = VectorToAngles( vector ).y
    local facing_angle = VectorToAngles( self.parent:GetForwardVector() ).y
    local distance = vector:Length2D()
    local prev_facing = self.facing
    local damage = (self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ruby_1")) * 0.03
    self.facing = ( math.abs( AngleDiff(center_angle,facing_angle) ) < self.stone_angle ) and (distance < self.radius )
    if self.facing~=prev_facing then
        self:ChangeEffects( self.facing )
    end
    if self.facing then
        self.counter = self.counter + self.interval
        ApplyDamage({ victim = self.parent, attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
    end
    if self.counter>=self.face_duration then
        if self.face_true then
            self.parent:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Ruby_SilverEyes_petrified", { duration = self.stun_duration * (1 - self.parent:GetStatusResistance()), physical_bonus = self.physical_bonus, center_unit = self.center_unit:entindex(), }  )
            self.face_true = false
        end
    end
end

function modifier_Ruby_SilverEyes_debuff:PlayEffects1()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, self.center_unit, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    self:AddParticle( effect_cast, false, false, -1, false, false )
end

function modifier_Ruby_SilverEyes_debuff:PlayEffects2()
    self.effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_stone_gaze_facing.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( self.effect_cast, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    self:AddParticle( self.effect_cast, false, false, -1, false, false )
end

function modifier_Ruby_SilverEyes_debuff:ChangeEffects( IsNowFacing )
    local target = self.parent
    if IsNowFacing then
        target = self.center_unit
        self:GetParent():EmitSound("Hero_Medusa.StoneGaze.Target")
    end
    ParticleManager:SetParticleControlEnt( self.effect_cast, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
end

modifier_Ruby_SilverEyes_petrified = class({})

function modifier_Ruby_SilverEyes_petrified:OnCreated( kv )
    if not IsServer() then return end
    self.physical_bonus = kv.physical_bonus
    self.center_unit = EntIndexToHScript( kv.center_unit )
    self:PlayEffects()
end

function modifier_Ruby_SilverEyes_petrified:OnRefresh( kv )
    if not IsServer() then return end
    self.physical_bonus = kv.physical_bonus
    self.center_unit = EntIndexToHScript( kv.center_unit )
    self:PlayEffects()
end

function modifier_Ruby_SilverEyes_petrified:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }

    return funcs
end

function modifier_Ruby_SilverEyes_petrified:GetModifierIncomingDamage_Percentage( params )
    if params.damage_type==DAMAGE_TYPE_PHYSICAL then
        return self.physical_bonus
    end
end

function modifier_Ruby_SilverEyes_petrified:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true,
    }

    return state
end

function modifier_Ruby_SilverEyes_petrified:GetStatusEffectName()
    return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function modifier_Ruby_SilverEyes_petrified:StatusEffectPriority(  )
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_Ruby_SilverEyes_petrified:PlayEffects()
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff_stoned.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 1, self.center_unit, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector( 0,0,0 ), true )
    self:AddParticle( particle, false, false, -1, false, false )
    self:GetParent():EmitSound("Hero_Medusa.StoneGaze.Stun")
end

Ruby_RoseStrike = class({})

function Ruby_RoseStrike:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_ruby_2")
end

function Ruby_RoseStrike:GetIntrinsicModifierName()
    if self:GetCaster():IsIllusion() then return end
    return "modifier_Ruby_RoseStrike"
end

modifier_Ruby_RoseStrike = class({})

function modifier_Ruby_RoseStrike:IsHidden()
    return true
end

function modifier_Ruby_RoseStrike:IsPurgable()
    return false
end

function modifier_Ruby_RoseStrike:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACKED
    }

    return funcs
end

function modifier_Ruby_RoseStrike:OnAttackLanded( params )
    if not IsServer() then return end
    if params.target~=self:GetCaster() then return end
    if self:GetCaster():PassivesDisabled() then return end
    if params.attacker:GetTeamNumber()==params.target:GetTeamNumber() then return end
    self.chance = self:GetAbility():GetSpecialValueFor( "trigger_chance2" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    local damage = self:GetAbility():GetSpecialValueFor( "damage" )

    if RandomInt(1,100)>self.chance then return end
    if not self:GetAbility():IsFullyCastable() then return end
    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        0,
        false
    )
    for _,enemy in pairs(enemies) do
        self.damageTable = {
            victim = enemy,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = DAMAGE_TYPE_PURE,
            ability = self:GetAbility(),
            damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        }
        ApplyDamage( self.damageTable )
    end
    self:GetAbility():UseResources( false, false, true )
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_counterhelix.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( particle )
    self:GetParent():EmitSound("rubyaxe")
    self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_6)
    Timers:CreateTimer(0.5, function()
        self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_6)
    end)
end

function modifier_Ruby_RoseStrike:OnAttacked( params )
    if not IsServer() then return end
    if params.attacker == self:GetParent() then
        if self:GetCaster():PassivesDisabled() then return end
        self.chance = self:GetAbility():GetSpecialValueFor( "trigger_chance" )
        self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
        local damage = self:GetAbility():GetSpecialValueFor( "damage" )

        if RandomInt(1,100)>self.chance then return end
        if not self:GetAbility():IsFullyCastable() then return end
        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            0,
            false
        )
        for _,enemy in pairs(enemies) do
            self.damageTable = {
                victim = enemy,
                attacker = self:GetCaster(),
                damage = damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self:GetAbility(),
                damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            }
            ApplyDamage( self.damageTable )
        end
        self:GetAbility():UseResources( false, false, true )
        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:ReleaseParticleIndex( particle )
        self:GetParent():EmitSound("rubyaxe")
        self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_6)
        Timers:CreateTimer(0.5, function()
            self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_6)
        end)
    end
end

