LinkLuaModifier("modifier_kelthuzad_die_and_decripify_cold_thinker", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kelthuzad_die_and_decripify_cold_stunned", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kelthuzad_die_and_decripify_thinker", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kelthuzad_die_and_decripify_thinker_debuff", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kelthuzad_die_and_decripify_thinker_friendly", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kelthuzad_die_and_decripify_thinker_friendly_buff", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)

kelthuzad_die_and_decripify = class({})

function kelthuzad_die_and_decripify:Precache(context)
    local particle_list = 
    {
        "particles/dead_lich/dead_lich_decay.vpcf",
        "particles/dead_lich/recuto_projectile.vpcf",
        "particles/dead_lich/dead_lich_pre_cast_cold.vpcf",
        "particles/dead_lich/dead_lich_ability_cold.vpcf",
        "particles/dead_lich/dead_lich_cast_after.vpcf",
        "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf",
        "particles/units/heroes/hero_crystalmaiden/maiden_shard_frostbite.vpcf",
        "particles/dead_lich/skverna_thinker.vpcf",
        "particles/units/heroes/hero_undying/undying_zombie_spawn.vpcf",
        "particles/status_fx/status_effect_rupture.vpcf",
        "particles/dead_lich/effect_thirst_owner.vpcf",
        "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf",
        "particles/units/heroes/hero_lich/lich_ice_spire_debuff.vpcf",
        "particles/status_fx/status_effect_frost_lich.vpcf",
        "particles/dead_lich/steal_soul_target.vpcf",
        "particles/dead_lich/knight_die_effect.vpcf",
        "particles/dead_lich/knight_effect_ambient_shadow.vpcf",
        "particles/dead_lich_death_knight_effect.vpcf",
        "particles/dead_lich/death_knight_spawn_effect.vpcf",
        "particles/dead_lich/chain_cast.vpcf",
        "particles/dead_lich/dead_lich_chain_effect.vpcf",
        "particles/dead_lich/chain_pulling.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function kelthuzad_die_and_decripify:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function kelthuzad_die_and_decripify:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_kelthuzad_cold_undead") then
        return "kelthuzad/die_and_decripify"
    end
    return "kelthuzad/die_and_decripify_2"
end

function kelthuzad_die_and_decripify:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    if self:GetCaster():HasModifier("modifier_kelthuzad_cold_undead") then
        self:ColdSpellStart(point)
    else
        self:UndeadSpellStart(point)
    end
end

function kelthuzad_die_and_decripify:ColdSpellStart(point)
    if not IsServer() then return end
    local delay = self:GetSpecialValueFor("delay")
    CreateModifierThinker(self:GetCaster(), self, "modifier_kelthuzad_die_and_decripify_cold_thinker", {duration = 1}, point, self:GetCaster():GetTeamNumber(), false) 
end

function kelthuzad_die_and_decripify:OnProjectileHit(target, location)
    if not IsServer() then return end
    Timers:CreateTimer(FrameTime(), function()
        UTIL_Remove(target)
    end)
    local radius = self:GetSpecialValueFor("radius")
    local decay_particle = ParticleManager:CreateParticle("particles/dead_lich/dead_lich_decay.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(decay_particle, 0, location)
    ParticleManager:SetParticleControl(decay_particle, 1, Vector(radius, 0, 0))
    ParticleManager:SetParticleControl(decay_particle, 2, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(decay_particle)
    local duration = self:GetSpecialValueFor("filth_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kelthuzad_3")
    CreateModifierThinker(self:GetCaster(), self, "modifier_kelthuzad_die_and_decripify_thinker", {duration = duration}, location, self:GetCaster():GetTeamNumber(), false) 
    CreateModifierThinker(self:GetCaster(), self, "modifier_kelthuzad_die_and_decripify_thinker_friendly", {duration = duration}, location, self:GetCaster():GetTeamNumber(), false) 
end

function kelthuzad_die_and_decripify:UndeadSpellStart(point)
    if not IsServer() then return end
    local thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_invulnerable", {}, point, self:GetCaster():GetTeamNumber(), false)
    local info = 
	{
		EffectName = "particles/dead_lich/recuto_projectile.vpcf",
		Dodgeable = true,
		Ability = self,
		ProvidesVision = true,
		VisionRadius = 100,
		bVisibleToEnemies = true,
		iMoveSpeed = self:GetSpecialValueFor("proj_speed"),
		Source = self:GetCaster(),
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		Target = thinker,
		bReplaceExisting = false,
	}
    self:GetCaster():EmitSound("kelthuzad_aoe_cast")
	ProjectileManager:CreateTrackingProjectile(info)
end

modifier_kelthuzad_die_and_decripify_cold_thinker = class({})

function modifier_kelthuzad_die_and_decripify_cold_thinker:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("cold_radius")
    self.damage = self:GetAbility():GetSpecialValueFor("cold_damage")
    self.root_duration = self:GetAbility():GetSpecialValueFor("root_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kelthuzad_4")
    local particle = ParticleManager:CreateParticle( "particles/dead_lich/dead_lich_pre_cast_cold.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 1, Vector( self.radius, self:GetDuration(), 1 ) )
	ParticleManager:ReleaseParticleIndex( particle )
    self:GetParent():EmitSound("Hero_Tusk.IceShards.Projectile")
end

function modifier_kelthuzad_die_and_decripify_cold_thinker:OnDestroy()
    if not IsServer() then return end
    EmitSoundOnLocationWithCaster( self:GetParent():GetAbsOrigin(), "Hero_Tusk.IceShards", self:GetCaster() )
    local particle = ParticleManager:CreateParticle( "particles/dead_lich/dead_lich_ability_cold.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetAbsOrigin() + Vector( 0, 0, 40 ) )
    ParticleManager:SetParticleControl( particle, 1, Vector( self.radius, 0, 0) )
    ParticleManager:ReleaseParticleIndex( particle )

    local particle_nova = ParticleManager:CreateParticle("particles/dead_lich/dead_lich_cast_after.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( particle_nova, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle_nova, 1, Vector(self.radius,0,0) )

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
    for _,enemy in pairs( enemies ) do
        ApplyDamage( { victim = enemy, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()} )
        enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_kelthuzad_die_and_decripify_cold_stunned", { duration = self.root_duration * (1-enemy:GetStatusResistance()) } )
    end
end

modifier_kelthuzad_die_and_decripify_cold_stunned = class({})
function modifier_kelthuzad_die_and_decripify_cold_stunned:GetTexture() return "kelthuzad/die_and_decripify" end

function modifier_kelthuzad_die_and_decripify_cold_stunned:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(particle, false, false, -1, false, false)
    local particle_vusal = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_shard_frostbite.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(particle_vusal, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(particle_vusal, false, false, -1, false, false)
end

function modifier_kelthuzad_die_and_decripify_cold_stunned:CheckState()
    return
    {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
    }
end

modifier_kelthuzad_die_and_decripify_thinker = class({})

function modifier_kelthuzad_die_and_decripify_thinker:OnCreated()
    if not IsServer() then return end
    self:GetParent():EmitSound("kelthuzad_aoe_spawn")
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.percent_damage = self:GetAbility():GetSpecialValueFor("percent_damage")
    self.duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kelthuzad_2")
    local particle = ParticleManager:CreateParticle( "particles/dead_lich/skverna_thinker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( particle, 1, Vector( self.radius, 1, 1 ) )
	ParticleManager:SetParticleControl( particle, 2, Vector( self:GetDuration(), 0, 0 ) )
	self:AddParticle( particle, false, false, -1, false, false )
    self:StartIntervalThink(0.5)
end

function modifier_kelthuzad_die_and_decripify_thinker:OnIntervalThink()
    if not IsServer() then return end
    if self.duration > 0 then
        self.duration = self.duration - 0.5
    else
        self:StartIntervalThink(-1)
    end
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
    for _,enemy in pairs( enemies ) do
        local damage = self:GetParent():GetMaxHealth() / 100 * self.percent_damage
        ApplyDamage( { victim = enemy, attacker = self:GetCaster(), damage = damage * 0.5, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()} )
    end
end

function modifier_kelthuzad_die_and_decripify_thinker:IsAura()
    return true
end

function modifier_kelthuzad_die_and_decripify_thinker:GetModifierAura()
    return "modifier_kelthuzad_die_and_decripify_thinker_debuff"
end

function modifier_kelthuzad_die_and_decripify_thinker:GetAuraRadius()
    return self.radius
end

function modifier_kelthuzad_die_and_decripify_thinker:GetAuraDuration()
    return 0
end

function modifier_kelthuzad_die_and_decripify_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_kelthuzad_die_and_decripify_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_kelthuzad_die_and_decripify_thinker:GetAuraSearchFlags()
    return 0
end

modifier_kelthuzad_die_and_decripify_thinker_debuff = class({})
function modifier_kelthuzad_die_and_decripify_thinker_debuff:GetTexture() return "kelthuzad/die_and_decripify_2" end

function modifier_kelthuzad_die_and_decripify_thinker_debuff:DeclareFunctions()
	local decFuncs = 
    {
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
	return decFuncs
end

function modifier_kelthuzad_die_and_decripify_thinker_debuff:Custom_HealAmplifyReduce()
	return self:GetAbility():GetSpecialValueFor('health_decrease')
end

function modifier_kelthuzad_die_and_decripify_thinker_debuff:GetModifierHPRegenAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor('health_decrease')
end

modifier_kelthuzad_die_and_decripify_thinker_friendly = class({})

function modifier_kelthuzad_die_and_decripify_thinker_friendly:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_kelthuzad_die_and_decripify_thinker_friendly:IsAura()
    return true
end

function modifier_kelthuzad_die_and_decripify_thinker_friendly:GetModifierAura()
    return "modifier_kelthuzad_die_and_decripify_thinker_friendly_buff"
end

function modifier_kelthuzad_die_and_decripify_thinker_friendly:GetAuraRadius()
    return self.radius
end

function modifier_kelthuzad_die_and_decripify_thinker_friendly:GetAuraDuration()
    return 0
end

function modifier_kelthuzad_die_and_decripify_thinker_friendly:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_kelthuzad_die_and_decripify_thinker_friendly:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_kelthuzad_die_and_decripify_thinker_friendly:GetAuraSearchFlags()
    return 0
end

modifier_kelthuzad_die_and_decripify_thinker_friendly_buff = class({})
function modifier_kelthuzad_die_and_decripify_thinker_friendly_buff:GetTexture() return "kelthuzad/die_and_decripify_2" end

function modifier_kelthuzad_die_and_decripify_thinker_friendly_buff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }
end

function modifier_kelthuzad_die_and_decripify_thinker_friendly_buff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor_bonus")
end

function modifier_kelthuzad_die_and_decripify_thinker_friendly_buff:GetModifierHealthRegenPercentage()
	return self:GetAbility():GetSpecialValueFor('health_regen_bonus')
end

LinkLuaModifier("modifier_kelthuzad_zombie_handler", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kelthuzad_zombie_active", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kelthuzad_zombie_ai", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)

kelthuzad_zombie = class({})

function kelthuzad_zombie:GetIntrinsicModifierName()
    return "modifier_kelthuzad_zombie_handler"
end

function kelthuzad_zombie:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kelthuzad_zombie_active", {duration = self:GetSpecialValueFor("duration_active")})
end

modifier_kelthuzad_zombie_active = class({})
function modifier_kelthuzad_zombie_active:IsPurgable() return false end
function modifier_kelthuzad_zombie_active:IsPurgeException() return false end

modifier_kelthuzad_zombie_handler = class({})

function modifier_kelthuzad_zombie_handler:IsHidden() return true end
function modifier_kelthuzad_zombie_handler:IsPurgable() return false end
function modifier_kelthuzad_zombie_handler:IsPurgeException() return false end
function modifier_kelthuzad_zombie_handler:RemoveOnDeath() return false end
function modifier_kelthuzad_zombie_handler:OnCreated()
    if not IsServer() then return end
    if self:GetParent():IsIllusion() then return end
    self.zombie_think = 0
    self.zombies = {}
    self:StartIntervalThink(1)
end

function modifier_kelthuzad_zombie_handler:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetParent():IsAlive() then return end
    local zombie_count = self:GetAbility():GetSpecialValueFor("zombie_count")
    if #self.zombies >= zombie_count then return end
    local zombie_cooldown = self:GetAbility():GetSpecialValueFor("zombie_cooldown")
    if self:GetParent():HasModifier("modifier_kelthuzad_zombie_active") then
        zombie_cooldown = self:GetAbility():GetSpecialValueFor("zombie_cooldown_active")
    end
    self.zombie_think = self.zombie_think + 1
    if self.zombie_think >= zombie_cooldown then
        self.zombie_think = 0
        self:SpawnNewZombie()
    end
end

function modifier_kelthuzad_zombie_handler:SpawnNewZombie()
    if not IsServer() then return end

	local zombie = CreateUnitByName("npc_dota_kelthuzad_zombie_"..RandomInt(1, 2), self:GetParent():GetAbsOrigin(), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
    zombie:SetOwner(self:GetCaster())
	table.insert(self.zombies, zombie)
    
	zombie:EmitSound("Undying_Zombie.Spawn")

	FindClearSpaceForUnit(zombie, self:GetParent():GetAbsOrigin() + RandomVector(self:GetParent():GetHullRadius() + zombie:GetHullRadius()), true)

	ResolveNPCPositions(zombie:GetAbsOrigin(), self:GetParent():GetHullRadius())

    local kelthuzad_king_blood = self:GetCaster():FindAbilityByName("kelthuzad_king_blood")
    if kelthuzad_king_blood then
        kelthuzad_king_blood:UpdateZombie(zombie)
    end

	if zombie.AI ~= nil then
		zombie.AI.hBucket = self:GetCaster()
	end

	zombie:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kelthuzad_zombie_ai", {})
end

function modifier_kelthuzad_zombie_handler:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_DEATH
    }
end

function modifier_kelthuzad_zombie_handler:OnDeath(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end

    for i=1, #self.zombies do
        local zombie = self.zombies[i]
        if zombie and not zombie:IsNull() and zombie:IsAlive() then
            zombie:ForceKill(false)
        end
    end

    Timers:CreateTimer(1, function()
        self.zombies = {}
    end)
end

modifier_kelthuzad_zombie_ai = class({})

function modifier_kelthuzad_zombie_ai:IsHidden()
    return true
end

function modifier_kelthuzad_zombie_ai:IsPurgable()
    return false
end

function modifier_kelthuzad_zombie_ai:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_zombie_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:ReleaseParticleIndex(particle)
    self.health = self:GetAbility():GetSpecialValueFor( "attack_count_die" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kelthuzad_1")
    self:GetParent():SetBaseMaxHealth(self.health * 2)
    self:GetParent():SetMaxHealth(self.health * 2)
    self:GetParent():SetHealth(self.health * 2)
end

function modifier_kelthuzad_zombie_ai:OnDestroy()
    if not IsServer() then return end
    if not self:GetCaster():IsAlive() then return end
    local modifier_kelthuzad_zombie_handler = self:GetCaster():FindModifierByName("modifier_kelthuzad_zombie_handler")
    if modifier_kelthuzad_zombie_handler then
        for i = #modifier_kelthuzad_zombie_handler.zombies, 1, -1 do
            if modifier_kelthuzad_zombie_handler.zombies[i] and modifier_kelthuzad_zombie_handler.zombies[i] == self:GetParent() then
                table.remove(modifier_kelthuzad_zombie_handler.zombies, i)
                if self:GetParent():IsAlive() then
                    self:GetParent():ForceKill(false)
                end
                break
            end
        end
    end
end

function modifier_kelthuzad_zombie_ai:CheckState()
    local state =
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }
    return state
end

function modifier_kelthuzad_zombie_ai:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
    return decFuncs
end

function modifier_kelthuzad_zombie_ai:GetDisableHealing()
    return 1
end

function modifier_kelthuzad_zombie_ai:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_kelthuzad_zombie_ai:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_kelthuzad_zombie_ai:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_kelthuzad_zombie_ai:GetModifierHealthBarPips()
    return self:GetAbility():GetSpecialValueFor( "attack_count_die" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kelthuzad_1")
end

function modifier_kelthuzad_zombie_ai:OnAttackLanded(params)
    if not IsServer() then return end
    if params.target == self:GetParent() then
        if self:GetParent():IsRealHero() then
            self.health = self.health - 2
        else
            self.health = self.health - 1
        end
        if self.health <= 0 then
            self:GetParent():ForceKill(false)
        else
            self:GetParent():SetHealth(self.health)
        end
    end
end

function modifier_kelthuzad_zombie_ai:GetModifierProcAttack_BonusDamage_Physical(params)
    local bonus_damage = 0
    local modifier_kelthuzad_king_blood_active_cold = self:GetParent():FindModifierByName("modifier_kelthuzad_king_blood_active_cold")
    if modifier_kelthuzad_king_blood_active_cold then
        bonus_damage = self:GetCaster():GetIntellect(false) / 100 * modifier_kelthuzad_king_blood_active_cold:GetAbility():GetSpecialValueFor("bonus_intellect_damage")
    end
    if self:GetCaster():HasTalent("special_bonus_birzha_kelthuzad_7") then
        self:GetCaster():PerformAttack(params.target, true, true, true, false, false, true, true)
    end
	return self:GetCaster():GetAverageTrueAttackDamage(nil) + bonus_damage
end

function modifier_kelthuzad_zombie_ai:GetModifierMoveSpeed_Absolute()
	return self:GetCaster():GetMoveSpeedModifier(self:GetCaster():GetBaseMoveSpeed(), true) + 75
end

function modifier_kelthuzad_zombie_ai:CheckState()
	return 
	{
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_DISARMED] = not self:GetCaster():IsAlive() or self:GetCaster():IsDisarmed() or self:GetCaster():IsStunned() or self:GetCaster():IsInvisible(),
		[MODIFIER_STATE_STUNNED] = not self:GetCaster():IsAlive() or self:GetCaster():IsDisarmed() or self:GetCaster():IsStunned(),
        [MODIFIER_STATE_INVISIBLE] = not self:GetCaster():IsAlive() or self:GetCaster():IsInvisible(),
	}
end

function modifier_kelthuzad_zombie_ai:GetModifierInvisibilityLevel()
    if self:GetCaster():IsInvisible() then
        return 1
    end
    return 0
end

LinkLuaModifier("modifier_kelthuzad_king_blood_active", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kelthuzad_king_blood_active_cold", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kelthuzad_king_blood_health_effect", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kelthuzad_king_blood_slow", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)

kelthuzad_king_blood = class({})

function kelthuzad_king_blood:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_kelthuzad_cold_undead") then
        return "kelthuzad/king_blood_2"
    end
    return "kelthuzad/king_blood"
end

function kelthuzad_king_blood:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("effect_duration")
    
    if self:GetCaster():HasModifier("modifier_kelthuzad_cold_undead") then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kelthuzad_king_blood_active_cold", {duration = duration})
        self:GetCaster():EmitSound("Hero_Lich.SinisterGaze.Cast")
    else
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kelthuzad_king_blood_active", {duration = duration})
        self:GetCaster():EmitSound("kelthuzad_blood")
    end
end

function kelthuzad_king_blood:UpdateZombie(zombie)
    if self:GetCaster():HasModifier("modifier_kelthuzad_king_blood_active_cold") then
        zombie:AddNewModifier(self:GetCaster(), self, "modifier_kelthuzad_king_blood_active_cold", {})
    end
    if self:GetCaster():HasModifier("modifier_kelthuzad_king_blood_active") then
        zombie:AddNewModifier(self:GetCaster(), self, "modifier_kelthuzad_king_blood_active", {})
    end
end

modifier_kelthuzad_king_blood_active = class({})
function modifier_kelthuzad_king_blood_active:IsPurgable() return false end
function modifier_kelthuzad_king_blood_active:GetTexture() return "kelthuzad/king_blood" end

function modifier_kelthuzad_king_blood_active:OnCreated()
    if not IsServer() then return end
    if self:GetParent():IsRealHero() then
        local modifier_kelthuzad_zombie_handler = self:GetCaster():FindModifierByName("modifier_kelthuzad_zombie_handler")
        if modifier_kelthuzad_zombie_handler then
            for _, zombie in pairs(modifier_kelthuzad_zombie_handler.zombies) do
                zombie:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kelthuzad_king_blood_active", {})
            end
        end
    end
end

function modifier_kelthuzad_king_blood_active:OnDestroy()
    if not IsServer() then return end
    if self:GetParent():IsRealHero() then
        local modifier_kelthuzad_zombie_handler = self:GetCaster():FindModifierByName("modifier_kelthuzad_zombie_handler")
        if modifier_kelthuzad_zombie_handler then
            for _, zombie in pairs(modifier_kelthuzad_zombie_handler.zombies) do
                if zombie and not zombie:IsNull() and zombie:IsAlive() then
                    zombie:RemoveModifierByName("modifier_kelthuzad_king_blood_active")
                end
            end
        end
    end
end

function modifier_kelthuzad_king_blood_active:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_kelthuzad_king_blood_active:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target == self:GetParent() then return end
    if params.target:IsOther() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kelthuzad_king_blood_health_effect", {duration = self:GetAbility():GetSpecialValueFor("duration_health")})
end

function modifier_kelthuzad_king_blood_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_rupture.vpcf"
end

function modifier_kelthuzad_king_blood_active:GetEffectName()
	return "particles/dead_lich/effect_thirst_owner.vpcf"
end

function modifier_kelthuzad_king_blood_active:StatusEffectPriority()
	return 500
end

modifier_kelthuzad_king_blood_health_effect = class({})
function modifier_kelthuzad_king_blood_health_effect:GetTexture() return "kelthuzad/king_blood" end
function modifier_kelthuzad_king_blood_health_effect:IsPurgable() return false end

function modifier_kelthuzad_king_blood_health_effect:OnCreated()
    if not IsServer() then return end
    self:IncrementStackCount()
    self:GetParent():CalculateStatBonus(true)
    self:GetParent():Heal(self:GetAbility():GetSpecialValueFor("bonus_max_health_per_attack"), self:GetAbility())
end

function modifier_kelthuzad_king_blood_health_effect:OnRefresh()
    if not IsServer() then return end
    self:IncrementStackCount()
    self:GetParent():CalculateStatBonus(true)
    self:GetParent():Heal(self:GetAbility():GetSpecialValueFor("bonus_max_health_per_attack"), self:GetAbility())
end

function modifier_kelthuzad_king_blood_health_effect:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_HEALTH_BONUS
    }
end

function modifier_kelthuzad_king_blood_health_effect:GetModifierHealthBonus()
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("bonus_max_health_per_attack") + self:GetCaster():FindTalentValue("special_bonus_birzha_kelthuzad_5"))
end

modifier_kelthuzad_king_blood_active_cold = class({})
function modifier_kelthuzad_king_blood_active_cold:IsPurgable() return false end
function modifier_kelthuzad_king_blood_active_cold:GetTexture() return "kelthuzad/king_blood_2" end

function modifier_kelthuzad_king_blood_active_cold:OnCreated()
    if not IsServer() then return end
    if self:GetParent():IsRealHero() then
        local modifier_kelthuzad_zombie_handler = self:GetCaster():FindModifierByName("modifier_kelthuzad_zombie_handler")
        if modifier_kelthuzad_zombie_handler then
            for _, zombie in pairs(modifier_kelthuzad_zombie_handler.zombies) do
                zombie:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kelthuzad_king_blood_active_cold", {})
            end
        end
    end

    local target_effect = self:GetParent()

    local imbued_ice_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(imbued_ice_particle, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(imbued_ice_particle, false, false, -1, false, false)

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_ice_spire_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetOrigin())
    ParticleManager:SetParticleControlEnt( particle, 1, target_effect, PATTACH_POINT_FOLLOW, "attach_hitloc", target_effect:GetOrigin(), true )
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_kelthuzad_king_blood_active_cold:OnDestroy()
    if not IsServer() then return end
    if self:GetParent():IsRealHero() then
        local modifier_kelthuzad_zombie_handler = self:GetCaster():FindModifierByName("modifier_kelthuzad_zombie_handler")
        if modifier_kelthuzad_zombie_handler then
            for _, zombie in pairs(modifier_kelthuzad_zombie_handler.zombies) do
                if zombie and not zombie:IsNull() and zombie:IsAlive() then
                    zombie:RemoveModifierByName("modifier_kelthuzad_king_blood_active_cold")
                end
            end
        end
    end
end

function modifier_kelthuzad_king_blood_active_cold:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_kelthuzad_king_blood_active_cold:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target == self:GetParent() then return end
    if params.target:IsOther() then return end
    if self:GetParent() ~= self:GetCaster() then return end
    params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kelthuzad_king_blood_slow", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
end

modifier_kelthuzad_king_blood_slow = class({})
function modifier_kelthuzad_king_blood_slow:GetTexture() return "kelthuzad/king_blood_2" end

function modifier_kelthuzad_king_blood_slow:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_kelthuzad_king_blood_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_kelthuzad_king_blood_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost_lich.vpcf"
end

LinkLuaModifier("modifier_kelthuzad_death_knight", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)

kelthuzad_death_knight = class({})

function kelthuzad_death_knight:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local info = 
    {
		Target = self:GetCaster(),
		Source = target,
		Ability = self,
		EffectName = "particles/dead_lich/steal_soul_target.vpcf",
		iMoveSpeed = 1200,
		vSourceLoc = target:GetAbsOrigin(),             
		bDrawsOnMinimap = false,                         
		bDodgeable = false,                               
		bVisibleToEnemies = true,                        
		bReplaceExisting = false,  
        ExtraData = {target = target:entindex()}                       
	}
    target:EmitSound("kelthuzad_soul_steal")
	ProjectileManager:CreateTrackingProjectile(info)
end

function kelthuzad_death_knight:OnProjectileHit_ExtraData(caster_target, point, table)
    if not IsServer() then return end
    local target = EntIndexToHScript(table.target)
    if self.knight ~= nil then
        self.knight:RemoveModifierByName("modifier_kelthuzad_death_knight")
    end
    if target then
        local spawn_point = self:GetCaster():GetAbsOrigin() + RandomVector(250)
        local knight = CreateUnitByName( target:GetUnitName(), spawn_point, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber()  )
        if knight then
            self.knight = knight
            knight:AddNewModifier(self:GetCaster(), self, "modifier_kelthuzad_death_knight", {duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_kelthuzad_6")})
            knight:SetUnitCanRespawn(true)
            knight:SetRespawnsDisabled(true)
            knight:RemoveModifierByName("modifier_fountain_invulnerability")
            knight.IsRealHero = function() return true end
            knight.IsMainHero = function() return false end
            knight.IsTempestDouble = function() return true end
            knight:SetControllableByPlayer(self:GetCaster():GetPlayerOwnerID(), true)
            knight:SetRenderColor(85, 85, 85)
            knight:SetAbilityPoints(0)
            knight:SetPlayerID(self:GetCaster():GetPlayerOwnerID())
            knight:SetHasInventory(false)
            knight:SetCanSellItems(false)
            Timers:CreateTimer(FrameTime(), function()
                knight:RemoveModifierByName("modifier_fountain_invulnerability")
                knight:RemoveModifierByName("modifier_birzha_invul")
            end)

            local particle = ParticleManager:CreateParticle( "particles/dead_lich/knight_die_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, knight )
            ParticleManager:SetParticleControlEnt(particle, 0, knight, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", knight:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(particle)

            for itemSlot = 0,16 do
                local itemName = target:GetItemInSlot(itemSlot)
                if itemName then 
                    if itemName:GetName() ~= "item_rapier" and itemName:GetName() ~= "item_gem" and itemName:GetName() ~= "item_roscom_midas" and itemName:IsPermanent() then
                        local newItem = CreateItem(itemName:GetName(), nil, nil)
                        knight:AddItem(newItem)
                        if itemName and itemName:GetCurrentCharges() > 0 and newItem and not newItem:IsNull() then
                            newItem:SetCurrentCharges(itemName:GetCurrentCharges())
                        end
                        if newItem and not newItem:IsNull() then
                            knight:SwapItems(newItem:GetItemSlot(), itemSlot)
                        end
                        newItem:SetSellable(false)
                        newItem:SetDroppable(false)
                        newItem:SetShareability( ITEM_FULLY_SHAREABLE )
                        newItem:SetPurchaser( nil )
                    end
                end
            end
            while knight:GetLevel() < target:GetLevel() do
                knight:HeroLevelUp( false )
                knight:SetAbilityPoints(0)
            end
            for i = 0, 24 do
                local ability = target:GetAbilityByIndex(i)
                if ability then
                    local knight_ability = knight:FindAbilityByName(ability:GetAbilityName())
                    if i == 5 then
                        if not self:GetCaster():HasScepter() then
                            knight_ability:SetActivated(false)
                        else
                            if knight_ability then
                                knight_ability:SetLevel(ability:GetLevel())
                            end
                        end
                    else
                        if knight_ability then
                            knight_ability:SetLevel(ability:GetLevel())
                        end
                    end
                end
            end
            knight:CalculateStatBonus(true)
        end
    end
end

modifier_kelthuzad_death_knight = class({})
function modifier_kelthuzad_death_knight:IsPurgable() return false end
function modifier_kelthuzad_death_knight:IsPurgeException() return false end

function modifier_kelthuzad_death_knight:OnCreated()
    if not IsServer() then return end
    self:GetParent():EmitSound("kelthuzad_spawn_knight")
    local particle_ambient = ParticleManager:CreateParticle( "particles/dead_lich/knight_effect_ambient_shadow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt(particle_ambient, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(particle_ambient, false, false, -1, false, false)
end

function modifier_kelthuzad_death_knight:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_LIFETIME_FRACTION,
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_kelthuzad_death_knight:GetModifierIncomingDamage_Percentage()
    if self:GetCaster():HasTalent("special_bonus_birzha_kelthuzad_8") then
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("incoming_damage") - 100
end

function modifier_kelthuzad_death_knight:GetModifierTotalDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("outgoing_damage") - 100
end

function modifier_kelthuzad_death_knight:GetUnitLifetimeFraction( params )
	return ( ( self:GetDieTime() - GameRules:GetGameTime() ) / self:GetDuration() )
end

function modifier_kelthuzad_death_knight:GetEffectName()
    return "particles/dead_lich_death_knight_effect.vpcf"
end

function modifier_kelthuzad_death_knight:OnDestroy()
    if not IsServer() then return end
    local particle_target = ParticleManager:CreateParticle( "particles/dead_lich/death_knight_spawn_effect.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl(particle_target, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_target)
    for _, mod in pairs(self:GetParent():FindAllModifiers()) do
        if mod ~= self then
            mod:Destroy()
        end
    end
    local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    for _, unit in pairs(units) do
        if unit ~= self:GetParent() then
            if unit:IsRealHero() then
                for _, mod in pairs(unit:FindAllModifiers()) do
                    if mod and mod:GetCaster() == self:GetParent() then
                        mod:Destroy()
                    end
                end
            end
        end
    end
    self:GetAbility().knight = nil
    UTIL_Remove(self:GetParent())
end

function modifier_kelthuzad_death_knight:GetMinHealth()
    return 1
end

function modifier_kelthuzad_death_knight:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if self:GetParent():GetHealth() > 1 then return end
    self:Destroy()
end

LinkLuaModifier("modifier_kelthuzad_cold_undead", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)

kelthuzad_cold_undead = class({})

function kelthuzad_cold_undead:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_kelthuzad_cold_undead") then
        return "kelthuzad/cold_undead"
    end
    return "kelthuzad/cold_undead_2"
end

function kelthuzad_cold_undead:OnSpellStart()
    if not IsServer() then return end
    local modifier_kelthuzad_cold_undead = self:GetCaster():FindModifierByName("modifier_kelthuzad_cold_undead")
    if modifier_kelthuzad_cold_undead then
        modifier_kelthuzad_cold_undead:Destroy()
    else
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kelthuzad_cold_undead", {})
    end
end

modifier_kelthuzad_cold_undead = class({})
function modifier_kelthuzad_cold_undead:IsHidden() return true end
function modifier_kelthuzad_cold_undead:IsPurgable() return false end
function modifier_kelthuzad_cold_undead:RemoveOnDeath() return false end
function modifier_kelthuzad_cold_undead:IsPurgeException() return false end

LinkLuaModifier("modifier_kelthuzad_chain_find", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kelthuzad_chain_pull", "abilities/heroes/kelthuzad", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

kelthuzad_chain = class({})

function kelthuzad_chain:OnInventoryContentsChanged()
    if self:GetCaster():HasShard() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function kelthuzad_chain:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function kelthuzad_chain:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local cast_particle = ParticleManager:CreateParticle("particles/dead_lich/chain_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(cast_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(cast_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(cast_particle, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(cast_particle)
    target:EmitSound("kelthuzad_chain_cast")
    target:AddNewModifier(self:GetCaster(), self, "modifier_kelthuzad_chain_find", {duration = self:GetSpecialValueFor("duration")})
end

modifier_kelthuzad_chain_find = class({})

function modifier_kelthuzad_chain_find:OnCreated()
    if not IsServer() then return end
    self.active = true
    self.radius = self:GetAbility():GetSpecialValueFor("radius")

    self.particle = ParticleManager:CreateParticle("particles/dead_lich/dead_lich_chain_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.particle, false, false, -1, false, false)

    self:StartIntervalThink(FrameTime())
end

function modifier_kelthuzad_chain_find:OnIntervalThink()
    if not IsServer() then return end
    if not self.active then return end
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
    for _,enemy in pairs( enemies ) do
        if enemy and enemy ~= self:GetParent() and enemy:HasModifier("modifier_kelthuzad_chain_find") then
            self.active = false
            self:TargetChain(enemy)
            self:Destroy()
        end
    end
end

function modifier_kelthuzad_chain_find:TargetChain(target)
    if not IsServer() then return end
    target:RemoveModifierByName("modifier_kelthuzad_chain_find")
    target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kelthuzad_chain_pull", {target = self:GetParent():entindex()})
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kelthuzad_chain_pull", {target = target:entindex()})
    self:GetParent():EmitSound("kelthuzad_chain_active")
    target:EmitSound("kelthuzad_chain_active")
end

modifier_kelthuzad_chain_pull = class({})

function modifier_kelthuzad_chain_pull:IsDebuff() return false end
function modifier_kelthuzad_chain_pull:IsHidden() return true end

function modifier_kelthuzad_chain_pull:OnCreated(params)
    if not IsServer() then return end
    self.target = EntIndexToHScript(params.target)
    self.speed = 600
    self.angle = (self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
    self.point = (self:GetParent():GetAbsOrigin() + self.target:GetAbsOrigin()) / 2

    self.particle = ParticleManager:CreateParticle("particles/dead_lich/chain_pulling.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 2, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 10, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.particle, false, false, -1, false, false)

    if self:ApplyHorizontalMotionController() == false then
        self:Destroy()
    end
end

function modifier_kelthuzad_chain_pull:OnDestroy()
    if not IsServer() then return end
    self:GetParent():InterruptMotionControllers( true )
    ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
end

function modifier_kelthuzad_chain_pull:CheckState()
    return
    {
        [MODIFIER_STATE_ROOTED] = true
    }
end

function modifier_kelthuzad_chain_pull:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
    local origin = self:GetParent():GetOrigin()
    if not self.target:IsAlive() then
        self:Destroy()
    end
    local direction = self.point - origin
    direction.z = 0
    local distance = direction:Length2D()
    direction = direction:Normalized()
    local flPad = self:GetParent():GetPaddedCollisionRadius()
    if distance<flPad then
        self:Destroy()
    elseif distance>1500 then
        self:Destroy()
    end
    GridNav:DestroyTreesAroundPoint(origin, 80, false)
    local target = origin + direction * self.speed * dt
    self:GetParent():SetOrigin( target )
    self:GetParent():FaceTowards( self.target:GetOrigin() )
end

function modifier_kelthuzad_chain_pull:OnHorizontalMotionInterrupted()
    self:Destroy()
end