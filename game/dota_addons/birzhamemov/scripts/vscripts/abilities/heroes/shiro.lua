LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shiro_namelessworm_buff", "abilities/heroes/shiro.lua", LUA_MODIFIER_MOTION_NONE)

Shiro_NamelessWorm = class({})

function Shiro_NamelessWorm:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Shiro_NamelessWorm:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Shiro_NamelessWorm:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Shiro_NamelessWorm:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb( self ) then
        return
    end
	target:AddNewModifier(self:GetCaster(), self, "modifier_shiro_namelessworm_buff", { duration = duration })
    target:EmitSound("Hero_Bloodseeker.Rage")
    target:EmitSound("shiroone")
end

modifier_shiro_namelessworm_buff = class({})

function modifier_shiro_namelessworm_buff:IsPurgable()
    return true
end

function modifier_shiro_namelessworm_buff:IsDebuff()
	return self.debuff
end

function modifier_shiro_namelessworm_buff:OnCreated( kv )
	self.debuff = self:GetCaster():GetTeamNumber()~=self:GetParent():GetTeamNumber()
	self.range = self:GetAbility():GetSpecialValueFor( "range" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_4")
end

function modifier_shiro_namelessworm_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}

	return funcs
end

function modifier_shiro_namelessworm_buff:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
    	local damage = self:GetAbility():GetSpecialValueFor( "damage_forcaster" )
    	ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE })
    end
end

function modifier_shiro_namelessworm_buff:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_2")
end

function modifier_shiro_namelessworm_buff:GetModifierAttackRangeBonus()
	if not self:GetParent():IsRangedAttacker() then return end
	return self.range
end


function modifier_shiro_namelessworm_buff:OnDeath( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
		if params.unit:IsAncient() then return end
		local health_bonus_pct = self:GetAbility():GetSpecialValueFor( "health_bonus_pct" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_7")
		local heal = self:GetParent():GetMaxHealth() * (health_bonus_pct / 100)
		self:GetParent():Heal(heal, self:GetAbility())
	end
end

function modifier_shiro_namelessworm_buff:GetEffectName()
	return "particles/shiro/shiro_namelessworm.vpcf"
end

function modifier_shiro_namelessworm_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shiro_namelessworm_buff:CheckState()
	if self:GetCaster():HasTalent("special_bonus_birzha_shiro_6") and self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then return end
    local funcs = {
        [MODIFIER_STATE_SILENCED] = true,
    }
    return funcs
end

Shiro_Punch = class({})

function Shiro_Punch:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Shiro_Punch:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Shiro_Punch:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Shiro_Punch:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_3")
    local damage = self:GetSpecialValueFor("damage")
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end
    target:EmitSound("Hero_Riki.Blink_Strike")
    target:EmitSound("shirotwo")
    local target_loc_forward_vector = target:GetForwardVector()
    local final_pos = target:GetAbsOrigin() - target_loc_forward_vector * 100
	local particle = ParticleManager:CreateParticle("particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 1, final_pos)
	ParticleManager:ReleaseParticleIndex(particle)
	target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = duration } )
	ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self})
	local victim_angle = target:GetAnglesAsVector()
    local victim_forward_vector = target:GetForwardVector()
    local victim_angle_rad = victim_angle.y*math.pi/180
    local victim_position = target:GetAbsOrigin()
    local attacker_new = Vector(victim_position.x - 100 * math.cos(victim_angle_rad), victim_position.y - 100 * math.sin(victim_angle_rad), 0)
    self:GetCaster():SetAbsOrigin(attacker_new)
    FindClearSpaceForUnit(self:GetCaster(), attacker_new, true)
    self:GetCaster():SetForwardVector(victim_forward_vector)
    self:GetCaster():MoveToTargetToAttack(target)
    self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_2_END )
end

LinkLuaModifier( "modifier_shiro_shield_buff", "abilities/heroes/shiro.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_shiro_shield_evasion", "abilities/heroes/shiro.lua", LUA_MODIFIER_MOTION_NONE)

Shiro_Shield = class({})

function Shiro_Shield:GetIntrinsicModifierName()
    return "modifier_shiro_shield_evasion"
end

function Shiro_Shield:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Shiro_Shield:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Shiro_Shield:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Shiro_Shield:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local target = self:GetCursorTarget()
	target:AddNewModifier(self:GetCaster(), self, "modifier_shiro_shield_buff", { duration = duration })
    target:Purge( false, true, false, true, true)
    target:EmitSound("Hero_Abaddon.AphoticShield.Cast")
end

