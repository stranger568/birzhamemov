LinkLuaModifier( "modifier_ayano_TakeACircularSaw", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Ayano_TakeACircularSaw = class({})

function Ayano_TakeACircularSaw:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ayano_TakeACircularSaw:OnToggle()
    local caster = self:GetCaster()
    local toggle = self:GetToggleState()
    if not IsServer() then return end
    caster:EmitSound("ayanopila")
    if toggle then
        self.modifier = caster:AddNewModifier( caster, self, "modifier_ayano_TakeACircularSaw", {} )
    else
        if self.modifier and not self.modifier:IsNull() then
            self.modifier:Destroy()
        end
        self.modifier = nil
    end
end

modifier_ayano_TakeACircularSaw = class({})

function modifier_ayano_TakeACircularSaw:IsHidden()
    return true
end

function modifier_ayano_TakeACircularSaw:IsPurgable()
    return false
end

function modifier_ayano_TakeACircularSaw:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_ayano_TakeACircularSaw:GetEffectName()
    return "particles/units/heroes/hero_sven/sven_warcry_buff.vpcf"
end

function modifier_ayano_TakeACircularSaw:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_ayano_TakeACircularSaw:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControlEnt( particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
        ParticleManager:SetParticleControl( particle, 1, target:GetOrigin() )
        ParticleManager:SetParticleControlForward( particle, 1, (self:GetParent():GetOrigin()-target:GetOrigin()):Normalized() )
        ParticleManager:SetParticleControlEnt( particle, 10, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true )
        ParticleManager:ReleaseParticleIndex( particle )
        target:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
    end
end

function modifier_ayano_TakeACircularSaw:GetModifierBaseDamageOutgoing_Percentage()
    if self:GetCaster():HasTalent("special_bonus_birzha_ayano_1") then return self:GetCaster():FindTalentValue("special_bonus_birzha_ayano_1") end
    return 0
end

function modifier_ayano_TakeACircularSaw:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("base_attack_time")
end

LinkLuaModifier( "modifier_Ayano_Tranquilizer_1", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ayano_Tranquilizer_2", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ayano_Tranquilizer_3", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )

Ayano_Tranquilizer = class({})

function Ayano_Tranquilizer:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ayano_Tranquilizer:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Ayano_Tranquilizer:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ayano_Tranquilizer:OnSpellStart()
    local caster = self:GetCaster()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local info = {
        Target = target,
        Source = caster,
        Ability = self, 
        EffectName = "particles/econ/items/dazzle/dazzle_darkclaw/dazzle_darkclaw_poison_touch.vpcf",
        iMoveSpeed = 1600,
        bReplaceExisting = false,
        bProvidesVision = true,
        iVisionRadius = 25,
        iVisionTeamNumber = caster:GetTeamNumber()
    }
    ProjectileManager:CreateTrackingProjectile(info)
    caster:EmitSound("Hero_Dazzle.Poison_Cast")
end

function Ayano_Tranquilizer:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target:IsMagicImmune() then return end
    if target==nil then return end
    if target:TriggerSpellAbsorb( self ) then return end
    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_ayano_2")
    ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
    target:AddNewModifier( self:GetCaster(), self, "modifier_Ayano_Tranquilizer_3", {duration = 1} )
end

modifier_Ayano_Tranquilizer_3 = class({})

function modifier_Ayano_Tranquilizer_3:IsPurgable()
    return true
end

function modifier_Ayano_Tranquilizer_3:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_Ayano_Tranquilizer_3:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_speed_1") 
end

function modifier_Ayano_Tranquilizer_3:OnDestroy()
    if not IsServer() then return end
    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Ayano_Tranquilizer_2", {duration = 0.5} )
end

modifier_Ayano_Tranquilizer_2 = class({})

function modifier_Ayano_Tranquilizer_2:IsPurgable()
    return true
end

function modifier_Ayano_Tranquilizer_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_Ayano_Tranquilizer_2:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_speed_2") 
end

function modifier_Ayano_Tranquilizer_2:OnDestroy()
    if not IsServer() then return end
    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_Ayano_Tranquilizer_1", {duration = 0.5} )
end

modifier_Ayano_Tranquilizer_1 = class({})

function modifier_Ayano_Tranquilizer_1:IsPurgable()
    return true
end

function modifier_Ayano_Tranquilizer_1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_Ayano_Tranquilizer_1:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_speed_3") 
end

function modifier_Ayano_Tranquilizer_1:OnDestroy()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("stun_duration") 
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned_purge", {duration = duration})
end

LinkLuaModifier( "modifier_Ayano_WeakMind_buff", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Ayano_WeakMind_passive", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )

Ayano_WeakMind = class({})

function Ayano_WeakMind:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ayano_WeakMind:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Ayano_WeakMind:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ayano_WeakMind:GetIntrinsicModifierName()
    return "modifier_Ayano_WeakMind_passive"
end

function Ayano_WeakMind:OnSpellStart()
    local caster = self:GetCaster()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") 
    local target = self:GetCursorTarget()
    target:AddNewModifier( caster, self, "modifier_Ayano_WeakMind_buff", {duration = duration} )
    caster:EmitSound("hero_bloodseeker.rupture.cast")
end

modifier_Ayano_WeakMind_passive = class({})

function modifier_Ayano_WeakMind_passive:IsHidden()
    return true
end

function modifier_Ayano_WeakMind_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_Ayano_WeakMind_passive:OnAttackLanded(kv)
    if IsServer() then
        local attacker = kv.attacker
        local target = kv.target
        local damage = kv.damage
		if attacker:GetTeam() == target:GetTeam() then
			return
		end 
        if self:GetParent() == attacker then
            self.heal_multiplier = self:GetAbility():GetSpecialValueFor("heal_multiplier") + self:GetCaster():FindTalentValue("special_bonus_birzha_ayano_4")
            attacker:Heal(damage * (self.heal_multiplier * 0.01), self:GetAbility())
        end
    end
end

modifier_Ayano_WeakMind_buff = class({})

function modifier_Ayano_WeakMind_buff:IsPurgable()
    return true
end

function modifier_Ayano_WeakMind_buff:GetEffectName()
    return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
end

function modifier_Ayano_WeakMind_buff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW 
end

function modifier_Ayano_WeakMind_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_Ayano_WeakMind_buff:OnAttackLanded(kv)
    if IsServer() then
        local attacker = kv.attacker
        local target = kv.target
        local damage = kv.damage
        if self:GetParent() == attacker then
            self.heal_multiplier = (self:GetAbility():GetSpecialValueFor("heal_multiplier") + self:GetCaster():FindTalentValue("special_bonus_birzha_ayano_4")) * 2
            attacker:Heal(damage * (self.heal_multiplier * 0.01), self:GetAbility())
        end
    end
end

local model_list = {
    "models/courier/baby_rosh/babyroshan.vmdl",
    "models/courier/donkey_trio/mesh/donkey_trio.vmdl",
    "models/courier/mechjaw/mechjaw.vmdl",
    "models/courier/huntling/huntling.vmdl",
    "models/items/courier/devourling/devourling.vmdl",
    "models/courier/seekling/seekling.vmdl",
    "models/courier/venoling/venoling.vmdl",
    "models/items/courier/amaterasu/amaterasu.vmdl",
    "models/items/courier/beaverknight_s2/beaverknight_s2.vmdl",
    "models/items/courier/nian_courier/nian_courier.vmdl",
    "models/items/courier/faceless_rex/faceless_rex.vmdl",
    "models/pets/icewrack_wolf/icewrack_wolf.vmdl",
    "models/props_gameplay/chicken.vmdl",
}

local selection = "models/courier/baby_rosh/babyroshan.vmdl"

LinkLuaModifier("modifier_ayano_mischief", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ayano_mischie_invul", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE)

Ayano_Mischief = class({})

function Ayano_Mischief:OnSpellStart()
    if self:GetCaster():HasModifier("modifier_ayano_mischief") then
        self:GetCaster():RemoveModifierByName("modifier_ayano_mischief")
    else
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ayano_mischief", {} )
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ayano_mischie_invul", {duration = 0.2} )
        self:GetCaster():EmitSound("aynoinvis")
        self:EndCooldown()
    end
end

modifier_ayano_mischief = class({})

function modifier_ayano_mischief:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }

    return funcs
end

function modifier_ayano_mischief:Exposed()
    if self:GetParent():HasModifier("modifier_ayano_mischief") then
        self:GetParent():RemoveModifierByName("modifier_ayano_mischief")
        self:GetAbility():UseResources(false, false, true)
    end
end

function modifier_ayano_mischief:IsHidden() return true end

function modifier_ayano_mischief:OnAttackStart( keys )
    if keys.attacker == self:GetParent() then
        self:Exposed()
    end
end

function modifier_ayano_mischief:OnTakeDamage( keys )   
    if keys.unit == self:GetParent() or keys.attacker == self:GetParent() then
        self:Exposed()
    end
end

function modifier_ayano_mischief:OnAbilityExecuted( params )
    if IsServer() then
        local hAbility = params.ability
        if hAbility == self:GetAbility() then return end

        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
            return 0
        end

        self:Exposed()
    end
        
end

function modifier_ayano_mischief:GetEffectName()
    return "particles/units/heroes/hero_monkey_king/monkey_king_disguise.vpcf"
end

function modifier_ayano_mischief:CheckState()
    local state = {
    [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR]              = true,
    [MODIFIER_STATE_LOW_ATTACK_PRIORITY]        = true  }
    
    return state
end

function modifier_ayano_mischief:OnCreated()
    if not IsServer() then return end

    self.search_range   = 350
    self.particle       = ""
    self.model_found    = false
    self:SetStackCount(200)

    self:GetParent():RemoveDonate()
    
    if self:GetParent():HasModifier("modifier_get_xp") then
        selection = "models/props_gameplay/gold_coin001.vmdl"
        return
    end

    local trees = GridNav:GetAllTreesAroundPoint(self:GetParent():GetAbsOrigin(), self.search_range, false)
    if #trees > 0 then
        selection = "models/props_tree/frostivus_tree.vmdl"
        return
    end
    
    local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
    self:GetParent():GetAbsOrigin(),
    nil,
    self.search_range,
    DOTA_UNIT_TARGET_TEAM_BOTH,
    DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false)
    if (#units > 0) then
        selection = model_list[RandomInt(1, #model_list)]
        self:SetStackCount(380)
        return
    end
end

function modifier_ayano_mischief:OnRemoved()
    if not IsServer() then return end
    local poof = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_disguise.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(poof, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(poof)
    self:GetParent():AddDonate(PLAYERS[ self:GetParent():GetPlayerID() ].effect)
end

function modifier_ayano_mischief:GetModifierModelChange()
    return selection
end

function modifier_ayano_mischief:GetModifierMoveSpeed_Absolute()
    return self:GetStackCount()
end

function modifier_ayano_mischief:GetModifierMoveSpeed_AbsoluteMin()
    return self:GetStackCount()
end

function modifier_ayano_mischief:GetModifierMoveSpeed_Limit()
    return self:GetStackCount()
end

modifier_ayano_mischie_invul = class({})

function modifier_ayano_mischie_invul:IsHidden()
    return true
end

function modifier_ayano_mischie_invul:CheckState()
    local state = {
    [MODIFIER_STATE_INVULNERABLE] = true,}
    
    return state
end

LinkLuaModifier( "modifier_SpotTheTarget", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_SpotTheTarget_aura", "abilities/heroes/ayano.lua", LUA_MODIFIER_MOTION_NONE )

Ayano_SpotTheTarget = class({})

function Ayano_SpotTheTarget:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Ayano_SpotTheTarget:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Ayano_SpotTheTarget:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Ayano_SpotTheTarget:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    if target:TriggerSpellAbsorb( self ) then return end
    target:AddNewModifier( caster, self, "modifier_SpotTheTarget_aura", {duration = duration} )
    local particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_cast.vpcf", PATTACH_CUSTOMORIGIN, caster, caster:GetTeamNumber())
    ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)
    caster:EmitSound("aynoult")
end

modifier_SpotTheTarget_aura = class({})

function modifier_SpotTheTarget_aura:IsPurgable()
    return true
end

function modifier_SpotTheTarget_aura:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

function modifier_SpotTheTarget_aura:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    if not IsServer() then return end
    self.particle_shield_fx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent, self.caster:GetTeamNumber())
    ParticleManager:SetParticleControl(self.particle_shield_fx, 0, self.parent:GetAbsOrigin())
    self:AddParticle(self.particle_shield_fx, false, false, -1, false, true)
    self.particle_trail_fx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent, self.caster:GetTeamNumber())
    ParticleManager:SetParticleControl(self.particle_trail_fx, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(self.particle_trail_fx, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.particle_trail_fx, 8, Vector(1,0,0))
    self:AddParticle(self.particle_trail_fx, false, false, -1, false, false)
    self:StartIntervalThink(FrameTime())
end

function modifier_SpotTheTarget_aura:OnIntervalThink()
    self:SetStackCount(self.parent:GetGold())
    AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), 50, FrameTime(), false)
end

function modifier_SpotTheTarget_aura:CheckState()
    local state = {[MODIFIER_STATE_INVISIBLE] = false}
    return state
end

function modifier_SpotTheTarget_aura:DeclareFunctions()
    local decFuncs = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_TOOLTIP, }

    return decFuncs
end

function modifier_SpotTheTarget_aura:OnDeath(keys)
    if not IsServer() then return end
    local target = keys.unit
    if target == self.parent then
        local money = self:GetAbility():GetSpecialValueFor("money") + self:GetCaster():FindTalentValue("special_bonus_birzha_ayano_3")
        if self:GetParent():IsIllusion() then return end
        self.caster:ModifyGold( money, true, 0 )
    end
end

function modifier_SpotTheTarget_aura:OnTooltip()
    return self:GetStackCount()
end


function modifier_SpotTheTarget_aura:IsAura() return true end

function modifier_SpotTheTarget_aura:GetAuraRadius()
    return 999999
end

function modifier_SpotTheTarget_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_SpotTheTarget_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_SpotTheTarget_aura:GetModifierAura()
    return "modifier_SpotTheTarget"
end

function modifier_SpotTheTarget_aura:GetAuraEntityReject(target)
    if not IsServer() then return end
    if target == self:GetCaster() then
        return false
    else
        return true
    end
end

modifier_SpotTheTarget = class({})

function modifier_SpotTheTarget:IsPurgable()
    return true
end

function modifier_SpotTheTarget:GetEffectName()
    return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_haste.vpcf"
end

function modifier_SpotTheTarget:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_SpotTheTarget:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}

    return decFuncs
end

function modifier_SpotTheTarget:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_move_speed_pct")
end