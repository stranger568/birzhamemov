LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_miku_MusicWave", "abilities/heroes/miku.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_Miku_ritmic_song", "abilities/heroes/miku.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Miku_ritmic_song_buff", "abilities/heroes/miku.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Miku_ritmic_song_debuff", "abilities/heroes/miku.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Miku_ritmic_song_movespeed", "abilities/heroes/miku.lua", LUA_MODIFIER_MOTION_NONE )

Miku_MusicWave = class({})

function Miku_MusicWave:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Miku_MusicWave:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Miku_MusicWave:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Miku_MusicWave:OnSpellStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		if self:GetCaster():GetTeamNumber() ~= target:GetTeamNumber() then
			if target:TriggerSpellAbsorb(self) then return end
		end
		self:GetCaster():EmitSound("MikuWave")
		local head_particle = ParticleManager:CreateParticle("particles/miku/miku_musicwave.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(head_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(head_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(head_particle, 62, Vector(2, 0, 2))
		ParticleManager:ReleaseParticleIndex(head_particle)
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_miku_MusicWave", { starting_unit_entindex = target:entindex() })
	end
end

modifier_miku_MusicWave = class({})

function modifier_miku_MusicWave:IsHidden()		return true end
function modifier_miku_MusicWave:IsPurgable()		return false end
function modifier_miku_MusicWave:RemoveOnDeath()	return false end
function modifier_miku_MusicWave:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_miku_MusicWave:OnCreated(keys)
	if not IsServer() or not self:GetAbility() then return end
	self.int = self:GetCaster():GetIntellect() * (self:GetAbility():GetSpecialValueFor("int_mult") + self:GetCaster():FindTalentValue("special_bonus_birzha_miku_4"))
	self.arc_damage			= self:GetAbility():GetSpecialValueFor("damage") + self.int + self:GetCaster():FindTalentValue("special_bonus_birzha_miku_1")
	self.radius				= self:GetAbility():GetSpecialValueFor("radius") 
	self.jump_delay			= 0.25
	self.jump_count			= 10
	self.silence_duration = self:GetAbility():GetSpecialValueFor("silence_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_miku_2")
	self.buff_skill = false
	self.damage_type = DAMAGE_TYPE_MAGICAL
	self.starting_unit_entindex	= keys.starting_unit_entindex
	self.units_affected			= {}

	if self.starting_unit_entindex and EntIndexToHScript(self.starting_unit_entindex) then
		self.current_unit						= EntIndexToHScript(self.starting_unit_entindex)
		self.units_affected[self.current_unit]	= 1
		if self:GetCaster():GetTeamNumber() ~= self.current_unit:GetTeamNumber() then
			ApplyDamage({
				victim 			= self.current_unit,
				damage 			= self.arc_damage,
				damage_type		= self.damage_type,
				damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
				attacker 		= self:GetCaster(),
				ability 		= self:GetAbility()
			})
			self.current_unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_silence", { duration = self.silence_duration * (1-self.current_unit:GetStatusResistance()) } )
		else
			self.current_unit:Heal(self.arc_damage, self:GetAbility())
		end
		if self.current_unit:HasModifier("modifier_Miku_ritmic_song") then
			self.buff_skill = true
			self.current_unit:RemoveModifierByName("modifier_Miku_ritmic_song")
		end
	else
		if not self:IsNull() then
            self:Destroy()
        end
		return
	end
	
	self.unit_counter = 0
	self:StartIntervalThink(self.jump_delay)
end

function modifier_miku_MusicWave:OnIntervalThink()
	self.zapped = false
	
	if (self.unit_counter >= self.jump_count and self.jump_count > 0) or not self.zapped then
		for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.current_unit:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)) do
			if not self.units_affected[enemy] and enemy ~= self.current_unit and enemy ~= self.previous_unit then
				self.lightning_particle = ParticleManager:CreateParticle("particles/miku/miku_musicwave.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.current_unit)
				ParticleManager:SetParticleControlEnt(self.lightning_particle, 0, self.current_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", self.current_unit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.lightning_particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(self.lightning_particle, 62, Vector(2, 0, 2))
				ParticleManager:ReleaseParticleIndex(self.lightning_particle)
				
				self.unit_counter						= self.unit_counter + 1
				self.previous_unit						= self.current_unit
				self.current_unit						= enemy
				
				if self.units_affected[self.current_unit] then
					self.units_affected[self.current_unit]	= self.units_affected[self.current_unit] + 1
				else
					self.units_affected[self.current_unit]	= 1
				end
				
				self.zapped								= true
				if self:GetCaster():GetTeamNumber() ~= enemy:GetTeamNumber() then
					ApplyDamage({
						victim 			= enemy,
						damage 			= self.arc_damage,
						damage_type		= self.damage_type,
						damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
						attacker 		= self:GetCaster(),
						ability 		= self:GetAbility()
					})
					enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_silence", { duration = self.silence_duration * (1-enemy:GetStatusResistance()) } )
					if self.buff_skill then
						local Miku_ritmic_song = self:GetCaster():FindAbilityByName("Miku_ritmic_song")
						if Miku_ritmic_song and Miku_ritmic_song:GetLevel() > 0 then
							enemy:AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("Miku_ritmic_song"), "modifier_Miku_ritmic_song_debuff", { duration =  self:GetCaster():FindAbilityByName("Miku_ritmic_song"):GetSpecialValueFor("debuff_duration") * (1 - enemy:GetStatusResistance()) })
						end
					end
					break
				else
					enemy:Heal(self.arc_damage, self:GetAbility())
					if self.buff_skill then
						local Miku_ritmic_song = self:GetCaster():FindAbilityByName("Miku_ritmic_song")
						if Miku_ritmic_song and Miku_ritmic_song:GetLevel() > 0 then
							enemy:AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("Miku_ritmic_song"), "modifier_Miku_ritmic_song_buff", {duration =  self:GetCaster():FindAbilityByName("Miku_ritmic_song"):GetSpecialValueFor("buff_duration")})
						end
					end
					break
				end
			end
		end
		
		if (self.unit_counter >= self.jump_count and self.jump_count > 0) or not self.zapped then
			self:StartIntervalThink(-1)
			if not self:IsNull() then
                self:Destroy()
            end
		end
	end
