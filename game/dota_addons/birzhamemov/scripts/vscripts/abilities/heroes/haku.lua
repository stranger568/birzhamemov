LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_haku_needle_attack", "abilities/heroes/haku.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_haku_needle_debuff", "abilities/heroes/haku.lua", LUA_MODIFIER_MOTION_NONE )

haku_needle = class({})

function haku_needle:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function haku_needle:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function haku_needle:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function haku_needle:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/haku_dagger.vpcf",
		iMoveSpeed = 1200,
		bReplaceExisting = false,
		bProvidesVision = true,
		iVisionRadius = 150,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	for i = 1, self:GetSpecialValueFor("count") do
		info.iMoveSpeed = info.iMoveSpeed - 150
		ProjectileManager:CreateTrackingProjectile(info)
		caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast")
	end
end

function haku_needle:OnProjectileHit( hTarget, vLocation )
	local target = hTarget
	if target==nil then return end
	if target:TriggerSpellAbsorb( self ) then return end
	if target:IsAttackImmune() then return end
	local duration = self:GetSpecialValueFor("duration")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local damage_base = self:GetSpecialValueFor("damage_base") + self:GetCaster():FindTalentValue("special_bonus_birzha_haku_2")
	local damage = self:GetSpecialValueFor("damage")
	local effect_cast = ParticleManager:CreateParticle( "particles/haku_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	 ParticleManager:SetParticleControl( effect_cast, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControlEnt(effect_cast,0,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetOrigin(),true)
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 1, (self:GetCaster():GetOrigin()-target:GetOrigin()):Normalized() )
	ParticleManager:SetParticleControlEnt( effect_cast, 10, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( effect_cast )
    local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_haku_needle_attack", {} )
	self:GetCaster():PerformAttack( target, false, true, true, false, false, false, true )
	ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = damage_base, ability=self, damage_type = DAMAGE_TYPE_PHYSICAL })
	target:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
	modifier:Destroy()
	target:AddNewModifier( self:GetCaster(), self, "modifier_haku_needle_debuff", {duration = duration * (1 - target:GetStatusResistance())} )
	target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_bashed", {duration = stun_duration} )
	target:EmitSound("Hero_PhantomAssassin.Dagger.Target")
end

modifier_haku_needle_attack = class({})

function modifier_haku_needle_attack:IsHidden()
	return true
end

function modifier_haku_needle_attack:IsPurgable()
	return false
end

function modifier_haku_needle_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,

	}

	return funcs
end

function modifier_haku_needle_attack:GetModifierDamageOutgoing_Percentage( params )
	if IsServer() then
		local dmg = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_haku_4")
		local damage = (100 - dmg) * -1
		return damage
	end
end

modifier_haku_needle_debuff = class({})

function modifier_haku_needle_debuff:IsPurgable()
	return true
end

function modifier_haku_needle_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_haku_needle_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor( "movespeed" )
end

function modifier_haku_needle_debuff:GetEffectName()
	return "particles/haku_dagger_debuff.vpcf"
end

function modifier_haku_needle_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_haku_speed_buff", "abilities/heroes/haku.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_haku_speed_debuff", "abilities/heroes/haku.lua", LUA_MODIFIER_MOTION_NONE )

haku_speed = class({})

function haku_speed:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_haku_speed_buff", {duration = self:GetSpecialValueFor( "duration" )} )
	caster:EmitSound("HakuSpeed")
end

modifier_haku_speed_buff = class({})

function modifier_haku_speed_buff:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_haku_speed_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_haku_speed_buff:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor( "movespeed" )
end

function modifier_haku_speed_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor( "attack_speed" )
end

function modifier_haku_speed_buff:GetEffectName()
	return "particles/haku_weaver.vpcf"
end

function modifier_haku_speed_buff:OnCreated()
	if not IsServer() then return end
	self.radius				= self:GetAbility():GetSpecialValueFor("radius")
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration_debuff" )
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invisible", {duration = self:GetAbility():GetSpecialValueFor("invis_duration")})
	self.hit_targets		= {}
	self.shukuchi_particle	= nil
	self:StartIntervalThink(FrameTime())
