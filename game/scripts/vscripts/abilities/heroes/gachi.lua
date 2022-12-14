LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Gachi_Binding = class({})

function Gachi_Binding:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Gachi_Binding:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Gachi_Binding:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Gachi_Binding:CastFilterResultTarget( hTarget )
    if hTarget:IsMagicImmune() and (not self:GetCaster():HasShard()) then
        return UF_FAIL_MAGIC_IMMUNE_ENEMY
    end

    if not IsServer() then return UF_SUCCESS end
    local nResult = UnitFilter(
        hTarget,
        self:GetAbilityTargetTeam(),
        self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(),
        self:GetCaster():GetTeamNumber()
    )

    if nResult ~= UF_SUCCESS then
        return nResult
    end

    return UF_SUCCESS
end

function Gachi_Binding:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_gachi_1")

    if target:TriggerSpellAbsorb( self ) then
        return
    end

	target:AddNewModifier(self:GetCaster(), self, "modifier_gachi_binding", {duration = duration * (1 - target:GetStatusResistance())})

	target:EmitSound("gachifuck")

	if target:GetUnitName() == "npc_dota_hero_void_spirit" then
		target:EmitSound("VanBilly")
	end
end

LinkLuaModifier( "modifier_gachi_binding", "abilities/heroes/gachi.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gachi_binding = class({})

function modifier_gachi_binding:OnCreated()
	if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_gachi_binding:CheckState()
    local state = 
    {
        [MODIFIER_STATE_ROOTED] = true,
    }
    if self:GetCaster():HasTalent("special_bonus_birzha_gachi_6") then
	    state = {
	        [MODIFIER_STATE_ROOTED] = true,
	        [MODIFIER_STATE_DISARMED] = true,
	    }
	end
    return state
end

function modifier_gachi_binding:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

function modifier_gachi_binding:GetModifierIncomingDamage_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_gachi_8")
end

LinkLuaModifier("modifier_gachi_armor_buff", "abilities/heroes/gachi.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gachi_armor_buff_scepter", "abilities/heroes/gachi.lua", LUA_MODIFIER_MOTION_NONE)

Gachi_armor = class({})

function Gachi_armor:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_PASSIVE
    if self:GetCaster():HasScepter() then
        behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return behavior
end

function Gachi_armor:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("gachi_shard")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gachi_armor_buff_scepter", {duration = self:GetSpecialValueFor("scepter_duration")})
end

function Gachi_armor:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_cooldown")
    end
end

function Gachi_armor:GetManaCost(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_manacost")
    end
end

modifier_gachi_armor_buff_scepter = class({})

function modifier_gachi_armor_buff_scepter:IsPurgable() return false end

function modifier_gachi_armor_buff_scepter:OnCreated()
	if not IsServer() then return end
	self.damage_absorb = self:GetAbility():GetSpecialValueFor("scepter_damage_inc")
	self:SetStackCount(self.damage_absorb)
	self.particle = ParticleManager:CreateParticle("particles/gachi_shield_scepter.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(self.particle, 1, Vector(100,1,1))
	ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_gachi_armor_buff_scepter:OnRefresh(keys)
    if not IsServer() then return end
	self.damage_absorb = self:GetAbility():GetSpecialValueFor("scepter_damage_inc")
	self:SetStackCount(self.damage_absorb)
end

function modifier_gachi_armor_buff_scepter:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
    }
    return funcs
end

function modifier_gachi_armor_buff_scepter:GetModifierTotal_ConstantBlock(kv)
    if IsServer() then
        local target                    = self:GetParent()
        local original_shield_amount    = self.damage_absorb

        if kv.damage > 0 and kv.damage_type == DAMAGE_TYPE_PHYSICAL and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS then
            if kv.damage < self.damage_absorb then
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, kv.damage, nil)
                self.damage_absorb = self.damage_absorb - kv.damage
                self:SetStackCount(self.damage_absorb)
                return kv.damage
            else
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, original_shield_amount, nil)
                if not self:IsNull() then
                    self:Destroy()
                end
                return kv.damage
            end
        end
    end
end

function Gachi_armor:GetIntrinsicModifierName()
    return "modifier_gachi_armor_buff"
end

modifier_gachi_armor_buff = class({})

function modifier_gachi_armor_buff:IsHidden()
    return true
end

function modifier_gachi_armor_buff:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
    return declfuncs
end

function modifier_gachi_armor_buff:GetModifierPhysicalArmorBonus()
    if not self:GetCaster():HasTalent("special_bonus_birzha_gachi_3") then
        if self:GetParent():PassivesDisabled() then return end
    end
    return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_gachi_armor_buff:GetModifierConstantHealthRegen()
    if not self:GetCaster():HasTalent("special_bonus_birzha_gachi_3") then
        if self:GetParent():PassivesDisabled() then return end
    end
    return self:GetAbility():GetSpecialValueFor("regen")
end

LinkLuaModifier("modifier_gachi_hitonass", "abilities/heroes/gachi.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gachi_HitOnAss_slow", "abilities/heroes/gachi.lua", LUA_MODIFIER_MOTION_NONE)

Gachi_HitOnAss = class({})

