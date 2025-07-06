LinkLuaModifier("modifier_nix_phantom_d_thinker", "abilities/heroes/nix_streamer/nix_phantom_d", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

nix_phantom_d = class({})

function nix_phantom_d:Precache( context )
    PrecacheResource( "particle", "particles/nix/nix_phantom_d_thinker.vpcf", context )
end

function nix_phantom_d:GetCastRange(vLocation, hTarget)
    if IsClient() then
        if self:GetCaster():HasModifier("modifier_nix_marci_r_upgrade") then
            return self:GetSpecialValueFor("distance") * 2
        end
        return self:GetSpecialValueFor("distance")
    end
end

function nix_phantom_d:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local vector = (point-self:GetCaster():GetOrigin())
    local dist = vector:Length2D()
    vector.z = 0
    vector = vector:Normalized()
    local has_upgrade = nil
    local modifier_nix_marci_r_upgrade = self:GetCaster():FindModifierByName("modifier_nix_marci_r_upgrade")
    if modifier_nix_marci_r_upgrade then
        modifier_nix_marci_r_upgrade:Destroy()
        has_upgrade = true
    end
    self:GetCaster():EmitSound("nix_arbuz")
    local speed = self:GetSpecialValueFor( "dash_speed" )
    CreateModifierThinker(self:GetCaster(), self, "modifier_nix_phantom_d_thinker", {has_upgrade = has_upgrade, direction_x = vector.x, direction_y = vector.y}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
end

modifier_nix_phantom_d_thinker = class({})
function modifier_nix_phantom_d_thinker:IsHidden() return true end
function modifier_nix_phantom_d_thinker:IsPurgable() return false end
function modifier_nix_phantom_d_thinker:IsPurgeException() return false end

function modifier_nix_phantom_d_thinker:OnCreated(params)
    if not IsServer() then return end
    self.direction_end = Vector(params.direction_x, params.direction_y, 0)
    self.length = self:GetAbility():GetSpecialValueFor("distance")
    self.speed = self:GetAbility():GetSpecialValueFor("speed")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.damage_percent = self:GetAbility():GetSpecialValueFor("damage_percent")
    self.has_upgrade = params.has_upgrade
    if self.has_upgrade then
        self.length = self.length * 2
    end
    self.bee_activated = false
    self.particle = ParticleManager:CreateParticle("particles/nix/nix_phantom_d_thinker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.particle, false, false, -1, false, false)
    self:StartIntervalThink(0.03)
end

function modifier_nix_phantom_d_thinker:OnIntervalThink()
    if not IsServer() then return end
    local speed = self.speed * FrameTime()
    local new_position = self:GetParent():GetAbsOrigin() + self.direction_end * speed
    new_position = GetGroundPosition(new_position, nil) + Vector(0, 0, 175)
    self:GetParent():SetAbsOrigin(new_position)
    self.length = self.length - speed
    if self.particle then
        ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle, 3, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControlTransformForward( self.particle, 0, self:GetParent():GetAbsOrigin(), self.direction_end )
        ParticleManager:SetParticleControlTransformForward( self.particle, 3, self:GetParent():GetAbsOrigin(), self.direction_end )
    end
    AddFOWViewer(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 100, FrameTime(), true)
    self:CheckBee()
    if self:UpdateDamage() then
        AddFOWViewer(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 100, 1, true)
        self:Destroy()
        return
    end
    if self.length <= 0 then
        AddFOWViewer(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 100, 1, true)
        self:Destroy()
    end
end

function modifier_nix_phantom_d_thinker:CheckBee()
    if not IsServer() then return end
    if self.bee_activated then return end
    local units = Entities:FindAllByClassnameWithin( "npc_dota_thinker", self:GetParent():GetAbsOrigin(), 200 )
    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_dota_thinker" and unit:HasModifier("modifier_nix_phantom_e_thinker") then
            self.speed = self.speed * 2
            self.damage = self.damage * 2
            self.bee_activated = true
            break
        end
    end
end

function modifier_nix_phantom_d_thinker:UpdateDamage()
    if not IsServer() then return end
    local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    if #units <= 0 then return false end
    local nix_marci_w = self:GetCaster():FindAbilityByName("nix_marci_w")
    local target_main = units[1]
    if self.has_upgrade then
        for _, unit in pairs(units) do
            local damage = self.damage + (unit:GetMaxHealth() / 100 * self.damage_percent)
            ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self:GetAbility() })
            if nix_marci_w and nix_marci_w:GetLevel() > 0 then
                nix_marci_w:AddTargetMark(unit)
            end
        end
    else
        local damage = self.damage + (target_main:GetMaxHealth() / 100 * self.damage_percent)
        ApplyDamage({ victim = target_main, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self:GetAbility() })
        if nix_marci_w and nix_marci_w:GetLevel() > 0 then
            nix_marci_w:AddTargetMark(target_main)
        end
    end
    return true
end