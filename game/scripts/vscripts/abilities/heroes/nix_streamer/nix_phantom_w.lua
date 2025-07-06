LinkLuaModifier("modifier_nix_phantom_w_thinker", "abilities/heroes/nix_streamer/nix_phantom_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

nix_phantom_w = class({})

function nix_phantom_w:Precache( context )
    PrecacheResource( "particle", "particles/nix/nix_phantom_w_thinker.vpcf", context )
end

function nix_phantom_w:OnVectorCastStart(vStartLocation, vDirection)
    if not IsServer() then return end
    local caster_origin = self:GetCaster():GetAbsOrigin()
    if caster_origin.x == vStartLocation.x and caster_origin.y == vStartLocation.y then
        vStartLocation = caster_origin + self:GetCaster():GetForwardVector() * 50
        vDirection = self:GetCaster():GetForwardVector()
    end
    local vector = (vStartLocation-self:GetCaster():GetOrigin())
    local dist = vector:Length2D()
    vector.z = 0
    vector = vector:Normalized()
    local has_upgrade = nil
    local modifier_nix_marci_r_upgrade = self:GetCaster():FindModifierByName("modifier_nix_marci_r_upgrade")
    if modifier_nix_marci_r_upgrade then
        modifier_nix_marci_r_upgrade:Destroy()
        has_upgrade = true
    end
    self:GetCaster():EmitSound("Hero_Undying.Tombstone.Enter")
    local speed = self:GetSpecialValueFor( "dash_speed" )
    CreateModifierThinker(self:GetCaster(), self, "modifier_nix_phantom_w_thinker", {has_upgrade = has_upgrade, start_point_x = vStartLocation.x, start_point_y = vStartLocation.y, direction_x = vDirection.x, direction_y = vDirection.y}, vStartLocation, self:GetCaster():GetTeamNumber(), false)
end

modifier_nix_phantom_w_thinker = class({})
function modifier_nix_phantom_w_thinker:IsHidden() return true end
function modifier_nix_phantom_w_thinker:IsPurgable() return false end
function modifier_nix_phantom_w_thinker:IsPurgeException() return false end

function modifier_nix_phantom_w_thinker:OnCreated(params)
    if not IsServer() then return end
    self.start_point = Vector(params.start_point_x, params.start_point_y, 0)
    self.direction_end = Vector(params.direction_x, params.direction_y, 0)
    self.initial_distance = (self.start_point - self:GetParent():GetAbsOrigin()):Length2D()
    self.initial_direction = (self.start_point - self:GetParent():GetAbsOrigin()):Normalized()
    self.length = self:GetAbility():GetSpecialValueFor("length")
    self.speed = self:GetAbility():GetSpecialValueFor("speed")
    self.targets = {}
    self.has_upgrade = params.has_upgrade
    if self.has_upgrade then
        self.length = self:GetAbility():GetSpecialValueFor("upgrade_length")
    end
    self.particle = ParticleManager:CreateParticle("particles/nix/nix_phantom_w_thinker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.particle, false, false, -1, false, false)
    self:StartIntervalThink(0.03)
end

function modifier_nix_phantom_w_thinker:OnIntervalThink()
    if not IsServer() then return end
    local speed = self.speed * FrameTime()
    local new_position = self:GetParent():GetAbsOrigin() + self.direction_end * speed
    new_position = GetGroundPosition(new_position, nil) + Vector(0, 0, 175)
    self:GetParent():SetAbsOrigin(new_position)
    self.length = self.length - speed
    self:UpdateDamage()
    if self.particle then
        ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle, 3, self:GetParent():GetAbsOrigin())
    end
    if self.length <= 0 then
        self:Destroy()
    end
end

function modifier_nix_phantom_w_thinker:UpdateDamage()
    if not IsServer() then return end
    local nix_marci_w = self:GetCaster():FindAbilityByName("nix_marci_w")
    local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 150, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    for _,unit in pairs(units) do
        if not self.targets[unit:entindex()] then
            self.targets[unit:entindex()] = true
            if unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
                local damage = self:GetAbility():GetSpecialValueFor("damage")
                ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
                if self.has_upgrade then
                    self:GetCaster():PerformAttack(unit, true, true, true, true, false, false, true)
                end
                if nix_marci_w and nix_marci_w:GetLevel() > 0 then
                    nix_marci_w:AddTargetMark(unit)
                end
            end
            unit:AddNewModifier(self:GetCaster(), self, "modifier_generic_knockback_lua",{ direction_x = self.direction_end.x, direction_y = self.direction_end.y, distance = self:GetAbility():GetSpecialValueFor("knockback_distance"), height = 5, duration = 0.25, IsStun = unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() })
        end
    end
end