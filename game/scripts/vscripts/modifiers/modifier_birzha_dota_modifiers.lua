modifier_birzha_stunned = class({})

function modifier_birzha_stunned:OnCreated()
	self.stun = false
	if IsServer() then
		if self:IsNull() then return end
		for _, mod in pairs(self:GetParent():FindAllModifiers()) do
			local ability = mod:GetAbility()
			if ability then
				if self:GetAbility() == ability and self ~= mod and mod:GetName() == self:GetName() then
					if not mod:IsNull() then
						mod:Destroy()
					end
				end
			end
		end
		self:SetDuration(self:GetDuration()*(1 - self:GetParent():GetStatusResistance()), true)
		if self:GetParent() ~= self:GetCaster() then
			local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
			if ability_pucci and ability_pucci:GetLevel() > 0 then
				if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_stunned" then
					ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
					local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
	    			CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
					if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
						ability_pucci.current_quest[4] = true
						ability_pucci.word_count = ability_pucci.word_count + 1
						ability_pucci:SetActivated(true)
						ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_observer_ward"]
	    				CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
					end
				end
			end
		end
	end
	self.stun = true
end

function modifier_birzha_stunned:IsDebuff()
	return true
end

function modifier_birzha_stunned:IsStunDebuff()
	return true
end

function modifier_birzha_stunned:IsPurgable()
	return false
end

function modifier_birzha_stunned:IsPurgeException()
	return true
end

function modifier_birzha_stunned:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_birzha_stunned:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = self.stun,
	}

	return state
end

function modifier_birzha_stunned:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_birzha_stunned:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_birzha_stunned:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_birzha_stunned:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_birzha_bashed = class({})

function modifier_birzha_bashed:OnCreated()
	if not IsServer() then return end
	self:SetDuration(self:GetDuration()*(1 - self:GetParent():GetStatusResistance()), true)
	if self:GetParent() ~= self:GetCaster() then
		local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
		if ability_pucci and ability_pucci:GetLevel() > 0 then
			if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_stunned" then
				ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
				local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
				CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
				if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
					ability_pucci.current_quest[4] = true
					ability_pucci.word_count = ability_pucci.word_count + 1
					ability_pucci:SetActivated(true)
					ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_observer_ward"]
					CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
				end
			end
		end
	end
end

function modifier_birzha_bashed:IsDebuff()
	return true
end

function modifier_birzha_bashed:IsStunDebuff()
	return true
end

function modifier_birzha_bashed:IsPurgable()
	return false
end

function modifier_birzha_bashed:IsPurgeException()
	return true
end

function modifier_birzha_bashed:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_birzha_bashed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_birzha_bashed:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_birzha_bashed:GetEffectName()
	return "particles/generic_gameplay/generic_bashed.vpcf"
end

function modifier_birzha_bashed:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_birzha_stunned_purge = class({})

function modifier_birzha_stunned_purge:OnCreated()
	self.stun = false
	if IsServer() then
		if self:IsNull() then return end
		for _, mod in pairs(self:GetParent():FindAllModifiers()) do
			local ability = mod:GetAbility()
			if ability then
				if self:GetAbility() == ability and self ~= mod and mod:GetName() == self:GetName() then
					if not mod:IsNull() then
						mod:Destroy()
					end
				end
			end
		end
		self:SetDuration(self:GetDuration()*(1 - self:GetParent():GetStatusResistance()), true)
		if self:GetParent() ~= self:GetCaster() then
			local ability_pucci = self:GetCaster():FindAbilityByName("pucci_restart_world")
			if ability_pucci and ability_pucci:GetLevel() > 0 then
				if ability_pucci.current_quest[4] == false and ability_pucci.current_quest[1] == "pucci_quest_stunned" then
					ability_pucci.current_quest[2] = ability_pucci.current_quest[2] + 1
					local Player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
	    			CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_progress", {min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
					if ability_pucci.current_quest[2] >= ability_pucci.current_quest[3] then
						ability_pucci.current_quest[4] = true
						ability_pucci.word_count = ability_pucci.word_count + 1
						ability_pucci:SetActivated(true)
						ability_pucci.current_quest = ability_pucci.quests[GetMapName()]["pucci_quest_observer_ward"]
	    				CustomGameEventManager:Send_ServerToPlayer(Player, "pucci_quest_event_set_quest", {quest_name = ability_pucci.current_quest[1], min = ability_pucci.current_quest[2], max = ability_pucci.current_quest[3]} )
					end
				end
			end
		end
	end
	self.stun = true
end

function modifier_birzha_stunned_purge:IsDebuff()
	return true
end

function modifier_birzha_stunned_purge:IsStunDebuff()
	return true
end

function modifier_birzha_stunned_purge:IsPurgable()
	return false
