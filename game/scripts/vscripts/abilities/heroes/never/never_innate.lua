LinkLuaModifier("modifier_never_innate", "abilities/heroes/never/never_innate.lua", LUA_MODIFIER_MOTION_NONE)

never_innate = class({})

function never_innate:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf", context)
	PrecacheResource("particle", "particles/innate.vpcf", context)
end

function never_innate:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/Stupid_arcana"
	end
	return "Never/Stupid"
end

function never_innate:GetIntrinsicModifierName()
    return "modifier_never_innate"
end

modifier_never_innate = class({})

function modifier_never_innate:IsHidden() return false end
function modifier_never_innate:IsDebuff() return false end
function modifier_never_innate:IsPurgable() return false end
function modifier_never_innate:RemoveOnDeath() return false end

function modifier_never_innate:OnCreated()
	self.soul_release = self:GetAbility():GetSpecialValueFor("soul_release")
	self.soul_damage_pure = self:GetAbility():GetSpecialValueFor("soul_damage_pure")
	self.soul_hero_bonus = self:GetAbility():GetSpecialValueFor("soul_hero_bonus")
	self.soul_bonus = self:GetAbility():GetSpecialValueFor("soul_bonus")
	self.hero_kill_bonus_max = 0
	self.hero_max_gain = self:GetAbility():GetSpecialValueFor("scepter_bonus")

	if IsServer() then
		if not IsInToolsMode() then 
			self:SetStackCount(0)
		else
			self:SetStackCount(20)
		end
		self.bonus_max_souls = 0 
        self.soul_max = self:GetAbility():GetSpecialValueFor("soul_max")
		self:SetHasCustomTransmitterData(true)
		if IsInToolsMode() then
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_bp_never_reward", {})
        end
	end
end

function modifier_never_innate:OnRefresh()
	self.soul_release = self:GetAbility():GetSpecialValueFor("soul_release")
	self.soul_damage_pure = self:GetAbility():GetSpecialValueFor("soul_damage_pure")
	self.soul_hero_bonus = self:GetAbility():GetSpecialValueFor("soul_hero_bonus")
	self.soul_bonus = self:GetAbility():GetSpecialValueFor("soul_bonus")

	if IsServer() then 
		local base_max = self:GetAbility():GetSpecialValueFor("soul_max")
        self.soul_max = base_max + (self.bonus_max_souls or 0)
        self:SendBuffRefreshToClients()
	end
end

function modifier_never_innate:AddCustomTransmitterData()
    return {
        soul_max = self.soul_max
    }
end

function modifier_never_innate:HandleCustomTransmitterData(data)
    self.soul_max = data.soul_max
end

function modifier_never_innate:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
	}
	return funcs
end

function modifier_never_innate:GetModifierProcAttack_BonusDamage_Pure(params)
	local damage = self:GetParent():GetAgility() * ((self.soul_damage_pure * self:GetStackCount()) / 100)
	return damage
end

function modifier_never_innate:OnDeath( params )
	if IsServer() then
		self:DeathLogic( params )
		self:KillLogic( params )
	end
end

function modifier_never_innate:DeathLogic( params )
	local unit = params.unit
	if params.unit == self:GetParent() and not params.reincarnate then
        self.bonus_max_souls = 0
        self.soul_max = self:GetAbility():GetSpecialValueFor("soul_max")
        local after_death = math.floor(self:GetStackCount() * self.soul_release)
        self:SetStackCount(math.max(after_death, 1))
        self:SendBuffRefreshToClients()
    end
end

function modifier_never_innate:KillLogic( params )
	local target = params.unit
	local attacker = params.attacker
	if not attacker:PassivesDisabled() then
		if attacker == self:GetParent() and target ~= self:GetParent() and attacker:IsAlive() then
    	    if not target:IsIllusion() and not target:IsBuilding() then
    	        if target:IsRealHero() and self:GetParent():HasScepter() then
    	            self.bonus_max_souls = (self.bonus_max_souls or 0) + self.hero_max_gain
    	            self.soul_max = self:GetAbility():GetSpecialValueFor("soul_max") + self.bonus_max_souls
    	            self:SendBuffRefreshToClients()
    	        end
    	        local bonus = target:IsRealHero() and self.soul_hero_bonus or self.soul_bonus
    	        self:AddStack(bonus)
    	        self:PlayEffects( target )
    	    end
    	end
	end
end

function modifier_never_innate:AddStack( value )
	local current = self:GetStackCount()
	local after = current + value
	if after > self.soul_max then
		after = self.soul_max
	end
	self:SetStackCount( after )
end

function modifier_never_innate:GetModifierOverrideAbilitySpecial(data)
    if data.ability and data.ability:GetAbilityName() == "never_innate" then
        if data.ability_special_value == "current_souls_tooltip" then
            return 1
        end
    end
end

function modifier_never_innate:GetModifierOverrideAbilitySpecialValue(data)
    if data.ability:GetCaster() ~= self:GetParent() then return end
    if data.ability and data.ability:GetName() == "never_innate" then
        if data.ability_special_value == "current_souls_tooltip" then
            return self.soul_max
        end
    end
end

function modifier_never_innate:PlayEffects( target )
	local projectile_name = "particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf"
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		projectile_name = "particles/innate.vpcf"
	end
	local info = {
		Target = self:GetParent(),
		Source = target,
		EffectName = projectile_name,
		iMoveSpeed = 400,
		vSourceLoc= target:GetAbsOrigin(),               
		bDodgeable = false,                              
		bReplaceExisting = false,                        
		flExpireTime = GameRules:GetGameTime() + 5,
		bProvidesVision = false,                         
	}
	ProjectileManager:CreateTrackingProjectile(info)
end