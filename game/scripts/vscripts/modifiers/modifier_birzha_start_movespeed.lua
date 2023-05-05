LinkLuaModifier("modifier_birzha_penguin_speed", "modifiers/modifier_birzha_start_movespeed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_birzha_penguin_caster_zspeed", "modifiers/modifier_birzha_start_movespeed", LUA_MODIFIER_MOTION_NONE)

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
		if DonateShopIsItemBought(player, 20) then
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

		if DonateShopIsItemBought(player, 186) then
			self.penguin = CreateUnitByName("npc_dota_companion", self:GetParent():GetAbsOrigin(), false, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber())
			if self.penguin then
				self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_birzha_penguin_caster_zspeed", {})
				self.penguin:AddNewModifier(self:GetParent(), nil, "modifier_birzha_penguin_speed", {})
				self.penguin:SetOriginalModel("models/events/frostivus/penguin/penguin.vmdl")
				self.penguin:SetModel("models/events/frostivus/penguin/penguin.vmdl")
				self.penguin:SetModelScale(3)
			end
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
		if self.penguin and not self.penguin:IsNull() then
			UTIL_Remove(self.penguin)
		end
		self:GetParent():RemoveModifierByName("modifier_birzha_penguin_caster_zspeed")
		if self.speedeffect then
			ParticleManager:DestroyParticle(self.speedeffect, true)
		end
		if self.speedeffect2 then
			ParticleManager:DestroyParticle(self.speedeffect2, true)
		end
	end
	return 0	
end

modifier_birzha_penguin_speed = class({})
function modifier_birzha_penguin_speed:IsHidden() return true end
function modifier_birzha_penguin_speed:IsPurgable() return false end

function modifier_birzha_penguin_speed:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_birzha_penguin_speed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_birzha_penguin_speed:GetOverrideAnimation()
	return ACT_DOTA_SLIDE_LOOP
end

function modifier_birzha_penguin_speed:OnIntervalThink()
	if not IsServer() then return end
	self:GetParent():SetForwardVector(self:GetCaster():GetForwardVector())
	self:GetParent():SetAbsOrigin(self:GetCaster():GetAbsOrigin())
end

function modifier_birzha_penguin_speed:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end


modifier_birzha_penguin_caster_zspeed = class({})
function modifier_birzha_penguin_caster_zspeed:IsHidden() return true end
function modifier_birzha_penguin_caster_zspeed:IsPurgable() return false end

function modifier_birzha_penguin_caster_zspeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_EVENT_ON_ATTACK_START,
	}

	return funcs
end

function modifier_birzha_penguin_caster_zspeed:OnAttackStart(params)
	if params.attacker ~= self:GetParent() then return end
	self:Destroy()
end

function modifier_birzha_penguin_caster_zspeed:GetVisualZDelta()
	return 30
end

function modifier_birzha_penguin_caster_zspeed:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
