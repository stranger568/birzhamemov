LinkLuaModifier("modifier_item_birzha_contract_target", "items/birzha_contract", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_birzha_contract_cooldown", "items/birzha_contract", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_birzha_contract_use_cd", "items/birzha_contract", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_item_birzha_contract_passive_for_cd", "items/birzha_contract", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_birzha_contract_caster_cd", "items/birzha_contract", LUA_MODIFIER_MOTION_NONE)

item_birzha_contract = class({})
modifier_item_birzha_contract_passive_for_cd = class({})
modifier_item_birzha_contract_caster_cd = class({})

function item_birzha_contract:GetIntrinsicModifierName()
    return "modifier_item_birzha_contract_passive_for_cd"
end

function modifier_item_birzha_contract_passive_for_cd:IsHidden() return true end
function modifier_item_birzha_contract_passive_for_cd:IsPurgable() return false end

function modifier_item_birzha_contract_passive_for_cd:OnCreated()
    if not IsServer() then return end
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_birzha_contract_caster_cd", {duration = 240})
end

function modifier_item_birzha_contract_caster_cd:IsPurgable() return false end
function modifier_item_birzha_contract_caster_cd:RemoveOnDeath() return false end

function modifier_item_birzha_contract_caster_cd:GetTexture()
    return "items/birzha_contract"
end

function item_birzha_contract:CastFilterResultTarget(target)
	if target:HasModifier("modifier_item_birzha_contract_use_cd") then
        return UF_FAIL_CUSTOM
    end
	if target:HasModifier("modifier_item_birzha_contract_target") then
        return UF_FAIL_CUSTOM
    end
    if target:HasModifier("modifier_item_birzha_contract_cooldown") then
        return UF_FAIL_CUSTOM
    end
    if target:GetHealthPercent() <= 50 then
        return UF_FAIL_CUSTOM
    end
    if target:IsCreepHero() then
        return UF_FAIL_NOT_PLAYER_CONTROLLED
    end
    if not target:IsRealHero() then
        return UF_FAIL_NOT_PLAYER_CONTROLLED
    end
    local nResult = UnitFilter( target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber() )
    if nResult ~= UF_SUCCESS then
        return nResult
    end
    return UF_SUCCESS
end 

function item_birzha_contract:GetCustomCastErrorTarget(target)
	if target:HasModifier("modifier_item_birzha_contract_use_cd") then
        return "#dota_hud_error_contract_use"
    end
    if target:HasModifier("modifier_item_birzha_contract_target") then
        return "#dota_hud_error_contract_target"
    end
    if target:HasModifier("modifier_item_birzha_contract_cooldown") then
        return "#dota_hud_error_contract_cooldown"
    end
    if target:GetHealthPercent() <= 50 then
        return "#dota_hud_error_contract_health_percentage"
    end
    if target:IsCreepHero() then
        return ""
    end
    if not target:IsRealHero() then
        return ""
    end
end

function item_birzha_contract:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
    if not caster:IsHero() then
        caster = caster:GetOwner()
    end
    target:AddNewModifier(self:GetCaster(), nil, "modifier_item_birzha_contract_target", {})
    target:AddNewModifier(self:GetCaster(), nil, "modifier_item_birzha_contract_cooldown", {})
	self:SpendCharge()
end

modifier_item_birzha_contract_target = class({})

function modifier_item_birzha_contract_target:RemoveOnDeath() return false end
function modifier_item_birzha_contract_target:IsPurgable() return false end
function modifier_item_birzha_contract_target:IsHidden() return true end

function modifier_item_birzha_contract_target:GetTexture()
	return "items/birzha_contract"
end

function modifier_item_birzha_contract_target:OnCreated()
	if not IsServer() then return end
	CustomGameEventManager:Send_ServerToTeam( self:GetCaster():GetTeamNumber(), "contract_hero_add", {hero = self:GetParent():GetUnitName()} )
end

function modifier_item_birzha_contract_target:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

function modifier_item_birzha_contract_target:OnDeath( params )
    if not IsServer() then return end

    if params.unit == self:GetParent() then
        local killer = params.attacker

        if killer:GetUnitName() == "npc_palnoref_chariot_illusion" then return end
        if killer:GetUnitName() == "npc_palnoref_chariot_illusion_2" then return end

        if not killer:IsHero() then
            killer = killer:GetOwner()
        end

        if killer ~= self:GetParent() then
        	if killer:GetTeamNumber() == self:GetCaster():GetTeamNumber()  then
        		self:GetCaster():ModifyGold(BirzhaGameMode.contract_gold[killer:GetTeamNumber()], false, 0)
                BirzhaGameMode.contract_gold[killer:GetTeamNumber()] = BirzhaGameMode.contract_gold[killer:GetTeamNumber()] + 500
                CustomGameEventManager:Send_ServerToAllClients("contract_event_accept", {caster = self:GetCaster():GetUnitName(), target = self:GetParent():GetUnitName()} )
                if not self:IsNull() then
                    self:Destroy()
                end
            end
        end
    end
    
    if params.unit == self:GetCaster() then
        local killer = params.attacker
        if not killer:IsHero() then
            killer = killer:GetOwner()
        end
        if killer == self:GetParent() then
            self:GetParent():ModifyGold(BirzhaGameMode.contract_gold[self:GetParent():GetTeamNumber()] * 2, false, 0)
            CustomGameEventManager:Send_ServerToAllClients("contract_event_cancel", {caster = self:GetCaster():GetUnitName(), target = self:GetParent():GetUnitName()} )
            if not self:IsNull() then
                self:Destroy()
            end
        end 
    end
end

function modifier_item_birzha_contract_target:OnDestroy()
	if not IsServer() then return end
	local mod = self:GetParent():FindModifierByName("modifier_item_birzha_contract_cooldown")
	if mod then
		mod:SetDuration(240, true)
	end
	CustomGameEventManager:Send_ServerToAllClients( "contract_hero_delete", {hero = self:GetParent():GetUnitName()} )
end

modifier_item_birzha_contract_cooldown = class({})

function modifier_item_birzha_contract_cooldown:RemoveOnDeath() return false end
function modifier_item_birzha_contract_cooldown:IsPurgable() return false end
function modifier_item_birzha_contract_cooldown:IsHidden() return true end

modifier_item_birzha_contract_use_cd = class({})

function modifier_item_birzha_contract_use_cd:IsHidden() return true end
function modifier_item_birzha_contract_use_cd:IsPurgable() return false end

function modifier_item_birzha_contract_use_cd:OnDestroy()
	if not IsServer() then return end
	if self:GetParent():IsAlive() then
		self:GetParent():AddNewModifier(self:GetCaster(), nil, "modifier_item_birzha_contract_target", {})
		self:GetParent():AddNewModifier(self:GetCaster(), nil, "modifier_item_birzha_contract_cooldown", {})
	end
end