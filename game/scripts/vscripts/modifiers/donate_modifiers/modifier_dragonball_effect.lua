modifier_dragonball_effect = class({})

function modifier_dragonball_effect:IsHidden()
	return true
end

function modifier_dragonball_effect:IsPurgable()
	return false
end

function modifier_dragonball_effect:IsPurgeException()
	return false
end

function modifier_dragonball_effect:RemoveOnDeath()
	return false
end

function modifier_dragonball_effect:AllowIllusionDuplicate()
	return true
end

function modifier_dragonball_effect:OnCreated()
	if IsServer() then
		local timer = BIRZHA_GAME_ALL_TIMER / 60
		if timer < 3 then
			self.effect = "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_1.vpcf"
			self.effect_number = 1
		elseif timer > 3 and timer < 6 then
			self.effect = "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_2.vpcf"
		elseif timer > 6 and timer < 9 then
			self.effect = "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_3.vpcf"
		elseif timer > 9 and timer < 12 then
			self.effect = "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_4.vpcf"
		elseif timer > 12 and timer < 15 then
			self.effect = "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_5.vpcf"
		end
		self.particle = ParticleManager:CreateParticle(self.effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle, 1, self:GetParent():GetAbsOrigin())
		self.particle_storm = ParticleManager:CreateParticle("particles/donate_effect/refraction_1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.particle_storm, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particle_storm, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particle_storm, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_dragonball_effect:OnIntervalThink()
	if IsServer() then
		local timer = BIRZHA_GAME_ALL_TIMER / 60
		if timer > 3 and timer < 6 then
			if not self.particle_2 then
				ParticleManager:DestroyParticle(self.particle, false)
				ParticleManager:DestroyParticle(self.particle_storm, false)
				self.effect = "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_2.vpcf"
				self.particle = ParticleManager:CreateParticle(self.effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
				self.particle_storm = ParticleManager:CreateParticle("particles/donate_effect/refraction_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(self.particle_storm, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.particle_storm, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.particle_storm, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
				self.particle_2 = true
			end
		elseif timer > 6 and timer < 9 then
			if not self.particle_3 then
				ParticleManager:DestroyParticle(self.particle, false)
				ParticleManager:DestroyParticle(self.particle_storm, false)
				self.effect = "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_3.vpcf"
				self.particle = ParticleManager:CreateParticle(self.effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
				self.particle_storm = ParticleManager:CreateParticle("particles/donate_effect/refraction_3.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(self.particle_storm, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.particle_storm, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.particle_storm, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
				self.particle_3 = true
			end
		elseif timer > 9 and timer < 12 then
			if not self.particle_4 then
				ParticleManager:DestroyParticle(self.particle, false)
				ParticleManager:DestroyParticle(self.particle_storm, false)
				self.effect = "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_4.vpcf"
				self.particle = ParticleManager:CreateParticle(self.effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
				self.particle_storm = ParticleManager:CreateParticle("particles/donate_effect/refraction_4.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(self.particle_storm, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.particle_storm, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.particle_storm, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
				self.particle_4 = true
			end
		elseif timer > 12 then
			if not self.particle_5 then
				ParticleManager:DestroyParticle(self.particle, false)
				ParticleManager:DestroyParticle(self.particle_storm, false)
				self.effect = "particles/donate_effect/dragon_ball_effect/dragon_ball_effect_5.vpcf"
				self.particle = ParticleManager:CreateParticle(self.effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
				self.particle_storm = ParticleManager:CreateParticle("particles/donate_effect/refraction_5.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(self.particle_storm, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.particle_storm, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.particle_storm, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
				self.particle_5 = true
			end
		end
	end
end

function modifier_dragonball_effect:OnDestroy(params)
	if IsServer() then
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, true)
		end
		if self.particle_storm then
			ParticleManager:DestroyParticle(self.particle_storm, true)
		end
	end
	return 0	
end