end

function modifier_birzha_stunned_purge:IsPurgeException()
	return true
end

function modifier_birzha_stunned_purge:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_birzha_stunned_purge:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = self.stun,
	}

	return state
end

function modifier_birzha_stunned_purge:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_birzha_stunned_purge:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_birzha_stunned_purge:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_birzha_stunned_purge:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_birzha_silenced = class({})

function modifier_birzha_silenced:IsDebuff()
	return true
end

function modifier_birzha_silenced:IsStunDebuff()
	return false
end

function modifier_birzha_silenced:IsPurgable()
	return true
end

function modifier_birzha_silenced:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}

	return state
end

function modifier_birzha_silenced:GetEffectName()
	return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_birzha_silenced:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

 modifier_birzha_orb_effect_lua = class({})

function modifier_birzha_orb_effect_lua:IsHidden()
	return true
end

function modifier_birzha_orb_effect_lua:IsDebuff()
	return false
end

function modifier_birzha_orb_effect_lua:IsPurgable()
	return false
end

function modifier_birzha_orb_effect_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_birzha_orb_effect_lua:OnCreated( kv )
	self.ability = self:GetAbility()
	self.cast = false
	self.records = {}
	self:StartIntervalThink(FrameTime())
	self.piska = nil
end

function modifier_birzha_orb_effect_lua:OnIntervalThink()
	if not IsServer() then return end
	if self:GetParent():GetUnitName() == "npc_dota_hero_void_spirit" then
		local ability = self:GetParent():FindAbilityByName("van_takeitboy")
		if ability and ability:IsFullyCastable() then
			if self.piska == nil then
				self.particle = ParticleManager:CreateParticle("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_whip_ambient.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    			ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_whip_end", self:GetParent():GetAbsOrigin(), true)
    			self.particle_2 = ParticleManager:CreateParticle("particles/van/van_effe.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    			ParticleManager:SetParticleControlEnt(self.particle_2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
    			self.piska = true
    		end
		else
			if self.particle then
				ParticleManager:DestroyParticle(self.particle, false)
    			ParticleManager:ReleaseParticleIndex(self.particle)
    			ParticleManager:DestroyParticle(self.particle_2, true)
    			ParticleManager:ReleaseParticleIndex(self.particle_2)
    			self.piska = nil
			end
		end
	end
end

function modifier_birzha_orb_effect_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,

		MODIFIER_EVENT_ON_ORDER,

		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}

	return funcs
end

function modifier_birzha_orb_effect_lua:OnAttack( params )
	if params.attacker~=self:GetParent() then return end
	if self:ShouldLaunch( params.target ) then
		self.ability:UseResources( true, false, true )
		self.records[params.record] = true
		if self.ability.OnOrbFire then self.ability:OnOrbFire( params ) end
	end
	self.cast = false
end

function modifier_birzha_orb_effect_lua:GetModifierProcAttack_Feedback( params )
	if self.records[params.record] then
		if self.ability.OnOrbImpact then self.ability:OnOrbImpact( params ) end
	end
end

function modifier_birzha_orb_effect_lua:OnAttackFail( params )
	if self.records[params.record] then
		if self.ability.OnOrbFail then self.ability:OnOrbFail( params ) end
	end
end

function modifier_birzha_orb_effect_lua:OnAttackRecordDestroy( params )
	self.records[params.record] = nil
end

function modifier_birzha_orb_effect_lua:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	if params.ability then
		if params.ability==self:GetAbility() then
			self.cast = true
			return
		end

		-- if casting other ability that cancel channel while casting this ability, turn off
		local pass = false
		local behavior = params.ability:GetBehaviorInt()
		if self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL ) or 
			self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT ) or
			self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL )
		then
			local pass = true -- do nothing
		end

		if self.cast and (not pass) then
			self.cast = false
		end
	else
		-- if ordering something which cancel channel, turn off
		if self.cast then
			if self:FlagExist( params.order_type, DOTA_UNIT_ORDER_MOVE_TO_POSITION ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_MOVE_TO_TARGET )	or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_ATTACK_MOVE ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_ATTACK_TARGET ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_STOP ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_HOLD_POSITION )
			then
				self.cast = false
			end
		end
	end
end

function modifier_birzha_orb_effect_lua:GetModifierProjectileName()
	if not self.ability.GetProjectileName then return end
	if self:ShouldLaunch( self:GetCaster():GetAggroTarget() ) then
		return self.ability:GetProjectileName()
	end
end

