modifier_quest_thinker = class({})

function modifier_quest_thinker:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_MANA_GAINED
	}
end

function modifier_quest_thinker:OnAbilityExecuted(params)
	if not IsServer() then return end
	if params.unit == nil then return end
	if not params.unit:IsRealHero() then return end
	if params.ability == nil then return end

	local hAbility = params.ability

	if hAbility:GetAbilityName() == "item_ward_observer" then
        donate_shop:QuestProgress(19, params.ability:GetCaster():GetPlayerOwnerID(), 1)
    end

    if hAbility:GetAbilityName() == "item_ward_sentry" then
    	donate_shop:QuestProgress(17, params.ability:GetCaster():GetPlayerOwnerID(), 1)
    end

    if hAbility:GetAbilityName() == "item_ward_dispenser" then
        if hAbility:GetToggleState() then
			donate_shop:QuestProgress(19, params.ability:GetCaster():GetPlayerOwnerID(), 1)
        else
        	donate_shop:QuestProgress(17, params.ability:GetCaster():GetPlayerOwnerID(), 1)
        end
    end
end

function modifier_quest_thinker:OnManaGained(params)
	if not IsServer() then return end
	if params.unit:IsRealHero() then
		if params.gain > 100 then
			donate_shop:QuestProgress(21, params.unit:GetPlayerOwnerID(), math.floor(params.gain))
		end
	end
end

modifier_quest_thinker_player = class({})

function modifier_quest_thinker_player:IsHidden() return true end
function modifier_quest_thinker_player:IsPurgable() return false end
function modifier_quest_thinker_player:IsPurgeException() return false end

function modifier_quest_thinker_player:OnCreated()
	if not IsServer() then return end
	self.origin = self:GetCaster():GetAbsOrigin()
	self:StartIntervalThink(FrameTime())
end

function modifier_quest_thinker_player:OnIntervalThink()
	if not IsServer() then return end
	local distance = (self:GetCaster():GetAbsOrigin() - self.origin):Length2D()
	self.origin = self:GetCaster():GetAbsOrigin()
	if distance > 0 then
		donate_shop:QuestProgress(40, self:GetParent():GetPlayerOwnerID(), math.floor(distance))
	end
end