end

LinkLuaModifier( "modifier_miku_MusicBarrier", "abilities/heroes/miku.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_miku_MusicBarrier_buff", "abilities/heroes/miku.lua", LUA_MODIFIER_MOTION_NONE )

Miku_MusicBarrier = class({})

function Miku_MusicBarrier:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Miku_MusicBarrier:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Miku_MusicBarrier:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Miku_MusicBarrier:GetAOERadius()
	return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_miku_3")
end

function Miku_MusicBarrier:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	CreateModifierThinker(self:GetCaster(), self, "modifier_miku_MusicBarrier", {duration = duration}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
end

modifier_miku_MusicBarrier = class({})
modifier_miku_MusicBarrier.units = {}

function modifier_miku_MusicBarrier:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_miku_3")
	if not IsServer() then return end
	self.units = {}
	self:GetCaster():EmitSound("MikuBarrier")
	self.particle = ParticleManager:CreateParticle("particles/miku/miku_musicbarrier.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius, self.radius, 1))
	self:AddParticle(self.particle, false, false, 1, false, false)
end

function modifier_miku_MusicBarrier:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("MikuBarrier")
end

function modifier_miku_MusicBarrier:IsAura()					return true end
function modifier_miku_MusicBarrier:IsAuraActiveOnDeath() 		return false end
function modifier_miku_MusicBarrier:GetAuraDuration()			return 0.1 end
function modifier_miku_MusicBarrier:GetAuraRadius()				return self.radius end
function modifier_miku_MusicBarrier:GetAuraSearchFlags()		return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_miku_MusicBarrier:GetAuraSearchTeam()			return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_miku_MusicBarrier:GetAuraSearchType()			return DOTA_UNIT_TARGET_ALL end
function modifier_miku_MusicBarrier:GetModifierAura()			return "modifier_miku_MusicBarrier_buff" end

modifier_miku_MusicBarrier_buff = class({})

function modifier_miku_MusicBarrier_buff:IsHidden() return self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() end

function modifier_miku_MusicBarrier_buff:OnCreated()
	if not IsServer() then return end
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then return end
	if self:GetAuraOwner():FindModifierByName("modifier_miku_MusicBarrier").units[self:GetParent():entindex()] == nil then
		local damage = self:GetAbility():GetSpecialValueFor("damage_base") + (self:GetAbility():GetSpecialValueFor("int_scale") * self:GetCaster():GetIntellect())
		ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, ability=self:GetAbility(), damage_type = DAMAGE_TYPE_MAGICAL })
		self:GetAuraOwner():FindModifierByName("modifier_miku_MusicBarrier").units[self:GetParent():entindex()] = self:GetParent()
	end
