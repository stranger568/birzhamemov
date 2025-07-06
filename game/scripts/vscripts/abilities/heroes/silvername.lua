LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_silver_TopDeck", "abilities/heroes/silvername.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_silver_TopDeck_active", "abilities/heroes/silvername.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

SilverName_TopDeck = class({})

function SilverName_TopDeck:Precache(context)
    PrecacheResource("model", "models/creeps/ogre_1/large_ogre.vmdl", context)
    PrecacheResource("model", "models/creeps/ogre_1/boss_ogre.vmdl", context)
    local particle_list = 
    {
        "particles/neutral_fx/ogre_bruiser_smash.vpcf",
        "particles/units/heroes/hero_dark_willow/dark_willow_base_attack.vpcf",
        "particles/silvername/pukich.vpcf",
        "particles/econ/items/drow/drow_arcana/drow_arcana_silenced_v2.vpcf",
        "particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf",
        "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf",
        "particles/units/heroes/hero_night_stalker/nightstalker_change.vpcf",
        "particles/units/heroes/hero_night_stalker/nightstalker_night_buff.vpcf",
        "particles/units/heroes/hero_night_stalker/nightstalker_change.vpcf",
        "particles/units/heroes/hero_dark_willow/dark_willow_base_attack.vpcf",
        "particles/units/heroes/hero_night_stalker/nightstalker_shard_hunter.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
    PrecacheResource("model", "models/items/beastmaster/hawk/legacy_of_the_nords_legacy_of_the_nords_owl/legacy_of_the_nords_legacy_of_the_nords_owl.vmdl", context)
end

function SilverName_TopDeck:GetIntrinsicModifierName()
    return "modifier_silver_TopDeck"
end

function SilverName_TopDeck:GetCooldown(level)
    if self:GetCaster():HasModifier("modifier_silver_owl_buff") then
        return 0
    end
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_silver_1", "value2")
end

function SilverName_TopDeck:GetManaCost(level)
    if self:GetCaster():HasModifier("modifier_silver_owl_buff") then
        return 0
    end
    return self.BaseClass.GetManaCost(self, level)
end

function SilverName_TopDeck:GetBehavior()
    if self:GetCaster():HasModifier("modifier_silver_owl_buff") then
        return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function SilverName_TopDeck:OnSpellStart()
    if not IsServer() then return end
    local duration = (1 / self:GetCaster():GetAttacksPerSecond(true)) - (FrameTime() * 5)
    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, self:GetCaster():GetAttackSpeed(true))
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_silver_TopDeck_active", {duration = duration})
    self:GetCaster():EmitSound("silverdek")
end

modifier_silver_TopDeck_active = class({})

function modifier_silver_TopDeck_active:IsPurgable() return false end
function modifier_silver_TopDeck_active:IsHidden() return true end

function modifier_silver_TopDeck_active:OnDestroy()
    if not IsServer() then return end

    if not self:GetParent():IsAlive() then return end

    local radius = self:GetAbility():GetSpecialValueFor("radius")

    local origin = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 300

    EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "silver_aghanim", self:GetCaster() )

    local nFXIndex = ParticleManager:CreateParticle( "particles/neutral_fx/ogre_bruiser_smash.vpcf", PATTACH_WORLDORIGIN,  self:GetCaster()  )
    ParticleManager:SetParticleControl( nFXIndex, 0, origin )
    ParticleManager:SetParticleControl( nFXIndex, 1, Vector(radius, radius, radius ) )
    ParticleManager:ReleaseParticleIndex( nFXIndex )

    local damage = self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * (self:GetAbility():GetSpecialValueFor("crit") + self:GetCaster():FindTalentValue("special_bonus_birzha_silver_4"))

    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), origin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )

    for _,enemy in pairs( enemies ) do
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, enemy, damage, nil)
        ApplyDamage( { victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = nil } )
        self:GetParent():PerformAttack(enemy, true, true, true, true, false, true, true)
    end
end

