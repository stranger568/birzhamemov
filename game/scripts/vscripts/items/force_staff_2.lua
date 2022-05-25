LinkLuaModifier( "modifier_item_force_staff_2", "items/force_staff_2", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_force_staff_2_pull", "items/force_staff_2", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_force_staff_2_buff", "items/force_staff_2", LUA_MODIFIER_MOTION_NONE )

item_force_staff_2 = class({})

function item_force_staff_2:OnSpellStart()
    if not IsServer() then return end
    self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, 'modifier_item_force_staff_2_pull', {})
    EmitSoundOn('DOTA_Item.ForceStaff.Activate', self:GetCursorTarget())
end

function item_force_staff_2:GetIntrinsicModifierName() 
    return "modifier_item_force_staff_2"
end

modifier_item_force_staff_2 = class({})

function modifier_item_force_staff_2:IsHidden()
    return true
end

function modifier_item_force_staff_2:IsPurgable()
    return false
end

function modifier_item_force_staff_2:DeclareFunctions()
return  {
            MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
            MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
            MODIFIER_PROPERTY_HEALTH_BONUS,
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        }
end

function modifier_item_force_staff_2:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_intellect")
    end
end

function modifier_item_force_staff_2:GetModifierConstantHealthRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_hp_regen')
    end
end

function modifier_item_force_staff_2:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
    end
end

function modifier_item_force_staff_2:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_armor")
    end
end

modifier_item_force_staff_2_pull = modifier_item_force_staff_2_pull or class({})
function modifier_item_force_staff_2_pull:IsDebuff() return false end
function modifier_item_force_staff_2_pull:IsHidden() return true end
function modifier_item_force_staff_2_pull:IsPurgable() return false end
function modifier_item_force_staff_2_pull:IsStunDebuff() return true end
function modifier_item_force_staff_2_pull:IgnoreTenacity() return true end
function modifier_item_force_staff_2_pull:IsMotionController() return true end
function modifier_item_force_staff_2_pull:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_item_force_staff_2_pull:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_item_force_staff_2_pull:GetEffectName()
    return "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_item_force_staff_v2.vpcf" end

function modifier_item_force_staff_2_pull:CheckState()
    return   {  [MODIFIER_STATE_ROOTED] = true,
                [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                 [MODIFIER_STATE_STUNNED] = true, }
end

function modifier_item_force_staff_2_pull:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_item_force_staff_2_pull:GetOverrideAnimation( params )
    return ACT_DOTA_FLAIL
end

function modifier_item_force_staff_2_pull:OnCreated()
    if IsServer() then
        self:GetParent():InterruptMotionControllers(false)
        self.normalVelocity = 1200
        self.direction = (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
        self.distance = CalcDistanceBetweenEntityOBB(self:GetParent(), self:GetCaster()) - 100
        self.traveled = 0
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_item_force_staff_2_pull:OnIntervalThink()
    if IsServer() then
        self:HorizontalMotion(FrameTime())
        GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 100, false)
    end
end

function modifier_item_force_staff_2_pull:HorizontalMotion(dt)
    if IsServer() then
        if self.traveled < self.distance then
            self:GetParent():SetAbsOrigin(self:GetParent():GetAbsOrigin() + self.direction * self.normalVelocity * dt)
            self.traveled = self.traveled + self.normalVelocity * dt
            self:GetParent():SetAbsOrigin(Vector(self:GetParent():GetAbsOrigin().x, self:GetParent():GetAbsOrigin().y, GetGroundHeight(self:GetParent():GetAbsOrigin(), self:GetParent())))
        else
            FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
            self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_item_force_staff_2_buff', {duration = self:GetAbility():GetSpecialValueFor("duration")})
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

modifier_item_force_staff_2_buff = class({})

function modifier_item_force_staff_2_buff:IsPurgable()
    return false
end

function modifier_item_force_staff_2_buff:GetTexture()
    return "items/force_staff_2"
end

function modifier_item_force_staff_2_buff:OnCreated()
    self.bonus_movespeed_time = 0
    if self:GetAbility() then
        self.bonus_movespeed_time = self:GetAbility():GetSpecialValueFor("bonus_movespeed_time")
    end
end

function modifier_item_force_staff_2_buff:DeclareFunctions()
return  {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        }
end

function modifier_item_force_staff_2_buff:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_movespeed_time
end

function modifier_item_force_staff_2_buff:GetEffectName()
    return "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_windrun_v2.vpcf" end

function modifier_item_force_staff_2_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW end


