LinkLuaModifier( "modifier_ashab_q", "abilities/heroes/ashab/ashab_q", LUA_MODIFIER_MOTION_NONE )

ashab_q = class({})

function ashab_q:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_spirit_breaker.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", context )
end

function ashab_q:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "ashab_run", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ashab_q", {target = target:entindex(), duration = duration})
end

modifier_ashab_q = class({})
function modifier_ashab_q:IsPurgable() return false end
function modifier_ashab_q:OnCreated(params)
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.target = EntIndexToHScript(params.target)
    self.damage_multiplier = self:GetAbility():GetSpecialValueFor("damage_multiplier")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.targets_table = {}
    local order =
    {
        UnitIndex = self:GetParent():entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        TargetIndex = self.target:entindex()
    }
    ExecuteOrderFromTable(order)
    self:GetParent():SetForceAttackTarget(self.target)
    self:GetParent():MoveToTargetToAttack(self.target)
    self:StartIntervalThink(0.05)
end

function modifier_ashab_q:OnDestroy()
    if not IsServer() then return end
    self:GetParent():Interrupt()
    self:GetParent():SetForceAttackTarget(nil)
    self:GetParent():SetForceAttackTargetAlly(nil)
    if self.target and not self.target:IsNull() and self.target:IsAlive() then
        self:GetParent():MoveToTargetToAttack(self.target)
    else
        self:GetParent():Stop()
    end
end

function modifier_ashab_q:OnIntervalThink()
    if not IsServer() then return end
    if self.target == nil or not self.target:IsAlive() or ( self.target:IsInvisible() and not self:GetParent():CanEntityBeSeenByMyTeam(self.target) ) then
        if not self:IsNull() then
            self:Destroy()
            return
        end
    else
        AddFOWViewer(self:GetCaster():GetTeamNumber(), self.target:GetAbsOrigin(), 100, 0.1, true)
        self:GetParent():MoveToTargetToAttack(self.target)
    end
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _, unit in pairs(units) do
        if unit ~= self.target then
            if not self.targets_table[unit:entindex()] then
                self.targets_table[unit:entindex()] = true
                self:BashTarget(unit)
            end
        end
    end
end

function modifier_ashab_q:BashTarget(unit)
    ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self:GetAbility() })
    local direction = (unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin())
    direction.z = 0
    direction = direction:Normalized()
    unit:AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_generic_knockback_lua",
        {
            direction_x = direction.x,
            direction_y = direction.y,
            distance = 200,
            height = 50,	
            duration = 0.5,
            IsStun = true,
        }
    )
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", PATTACH_POINT_FOLLOW, unit )
    ParticleManager:SetParticleControlEnt( particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:ReleaseParticleIndex( particle )
end

function modifier_ashab_q:CheckState()
    return
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_UNSLOWABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_CANNOT_MISS] = true,
    }
end

function modifier_ashab_q:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK,
    }
end

function modifier_ashab_q:GetModifierPreAttack_CriticalStrike(params)
    return self.damage_multiplier * 100
end

function modifier_ashab_q:OnAttack(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() and params.target == self.target then
        if self:GetCaster():HasTalent("special_bonus_unique_ashab_5") then
            self:BashTarget(params.target)
        end
        self:Destroy()
    end
end

function modifier_ashab_q:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor("speed")
end