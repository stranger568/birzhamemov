modifier_birzha_start_movespeed = class({})

function modifier_birzha_start_movespeed:IsHidden()
	return true
end

function modifier_birzha_start_movespeed:IsPurgable()
	return true
end

function modifier_birzha_start_movespeed:IsPurgeException()
	return true
end

function modifier_birzha_start_movespeed:RemoveOnDeath()
	return true
end

function modifier_birzha_start_movespeed:AllowIllusionDuplicate()
	return false
end

function modifier_birzha_start_movespeed:OnCreated()
	if IsServer() then
		local player = self:GetParent():GetPlayerID()
		if IsUnlockedInPass(player, "reward1") then
			self.speedeffect = ParticleManager:CreateParticle("particles/birzhapass/start_game.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(self.speedeffect, 0, self:GetParent():GetAbsOrigin() )
			ParticleManager:SetParticleControl(self.speedeffect, 1, self:GetParent():GetAbsOrigin() )
			ParticleManager:SetParticleControl(self.speedeffect, 2, self:GetParent():GetAbsOrigin() )
			ParticleManager:SetParticleControl(self.speedeffect, 3, self:GetParent():GetAbsOrigin() )
			self.speedeffect2 = ParticleManager:CreateParticle("effect/emengchanrao/1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(self.speedeffect2, 0, self:GetParent():GetAbsOrigin() )
			ParticleManager:SetParticleControl(self.speedeffect2, 1, self:GetParent():GetAbsOrigin() )
			ParticleManager:SetParticleControl(self.speedeffect2, 2, self:GetParent():GetAbsOrigin() )
			ParticleManager:SetParticleControl(self.speedeffect2, 3, self:GetParent():GetAbsOrigin() )
		end
	end
end

function modifier_birzha_start_movespeed:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
	return funcs
end

function modifier_birzha_start_movespeed:GetModifierMoveSpeed_Absolute( params )
	return 550	
end

function modifier_birzha_start_movespeed:OnDestroy(params)
	if IsServer() then
		if self.speedeffect then
			ParticleManager:DestroyParticle(self.speedeffect, true)
		end
		if self.speedeffect2 then
			ParticleManager:DestroyParticle(self.speedeffect2, true)
		end
	end
	return 0	
end