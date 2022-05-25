LinkLuaModifier( "modifier_item_stone_mask_stats", "items/stone_mask", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_stone_mask_stats_aura", "items/stone_mask", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_stone_mask", "items/stone_mask", LUA_MODIFIER_MOTION_NONE )

item_stone_mask = class({})
modifier_item_stone_mask_stats = class({})

function item_stone_mask:CastFilterResultTarget(target)
	if not IsServer() then return end

	local caster = self:GetCaster()

	if target == caster then 
		return UF_FAIL_OTHER
	end

	if target:IsInvulnerable() then
		return UF_FAIL_INVULNERABLE
	end

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		local nResult = UnitFilter( target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, caster:GetTeamNumber() )
		return nResult
	else
		if target:HasModifier("modifier_item_stone_mask") then
			local nResult = UnitFilter( target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, caster:GetTeamNumber() )
			return nResult
		else
			if caster:GetHealth() < (caster:GetMaxHealth() / 100 * 51) or target:GetHealth() < (target:GetMaxHealth() / 100 * 51) then
				local nResult = UnitFilter( target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, caster:GetTeamNumber() )
				return nResult
			else
				return UF_FAIL_OTHER
			end
		end
	end
end

function item_stone_mask:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function item_stone_mask:GetChannelTime()
	return 10
end

function item_stone_mask:OnChannelFinish(bInterrupted)
    if not IsServer() then return end
    if self.modifier and not self.modifier:IsNull() then
    	self:GetCaster():Interrupt()
        self.modifier:Destroy()
    end
end

function item_stone_mask:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()

	local targetTeam = self.target:GetTeamNumber()
	local casterTeam = caster:GetTeamNumber()
	if self.target:TriggerSpellAbsorb( self ) then
        self:GetCaster():Interrupt()
        return
    end
    if self:GetCaster():GetUnitName() == "npc_dota_hero_void_spirit" then
		self:GetCaster():EmitSound("VanSuction")
	end
	self.modifier = self.target:AddNewModifier(caster, self, "modifier_item_stone_mask", {duration = self:GetChannelTime()})
end

function item_stone_mask:GetIntrinsicModifierName() 
	return "modifier_item_stone_mask_stats"
end

modifier_item_stone_mask_stats = class({})

function modifier_item_stone_mask_stats:GetTexture()
	return "stone_mask"
end

function modifier_item_stone_mask_stats:IsPurgable()
    return false
end

function modifier_item_stone_mask_stats:IsHidden()
    return true
end

function modifier_item_stone_mask_stats:GetAttributes()	return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_item_stone_mask_stats:OnCreated()
	self.attribute = self:GetAbility():GetSpecialValueFor("bonus_stats")
	self.magic_resist = self:GetAbility():GetSpecialValueFor("bonus_magic_resist")
	self.mana_regen_charge = self:GetAbility():GetSpecialValueFor("mana_regen_charge")
	self.health_regen_charge = self:GetAbility():GetSpecialValueFor("health_regen_charge")
	self.spell_amplify_charge = self:GetAbility():GetSpecialValueFor("spell_amplify_charge")
end

function modifier_item_stone_mask_stats:OnRefresh()
	self:OnCreated()
end

function modifier_item_stone_mask_stats:OnDeath(params)
	if params.unit == self:GetParent() then
		if params.attacker == self:GetParent() then return end
		if self:GetAbility():GetCurrentCharges() <= 0 then return end
		local stack = math.max( self:GetAbility():GetCurrentCharges() / 2, 1)
		self:GetAbility():SetCurrentCharges(stack)
	end
end

function modifier_item_stone_mask_stats:OnHeroKilled(params)
	if params.attacker == self:GetParent() then
		if params.target == self:GetParent() then return end
		self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges() + 1)
	end
end

function modifier_item_stone_mask_stats:DeclareFunctions()
return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_HERO_KILLED, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end


function modifier_item_stone_mask_stats:GetModifierBonusStats_Strength()
return self.attribute
end

function modifier_item_stone_mask_stats:GetModifierBonusStats_Agility()
return self.attribute
end

function modifier_item_stone_mask_stats:GetModifierBonusStats_Intellect()
return self.attribute
end

function modifier_item_stone_mask_stats:GetModifierMagicalResistanceBonus()
return self.magic_resist
end

function modifier_item_stone_mask_stats:GetModifierConstantManaRegen()
	return self:GetAbility():GetCurrentCharges() * self.mana_regen_charge
end

function modifier_item_stone_mask_stats:GetModifierConstantHealthRegen()
	return self:GetAbility():GetCurrentCharges() * self.health_regen_charge
end

function modifier_item_stone_mask_stats:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetCurrentCharges() * self.spell_amplify_charge
end

function modifier_item_stone_mask_stats:IsAura()
    return true
end

function modifier_item_stone_mask_stats:IsPurgable()
    return false
end

function modifier_item_stone_mask_stats:GetAuraRadius()
    return 1200
end

function modifier_item_stone_mask_stats:GetModifierAura()
    return "modifier_item_stone_mask_stats_aura"
end
   
function modifier_item_stone_mask_stats:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_stone_mask_stats:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_item_stone_mask_stats:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

