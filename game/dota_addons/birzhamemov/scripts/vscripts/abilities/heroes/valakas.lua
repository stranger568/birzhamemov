LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_glad_sorry_target", "abilities/heroes/valakas.lua", LUA_MODIFIER_MOTION_NONE )

Valakas_sorry = class({})

function Valakas_sorry:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_valakas_reward") then
		return "Valakas/Sorry_arcana"
	end
	return "Valakas/Sorry"
end

function Valakas_sorry:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Valakas_sorry:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Valakas_sorry:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Valakas_sorry:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_valakas_3")
    if target:IsDuel() then return end
    if target:TriggerSpellAbsorb(self) then return end
    self:GetCaster():EmitSound("gladsorry")
    target:AddNewModifier( self:GetCaster(), self, "modifier_glad_sorry_target", { duration = duration } )
    if self:GetCaster():HasModifier("modifier_bp_valakas_reward") then
    	local particle = ParticleManager:CreateParticle( "particles/birzhapass/valakas_arcana_sorry_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    	ParticleManager:SetParticleControl( particle, 0, self:GetCaster():GetOrigin() )
    	ParticleManager:SetParticleControl( particle, 1, self:GetCaster():GetOrigin() )
    	ParticleManager:SetParticleControl( particle, 2, Vector(125,0,0) )
    	ParticleManager:ReleaseParticleIndex( particle )
    else
    	local particle = ParticleManager:CreateParticle( "particles/econ/items/axe/axe_helm_shoutmask/axe_beserkers_call_owner_shoutmask.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    	ParticleManager:SetParticleControl( particle, 0, self:GetCaster():GetOrigin() )
    	ParticleManager:SetParticleControl( particle, 1, self:GetCaster():GetOrigin() )
    	ParticleManager:SetParticleControl( particle, 2, Vector(125,0,0) )
    	ParticleManager:ReleaseParticleIndex( particle )
    end
end

modifier_glad_sorry_target = class({})

function modifier_glad_sorry_target:IsHidden()
    return false
end

function modifier_glad_sorry_target:IsPurgable()
    return false
end

function modifier_glad_sorry_target:OnCreated( kv )
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( self:GetCaster() )
    self:GetParent():MoveToTargetToAttack( self:GetCaster() )
    self:StartIntervalThink(FrameTime())
end

function modifier_glad_sorry_target:OnIntervalThink( kv )
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_fountain_passive_invul") or (not self:GetCaster():IsAlive()) then
        self:Destroy()
    end
end

function modifier_glad_sorry_target:OnRemoved()
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( nil )
end

function modifier_glad_sorry_target:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_TAUNTED] = true,
    }

    return state
end

function modifier_glad_sorry_target:GetStatusEffectName()
	if self:GetCaster():HasModifier("modifier_valakas_arcana") then
		return "particles/birzhapass/valakas_arcana_sorry_owner_effect.vpcf" 
	end
    return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

LinkLuaModifier( "modifier_Valakas_DabDabDab", "abilities/heroes/valakas.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Valakas_DabDabDab_lifesteal", "abilities/heroes/valakas.lua", LUA_MODIFIER_MOTION_NONE )

Valakas_DabDabDab = class({})

function Valakas_DabDabDab:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_bp_valakas_reward") then
        return "Valakas/DabDabDab_arcana"
    end
    return "Valakas/DabDabDab"
end

function Valakas_DabDabDab:GetIntrinsicModifierName()
    return "modifier_Valakas_DabDabDab"
end

modifier_Valakas_DabDabDab = class({})

function modifier_Valakas_DabDabDab:IsHidden()
    return true
end

function modifier_Valakas_DabDabDab:IsPurgable()
    return false
end

function modifier_Valakas_DabDabDab:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_ATTACK
    }

    return decFuncs
end

