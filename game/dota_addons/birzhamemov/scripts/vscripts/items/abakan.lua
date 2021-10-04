item_abakan = class({})

function item_abakan:OnSpellStart()
    if not IsServer() then return end
    local heal = self:GetSpecialValueFor( "heal" )
    self:GetCaster():Heal( heal, self )
    self:GetCaster():EmitSound("beer")
    if self:GetCaster():GetUnitName() == "npc_dota_hero_void_spirit" then
        self:GetCaster():EmitSound("van_abakan")
    end
    self:SpendCharge()
end