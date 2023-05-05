item_ananas_custom = class({})

function item_ananas_custom:OnSpellStart()
    if not IsServer() then return end
    GameRules:SendCustomMessage("Кушайте фрукты гайс", 0, 0)
    self:Destroy()
end
