LinkLuaModifier("modifier_Akame_slice", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_akame_slice_damage", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Akame_slice_debuff", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Akame_slice_stack", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Akame_slice = class({})

function Akame_slice:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Akame_slice:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Akame_slice:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Akame_slice:GetIntrinsicModifierName()
    return "modifier_Akame_slice_stack"
end

modifier_Akame_slice_stack = class({})

function modifier_Akame_slice_stack:IsHidden()
    return false
end

function modifier_Akame_slice_stack:IsPurgable()
    return false
end

function modifier_Akame_slice_stack:DestroyOnExpire()
    return false
end

function modifier_Akame_slice_stack:OnCreated( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_6")
    if not IsServer() then return end
    self:SetStackCount( self.max_charges )
    self:CalculateCharge()
end

function modifier_Akame_slice_stack:OnRefresh( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_6")
    if not IsServer() then return end
    self:CalculateCharge()
end

function modifier_Akame_slice_stack:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_EVENT_ON_HERO_KILLED
    }

    return funcs
end

function modifier_Akame_slice_stack:OnHeroKilled( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if self:GetParent():IsIllusion() then return end
        if not self:GetParent():HasScepter() then return end
        self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_6")
        if self:GetStackCount() < self.max_charges then
            self:IncrementStackCount()
        end
    end
end

function modifier_Akame_slice_stack:OnAbilityFullyCast( params )
    if not IsServer() then return end
    if params.unit==self:GetParent() and (params.ability:GetName() == "item_refresher" or params.ability:GetName() == "item_refresher_shard") then
        self:SetStackCount(self.max_charges)
        self:SetDuration( -1, true )
        self:StartIntervalThink( -1 )
        return
    end
    if params.unit~=self:GetParent() or params.ability~=self:GetAbility() then
        return
    end
    self:DecrementStackCount()
    self:CalculateCharge()
end

function modifier_Akame_slice_stack:OnIntervalThink()
    if self:GetStackCount() < self.max_charges then
        self:IncrementStackCount()
    end
    self:StartIntervalThink(-1)
    self:CalculateCharge()
end

function modifier_Akame_slice_stack:CalculateCharge()
    self:GetAbility():EndCooldown()
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_6")
    if self:GetStackCount()>=self.max_charges then
        self:SetDuration( -1, false )
        self:StartIntervalThink( -1 )
    else
        if self:GetRemainingTime() <= 0.05 then
            local charge_time = self:GetAbility():GetCooldown( -1 ) * self:GetParent():GetCooldownReduction()
            self:StartIntervalThink( charge_time )
            self:SetDuration( charge_time, true )
        end
        if self:GetStackCount()==0 then
            self:GetAbility():StartCooldown( self:GetRemainingTime() )
        end
    end
end

function Akame_slice:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Akame_slice", {
		duration	= (point - self:GetCaster():GetAbsOrigin()):Length2D() / 3000,
		x			= point.x,
		y 			= point.y,
		z			= point.z
	})
    self:GetCaster():EmitSound("Hero_Pangolier.TailThump.Cast")
    self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, 3 )
end

modifier_Akame_slice = class({})

function modifier_Akame_slice:IsPurgable() return false end
function modifier_Akame_slice:IsHidden() return true end

function modifier_Akame_slice:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_Akame_slice:IgnoreTenacity() return true end
function modifier_Akame_slice:IsMotionController() return true end
function modifier_Akame_slice:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_Akame_slice:IsAura() return true end

function modifier_Akame_slice:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_Akame_slice:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_Akame_slice:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_Akame_slice:GetModifierAura()
    return "modifier_akame_slice_damage"
end

function modifier_Akame_slice:GetAuraRadius()
    return 150
end

function modifier_Akame_slice:GetEffectName()
	return "particles/units/heroes/hero_faceless_void/faceless_void_time_walk.vpcf" end

function modifier_Akame_slice:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW end

function modifier_Akame_slice:CheckState()
	return {
		[MODIFIER_STATE_STUNNED]			= true,
		[MODIFIER_STATE_INVULNERABLE]		= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]	= true
	}
end

function modifier_Akame_slice:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }

    return funcs
end

function modifier_Akame_slice:GetModifierDamageOutgoing_Percentage()
	if IsServer() then
		local new_damage = 100 - self:GetAbility():GetSpecialValueFor("damage")
	    return -new_damage
	end
end

