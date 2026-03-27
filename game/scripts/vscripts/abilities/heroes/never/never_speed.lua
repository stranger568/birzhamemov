LinkLuaModifier("modifier_never_speed", "abilities/heroes/never/never_speed.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_never_speed_aura", "abilities/heroes/never/never_speed.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_never_speed_aura_buff", "abilities/heroes/never/never_speed.lua", LUA_MODIFIER_MOTION_NONE)

never_speed = class({})

function never_speed:Precache(context)
    PrecacheResource("particle", "particles/econ/items/spirit_breaker/spirit_breaker_iron_surge/spirit_breaker_charge_iron.vpcf", context)
    PrecacheResource("particle", "particles/econ/events/seasonal_reward_line_fall_2025/lotus_orb_fallrewardline_2025_swirl_wind.vpcf", context)
    PrecacheResource("particle", "particles/never/spirit_breaker_charge_iron.vpcf", context)
end

function never_speed:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function never_speed:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function never_speed:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function never_speed:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/SpeedArcana"
	end
	return "Never/Speed"
end

function never_speed:GetIntrinsicModifierName()
    return "modifier_never_speed_aura"
end

function never_speed:CastFilterResult()
    if self:GetCaster():GetModifierStackCount( "modifier_never_innate", self:GetCaster() ) < self:GetSpecialValueFor("soul_loss") then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

function never_speed:GetCustomCastError()
    if self:GetCaster():GetModifierStackCount( "modifier_never_innate", self:GetCaster() ) < self:GetSpecialValueFor("soul_loss") then
        return "#dota_hud_error_never_no_souls"
    end
    return ""
end

function never_speed:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration =  self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_never_speed", {duration = duration})
    caster:EmitSound("never")
end

modifier_never_speed = class({})

function modifier_never_speed:IsHidden() return false end 
function modifier_never_speed:IsPurgable() return true end

function modifier_never_speed:OnCreated()
    if not IsServer() then return end 
    self.soul_loss = self:GetAbility():GetSpecialValueFor("soul_loss")
    if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		local particle_never_speed = ParticleManager:CreateParticle("particles/econ/items/spirit_breaker/spirit_breaker_iron_surge/spirit_breaker_charge_iron.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(particle_never_speed, false, false, -1, false, false)
	else
		local particle_never_speed = ParticleManager:CreateParticle("particles/never/spirit_breaker_charge_iron.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(particle_never_speed, false, false, -1, false, false)
	end
end

function modifier_never_speed:OnDestroy()
    if not IsServer() then return end
    local mod = self:GetCaster():FindModifierByName("modifier_never_innate")
    local stacks = mod:GetStackCount()
    if mod and stacks > self.soul_loss then 
        mod:SetStackCount(stacks - self.soul_loss)
    else
        mod:SetStackCount(0)
    end
end

function modifier_never_speed:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
    }
end

function modifier_never_speed:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_ally") * self:GetAbility():GetSpecialValueFor("movespeed_mult")
end

function modifier_never_speed:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attackspeed")
end

function modifier_never_speed:GetModifierPercentageCasttime()
    local casttime = self:GetAbility():GetSpecialValueFor("casttime")
    if casttime > 0 then
        return casttime
    end
    return 0
end

modifier_never_speed_aura = class({})

function modifier_never_speed_aura:IsPurgable()             return false end 
function modifier_never_speed_aura:IsHidden()               return true end 
function modifier_never_speed_aura:IsAura()	                return true end
function modifier_never_speed_aura:IsAuraActiveOnDeath()    return false end
function modifier_never_speed_aura:GetAuraDuration()        return 0.1 end
function modifier_never_speed_aura:GetAuraRadius()		    return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_never_speed_aura:GetAuraSearchFlags()	    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_never_speed_aura:GetAuraSearchTeam()	    return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_never_speed_aura:GetAuraSearchType()	    return DOTA_UNIT_TARGET_HEROES_AND_CREEPS end
function modifier_never_speed_aura:GetModifierAura()	    return "modifier_never_speed_aura_buff" end

modifier_never_speed_aura_buff = class({})

function modifier_never_speed_aura_buff:OnCreated()
    if not IsServer() then return end
    local particle_never_speed = ParticleManager:CreateParticle("particles/econ/events/seasonal_reward_line_fall_2025/lotus_orb_fallrewardline_2025_swirl_wind.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    --if DonateShopIsItemActive(self:GetCaster():GetPlayerID(), 27) then
	--	particle_never_speed = ParticleManager:CreateParticle("", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    --end
	self:AddParticle(particle_never_speed, false, false, -1, false, false)
end

function modifier_never_speed_aura_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_never_speed_aura_buff:GetModifierMoveSpeedBonus_Percentage()
    if self:GetParent():HasModifier("modifier_never_speed") then return 0 end
    return self:GetAbility():GetSpecialValueFor("movespeed_ally")
end