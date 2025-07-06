LinkLuaModifier("modifier_nix_phantom_e_thinker", "abilities/heroes/nix_streamer/nix_phantom_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nix_phantom_e", "abilities/heroes/nix_streamer/nix_phantom_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

nix_phantom_e = class({})

function nix_phantom_e:Precache( context )
    PrecacheResource( "particle", "particles/nix/nix_phantom_e.vpcf", context )
end

function nix_phantom_e:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local point = self:GetCursorPosition()
    local direction = (point - self:GetCaster():GetAbsOrigin())
    direction.z = 0
    local distance = direction:Length2D()
    direction = direction:Normalized()
    local modifier_nix_phantom_e_thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_nix_phantom_e_thinker", {duration = duration + 0.25}, point, self:GetCaster():GetTeamNumber(), false)
    local modifier_nix_marci_r_upgrade = self:GetCaster():FindModifierByName("modifier_nix_marci_r_upgrade")
    if modifier_nix_marci_r_upgrade then
        modifier_nix_marci_r_upgrade:Destroy()
        modifier_nix_phantom_e_thinker.is_upgrade = true
    end
end

modifier_nix_phantom_e_thinker = class({})
function modifier_nix_phantom_e_thinker:IsHidden() return true end
function modifier_nix_phantom_e_thinker:IsPurgable() return false end
function modifier_nix_phantom_e_thinker:IsPurgeException() return false end
function modifier_nix_phantom_e_thinker:OnCreated()
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/nix/nix_phantom_e.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, 0))
    self:AddParticle(particle, false, false, -1, false, false)
end
function modifier_nix_phantom_e_thinker:IsAura() return true end
function modifier_nix_phantom_e_thinker:GetAuraDuration() return 0 end
function modifier_nix_phantom_e_thinker:GetModifierAura() return "modifier_nix_phantom_e" end
function modifier_nix_phantom_e_thinker:GetAuraRadius() return self.radius end
function modifier_nix_phantom_e_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_nix_phantom_e_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_nix_phantom_e = class({})

function modifier_nix_phantom_e:OnCreated()
    if not IsServer() then return end
    self.bonus_damage = 0
    self.cooldown_scepter_decrease = self:GetAbility():GetSpecialValueFor("cooldown_scepter_decrease")
    if self:GetAuraOwner() and self:GetAuraOwner().is_upgrade then
        self.bonus_damage = self:GetCaster():GetIntellect(true) / 100 * self:GetAbility():GetSpecialValueFor("upgrade_damage_int")
    end
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self:GetAbility():GetSpecialValueFor("damage") + self.bonus_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
    if self:GetCaster():HasScepter() and self:GetParent():IsRealHero() then
        local cooldown = self:GetAbility():GetCooldownTimeRemaining()
        self:GetAbility():EndCooldown()
        cooldown = cooldown - self.cooldown_scepter_decrease
        if cooldown > 0 then
            self:GetAbility():StartCooldown(cooldown)
        end
    end
end

function modifier_nix_phantom_e:OnDestroy()
    if not IsServer() then return end
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self:GetAbility():GetSpecialValueFor("damage") + self.bonus_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
    if self:GetCaster():HasScepter() and self:GetParent():IsRealHero() then
        local cooldown = self:GetAbility():GetCooldownTimeRemaining()
        self:GetAbility():EndCooldown()
        cooldown = cooldown - self.cooldown_scepter_decrease
        if cooldown > 0 then
            self:GetAbility():StartCooldown(cooldown)
        end
    end
end