function Gachi_HitOnAss:GetCooldown(level)
	local cooldown = self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gachi_7")
    return cooldown / ( self:GetCaster():GetCooldownReduction())
end

function Gachi_HitOnAss:GetIntrinsicModifierName()
    return "modifier_gachi_hitonass"
end

modifier_gachi_hitonass = class({})

function modifier_gachi_hitonass:IsPurgable() return false end
function modifier_gachi_hitonass:IsHidden() return true end

function modifier_gachi_hitonass:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_gachi_hitonass:GetModifierPreAttack_CriticalStrike(params)
	if not IsServer() then return end
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    if not self:GetAbility():IsFullyCastable() then return end
    return self:GetAbility():GetSpecialValueFor("crit_multiplier")
end

function modifier_gachi_hitonass:OnAttackLanded(params)
	if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.attacker:PassivesDisabled() then return end
    if params.target:IsWard() then return end
    if not self:GetAbility():IsFullyCastable() then return end

    local duration = self:GetAbility():GetSpecialValueFor("duration")
    self:GetAbility():UseResources(false, false, true)
    self:GetParent():EmitSound("gachishlep")

    local crit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
    ParticleManager:SetParticleControl(crit_pfx, 0, params.target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(crit_pfx)

	params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_gachi_HitOnAss_slow", {duration = duration * (1-params.target:GetStatusResistance())})

    if params.target:IsRealHero() and params.target:GetPlayerID() then
    	local gold = math.min(self:GetAbility():GetSpecialValueFor("gold"), PlayerResource:GetUnreliableGold(params.target:GetPlayerID()))
		params.target:ModifyGold(-gold, false, 0)
		self:GetParent():ModifyGold(gold, false, 0)
		SendOverheadEventMessage(self:GetParent(), OVERHEAD_ALERT_GOLD, self:GetParent(), gold, nil)
	end
end

function modifier_gachi_hitonass:GetModifierDamageOutgoing_Percentage()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_damage_passive") + self:GetCaster():FindTalentValue("special_bonus_birzha_gachi_5")
end

modifier_gachi_HitOnAss_slow = class({})

function modifier_gachi_HitOnAss_slow:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
    return declfuncs
end

function modifier_gachi_HitOnAss_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_gachi_HitOnAss_slow:GetModifierAttackSpeedBonus_Constant()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_gachi_2")
end

function modifier_gachi_HitOnAss_slow:StatusEffectPriority()
    return 3
end

function modifier_gachi_HitOnAss_slow:GetStatusEffectName()
    return "particles/units/heroes/hero_bounty_hunter/status_effect_bounty_hunter_jinda_slow.vpcf"
end

Gachi_GachiPower = class({})

LinkLuaModifier( "modifier_gachipower", "abilities/heroes/gachi.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gachipower_target", "abilities/heroes/gachi.lua", LUA_MODIFIER_MOTION_NONE )

function Gachi_GachiPower:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():EmitSound("gaypower")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gachipower", {duration=duration})
end

modifier_gachipower = class({})

function modifier_gachipower:IsPurgable()
	return false
end

function modifier_gachipower:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("gaypower")
end

function modifier_gachipower:DeclareFunctions()
	local decFuns =
	{
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return decFuns
end

function modifier_gachipower:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("agility_bonus") + self:GetStackCount()
end

function modifier_gachipower:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage.vpcf"
end

function modifier_gachipower:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_gachipower:GetStatusEffectName()
	return "particles/status_fx/status_effect_chemical_rage.vpcf"
end

function modifier_gachipower:StatusEffectPriority()
	return 10
end

function modifier_gachipower:GetHeroEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage_hero_effect.vpcf"
end

function modifier_gachipower:HeroEffectPriority()
	return 10
end

function modifier_gachipower:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.target:IsIllusion() then return end
    if params.target:IsWard() then return end
    if not params.target:IsRealHero() then return end

	local attribute = self:GetAbility():GetSpecialValueFor("attribute") + self:GetCaster():FindTalentValue("special_bonus_birzha_gachi_4")
		
	if not params.target:HasModifier("modifier_GachiPower_target") then
		params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gachipower_target", {})
		params.target:FindModifierByName("modifier_gachipower_target"):SetStackCount(params.target:FindModifierByName("modifier_gachipower_target"):GetStackCount() + attribute)
		self:SetStackCount(self:GetStackCount() + attribute)
	else
		params.target:FindModifierByName("modifier_gachipower_target"):SetStackCount(params.target:FindModifierByName("modifier_gachipower_target"):GetStackCount() + attribute)
		self:SetStackCount(self:GetStackCount() + attribute)
	end
end

modifier_gachipower_target = class({})

function modifier_gachipower_target:IsPurgable()
	return false
end

function  modifier_gachipower_target:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_gachipower_target:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetAbility():GetCaster():HasModifier("modifier_gachipower") then
		if not self:IsNull() then
            self:Destroy()
        end
	end
end

function modifier_gachipower_target:DeclareFunctions()
	local decFuns =
	{
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
	return decFuns
end

function modifier_gachipower_target:GetModifierBonusStats_Agility()
	return -self:GetStackCount()
end