end

function modifier_miku_MusicBarrier_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_miku_MusicBarrier_buff:GetModifierAttackSpeedBonus_Constant()
	if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then return end
	return self:GetAbility():GetSpecialValueFor("attackspeed") + self:GetCaster():FindTalentValue("special_bonus_birzha_miku_6")
end

LinkLuaModifier("modifier_Miku_HealSound", "abilities/heroes/miku", LUA_MODIFIER_MOTION_NONE)

Miku_HealSound = class({}) 

function Miku_HealSound:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_miku_7")
end

function Miku_HealSound:GetCastRange(location, target)
	return self:GetSpecialValueFor("radius")
end

function Miku_HealSound:GetIntrinsicModifierName()
    return "modifier_Miku_HealSound"
end

modifier_Miku_HealSound = class({}) 

function modifier_Miku_HealSound:IsHidden()      return true end
function modifier_Miku_HealSound:IsPurgable()    return false end

function modifier_Miku_HealSound:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_Miku_HealSound:OnAttackLanded( params )
    if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.attacker:IsIllusion() then return end
	if params.attacker:PassivesDisabled() then return end
	if params.target:IsWard() then return end

	local target = params.target
    local heal = self:GetAbility():GetSpecialValueFor("heal")
	local heal_percent = (self:GetAbility():GetSpecialValueFor("heal_percent") + self:GetCaster():FindTalentValue("special_bonus_birzha_miku_5")) / 100
	local radius = self:GetAbility():GetSpecialValueFor("radius")

    if self:GetAbility():IsFullyCastable() then        
    	local particle = ParticleManager:CreateParticle("particles/miku/miku_healsound.vpcf",  PATTACH_ABSORIGIN, self:GetParent())   
		local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for _,unit in pairs(targets) do
			local fullheal = heal + (unit:GetMaxHealth() * heal_percent)
			unit:Heal(fullheal, self:GetAbility())
		end	       
        self:GetAbility():UseResources(false, false, false,true)
        self:GetParent():EmitSound("MikuUhh")
    end
end

LinkLuaModifier("modifier_Miku_DanceSong_aura", "abilities/heroes/miku", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Miku_DanceSong_debuff", "abilities/heroes/miku", LUA_MODIFIER_MOTION_NONE)

Miku_DanceSong = class({}) 

function Miku_DanceSong:OnUpgrade()
	if not IsServer() then return end
	local dance = self:GetCaster():FindAbilityByName("Miku_DanceSong_cancel")
	if dance then
		dance:SetLevel(1)
	end
	local ability = self:GetCaster():FindAbilityByName("Miku_BattleSong")
	if ability then
		local level = self:GetLevel()
		if level > 0 then
			ability:SetLevel(level)
		end
	end
end

function Miku_DanceSong:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Miku_DanceSong:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Miku_DanceSong:GetCastRange(location, target)
	return self:GetSpecialValueFor("radius")
end

function Miku_DanceSong:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_miku_8")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_siren_song_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Miku_DanceSong_aura", {duration = duration})
	self:GetCaster():EmitSound("MikuUltimate")
	ParticleManager:ReleaseParticleIndex(pfx)
end

modifier_Miku_DanceSong_aura = class({})

