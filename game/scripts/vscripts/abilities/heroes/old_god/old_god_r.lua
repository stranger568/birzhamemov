LinkLuaModifier( "modifier_old_god_r", "abilities/heroes/old_god/old_god_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_old_god_r_thinker", "abilities/heroes/old_god/old_god_r", LUA_MODIFIER_MOTION_NONE )

old_god_r = class({})

function old_god_r:Precache(context)
    PrecacheResource("particle", "particles/old_god/old_god_r.vpcf", context)
end

function old_god_r:OnInventoryContentsChanged()
    if not IsServer() then return end
    if self:GetCaster():HasScepter() then
        if self:GetCaster():IsIllusion() then return end
        local modifier_old_god_r = self:GetCaster():FindModifierByName("modifier_old_god_r")
        if modifier_old_god_r and modifier_old_god_r:GetRemainingTime() > 0 then
            modifier_old_god_r:Destroy()
        end
        if not self:GetCaster():HasModifier("modifier_old_god_r") then
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_old_god_r", {})
        end
    else
        local modifier_old_god_r = self:GetCaster():FindModifierByName("modifier_old_god_r")
        if modifier_old_god_r and modifier_old_god_r:GetRemainingTime() <= 0 then
            modifier_old_god_r:Destroy()
        end
    end
end

function old_god_r:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function old_god_r:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function old_god_r:GetIntrinsicModifierName()
    if self:GetCaster():IsIllusion() then return end
    if self:GetCaster():HasScepter() then
        return "modifier_old_god_r"
    end
end

function old_god_r:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("stariy_laser")
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_old_god_r", {duration=duration})
end