function modifier_Akame_slice:OnCreated(params)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local position = GetGroundPosition(Vector(params.x, params.y, params.z), nil)
		local max_distance = self:GetAbility():GetSpecialValueFor("range") + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_4")
		local distance = (caster:GetAbsOrigin() - position):Length2D()
		if distance > max_distance then distance = max_distance end
		self.velocity = 3000
		self.direction = (position - caster:GetAbsOrigin()):Normalized()
		self.distance_traveled = 0
		self.distance = distance
		self.frametime = FrameTime()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_Akame_slice:OnIntervalThink()
	if not self:CheckMotionControllers() then
        if not self:IsNull() then
            self:Destroy()
        end
		return nil
	end
	self:HorizontalMotion(self:GetParent(), self.frametime)
end

function modifier_Akame_slice:HorizontalMotion( me, dt )
	if IsServer() then
		if self.distance_traveled <= self.distance then
			self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self.direction * self.velocity * math.min(dt, self.distance - self.distance_traveled))
			self.distance_traveled = self.distance_traveled + self.velocity * math.min(dt, self.distance - self.distance_traveled)
		else
            if not self:IsNull() then
                self:Destroy()
            end
		end
	end
end

modifier_akame_slice_damage = class({})

function modifier_akame_slice_damage:IsPurgable() return false end
function modifier_akame_slice_damage:IsHidden() return true end