function modifier_silver_TopDeck_active:CheckState()
    return {[MODIFIER_STATE_STUNNED] = true}
end

modifier_silver_TopDeck = class({})

function modifier_silver_TopDeck:IsPurgable() return false end
function modifier_silver_TopDeck:IsHidden() return true end

function modifier_silver_TopDeck:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
    }
    return funcs
end

function modifier_silver_TopDeck:GetModifierPreAttack_CriticalStrike(params)
    if self:GetParent():PassivesDisabled() then return end
    if params.target:IsWard() then return end
    if not self:GetParent():HasModifier("modifier_silver_owl_buff") then return end
    local chance = self:GetAbility():GetSpecialValueFor("chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_silver_1")

    if RollPercentage(chance) then
        return self:GetAbility():GetSpecialValueFor("crit") + self:GetCaster():FindTalentValue("special_bonus_birzha_silver_4")
    end
end

LinkLuaModifier( "modifier_silver_screamer", "abilities/heroes/silvername.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_silver_screamer_thinker", "abilities/heroes/silvername.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_silver_screamer_silence", "abilities/heroes/silvername.lua", LUA_MODIFIER_MOTION_NONE )

SilverName_Screamer = class({})

function SilverName_Screamer:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_silver_3")
end

function SilverName_Screamer:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function SilverName_Screamer:GetCastRange(location, target)
    if self:GetCaster():HasModifier("modifier_silver_owl_buff") then
        return self:GetSpecialValueFor("cast_range_fly")
    end
    return self:GetSpecialValueFor("radius")
end

function SilverName_Screamer:GetBehavior()
    if self:GetCaster():HasModifier("modifier_silver_owl_buff") then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function SilverName_Screamer:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function SilverName_Screamer:OnSpellStart()
    if not IsServer() then return end

    if self:GetCaster():HasModifier("modifier_silver_owl_buff") then
        local point = self:GetCursorPosition()
        point = point + Vector(0,0,120)
        local target = CreateModifierThinker(self:GetCaster(), self, "modifier_silver_screamer_thinker", nil, point, self:GetCaster():GetTeamNumber(), false)

        local info = 
        {
            EffectName = "particles/units/heroes/hero_dark_willow/dark_willow_base_attack.vpcf",
            Ability = self,
            iMoveSpeed = 1200,
            Source = self:GetCaster(),
            Target = target,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
        }
        self:GetCaster():EmitSound("Hero_DeathProphet.Silence.Cast")
        ProjectileManager:CreateTrackingProjectile( info )
    else
        self:Scream(self:GetCaster():GetAbsOrigin())
    end
end

function SilverName_Screamer:OnProjectileHit( target, vLocation )
    if not IsServer() then return end

    if target == nil then return end

    self:Scream(vLocation)

    UTIL_Remove(target)

    return true
end

function SilverName_Screamer:Scream(point)
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_silver_5")
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")

    EmitSoundOnLocationWithCaster( point, "silverscream", self:GetCaster() )

    local effect_cast = ParticleManager:CreateParticle( "particles/silvername/pukich.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl(effect_cast, 0, point)
    ParticleManager:ReleaseParticleIndex( effect_cast )

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )

    for _,enemy in pairs(enemies) do
        ApplyDamage( { victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self } )
        enemy:AddNewModifier( self:GetCaster(), self, "modifier_silver_screamer", { duration = duration * (1 - enemy:GetStatusResistance()), x = point.x, y=point.y } )
    end
end

modifier_silver_screamer_thinker = class({})
function modifier_silver_screamer_thinker:IsHidden() return true end

modifier_silver_screamer = class({})

function modifier_silver_screamer:IsPurgable() return false end
function modifier_silver_screamer:IsPurgeException() return false end

