LinkLuaModifier("modifier_item_mana_booster", "items/booster", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mystic_booster", "items/booster", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_modifier_eul_cyclone_birzha", "items/booster", LUA_MODIFIER_MOTION_BOTH)

item_mana_booster = class({})

function item_mana_booster:GetIntrinsicModifierName()
    return "modifier_item_mana_booster"
end

modifier_item_mana_booster = class({})

function modifier_item_mana_booster:IsHidden()
	return true
end

function modifier_item_mana_booster:IsPurgable()
    return false
end

function modifier_item_mana_booster:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_mana_booster:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_BONUS,
    }

    return funcs
end

function modifier_item_mana_booster:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor('mana')
end

item_mystic_booster = class({})

function item_mystic_booster:GetIntrinsicModifierName()
    return "modifier_item_mystic_booster"
end

function item_mystic_booster:CastFilterResultTarget(target)
    if target == self:GetCaster() then
        return UF_SUCCESS
    else
        return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
    end
end

function item_mystic_booster:OnSpellStart()
    local target = self:GetCursorTarget()
    if not target:TriggerSpellAbsorb(self) then
        target:EmitSound("DOTA_Item.Cyclone.Activate")
        target:AddNewModifier(self:GetCaster(), self, "modifier_modifier_eul_cyclone_birzha", {duration = self:GetSpecialValueFor("duration")})
        if target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
            target:Purge(true, false, false, false, false)
        else
            target:Purge(false, true, false, false, false)
        end
    end
end

modifier_modifier_eul_cyclone_birzha = class({})

function modifier_modifier_eul_cyclone_birzha:IsHidden()     return false  end
function modifier_modifier_eul_cyclone_birzha:IsPurgable()   return false  end
function modifier_modifier_eul_cyclone_birzha:IsPurgeException()     return false  end
function modifier_modifier_eul_cyclone_birzha:IsMotionController()  return true end
function modifier_modifier_eul_cyclone_birzha:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end

function modifier_modifier_eul_cyclone_birzha:OnCreated(kv)
    if not IsServer() then return end
    self.angle = self:GetParent():GetAngles()
    self.cyc_pos = self:GetParent():GetAbsOrigin()
    self.pfx = ParticleManager:CreateParticle("particles/econ/events/ti9/cyclone_ti9.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self.pfx, 0, self:GetParent():GetAbsOrigin())
    self:StartIntervalThink(FrameTime())
end

function modifier_modifier_eul_cyclone_birzha:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_STUNNED]            = true,
        [MODIFIER_STATE_ROOTED]             = true,
        [MODIFIER_STATE_DISARMED]           = true,
        [MODIFIER_STATE_FLYING]             = true,
        [MODIFIER_STATE_INVULNERABLE]             = true,
        [MODIFIER_STATE_OUT_OF_GAME]             = true,
    }
    return state
end

function modifier_modifier_eul_cyclone_birzha:OnIntervalThink()
    if not self:CheckMotionControllers() then
        self:Destroy()
        return
    end
    self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_modifier_eul_cyclone_birzha:HorizontalMotion(unit, time)
    if not IsServer() then return end
    local angle = self:GetParent():GetAngles()
    local new_angle = RotateOrientation(angle, QAngle(0,20,0))
    self:GetParent():SetAngles(angle.x, angle.y+20, angle.z)
    if self:GetElapsedTime() <= 0.3 then
        self.cyc_pos.z = self.cyc_pos.z + 25
        self:GetParent():SetAbsOrigin(self.cyc_pos)
    elseif self:GetDuration() - self:GetElapsedTime() < 0.3 then
        self.step = self.step or (self.cyc_pos.z - self:GetParent():GetAbsOrigin().z) / ((self:GetDuration() - self:GetElapsedTime()) / FrameTime())
        self.cyc_pos.z = self.cyc_pos.z - self.step
        self:GetParent():SetAbsOrigin(self.cyc_pos)
    end
end

function modifier_modifier_eul_cyclone_birzha:OnDestroy()
    StopSoundOn("DOTA_Item.Cyclone.Activate", self:GetParent())
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.pfx, false)
    ParticleManager:ReleaseParticleIndex(self.pfx)
    self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
    self:GetParent():SetAbsOrigin(self:GetParent():GetAbsOrigin())
    ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
    self:GetParent():SetAngles(self.angle[1], self.angle[2], self.angle[3])
    local damage = self:GetAbility():GetSpecialValueFor("damage") + (self:GetCaster():GetIntellect() * self:GetAbility():GetSpecialValueFor("int_mult"))
    if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
        ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
    end
end

function modifier_modifier_eul_cyclone_birzha:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_modifier_eul_cyclone_birzha:GetOverrideAnimation( params )
    return ACT_DOTA_FLAIL
end



modifier_item_mystic_booster = class({})

function modifier_item_mystic_booster:IsHidden()
    return true
end

function modifier_item_mystic_booster:IsPurgable()
    return false
end

function modifier_item_mystic_booster:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_mystic_booster:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE,

    }

    return funcs
end

function modifier_item_mystic_booster:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor('mana')
end

function modifier_item_mystic_booster:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor('int')
end

function modifier_item_mystic_booster:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor('health_regen')
end

function modifier_item_mystic_booster:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor('movement_speed')
end

function modifier_item_mystic_booster:OnTakeDamage(params)
    if params.attacker == self:GetParent() then
        if params.damage_type == 2 then
            if params.inflictor:GetName() ~= "Ricardo_KokosMaslo" then
                local real_damage = params.original_damage
                local pure_damage = ((self:GetAbility():GetSpecialValueFor("pure_damage") + (self:GetParent():GetMaxMana() / 1000 )) / 100) * real_damage
                ApplyDamage({attacker = self:GetParent(), victim = params.unit, ability = params.inflictor, damage = pure_damage, damage_type = DAMAGE_TYPE_PURE, damage_flag = DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR})
            end
        end
    end
end