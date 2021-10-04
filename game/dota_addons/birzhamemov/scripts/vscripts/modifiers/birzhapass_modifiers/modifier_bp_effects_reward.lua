modifier_bp_effects_reward = class({})

function modifier_bp_effects_reward:IsHidden()
	return true
end

function modifier_bp_effects_reward:IsPurgable()
	return false
end

function modifier_bp_effects_reward:IsPurgeException()
	return false
end

function modifier_bp_effects_reward:RemoveOnDeath()
	return false
end

function modifier_bp_effects_reward:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_bp_effects_reward:OnDeath(params)
	local player = self:GetParent():GetPlayerID()
	local hAttacker = params.attacker
	local hVictim = params.unit
	if IsServer() then
		if self:GetParent():IsRealHero() then
			if not self:GetParent():IsIllusion() then
				if IsUnlockedInPass(player, "reward14") then
					if hVictim == self:GetParent() and self:GetParent():IsRealHero() then
						LinkLuaModifier("modifier_birzha_pet", "modifiers/modifier_birzha_pet.lua", LUA_MODIFIER_MOTION_NONE)
						local tombstone = CreateUnitByName("npc_dota_tombstone", self:GetParent():GetOrigin(), true, self:GetParent(), nil, 1)
						tombstone:AddNewModifier(tombstone, nil, "modifier_birzha_pet", {})
						local storm = ParticleManager:CreateParticle( "particles/birzhapass/bp_death_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, tombstone )
						ParticleManager:SetParticleControl(storm, 0, self:GetParent():GetAbsOrigin())
						ParticleManager:SetParticleControl(storm, 1, self:GetParent():GetAbsOrigin())
						Timers:CreateTimer(10, function()
							if tombstone then
								tombstone:Destroy()
							end
						end)
					end
				end
			end
		end
	end
	return 0	
end