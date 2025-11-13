LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gypsy_tabor_illusion","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)

gypsy_tabor = class({})

function gypsy_tabor:Precache(context)
    local particle_list = 
    {
        "particles/gypsy_horse_endof_the_light_blinding_light_aoe.vpcf",
        "particles/gypsy_horse.vpcf",
        "particles/gypsy_horse_endof_the_light_blinding_light_aoe.vpcf",
        "particles/gypsy/skill_debosh.vpcf",
        "particles/gypsy/gypsy_multicast.vpcf",
        "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function gypsy_tabor:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_2")
end

function gypsy_tabor:OnSpellStart()
	if not IsServer() then return end
	local point = self:GetCursorPosition()

	if point == self:GetCaster():GetAbsOrigin() then
		point = point + self:GetCaster():GetForwardVector()
	end

	local distance = self:GetCastRange(self:GetCaster():GetAbsOrigin(),self:GetCaster()) + self:GetCaster():GetCastRangeBonus()

	local direction = point - self:GetCaster():GetAbsOrigin()
	direction.z = 0
	direction = direction:Normalized()

	local velocity = direction * 1500
	local distance_teleport = (point - self:GetCaster():GetAbsOrigin()):Length2D()

	local projectile =
	{
		Ability				= self,
		vSpawnOrigin		= self:GetCaster():GetAbsOrigin(),
		fDistance			= distance_teleport,
		fStartRadius		= 325,
		fEndRadius			= 325,
		Source				= self:GetCaster(),
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= self:GetAbilityTargetTeam(),
		iUnitTargetFlags	= self:GetAbilityTargetFlags(),
		iUnitTargetType		= self:GetAbilityTargetType(),
		fExpireTime 		= GameRules:GetGameTime() + 10.0,
		bDeleteOnHit		= false,
		vVelocity			= Vector(velocity.x,velocity.y,0),
		bProvidesVision		= true,
		iVisionRadius 		= vision_aoe,
		iVisionTeamNumber 	= self:GetCaster():GetTeamNumber(),
		ExtraData			= {teleport = 1}
	}

	ProjectileManager:CreateLinearProjectile(projectile)

	EmitSoundOnLocationWithCaster(point, "GypsyTabor", self:GetCaster())
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gypsy_tabor_illusion", {x=direction.x,y=direction.y})
end

function gypsy_tabor:OnProjectileHit_ExtraData(target, location, ExtraData)
	if ExtraData.teleport ~= nil and ExtraData.teleport == 1 then
		FindClearSpaceForUnit(self:GetCaster(), location, true)
		self:GetCaster():RemoveModifierByName("modifier_gypsy_tabor_illusion")
	end
	return false
end

modifier_gypsy_tabor_illusion = class({})

function modifier_gypsy_tabor_illusion:IsHidden()
	return true
end

function modifier_gypsy_tabor_illusion:OnCreated(data)
	if not IsServer() then return end

	local particle = ParticleManager:CreateParticle("particles/gypsy_horse_endof_the_light_blinding_light_aoe.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 2, Vector(150, 0, 0))
	ParticleManager:ReleaseParticleIndex(particle)

	self.particle = ParticleManager:CreateParticle("particles/gypsy_horse.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.particle, 1, Vector(data.x,data.y,0) * 1400)
    ParticleManager:SetParticleControl(self.particle, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.particle, true, false, -1, false, false)

	self:GetParent():AddNoDraw()
end

function modifier_gypsy_tabor_illusion:OnDestroy()
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/gypsy_horse_endof_the_light_blinding_light_aoe.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 2, Vector(150, 0, 0))
	ParticleManager:ReleaseParticleIndex(particle)
	self:GetParent():RemoveNoDraw()
end

function modifier_gypsy_tabor_illusion:IsPurgable() return false end
function modifier_gypsy_tabor_illusion:IsPurgeException() return false end
function modifier_gypsy_tabor_illusion:CheckState()
	return
	{
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_SILENCED] = true,
	}
end

