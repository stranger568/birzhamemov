modifier_npc_dota_azazin_antosha = class({})
function modifier_npc_dota_azazin_antosha:IsPurgable() return false end
function modifier_npc_dota_azazin_antosha:IsPurgeException() return false end
function modifier_npc_dota_azazin_antosha:IsHidden() return true end

function modifier_npc_dota_azazin_antosha:OnCreated()
    if not IsServer() then return end
    self.health = 3
    self.sound_time = 0
    self.move_time = 0
    self:StartIntervalThink(FrameTime())
end

function modifier_npc_dota_azazin_antosha:OnIntervalThink()
    if not IsServer() then return end
    self.move_time = self.move_time - FrameTime()
    if self.move_time <= 0 then
        self.move_time = 3
        self:GetParent():SetBaseMoveSpeed(200)
        local point = self:GetParent():GetAbsOrigin() + RandomVector(700)
        point = GetClearSpaceForUnit(self:GetParent(), point)
        self:GetParent():MoveToPosition(point)
    end
    self.sound_time = self.sound_time - FrameTime()
    if self.sound_time <= 0 then
        self.sound_time = 5
        self:GetParent():EmitSound("sound_anton1")
        local particle = ParticleManager:CreateParticle("particles/speechbubbles/speech_voice.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
        self:AddParticle(particle, false, false, -1, false, false)
        Timers:CreateTimer(2, function()
            if particle then
                ParticleManager:DestroyParticle(particle, false)
            end
        end)
    end
end

function modifier_npc_dota_azazin_antosha:CheckState()
    return
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_npc_dota_azazin_antosha:DeclareFunctions()
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

function modifier_npc_dota_azazin_antosha:GetDisableHealing()
    return 1
end

function modifier_npc_dota_azazin_antosha:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_npc_dota_azazin_antosha:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_npc_dota_azazin_antosha:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_npc_dota_azazin_antosha:GetModifierHealthBarPips()
    return 3
end

function modifier_npc_dota_azazin_antosha:OnAttackLanded(params)
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
        local point = self:GetParent():GetAbsOrigin() + RandomVector(400)
        point = GetClearSpaceForUnit(self:GetParent(), point)
        self:GetParent():MoveToPosition(point)
        self:GetParent():SetBaseMoveSpeed(550)
    end
end

function modifier_npc_dota_azazin_antosha:OnDestroy()
    if not IsServer() then return end
    self:GetParent():EmitSound("sound_kill")
    local origin = self:GetParent():GetAbsOrigin()
    BirzhaGameMode:SpawnGoldKobold( origin, true )
end