end

function modifier_haku_speed_buff:OnRefresh()
	if not IsServer() then return end
	self:OnCreated()
end


function modifier_haku_speed_buff:OnIntervalThink()
	self.enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, enemy in pairs(self.enemies) do
		if not self.hit_targets[enemy] then
			self.shukuchi_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_shukuchi_damage_arc.vpcf", PATTACH_ABSORIGIN, enemy)
			ParticleManager:SetParticleControl(self.shukuchi_particle, 0, enemy:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.shukuchi_particle, 1, enemy:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(self.shukuchi_particle)
			ApplyDamage({ victim = enemy, attacker = self:GetCaster(), damage = self.damage, ability=self:GetAbility(), damage_type = DAMAGE_TYPE_MAGICAL })
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_haku_speed_debuff", {duration = self.duration})
			self.shukuchi_particle = nil
			self.hit_targets[enemy]	= true
		end
	end
end

modifier_haku_speed_debuff = class({})

function modifier_haku_speed_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_haku_speed_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor( "movespeed_debuff" )
end

function modifier_haku_speed_debuff:GetEffectName()
	return "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step_debuff.vpcf"
end



LinkLuaModifier( "modifier_haku_best_buff", "abilities/heroes/haku.lua", LUA_MODIFIER_MOTION_NONE )

haku_best = class({})
modifier_haku_best_buff = class({})

function haku_best:GetIntrinsicModifierName()
	return "modifier_haku_best_buff"
end

function modifier_haku_best_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_EVENT_ON_DEATH,

	}
end

function modifier_haku_best_buff:GetModifierPreAttack_BonusDamage()
	if self:GetParent():HasModifier("modifier_haku_mask") then return 0 end
	return (self:GetAbility():GetSpecialValueFor( "bonus_damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_haku_5") ) * self:GetStackCount()
end

function modifier_haku_best_buff:OnHeroKilled( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
    	if self:GetCaster():HasModifier("modifier_haku_mask") then return end
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
        parent:EmitSound("")
        if self:GetStackCount() < self:GetAbility():GetSpecialValueFor( "max_stacks" ) then
        	self:IncrementStackCount()
        end
    end
end

function modifier_haku_best_buff:OnDeath( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() then 
    	if self:GetCaster():HasModifier("modifier_haku_mask") then return end   
        if self:GetStackCount() < 15 then
        	if self:GetStackCount() >= 1 then
        		if RandomInt(1, 100) <= 50 then           
        			self:DecrementStackCount()
        		end
        	end
        end
    end
end

haku_eyes = class({})


function haku_eyes:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_haku_3")
end

function haku_eyes:OnSpellStart()
	local caster = self:GetCaster()
	local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetOrigin(),
        nil,
        self:GetSpecialValueFor( "radius" ),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        FIND_CLOSEST,
        false
    )
    for _,enemy in pairs(enemies) do
	    local vector = self:GetCaster():GetOrigin()-enemy:GetOrigin()
	    local center_angle = VectorToAngles( vector ).y
	    local facing_angle = VectorToAngles( enemy:GetForwardVector() ).y
	    local distance = vector:Length2D()
		local facing = ( math.abs( AngleDiff(center_angle,facing_angle) ) < 85 )
		if facing then
			enemy:AddNewModifier( caster, self, "modifier_birzha_stunned_purge", {duration = (self:GetSpecialValueFor( "stun_duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_haku_1"))} )
			ApplyDamage({ victim = enemy, attacker = self:GetCaster(), damage = self:GetSpecialValueFor( "damage" ) + self:GetCaster():GetIntellect(), ability=self, damage_type = DAMAGE_TYPE_MAGICAL })
			break
		end
	end
	caster:EmitSound("HakuStun")
end

LinkLuaModifier("modifier_haku_needle_heal", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)

haku_needle_heal = class({}) 

function haku_needle_heal:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function haku_needle_heal:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function haku_needle_heal:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function haku_needle_heal:GetChannelTime()
    return self:GetSpecialValueFor("duration")
end

function haku_needle_heal:OnSpellStart() 
    self.target = self:GetCursorTarget()
    local duration = self:GetChannelTime()
    if self.target == nil then
        return
    end
    self:GetCaster():SetForwardVector(self.target:GetForwardVector())
    self.modifier_caster = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_haku_needle_heal", { duration = self:GetChannelTime() } )
end

function haku_needle_heal:OnChannelFinish( bInterrupted )
    self.modifier_caster:Destroy()
end

modifier_haku_needle_heal = class({}) 

function modifier_haku_needle_heal:OnCreated()
    if not IsServer() then return end
    self:OnIntervalThink()
    self:StartIntervalThink(0.5)
end

function modifier_haku_needle_heal:IsHidden()
    return true
end

function modifier_haku_needle_heal:IsPurgable()
    return false
end

function modifier_haku_needle_heal:OnIntervalThink()
	self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)
    local info = {
        Target = self:GetAbility().target,
        Source = self:GetCaster(),
        Ability = self:GetAbility(), 
        EffectName = "particles/haku_dagger.vpcf",
        iMoveSpeed = 1600,
        bReplaceExisting = false,
        bProvidesVision = true,
        iVisionRadius = 25,
        bDodgeable = false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber()
    }
    ProjectileManager:CreateTrackingProjectile(info)
    EmitSoundOn("HakuNeedleheal", self:GetCaster())
    self:GetCaster():StartGesture(ACT_DOTA_ATTACK)
