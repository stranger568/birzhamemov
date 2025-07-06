modifier_npc_dota_azazin_kobold = class({})
function modifier_npc_dota_azazin_kobold:IsPurgable() return false end
function modifier_npc_dota_azazin_kobold:IsPurgeException() return false end
function modifier_npc_dota_azazin_kobold:IsHidden() return true end

function modifier_npc_dota_azazin_kobold:OnCreated()
    if not IsServer() then return end
    self.health = 5
    self:StartIntervalThink(1)
    local point = self:GetParent():GetAbsOrigin() + RandomVector(400)
    point = GetClearSpaceForUnit(self:GetParent(), point)
    self:GetParent():MoveToPosition(point)
    self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_invulnerable", {})
end

function modifier_npc_dota_azazin_kobold:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():IsMoving() then
        return 
    end
    self:GetParent():SetBaseMoveSpeed(200)
    local point = self:GetParent():GetAbsOrigin() + RandomVector(400)
    point = GetClearSpaceForUnit(self:GetParent(), point)
    self:GetParent():MoveToPosition(point)
    self:GetParent():RemoveModifierByName("modifier_invulnerable")
end

function modifier_npc_dota_azazin_kobold:CheckState()
    return
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_npc_dota_azazin_kobold:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
end

function modifier_npc_dota_azazin_kobold:GetDisableHealing()
    return 1
end

function modifier_npc_dota_azazin_kobold:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_npc_dota_azazin_kobold:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_npc_dota_azazin_kobold:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_npc_dota_azazin_kobold:GetModifierHealthBarPips()
    return 5
end

function modifier_npc_dota_azazin_kobold:OnAttackLanded(params)
    if not IsServer() then return end
    if params.target == self:GetParent() then
        self.health = self.health - 1
        if self.health <= 0 then
            if not params.attacker:IsHero() then
                self:GetParent():ForceKill(false)
            else
                self:GetParent():Kill(nil, params.attacker)
            end
        else
            self:GetParent():SetHealth(self.health)
        end
        self:GetParent():EmitSound("sound_hit_1")
        local point = self:GetParent():GetAbsOrigin() + RandomVector(400)
        point = GetClearSpaceForUnit(self:GetParent(), point)
        self:GetParent():MoveToPosition(point)
        self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_invulnerable", {})
        self:GetParent():SetBaseMoveSpeed(550)
    end
end

function modifier_npc_dota_azazin_kobold:OnDestroy()
    if not IsServer() then return end
    EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "sound_hit_5", self:GetParent())
    local origin = self:GetParent():GetAbsOrigin()
    local coinsToSpawn = 100
    local coinsSpawned = 0
    Timers:CreateTimer(0, function()
        if coinsSpawned < coinsToSpawn then
            BirzhaGameMode:SpawnGoldKobold(origin)
            coinsSpawned = coinsSpawned + 1
            if coinsSpawned >= 20 then
                return 0.05
            end
            if coinsSpawned >= 4 then
                return 0.2
            end
            return 0.4
        else
            return nil
        end
    end)
end