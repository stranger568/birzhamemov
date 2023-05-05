LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shiro_namelessworm_buff", "abilities/heroes/shiro.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_shiro_namelessworm_debuff", "abilities/heroes/shiro.lua", LUA_MODIFIER_MOTION_NONE)

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

    if target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
	   target:AddNewModifier(self:GetCaster(), self, "modifier_shiro_namelessworm_buff", { duration = duration })
    else
        if target:TriggerSpellAbsorb( self ) then
            return
        end
        target:AddNewModifier(self:GetCaster(), self, "modifier_shiro_namelessworm_debuff", { duration = duration * ( 1 - target:GetStatusResistance()) })
    end

    target:EmitSound("Hero_Bloodseeker.Rage")
    self:GetCaster():EmitSound("shiroone")
end

modifier_shiro_namelessworm_buff = class({})

function modifier_shiro_namelessworm_buff:IsPurgable()
    return true
end

function modifier_shiro_namelessworm_buff:OnCreated( kv )
	self.range = self:GetAbility():GetSpecialValueFor( "range" )
end

function modifier_shiro_namelessworm_buff:DeclareFunctions()
	local funcs = 
    {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_shiro_namelessworm_buff:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    local damage = self:GetParent():GetMaxHealth() / 100 * self:GetAbility():GetSpecialValueFor( "damage_forcaster" )
    if self:GetCaster():HasShard() then return end
    ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PURE })
end

function modifier_shiro_namelessworm_buff:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_1")
end

function modifier_shiro_namelessworm_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_4")
end

function modifier_shiro_namelessworm_buff:GetModifierAttackRangeBonus()
	if not self:GetParent():IsRangedAttacker() then return end
	return self.range
end

function modifier_shiro_namelessworm_buff:OnDeath( params )
    if params.attacker~=self:GetParent() then return end
    if params.unit:IsAncient() then return end
    if not params.unit:IsRealHero() then return end
    local health_bonus_pct = self:GetAbility():GetSpecialValueFor( "health_bonus_pct" )
    local heal = self:GetParent():GetMaxHealth() * (health_bonus_pct / 100)
    self:GetParent():Heal(heal, self:GetAbility())
end

function modifier_shiro_namelessworm_buff:GetEffectName()
	return "particles/shiro/shiro_namelessworm.vpcf"
end

function modifier_shiro_namelessworm_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shiro_namelessworm_buff:CheckState()
    if self:GetCaster():HasTalent("special_bonus_birzha_shiro_5") then return end
    local funcs = 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }
    return funcs
end

-----------------------------------------------------------------------------

modifier_shiro_namelessworm_debuff = class({})

function modifier_shiro_namelessworm_debuff:IsPurgable()
    return true
end

function modifier_shiro_namelessworm_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_shiro_namelessworm_debuff:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_1")
end

function modifier_shiro_namelessworm_debuff:GetModifierAttackSpeedBonus_Constant()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_4")
end

function modifier_shiro_namelessworm_debuff:OnDeath( params )
    if not IsServer() then return end
    if params.attacker~=self:GetParent() then return end
    if params.unit:IsAncient() then return end
    if not params.unit:IsRealHero() then return end
    local health_bonus_pct = self:GetAbility():GetSpecialValueFor( "health_bonus_pct" )
    local heal = self:GetParent():GetMaxHealth() * (health_bonus_pct / 100)
    self:GetParent():Heal(heal, self:GetAbility())
end

function modifier_shiro_namelessworm_debuff:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    local damage = self:GetParent():GetMaxHealth() / 100 * self:GetAbility():GetSpecialValueFor( "damage_forcaster" )
    ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PURE })
end

function modifier_shiro_namelessworm_debuff:GetEffectName()
    return "particles/shiro/shiro_namelessworm.vpcf"
end

function modifier_shiro_namelessworm_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shiro_namelessworm_debuff:CheckState()
    local funcs = 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }
    return funcs
end

----------------------------

LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )


Shiro_Punch = class({})

function Shiro_Punch:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_3")
end

