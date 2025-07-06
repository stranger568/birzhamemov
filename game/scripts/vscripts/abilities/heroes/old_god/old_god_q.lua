LinkLuaModifier("modifier_old_god_q", "abilities/heroes/old_god/old_god_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_old_god_q_move", "abilities/heroes/old_god/old_god_q", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_old_god_q_debuff_movement", "abilities/heroes/old_god/old_god_q", LUA_MODIFIER_MOTION_BOTH)

old_god_q = class({})

function old_god_q:Precache(context)
    PrecacheResource("particle", "particles/old_god/old_god_q.vpcf", context)
    PrecacheResource("particle", "particles/old_god/old_god_q_base_attack.vpcf", context)
end

function old_god_q:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    self:GetCaster():EmitSound("stariy_teaser")
    self:UseThisAbility(self:GetCaster(), target)
    local old_god_w = self:GetCaster():FindAbilityByName("old_god_w")
    if self:GetCaster():HasShard() and old_god_w and old_god_w:GetLevel() > 0 and old_god_w.illusion_table then
        for _, illusion in pairs(old_god_w.illusion_table) do
            if illusion and not illusion:IsNull() and illusion:IsAlive() then
                self:UseThisAbility(illusion, target)
            end
        end
    end
end

function old_god_q:UseThisAbility(caster, target)
    local duration = self:GetSpecialValueFor("duration")
    local max_range = self:GetSpecialValueFor("max_range")
    local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
    if target:TriggerSpellAbsorb(self) then return end
    local modifier_old_god_q = caster:FindModifierByName("modifier_old_god_q")
    if modifier_old_god_q then
        modifier_old_god_q:Destroy()
    end
    if distance > max_range then
        caster:AddNewModifier(caster, self, "modifier_old_god_q_move", {target = target:entindex()})
    end
    caster:AddNewModifier(caster, self, "modifier_old_god_q", {duration = duration, target = target:entindex()})
end

function old_god_q:OnProjectileHit(target, vLocation)
    if not IsServer() then return end
    if target then
        self:GetCaster():PerformAttack(target, true, true, true, false, false, false, true)
    end
end

modifier_old_god_q_move = class({})
function modifier_old_god_q_move:IsHidden() return true end
function modifier_old_god_q_move:IsPurgable() return false end
function modifier_old_god_q_move:IsPurgeException() return false end
function modifier_old_god_q_move:OnCreated(params)
    self.max_range = self:GetAbility():GetSpecialValueFor("max_range") * 0.6
    if not IsServer() then return end
    self.target = EntIndexToHScript(params.target)
    if self:ApplyHorizontalMotionController() == false then 
        self:Destroy()
        return
    end
    if self:ApplyVerticalMotionController() == false then 
        self:Destroy()
        return
    end
end

function modifier_old_god_q_move:OnDestroy()
	if not IsServer() then return end
	GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), 200, true )
	self:GetParent():InterruptMotionControllers( true )
end

function modifier_old_god_q_move:UpdateHorizontalMotion( me, dt )
    local direction = (self.target:GetOrigin() - self:GetParent():GetOrigin())
    direction.z = 0
    local distance = direction:Length2D()
    direction = direction:Normalized()
	local new_position = self:GetParent():GetAbsOrigin() + direction * (900 * dt)
    new_position = GetGroundPosition(new_position, nil)
	self:GetParent():SetOrigin( new_position )
    if (distance <= self.max_range) or self.target:IsNull() or not self.target:IsAlive() then
        self:Destroy()
    end
end

function modifier_old_god_q_move:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

modifier_old_god_q = class({})
function modifier_old_god_q:IsPurgable() return false end
function modifier_old_god_q:IsPurgeException() return false end
function modifier_old_god_q:OnCreated(params)
    self.base_attack_time = self:GetAbility():GetSpecialValueFor("base_attack_time")
    self.max_range = self:GetAbility():GetSpecialValueFor("max_range")
    if not IsServer() then return end
    self.target = EntIndexToHScript(params.target)
    local particle = ParticleManager:CreateParticle("particles/old_god/old_god_q.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
    self:AddParticle(particle, false, false, -1, false, false)
    self.modifier_old_god_q_debuff_movement = self.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_old_god_q_debuff_movement", {})
    self.bonus_attack = 0
    self:StartIntervalThink(0.1)
end

function modifier_old_god_q:OnIntervalThink()
    if not IsServer() then return end
    local distance = (self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
    if self.modifier_old_god_q_debuff_movement then
        self.modifier_old_god_q_debuff_movement:SetStackCount(distance)
    end
    if distance > self:GetAbility():GetCastRange(self:GetParent():GetAbsOrigin(), self:GetParent()) then
        if not self:GetParent():HasModifier("modifier_old_god_q_move") then
            self:Destroy()
        end
        return
    end
    if distance > self.max_range then
        self.active = false
        return
    end
    if self:GetParent():GetAggroTarget() ~= nil and self:GetParent():GetAggroTarget() == self.target then
        self.active = true
    else
        self.active = false
    end
    if self:GetCaster():HasModifier("modifier_old_god_d") then
        self.bonus_attack = self.bonus_attack + 0.1
        if self.bonus_attack >= (1 / self:GetParent():GetAttackSpeed(true)) then
            local projectile = 
            {
                Target = self.target,
                Source = self:GetParent(),
                Ability = self:GetAbility(),
                EffectName = "particles/old_god/old_god_q_base_attack.vpcf",
                bDodgeable = true,
                bProvidesVision = false,
                iMoveSpeed = self:GetParent():GetProjectileSpeed(),
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
                vSpawnOrigin = self:GetParent():GetAbsOrigin(),
                bVisibleToEnemies = true
            }
            ProjectileManager:CreateTrackingProjectile(projectile)
            self.bonus_attack = 0
        end
    end
end

function modifier_old_god_q:OnDestroy()
    if not IsServer() then return end
    if self.modifier_old_god_q_debuff_movement then
        self.modifier_old_god_q_debuff_movement:Destroy()
    end
end

function modifier_old_god_q:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
    }
end

function modifier_old_god_q:GetModifierBaseAttackTimeConstant()
    if self.active then
        return self.base_attack_time
    end
end

modifier_old_god_q_debuff_movement = class({})
function modifier_old_god_q_debuff_movement:IsHidden() return true end
function modifier_old_god_q_debuff_movement:IsPurgable() return false end
function modifier_old_god_q_debuff_movement:IsPurgeException() return false end
function modifier_old_god_q_debuff_movement:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_old_god_q_debuff_movement:OnCreated()
    self.max_slow = self:GetAbility():GetSpecialValueFor("max_slow")
end
function modifier_old_god_q_debuff_movement:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_old_god_q_debuff_movement:GetModifierMoveSpeedBonus_Percentage()
    return (self.max_slow * (self:GetStackCount() / self:GetAbility():GetSpecialValueFor("max_range"))) * -1
end