modifier_item_stone_mask_stats_aura = class({})

function modifier_item_stone_mask_stats_aura:GetTexture()
	return "stone_mask"
end

function modifier_item_stone_mask_stats_aura:OnCreated()
	self.mana_regen = self:GetAbility():GetSpecialValueFor("bonus_mp_regen")
	self.health_regen = self:GetAbility():GetSpecialValueFor("bonus_hp_regen")
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_stone_mask_stats_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_stone_mask_stats_aura:GetModifierConstantManaRegen()
	return self.mana_regen
end

function modifier_item_stone_mask_stats_aura:GetModifierConstantHealthRegen()
	return self.health_regen
end

function modifier_item_stone_mask_stats_aura:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed
end

function modifier_item_stone_mask_stats_aura:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus_damage
end

function modifier_item_stone_mask_stats_aura:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_stone_mask_stats_aura:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			local lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100
			self:GetParent():Heal(params.damage * lifesteal, self:GetAbility())
		end
	end
end

function modifier_item_stone_mask_stats_aura:OnTakeDamage(params)
    if params.attacker == self:GetParent() then
        if params.unit == self:GetParent() then return end
        if params.inflictor == nil then return end

        local no_magic_heal = {
            "azazin_gayaura",
            "Dio_Za_Warudo",
            "Felix_WaterShield",
            "haku_help",
            "Kurumi_Zafkiel",
            "item_birzha_blade_mail",
            "item_nimbus_lapteva",
            "polnaref_return",
            "polnaref_stand",
            "item_cuirass_2"
        }

        for _, ability_no in pairs(no_magic_heal) do
            if params.inflictor:GetAbilityName() == ability_no then
                return
            end
        end

        local lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100
        self:GetParent():Heal(params.damage * lifesteal, self:GetAbility())
        local octarine = ParticleManager:CreateParticle( "particles/stone_mask/stone_mask_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:ReleaseParticleIndex( octarine )
    end
end
















modifier_item_stone_mask = class({})

function modifier_item_stone_mask:GetTexture()
	return "item_stone_mask"
end

function modifier_item_stone_mask:OnCreated()
	if not IsServer() then return end
	EmitSoundOn("Hero_Pugna.LifeDrain.Target", self:GetParent())
	StopSoundOn("Hero_Pugna.LifeDrain.Loop", self:GetParent())
	EmitSoundOn("Hero_Pugna.LifeDrain.Loop", self:GetParent())

	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		self.is_ally = true
	else
		self.is_ally = false
	end

	if self.is_ally then
		self.particle_drain_fx = ParticleManager:CreateParticle("particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_give.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	else
		self.particle_drain_fx = ParticleManager:CreateParticle("particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	end
	self:StartIntervalThink(0.25)
end

function modifier_item_stone_mask:OnIntervalThink()
	if not IsServer() then return end
	if self:GetParent():IsIllusion() and self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		self:GetParent():ForceKill(true)
		return nil
	end
	if not self:GetCaster():CanEntityBeSeenByMyTeam(self:GetParent()) or self:GetParent():IsInvulnerable() then
		if not self:IsNull() then
            self:Destroy()
            return
        end
	end
	local distance = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()

	if distance > 1200 then
		if not self:IsNull() then
            self:Destroy()
            return
        end
	end
	if not self:GetCaster():IsAlive() then
		if not self:IsNull() then
            self:Destroy()
            return
        end
	end

	local damage = self:GetAbility():GetSpecialValueFor("base_damage") + (self:GetParent():GetMaxHealth() - self:GetParent():GetHealth()) * (self:GetAbility():GetSpecialValueFor("damage_hp_check") / 100 )

	print(damage, self:GetAbility():GetSpecialValueFor("base_damage"))

	if self.is_ally then
		local damageTable = {victim = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			attacker = self:GetCaster(),
			damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
			ability = self:GetAbility()
		}
		ApplyDamage(damageTable)
		self:GetParent():Heal(damage, self:GetAbility())

		if self:GetParent():GetHealth() == self:GetParent():GetMaxHealth() then
			self:GetParent():GiveMana(damage)
		end
	else
		local damageTable = {victim = self:GetParent(),
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			attacker = self:GetCaster(),
			ability = self:GetAbility()
		}

		ApplyDamage(damageTable)
		self:GetCaster():Heal(damage, self:GetCaster())
		if self:GetCaster():GetHealth() == self:GetCaster():GetMaxHealth() then
			self:GetCaster():GiveMana(damage)
		end
	end
end

function modifier_item_stone_mask:IsHidden() return false end
function modifier_item_stone_mask:IsPurgable() return false end
function modifier_item_stone_mask:IsDebuff()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return false
	else
		return true
	end
end

function modifier_item_stone_mask:OnDestroy()
	if not IsServer() then return end
	if self.particle_drain_fx then
		ParticleManager:DestroyParticle(self.particle_drain_fx, false)
		ParticleManager:ReleaseParticleIndex(self.particle_drain_fx)
	end
	self:GetCaster():Interrupt()
	StopSoundOn("Hero_Pugna.LifeDrain.Target", self:GetParent())
	StopSoundOn("Hero_Pugna.LifeDrain.Loop", self:GetParent())
end