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
    return self.BaseClass.GetCastRange(self, location, target) + self:GetCaster():FindTalentValue("special_bonus_birzha_valakas_1")
end

function Valakas_sorry:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Valakas_sorry:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()

    local duration = self:GetSpecialValueFor("duration")

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
        if not self:IsNull() then
            self:Destroy()
        end
    else
        self:GetParent():SetForceAttackTarget( self:GetCaster() )
        self:GetParent():MoveToTargetToAttack( self:GetCaster() )
    end
end

function modifier_glad_sorry_target:OnRemoved()
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( nil )
end

function modifier_glad_sorry_target:DeclareFunctions()
    local decFuns =
    {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return decFuns
end

function modifier_glad_sorry_target:GetModifierDamageOutgoing_Percentage()
    if not self:GetCaster():HasShard() then return end
    return self:GetAbility():GetSpecialValueFor("shard_damage")
end

function modifier_glad_sorry_target:CheckState()
    local state = 
    {
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
LinkLuaModifier( "modifier_Valakas_DabDabDab_scepter", "abilities/heroes/valakas.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Valakas_DabDabDab_debuff", "abilities/heroes/valakas.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Valakas_DabDabDab_cooldown", "abilities/heroes/valakas.lua", LUA_MODIFIER_MOTION_NONE )

Valakas_DabDabDab = class({})

function Valakas_DabDabDab:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) / ( self:GetCaster():GetCooldownReduction())
end

function Valakas_DabDabDab:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_PASSIVE
    if self:GetCaster():HasScepter() then
        behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return behavior
end

function Valakas_DabDabDab:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Valakas_DabDabDab_scepter", {duration = self:GetSpecialValueFor("scepter_duration")})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Valakas_DabDabDab_lifesteal", {duration = self:GetSpecialValueFor("scepter_duration")})
    self:GetCaster():EmitSound("gladbak")
end

function Valakas_DabDabDab:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_cooldown")
    end
end

function Valakas_DabDabDab:GetManaCost(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_manacost")
    end
end

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
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return decFuncs
end

function modifier_Valakas_DabDabDab:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker == self:GetParent() then return end
    if params.target ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if params.target:PassivesDisabled() then return end
    if self:GetParent():IsIllusion() then return end
    if self:GetCaster():HasModifier("modifier_Valakas_DabDabDab_scepter") then return end

    local chance = self:GetAbility():GetSpecialValueFor("chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_valakas_5")

    if RollPercentage(chance) then
        if not self:GetParent():HasModifier("modifier_Valakas_DabDabDab_cooldown") then
            if self:GetCaster():HasTalent("special_bonus_birzha_valakas_4") then
                params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Valakas_DabDabDab_debuff", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_valakas_4", "value2")})
            end
            self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_Valakas_DabDabDab_lifesteal", { duration = 1.5 } )
            self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_Valakas_DabDabDab_cooldown", {duration = 1})
        end
    end
end

modifier_Valakas_DabDabDab_cooldown = class({})

function modifier_Valakas_DabDabDab_cooldown:IsHidden() return true end
function modifier_Valakas_DabDabDab_cooldown:IsPurgable() return false end
function modifier_Valakas_DabDabDab_cooldown:IsPurgeException() return false end

modifier_Valakas_DabDabDab_debuff = class({})

function modifier_Valakas_DabDabDab_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
end

function modifier_Valakas_DabDabDab_debuff:GetModifierMagicalResistanceBonus()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_valakas_4")
end

modifier_Valakas_DabDabDab_lifesteal = class({})

function modifier_Valakas_DabDabDab_lifesteal:IsPurgable()
    return false
end

function modifier_Valakas_DabDabDab_lifesteal:IsHidden()
    return true
end

function modifier_Valakas_DabDabDab_lifesteal:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_Valakas_DabDabDab_lifesteal:GetModifierAttackSpeedBonus_Constant( params )
    return 15000
end

function modifier_Valakas_DabDabDab_lifesteal:GetModifierDamageOutgoing_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_valakas_3")
end

function modifier_Valakas_DabDabDab_lifesteal:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if params.inflictor == nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        
        local lifesteal = (self:GetAbility():GetSpecialValueFor( "lifesteal" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_valakas_7")) / 100

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

        params.attacker:Heal(params.damage * lifesteal, self:GetAbility())
        if self:GetParent():HasModifier("modifier_Valakas_DabDabDab_scepter") then return end
        self:Destroy()
    end
end


modifier_Valakas_DabDabDab_scepter = class({})
function modifier_Valakas_DabDabDab_scepter:IsPurgable() return false end




LinkLuaModifier( "modifier_valakas_dadaya", "abilities/heroes/valakas.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_valakas_dadaya_stacks", "abilities/heroes/valakas.lua", LUA_MODIFIER_MOTION_NONE )

Valakas_DaDaYa = class({})

function Valakas_DaDaYa:Spawn()
    if not IsServer() then return end
    if not self:GetCaster():HasModifier("modifier_valakas_dadaya") then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_valakas_dadaya", {})
    end
end

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

function modifier_valakas_dadaya_stacks:OnCreated()
    if not IsServer() then return end
    if not self:GetParent():IsIllusion() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_valakas_dadaya_stacks:OnIntervalThink()
    if self:GetCaster():HasModifier("modifier_valakas_dadaya") then
        self:SetStackCount(self:GetCaster():FindModifierByName("modifier_valakas_dadaya"):GetStackCount())
    end
    self:GetCaster():CalculateStatBonus(true)
end

function modifier_valakas_dadaya_stacks:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
    return decFuncs
end

function modifier_valakas_dadaya_stacks:IsHidden() return self:GetStackCount() == 0 end

function modifier_valakas_dadaya_stacks:GetModifierBonusStats_Strength( params )
    if self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_strength")
end

modifier_valakas_dadaya = class({})

function modifier_valakas_dadaya:IsHidden() return true end
function modifier_valakas_dadaya:IsPurgable() return false end
function modifier_valakas_dadaya:RemoveOnDeath() return false end

function modifier_valakas_dadaya:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_HERO_KILLED,
    }

    return decFuncs
end

function modifier_valakas_dadaya:OnHeroKilled( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if self:GetParent():IsIllusion() then return end
        parent:EmitSound("gladda")
        self:IncrementStackCount()
        if self:GetCaster():HasModifier("modifier_bp_valakas_reward") then
            local particle = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_blink_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent )
            ParticleManager:SetParticleControl( particle, 0, parent:GetOrigin() )
            ParticleManager:ReleaseParticleIndex( particle )
        end
    end
end

LinkLuaModifier( "modifier_Valakas_Gadza", "abilities/heroes/valakas.lua", LUA_MODIFIER_MOTION_NONE )

Valakas_Gadza = class({})

function Valakas_Gadza:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_valakas_2")
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
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    local radius = self:GetAbility():GetSpecialValueFor("radius")

    local flag = DOTA_UNIT_TARGET_FLAG_NONE

    if self:GetCaster():HasTalent("special_bonus_birzha_valakas_8") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, flag, FIND_ANY_ORDER, false)

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
        ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = damage * 0.4, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
        if self:GetCaster():HasTalent("special_bonus_birzha_valakas_6") then
            unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = self:GetCaster():FindTalentValue("special_bonus_birzha_valakas_6") * (1 - unit:GetStatusResistance()) } )
        end
    end
end