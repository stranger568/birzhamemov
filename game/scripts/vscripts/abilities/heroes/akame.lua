LinkLuaModifier("modifier_Akame_slice", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_akame_slice_damage", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Akame_slice_debuff", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Akame_slice_shard", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

Akame_slice = class({})

function Akame_slice:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Akame_slice:GetCastRange(location, target)
    if IsClient() then
        return self:GetSpecialValueFor("range")
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function Akame_slice:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Akame_slice:GetIntrinsicModifierName()
    return "modifier_Akame_slice_shard"
end

function Akame_slice:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_akame_1" )
end


-- Shard -----------------------------------------------------------------
modifier_Akame_slice_shard = class({})

function modifier_Akame_slice_shard:IsHidden()
    return true
end

function modifier_Akame_slice_shard:IsPurgable()
    return false
end

function modifier_Akame_slice_shard:DestroyOnExpire()
    return false
end

function modifier_Akame_slice_shard:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_HERO_KILLED
    }
    return funcs
end

function modifier_Akame_slice_shard:OnHeroKilled( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if self:GetParent():IsIllusion() then return end
        if not self:GetParent():HasShard() then return end
        if self:GetAbility():GetMaxAbilityCharges(self:GetAbility():GetLevel()) > self:GetAbility():GetCurrentAbilityCharges() then
            self:GetAbility():SetCurrentAbilityCharges(self:GetAbility():GetCurrentAbilityCharges()+1)
        end
        if self:GetAbility():GetCurrentAbilityCharges() >= self:GetAbility():GetMaxAbilityCharges(self:GetAbility():GetLevel()) then
            self:GetAbility():RefreshCharges()
        end
    end
end
-----------------------------------------------------------------

function Akame_slice:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local direction = point - self:GetCaster():GetAbsOrigin()
    local length = direction:Length2D()
    direction.z = 0
    direction = direction:Normalized()
    local speed = self:GetSpecialValueFor("speed")
    local distance = math.min(length, self:GetSpecialValueFor("range"))

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Akame_slice", {duration = distance/speed})
    self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_generic_knockback_lua",
        {
            direction_x = direction.x,
            direction_y = direction.y,
            distance = distance,
            duration = distance/speed,
        }
    )

    self:GetCaster():EmitSound("Hero_Pangolier.TailThump.Cast")
end

modifier_Akame_slice = class({})
function modifier_Akame_slice:IsPurgable() return false end
function modifier_Akame_slice:IsHidden() return true end
function modifier_Akame_slice:IsAura() return true end
function modifier_Akame_slice:GetAuraDuration() return 0 end
function modifier_Akame_slice:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_Akame_slice:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_Akame_slice:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_Akame_slice:GetModifierAura() return "modifier_akame_slice_damage" end
function modifier_Akame_slice:GetAuraRadius() return 100 end
function modifier_Akame_slice:OnCreated()
    if not IsServer() then return end
    local base_damage = self:GetAbility():GetSpecialValueFor("base_damage")
    self.percent_damage = self:GetAbility():GetSpecialValueFor("damage")
    self.damage = base_damage
end

function modifier_Akame_slice:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	return funcs
end

function modifier_Akame_slice:GetModifierDamageOutgoing_Percentage( params )
	if IsServer() then
		return self.percent_damage
	end
end

function modifier_Akame_slice:GetModifierPreAttack_BonusDamage( params )
	if IsServer() then
		return self.damage * 100 / ( 100 + self.percent_damage )
	end
end

function modifier_Akame_slice:GetEffectName()
    return "particles/units/heroes/hero_phantom_lancer/phantomlancer_edge_boost.vpcf"
end

function modifier_Akame_slice:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():MoveToPositionAggressive(self:GetCaster():GetAbsOrigin())
end

modifier_akame_slice_damage = class({})
function modifier_akame_slice_damage:IsPurgable() return false end
function modifier_akame_slice_damage:IsHidden() return true end

