LinkLuaModifier( "modifier_klichko_charge_of_darkness", "abilities/heroes/klichko.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_klichko_charge_of_darkness_vision", "abilities/heroes/klichko.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

klichko_charge_of_darkness = class({})

function klichko_charge_of_darkness:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function klichko_charge_of_darkness:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function klichko_charge_of_darkness:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return nil end
    self:GetCaster():EmitSound("Hero_Spirit_Breaker.ChargeOfDarkness")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_klichko_charge_of_darkness", 
    {
        ent_index = target:GetEntityIndex()
    })
    self:SetActivated(false)
    self:EndCooldown()
end

modifier_klichko_charge_of_darkness = class({})

function modifier_klichko_charge_of_darkness:IsPurgable() return false end

function modifier_klichko_charge_of_darkness:GetEffectName()
    return "particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf"
end

function modifier_klichko_charge_of_darkness:GetStatusEffectName()
    return "particles/status_fx/status_effect_charge_of_darkness.vpcf"
end

function modifier_klichko_charge_of_darkness:OnCreated(params)
    self.movement_speed     = self:GetAbility():GetSpecialValueFor("movement_speed")
    self.stun_duration      = self:GetAbility():GetSpecialValueFor("stun_duration")
    self.bash_radius        = self:GetAbility():GetSpecialValueFor("bash_radius")
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_Spirit_Breaker.ChargeOfDarkness.FP")
    if self:ApplyHorizontalMotionController() == false then 
        self:Destroy()
        return
    end
    self.target                 = EntIndexToHScript(params.ent_index)
    self.bashed_enemies         = {}
    self.trees                  = {}
    self.darkness_counter       = 0
    self.attempting_to_board    = {}
    self.vision_modifier = self.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_klichko_charge_of_darkness_vision", {})
end

function modifier_klichko_charge_of_darkness:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end

    if not self:GetAbility() then
        self:Destroy()
        return
    end

    if not self.target:IsAlive() then
        local new_targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.target:GetAbsOrigin(), nil, 4000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
        
        if #new_targets == 0 then
            self:Destroy()
            return
        end
        
        for _, target in pairs(new_targets) do 
            if target ~= self.clothesline_target then
                self.target = target
                self.vision_modifier = self.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_klichko_charge_of_darkness_vision", {})
                break
            else
                self:Destroy()
                return
            end
        end
    end

    if (self.target:GetOrigin() - me:GetOrigin()):Length2D() <= 128 then
        self:GetParent():EmitSound("Hero_Spirit_Breaker.Charge.Impact")

        if not self.target:IsMagicImmune() and self:GetAbility() then
            local stun_modifier = self.target:AddNewModifier(me, self:GetAbility(), "modifier_birzha_stunned_purge", {duration = self.stun_duration})
        end

        if self.target:IsAlive() then
            me:SetAggroTarget(self.target)
            self:Destroy()
        end
        return        
    elseif me:IsStunned() or me:IsOutOfGame() or me:IsHexed() or me:IsRooted() then
        self:Destroy()
        return
    end

    me:FaceTowards(self.target:GetOrigin())
    local distance = (GetGroundPosition(self.target:GetOrigin(), nil) - GetGroundPosition(me:GetOrigin(), nil)):Normalized()
    me:SetOrigin( me:GetOrigin() + distance * me:GetIdealSpeed() * dt )
end

function modifier_klichko_charge_of_darkness:OnHorizontalMotionInterrupted()
    self:Destroy()
end

function modifier_klichko_charge_of_darkness:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController( self )
    if self:GetAbility() then
        self:GetAbility():SetActivated(true)
        self:GetAbility():UseResources(false, false, true)
    end
    self:GetParent():StopSound("Hero_Spirit_Breaker.ChargeOfDarkness.FP")
    self:GetParent():StartGesture(ACT_DOTA_SPIRIT_BREAKER_CHARGE_END)
    if self.vision_modifier and not self.vision_modifier:IsNull() then
        self.vision_modifier:Destroy()
    end
end

function modifier_klichko_charge_of_darkness:CheckState()
    local state = {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
    
    return state
end

function modifier_klichko_charge_of_darkness:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_EVENT_ON_ORDER
    }
end

function modifier_klichko_charge_of_darkness:GetModifierIgnoreMovespeedLimit()
    return 1
end

function modifier_klichko_charge_of_darkness:GetDisableAutoAttack()
    return 1
end

function modifier_klichko_charge_of_darkness:GetModifierMoveSpeedBonus_Constant()
    return self.movement_speed + self:GetStackCount()
end

function modifier_klichko_charge_of_darkness:GetOverrideAnimation()
    return ACT_DOTA_RUN
end

function modifier_klichko_charge_of_darkness:GetActivityTranslationModifiers()
    return "charge"
end