end

function haku_needle_heal:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target==nil then return end
    local heal = self:GetSpecialValueFor( "heal" ) + (self:GetSpecialValueFor("int") * self:GetCaster():GetIntellect())
    target:Heal(heal, self)
    target:Purge(false, true, false, true, true)
    EmitSoundOn("", target)
end

LinkLuaModifier("modifier_haku_aura", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_aura_hero", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)

haku_aura = class({})

function haku_aura:GetIntrinsicModifierName() 
	return "modifier_haku_aura"
end

modifier_haku_aura = class({})

function modifier_haku_aura:IsAura() return true end
function modifier_haku_aura:IsAuraActiveOnDeath() return false end
function modifier_haku_aura:IsBuff() return true end
function modifier_haku_aura:IsHidden() return true end
function modifier_haku_aura:IsPermanent() return true end
function modifier_haku_aura:IsPurgable() return false end

function modifier_haku_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_haku_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_haku_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_haku_aura:GetModifierAura()
	if not self:GetParent():HasModifier("modifier_haku_mask") then return end
	return "modifier_haku_aura_hero"
end

modifier_haku_aura_hero = class({})

function modifier_haku_aura_hero:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function modifier_haku_aura_hero:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_haku_aura_hero:OnAttackLanded(kv)
    if IsServer() then
        local attacker = kv.attacker
        local target = kv.target
        local damage = kv.damage
        self.lifesteal = self:GetAbility():GetSpecialValueFor( "lifesteal" ) / 100
        if self:GetParent() == attacker then
            if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
            attacker:Heal(damage * self.lifesteal, self:GetAbility())
        end
    end
end





LinkLuaModifier("modifier_haku_help", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)

haku_help = class({}) 

function haku_help:OnSpellStart() 
    self.target = self:GetCursorTarget()
    self.target:AddNewModifier( self:GetCaster(), self, "modifier_haku_help", { duration = self:GetSpecialValueFor("duration") } )
    self:GetCaster():EmitSound("HakuHelp")
end

modifier_haku_help = class({})

function modifier_haku_help:IsHidden()
    return true
end

function modifier_haku_help:IsPurgable()
    return false
end

function modifier_haku_help:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MIN_HEALTH,
                      MODIFIER_EVENT_ON_TAKEDAMAGE}

    return decFuncs
end

function modifier_haku_help:OnCreated()
    if not IsServer() then return end
    self:PlayEffects()
    self:StartIntervalThink(FrameTime())
end