function modifier_silver_screamer:CheckState()
    local state = 
    {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_FEARED] = true,
    }
    if self:GetCaster():HasShard() then
        state = 
        {
            [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
            [MODIFIER_STATE_DISARMED] = true,
            [MODIFIER_STATE_FEARED] = true,
            [MODIFIER_STATE_EVADE_DISABLED] = true,
        }
    end
    return state
end

function modifier_silver_screamer:OnCreated(params)
    if not IsServer() then return end
    local start_pos = Vector(params.x,params.y,0)
    local pos = (self:GetParent():GetAbsOrigin() - start_pos)
    pos.z = 0
    pos = pos:Normalized()
    self.position = self:GetParent():GetAbsOrigin() + pos * 3000
    self:GetParent():MoveToPosition( self.position )
end

function modifier_silver_screamer:OnDestroy()
    if not IsServer() then return end
    self:GetParent():Stop()
    --if self:GetCaster():HasTalent("special_bonus_birzha_silver_5") then
    --    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_silver_screamer_silence", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_silver_5") * (1 - self:GetParent():GetStatusResistance()) })
    --end
end

modifier_silver_screamer_silence = class({})

function modifier_silver_screamer_silence:GetEffectName()
    return "particles/econ/items/drow/drow_arcana/drow_arcana_silenced_v2.vpcf"
end

function modifier_silver_screamer_silence:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_silver_screamer_silence:CheckState()
    return 
    {
        [MODIFIER_STATE_SILENCED] = true
    }
end

SilverName_Papaz = class({})

function SilverName_Papaz:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_silver_2")
end

function SilverName_Papaz:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function SilverName_Papaz:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function SilverName_Papaz:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function SilverName_Papaz:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor( "radius" )
    local duration = self:GetSpecialValueFor('duration')
    local stun_duration = self:GetSpecialValueFor("stun_duration")

    caster:EmitSound("papaz")

    GridNav:DestroyTreesAroundPoint(point, radius, false)

    local flag = 0

    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, FIND_ANY_ORDER, false)

    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration})
    end

    self.papaz = CreateUnitByName("npc_dota_papaz_"..self:GetLevel(), point, true, caster, nil, caster:GetTeamNumber())
    self.papaz:SetOwner(caster)
    self.papaz:SetControllableByPlayer(caster:GetPlayerID(), true)

    FindClearSpaceForUnit(self.papaz, self.papaz:GetAbsOrigin(), true)

    self.papaz:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})

    local particle_start_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle_start_fx, 0, point)
    ParticleManager:ReleaseParticleIndex(particle_start_fx)
end

LinkLuaModifier( "modifier_silver_owl_buff", "abilities/heroes/silvername.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_silver_owl_talent", "abilities/heroes/silvername.lua", LUA_MODIFIER_MOTION_NONE )

SilverName_Owl = class({})

function SilverName_Owl:GetIntrinsicModifierName()
    return "modifier_silver_owl_talent"
end

function SilverName_Owl:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function SilverName_Owl:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function SilverName_Owl:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor('duration')
    caster:AddNewModifier(caster, self, "modifier_silver_owl_buff", {duration = duration})
    GameRules:BeginNightstalkerNight(duration)
    caster:EmitSound("Hero_Nightstalker.Darkness")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
end

modifier_silver_owl_buff = class({})

function modifier_silver_owl_buff:IsPurgable() return false end
function modifier_silver_owl_buff:AllowIllusionDuplicate() return true end
function modifier_silver_owl_buff:RemoveOnDeath() return false end

function modifier_silver_owl_buff:OnCreated()
	if not IsServer() then return end

    self.ultimate_caster = false

	self:GetAbility():SetActivated(false)

	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK) 

	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_change.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, self:GetParent():GetAbsOrigin())    
	ParticleManager:ReleaseParticleIndex(self.particle)

	self.particle_buff_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_night_buff.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())    
	ParticleManager:SetParticleControl(self.particle_buff_fx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle_buff_fx, 1, Vector(1,0,0))
	self:AddParticle(self.particle_buff_fx, false, false, -1, false, false)
end

function modifier_silver_owl_buff:OnRefresh()
	self:OnCreated()
end