function modifier_Miku_DanceSong_aura:IsPurgable() return false end
function modifier_Miku_DanceSong_aura:IsPurgeException() return false end
function modifier_Miku_DanceSong_aura:IsAura() return true end
function modifier_Miku_DanceSong_aura:GetAuraDuration() return 0.5 end
function modifier_Miku_DanceSong_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_Miku_DanceSong_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_Miku_DanceSong_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_Miku_DanceSong_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_ALL end
function modifier_Miku_DanceSong_aura:GetModifierAura() return "modifier_Miku_DanceSong_debuff" end

function modifier_Miku_DanceSong_aura:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }
end

function modifier_Miku_DanceSong_aura:GetActivityTranslationModifiers()
    return "dance"
end

function modifier_Miku_DanceSong_aura:OnCreated()
	if not IsServer() then return end
	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_song_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	self:GetCaster():SwapAbilities(self:GetAbility():GetAbilityName(), "Miku_DanceSong_cancel", false, true)
end

function modifier_Miku_DanceSong_aura:OnDestroy()
	if not IsServer() then return end
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
	self:GetCaster():StopSound("MikuUltimate")
	self:GetCaster():SwapAbilities(self:GetAbility():GetAbilityName(), "Miku_DanceSong_cancel", true, false)
end

modifier_Miku_DanceSong_debuff = class({})

function modifier_Miku_DanceSong_debuff:IsDebuff() return true end
function modifier_Miku_DanceSong_debuff:IsPurgable() return false end
function modifier_Miku_DanceSong_debuff:IsPurgeException() return false end

function modifier_Miku_DanceSong_debuff:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
	self:OnIntervalThink()
	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_song_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end

function modifier_Miku_DanceSong_debuff:OnIntervalThink()
	if not IsServer() then return end

	if self:GetParent():IsMagicImmune() then return end

	local mana = self:GetAbility():GetSpecialValueFor("mana_spend") / 100
	local reduce_mana = (self:GetParent():GetMana() * mana) * FrameTime()

	if ( self:GetParent():GetMana() >= reduce_mana ) then

		self:GetParent():Script_ReduceMana(reduce_mana, self:GetAbility())

		if self:GetCaster():GetMana() < self:GetCaster():GetMaxMana() then
			self:GetCaster():GiveMana(reduce_mana)
		else
			local friendly = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
			local heroes_mana = {}
			if #friendly > 0 then
	            for _, i in ipairs(friendly) do
	                table.insert(heroes_mana, {hero = i, mana = i:GetMana()} )
	            end    
	            table.sort( heroes_mana, function(x,y) return y.mana < x.mana end )
	            heroes_mana[#heroes_mana].hero:GiveMana(reduce_mana)
	        end
		end
	end
end

function modifier_Miku_DanceSong_debuff:OnDestroy()
	if not IsServer() then return end

	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end

function modifier_Miku_DanceSong_debuff:CheckState()
	if self:GetParent():IsMagicImmune() then return end

    local state = 
    {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NIGHTMARED] = true,
		[MODIFIER_STATE_STUNNED] = true,
    }

    if self:GetCaster():HasScepter() then
		state = 
		{
			[MODIFIER_STATE_NIGHTMARED] = true,
			[MODIFIER_STATE_STUNNED] = true,
	    }
    end

    return state
end

function modifier_Miku_DanceSong_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end

function modifier_Miku_DanceSong_debuff:GetModifierIncomingDamage_Percentage()
	if self:GetParent():IsMagicImmune() then
   		return self:GetAbility():GetSpecialValueFor("bonus_damage")
   	end
   	if self:GetCaster():HasScepter() then
   		return self:GetAbility():GetSpecialValueFor("scepter_damage")
   	end
end

Miku_DanceSong_cancel = class({})

function Miku_DanceSong_cancel:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():RemoveModifierByName("modifier_Miku_DanceSong_aura")
end

Miku_ritmic_song = class({})