LinkLuaModifier("modifier_gypsy_debosh_caster_debuff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_debosh_target_debuff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)

gypsy_debosh = class({})

function gypsy_debosh:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	local debuff_duration = self:GetSpecialValueFor( "debuff_duration" )
	local info = 
	{
		EffectName = "particles/gypsy/skill_debosh.vpcf",
		Dodgeable = true,
		Ability = self,
		ProvidesVision = true,
		VisionRadius = 600,
		bVisibleToEnemies = true,
		iMoveSpeed = 1500,
		Source = self:GetCaster(),
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		Target = target,
		bReplaceExisting = false,
	}
	local bottle = ProjectileManager:CreateTrackingProjectile(info)
	if not self:GetCaster():HasTalent("special_bonus_birzha_gypsy_6") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gypsy_debosh_caster_debuff", {duration = debuff_duration * (1-self:GetCaster():GetStatusResistance())})
	end
	self:GetCaster():EmitSound("GypsyDebosh")
end

function gypsy_debosh:OnProjectileHit(target,_)
	if target:TriggerSpellAbsorb(self) then return end
	if target:IsMagicImmune() then return end 

	if target ~= nil and target:IsAlive() then

		local stun_duration = self:GetSpecialValueFor( "stun_duration" )

		target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = stun_duration * (1 - target:GetStatusResistance())})

		local bonus_damage = self:GetSpecialValueFor( "bonus_damage" )

		local damage = self:GetSpecialValueFor( "damage" )

		local modifier = target:FindModifierByName( "modifier_gypsy_debosh_target_debuff" )

		local effect_duration = self:GetSpecialValueFor( "effect_duration" )

		target:AddNewModifier(self:GetCaster(), self, "modifier_gypsy_debosh_target_debuff", {duration = effect_duration * (1-target:GetStatusResistance())})

		local modifier = target:FindModifierByName("modifier_gypsy_debosh_target_debuff")

		local full_damage = damage
		if modifier then
			full_damage = full_damage + (bonus_damage * modifier:GetStackCount())
		end

		target:EmitSound("GypsyDebosh")

		ApplyDamage({attacker = self:GetCaster(), victim = target, ability = self, damage = full_damage, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

modifier_gypsy_debosh_target_debuff = class({})

function modifier_gypsy_debosh_target_debuff:IsHidden()
	return false
end

function modifier_gypsy_debosh_target_debuff:IsPurgable() return false end

function modifier_gypsy_debosh_target_debuff:OnCreated()
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_gypsy_debosh_target_debuff:OnRefresh()
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_gypsy_debosh_target_debuff:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_gypsy_debosh_target_debuff:GetModifierMagicalResistanceBonus()
	if not self:GetCaster():HasShard() then return end
	return self:GetAbility():GetSpecialValueFor("shard_magic_resist_per_effect") * self:GetStackCount()
end

modifier_gypsy_debosh_caster_debuff = class({})

function modifier_gypsy_debosh_caster_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_MISS_PERCENTAGE }
end

function modifier_gypsy_debosh_caster_debuff:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor( "magic_resist" )
end

function modifier_gypsy_debosh_caster_debuff:GetModifierMiss_Percentage()
	return 100
end

LinkLuaModifier( "modifier_gypsy_lucky", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gypsy_lucky_use", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE )

gypsy_lucky = class({})

function gypsy_lucky:GetIntrinsicModifierName()
	return "modifier_gypsy_lucky"
end

modifier_gypsy_lucky = class({})

function modifier_gypsy_lucky:IsPurgable()
	return false
end

function modifier_gypsy_lucky:IsHidden()
	return true
end

function modifier_gypsy_lucky:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end

function modifier_gypsy_lucky:OnCreated()
    if not IsServer() then return end
    self.useless_abilities = 
    {
        ["gypsy_steal"] = true,
        ["item_bag_of_gold"] = true,
        ["item_bag_of_gold_event"] = true,
        ["item_treasure_chest"] = true,
        ["item_treasure_chest_winter"] = true,
        ["item_treasure_chest_bp_fake"] = true,
        ["item_bag_of_gold_bp_fake"] = true,
        ["item_bag_of_gold_van"] = true,
        ["item_hallowen_birzha_candy"] = true,
        ["item_ultimate_mem"] = true,
        ["item_moon_shard"] = true,
        ["Durov_omni_slash"] = true,
    }
end

function modifier_gypsy_lucky:OnAbilityFullyCast( params )
	if params.unit~=self:GetCaster() then return end
	if params.ability==self:GetAbility() then return end
	if self:GetCaster():PassivesDisabled() then return end

	if not params.target then return end
	if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_POINT ) ~= 0 then return end
	if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET ) ~= 0 then return end
	if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_CHANNELLED ) ~= 0 then return end

    if self.useless_abilities[params.ability:GetAbilityName()] then
        return
    end

	local target = params.target
	local multicast_multi = 1

	self.chance_2 = self:GetAbility():GetSpecialValueFor( "chance_multi_1" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_8")
	self.chance_3 = self:GetAbility():GetSpecialValueFor( "chance_multi_2" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_8")
	self.chance_4 = self:GetAbility():GetSpecialValueFor( "chance_multi_3" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_8")
	self.chance_5 = self:GetAbility():GetSpecialValueFor( "chance_multi_4" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_8")

	if RollPseudoRandomPercentage(self.chance_5, 6, self:GetParent()) then 
		multicast_multi = 5 
	else 
		if RollPseudoRandomPercentage(self.chance_4, 7, self:GetParent()) then 
			multicast_multi = 4 
		else 
			if RollPseudoRandomPercentage(self.chance_3, 8, self:GetParent()) then
				multicast_multi = 3 
			else
				if RollPseudoRandomPercentage(self.chance_2, 9, self:GetParent()) then
					multicast_multi = 2 
				end
			end
		end
	end

	local delay = FrameTime()
	local single = false
	self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_gypsy_lucky_use", { ability = params.ability:entindex(), target = target:entindex(), multicast = multicast_multi, delay = delay, single = single, } )
end

modifier_gypsy_lucky_use = class({})

function modifier_gypsy_lucky_use:IsHidden()
	return true
end

function modifier_gypsy_lucky_use:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_gypsy_lucky_use:IsPurgable()
	return false
end

function modifier_gypsy_lucky_use:IsPurgeException() return false end

function modifier_gypsy_lucky_use:RemoveOnDeath()
	return false
end

function modifier_gypsy_lucky_use:OnCreated( kv )
	if not IsServer() then return end
	self.caster = self:GetParent()
	self.ability = EntIndexToHScript( kv.ability )
	self.target = EntIndexToHScript( kv.target )
	self.multicast = kv.multicast
	self.delay = kv.delay
	self.single = kv.single==1
	self.buffer_range = 600
	self:SetStackCount( self.multicast )

	self.casts = 0
	if self.multicast==1 then
		self:Destroy()
		return
	end

	self.targets = {}
	self.targets[self.target] = true
	self.radius = self.ability:GetCastRange( self.target:GetOrigin(), self.target ) + self.buffer_range
	self.target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY

	if self.target:GetTeamNumber()~=self.caster:GetTeamNumber() then
		self.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	end

	self.target_type = self.ability:GetAbilityTargetType()
	if self.target_type==DOTA_UNIT_TARGET_CUSTOM then
		self.target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	end

	self.target_flags = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	if bit.band( self.ability:GetAbilityTargetFlags(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES ) ~= 0 then
		self.target_flags = self.target_flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end

	self:PlayEffects( self.multicast )
	self:StartIntervalThink( self.delay )
end

function modifier_gypsy_lucky_use:OnIntervalThink()
	local current_target = nil

	if self.single then
		current_target = self.target
	else
		local units = FindUnitsInRadius( self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, self.radius, self.target_team, self.target_type, self.target_flags, FIND_CLOSEST, false )
		if #units <= 0 then
			self:StartIntervalThink( -1 )
			self:Destroy()
			return
		end
		
		local unit = units[RandomInt(1, #units)]

		local filter = false
		if self.ability.CastFilterResultTarget then
			filter = self.ability:CastFilterResultTarget( unit ) == UF_SUCCESS
		else
			filter = true
		end

		if filter then
			current_target = unit
		end


		if not current_target then
			self:StartIntervalThink( -1 )
			self:Destroy()
			return
		end
	end

	self.caster:SetCursorCastTarget( current_target )
	self.ability:OnSpellStart()

	self.casts = self.casts + 1
	if self.casts>=(self.multicast-1) then
		self:StartIntervalThink( -1 )
		self:Destroy()
	end
end

function modifier_gypsy_lucky_use:PlayEffects( value )
	local nFXIndex = ParticleManager:CreateParticle( "particles/gypsy/gypsy_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( value, 2, 1 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	self:GetParent():EmitSound("GypsyMulticast")
end

LinkLuaModifier( "gypsy_steal_lua", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "gypsy_steal_lua_scepter", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "gypsy_steal_hidden", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE )

gypsy_steal = class({})
gypsy_steal_slot1 = class({})
gypsy_steal_slot2 = class({})

gypsy_steal.heroesData = {} -- Кто такой скилл использовал

gypsy_steal.currentSpell = nil
gypsy_steal.currentSpell_2 = nil

gypsy_steal.stolenSpell = nil
gypsy_steal.stolenSpell_2 = nil

gypsy_steal.slot1 = "gypsy_steal_slot1"
gypsy_steal.slot2 = "gypsy_steal_slot2"

function gypsy_steal:OnInventoryContentsChanged()
    for i=0, 8 do
        local item = self:GetCaster():GetItemInSlot(i)
        if item then
            if item.scepter then return end
            if (item:GetName() == "item_ultimate_scepter" or item:GetName() == "item_ultimate_mem" ) and not item.scepter then
                if self:GetCaster():IsRealHero() then
                    item.scepter = true
                    item:SetSellable(false)
                    item:SetDroppable(false)
                end
            end
        end
    end
end

function gypsy_steal:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function gypsy_steal:GetIntrinsicModifierName()
	return "gypsy_steal_hidden"
end

function gypsy_steal:CastFilterResultTarget( hTarget )
	if IsServer() then
		if self:GetLastSpell( hTarget )==nil then
			return UF_FAIL_OTHER
		end
	end

	local nResult = UnitFilter(
		hTarget,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
		self:GetCaster():GetTeamNumber()
	)

	if hTarget == self:GetCaster() then
		return UF_FAIL_OTHER
	end

	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

function gypsy_steal:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb( self ) then
		return
	end

	local duration_silence = self:GetSpecialValueFor("duration_silence") + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_5")

	if caster:GetTeamNumber() ~= target:GetTeamNumber() then
		target:AddNewModifier(caster, self, "modifier_silence", {duration = duration_silence * (1-target:GetStatusResistance())})
	end

	self.stolenSpell = {}
	self.stolenSpell.lastSpell = self:GetLastSpell( target )

	local info = {
		Target = caster,
		Source = target,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf",
		iMoveSpeed = 1200,
		vSourceLoc = target:GetAbsOrigin(),             
		bDrawsOnMinimap = false,                         
		bDodgeable = false,                               
		bVisibleToEnemies = true,                        
		bReplaceExisting = false,                         
	}

	ProjectileManager:CreateTrackingProjectile(info)

	self:GetCaster():EmitSound("GypsyUltimate")
	target:EmitSound("Hero_Rubick.SpellSteal.Target")
end

function gypsy_steal:OnProjectileHit( target, location )
	if target == nil then return end
	if not target:IsAlive() then return end

	if self:GetCaster():HasScepter() then
		self:SetStolenSpellScepter( self.stolenSpell )
		self.stolenSpell = nil
		local steal_duration = self:GetSpecialValueFor("duration")
		target:AddNewModifier( self:GetCaster(), self, "gypsy_steal_lua", { duration = steal_duration } )
		target:EmitSound("Hero_Rubick.SpellSteal.Complete")
	else
		self:SetStolenSpell( self.stolenSpell )
		self.stolenSpell = nil
		local steal_duration = self:GetSpecialValueFor("duration")
		target:AddNewModifier( self:GetCaster(), self, "gypsy_steal_lua", { duration = steal_duration } )
		target:EmitSound("Hero_Rubick.SpellSteal.Complete")
	end
end

function gypsy_steal:SetLastSpell( hHero, hSpell )
	local heroData = nil
	for _,data in pairs(gypsy_steal.heroesData) do
		if data.handle==hHero then
			heroData = data
			break
		end
	end

	if heroData then
		heroData.lastSpell = hSpell
	else
		local newData = {}
		newData.handle = hHero
		newData.lastSpell = hSpell
		table.insert( gypsy_steal.heroesData, newData )
	end
end

function gypsy_steal:GetLastSpell( hHero )
	local heroData = nil
	for _,data in pairs(gypsy_steal.heroesData) do
		if data.handle==hHero then
			heroData = data
			break
		end
	end

	if heroData then
		return heroData.lastSpell
	end

	return nil
end

function gypsy_steal:SetStolenSpell( spellData )
	if spellData == nil then return end
	local spell = spellData.lastSpell
	local interaction = spellData.interaction

	if self.currentSpell~=nil then 
		if self.currentSpell:GetAbilityName() ~= spell:GetAbilityName() then
			self:ForgetSpell()
		else
			return
		end
	end

    local old_spell = false
    for _,hSpell in pairs(self:GetCaster().spell_steal_history) do
        if hSpell ~= nil and hSpell:GetAbilityName() == spell:GetAbilityName() then
            old_spell = true
            break
        end
    end

    if old_spell then
	    for id,hSpell in pairs(self:GetCaster().spell_steal_history) do
	        if hSpell ~= nil and hSpell:GetAbilityName() == spell:GetAbilityName() then
	            table.remove(self:GetCaster().spell_steal_history, id)
	        end
	    end
        self.currentSpell = self:GetCaster():FindAbilityByName(spell:GetAbilityName())
    else
        self.currentSpell = self:GetCaster():AddAbility( spell:GetAbilityName() )
        self.currentSpell:SetStolen(true)
        self.currentSpell:SetRefCountsModifiers(true)
    end
    self.currentSpell:SetHidden(false)
	self.currentSpell:SetLevel( spell:GetLevel() )
	if self.currentSpell.OnStolen then self.currentSpell:OnStolen( spell ) end
	self:GetCaster():SwapAbilities( self.slot1, self.currentSpell:GetAbilityName(), false, true )
end

function gypsy_steal:SetStolenSpellScepter( spellData )
	if spellData == nil then return end
	local spell = spellData.lastSpell
	local interaction = spellData.interaction

	if self.currentSpell~=nil then 
		if self.currentSpell:GetAbilityName() ~= spell:GetAbilityName() then
			self:ForgetSpellScepter()
		else
			return
		end
	end

    local old_spell = false
    for _,hSpell in pairs(self:GetCaster().spell_steal_history) do
        if hSpell ~= nil and hSpell:GetAbilityName() == spell:GetAbilityName() then
            old_spell = true
            break
        end
    end

    if old_spell then
	    for id,hSpell in pairs(self:GetCaster().spell_steal_history) do
	        if hSpell ~= nil and hSpell:GetAbilityName() == spell:GetAbilityName() then
	            table.remove(self:GetCaster().spell_steal_history, id)
	        end
	    end
        self.currentSpell = self:GetCaster():FindAbilityByName(spell:GetAbilityName())
    else
        self.currentSpell = self:GetCaster():AddAbility( spell:GetAbilityName() )
        self.currentSpell:SetStolen(true)
        self.currentSpell:SetRefCountsModifiers(true)
    end
    self.currentSpell:SetHidden(false)
	self.currentSpell:SetLevel( spell:GetLevel() )
	if self.currentSpell.OnStolen then self.currentSpell:OnStolen( spell ) end
	self:GetCaster():SwapAbilities( self.slot1, self.currentSpell:GetAbilityName(), false, true )
end

function gypsy_steal:ForgetSpell()
	if self.currentSpell~=nil then
		self.currentSpell:SetRefCountsModifiers(true)
		table.insert(self:GetCaster().spell_steal_history, self.currentSpell)
		if self.currentSpell.OnUnStolen then self.currentSpell:OnUnStolen() end
		self.currentSpell:SetHidden(true)
		self:GetCaster():SwapAbilities( self.currentSpell:GetAbilityName(), self.slot1, false, true )
		self.currentSpell = nil
	end
end

function gypsy_steal:ForgetSpellScepter()
	self:ForgetSpellScepterDelete()
	if self.currentSpell~=nil then
		self.currentSpell:SetRefCountsModifiers(true)
		self:GetCaster():SwapAbilities( self.currentSpell:GetAbilityName(), self.slot1, false, true )
		self:GetCaster():SwapAbilities( self.slot2, self.currentSpell:GetAbilityName(), false, true )
		self.currentSpell_2 = self.currentSpell
		local steal_duration = self:GetSpecialValueFor("duration")
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "gypsy_steal_lua_scepter", { duration = steal_duration } )
		self.currentSpell = nil
	end
end

function gypsy_steal:ForgetSpellScepterDelete()
	if self.currentSpell_2~=nil then
		self.currentSpell_2:SetRefCountsModifiers(true)
		table.insert(self:GetCaster().spell_steal_history, self.currentSpell_2)
		if self.currentSpell_2.OnUnStolen then self.currentSpell_2:OnUnStolen() end
		self.currentSpell_2:SetHidden(true)
		self:GetCaster():SwapAbilities( self.currentSpell_2:GetAbilityName(), self.slot2, false, true )
		self.currentSpell_2 = nil
	end
end

function gypsy_steal:GetAT()
	if self.abilityTable==nil then
		self.abilityTable = {}
	end
	return self.abilityTable
end

function gypsy_steal:GetATEmptyKey()
	local table = self:GetAT()
	local i = 1
	while table[i]~=nil do
		i = i+1
	end
	return i
end

function gypsy_steal:AddATValue( value )
	local table = self:GetAT()
	local i = self:GetATEmptyKey()
	table[i] = value
	return i
end

function gypsy_steal:RetATValue( key )
	local table = self:GetAT()
	local ret = table[key]
	table[key] = nil
	return ret
end

function gypsy_steal:DisplayAT()
	local table = self:GetAT()
	for k,v in pairs(table) do
		print(k,v)
	end
end

function gypsy_steal:FlagExist(a,b)
	local p,c,d=1,0,b
	while a>0 and b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>1 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	return c==d
end

function gypsy_steal:FlagAdd(a,b)
	if FlagExist(a,b) then
		return a
	else
		return a+b
	end
end

function gypsy_steal:FlagMin(a,b)
	if FlagExist(a,b) then
		return a-b
	else
		return a
	end
end

function gypsy_steal:BitXOR(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra~=rb then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    if a<b then a=b end
    while a>0 do
        local ra=a%2
        if ra>0 then c=c+p end
        a,p=(a-ra)/2,p*2
    end
    return c
end

function gypsy_steal:BitOR(a,b)
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>0 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

function gypsy_steal:BitNOT(n)
    local p,c=1,0
    while n>0 do
        local r=n%2
        if r<1 then c=c+p end
        n,p=(n-r)/2,p*2
    end
    return c
end

function gypsy_steal:BitAND(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

gypsy_steal_lua = class({})

function gypsy_steal_lua:IsHidden()
	return false
end

function gypsy_steal_lua:IsDebuff()
	return false
end

function gypsy_steal_lua:IsPurgable()
	return false
end

function gypsy_steal_lua:RemoveOnDeath()
	return not self:GetCaster():HasTalent("special_bonus_birzha_gypsy_1")
end

function gypsy_steal_lua:OnDestroy( kv )
	self:GetAbility():ForgetSpell()
end

gypsy_steal_lua_scepter = class({})

function gypsy_steal_lua_scepter:IsHidden()
	return false
end

function gypsy_steal_lua_scepter:IsDebuff()
	return false
end

function gypsy_steal_lua_scepter:IsPurgable()
	return false
end

function gypsy_steal_lua_scepter:RemoveOnDeath()
	return not self:GetCaster():HasTalent("special_bonus_birzha_gypsy_1")
end

function gypsy_steal_lua_scepter:OnDestroy( kv )
	self:GetAbility():ForgetSpellScepterDelete()
end

gypsy_steal_hidden = class({})

function gypsy_steal_hidden:IsHidden()
	return true
end

function gypsy_steal_hidden:IsDebuff()
	return false
end

function gypsy_steal_hidden:IsPurgable()
	return false
end

function gypsy_steal_hidden:RemoveOnDeath()
	return false
end

function gypsy_steal_hidden:OnCreated()
    if IsServer() then
        self:GetParent().spell_steal_history = {}
        self:StartIntervalThink(FrameTime())
    end
end

function gypsy_steal_hidden:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_EVENT_ON_MODIFIER_ADDED,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}

	return funcs
end

function gypsy_steal_hidden:OnIntervalThink()
    if IsServer() then
        local caster = self:GetParent()
        for i=#caster.spell_steal_history,1,-1 do
            local hSpell = caster.spell_steal_history[i]
            if hSpell and not hSpell:IsNull() then
                if hSpell:GetIntrinsicModifierName() ~= nil then
                    local find_intrinsic = caster:FindModifierByName(hSpell:GetIntrinsicModifierName())
                    if find_intrinsic then
                        find_intrinsic:Destroy()
                    end
                end
	            if hSpell:NumModifiersUsingAbility() <= 0 and not hSpell:IsChanneling() then
	            	hSpell:SetHidden(true)
	                self:GetCaster():RemoveAbility(hSpell:GetAbilityName())
	                table.remove(caster.spell_steal_history,i)
	            end
	        end
        end
    end
end

function gypsy_steal_hidden:OnAbilityFullyCast( params )
	if IsServer() then

		if params.unit == self:GetParent() then
			if self:GetParent():HasTalent("special_bonus_birzha_gypsy_3") then
				if params.ability then
					if params.ability == self:GetAbility().currentSpell then
						if params.ability:GetCooldownTimeRemaining() > 0 then
							if params.ability:GetCooldownTimeRemaining() - (params.ability:GetCooldown(params.ability:GetLevel() - 1) / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_3")) > 0 then
								local new_cooldown = params.ability:GetCooldownTimeRemaining() - (params.ability:GetCooldown(params.ability:GetLevel() - 1) / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_3"))
								params.ability:EndCooldown()
								params.ability:StartCooldown(new_cooldown)
							else
								params.ability:EndCooldown()
							end
						end
					end
				end
			end
		end

		if params.unit==self:GetParent() and (not params.ability:IsItem()) then
			return
		end
		if params.ability:IsItem() then
			return
		end
		if params.unit:IsIllusion() then
			return
		end

		if params.ability:IsStolen() then
			return
		end

		local useless_abilities = 
		{
			"haku_mask",
			"aang_quas",
			"aang_wex",
			"aang_exort",
			"aang_invoke",
			"aang_lunge",
			"aang_ice_wall",
			"aang_vacuum",
			"aang_fast_hit",
			"aang_jumping",
			"aang_agility",
			"aang_fire_hit",
			"aang_lightning",
			"aang_firestone",
			"aang_avatar",
			"kakashi_quas",
			"kakashi_wex",
			"kakashi_exort",
			"kakashi_invoke",
			"kakashi_lightning",
			"kakashi_raikiri",
			"kakashi_lightning_hit",
			"kakashi_shadow_clone",
			"kakashi_tornado",
			"kakashi_graze_wave",
			"kakashi_susano",
			"kakashi_ligning_sphere",
			"kakashi_meteor",
			"kakashi_sharingan",
			"rin_satana_explosion",
			"travoman_remote_mines",
			"travoman_focused_detonate",
			"jull_light_future",
			"jull_steal_time",
			"pyramide_passive",
			"pucci_restart_world",
			"haku_help",
			"pucci_time_acceleration",
			"Overlord_one_book",
			"Overlord_two_book",
			"Overlord_three_book",
			"overlord_spellbook_close",
			"migi_inside",
			"polnaref_stand",
			"polnaref_stand_inside",
			"horo_ultimate",
			"Miku_DanceSong_cancel",
			"Dio_TheWorld",
			"V1lat_ItsNotNormal",
			"V1lat_AiAiAi_slam",
			"yakubovich_roll",
			"yakubovich_roll_scepter",
			"yakubovich_roll_return",
			"yakubovich_roll_return_scepter",
			"Slidan_ReallyClassic",
			"Zema_cosmo_ray_stop",
			"monika_perception_teleport",
			"Robi_WeAreNumberOneTeleport",
			"goku_saiyan",
			"gypsy_tabor",
			"gypsy_gipnoz",
			"gypsy_lucky",
			"gypsy_debosh",
			"gypsy_steal_slot1",
			"gypsy_steal",
			"thomas_ability_two_one",
			"thomas_ability_three",
			"thomas_ability_two_two",
			"Miku_DanceSong",
			"morgenshtern_car_stop",
			"scp173_statue_aghanim_teleport",
			"scp173_statue_aghanim",
			"bigrussianboss_spise",
			"venom_reproduction",
			"garold_cloud",
			"hisoka_trap_teleport",
			"Kurumi_shard",
			"never_zxc",
			"gypsy_debosh",
			"Miku_BattleSong",
			"puchkov_hurricane",
			"mina_radiation_field",
			"saitama_react",
			"migi_aghanim_ability",
			"kaneki_feeling",
			"overlord_portal",
			"gorshok_spin_web",
			"Kurumi_scepter",
			"metagame_shadow_blade",
			"polnaref_stand_inside",
			"van_swallowmycum",
			"shelby_shard",
			"stray_shveps",
			"dio_roller",
			"morgenshtern_ice",
			"yakubovich_roll_scepter",
			"mina_suicide",
			"ponasenkov_ya_vas_killed",
            "Kirill_GiantArms",
            "Papich_StreamSnipers",
            "migi_mutation",
            "Ruby_RoseStrike",
            "Grem_HardSkeleton",
            "sonic_fast_sound",
            "sobolev_biceps",
            "horo_forest_wisdom",
            "Doljan_Intellect",
            "serega_pirat_bike",
            "serega_pirat_bike_release",
            "dwayne_fight_of_death",
            "dwayne_fight_of_death_cancel",
            "V1lat_AiAiAi",
            "kelthuzad_death_knight",
		}

		local stop_please = false

		for _, useless in pairs(useless_abilities) do
			if params.ability:GetAbilityName() == useless then
				stop_please = true
				break
			end
		end

		if stop_please then
			return
		end

		self:GetAbility():SetLastSpell( params.unit, params.ability )
	end
end


function gypsy_steal_hidden:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then 
		if params.inflictor ~= nil then
			if params.inflictor == self:GetAbility().currentSpell then
				if self:GetParent():HasTalent("special_bonus_birzha_gypsy_7") then
					return self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_7")
				end
			end
		end
	end
end

function gypsy_steal_hidden:OnModifierAdded(params)
	if not IsServer() then return end
	if params.unit == self:GetParent() then return end
	if params.added_buff:GetCaster() ~= self:GetParent() then return end
	if not params.added_buff:IsDebuff() then return end
	if params.added_buff:GetDuration() <= 0 then return end
	if params.added_buff:GetName() == "modifier_cyclone" then return end
	if params.added_buff:GetName() == "modifier_eul_cyclone" then return end
	if params.added_buff:GetName() == "modifier_eul_cyclone_thinker" then return end
	if params.added_buff:GetName() == "modifier_eul_wind_waker_thinker" then return end
	if params.added_buff:GetName() == "modifier_wind_waker" then return end
	if params.added_buff:GetAbility() ~= self:GetAbility().currentSpell then return end
	if not self:GetParent():HasTalent("special_bonus_birzha_gypsy_4") then return end
	local new_duration = params.added_buff:GetDuration() + (params.added_buff:GetDuration() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_4"))
	params.added_buff:SetDuration(new_duration, true)
end

--LinkLuaModifier("modifier_gypsy_gipnoz_attack","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_gypsy_gipnoz_buff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_gypsy_gipnoz_debuff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_gypsy_gipnoz_buff_hud","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_gypsy_gipnoz_debuff_hud","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
--
--gypsy_gipnoz = class({})
--
--function gypsy_gipnoz:GetIntrinsicModifierName() 
--	return "modifier_gypsy_gipnoz_attack"
--end
--
--modifier_gypsy_gipnoz_attack = class({})
--
--function modifier_gypsy_gipnoz_attack:IsHidden()
--	return true
--end
--
--function modifier_gypsy_gipnoz_attack:DeclareFunctions()
--	return 
--	{
--		MODIFIER_EVENT_ON_ATTACK_LANDED,
--	}
--end
--
--function modifier_gypsy_gipnoz_attack:OnAttackLanded( params )
--	if not IsServer() then return end
--	if params.attacker ~= self:GetParent() then return end
--	if params.attacker:IsIllusion() then return end
--	if params.attacker:PassivesDisabled() then return end
--	if params.target:IsWard() then return end	
--	if not params.target:IsRealHero() then return end
--
--	local stats_steal = self:GetAbility():GetSpecialValueFor("stats_steal")
--	local armor_steal = self:GetAbility():GetSpecialValueFor("armor_steal")
--	local duration = self:GetAbility():GetSpecialValueFor("duration_debuff") + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_6")
--
--	params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_gypsy_gipnoz_buff", {duration = duration})
--	params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_gypsy_gipnoz_debuff", {duration = duration})
--	params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_gypsy_gipnoz_buff_hud", {duration = duration})
--	params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_gypsy_gipnoz_debuff_hud", {duration = duration})
--end
--
--modifier_gypsy_gipnoz_buff_hud = class({})
--
--function modifier_gypsy_gipnoz_buff_hud:OnCreated(kv)
--	if not IsServer() then return end
--	self:StartIntervalThink(FrameTime())
--end
--
--function modifier_gypsy_gipnoz_buff_hud:OnIntervalThink()
--	if not IsServer() then return end
--	local modifiers = self:GetParent():FindAllModifiersByName("modifier_gypsy_gipnoz_buff")
--	self:SetStackCount(#modifiers)
--end
--
--function modifier_gypsy_gipnoz_buff_hud:DeclareFunctions()
--	return 
--	{
--		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
--		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
--		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
--		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
--
--	}
--end
--
--function modifier_gypsy_gipnoz_buff_hud:GetModifierPhysicalArmorBonus()
--    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor_steal")
--end
--
--function modifier_gypsy_gipnoz_buff_hud:GetModifierBonusStats_Strength()
--    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stats_steal")
--end
--
--function modifier_gypsy_gipnoz_buff_hud:GetModifierBonusStats_Agility()
--    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stats_steal")
--end
--
--function modifier_gypsy_gipnoz_buff_hud:GetModifierBonusStats_Intellect()
--    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stats_steal")
--end
--
--modifier_gypsy_gipnoz_debuff_hud = class({})
--
--function modifier_gypsy_gipnoz_debuff_hud:OnCreated()
--	if not IsServer() then return end
--	self:StartIntervalThink(FrameTime())
--end
--
--function modifier_gypsy_gipnoz_debuff_hud:OnIntervalThink()
--	if not IsServer() then return end
--	local modifiers = self:GetParent():FindAllModifiersByName("modifier_gypsy_gipnoz_debuff")
--	self:SetStackCount(#modifiers)
--end
--
--function modifier_gypsy_gipnoz_debuff_hud:DeclareFunctions()
--	return 
--	{
--		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
--		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
--		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
--		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
--
--	}
--end
--
--function modifier_gypsy_gipnoz_debuff_hud:GetModifierPhysicalArmorBonus()
--    return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor_steal") ) * -1
--end
--
--function modifier_gypsy_gipnoz_debuff_hud:GetModifierBonusStats_Strength()
--    return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stats_steal") ) * -1
--end
--
--function modifier_gypsy_gipnoz_debuff_hud:GetModifierBonusStats_Agility()
--    return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stats_steal") ) * -1
--end
--
--function modifier_gypsy_gipnoz_debuff_hud:GetModifierBonusStats_Intellect()
--    return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stats_steal") ) * -1
--end
--
--modifier_gypsy_gipnoz_buff = class({})
--
--function modifier_gypsy_gipnoz_buff:IsHidden()
--	return true
--end
--
--function modifier_gypsy_gipnoz_buff:GetAttributes()
--    return MODIFIER_ATTRIBUTE_MULTIPLE
--end
--
--modifier_gypsy_gipnoz_debuff = class({})
--
--function modifier_gypsy_gipnoz_debuff:IsHidden()
--	return true
--end
--
--function modifier_gypsy_gipnoz_debuff:GetAttributes()
--    return MODIFIER_ATTRIBUTE_MULTIPLE
--end
