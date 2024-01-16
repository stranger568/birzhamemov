if HeroDemo == nil then
	_G.HeroDemo = class({})
end

function HeroDemo:OnGameRulesStateChange()
    if not GameRules:IsCheatMode() then return end
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
        for i=0,19 do
            CustomUI:DynamicHud_Create( i, "Hero_Demo", "file://{resources}/layout/custom_game/hud_hero_demo/hud_hero_demo.xml", nil )
        end
	end
end