function Miku_ritmic_song:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Miku_ritmic_song:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Miku_ritmic_song:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Miku_ritmic_song:OnSpellStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		local base_mana = self:GetSpecialValueFor("base_mana")
		local perc_mana = self:GetSpecialValueFor("perc_mana")
		local mana = base_mana + (self:GetCaster():GetMaxMana() / 100 * perc_mana)

		if self:GetCaster():GetTeamNumber() ~= target:GetTeamNumber() then
			if target:TriggerSpellAbsorb(self) then return end
		end

		self:GetCaster():EmitSound("MikuStart")

		if target:IsIllusion() then
        	target:Kill( self, self:GetCaster() )
    	end

		if self:GetCaster():GetTeamNumber() == target:GetTeamNumber() then
			target:GiveMana(mana)
			target:AddNewModifier(self:GetCaster(), self, "modifier_Miku_ritmic_song_buff", {duration =  self:GetSpecialValueFor("debuff_duration")})
		else 
			target:SpendMana( mana, self )
			target:AddNewModifier(self:GetCaster(), self, "modifier_Miku_ritmic_song_debuff", { duration =  self:GetSpecialValueFor("debuff_duration") * (1-target:GetStatusResistance()) })
		end

		target:AddNewModifier(self:GetCaster(), self, "modifier_Miku_ritmic_song", {duration = self:GetSpecialValueFor("duration")}) 
	end
end

modifier_Miku_ritmic_song = class({})

function modifier_Miku_ritmic_song:IsPurgable() return true end
function modifier_Miku_ritmic_song:IsPurgeException() return true end