function modifier_haku_help:OnTakeDamage(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.unit 
    local damage = keys.damage
    local caster_health = self:GetParent():GetMaxHealth() / 2
    if self:GetCaster():HasTalent("special_bonus_birzha_papich_3") then
        caster_health = self:GetParent():GetMaxHealth()
    end
    local duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_papich_4")

    if self:GetParent() == target then
		if target:FindAbilityByName("Papich_reincarnation") then
	        if target:FindAbilityByName("Papich_reincarnation"):IsFullyCastable() or target:FindAbilityByName("scp682_ultimate"):IsFullyCastable() then
	            return false
	        end
	    end

	    if target:HasModifier("modifier_item_aeon_disk_buff") or target:HasModifier("modifier_item_uebator_active") or target:HasModifier("modifier_Felix_WaterShield") or target:HasModifier("modifier_Dio_Za_Warudo") or target:HasModifier("modifier_kurumi_zafkiel") or target:HasModifier("modifier_LenaGolovach_Radio_god") or target:HasModifier("modifier_pistoletov_deathfight") then
	        return false
	    end

	    for i = 0, 5 do 
	        local item = target:GetItemInSlot(i)
	        if item then
	            if item:GetName() == "item_uebator" or item:GetName() == "item_aeon_disk" then
	                if item:IsFullyCastable() then
	                    return false
	                end
	            end
	        end        
	    end
        if self:GetParent():GetHealth() <= 1 then
        	local damage_table = {}
            damage_table.victim = self:GetCaster()
            damage_table.attacker = attacker
            damage_table.ability = self:GetAbility()
            damage_table.damage_type = DAMAGE_TYPE_PURE
            damage_table.damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
            damage_table.damage = 999999
            ApplyDamage(damage_table)
            self:GetParent():Heal(self:GetAbility():GetSpecialValueFor("heal")+self:GetCaster():FindTalentValue("special_bonus_birzha_haku_6"), self:GetAbility())
            self:Destroy()           
        end
    end
end

function modifier_haku_help:GetMinHealth()
    return 1
end

function modifier_haku_help:PlayEffects()
	local effect_cast = ParticleManager:CreateParticle( "particles/emperor_time.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(effect_cast,false,false, -1,false,false)
	local effect_cast_2 = ParticleManager:CreateParticle( "particles/devil_trigger22.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
	ParticleManager:SetParticleControlEnt(effect_cast_2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast_2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast_2, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast_2, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast_2, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(effect_cast_2,false,false, -1,false,false)
end

LinkLuaModifier("modifier_haku_mask", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)

haku_mask = class({}) 

function haku_mask:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function haku_mask:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function haku_mask:OnSpellStart()
    if not IsServer() then return end
    EmitSoundOn("ui.inv_equip_jug", self:GetCaster())
end

function haku_mask:OnChannelFinish( bInterrupted )
	if bInterrupted then
		return
	end
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_haku_mask", {} )
end

modifier_haku_mask = class({})

function modifier_haku_mask:IsHidden()
    return true
end

function modifier_haku_mask:IsPurgable()
    return false
end


function modifier_haku_mask:RemoveOnDeath()
    return false
end

function modifier_haku_mask:OnCreated()
    if not IsServer() then return end
    self:GetParent():SwapAbilities("haku_needle", "haku_needle_heal", false, true)
    self:GetParent():SwapAbilities("haku_speed", "haku_eyes", false, true)
    self:GetParent():SwapAbilities("haku_best", "haku_aura", false, true)
    self:GetParent():SwapAbilities("haku_zerkala", "haku_help", false, true)
    self:GetParent():FindAbilityByName("haku_zerkalo"):SetHidden(true)
    self:GetCaster():FindAbilityByName("haku_mask"):SetHidden(true)
    self:GetAbility():SetActivated(false)
    self:GetParent():SetPrimaryAttribute(2)
    self:GetCaster():SetModel("models/haku/haku.vmdl")
    self:GetCaster():SetOriginalModel("models/haku/haku.vmdl")
end

function modifier_haku_mask:OnRemoved()
    if not IsServer() then return end
    self:GetParent():SwapAbilities("haku_needle_heal", "haku_needle", false, true)
    self:GetParent():SwapAbilities("haku_eyes", "haku_speed", false, true)
    self:GetParent():SwapAbilities("haku_aura", "haku_best", false, true)
    self:GetParent():SwapAbilities("haku_help", "haku_zerkala", false, true)
    self:GetParent():FindAbilityByName("haku_zerkalo"):SetHidden(false)
    self:GetCaster():FindAbilityByName("haku_mask"):SetHidden(false)
    self:GetAbility():SetActivated(true)
    self:GetParent():SetPrimaryAttribute(1)
    self:GetCaster():SetModel("models/haku/haku_mask.vmdl")
    self:GetCaster():SetOriginalModel("models/haku/haku_mask.vmdl")
end

LinkLuaModifier("modifier_haku_zerkala_parent", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_zerkala_radius", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_zerkala", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_zerkala_attack", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)

haku_zerkala = class({}) 

function haku_zerkala:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
	self.modifier = CreateModifierThinker( self:GetCaster(), self, "modifier_haku_zerkala_radius", {duration = duration}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false )
	self:GetCaster():EmitSound("HakuMirror")
end

function haku_zerkala:OnProjectileHit( hTarget, vLocation )
	local target = hTarget
	if target==nil then return end
	if self:GetCaster():IsAlive() then
		local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_haku_zerkala_attack", {} )
		self:GetCaster():PerformAttack( target, true, true, true, false, false, false, false )
		modifier:Destroy()
	end
end

modifier_haku_zerkala_attack = class({})

function modifier_haku_zerkala_attack:IsHidden()
	return true
end

function modifier_haku_zerkala_attack:IsPurgable()
	return false
end

function modifier_haku_zerkala_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,

	}

	return funcs
end

function modifier_haku_zerkala_attack:GetModifierDamageOutgoing_Percentage( params )
	if IsServer() then
		local dmg = self:GetAbility():GetSpecialValueFor( "damage" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_haku_7")
		local damage = (100 - dmg) * -1
		return damage
	end
end

modifier_haku_zerkala_parent = class({})

function modifier_haku_zerkala_parent:IsHidden()
    return true
end

function modifier_haku_zerkala_parent:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }

    return decFuncs
end

function modifier_haku_zerkala_parent:GetModifierInvisibilityLevel()
	return 1
end

function modifier_haku_zerkala_parent:GetVisualZDelta()
    return 150
end

function modifier_haku_zerkala_parent:CheckState()
    return {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
    }
end

function modifier_haku_zerkala_parent:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_haku_zerkala_parent:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_haku_zerkala_parent:GetAbsoluteNoDamagePhysical()
    return 1
end

modifier_haku_zerkala_radius = class({})
modifier_haku_zerkala = class({})

function modifier_haku_zerkala_radius:IsPurgable() return false end
function modifier_haku_zerkala_radius:IsHidden() return true end

function modifier_haku_zerkala:IsPurgable() return false end
function modifier_haku_zerkala:IsHidden() return true end

function modifier_haku_zerkala:OnCreated()
    self.mv = self:GetAbility():GetSpecialValueFor("slow_movespeed")
end

function modifier_haku_zerkala:DeclareFunctions()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then return end
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_haku_zerkala:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then return end
    return -100
end

function modifier_haku_zerkala:CheckState()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then return end
	return {
		[MODIFIER_STATE_MUTED] = true,
	}
end

function modifier_haku_zerkala_radius:OnCreated(kv)
	if not IsServer() then return end
	local caster = self:GetAbility():GetCaster()
	local pos = self:GetParent():GetAbsOrigin()
	local duration = self:GetDuration()-0.05
	local radius = 600
	self.attack_timer = 0
	self.zerkala = {}




	local origin = self:GetParent():GetOrigin()
	local angle = 0
	local vector = origin + Vector(600,0,0)
	local zero = Vector(0,0,0)
	local one = Vector(1,0,0)
	local count = 18
	local angle_diff = 360/count

	for i=0, 17 do
		local location = RotatePosition( origin, QAngle( 0, angle_diff*i, 0 ), vector )
		local facing = RotatePosition( zero, QAngle( 0, 200+angle_diff*i, 0 ), one )
        local zerkalo = CreateUnitByName( "npc_dota_zerkalo", location, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
        zerkalo:SetForwardVector( facing )
        zerkalo:FaceTowards(self:GetParent():GetAbsOrigin())
        zerkalo:AddNewModifier(self:GetCaster(), self, "modifier_haku_zerkala_parent", {})
        ResolveNPCPositions( location, 64.0 )
        table.insert(self.zerkala, zerkalo)
	end

	local entities = FindEntities(caster,pos,radius)


	if not self:GetParent():IsAlive() then return end
	for k,v in pairs(entities) do
		v:AddNewModifier(caster, self:GetAbility(), "modifier_haku_zerkala", {Duration=duration + 0.3})
	end
	self:StartIntervalThink(0.03)
end

function modifier_haku_zerkala_radius:OnRemoved()
	if IsServer() then
		for _,unit in pairs(self.zerkala) do
			if unit and not unit:IsNull() then
				unit:Destroy()
			end
		end
		UTIL_Remove( self:GetParent() )
	end
end

function modifier_haku_zerkala_radius:OnIntervalThink()
	if not IsServer() then return end
	local entities = FindEntities(self:GetAbility():GetCaster(),Vector(0,0,0),FIND_UNITS_EVERYWHERE)
	local buffer = 100
	local radius = 600
	local range_to_ignore = radius + 2000

	local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	for _,enemy in pairs(enemies) do
		if ( enemy:HasModifier("modifier_haku_zerkala") ) then
			if self.attack_timer >= 0.5 then
				local from_zerkalo = self.zerkala[RandomInt(1, #self.zerkala)]
				if from_zerkalo and not from_zerkalo:IsNull() then
					local info = {
						Target = enemy,
						Source = from_zerkalo,
						Ability = self:GetAbility(),	
						EffectName = "particles/haku_dagger.vpcf",
						iMoveSpeed = 1200,
						bReplaceExisting = false,
						bProvidesVision = true,
						iVisionRadius = 150,
						iVisionTeamNumber = self:GetCaster():GetTeamNumber()
					}
					ProjectileManager:CreateTrackingProjectile(info)
					break
				end
			end
		end
	end
	if self.attack_timer >= 0.5 then
		self.attack_timer = 0
	end
	self.attack_timer = self.attack_timer + 0.03
	local duration = self:GetRemainingTime()
	for k,v in pairs(entities) do
		if v:IsAlive() then
			if ( v:GetRangeToUnit(self:GetParent()) < ( radius ) ) then
				if ( v:GetCreationTime() >= GameRules:GetGameTime() - 0.3 ) then
					if v:HasModifier("modifier_Kudes_GoldHook_debuff") then return end
					--v:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_haku_zerkala", {Duration=duration})
				end

				if ( not v:HasModifier("modifier_haku_zerkala") ) then
					local vpos = v:GetAbsOrigin()
					local ppos = self:GetParent():GetAbsOrigin()
					local dir = ( vpos - ppos ):Normalized()
					local rdir = ( ppos - vpos ):Normalized()
					if v:HasModifier("modifier_Kudes_GoldHook_debuff") then return end
												FindClearSpaceForUnit(v,
						(dir*(radius+buffer))+self:GetParent():GetAbsOrigin(),
						true)
				end
			else
				if ( v:HasModifier("modifier_haku_zerkala") ) then
					local vpos = v:GetAbsOrigin()
					local ppos = self:GetParent():GetAbsOrigin()
					local dir = ( vpos - ppos ):Normalized()
					local rdir = ( ppos - vpos ):Normalized()
					if v:HasModifier("modifier_Kudes_GoldHook_debuff") then return end
												FindClearSpaceForUnit(v,
						(dir*(radius-buffer))+self:GetParent():GetAbsOrigin(),
						true)
				end
			end
		end
	end
end

LinkLuaModifier("modifier_haku_zerkalo_parent", "abilities/heroes/haku", LUA_MODIFIER_MOTION_NONE)

haku_zerkalo = class({}) 

function haku_zerkalo:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    if self:GetCaster():HasModifier("modifier_haku_zerkalo_parent") then
    	behavior = behavior + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
    end
    return behavior
end

function haku_zerkalo:GetCastRange(location, target)
	if self:GetCaster():FindAbilityByName("haku_zerkala") then
    	if self:GetCaster():HasModifier("modifier_haku_zerkalo_parent") then
        	return 9999999
        end
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function haku_zerkalo:OnAbilityPhaseStart()
    self.target = self:GetCursorTarget()
    if self.target:GetUnitName() == "npc_dota_zerkalo" then return true end
    return false
end

function haku_zerkalo:OnSpellStart()
    if not IsServer() then return end
    local modifier_ls = self:GetCaster():FindModifierByName("modifier_haku_zerkalo_parent")
	if self:GetCaster():HasModifier("modifier_haku_zerkalo_parent") then
	    if modifier_ls then
	    	ParticleManager:DestroyParticle(self.effect, true)
	    end
	    if self.target then
	    	if self.target == modifier_ls.target_ent then
	    		modifier_ls:Destroy()
	    	else
	    		modifier_ls.target_ent = self.target
    			self.effect = ParticleManager:CreateParticleForTeam(
				"particles/econ/courier/courier_trail_international_2014/courier_international_2014.vpcf",
				PATTACH_RENDERORIGIN_FOLLOW,
				self.target,
				self:GetCaster():GetTeamNumber()
				)

				ParticleManager:SetParticleControl( self.effect, 15, Vector( 35, 168, 192 ) )
				ParticleManager:SetParticleControl( self.effect, 16, Vector( 1, 0, 0 ) )
	    	end
	    end
	    return
	end
    if not self.target then
        return
    end
    local target = self.target
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_haku_zerkalo_parent", {target_ent = target:entindex()})
	self.effect = ParticleManager:CreateParticleForTeam(
	"particles/econ/courier/courier_trail_international_2014/courier_international_2014.vpcf",
	PATTACH_RENDERORIGIN_FOLLOW,
	target,
	self:GetCaster():GetTeamNumber()
	)

	ParticleManager:SetParticleControl( self.effect, 15, Vector( 35, 168, 192 ) )
	ParticleManager:SetParticleControl( self.effect, 16, Vector( 1, 0, 0 ) )
end

modifier_haku_zerkalo_parent = class({})

function modifier_haku_zerkalo_parent:IsPurgable() return false end

function modifier_haku_zerkalo_parent:OnCreated(params)
    if not IsServer() then return end
    self.target_ent = EntIndexToHScript(params.target_ent)
    self:GetParent():AddNoDraw()
    self:StartIntervalThink(FrameTime())
    self:GetCaster():FindAbilityByName("haku_needle"):SetHidden(true)
    self:GetCaster():FindAbilityByName("haku_speed"):SetHidden(true)
    self:GetCaster():FindAbilityByName("haku_best"):SetHidden(true)
    self:GetCaster():FindAbilityByName("haku_mask"):SetHidden(true)
    self:GetCaster():FindAbilityByName("haku_zerkala"):SetHidden(true)
end

function modifier_haku_zerkalo_parent:OnIntervalThink()
    if not IsServer() then return end
    if self.target_ent:IsNull() then self:Destroy() return end
    self:GetParent():SetAbsOrigin(self.target_ent:GetAbsOrigin())
end

function modifier_haku_zerkalo_parent:OnDestroy()
    if not IsServer() then return end
    self:GetParent():EmitSound("HakuQiut")
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
    self:GetParent():RemoveNoDraw()
    self:GetCaster():FindAbilityByName("haku_needle"):SetHidden(false)
    self:GetCaster():FindAbilityByName("haku_speed"):SetHidden(false)
    self:GetCaster():FindAbilityByName("haku_best"):SetHidden(false)
    self:GetCaster():FindAbilityByName("haku_mask"):SetHidden(false)
    self:GetCaster():FindAbilityByName("haku_zerkala"):SetHidden(false)
end

function modifier_haku_zerkalo_parent:CheckState(keys)
    if not IsServer() then return end
    return {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_MUTED] = true,
    }
end