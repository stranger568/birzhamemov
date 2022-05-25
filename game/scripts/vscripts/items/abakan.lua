item_abakan = class({})

function item_abakan:OnSpellStart()
    if not IsServer() then return end
    local heal = self:GetSpecialValueFor( "heal" )
    self:GetCaster():Heal( heal, self )
    self:GetCaster():EmitSound("beer")
    if self:GetCaster():GetUnitName() == "npc_dota_hero_void_spirit" then
        self:GetCaster():EmitSound("van_abakan")
    end
    local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
    if ability_pucci and ability_pucci:GetLevel() > 0 then
        if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_use_abakan" then
            ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
            local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
            CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
            if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
                ability_pucci.current_quest[4] = true
                ability_pucci.word_count = ability_pucci.word_count + 1
                ability_pucci:SetActivated(true)
                ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_use_cmoon"]
                CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
            end
        end
    end
    self:SpendCharge()
end