function modifier_Miku_ritmic_song:OnCreated()
	if not IsServer() then return end
	self.pfx = ParticleManager:CreateParticle("particles/miku_ritmic.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end

function modifier_Miku_ritmic_song:OnDestroy()
	if not IsServer() then return end
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end

modifier_Miku_ritmic_song_buff = class({})

function modifier_Miku_ritmic_song_buff:IsPurgable() return true end
function modifier_Miku_ritmic_song_buff:IsPurgeException() return true end

function modifier_Miku_ritmic_song_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_morphling_morph_target.vpcf"
end

function modifier_Miku_ritmic_song_buff:OnCreated()
	if not IsServer() then return end
	local attacks = self:GetAbility():GetSpecialValueFor("attack_count")
	self:SetStackCount(attacks)
end

function modifier_Miku_ritmic_song_buff:OnRefresh( keys )
	if not IsServer() then return end
	local attacks = self:GetAbility():GetSpecialValueFor("attack_count")
	self:SetStackCount(attacks)
end

function modifier_Miku_ritmic_song_buff:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_Miku_ritmic_song_buff:OnAttackLanded( keys )
	if not IsServer() then return end
	local attacker = self:GetParent()
	if attacker ~= keys.attacker then
		return
	end
	keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Miku_ritmic_song_movespeed", {duration = self:GetAbility():GetSpecialValueFor("buff_duration")}) 
	self:SetStackCount(self:GetStackCount() - 1)
	if self:GetStackCount() <= 0 then
        self:Destroy()
		return
	end
end

modifier_Miku_ritmic_song_movespeed = class({})

function modifier_Miku_ritmic_song_movespeed:IsPurgable() return true end
function modifier_Miku_ritmic_song_movespeed:IsPurgeException() return true end

function modifier_Miku_ritmic_song_movespeed:OnCreated()
	self.mv = self:GetAbility():GetSpecialValueFor("debuff_movespeed")
end

function modifier_Miku_ritmic_song_movespeed:OnRefresh( keys )
	self.mv = self:GetAbility():GetSpecialValueFor("debuff_movespeed")
end

function modifier_Miku_ritmic_song_movespeed:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_Miku_ritmic_song_movespeed:GetModifierMoveSpeedBonus_Percentage()
	return self.mv
end

modifier_Miku_ritmic_song_debuff = class({})

function modifier_Miku_ritmic_song_debuff:IsPurgable() return true end
function modifier_Miku_ritmic_song_debuff:IsPurgeException() return true end

function modifier_Miku_ritmic_song_debuff:GetStatusEffectName()
	return "particles/status_miku_ritmic.vpcf"
end

function modifier_Miku_ritmic_song_debuff:OnCreated()
	if not IsServer() then return end
	local attacks = self:GetAbility():GetSpecialValueFor("attack_count")
	self:SetStackCount(attacks)
end

function modifier_Miku_ritmic_song_debuff:OnRefresh( keys )
	if not IsServer() then return end
	local attacks = self:GetAbility():GetSpecialValueFor("attack_count")
	self:SetStackCount(attacks)
end

function modifier_Miku_ritmic_song_debuff:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_Miku_ritmic_song_debuff:OnAttackLanded( keys )
	if not IsServer() then return end
	local attacker = self:GetParent()
	if attacker ~= keys.attacker then
		return
	end
	self:SetStackCount(self:GetStackCount() - 1)
	if self:GetStackCount() <= 0 then
        self:Destroy()
		return
	end
end

function modifier_Miku_ritmic_song_debuff:GetModifierDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("debuff_damage")
end

LinkLuaModifier("modifier_Miku_BattleSong_aura", "abilities/heroes/miku", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Miku_BattleSong_buff", "abilities/heroes/miku", LUA_MODIFIER_MOTION_NONE)

Miku_BattleSong = class({})

function Miku_BattleSong:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Miku_BattleSong:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Miku_BattleSong:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Miku_BattleSong:OnInventoryContentsChanged()
	if self:GetCaster():HasShard() then
		self:SetHidden(false)		
		if not self:IsTrained() then
			local level = self:GetCaster():FindAbilityByName("Miku_DanceSong"):GetLevel()
			if level > 0 then
				self:SetLevel(level)
			end
		end
	else
		self:SetHidden(true)
	end
end

function Miku_BattleSong:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end

function Miku_BattleSong:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Miku_BattleSong_aura", {duration = duration})
	self:GetCaster():EmitSound("MikuScepter")
end

modifier_Miku_BattleSong_aura = class({})

function modifier_Miku_BattleSong_aura:IsPurgable() return false end
function modifier_Miku_BattleSong_aura:IsPurgeException() return false end
function modifier_Miku_BattleSong_aura:IsAura() return true end
function modifier_Miku_BattleSong_aura:GetAuraDuration() return 0.5 end
function modifier_Miku_BattleSong_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_Miku_BattleSong_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_Miku_BattleSong_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_Miku_BattleSong_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_Miku_BattleSong_aura:GetModifierAura() return "modifier_Miku_BattleSong_buff" end

function modifier_Miku_BattleSong_aura:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():StopSound("MikuScepter")
end

function modifier_Miku_BattleSong_aura:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end

function modifier_Miku_BattleSong_aura:OnAbilityExecuted( params )
	if IsServer() then
		local hAbility = params.ability
		if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
			return 0
		end

		if hAbility:IsToggle() or hAbility:IsItem() then
			return 0
		end

		local radius = self:GetAbility():GetSpecialValueFor("radius")
		local heal = self:GetAbility():GetSpecialValueFor("heal")

		local friendly = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
		if #friendly > 0 then
			for _,hero in pairs( friendly ) do
				local fullheal = hero:GetMaxHealth() / 100 * heal
				hero:Heal(fullheal, self:GetAbility())
			end
		end
	end

	return 0
end

modifier_Miku_BattleSong_buff = class({})

function modifier_Miku_BattleSong_buff:IsPurgable() return false end
function modifier_Miku_BattleSong_buff:IsPurgeException() return false end

function modifier_Miku_BattleSong_buff:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
	if not IsServer() then return end
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("cooldown_purge"))
	self:OnIntervalThink()
	self.pfx = ParticleManager:CreateParticle("particles/miku_battlesong.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end

function modifier_Miku_BattleSong_buff:OnRefresh()
	self.movespeed = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
end

function modifier_Miku_BattleSong_buff:OnIntervalThink()
	if not IsServer() then return end
	self:GetParent():Purge( false, true, false, true, true )
end

function modifier_Miku_BattleSong_buff:OnDestroy()
	if not IsServer() then return end
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end

function modifier_Miku_BattleSong_buff:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_Miku_BattleSong_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_Miku_BattleSong_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end