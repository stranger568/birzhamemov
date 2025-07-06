old_god_w = class({})

function old_god_w:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local outgoing_damage = self:GetSpecialValueFor("outgoing_damage") - 100
    local incoming_damage = self:GetSpecialValueFor("incoming_damage") - 100
    local illusion_count = 1
    if self:GetCaster():HasModifier("modifier_old_god_d") then
        illusion_count = 2
    end
    local illusion = BirzhaCreateIllusion( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=illusion_damage,incoming_damage=illusion_damage_in}, illusion_count, 1, true, true )  
    local old_god_r = self:GetCaster():FindAbilityByName("old_god_r")
    old_god_w.illusion_table = illusion
    for k, v in pairs(illusion) do
        if old_god_r and old_god_r:GetLevel() > 0 and self:GetCaster():HasModifier("modifier_old_god_r") then
            v:AddNewModifier(v, old_god_r, "modifier_old_god_r", {duration = duration})
        end
    end
    self:GetCaster():EmitSound("stariy_vova")
end