function modifier_akame_slice_damage:OnCreated()
	if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()
	local duration = self:GetAbility():GetSpecialValueFor("duration")
    local hit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(hit_pfx, 0, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(hit_pfx, 1, parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(hit_pfx)
	self:GetParent():EmitSound("Hero_Juggernaut.OmniSlash.Damage")
    caster:PerformAttack(parent, true, true, true, true, false, false, true)
    if not parent:IsMagicImmune() then
        parent:AddNewModifier(caster, self:GetAbility(), "modifier_Akame_slice_debuff", { duration = duration })
    end
end

modifier_Akame_slice_debuff = class({})

function modifier_Akame_slice_debuff:IsPurgable()
    return true
end

function modifier_Akame_slice_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
    return funcs
end

function modifier_Akame_slice_debuff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor")
end

LinkLuaModifier( "modifier_akame_obraz_illusion", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_NONE)

Akame_Obraz = class({})

function Akame_Obraz:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_akame_2" )
end

function Akame_Obraz:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Akame_Obraz:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Akame_Obraz:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target) + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_2")
end

function Akame_Obraz:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_birzha_akame_4") then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
end

function Akame_Obraz:GetIntrinsicModifierName()
    return "modifier_Akame_Obraz_stack"
end

function Akame_Obraz:OnSpellStart()
    if not IsServer() then return end

    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local illusion_damage_in = self:GetSpecialValueFor("illusion_damage_in") - 100
    local illusion_damage = self:GetSpecialValueFor("illusion_damage") - 100

    if self:GetCaster():HasTalent("special_bonus_birzha_akame_4") and target == nil then
    	local point = self:GetCursorPosition()
		self:GetCaster():EmitSound("Hero_Antimage.Blink_in")

	    local particle = ParticleManager:CreateParticle("particles/items_fx/abyssal_blink_end.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())

	    local illusion = BirzhaCreateIllusion( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=illusion_damage,incoming_damage=illusion_damage_in}, 1, 1, true, true )  

	    for k, v in pairs(illusion) do
	        v:AddNewModifier(self:GetCaster(), self, "modifier_akame_obraz_illusion", {})
	    end 

	    self:GetCaster():SetAbsOrigin(point)
	    FindClearSpaceForUnit(self:GetCaster(), point, true)

	    local particle = ParticleManager:CreateParticle("particles/items_fx/abyssal_blink_end.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    	return
    end

    local victim_angle = target:GetAnglesAsVector()
    local victim_forward_vector = target:GetForwardVector()
    local victim_angle_rad = victim_angle.y*math.pi/180
    local victim_position = target:GetAbsOrigin()
    local attacker_new = Vector(victim_position.x - 100 * math.cos(victim_angle_rad), victim_position.y - 100 * math.sin(victim_angle_rad), 0)

    if target:TriggerSpellAbsorb( self ) then return end

    self:GetCaster():EmitSound("Hero_Antimage.Blink_in")

    local particle = ParticleManager:CreateParticle("particles/items_fx/abyssal_blink_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())

    local illusion = BirzhaCreateIllusion( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=illusion_damage,incoming_damage=illusion_damage_in}, 1, 1, true, true )        
    for k, v in pairs(illusion) do
        v:AddNewModifier(self:GetCaster(), self, "modifier_akame_obraz_illusion", {})
    end 

    self:GetCaster():SetAbsOrigin(attacker_new)
    FindClearSpaceForUnit(self:GetCaster(), attacker_new, true)
    self:GetCaster():SetForwardVector(victim_forward_vector)
    self:GetCaster():MoveToTargetToAttack(target)
end

modifier_akame_obraz_illusion = class({})

function modifier_akame_obraz_illusion:IsPurgable() return false end
function modifier_akame_obraz_illusion:IsHidden() return true end

function modifier_akame_obraz_illusion:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_akame_obraz_illusion:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
    	local damage = self:GetAbility():GetSpecialValueFor( "damage_one" )
    	ApplyDamage({ victim = target, attacker = self:GetParent(), ability=self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL })
        self:Destroy()
    end
end

LinkLuaModifier( "modifier_akame_attack_series", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_NONE )

akame_attack_series = class({})

function akame_attack_series:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_6")
end

function akame_attack_series:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function akame_attack_series:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function akame_attack_series:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then return end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_akame_attack_series', {target = target:entindex()})
end

modifier_akame_attack_series = class({})

function modifier_akame_attack_series:OnCreated(params)
	if not IsServer() then return end
	self.target = EntIndexToHScript(params.target)
	self.start_angle = self:GetParent():GetAngles()
	self.start_pos = self:GetParent():GetAbsOrigin()
	self.attack_count = self:GetAbility():GetSpecialValueFor("series_count")
	self:StartIntervalThink(0.2)
    self:OnIntervalThink()
end

function modifier_akame_attack_series:OnIntervalThink()
	if not IsServer() then return end
    if self.target:IsNull() then
        self:Destroy()
        return
    end
	if not self.target:IsAlive() then 
        self:Destroy() 
        return
    end
	if not self:GetCaster():CanEntityBeSeenByMyTeam(self.target) and self.target:IsInvisible() then 
        self:Destroy() 
        return
    end
	if self.attack_count == 0 then 
        self:Destroy()
        return
    end

    local pos = self.target:GetAbsOrigin() + RandomVector(100)
    local pos_start = self:GetCaster():GetAbsOrigin()
	self:GetParent():SetAbsOrigin(pos)
    local angle_vector = self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()
    self:GetParent():SetAngles(0, VectorToAngles(angle_vector).y, 0)
	self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 5)
    self:GetParent():PerformAttack(self.target, true, true, true, true, false, false, true)

    local particle = ParticleManager:CreateParticle( "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControl( particle, 0, pos )
    ParticleManager:SetParticleControl( particle, 1, pos_start )
    ParticleManager:ReleaseParticleIndex(particle)

	if self.attack_count == 1 then
		local agi_mult = self:GetAbility():GetSpecialValueFor("agi_mult")
    	local mult_damage = self:GetParent():GetAgility() * agi_mult 
		local damage = self:GetAbility():GetSpecialValueFor("last_attack_damage") + mult_damage
        ApplyDamage({ victim = self.target, attacker = self:GetParent(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION })
	end

    self.attack_count = self.attack_count - 1
end

function modifier_akame_attack_series:CheckState()
	return 
    {
		[MODIFIER_STATE_STUNNED]			= true,
		[MODIFIER_STATE_INVULNERABLE]		= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]	= true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end

function modifier_akame_attack_series:OnDestroy()
	if not IsServer() then return end
	--self:GetParent():SetAngles(self.start_angle.x, self.start_angle.y, self.start_angle.z)
    FindClearSpaceForUnit(self:GetParent(), self.start_pos, false)
end

Akame_jump = class({})

function Akame_jump:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Akame_jump:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Akame_jump:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_akame_3" )
end

function Akame_jump:OnSpellStart()
    if not IsServer() then return end
    
    local direction = self:GetForwardVector() * -1
    local leap_distance = self:GetSpecialValueFor( "leap_distance" )
	local leap_speed = self:GetSpecialValueFor( "leap_speed" )
	local point = self:GetCaster():GetAbsOrigin() + direction
    
    local knockback = self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_generic_knockback_lua",
        {
            direction_x = direction.x,
            direction_y = direction.y,
            distance = leap_distance,
            height = 100,	
            duration = leap_distance/leap_speed,
        }
    )

    ProjectileManager:ProjectileDodge(self:GetCaster())

    local callback = function( bInterrupted )
    	self:GetCaster():Stop()
    end

    if self:GetCaster():HasShard() then
    	self:GetCaster():Purge(false, true, false, false, false)
    end

    knockback:SetEndCallback( callback )
end

LinkLuaModifier("modifier_akame_cursed_blade", "abilities/heroes/akame", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cursed_blade_debuff", "abilities/heroes/akame", LUA_MODIFIER_MOTION_NONE)

Akame_cursed_blade = class({}) 

function Akame_cursed_blade:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_5")
end

function Akame_cursed_blade:GetCastRange(location, target)
    if IsClient() then
        return self:GetSpecialValueFor("range")
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function Akame_cursed_blade:GetIntrinsicModifierName()
    return "modifier_akame_cursed_blade"
end

function Akame_cursed_blade:OnSpellStart()
	if not IsServer() then return end

    local direction = self:GetCaster():GetForwardVector()

    self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, 3 )

	local ldirection = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized()

    if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
        ldirection = direction
    end

    self:GetCaster():EmitSound("Hero_Juggernaut.BladeDance")

    local index = DoUniqueString("index")
    self[index] = {}

	self:StartAttack(ldirection, index)
end

function Akame_cursed_blade:StartAttack(direction, index)
    if not IsServer() then return end
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/econ/items/magnataur/shock_of_the_anvil/magnataur_shockanvil.vpcf",
        vSpawnOrigin        = self:GetCaster():GetAbsOrigin(),
        fDistance           = self:GetSpecialValueFor("range"),
        fStartRadius        = 120,
        fEndRadius          = 120,
        Source              = self:GetCaster(),
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 3000,
        bProvidesVision     = false,
        ExtraData           = {index = index}
    }
    ProjectileManager:CreateLinearProjectile(projectile)
end

function RotateVector2DPudge(vector, theta)
    local xp = vector.x*math.cos(theta)-vector.y*math.sin(theta)
    local yp = vector.x*math.sin(theta)+vector.y*math.cos(theta)
    return Vector(xp,yp,vector.z):Normalized()
end

function ToRadians(degrees)
    return degrees * math.pi / 180
end

function CalculateDirection(ent1, ent2)
    local pos1 = ent1
    local pos2 = ent2
    if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
    if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
    local direction = (pos1 - pos2)
    direction.z = 0
    return direction:Normalized()
end

function Akame_cursed_blade:OnProjectileHit_ExtraData(target, vLocation, ExtraData)
    if not IsServer() then return end
    if target ~= nil then
    	local was_hit = false
        for _, stored_target in ipairs(self[ExtraData.index]) do
            if target == stored_target then
                was_hit = true
                break
            end
        end
        if was_hit then
            return nil
        end
        table.insert(self[ExtraData.index],target)
	    local agi_mult = self:GetSpecialValueFor("agility_attack")
	    local damage = (self:GetCaster():GetAgility() * agi_mult) + self:GetCaster():GetAverageTrueAttackDamage(nil)
	    ApplyDamage({ victim = target, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
	    self:GetCaster():PerformAttack(target, true, true, true, true, false, true, true)
	else
		self[ExtraData.index]["count"] = self[ExtraData.index]["count"] or 0
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] + 1
        if self[ExtraData.index]["count"] == ExtraData.card_count then
            self[ExtraData.index] = nil
        end
	end
end

modifier_akame_cursed_blade = class({}) 

function modifier_akame_cursed_blade:IsHidden()      return true end
function modifier_akame_cursed_blade:IsPurgable()    return false end

function modifier_akame_cursed_blade:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_akame_cursed_blade:OnAttackLanded( keys )
    if not IsServer() then return end
    local attacker = self:GetParent()
    if attacker ~= keys.attacker then return end
    if attacker:PassivesDisabled() or attacker:IsIllusion() then return end
    local target = keys.target
    if attacker:GetTeam() == target:GetTeam() then return end
    if target:IsBoss() then return end
    if target:IsWard() then return end
    local duration = self:GetAbility():GetSpecialValueFor('duration')
    target:AddNewModifier(attacker, self:GetAbility(), "modifier_cursed_blade_debuff", {duration = duration})
end

modifier_cursed_blade_debuff = class({})

function modifier_cursed_blade_debuff:IsPurgable()
    return true
end

function modifier_cursed_blade_debuff:OnCreated( kv )
	if not IsServer() then return end
	self.particle = ParticleManager:CreateParticle( "particles/akame/skill_stacks.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( self.particle, 1, Vector( 0, self:GetStackCount(), 0) )
    self:AddParticle(self.particle, false, false, -1, false, true)
	self:StartIntervalThink(0.5)			
end

function modifier_cursed_blade_debuff:DeclareFunctions()
	local decFuncs = 
    {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,

	}
	return decFuncs
end

function modifier_cursed_blade_debuff:OnIntervalThink()
	if not IsServer() then return end
    if self:GetParent():IsMagicImmune() then return end
	local damage_base = self:GetAbility():GetSpecialValueFor("damage")
	local damage = self:GetParent():GetMaxHealth() / 100 * damage_base
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage * 0.5, damage_type = DAMAGE_TYPE_PURE})
end

function modifier_cursed_blade_debuff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor('attack_speed')
end

function modifier_cursed_blade_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor('movespeed')
end

function modifier_cursed_blade_debuff:Custom_HealAmplifyReduce()
	if self:GetCaster():HasShard() then
		return self:GetAbility():GetSpecialValueFor('heal_ruin')
	end
	return 0
end

function modifier_cursed_blade_debuff:GetModifierHPRegenAmplify_Percentage()
	if self:GetCaster():HasShard() then
		return self:GetAbility():GetSpecialValueFor('heal_ruin')
	end
	return 0
end