modifier_shiro_shield_buff = class ({})

function modifier_shiro_shield_buff:IsPurgable() return false end

function modifier_shiro_shield_buff:OnCreated(keys)
    if not IsServer() then return end
	self:GetParent():Purge( false, true, false, true, true)
	local particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 1, Vector(75,0,75))
	ParticleManager:SetParticleControl(particle, 2, Vector(75,0,75))
	ParticleManager:SetParticleControl(particle, 4, Vector(75,0,75))
	ParticleManager:SetParticleControl(particle, 5, Vector(75,0,0))
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, false)
	self:StartIntervalThink(FrameTime())
	self.damage_absorb = self:GetAbility():GetSpecialValueFor( "damage_absorb" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_1")
	self:SetStackCount(self.damage_absorb)
end

function modifier_shiro_shield_buff:OnRefresh(keys)
    if not IsServer() then return end
	self:GetParent():Purge( false, true, false, true, true)
	self.damage_absorb = self:GetAbility():GetSpecialValueFor( "damage_absorb" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_1")
	self:SetStackCount(self.damage_absorb)
end

function modifier_shiro_shield_buff:OnDestroy()
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_Abaddon.AphoticShield.Destroy")
	local particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_shiro_shield_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
    }
    return funcs
end

function modifier_shiro_shield_buff:GetModifierTotal_ConstantBlock(kv)
    if IsServer() then
        local target                    = self:GetParent()
        local original_shield_amount    = self.damage_absorb

        if kv.damage > 0 and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS then
            if kv.damage < self.damage_absorb then
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, kv.damage, nil)
                self.damage_absorb = self.damage_absorb - kv.damage
                self:SetStackCount(self.damage_absorb)
                return kv.damage
            else
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, original_shield_amount, nil)
                self:Destroy()
                return original_shield_amount
            end
        end
    end
end

modifier_shiro_shield_evasion = class ({})

function modifier_shiro_shield_evasion:IsPurgable() return false end
function modifier_shiro_shield_evasion:IsHidden() return true end

function modifier_shiro_shield_evasion:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_AVOID_DAMAGE
    }
    return funcs
end

function modifier_shiro_shield_evasion:GetModifierAvoidDamage(keys)
    if not IsServer() then return end
    local chance = self:GetAbility():GetSpecialValueFor( "chance" )
    if RandomInt(1, 100) <= chance then
    	return 1
    else
    	return 0
    end
end

LinkLuaModifier( "modifier_WretchedEggAwakeness_buff", "abilities/heroes/shiro.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_WretchedEggAwakeness_debuff", "abilities/heroes/shiro.lua", LUA_MODIFIER_MOTION_NONE)

Shiro_WretchedEggAwakeness = class({})

function Shiro_WretchedEggAwakeness:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Shiro_WretchedEggAwakeness:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Shiro_WretchedEggAwakeness:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Shiro_WretchedEggAwakeness:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_8")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_WretchedEggAwakeness_buff", { duration = duration })
    self:GetCaster():EmitSound("shiroult")
end

modifier_WretchedEggAwakeness_buff = class({})

function modifier_WretchedEggAwakeness_buff:GetEffectName()
    return  "particles/units/heroes/hero_lone_druid/lone_druid_battle_cry_buff.vpcf"
end

function modifier_WretchedEggAwakeness_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_WretchedEggAwakeness_buff:IsPurgable() return false end
function modifier_WretchedEggAwakeness_buff:IsAura() return true end

function modifier_WretchedEggAwakeness_buff:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_WretchedEggAwakeness_buff:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_WretchedEggAwakeness_buff:GetModifierAura()
    return "modifier_WretchedEggAwakeness_debuff"
end

function modifier_WretchedEggAwakeness_buff:GetAuraRadius()
    return 999999
end

function modifier_WretchedEggAwakeness_buff:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return decFuncs
end

function modifier_WretchedEggAwakeness_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeedcaster")
end

function modifier_WretchedEggAwakeness_buff:GetModifierPreAttack_CriticalStrike()
    if not IsServer() then return end                   
    return self:GetAbility():GetSpecialValueFor('crit')    
end

modifier_WretchedEggAwakeness_debuff = class({})

function modifier_WretchedEggAwakeness_debuff:IsPurgable() return false end

function modifier_WretchedEggAwakeness_debuff:GetEffectName()
    return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end

function modifier_WretchedEggAwakeness_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_WretchedEggAwakeness_debuff:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, }
    return funcs
end

function modifier_WretchedEggAwakeness_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeedtarget") + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_5")
end

