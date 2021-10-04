LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_silver_TopDeck", "abilities/heroes/silvername.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

SilverName_TopDeck = class({})

function SilverName_TopDeck:GetIntrinsicModifierName()
    return "modifier_silver_TopDeck"
end

modifier_silver_TopDeck = class({})

function modifier_silver_TopDeck:IsPurgable() return false end
function modifier_silver_TopDeck:IsHidden() return true end

function modifier_silver_TopDeck:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_silver_TopDeck:OnAttackStart(keys)
    if keys.attacker == self:GetParent() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        if keys.target:IsOther() then
            return nil
        end
        self.critProc = false
        self.chance = self:GetAbility():GetSpecialValueFor("chance")
        self.crit = self:GetAbility():GetSpecialValueFor("crit")
        if self.chance >= RandomInt(1, 100) then
            self:GetParent():StartGesture(ACT_DOTA_ATTACK)
            self:GetParent():EmitSound("silverdek")
            if not self:GetParent():HasModifier("modifier_silver_owl_buff") then
                local crit_pfx = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_attack_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
                ParticleManager:SetParticleControl(crit_pfx, 0, self:GetParent():GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(crit_pfx)
            end
            self.critProc = true
            return self.crit
        end 
    end
end

function modifier_silver_TopDeck:GetModifierPreAttack_CriticalStrike(params)
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    if self.critProc == true then
        return self.crit
    else
        return nil
    end
end

function modifier_silver_TopDeck:OnAttackLanded(params)
    if params.attacker == self:GetParent() then
        if self.critProc == true then
            self.critProc = false
        end
    end
end

LinkLuaModifier( "modifier_silver_screamer", "abilities/heroes/silvername.lua", LUA_MODIFIER_MOTION_NONE )

SilverName_Screamer = class({})

function SilverName_Screamer:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function SilverName_Screamer:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function SilverName_Screamer:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function SilverName_Screamer:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_silver_1")
    caster:EmitSound("silverscream")
    local effect_cast = ParticleManager:CreateParticle( "particles/silvername/pukich.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )
    for _,enemy in pairs(enemies) do
        self.damageTable = {
            victim = enemy,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
        }
        ApplyDamage( self.damageTable )
        enemy:AddNewModifier( caster, self, "modifier_silver_screamer", { duration = duration * (1 - enemy:GetStatusResistance()) } )
    end
end

modifier_silver_screamer = class({})

function modifier_silver_screamer:IsPurgable() return false end
function modifier_silver_screamer:IsPurgeException() return false end

function modifier_silver_screamer:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_FEARED] = true,
    }

    return state
end

function modifier_silver_screamer:OnCreated()
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

function modifier_silver_screamer:OnDestroy()
    if not IsServer() then return end
    self:GetParent():Stop()
end

LinkLuaModifier( "modifier_SilverName_Papaz_talent", "abilities/heroes/silvername.lua", LUA_MODIFIER_MOTION_NONE )

SilverName_Papaz = class({})

function SilverName_Papaz:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
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
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
        point,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        FIND_ANY_ORDER,
        false)

    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration})
    end

    self.papaz = CreateUnitByName("npc_dota_papaz_"..self:GetLevel(), point, true, caster, nil, caster:GetTeamNumber())
    self.papaz:SetOwner(caster)
    self.papaz:SetControllableByPlayer(caster:GetPlayerID(), true)
    FindClearSpaceForUnit(self.papaz, self.papaz:GetAbsOrigin(), true)
    self.papaz:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    if self:GetCaster():HasTalent("special_bonus_birzha_silver_4") then
        self.papaz:SetBaseDamageMin(self.papaz:GetBaseDamageMin() + 150)
        self.papaz:SetBaseDamageMax(self.papaz:GetBaseDamageMax() + 150)
    end
    if self:GetCaster():HasTalent("special_bonus_birzha_silver_3") then
        if self.papaz_count == nil then
            self.papaz_count = 0
        end
        self.papaz:AddNewModifier(self:GetCaster(), self, "modifier_SilverName_Papaz_talent", {})
    end
    local particle_start_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle_start_fx, 0, point)
    ParticleManager:ReleaseParticleIndex(particle_start_fx)
end

modifier_SilverName_Papaz_talent = class({})
function modifier_SilverName_Papaz_talent:IsPurgable() 	return false end
function modifier_SilverName_Papaz_talent:IsHidden() 	return true end

function modifier_SilverName_Papaz_talent:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_DEATH,
    }

    return funcs