function Shiro_Punch:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Shiro_Punch:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Shiro_Punch:OnSpellStart()
    if not IsServer() then return end

    local duration = self:GetSpecialValueFor("duration")

    local damage = self:GetSpecialValueFor("damage")

    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb(self) then return end

    target:EmitSound("Hero_Riki.Blink_Strike")

    target:EmitSound("shirotwo")

    local target_loc_forward_vector = target:GetForwardVector()

    local final_pos = target:GetAbsOrigin() - target_loc_forward_vector * 100

	local particle = ParticleManager:CreateParticle("particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 2, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 3, final_pos)
	ParticleManager:ReleaseParticleIndex(particle)

	target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = duration * (1-target:GetStatusResistance()) } )
    
    local bonus_attack_damage = 0

    if self:GetCaster():HasScepter() then
        bonus_attack_damage = self:GetCaster():GetAverageTrueAttackDamage(nil)
        self:GetCaster():PerformAttack(target, true, true, true, false, false, true, true)
    end

	ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage + bonus_attack_damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self})

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

    local direction = target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
    direction.z = 0
    direction = direction:Normalized()

    target:AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", { duration = 0.1, distance = self:GetSpecialValueFor("distance"), height = 10, direction_x = direction.x, direction_y = direction.y})
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

	local particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 1, Vector(75,0,75))
	ParticleManager:SetParticleControl(particle, 2, Vector(75,0,75))
	ParticleManager:SetParticleControl(particle, 4, Vector(75,0,75))
	ParticleManager:SetParticleControl(particle, 5, Vector(75,0,0))
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, false)

	self.damage_absorb = self:GetAbility():GetSpecialValueFor( "damage_absorb" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_2")
	self:SetStackCount(self.damage_absorb)


    self.damage_talent_enemy = 0
    self.original_full_absorb = self:GetAbility():GetSpecialValueFor( "damage_absorb" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_2")

    if self:GetCaster():HasTalent("special_bonus_birzha_shiro_8") then
        self:StartIntervalThink(self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_8"))
    end
end

function modifier_shiro_shield_buff:OnIntervalThink()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/shiro_shield_purge.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    self:GetParent():Purge( false, true, false, true, true)
end

function modifier_shiro_shield_buff:OnRefresh(keys)
    if not IsServer() then return end
	self.damage_absorb = self:GetAbility():GetSpecialValueFor( "damage_absorb" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_2")
	self:SetStackCount(self.damage_absorb)
end

function modifier_shiro_shield_buff:OnDestroy()
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_Abaddon.AphoticShield.Destroy")
	local particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

    if self:GetCaster():HasTalent("special_bonus_birzha_shiro_6") then
        local damage = self.damage_talent_enemy / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_6")
        local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_6", "value2"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        for _,enemy in pairs(enemies) do
            ApplyDamage({ victim = enemy, attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PURE })
        end
    end
end

function modifier_shiro_shield_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_CONSTANT,
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
                self.damage_talent_enemy = self.damage_talent_enemy + kv.damage
                self:SetStackCount(self.damage_absorb)
                return kv.damage
            else
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, original_shield_amount, nil)
                self.damage_talent_enemy = self.original_full_absorb
                if not self:IsNull() then
                    self:Destroy()
                end
                return original_shield_amount
            end
        end
    end
end

function modifier_shiro_shield_buff:GetModifierIncomingSpellDamageConstant()
    if (not IsServer()) then
        return self:GetStackCount()
    end
end

function modifier_shiro_shield_buff:GetModifierIncomingPhysicalDamageConstant()
    if (not IsServer()) then
        return self:GetStackCount()
    end
end

modifier_shiro_shield_evasion = class ({})

function modifier_shiro_shield_evasion:IsPurgable() return false end
function modifier_shiro_shield_evasion:IsHidden() return true end

function modifier_shiro_shield_evasion:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_AVOID_DAMAGE
    }
    return funcs
end

function modifier_shiro_shield_evasion:GetModifierAvoidDamage(keys)
    if not IsServer() then return end
    local chance = self:GetAbility():GetSpecialValueFor( "chance" )
    if RollPercentage(chance) then
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
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_shiro_7")
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
    return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_WretchedEggAwakeness_buff:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_WretchedEggAwakeness_buff:GetModifierAura()
    return "modifier_WretchedEggAwakeness_debuff"
end

function modifier_WretchedEggAwakeness_buff:GetAuraRadius()
    return -1
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
    return self:GetAbility():GetSpecialValueFor("movespeedtarget")
end