function modifier_akame_slice_damage:OnCreated()
	if IsServer() then
	local damage = self:GetAbility():GetSpecialValueFor("base_damage")
	local duration = self:GetAbility() :GetSpecialValueFor("duration")
    local hit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(hit_pfx, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(hit_pfx, 1, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(hit_pfx)
	    local damageTable = {victim = self:GetParent(),
	                        attacker = self:GetCaster(),
	                        damage = damage,
	                        ability = self:GetAbility(),
	                        damage_type = DAMAGE_TYPE_PHYSICAL,
	                        }
	    ApplyDamage(damageTable)
	    self:GetParent():EmitSound("Hero_Juggernaut.OmniSlash.Damage")
	    self:GetCaster():PerformAttack(self:GetParent(), true, true, true, true, false, false, true)
        if not self:GetParent():IsMagicImmune() then
	       self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Akame_slice_debuff", { duration = duration})
        end
	end
end

function modifier_Akame_slice:GetModifierProcAttack_BonusDamage_Physical( params )
    local agi_mult = self:GetAbility():GetSpecialValueFor("agi_mult")
    if not IsServer() then return end
    local damage = self:GetParent():GetAgility() * agi_mult
    return damage
end

modifier_Akame_slice_debuff = class({})

function modifier_Akame_slice_debuff:IsPurgable()
    return true
end

function modifier_Akame_slice_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

function modifier_Akame_slice_debuff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor")
end

LinkLuaModifier("modifier_akame_obraz_illusion", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_Akame_Obraz_stack" , "abilities/heroes/akame", LUA_MODIFIER_MOTION_NONE)

Akame_Obraz = class({})

function Akame_Obraz:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Akame_Obraz:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Akame_Obraz:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Akame_Obraz:GetIntrinsicModifierName()
    return "modifier_Akame_Obraz_stack"
end

modifier_Akame_Obraz_stack = class({})

function modifier_Akame_Obraz_stack:IsHidden()
    return false
end

function modifier_Akame_Obraz_stack:IsPurgable()
    return false
end

function modifier_Akame_Obraz_stack:DestroyOnExpire()
    return false
end

function modifier_Akame_Obraz_stack:OnCreated( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_8")
    if not IsServer() then return end
    self:SetStackCount( self.max_charges )
    self:CalculateCharge()
end

function modifier_Akame_Obraz_stack:OnRefresh( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_8")
    if not IsServer() then return end
    self:CalculateCharge()
end

function modifier_Akame_Obraz_stack:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }

    return funcs
end

function modifier_Akame_Obraz_stack:OnAbilityFullyCast( params )
    if not IsServer() then return end
    if params.unit==self:GetParent() and (params.ability:GetName() == "item_refresher" or params.ability:GetName() == "item_refresher_shard") then
        self:SetStackCount(self.max_charges)
        self:SetDuration( -1, true )
        self:StartIntervalThink( -1 )
        return
    end
    if params.unit~=self:GetParent() or params.ability~=self:GetAbility() then
        return
    end
    self:DecrementStackCount()
    self:CalculateCharge()
end

function modifier_Akame_Obraz_stack:OnIntervalThink()
    self:IncrementStackCount()
    self:StartIntervalThink(-1)
    self:CalculateCharge()
end

function modifier_Akame_Obraz_stack:CalculateCharge()
    self:GetAbility():EndCooldown()
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_8")
    if self:GetStackCount()>=self.max_charges then
        self:SetDuration( -1, false )
        self:StartIntervalThink( -1 )
    else
        if self:GetRemainingTime() <= 0.05 then
            local charge_time = self:GetAbility():GetCooldown( -1 ) * self:GetParent():GetCooldownReduction()
            self:StartIntervalThink( charge_time )
            self:SetDuration( charge_time, true )
        end
        if self:GetStackCount()==0 then
            self:GetAbility():StartCooldown( self:GetRemainingTime() )
        end
    end
end

function Akame_Obraz:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local point = self:GetCursorPosition()

    if target then
        local victim_angle = target:GetAnglesAsVector()
        local victim_forward_vector = target:GetForwardVector()
        local victim_angle_rad = victim_angle.y*math.pi/180
        local victim_position = target:GetAbsOrigin()
        local attacker_new = Vector(victim_position.x - 100 * math.cos(victim_angle_rad), victim_position.y - 100 * math.sin(victim_angle_rad), 0)
        local duration = self:GetSpecialValueFor("duration")
        local illusion_damage_in = self:GetSpecialValueFor("illusion_damage_in")
        local illusion_damage = self:GetSpecialValueFor("illusion_damage")
        if target:TriggerSpellAbsorb( self ) then return end
        self:GetCaster():EmitSound("Hero_Antimage.Blink_in")
        local particle = ParticleManager:CreateParticle("particles/items_fx/abyssal_blink_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
        if self:GetCaster():HasScepter() then
            illusion_damage_in = 0
            illusion_damage = 0
        end
        local illusion_c = 1
        if self:GetCaster():HasTalent("special_bonus_birzha_akame_7") then
            illusion_c = 2
        end
        local illusion = CreateIllusions( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=illusion_damage,incoming_damage=illusion_damage_in}, illusion_c, 1, true, true )        
        for k, v in pairs(illusion) do
            v:AddNewModifier(self:GetCaster(), self, "modifier_akame_obraz_illusion", {})
        end 
        self:GetCaster():SetAbsOrigin(attacker_new)
        FindClearSpaceForUnit(self:GetCaster(), attacker_new, true)
        self:GetCaster():SetForwardVector(victim_forward_vector)
        self:GetCaster():MoveToTargetToAttack(target)
        if self:GetCaster():HasTalent("special_bonus_birzha_akame_5") then
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invisible", {duration=1})
        end
        return
    end

    local duration = self:GetSpecialValueFor("duration")
    local illusion_damage_in = self:GetSpecialValueFor("illusion_damage_in")
    local illusion_damage = self:GetSpecialValueFor("illusion_damage") 
    self:GetCaster():EmitSound("Hero_Antimage.Blink_in")  
    local particle = ParticleManager:CreateParticle("particles/items_fx/abyssal_blink_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    if self:GetCaster():HasScepter() then
        illusion_damage_in = 0
        illusion_damage = 0
    end
    local illusion_c = 1
    if self:GetCaster():HasTalent("special_bonus_birzha_akame_7") then
        illusion_c = 2
    end
    local illusion = CreateIllusions( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=illusion_damage,incoming_damage=illusion_damage_in}, illusion_c, 1, true, true )        
    for k, v in pairs(illusion) do
        v:AddNewModifier(self:GetCaster(), self, "modifier_akame_obraz_illusion", {})
    end 
    FindClearSpaceForUnit(self:GetCaster(), point, true)
    if self:GetCaster():HasTalent("special_bonus_birzha_akame_5") then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invisible", {duration=1})
    end
end

modifier_akame_obraz_illusion = class({})

function modifier_akame_obraz_illusion:IsPurgable() return false end
function modifier_akame_obraz_illusion:IsHidden() return true end

function modifier_akame_obraz_illusion:DeclareFunctions()
    local funcs = {
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
    	local damage_persentage = self:GetAbility():GetSpecialValueFor( "damage_one_persentage" ) / 100 * self:GetCaster():GetAverageTrueAttackDamage(nil)
    	local base_damage = self:GetAbility():GetSpecialValueFor( "damage_one" )
    	local damage = base_damage + damage_persentage
    	ApplyDamage({ victim = target, attacker = self:GetParent(), ability=self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL })
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

LinkLuaModifier( "modifier_akame_attack_series", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_akame_attack_series_passive", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_akame_attack_series_passive_haste", "abilities/heroes/akame.lua", LUA_MODIFIER_MOTION_NONE )

akame_attack_series = class({})

function akame_attack_series:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function akame_attack_series:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function akame_attack_series:GetManaCost(level)
	if self:GetCaster():HasTalent("special_bonus_birzha_akame_1") then
		return 0
	end
    return self.BaseClass.GetManaCost(self, level)
end

function akame_attack_series:OnSpellStart()
	if not IsServer() then return end
	self.target = self:GetCursorTarget()
	if not self:GetCaster():HasTalent("special_bonus_birzha_akame_2") then
		if self.target:TriggerSpellAbsorb( self ) then return end
	end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_akame_attack_series', {})
end

function akame_attack_series:GetIntrinsicModifierName() 
	return "modifier_akame_attack_series_passive"
end

modifier_akame_attack_series_passive = class({})

function modifier_akame_attack_series_passive:IsHidden()
	return true
end

function modifier_akame_attack_series_passive:IsPurgable()
	return false
end

function modifier_akame_attack_series_passive:DeclareFunctions()
return 	{
			MODIFIER_EVENT_ON_ATTACK_LANDED,
		}
end

function modifier_akame_attack_series_passive:OnAttackLanded( keys )
	if IsServer() then
		local attacker = self:GetParent()

		if attacker ~= keys.attacker then
			return
		end

		if attacker:IsIllusion() then
			return
		end

		if attacker:PassivesDisabled() then
			return
		end

		local target = keys.target
		if attacker:GetTeam() == target:GetTeam() then
			return
		end	

		local chance = self:GetAbility():GetSpecialValueFor("chance")
		if chance >= RandomInt(1, 100) then
			attacker:AddNewModifier(attacker, self:GetAbility(), "modifier_akame_attack_series_passive_haste", {})
		end
	end
end

modifier_akame_attack_series_passive_haste = class({})

function modifier_akame_attack_series_passive_haste:IsHidden()
 	return true
end

function modifier_akame_attack_series_passive_haste:IsPurgable()
	return false
end

function modifier_akame_attack_series_passive_haste:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_EVENT_ON_ATTACK
		}
	return decFuns
end

function modifier_akame_attack_series_passive_haste:OnAttack(keys)
	if self:GetParent() == keys.attacker then
        if not self:IsNull() then
            self:Destroy()
        end
	end
end

function modifier_akame_attack_series_passive_haste:GetModifierAttackSpeedBonus_Constant()
	return 999999
end

modifier_akame_attack_series = class({})

function modifier_akame_attack_series:OnCreated()
	if not IsServer() then return end
	self.target = self:GetAbility().target
	self.start_angle = self:GetParent():GetAngles()
	self.start_pos = self:GetParent():GetAbsOrigin()
	self.attack_count = self:GetAbility():GetSpecialValueFor('series_count') + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_3")
	self:StartIntervalThink(0.1)
end

function modifier_akame_attack_series:OnIntervalThink()
	if not IsServer() then return end
	if not self.target:IsAlive() then
        if not self:IsNull() then
            self:Destroy()
        end
    end
	if not self:GetCaster():CanEntityBeSeenByMyTeam(self.target) then
        if not self:IsNull() then
            self:Destroy()
        end
    end
	if self.attack_count == 0 then
        if not self:IsNull() then
            self:Destroy()
        end
    end
	if self.attack_count == 1 then
		local agi_mult = self:GetAbility():GetSpecialValueFor("agi_mult")
    	local mult_damage = self:GetParent():GetAgility() * agi_mult 
		local last_damage = self:GetAbility():GetSpecialValueFor("last_attack_damage") + mult_damage
		ApplyDamage({ victim = self.target, attacker = self:GetParent(), ability = self:GetAbility(), damage = last_damage, damage_type = DAMAGE_TYPE_PHYSICAL })
	end
	local pos = self.target:GetAbsOrigin() + RandomVector(100)
	self:GetParent():SetAbsOrigin(pos)
	local angle_vector = self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()
	self:GetParent():SetAngles(0, VectorToAngles(angle_vector).y, 0)
	self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 3)
	self:GetParent():EmitSound('Hero_NagaSiren.Attack')
	local sliceFX = ParticleManager:CreateParticle("particles/econ/items/juggernaut/bladekeeper_omnislash/dc_juggernaut_omni_slash_rope.vpcf", PATTACH_ABSORIGIN  , self:GetParent())
	ParticleManager:SetParticleControl(sliceFX, 0, pos)
	ParticleManager:SetParticleControl(sliceFX, 2, pos)
	ParticleManager:SetParticleControl(sliceFX, 3, self:GetParent():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(sliceFX)
	local crit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/jugg_crit_blur.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(crit_pfx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(crit_pfx)
	self:GetParent():PerformAttack(self.target, true, true, true, true, false, false, true)
	self.attack_count = self.attack_count - 1
end

function modifier_akame_attack_series:CheckState()
	return {
		[MODIFIER_STATE_STUNNED]			= true,
		[MODIFIER_STATE_INVULNERABLE]		= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]	= true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,

	}
end

function  modifier_akame_attack_series:OnDestroy()
	if not IsServer() then return end
	self:GetParent():SetAbsOrigin(self.start_pos)
	self:GetParent():SetAngles(self.start_angle.x, self.start_angle.y, self.start_angle.z)
end

LinkLuaModifier("modifier_akame_demon", "abilities/heroes/akame", LUA_MODIFIER_MOTION_NONE)

Akame_Demon = class({}) 

function Akame_Demon:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Akame_Demon:GetIntrinsicModifierName()
    return "modifier_akame_demon"
end

modifier_akame_demon = class ({})

function modifier_akame_demon:IsPurgable() return true end
function modifier_akame_demon:IsHidden() return true end

function modifier_akame_demon:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_akame_demon:OnAttackLanded( keys )
    if not IsServer() then return end
    if keys.target == self:GetParent() then
	   	if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
	    if self:GetAbility():IsFullyCastable() then
	    	if self:GetParent():IsAlive() then
			    if self:GetCaster():HasTalent("special_bonus_birzha_akame_1") then
			        self:GetAbility():UseResources(false,false,true)
			        self:GetParent():PerformAttack(keys.attacker, true, true, true, true, false, false, true)
			        keys.attacker:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_disarmed", {duration = 1})
			        self:GetParent():SetHealth(self:GetParent():GetHealth() + keys.damage )
			        return
			   	end
			    if keys.attacker:GetAttackCapability() == 1 then
			        self:GetAbility():UseResources(false,false,true)
			        self:GetParent():PerformAttack(keys.attacker, true, true, true, true, false, false, true)
			        keys.attacker:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_disarmed", {duration = 1})
			        self:GetParent():SetHealth(self:GetParent():GetHealth() + keys.damage )
			    end
			end
	    end
    end
end



LinkLuaModifier("modifier_akame_cursed_blade", "abilities/heroes/akame", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cursed_blade_debuff", "abilities/heroes/akame", LUA_MODIFIER_MOTION_NONE)

Akame_cursed_blade = class({}) 

function Akame_cursed_blade:GetIntrinsicModifierName()
    return "modifier_akame_cursed_blade"
end

function Akame_cursed_blade:OnSpellStart()
	if not IsServer() then return end
    local direction = self:GetCaster():GetForwardVector()
    local startPos = self:GetCaster():GetAbsOrigin() + direction * 25
    local endPos = self:GetCaster():GetAbsOrigin() + direction * self:GetSpecialValueFor("range")
    local agi_mult = self:GetSpecialValueFor("agility_attack")
    local units = FindUnitsInLine(self:GetCaster():GetTeam(), startPos, endPos, nil, 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE)
    self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, 3 )
	local ldirection = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized()
    self:GetCaster():EmitSound("Hero_Juggernaut.BladeDance")
	local projectile =
	{
		Ability				= self,
		EffectName			= "particles/econ/items/magnataur/shock_of_the_anvil/magnataur_shockanvil.vpcf",
		vSpawnOrigin		= self:GetCaster():GetAbsOrigin(),
		fDistance			= self:GetSpecialValueFor("range")+125,
		fStartRadius		= 150,
		fEndRadius			= 150,
		Source				= self:GetCaster(),
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime 		= GameRules:GetGameTime() + 5.0,
		bDeleteOnHit		= false,
		vVelocity			= Vector(ldirection.x,ldirection.y,0) * 3000,
		bProvidesVision		= false,
	}
	ProjectileManager:CreateLinearProjectile(projectile)
    for _,unit in ipairs(units) do
    	local damage = (self:GetCaster():GetAgility() * agi_mult)
        ApplyDamage({ victim = unit, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
        self:GetCaster():PerformAttack(unit, true, true, true, true, false, false, true)
    end
    self:StartCooldown(self:GetSpecialValueFor("cooldown"))
end

modifier_akame_cursed_blade = class({}) 

function modifier_akame_cursed_blade:IsHidden()      return true end
function modifier_akame_cursed_blade:IsPurgable()    return false end

function modifier_akame_cursed_blade:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_akame_cursed_blade:OnAttackLanded( keys )
    if not IsServer() then return end
    local attacker = self:GetParent()
    if attacker ~= keys.attacker then
        return
    end
    if attacker:PassivesDisabled() or attacker:IsIllusion() then
        return
    end
    local target = keys.target
    if attacker:GetTeam() == target:GetTeam() then
        return
    end 
    if target:IsOther() then
		return nil
	end
    if target:IsBoss() then return end
    local duration = self:GetAbility():GetSpecialValueFor('duration')
    local damage_perc = self:GetAbility():GetSpecialValueFor('damage_perc')   
    local attack_count = self:GetAbility():GetSpecialValueFor('attack_count')
    local modifier = target:FindModifierByNameAndCaster("modifier_cursed_blade_debuff", self:GetAbility():GetCaster())
    if modifier == nil then
    	target:AddNewModifier(attacker, self:GetAbility(), "modifier_cursed_blade_debuff", {duration = duration})
    else
    	if modifier:GetStackCount() >= attack_count then
	    	local damageTable = {victim = target,
            attacker = attacker,
            damage = target:GetMaxHealth() / 100 * damage_perc,
            ability = self:GetAbility(),
            damage_type = DAMAGE_TYPE_PURE,
            }
    		ApplyDamage(damageTable)
            if modifier and not modifier:IsNull() then
    		    modifier:Destroy()
            end
    	else
    		target:AddNewModifier(attacker, self:GetAbility(), "modifier_cursed_blade_debuff", {duration = duration})
            if modifier then
        	   modifier:IncrementStackCount()
            end
        	ParticleManager:SetParticleControl( modifier.particle, 1, Vector( 0, modifier:GetStackCount(), 0) )
        end
    end
end

modifier_cursed_blade_debuff = class({})

function modifier_cursed_blade_debuff:IsPurgable()
    return true
end

function modifier_cursed_blade_debuff:OnCreated( kv )
	if not IsServer() then return end
    self:SetStackCount(1)
	self.particle = ParticleManager:CreateParticle( "particles/akame/skill_stacks.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( self.particle, 1, Vector( 0, self:GetStackCount(), 0) )
	self:StartIntervalThink(1)			
end

function modifier_cursed_blade_debuff:OnDestroy( kv )
    if not IsServer() then return end
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex( self.particle )
    end
end

function modifier_cursed_blade_debuff:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return decFuncs
end

function modifier_cursed_blade_debuff:OnIntervalThink()
	if not IsServer() then return end
	local damage_base = self:GetAbility():GetSpecialValueFor("damage")
	local damage = self:GetParent():GetMaxHealth() / 100 * damage_base
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
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

LinkLuaModifier( "modifier_Akame_jump" , "abilities/heroes/akame", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Akame_jump_stack" , "abilities/heroes/akame", LUA_MODIFIER_MOTION_NONE)

Akame_jump = class({})

function Akame_jump:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Akame_jump:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Akame_jump:GetIntrinsicModifierName()
    return "modifier_Akame_jump_stack"
end

modifier_Akame_jump_stack = class({})

function modifier_Akame_jump_stack:IsHidden()
    return false
end

function modifier_Akame_jump_stack:IsPurgable()
    return false
end

function modifier_Akame_jump_stack:DestroyOnExpire()
    return false
end

function modifier_Akame_jump_stack:OnCreated( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_6") + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_8")
    if not IsServer() then return end
    self:SetStackCount( self.max_charges )
    self:CalculateCharge()
end

function modifier_Akame_jump_stack:OnRefresh( kv )
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_6") + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_8")
    if not IsServer() then return end
    self:CalculateCharge()
end

function modifier_Akame_jump_stack:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }

    return funcs
end

function modifier_Akame_jump_stack:OnAbilityFullyCast( params )
    if not IsServer() then return end
    if params.unit==self:GetParent() and (params.ability:GetName() == "item_refresher" or params.ability:GetName() == "item_refresher_shard") then
        self:SetStackCount(self.max_charges)
        self:SetDuration( -1, true )
        self:StartIntervalThink( -1 )
        return
    end
    if params.unit~=self:GetParent() or params.ability~=self:GetAbility() then
        return
    end
    self:DecrementStackCount()
    self:CalculateCharge()
end

function modifier_Akame_jump_stack:OnIntervalThink()
    self:IncrementStackCount()
    self:StartIntervalThink(-1)
    self:CalculateCharge()
end

function modifier_Akame_jump_stack:CalculateCharge()
    self:GetAbility():EndCooldown()
    self.max_charges = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_6") + self:GetCaster():FindTalentValue("special_bonus_birzha_akame_8")
    if self:GetStackCount()>=self.max_charges then
        self:SetDuration( -1, false )
        self:StartIntervalThink( -1 )
    else
        if self:GetRemainingTime() <= 0.05 then
            local charge_time = self:GetAbility():GetCooldown( -1 ) * self:GetParent():GetCooldownReduction()
            self:StartIntervalThink( charge_time )
            self:SetDuration( charge_time, true )
        end
        if self:GetStackCount()==0 then
            self:GetAbility():StartCooldown( self:GetRemainingTime() )
        end
    end
end

function Akame_jump:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local direction = (point - self:GetCaster():GetAbsOrigin())
    direction.z = 0
    direction = direction:Normalized() * -1
    self:GetCaster():SetForwardVector(direction)
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_Akame_jump", {} )
end

modifier_Akame_jump = class({})

function modifier_Akame_jump:IsHidden()
    return true
end

function modifier_Akame_jump:IsPurgable()
    return false
end

function modifier_Akame_jump:OnCreated( kv )
    if IsServer() then
    	ProjectileManager:ProjectileDodge(self:GetParent())
        self.distance = self:GetAbility():GetSpecialValueFor( "leap_distance" )
        self.speed = self:GetAbility():GetSpecialValueFor( "leap_speed" )
        self.origin = self:GetParent():GetOrigin()
        self.duration = self.distance/self.speed
        self.hVelocity = self.speed
        self.direction = self:GetParent():GetForwardVector()
        self.peak = 200
        self.elapsedTime = 0
        self.motionTick = {}
        self.motionTick[0] = 0
        self.motionTick[1] = 0
        self.motionTick[2] = 0
        self.gravity = -self.peak/(self.duration*self.duration*0.125)
        self.vVelocity = (-0.5)*self.gravity*self.duration
        self:GetAbility():SetActivated( false )
        if self:ApplyVerticalMotionController() == false then 
            if not self:IsNull() then
                self:Destroy()
            end
        end
        if self:ApplyHorizontalMotionController() == false then 
            if not self:IsNull() then
                self:Destroy()
            end
        end
    end
end

function modifier_Akame_jump:OnDestroy( kv )
    if IsServer() then
        self:GetAbility():SetActivated( true )
        self:GetParent():InterruptMotionControllers( true )
    end
end

function modifier_Akame_jump:SyncTime( iDir, dt )
    if self.motionTick[1]==self.motionTick[2] then
        self.motionTick[0] = self.motionTick[0] + 1
        self.elapsedTime = self.elapsedTime + dt
    end
    self.motionTick[iDir] = self.motionTick[0]
    if self.elapsedTime > self.duration and self.motionTick[1]==self.motionTick[2] then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_Akame_jump:UpdateHorizontalMotion( me, dt )
    self:SyncTime(1, dt)
    local parent = self:GetParent()
    local target = self.direction*self.hVelocity*self.elapsedTime
    parent:SetOrigin( self.origin - target )
end

function modifier_Akame_jump:OnHorizontalMotionInterrupted()
    if IsServer() then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_Akame_jump:UpdateVerticalMotion( me, dt )
    self:SyncTime(2, dt)
    local parent = self:GetParent()
    local target = self.vVelocity*self.elapsedTime + 0.5*self.gravity*self.elapsedTime*self.elapsedTime
    parent:SetOrigin( Vector( parent:GetOrigin().x, parent:GetOrigin().y, self.origin.z+target ) )
end

function modifier_Akame_jump:OnVerticalMotionInterrupted()
    if IsServer() then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end
