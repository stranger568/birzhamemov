LinkLuaModifier("modifier_custom_ability_teleport", "items/item_tpscroll_custom", LUA_MODIFIER_MOTION_NONE)

item_tpscroll_custom = class({})

function item_tpscroll_custom:Precache(context)
    if self:GetCaster() and self:GetCaster():IsIllusion() then return end
    PrecacheResource( "particle","particles/items2_fx/teleport_start.vpcf", context )
    PrecacheResource( "particle","particles/items2_fx/teleport_end.vpcf", context )
    PrecacheResource( "particle","particles/items_fx/glyph.vpcf", context ) 
    PrecacheResource( "particle","particles/econ/events/ti10/teleport/teleport_start_ti10_lvl1_rewardline.vpcf", context )
    PrecacheResource( "particle","particles/econ/events/ti5/teleport_end_lvl2_ti5.vpcf", context )
    PrecacheResource( "particle","particles/items2_fx/smoke_of_deceit.vpcf", context )
end

function item_tpscroll_custom:OnSpellStart()
    if not IsServer() then return end
    local hero = self:GetCaster()
    local spawn_entity = FindSpawnEntityForTeam(hero:GetTeamNumber())
    if not spawn_entity then return end
	self.point =  GetGroundPosition(spawn_entity:GetAbsOrigin(), nil)
    self.point_start = hero:GetAbsOrigin()
    hero:StartGesture(ACT_DOTA_TELEPORT)
    self.teleport_center = CreateUnitByName("npc_dota_companion", self.point, false, nil, nil, 0)
    self.teleport_center:AddNewModifier(self.teleport_center, nil, "modifier_phased", {})
    self.teleport_center:AddNewModifier(self.teleport_center, nil, "modifier_invulnerable", {})
    self.teleport_center:SetAbsOrigin(self.point)
    AddFOWViewer(hero:GetTeamNumber(), self.point, 400, self:GetChannelTime() + 0.5, false)
    local modifier_custom_ability_teleport = hero:AddNewModifier(hero, self, "modifier_custom_ability_teleport", {duration = self:GetChannelTime(), center = self.teleport_center:entindex()})
    if modifier_custom_ability_teleport then
        self.particle_start = ParticleManager:CreateParticle("particles/items2_fx/teleport_start.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.particle_start, 0, hero:GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle_start, 2, Vector(255, 255, 255))
        modifier_custom_ability_teleport:AddParticle(self.particle_start, false, false, -1, false, false)

        self.particle_end = ParticleManager:CreateParticle("particles/items2_fx/teleport_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.teleport_center)
        ParticleManager:SetParticleControlEnt(self.particle_end, 1, self.teleport_center, PATTACH_ABSORIGIN_FOLLOW, nil, self.teleport_center:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.particle_end, 3, hero, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.teleport_center:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(self.particle_end, 4, Vector(0.9, 0, 0))
        ParticleManager:SetParticleControlEnt(self.particle_end, 5, self.teleport_center, PATTACH_ABSORIGIN_FOLLOW, nil, self.teleport_center:GetAbsOrigin(), true)
        modifier_custom_ability_teleport:AddParticle(self.particle_end, false, false, -1, false, false)
    end
end

function item_tpscroll_custom:OnChannelFinish(bInterrupted)
    if not IsServer() then return end
    local hero = self:GetCaster()
    hero:RemoveModifierByName("modifier_custom_ability_teleport")
    if self.teleport_center and not self.teleport_center:IsNull() then
        UTIL_Remove(self.teleport_center)
    end
    hero:RemoveGesture(ACT_DOTA_TELEPORT)
    if self.particle_start then
        ParticleManager:DestroyParticle(self.particle_start, false)
        ParticleManager:ReleaseParticleIndex(self.particle_start)
    end
    if self.particle_end then
        ParticleManager:DestroyParticle(self.particle_end, false)
        ParticleManager:ReleaseParticleIndex(self.particle_end)
    end
    if bInterrupted then return end   
    EmitSoundOnLocationWithCaster(self.point_start, "Portal.Hero_Disappear", hero)
    hero:SetAbsOrigin(self.point)
    FindClearSpaceForUnit(hero, self.point, true)
    hero:Stop()
    hero:Interrupt()
    hero:EmitSound("Portal.Hero_Disappear")
    hero:StartGesture(ACT_DOTA_TELEPORT_END)
end

function item_tpscroll_custom:OnChannelThink(fInterval)
    if self:GetCaster():IsRooted() or self:GetCaster():IsHexed() or self:GetCaster():IsStunned() then 
        self:GetCaster():Stop()
        self:GetCaster():Interrupt() 
    end 
end

modifier_custom_ability_teleport = class({})
function modifier_custom_ability_teleport:IsHidden() return false end
function modifier_custom_ability_teleport:IsPurgable() return false end
function modifier_custom_ability_teleport:GetTexture()
    return "item_tpscroll"
end

function modifier_custom_ability_teleport:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_custom_ability_teleport:GetOverrideAnimation()
    return ACT_DOTA_TELEPORT
end

function modifier_custom_ability_teleport:OnCreated(table)
    if not IsServer() then return end
    self.parent = self:GetParent()
    self.center = EntIndexToHScript(table.center)
    self:StartIntervalThink(0.1)
end

function modifier_custom_ability_teleport:OnIntervalThink()
    if not IsServer() then return end
    self.parent:EmitSound("Portal.Loop_Appear")
    if self.center and not self.center:IsNull() then
        self.center:EmitSound("Portal.Loop_Appear")
    end
    self:StartIntervalThink(-1)
end

function modifier_custom_ability_teleport:OnDestroy()
    if not IsServer() then return end
    self.parent:StopSound("Portal.Loop_Appear")
    if self.center and not self.center:IsNull() then
        self.center:StopSound("Portal.Loop_Appear")
    end
end
