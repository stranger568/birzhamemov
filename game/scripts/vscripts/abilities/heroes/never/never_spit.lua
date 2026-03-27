LinkLuaModifier("modifier_never_spit", "abilities/heroes/never/never_spit.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_never_spit_debuff", "abilities/heroes/never/never_spit.lua", LUA_MODIFIER_MOTION_NONE)

never_spit = class({})

function never_spit:Precache(context)
    PrecacheResource("particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", context)
    PrecacheResource("particle", "particles/never_arcana/sf_fire_arcana_shadowraze.vpcf", context)
end

function never_spit:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/SpitArcana"
	end
	return "Never/Spit"
end

function never_spit:GetIntrinsicModifierName()
    return "modifier_never_spit"
end

function never_spit:GetAbilityDamageType()
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_never_8")
    if talent and talent:GetLevel() > 0 then 
        return DAMAGE_TYPE_PURE
    end
    return DAMAGE_TYPE_PHYSICAL
end

modifier_never_spit = class({})

function modifier_never_spit:IsHidden() return self:GetStackCount()==0 end
function modifier_never_spit:IsPurgable() return false end
function modifier_never_spit:RemoveOnDeath() return false end

function modifier_never_spit:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_never_spit:OnCreated()
    if not IsServer() then return end
    self.attacks = self:GetAbility():GetSpecialValueFor( "attacks" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
end

function modifier_never_spit:OnRefresh()
    if not IsServer() then return end
    self.attacks = self:GetAbility():GetSpecialValueFor( "attacks" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
end

function modifier_never_spit:OnAttackLanded(params)
    if not IsServer() then return end 
    if params.attacker ~= self:GetParent() then return end
    if params.target == self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.attacker:PassivesDisabled() then return end
    if params.target:IsWard() then return end
    local target = params.target
    local attacker = params.attacker
    local soul_mod = self:GetParent():FindModifierByName("modifier_never_innate")

    self:IncrementStackCount()

    if self:GetStackCount() >= self.attacks then
        local damageTable = {
			victim = target,
			attacker = attacker,
			damage = self.damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(),
		}
		ApplyDamage( damageTable )
        target:AddNewModifier(attacker, self:GetAbility(), "modifier_never_spit_debuff", {duration = self.duration * (1 - params.target:GetStatusResistance())})
        if soul_mod then 
            soul_mod:AddStack(1)
        end
        self:PlayEffects(params)
        self:SetStackCount(0)
    end
end

function modifier_never_spit:PlayEffects(params)
    self.particle_spit = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf"
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		self.particle_spit = "particles/never_arcana/sf_fire_arcana_shadowraze.vpcf"
	end
    local effect_spit = ParticleManager:CreateParticle(self.particle_spit, PATTACH_ABSORIGIN, params.target)
    ParticleManager:SetParticleControl(effect_spit, 0, params.target:GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_spit, 1, params.target:GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_spit, 3, params.target:GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_spit, 5, params.target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(effect_spit)
    params.target:EmitSound("neverbash")
end

modifier_never_spit_debuff = class({})

function modifier_never_spit_debuff:IsDebuff() return true end 
function modifier_never_spit_debuff:IsPurgable() return true end 
function modifier_never_spit_debuff:IsHidden() return false end 

function modifier_never_spit_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_never_spit_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_never_spit_debuff:CheckState()
    return {[MODIFIER_STATE_SILENCED] = true}
end