function modifier_birzha_orb_effect_lua:ShouldLaunch( target )
	if self.ability:GetAutoCastState() then
		if self.ability.CastFilterResultTarget~=CDOTA_Ability_Lua.CastFilterResultTarget then
			if self.ability:CastFilterResultTarget( target )==UF_SUCCESS then
				self.cast = true
			end
		else
			local nResult = UnitFilter(
				target,
				self.ability:GetAbilityTargetTeam(),
				self.ability:GetAbilityTargetType(),
				self.ability:GetAbilityTargetFlags(),
				self:GetCaster():GetTeamNumber()
			)
			if nResult == UF_SUCCESS then
				self.cast = true
			end
		end
	end

	if self.cast and self.ability:IsFullyCastable() and (not self:GetParent():IsSilenced()) then
		return true
	end

	return false
end

function modifier_birzha_orb_effect_lua:FlagExist(a,b)--Bitwise Exist
	local p,c,d=1,0,b
	while a>0 and b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>1 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	return c==d
end















modifier_birzha_invul = class({})

function modifier_birzha_invul:IsDebuff()
	return false
end

function modifier_birzha_invul:IsStunDebuff()
	return false
end

function modifier_birzha_invul:IsPurgable()
	return false
end

function modifier_birzha_invul:IsPurgeException()
	return false
end

function modifier_birzha_invul:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}

	return state
end









modifier_birzha_illusion_cosmetics = class({})

function modifier_birzha_illusion_cosmetics:IsHidden()
	return true
end