function modifier_Valakas_DabDabDab:OnAttack( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if params.target == self:GetParent() then
        if target:IsOther() then
            return nil
        end
    	local chance = self:GetAbility():GetSpecialValueFor("chance")
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if RandomInt(1, 100) <= chance then
            parent:AddNewModifier( parent, self:GetAbility(), "modifier_Valakas_DabDabDab_lifesteal", { duration = 1.5 } )
        end
    end
end

modifier_Valakas_DabDabDab_lifesteal = class({})

function modifier_Valakas_DabDabDab_lifesteal:IsPurgable()
    return true
end

function modifier_Valakas_DabDabDab_lifesteal:IsHidden()
    return true
end

function modifier_Valakas_DabDabDab_lifesteal:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_Valakas_DabDabDab_lifesteal:GetModifierAttackSpeedBonus_Constant ( params )
    return 15000
end

function modifier_Valakas_DabDabDab_lifesteal:OnAttackLanded(kv)
    if IsServer() then
        local attacker = kv.attacker
        local target = kv.target
        local damage = kv.damage
        if self:GetParent() == attacker then
            self.lifesteal = self:GetAbility():GetSpecialValueFor( "lifesteal" ) / 100
            self:GetParent():EmitSound("gladbak")
            if self:GetCaster():HasModifier("modifier_bp_valakas_reward") then
                local particle = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
                ParticleManager:SetParticleControl( particle, 1, Vector( 125, 125, 125 ) )
                ParticleManager:ReleaseParticleIndex( particle )
            else
                local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
                ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetOrigin(), true )
                ParticleManager:ReleaseParticleIndex( particle )
            end
            print(kv.original_damage, " ", kv.damage, " ", self.lifesteal, " ", self:GetAbility():GetSpecialValueFor( "lifesteal" ))
            attacker:Heal(damage * self.lifesteal, self:GetAbility())
            self:Destroy()
        end
    end
end

LinkLuaModifier( "modifier_valakas_dadaya_stacks", "abilities/heroes/valakas.lua", LUA_MODIFIER_MOTION_NONE )

Valakas_DaDaYa = class({})

function Valakas_DaDaYa:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_bp_valakas_reward") then
        return "Valakas/DaDaYa_arcana"
    end
    return "Valakas/DaDaYa"
end

function Valakas_DaDaYa:GetIntrinsicModifierName()
    return "modifier_valakas_dadaya_stacks"
end

modifier_valakas_dadaya_stacks = class({})

function modifier_valakas_dadaya_stacks:IsPurgable()
    return false
end

function modifier_valakas_dadaya_stacks:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_HERO_KILLED,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }

    return decFuncs
end

function modifier_valakas_dadaya_stacks:OnHeroKilled( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        parent:EmitSound("gladda")
        self:IncrementStackCount()
        if self:GetCaster():HasModifier("modifier_bp_valakas_reward") then
            local particle = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_blink_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent )
            ParticleManager:SetParticleControl( particle, 0, parent:GetOrigin() )
            ParticleManager:ReleaseParticleIndex( particle )
        end
    end
end

function modifier_valakas_dadaya_stacks:GetModifierBonusStats_Strength( params )
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("bonus_strength") + self:GetCaster():FindTalentValue("special_bonus_birzha_valakas_4"))
end

LinkLuaModifier( "modifier_Valakas_Gadza", "abilities/heroes/valakas.lua", LUA_MODIFIER_MOTION_NONE )

Valakas_Gadza = class({})

function Valakas_Gadza:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Valakas_Gadza:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Valakas_Gadza:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Valakas_Gadza:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_bp_valakas_reward") then
        return "Valakas/Gadza_arcana"
    end
    return "Valakas/Gadza"
end

function Valakas_Gadza:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    if self:GetCaster():HasModifier("modifier_bp_valakas_reward") then
        self:GetCaster():EmitSound("gadzaarcana")
    else
        self:GetCaster():EmitSound("gladult")
    end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_Valakas_Gadza", { duration = duration } )
end

modifier_Valakas_Gadza = class({})

function modifier_Valakas_Gadza:IsPurgable()
    return false
end

function modifier_Valakas_Gadza:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.4)
end

function modifier_Valakas_Gadza:OnDestroy()
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_bp_valakas_reward") then
        self:GetCaster():StopSound("gadzaarcana")
    else
        self:GetCaster():StopSound("gladult")
    end
end

function modifier_Valakas_Gadza:OnIntervalThink()
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_valakas_1")
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local flag = DOTA_UNIT_TARGET_FLAG_NONE
    if self:GetCaster():HasTalent("special_bonus_birzha_valakas_5") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
    self:GetCaster():GetAbsOrigin(),
    nil,
    radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
    flag,
    FIND_ANY_ORDER,
    false)

    if self:GetCaster():HasModifier("modifier_bp_valakas_reward") then
        local particle = ParticleManager:CreateParticle( "particles/birzhapass/valakas_arcana_gadza.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl( particle, 0, self:GetCaster():GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex( particle )
    else
        local particle = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_egset.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl( particle, 0, self:GetCaster():GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex( particle )
    end

    for _,unit in pairs(targets) do
        ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
        if self:GetCaster():HasTalent("special_bonus_birzha_valakas_2") then
            unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = 0.1 } )
        end
    end
end