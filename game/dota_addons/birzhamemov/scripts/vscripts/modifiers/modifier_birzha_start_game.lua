modifier_birzha_start_game = class({})

function modifier_birzha_start_game:IsHidden()
	return true
end

function modifier_birzha_start_game:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,[MODIFIER_STATE_MUTED]= true,[MODIFIER_STATE_SILENCED]= true,[MODIFIER_STATE_NIGHTMARED] = true,[MODIFIER_STATE_NO_HEALTH_BAR] = true,[MODIFIER_STATE_OUT_OF_GAME] = true,[MODIFIER_STATE_MAGIC_IMMUNE] = true,[MODIFIER_STATE_INVULNERABLE] = true, }
end

function modifier_birzha_start_game:OnCreated()
	self:StartIntervalThink(FrameTime())
end

function modifier_birzha_start_game:OnIntervalThink()
	if pick_ended then 
		self:Destroy() 
	end
end  
