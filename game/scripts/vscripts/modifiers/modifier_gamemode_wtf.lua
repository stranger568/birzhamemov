modifier_gamemode_wtf = class({})

modifier_gamemode_wtf.exceptions = {
	["Naval_Youtube"] = true,
	["Naval_meeting"] = true,
	["face_tombstone"] = true,
	["Kudes_GoldHook"] = true,
	["poroshenko_donbass"] = true,
	["Versuta_pudge"] = true,
	["Pistoletov_NewPirat"] = true,
	["Vernon_silence"] = true,
	["SilverName_Papaz"] = true,
	["evrei_ult"] = true,
	["Bogdan_Ultimate"] = true,
	["JesusAVGN_Spider"] = true,
	["JesusAVGN_SpiderPoison"] = true,
	["Gorin_TwinBrother"] = true,
	["Kurumi_Zafkiel"] = true,
	["Kurumi_shard"] = true,
	["rin_satana_explosion"] = true,
	["Slidan_ReallyClassic"] = true,
	["Miku_DanceSong"] = true,
	["gypsy_tabor"] = true,
	["van_leatherstuff"] = true,
	["kakashi_meteor"] = true,
	["kakashi_sharingan"] = true,
	["Overlord_spell_ultimate"] = true,
	["pucci_time_acceleration"] = true,
	["pucci_erace_disk"] = true,
	["pucci_restart_world"] = true,
	["pump_spooky"] = true,
	["jull_choronostasis"] = true,
	["jull_in_time"] = true,
	["nolik_tech"] = true,
	["Ns_TricksMaster"] = true,
}

function modifier_gamemode_wtf:IsHidden() return true end
function modifier_gamemode_wtf:IsPurgable() return false end
function modifier_gamemode_wtf:IsPurgeException() return false end
function modifier_gamemode_wtf:RemoveOnDeath() return false end

function modifier_gamemode_wtf:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end

function modifier_gamemode_wtf:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_gamemode_wtf:OnIntervalThink()
	if not IsServer() then return end
    for i = 0, 23 do
        local current_ability = self:GetParent():GetAbilityByIndex(i)
        if current_ability and not current_ability:IsAttributeBonus() and not current_ability:IsCooldownReady() then
        	if modifier_gamemode_wtf.exceptions[current_ability:GetAbilityName()] == nil then
            	current_ability:EndCooldown()
            end
        end
    end
end

function modifier_gamemode_wtf:OnAbilityExecuted( params )
	if IsServer() then
		local hAbility = params.ability
		if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
			return 0
		end

		if hAbility:IsItem() then
			return 0
		end
		if modifier_gamemode_wtf.exceptions[hAbility:GetAbilityName()] == nil then
        	hAbility:EndCooldown()
        end
        self:GetParent():GiveMana(hAbility:GetManaCost(hAbility:GetLevel()))
	end
	return 0
end