function modifier_klichko_charge_of_darkness:OnOrder(keys)
    if not IsServer() then return end
    
    if keys.unit == self:GetParent() then
        local cancel_commands = 
        {
            [DOTA_UNIT_ORDER_MOVE_TO_POSITION]  = true,
            [DOTA_UNIT_ORDER_MOVE_TO_TARGET]    = true,
            [DOTA_UNIT_ORDER_ATTACK_MOVE]       = true,
            [DOTA_UNIT_ORDER_ATTACK_TARGET]     = true,
            [DOTA_UNIT_ORDER_CAST_POSITION]     = true,
            [DOTA_UNIT_ORDER_CAST_TARGET]       = true,
            [DOTA_UNIT_ORDER_CAST_TARGET_TREE]  = true,
            [DOTA_UNIT_ORDER_HOLD_POSITION]     = true,
            [DOTA_UNIT_ORDER_STOP]              = true
        }
        
        if cancel_commands[keys.order_type] and self:GetElapsedTime() >= 0.1 then
            self:Destroy()
        end
    elseif keys.unit:GetTeamNumber() == self:GetParent():GetTeamNumber() then
        if keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET and keys.target == self:GetParent() then
            self.attempting_to_board[keys.unit] = true
        elseif self.attempting_to_board[keys.unit] then
            self.attempting_to_board[keys.unit] = nil
        end
    end
end

modifier_klichko_charge_of_darkness_vision = class({})

function modifier_klichko_charge_of_darkness_vision:IsHidden()      return true end
function modifier_klichko_charge_of_darkness_vision:IsPurgable()    return false end
function modifier_klichko_charge_of_darkness_vision:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_klichko_charge_of_darkness_vision:ShouldUseOverheadOffset() return true end

function modifier_klichko_charge_of_darkness_vision:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge_target.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
end

function modifier_klichko_charge_of_darkness_vision:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

function modifier_klichko_charge_of_darkness_vision:CheckState()
    local state = {[MODIFIER_STATE_PROVIDES_VISION] = true}

    return state
end

LinkLuaModifier( "modifier_kilchko_boxingPunchSeries", "abilities/heroes/klichko.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kilchko_boxingPunchSeries_passive", "abilities/heroes/klichko.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_kilchko_boxingPunchSeries_debuff", "abilities/heroes/klichko.lua", LUA_MODIFIER_MOTION_NONE)


Klichko_BoxingPunchSeries = class({})

function Klichko_BoxingPunchSeries:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Klichko_BoxingPunchSeries:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Klichko_BoxingPunchSeries:GetIntrinsicModifierName()
    return "modifier_kilchko_boxingPunchSeries_passive"
end

function Klichko_BoxingPunchSeries:OnSpellStart()
    if not IsServer() then return end  
    local caster = self:GetCaster()
    local ability = self
    local max_attacks = ability:GetSpecialValueFor("max_attacks")
    local duration = ability:GetSpecialValueFor("duration")
    caster:EmitSound("Hero_Ursa.Enrage")
    caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
    if caster:HasModifier("modifier_kilchko_boxingPunchSeries") then
        caster:RemoveModifierByName("modifier_kilchko_boxingPunchSeries")
    end
    caster:AddNewModifier(caster, ability, "modifier_kilchko_boxingPunchSeries", {duration = duration})
    caster:SetModifierStackCount("modifier_kilchko_boxingPunchSeries", caster, max_attacks)
end

modifier_kilchko_boxingPunchSeries = class({})

function modifier_kilchko_boxingPunchSeries:IsPurgable() return true end

function modifier_kilchko_boxingPunchSeries:OnCreated()
    if not IsServer() then return end 
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
    ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_head", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_kilchko_boxingPunchSeries:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_kilchko_boxingPunchSeries:StatusEffectPriority()
    return 10
end

function modifier_kilchko_boxingPunchSeries:GetStatusEffectName()
    return "particles/status_fx/status_effect_overpower.vpcf"
end

function modifier_kilchko_boxingPunchSeries:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK,}
    return decFuncs
end

function modifier_kilchko_boxingPunchSeries:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_kilchko_boxingPunchSeries:OnAttack( keys )
    if keys.attacker == self:GetCaster() then
        local current_stacks = self:GetStackCount()
        if current_stacks > 1 then
            self:DecrementStackCount()
        else
            self:Destroy()
        end
    end
end

modifier_kilchko_boxingPunchSeries_passive = class({})

function modifier_kilchko_boxingPunchSeries_passive:IsHidden() return true end
function modifier_kilchko_boxingPunchSeries_passive:IsPurgable() return false end

function modifier_kilchko_boxingPunchSeries_passive:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL}
    return decFuncs
end