modifier_old_god_r = class({})
function modifier_old_god_r:IsPurgable() return false end
function modifier_old_god_r:IsPurgeException() return false end
function modifier_old_god_r:RemoveOnDeath() return false end
function modifier_old_god_r:OnCreated(params)
    if not IsServer() then return end
    self.point = self:GetCaster():GetAbsOrigin()
    self.dummy = CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_old_god_r_thinker", {}, self:GetParent():GetAbsOrigin(), self:GetParent():GetTeamNumber(), false)
    self.dummy:SetAbsOrigin(self.point)
    self.nBeamFXIndex = ParticleManager:CreateParticle( "particles/old_god/old_god_r.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControlEnt( self.nBeamFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "eye_1", self:GetCaster():GetAbsOrigin(), true )
    ParticleManager:SetParticleControlEnt( self.nBeamFXIndex, 5, self:GetCaster(), PATTACH_POINT_FOLLOW, "eye_2", self:GetCaster():GetAbsOrigin(), true )
    ParticleManager:SetParticleControlEnt( self.nBeamFXIndex, 1, self.dummy, PATTACH_ABSORIGIN_FOLLOW, nil, self.dummy:GetOrigin(), true )
    ParticleManager:SetParticleControlEnt( self.nBeamFXIndex, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self.dummy:GetOrigin(), true )
    ParticleManager:SetParticleControlEnt( self.nBeamFXIndex, 9, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
    self.tick_damage = 0
    self:StartIntervalThink(FrameTime())
end

function modifier_old_god_r:OnIntervalThink()
    if not IsServer() then return end
    if self.dummy and self.dummy:IsNull() then return end
    local passive_disabled = self:GetParent():PassivesDisabled()
    if self:GetCaster():IsAlive() and not passive_disabled then
        if self.nBeamFXIndex == nil then
            local particle_name = "particles/old_god/old_god_r.vpcf"
            self.nBeamFXIndex = ParticleManager:CreateParticle( "particles/old_god/old_god_r.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControlEnt( self.nBeamFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "eye_1", self:GetCaster():GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( self.nBeamFXIndex, 5, self:GetCaster(), PATTACH_POINT_FOLLOW, "eye_2", self:GetCaster():GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( self.nBeamFXIndex, 1, self.dummy, PATTACH_ABSORIGIN_FOLLOW, nil, self.dummy:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( self.nBeamFXIndex, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self.dummy:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( self.nBeamFXIndex, 9, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
        end
    else
        if self.nBeamFXIndex ~= nil then
            ParticleManager:DestroyParticle(self.nBeamFXIndex, true)
            ParticleManager:ReleaseParticleIndex(self.nBeamFXIndex)
            self.nBeamFXIndex = nil
        end
    end

    if not self:GetCaster():IsAlive() then return end
    local heroes = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
    
    if self:GetParent():GetAggroTarget() ~= nil and not self:GetParent():GetAggroTarget():IsNull() and self:GetParent():GetAggroTarget():IsAlive() then
        self.point = self:GetParent():GetAggroTarget():GetAbsOrigin()
        --self.dummy:SetAbsOrigin(self.point)
    elseif #heroes > 0 then
        self.point = heroes[1]:GetAbsOrigin()
        --self.dummy:SetAbsOrigin(self.point)
    elseif #units > 0 then
        self.point = units[1]:GetAbsOrigin()
        --self.dummy:SetAbsOrigin(self.point)
    else
        self.point = self:GetCaster():GetAbsOrigin()
        self.dummy:SetAbsOrigin(self.point + self:GetParent():GetForwardVector() * 350)
    end

    local direction = self.point - self.dummy:GetAbsOrigin()
    direction.z = 0
    direction = direction:Normalized()

    local ray_speed = self:GetAbility():GetSpecialValueFor("ray_speed")
    local new_point = self.dummy:GetAbsOrigin() + direction * (ray_speed * FrameTime())
    local dir_min_c = new_point - self:GetCaster():GetAbsOrigin()
    local distance = dir_min_c:Length2D()

    dir_min_c.z = 0

    local direction_min = dir_min_c:Normalized()
    if distance < self:GetAbility():GetSpecialValueFor("min_distance") - 50 then
        local dir = new_point - self:GetCaster():GetAbsOrigin()
        local len = dir:Length2D()
        dir.z = 0
        dir = dir:Normalized()
        new_point = new_point + dir * (self:GetAbility():GetSpecialValueFor("min_distance") - 150)
    end

    new_point = GetGroundPosition(new_point, nil)
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self.dummy:GetAbsOrigin(), 100, FrameTime(), false)
    self.dummy:SetAbsOrigin(new_point)
    self.tick_damage = self.tick_damage + FrameTime()

    local health_ever = self:GetAbility():GetSpecialValueFor("health_aver")
    local passive_disabled = self:GetParent():PassivesDisabled()
    if passive_disabled then return end
    local interval_tick = self:GetAbility():GetSpecialValueFor("interval")
    local flag = 0
    if self:GetCaster():HasModifier("modifier_old_god_d") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    if self.tick_damage >= interval_tick then
        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), new_point, nil, self:GetAbility():GetSpecialValueFor("radius_damage"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false )
        for _,enemy in pairs( enemies ) do
            if enemy:IsAlive() then
                local damage = self:GetAbility():GetSpecialValueFor("damage")
                local damageInfo = 
                {
                    victim = enemy,
                    attacker = self:GetCaster(),
                    damage = damage * self:GetAbility():GetSpecialValueFor("interval"),
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self:GetAbility(),
                    damage_flags = 0,
                }
                ApplyDamage( damageInfo )
                if not enemy:IsAlive() then
                    self:GetCaster():EmitSound("stariy_teaser")
                end
            end
        end
        self.tick_damage = 0
    end
end

function modifier_old_god_r:OnDestroy()
    if not IsServer() then return end
    if self.dummy and not self.dummy:IsNull() then
        self.dummy:RemoveModifierByName("modifier_old_god_r_thinker")
        UTIL_Remove(self.dummy)
    end
    if self.nBeamFXIndex then
        ParticleManager:DestroyParticle(self.nBeamFXIndex, true)
    end
end

modifier_old_god_r_thinker = class({})
function modifier_old_god_r_thinker:IsHidden() return true end
function modifier_old_god_r_thinker:IsPurgable() return false end
function modifier_old_god_r_thinker:RemoveOnDeath() return false end
function modifier_old_god_r_thinker:CheckState()
    return 
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end
function modifier_old_god_r_thinker:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())
end