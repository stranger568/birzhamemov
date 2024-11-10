LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

nix_marci_q = class({})

function nix_marci_q:Precache( context )
    PrecacheResource( "particle", "particles/nix/nix_marci_q_new.vpcf", context )
end

function nix_marci_q:OnSpellStart()
    if not IsServer() then return end
    local origin = self:GetCaster():GetAbsOrigin()
    local point = self:GetCursorPosition()
    local has_upgrade = false
    local modifier_nix_marci_r_upgrade = self:GetCaster():FindModifierByName("modifier_nix_marci_r_upgrade")
    if modifier_nix_marci_r_upgrade then
        modifier_nix_marci_r_upgrade:Destroy()
        has_upgrade = true
    end
    local direction = (point - origin)
    direction.z = 0
    direction = direction:Normalized()
    local damage = self:GetSpecialValueFor("base_damage")
    if has_upgrade then
        damage = damage + (self:GetCaster():GetStrength() / 100 * self:GetSpecialValueFor("upgrade_damage_str"))
    end
    local radius_width = self:GetSpecialValueFor("radius_width")
    local duration = self:GetSpecialValueFor("duration")
    local enemies = FindUnitsInLine(self:GetCaster():GetTeamNumber(), origin, point, nil, radius_width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
    for _, enemy in pairs(enemies) do
        local distance = (enemy:GetAbsOrigin() - origin):Length2D()
        local knockback_distance = self:GetSpecialValueFor("knockback_distance")
        knockback_distance =  math.max(0, knockback_distance - distance)
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_generic_knockback_lua",{ direction_x = direction.x, direction_y = direction.y, distance = knockback_distance, height = 10, duration = duration, IsStun = has_upgrade })
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self})
    end
    self:GetCaster():EmitSound("nix_sui")
    local particle = ParticleManager:CreateParticle("particles/nix/nix_marci_q_new.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, origin + Vector(0, 0, 100))
    ParticleManager:SetParticleControl(particle, 1, point + Vector(0, 0, 100))
    ParticleManager:ReleaseParticleIndex(particle)
end