end
function modifier_SilverName_Papaz_talent:OnAttackLanded(params)
    if params.target == self:GetParent() then
        if 50 >= RandomInt(1, 100) then
        	local duration = self:GetAbility():GetSpecialValueFor('duration')
            if self:GetAbility().papaz_count <= 4 then
    		    self.papaz = CreateUnitByName("npc_dota_papaz_"..self:GetAbility():GetLevel(), self:GetParent():GetAbsOrigin(), true, self:GetParent(), nil, self:GetParent():GetTeamNumber())
    		    self.papaz:SetOwner(self:GetParent())
    		    self.papaz:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
    		    FindClearSpaceForUnit(self.papaz, self.papaz:GetAbsOrigin(), true)
    		    self.papaz:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration = duration})
    		    if self:GetCaster():HasTalent("special_bonus_birzha_silver_4") then
    		        self.papaz:SetBaseDamageMin(self.papaz:GetBaseDamageMin() + 150)
    		        self.papaz:SetBaseDamageMax(self.papaz:GetBaseDamageMax() + 150)
    		    end
    		    if self:GetCaster():HasTalent("special_bonus_birzha_silver_3") then
    		        self.papaz:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_SilverName_Papaz_talent", {})
    		    end
    		    local particle_start_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    		    ParticleManager:SetParticleControl(particle_start_fx, 0, self:GetParent():GetAbsOrigin())
    		    ParticleManager:ReleaseParticleIndex(particle_start_fx)
                self:GetAbility().papaz_count = self:GetAbility().papaz_count + 1
            end
        end 
    end
end

function modifier_SilverName_Papaz_talent:OnDeath( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        if self:GetAbility().papaz_count >= 1 then
            self:GetAbility().papaz_count = self:GetAbility().papaz_count - 1
        end
    end
end

LinkLuaModifier( "modifier_silver_owl_buff", "abilities/heroes/silvername.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_silver_night", "abilities/heroes/silvername.lua", LUA_MODIFIER_MOTION_NONE )
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

function modifier_silver_owl_buff:IsPurgable() 	return false end
function modifier_silver_owl_buff:AllowIllusionDuplicate() return true end

function modifier_silver_owl_buff:OnCreated()
	if not IsServer() then return end
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

function modifier_silver_owl_buff:GetAuraRadius()
	return 25000
end

function modifier_silver_owl_buff:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

function modifier_silver_owl_buff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_silver_owl_buff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_silver_owl_buff:GetModifierAura()
	return "modifier_silver_night"
end

function modifier_silver_owl_buff:IsAura()
	return true
end

function modifier_silver_owl_buff:CheckState()
	return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,}
end

function modifier_silver_owl_buff:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}

	return decFuncs
end

function modifier_silver_owl_buff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor('bonus_movement_speed_pct_night')
end

function modifier_silver_owl_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor('bonus_attack_speed_night')
end

function modifier_silver_owl_buff:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor('bonus_range')
end

function modifier_silver_owl_buff:GetModifierModelChange()
    return "models/items/beastmaster/hawk/legacy_of_the_nords_legacy_of_the_nords_owl/legacy_of_the_nords_legacy_of_the_nords_owl.vmdl"
end

function modifier_silver_owl_buff:GetModifierProjectileName()
    return "particles/units/heroes/hero_dark_willow/dark_willow_base_attack.vpcf"
end

modifier_silver_night = class({})

function modifier_silver_night:IsPurgable() return false end

function modifier_silver_night:OnCreated()
	if not IsServer() then return end
	self.vision_reduction_pct = self:GetAbility():GetSpecialValueFor("blind_percentage")
	self.original_base_night_vision = self:GetParent():GetBaseNightTimeVisionRange()
	self:GetParent():SetNightTimeVisionRange(self.original_base_night_vision * (100 - self.vision_reduction_pct) / 100)
end

function modifier_silver_night:OnDestroy()
	if not IsServer() then return end 
	self:GetParent():SetNightTimeVisionRange(self.original_base_night_vision)
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
	if self:GetParent():HasTalent("special_bonus_birzha_silver_2") then
		if not GameRules:IsDaytime() then
			if not self:GetParent():HasModifier("modifier_silver_owl_buff") then self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_silver_owl_buff", {}) end
		else
			if self:GetParent():HasModifier("modifier_silver_owl_buff") then self:GetParent():RemoveModifierByName("modifier_silver_owl_buff") end
		end
	end
end




