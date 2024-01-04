LinkLuaModifier("modifier_item_birzha_contract_target", "items/birzha_contract", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_birzha_contract_caster", "items/birzha_contract", LUA_MODIFIER_MOTION_NONE)

item_birzha_contract = class({})

function item_birzha_contract:OnSpellStart()
	if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_item_birzha_contract_caster", {})
	self:SpendCharge()
end

modifier_item_birzha_contract_caster = class({})
function modifier_item_birzha_contract_caster:IsPurgable() return false end
function modifier_item_birzha_contract_caster:IsPurgeException() return false end
function modifier_item_birzha_contract_caster:IsHidden() return true end
function modifier_item_birzha_contract_caster:RemoveOnDeath() return false end
function modifier_item_birzha_contract_caster:OnCreated()
    if not IsServer() then return end
    self.target = nil
    self:StartIntervalThink(FrameTime())
end
function modifier_item_birzha_contract_caster:OnIntervalThink()
    if not IsServer() then return end
    local heroes = {}
    for id, player_info in pairs(BirzhaData.PLAYERS_GLOBAL_INFORMATION) do
        if IsInToolsMode() then
            if player_info.selected_hero ~= nil and player_info.selected_hero:IsAlive() and player_info.team ~= self:GetCaster():GetTeamNumber() then
                table.insert(heroes, player_info.selected_hero:GetUnitName())
            end
        else
            if player_info.selected_hero ~= nil and player_info.selected_hero:IsAlive() and not IsPlayerDisconnected(id) and player_info.team ~= self:GetCaster():GetTeamNumber() then
                table.insert(heroes, player_info.selected_hero:GetUnitName())
            end
        end
    end
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(self:GetCaster():GetPlayerOwnerID()), "contract_heroes_activate", {heroes = heroes} )
end

function modifier_item_birzha_contract_caster:OnDestroy()
    if not IsServer() then return end
    local target = self.target
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    if target ~= nil then
        target:AddNewModifier(caster, ability, "modifier_item_birzha_contract_target", {})
        if not target:IsAlive() or target:IsInvulnerable() then
            Timers:CreateTimer(1, function()
                if not target:IsAlive() or target:IsInvulnerable() then
                    return 1
                end
                target:AddNewModifier(caster, ability, "modifier_item_birzha_contract_target", {})
            end)
        end
    end
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(self:GetCaster():GetPlayerOwnerID()), "contract_heroes_close", {} )
end

modifier_item_birzha_contract_target = class({})
function modifier_item_birzha_contract_target:RemoveOnDeath() return false end
function modifier_item_birzha_contract_target:IsPurgable() return false end
function modifier_item_birzha_contract_target:IsPurgeException() return false end
function modifier_item_birzha_contract_target:IsHidden() return true end
function modifier_item_birzha_contract_target:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_birzha_contract_target:GetTexture()
	return "items/birzha_contract"
end
function modifier_item_birzha_contract_target:OnCreated()
	if not IsServer() then return end
	CustomGameEventManager:Send_ServerToTeam( self:GetCaster():GetTeamNumber(), "contract_hero_add", {hero = self:GetParent():GetUnitName()} )
end
function modifier_item_birzha_contract_target:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end
function modifier_item_birzha_contract_target:GetModifierIncomingDamage_Percentage(params)
    if params.attacker and params.attacker == self:GetCaster() then
        return 25
    end
end
function modifier_item_birzha_contract_target:OnDeath( params )
    if not IsServer() then return end
    local caster = self:GetCaster()
    if params.unit == self:GetParent() then
        local killer = params.attacker
        if killer:GetUnitName() == "npc_palnoref_chariot_illusion" then return end
        if killer:GetUnitName() == "npc_palnoref_chariot_illusion_2" then return end
        if not killer:IsHero() or killer:GetUnitName() == "npc_palnoref_chariot" or killer:GetUnitName() == "npc_dio_theworld_1" or killer:GetUnitName() == "npc_dio_theworld_2" or killer:GetUnitName() == "npc_dio_theworld_3" then
            killer = killer:GetOwner()
        end
        if not caster:IsHero() or caster:GetUnitName() == "npc_palnoref_chariot" or caster:GetUnitName() == "npc_dio_theworld_1" or caster:GetUnitName() == "npc_dio_theworld_2" or caster:GetUnitName() == "npc_dio_theworld_3" then
            caster = caster:GetOwner()
        end
        if killer ~= self:GetParent() then
        	if killer:GetTeamNumber() == caster:GetTeamNumber()  then
        		caster:ModifyGold(BirzhaGameMode.contract_gold[killer:GetTeamNumber()], false, 0)
                BirzhaGameMode.contract_gold[killer:GetTeamNumber()] = BirzhaGameMode.contract_gold[killer:GetTeamNumber()] + 500
                CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "AcceptContract", icon = "contract_accepted", caster = caster:GetUnitName(), target = self:GetParent():GetUnitName(), sound = "AcceptContract"} )
                if not self:IsNull() then
                    self:Destroy()
                end
            end
        end
    end
    if params.unit == caster then
        local killer = params.attacker
        if not killer:IsHero() then
            killer = killer:GetOwner()
        end
        if killer == self:GetParent() then
            self:GetParent():ModifyGold(BirzhaGameMode.contract_gold[self:GetParent():GetTeamNumber()] * 2, false, 0)
            CustomGameEventManager:Send_ServerToAllClients("birzha_toast_manager_create", {text = "CancelContract", icon = "contract_lose", target = caster:GetUnitName(), caster = self:GetParent():GetUnitName(), sound="CancelContract"} )
            if not self:IsNull() then
                self:Destroy()
            end
        end 
    end
end

function modifier_item_birzha_contract_target:OnDestroy()
	if not IsServer() then return end
	CustomGameEventManager:Send_ServerToTeam( self:GetCaster():GetTeamNumber(), "contract_hero_delete", {hero = self:GetParent():GetUnitName()} )
end