function modifier_silver_owl_buff:OnDestroy()
	if not IsServer() then return end 
	self:GetAbility():SetActivated(true)
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_change.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, self:GetParent():GetAbsOrigin())    
	ParticleManager:ReleaseParticleIndex(self.particle)
end

function modifier_silver_owl_buff:CheckState()
	return 
    {
        [MODIFIER_STATE_FORCED_FLYING_VISION] = true,
        [MODIFIER_STATE_FLYING] = true,
	    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_silver_owl_buff:DeclareFunctions()
	local decFuncs = 
    {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return decFuncs
end

function modifier_silver_owl_buff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor('bonus_movement_speed_pct_night')
end

function modifier_silver_owl_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor('bonus_attack_speed_night') + self:GetCaster():FindTalentValue("special_bonus_birzha_silver_7")
end

function modifier_silver_owl_buff:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor('bonus_range') + self:GetCaster():FindTalentValue("special_bonus_birzha_silver_6")
end

function modifier_silver_owl_buff:GetModifierModelChange()
    return "models/items/beastmaster/hawk/legacy_of_the_nords_legacy_of_the_nords_owl/legacy_of_the_nords_legacy_of_the_nords_owl.vmdl"
end

function modifier_silver_owl_buff:GetModifierProjectileName()
    return "particles/units/heroes/hero_dark_willow/dark_willow_base_attack.vpcf"
end

function modifier_silver_owl_buff:GetAttackSound()
    return "Hero_DeathProphet.Attack"
end

modifier_silver_owl_talent = class({})

function modifier_silver_owl_talent:IsPurgable() return false end
function modifier_silver_owl_talent:IsHidden() return true end

function modifier_silver_owl_talent:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_silver_owl_talent:OnIntervalThink()
	if not IsServer() then return end
	if self:GetParent():HasScepter() then
		if not GameRules:IsDaytime() then
			if not self:GetParent():HasModifier("modifier_silver_owl_buff") then 
                local modifier = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_silver_owl_buff", {}) 
                if modifier then
                    modifier.ultimate_caster = true
                end
            end
		else
            local modifier_silver_owl_buff = self:GetParent():FindModifierByName("modifier_silver_owl_buff")
            if modifier_silver_owl_buff and modifier_silver_owl_buff.ultimate_caster then
                modifier_silver_owl_buff:Destroy()
            end
		end
	else
        if GameRules:IsDaytime() then
            local modifier_silver_owl_buff = self:GetParent():FindModifierByName("modifier_silver_owl_buff")
            if modifier_silver_owl_buff and modifier_silver_owl_buff.ultimate_caster then
                modifier_silver_owl_buff:Destroy()
            end
		end
    end
end

silvername_eat_papaz = class({})

function silvername_eat_papaz:OnInventoryContentsChanged()
    if self:GetCaster():HasTalent("special_bonus_birzha_silver_8") then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function silvername_eat_papaz:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function silvername_eat_papaz:CastFilterResultTarget(target)
    if target:GetUnitName() ~= "npc_dota_papaz_1" and target:GetUnitName() ~= "npc_dota_papaz_2" and target:GetUnitName() ~= "npc_dota_papaz_3" and target:GetUnitName() ~= "npc_dota_papaz_4" then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end 

function silvername_eat_papaz:GetCustomCastErrorTarget(target)
    if target:GetUnitName() ~= "npc_dota_papaz_1" and target:GetUnitName() ~= "npc_dota_papaz_2" and target:GetUnitName() ~= "npc_dota_papaz_3" and target:GetUnitName() ~= "npc_dota_papaz_4" then
        return "#dota_hud_error_papaz"
    end
end

function silvername_eat_papaz:OnSpellStart()
    if not IsServer() then return end

    local target = self:GetCursorTarget()

    local health = target:GetHealth()

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_shard_hunter.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())

    local heal = health / 100 * self:GetSpecialValueFor("heal")

    self:GetCaster():GiveMana(heal)
    self:GetCaster():Heal(heal, self)

    self:GetCaster():EmitSound("Hero_Pudge.Swallow")

    target:ForceKill(false)
end