function modifier_birzha_illusion_cosmetics:OnDestroy()
	if not IsServer() then return end
	if self:GetParent().NevermoreWings
	and self:GetParent().NevermorePauldrons
	and self:GetParent().NevermoreHead
	and self:GetParent().NevermoreArms
	and self:GetParent().NevermoreRocks then
		self:GetParent().NevermoreWings:Destroy()
		self:GetParent().NevermorePauldrons:Destroy()
		self:GetParent().NevermoreHead:Destroy()
		self:GetParent().NevermoreArms:Destroy()
		self:GetParent().NevermoreRocks:Destroy()
	end


	if self:GetParent().pudge_mask then
		self:GetParent().pudge_mask:Destroy()
	end

	if self:GetParent().ValakasHead
	and self:GetParent().ValakasWeapon
	and self:GetParent().ValakasHands then
		self:GetParent().ValakasHead:Destroy()
		self:GetParent().ValakasWeapon:Destroy()
		self:GetParent().ValakasHands:Destroy()
	end


	if self:GetParent().model_void_1
	and self:GetParent().model_void_2 then
		self:GetParent().model_void_1:Destroy()
		self:GetParent().model_void_2:Destroy()
	end



	if self:GetParent().PudgeBack then
		self:GetParent().PudgeBack:Destroy()
	end


	if self:GetParent().BountyWeapon then
		self:GetParent().BountyWeapon:Destroy()
	end


	if self:GetParent().PapichBloodShard
	and self:GetParent().PapichHead
	and self:GetParent().PapichPauldrons
	and self:GetParent().PapichPunch
	and self:GetParent().PapichCape
	and self:GetParent().PapichArmor then
		self:GetParent().PapichBloodShard:Destroy()
		self:GetParent().PapichHead:Destroy()
		self:GetParent().PapichPauldrons:Destroy()
		self:GetParent().PapichPunch:Destroy()
		self:GetParent().PapichCape:Destroy()
		self:GetParent().PapichArmor:Destroy()
	end


	if self:GetParent().BookLeft
	and self:GetParent().BookRight then
		self:GetParent().BookLeft:Destroy()
		self:GetParent().BookRight:Destroy()
	end


	if self:GetParent().SpectreScream and self:GetParent().SpectreWeapon then
		self:GetParent().SpectreScream:Destroy()
		self:GetParent().SpectreWeapon:Destroy()
	end




	if self:GetParent().TravomanCostume and self:GetParent().TravomanCart then
		self:GetParent().TravomanCostume:Destroy()
		self:GetParent().TravomanCart:Destroy()
	end

	

	if self:GetParent().AyanoHead and self:GetParent().AyanoArms and self:GetParent().AyanoBack and self:GetParent().AyanoShoulder and self:GetParent().AyanoLegs and self:GetParent().AyanoSword then
		self:GetParent().AyanoHead:Destroy()
		self:GetParent().AyanoArms:Destroy()
		self:GetParent().AyanoBack:Destroy()
		self:GetParent().AyanoShoulder:Destroy()
		self:GetParent().AyanoLegs:Destroy()
		self:GetParent().AyanoSword:Destroy()
	end



	if self:GetParent().BoyHead and self:GetParent().BoyWeapon and self:GetParent().BoyArmor and self:GetParent().BoyShoulder then
		self:GetParent().BoyHead:Destroy()
		self:GetParent().BoyWeapon:Destroy()
		self:GetParent().BoyArmor:Destroy()
		self:GetParent().BoyShoulder:Destroy()
	end
	
	
	











	if self:GetParent().RinSword then
		self:GetParent().RinSword:Destroy()
	end


	if self:GetParent().OverlordSword then
		self:GetParent().OverlordSword:Destroy()
	end

	if self:GetParent().brb_crown then
		self:GetParent().brb_crown:Destroy()
	end

	if self:GetParent().GorinStools
	and self:GetParent().TrollHead
	and self:GetParent().TrollShoulders
	and self:GetParent().TrollLod then
		self:GetParent().GorinStools:Destroy()
		self:GetParent().TrollHead:Destroy()
		self:GetParent().TrollShoulders:Destroy()
		self:GetParent().TrollLod:Destroy()
	end


	if self:GetParent().ZelenskyHead then
		self:GetParent().ZelenskyHead:Destroy()
	end

	if self:GetParent().JuggHead and self:GetParent().JugLegs and self:GetParent().JugSword then
		self:GetParent().JuggHead:Destroy()
		self:GetParent().JugLegs:Destroy()
		self:GetParent().JugSword:Destroy()
	end


	if self:GetParent().InvokerBelt
	and self:GetParent().InvokerBracer then
		self:GetParent().InvokerBelt:Destroy()
		self:GetParent().InvokerBracer:Destroy()
	end

	if self:GetParent().InvokerArms and self:GetParent().InvokerBack and self:GetParent().InvokerApexKid then
		self:GetParent().InvokerArms:Destroy()
		self:GetParent().InvokerBack:Destroy()
		self:GetParent().InvokerApexKid:Destroy()
	end


	if self:GetParent().WeaponMeepo then
		self:GetParent().WeaponMeepo:Destroy()
	end

	if self:GetParent().robbie_weapon then
		self:GetParent().robbie_weapon:Destroy()
	end


	if self:GetParent().Ricardo then
		self:GetParent().Ricardo:Destroy()
	end

	if self:GetParent().Stray1
	and self:GetParent().Stray2
	and self:GetParent().Stray3
	and self:GetParent().Stray4
	and self:GetParent().Stray5 then
		self:GetParent().Stray1:Destroy()
		self:GetParent().Stray2:Destroy()
		self:GetParent().Stray3:Destroy()
		self:GetParent().Stray4:Destroy()
		self:GetParent().Stray5:Destroy()
	end

	if self:GetParent().HeadSAaker then
		ParticleManager:DestroyParticle(self:GetParent().HeadSAaker, false)
		ParticleManager:ReleaseParticleIndex( self:GetParent().HeadSAaker )
	end
	if self:GetParent().WeaponShaker then
		ParticleManager:DestroyParticle(self:GetParent().WeaponShaker, false)
		ParticleManager:ReleaseParticleIndex( self:GetParent().WeaponShaker )
	end
	if self:GetParent().effectvan then
		ParticleManager:DestroyParticle(self:GetParent().effectvan, false)
		ParticleManager:ReleaseParticleIndex( self:GetParent().effectvan )
	end
	if self:GetParent().PudgeEffect then
		ParticleManager:DestroyParticle(self:GetParent().PudgeEffect, false)
		ParticleManager:ReleaseParticleIndex( self:GetParent().PudgeEffect )
	end
	if self:GetParent().WeaponEffect then
		ParticleManager:DestroyParticle(self:GetParent().WeaponEffect, false)
		ParticleManager:ReleaseParticleIndex( self:GetParent().WeaponEffect )
	end
	if self:GetParent().PapichEffect then
		ParticleManager:DestroyParticle(self:GetParent().PapichEffect, false)
		ParticleManager:ReleaseParticleIndex( self:GetParent().PapichEffect )
	end
	if self:GetParent().HeadEffect then
		ParticleManager:DestroyParticle(self:GetParent().HeadEffect, false)
		ParticleManager:ReleaseParticleIndex( self:GetParent().HeadEffect )
	end
	if self:GetParent().AmbientEffect then
		ParticleManager:DestroyParticle(self:GetParent().AmbientEffect, false)
		ParticleManager:ReleaseParticleIndex( self:GetParent().AmbientEffect )
	end
	if self:GetParent().stray_effect_1 then
		ParticleManager:DestroyParticle(self:GetParent().stray_effect_1, false)
		ParticleManager:ReleaseParticleIndex( self:GetParent().stray_effect_1 )		
	end
	if self:GetParent().stray_effect_2 then
		ParticleManager:DestroyParticle(self:GetParent().stray_effect_2, false)
		ParticleManager:ReleaseParticleIndex( self:GetParent().stray_effect_2 )
	end
end

function modifier_birzha_illusion_cosmetics:IsPurgable()
	return false
end

function modifier_birzha_illusion_cosmetics:IsPurgeException()
	return false
end