function modifier_kilchko_boxingPunchSeries_passive:GetModifierProcAttack_BonusDamage_Physical( params )
    self.damage = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_klichko_1")
    self.chance = self:GetAbility():GetSpecialValueFor( "proc_chance" )
    if not IsServer() then return end
    if self:GetParent():HasModifier("modifier_kilchko_boxingPunchSeries") then
        self.chance = 100
    end
    if RandomInt(1, 100) <= self.chance then
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kilchko_boxingPunchSeries_debuff", {duration = 0.5}) 
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
        ParticleManager:ReleaseParticleIndex(particle)  
        params.target:EmitSound("Hero_Spirit_Breaker.GreaterBash")     
        return self.damage
    end
    return nil
end

modifier_kilchko_boxingPunchSeries_debuff = class({})

function modifier_kilchko_boxingPunchSeries_debuff:IsPurgable() return true end

function modifier_kilchko_boxingPunchSeries_debuff:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
    return decFuncs
end

function modifier_kilchko_boxingPunchSeries_debuff:GetModifierMoveSpeedBonus_Percentage( params )
    return -100
end

LinkLuaModifier( "modifier_klichko_saybullshit_debuff", "abilities/heroes/klichko.lua", LUA_MODIFIER_MOTION_NONE)

Klichko_SayBullshit = class({})

function Klichko_SayBullshit:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Klichko_SayBullshit:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Klichko_SayBullshit:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Klichko_SayBullshit:OnSpellStart()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    if not IsServer() then return end
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
      self:GetCaster():GetAbsOrigin(),
      nil,
      radius,
      DOTA_UNIT_TARGET_TEAM_ENEMY,
      DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
      DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
      FIND_ANY_ORDER,
      false)

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    self:GetCaster():EmitSound("KlichkoBullshit")
    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_klichko_saybullshit_debuff", {duration = duration * (1 - enemy:GetStatusResistance())}) 
    end
end

modifier_klichko_saybullshit_debuff = class({})

function modifier_klichko_saybullshit_debuff:IsPurgable() return false end
function modifier_klichko_saybullshit_debuff:IsPurgeException() return true end

function modifier_klichko_saybullshit_debuff:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
    return decFuncs
end

function modifier_klichko_saybullshit_debuff:GetModifierMoveSpeedBonus_Percentage( params )
    return self:GetAbility():GetSpecialValueFor("bonus_speed")
end

function modifier_klichko_saybullshit_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FEARED] = true,
    }

    return state
end

function modifier_klichko_saybullshit_debuff:OnCreated()
    if not IsServer() then return end
    local buildings = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        Vector(0,0,0),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_BUILDING,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        0,
        false
    )
    local fountain = nil
    for _,building in pairs(buildings) do
        if building:GetClassname()=="ent_dota_fountain" then
            fountain = building
            break
        end
    end
    if not fountain then return end
    self:GetParent():MoveToPosition( fountain:GetOrigin() )
end

function modifier_klichko_saybullshit_debuff:OnDestroy()
    if not IsServer() then return end
    self:GetParent():Stop()
end

function modifier_klichko_saybullshit_debuff:GetEffectName()
    return "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf"
end

function modifier_klichko_saybullshit_debuff:StatusEffectPriority()
    return 10
end

function modifier_klichko_saybullshit_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

function modifier_klichko_saybullshit_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_klichko_BecomeMayor", "abilities/heroes/klichko.lua", LUA_MODIFIER_MOTION_NONE )

Klichko_BecomeMayor = class({})

function Klichko_BecomeMayor:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Klichko_BecomeMayor:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Klichko_BecomeMayor:OnSpellStart()
    if not IsServer() then return end  
    local caster = self:GetCaster()
    local ability = self
    local duration = ability:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_klichko_2")
    caster:EmitSound("Hero_Invoker.Alacrity")
    caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
    caster:AddNewModifier(caster, ability, "modifier_klichko_BecomeMayor", {duration = duration})
end

modifier_klichko_BecomeMayor = class({})

function modifier_klichko_BecomeMayor:IsPurgable() return false end

function modifier_klichko_BecomeMayor:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
    return decFuncs
end

function modifier_klichko_BecomeMayor:GetModifierBonusStats_Strength( params )
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_klichko_BecomeMayor:GetModifierMoveSpeedBonus_Percentage( params )
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_klichko_BecomeMayor:GetModifierIncomingDamage_Percentage( params )
    return self:GetAbility():GetSpecialValueFor("outdamage")
end

function modifier_klichko_BecomeMayor:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/econ/items/invoker/invoker_ti7/invoker_ti7_alacrity_buff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
    self:AddParticle(particle, false,false, -1, false,false)
end

function modifier_klichko_BecomeMayor:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_alacrity_buff.vpcf"
end

function modifier_klichko_BecomeMayor:StatusEffectPriority()
    return 10
end

function modifier_klichko_BecomeMayor:GetStatusEffectName()
    return "particles/status_fx/status_effect_alacrity.vpcf" 
end

function modifier_klichko_BecomeMayor:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

