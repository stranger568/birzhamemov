LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rat_courier_infection_debuff", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_rat_courier_infection_unit", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)

rat_courier_infection = class({})

function rat_courier_infection:GetCooldown(iLevel)
    if self:GetCaster():HasShard() then
        return self.BaseClass.GetCooldown( self, iLevel ) - self:GetSpecialValueFor("shard_cooldown")
    end
    return self.BaseClass.GetCooldown( self, iLevel )
end

function rat_courier_infection:OnSpellStart()
    if not IsServer() then return end

    if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
        self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
    end

    self:GetCaster():EmitSound("Hero_Weaver.Swarm.Cast")

    local start_pos         = nil
    local rat_thinker      = nil
    local projectile_table  = nil
    local projectileID      = nil
    
    for beetles = 1, 12 do
        start_pos = self:GetCaster():GetAbsOrigin() + RandomVector(RandomInt(0, 300))
        rat_thinker = CreateModifierThinker(self:GetCaster(), self, nil, {}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
        projectile_table = {
            Ability             = self,
            EffectName          = "particles/rat/courier_infection_proj.vpcf",
            vSpawnOrigin        = start_pos,
            fDistance           = self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus(),
            fStartRadius        = 100,
            fEndRadius          = 100,
            Source              = self:GetCaster(),
            bHasFrontalCone     = false,
            bReplaceExisting    = false,
            iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_NO_INVIS,
            iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime         = GameRules:GetGameTime() + 10.0,
            bDeleteOnHit        = false,
            vVelocity           = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * 950 * Vector(1, 1, 0),
            bProvidesVision     = true,
            iVisionRadius       = 100,
            iVisionTeamNumber   = self:GetCaster():GetTeamNumber(),
            ExtraData           =  { rat_thinker_ent = rat_thinker:entindex() }
        }
        projectileID = ProjectileManager:CreateLinearProjectile(projectile_table)
        rat_thinker.projectileID = projectileID
    end
end

function rat_courier_infection:OnProjectileThink_ExtraData(location, data)
    if data.rat_thinker_ent and EntIndexToHScript(data.rat_thinker_ent) and not EntIndexToHScript(data.rat_thinker_ent):IsNull() then
        EntIndexToHScript(data.rat_thinker_ent):SetAbsOrigin(location)
    end
end

function rat_courier_infection:OnProjectileHit_ExtraData(target, location, data)
    if target and (not target:HasModifier("modifier_rat_courier_infection_debuff") or (self:GetCaster():HasTalent("special_bonus_birzha_rat_5") and #target:FindAllModifiersByName("modifier_rat_courier_infection_debuff") < 4)) and data.rat_thinker_ent and EntIndexToHScript(data.rat_thinker_ent) and not EntIndexToHScript(data.rat_thinker_ent):IsNull() then
        target:EmitSound("Hero_Weaver.SwarmAttach")
        
        local mini_rat = CreateUnitByName("npc_dota_rat_ratik", target:GetAbsOrigin() + target:GetForwardVector() * 64, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
        
        mini_rat:AddNewModifier(self:GetCaster(), self, "modifier_rat_courier_infection_unit", { destroy_attacks = self:GetSpecialValueFor("destroy_attack") + self:GetCaster():FindTalentValue("special_bonus_birzha_rat_3"), target_entindex = target:entindex() })
        mini_rat:SetForwardVector((target:GetAbsOrigin() - mini_rat:GetAbsOrigin()):Normalized())
        target:AddNewModifier(self:GetCaster(), self, "modifier_rat_courier_infection_debuff", { duration = self:GetSpecialValueFor("duration"), damage = self:GetSpecialValueFor("damage"), attack_rate = self:GetSpecialValueFor("attack_interval"), damage_type = self:GetAbilityDamageType(), mini_rat_entindex = mini_rat:entindex()})

        if data.rat_thinker_ent and EntIndexToHScript(data.rat_thinker_ent) and EntIndexToHScript(data.rat_thinker_ent).projectileID then
            ProjectileManager:DestroyLinearProjectile(EntIndexToHScript(data.rat_thinker_ent).projectileID)
            EntIndexToHScript(data.rat_thinker_ent):RemoveSelf()
        end

    elseif not target and data.rat_thinker_ent and EntIndexToHScript(data.rat_thinker_ent) and not EntIndexToHScript(data.rat_thinker_ent):IsNull() then
        EntIndexToHScript(data.rat_thinker_ent):RemoveSelf()
    end
end

modifier_rat_courier_infection_unit = class({})

function modifier_rat_courier_infection_unit:IsHidden()     return true end
function modifier_rat_courier_infection_unit:IsPurgable()   return false end

function modifier_rat_courier_infection_unit:GetEffectName()
    return "particles/units/heroes/hero_weaver/weaver_swarm_debuff.vpcf"
end

function modifier_rat_courier_infection_unit:OnCreated(params)
    if not IsServer() then return end

    self.destroy_attacks            = params.destroy_attacks

    if self:GetCaster():HasShard() then
        self.destroy_attacks = self.destroy_attacks + self:GetAbility():GetSpecialValueFor("shard_bonus_attack")
    end
    self:GetParent():SetBaseMaxHealth(self.destroy_attacks)
    self.target                     = EntIndexToHScript(params.target_entindex)
    self.hero_attack_multiplier     = 2
    self.health_increments      = 1
    self:StartIntervalThink(FrameTime())
end

function modifier_rat_courier_infection_unit:OnIntervalThink()
    if self.target and not self.target:IsNull() then
        if (self.target:IsInvisible() and not self:GetParent():CanEntityBeSeenByMyTeam(self.target)) then
            self:GetParent():ForceKill(false)
            if not self:IsNull() then
                self:Destroy()
            end
        elseif self.target:IsAlive() then
            self:GetParent():SetAbsOrigin(self.target:GetAbsOrigin() + self.target:GetForwardVector() * 64)
            self:GetParent():SetForwardVector((self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized())
        end
    end
end

function modifier_rat_courier_infection_unit:OnDestroy()
    if not IsServer() then return end
    if self.target and not self.target:IsNull() and self.target:HasModifier("modifier_rat_courier_infection_debuff") then
        self.target:RemoveModifierByName("modifier_rat_courier_infection_debuff")
    end
end

function modifier_rat_courier_infection_unit:CheckState()
    return
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_MAGIC_IMMUNE]       = true,
    }
end

function modifier_rat_courier_infection_unit:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS
    }
    return decFuncs
end

function modifier_rat_courier_infection_unit:GetOverrideAnimation()
    return ACT_DOTA_IDLE
end

function modifier_rat_courier_infection_unit:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_rat_courier_infection_unit:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_rat_courier_infection_unit:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_rat_courier_infection_unit:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_rat_courier_infection_unit:OnAttacked(keys)
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        local new_health = self:GetParent():GetHealth() - self.health_increments
        if new_health <= 0 then
            self:GetParent():Kill(nil, keys.attacker)
            if not self:IsNull() then
                self:Destroy()
            end
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

modifier_rat_courier_infection_debuff = class({})

function modifier_rat_courier_infection_debuff:IgnoreTenacity() return false end
function modifier_rat_courier_infection_debuff:IsPurgable()     return false end

function modifier_rat_courier_infection_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_rat_courier_infection_debuff:GetEffectName()
    return "particles/units/heroes/hero_weaver/weaver_swarm_infected_debuff.vpcf"
end

function modifier_rat_courier_infection_debuff:OnCreated(params)
    if not IsServer() then return end
    self.damage         = params.damage
    self.attack_rate    = params.attack_rate
    self.damage_type    = params.damage_type
    self.mini_rat         = EntIndexToHScript(params.mini_rat_entindex)
    self.damage_table   = 
    {
        victim          = self:GetParent(),
        damage          = self.damage,
        damage_type     = self.damage_type,
        damage_flags    = DOTA_DAMAGE_FLAG_NONE,
        attacker        = self:GetCaster(),
        ability         = self:GetAbility()
    }
    self:OnIntervalThink()
    self:StartIntervalThink(self.attack_rate)
end

function modifier_rat_courier_infection_debuff:OnIntervalThink()
    AddNewStack(1, self:GetParent(), self:GetCaster())
    if self.mini_rat and not self.mini_rat:IsNull() and self.mini_rat:IsAlive() then
        self.mini_rat:StartGesture(ACT_DOTA_ATTACK)
    end
    ApplyDamage(self.damage_table)
end

function modifier_rat_courier_infection_debuff:OnDestroy()
    if not IsServer() then return end
    if self.mini_rat and not self.mini_rat:IsNull() and self.mini_rat:IsAlive() then
        self.mini_rat:ForceKill(false)
    end
end

LinkLuaModifier( "modifier_rat_burrow_cast", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_rat_burrow", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_rat_burrow_destroy", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_rat_burrow_debuff", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_rat_burrow_attackspeed_debuff", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_rat_burrow_attackspeed_buff", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)

rat_burrow = class({})

function rat_burrow:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function rat_burrow:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rat_burrow_cast", {duration = 0.5})
end

modifier_rat_burrow_cast = class({})

function modifier_rat_burrow_cast:IsPurgable() return false end
function modifier_rat_burrow_cast:IsHidden() return true end

function modifier_rat_burrow_cast:OnCreated()
    if not IsServer() then return end
    self.targets = {}
    self:StartIntervalThink(FrameTime())
    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 2)
    self:GetParent():EmitSound("rat_burrow_in")
end

function modifier_rat_burrow_cast:OnIntervalThink()
    if not IsServer() then return end
    local abs = self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * (150 * FrameTime())
    abs.z = abs.z - (300 * FrameTime())
    self:GetParent():SetAbsOrigin(abs)
end

function modifier_rat_burrow_cast:CheckState()
    return 
    {
        [MODIFIER_STATE_STUNNED]            = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }
end

function modifier_rat_burrow_cast:OnDestroy()
    if not IsServer() then return end
    local abs = self:GetParent():GetAbsOrigin()
    self:GetParent():SetAbsOrigin(GetGroundPosition(abs, self:GetParent()))
    local duration = self:GetAbility():GetSpecialValueFor("invis_duration")
    self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_rat_burrow", {duration = duration})
    self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
end

modifier_rat_burrow = class({})

function modifier_rat_burrow:OnCreated()
    if not IsServer() then return end
    self.targets = {}
end

function modifier_rat_burrow:IsPurgable() return false end

function modifier_rat_burrow:CheckState()
    return 
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
    }
end

function modifier_rat_burrow:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }

    return funcs
end

function modifier_rat_burrow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_rat_burrow:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_reduced_caster")
end

function modifier_rat_burrow:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.attacker:PassivesDisabled() then return end
    if params.target:IsWard() then return end

    if not self.targets[params.target:entindex()] then
        local debuff_duration = self:GetAbility():GetSpecialValueFor("debuff_duration")
        params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_rat_burrow_debuff", {duration = debuff_duration})
        AddNewStack(2, params.target, self:GetParent())
        self.targets[params.target:entindex()] = params.target

        local particle = ParticleManager:CreateParticle("particles/items3_fx/iron_talon_active.vpcf", PATTACH_ABSORIGIN, params.target)
        ParticleManager:SetParticleControl(particle, 1, params.target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)

        if self:GetCaster():HasTalent("special_bonus_birzha_rat_4") then
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_rat_burrow_attackspeed_buff", {duration = self:GetRemainingTime()})
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_rat_burrow_attackspeed_debuff", {duration = self:GetRemainingTime() * (1-params.target:GetStatusResistance()) })
        end
    end
end

function modifier_rat_burrow:GetModifierModelChange()
    return "models/heroes/nerubian_assassin/mound.vmdl"
end

function modifier_rat_burrow:OnDestroy()
    if not IsServer() then return end
    self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_rat_burrow_destroy", {duration = 0.5})
end

modifier_rat_burrow_attackspeed_debuff = class({})

function modifier_rat_burrow_attackspeed_debuff:IsPurgable()
    return false
end

function modifier_rat_burrow_attackspeed_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_rat_burrow_attackspeed_debuff:GetModifierAttackSpeedBonus_Constant()
    return -self:GetCaster():FindTalentValue("special_bonus_birzha_rat_4")
end

modifier_rat_burrow_attackspeed_buff = class({})

function modifier_rat_burrow_attackspeed_buff:IsPurgable()
    return false
end

function modifier_rat_burrow_attackspeed_buff:IsHidden()
    return false
end

function modifier_rat_burrow_attackspeed_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_rat_burrow_attackspeed_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_rat_4")
end

modifier_rat_burrow_destroy = class({})

function modifier_rat_burrow_destroy:IsPurgable() return false end
function modifier_rat_burrow_destroy:IsHidden() return true end

function modifier_rat_burrow_destroy:OnCreated()
    if not IsServer() then return end
    local abs = self:GetParent():GetAbsOrigin()
    abs.z = abs.z - 100
    self:GetParent():SetAbsOrigin(abs)
    self:StartIntervalThink(FrameTime())
    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_END_ABILITY_2, 2)
    self:GetParent():EmitSound("rat_burrow_out")
end

function modifier_rat_burrow_destroy:OnIntervalThink()
    if not IsServer() then return end
    local abs = self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * (150 * FrameTime())
    abs.z = abs.z + (200 * FrameTime())
    self:GetParent():SetAbsOrigin(abs)
end

function modifier_rat_burrow_destroy:CheckState()
    return 
    {
        [MODIFIER_STATE_STUNNED]            = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }
end

function modifier_rat_burrow_destroy:OnDestroy()
    if not IsServer() then return end
    local abs = self:GetParent():GetAbsOrigin()
    self:GetParent():SetAbsOrigin(GetGroundPosition(abs, self:GetParent()))
    self:GetParent():RemoveGesture(ACT_DOTA_CHANNEL_END_ABILITY_2)
end

modifier_rat_burrow_debuff = class({})

function modifier_rat_burrow_debuff:IsPurgable() return false end

function modifier_rat_burrow_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }

    return funcs
end

function modifier_rat_burrow_debuff:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_reduced_target")
end

LinkLuaModifier( "modifier_rat_passive_caster_attack", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_rat_passive_stack", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_rat_passive_stack_buff", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)

rat_passive = class({})

function rat_passive:GetIntrinsicModifierName()
    return "modifier_rat_passive_caster_attack"
end

function AddNewStack(count, target, caster)
    if not IsServer() then return end
    if not target:IsRealHero() then return end
    local ability = caster:FindAbilityByName("rat_passive")

    if ability and ability:GetLevel() > 0 then
        local duration = ability:GetSpecialValueFor("duration")
        for i=1, count do
            if #target:FindAllModifiersByName("modifier_rat_passive_stack_buff") < (ability:GetSpecialValueFor("max_stack_count") + caster:FindTalentValue("special_bonus_birzha_rat_6")) then
                target:AddNewModifier(caster, ability, "modifier_rat_passive_stack", {duration = duration * ( 1 - target:GetStatusResistance())})
                target:AddNewModifier(caster, ability, "modifier_rat_passive_stack_buff", {duration = duration * ( 1 - target:GetStatusResistance())})
            end
        end
    end
end

modifier_rat_passive_caster_attack = class({})

function modifier_rat_passive_caster_attack:IsHidden() return self:GetStackCount() == 0 end
function modifier_rat_passive_caster_attack:IsPurgable() return false end

function modifier_rat_passive_caster_attack:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_rat_passive_caster_attack:OnAttackLanded( params )
     if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.attacker:PassivesDisabled() then return end
    if params.target:IsWard() then return end

    if self:GetParent():HasTalent("special_bonus_birzha_rat_8") then
        AddNewStack(self:GetCaster():FindTalentValue("special_bonus_birzha_rat_8"), params.target, self:GetParent())
    else
        AddNewStack(1, params.target, self:GetParent())
    end
end

function modifier_rat_passive_caster_attack:GetModifierPhysicalArmorBonus( params )
    if self:GetParent():HasTalent("special_bonus_birzha_rat_2") then
        local stack_count = math.ceil(self:GetStackCount())
        return stack_count * self:GetCaster():FindTalentValue("special_bonus_birzha_rat_2")
    end
    return 0
end

function modifier_rat_passive_caster_attack:GetModifierMoveSpeedBonus_Constant( params )
    if self:GetParent():HasTalent("special_bonus_birzha_rat_1") then
        local stack_count = math.ceil(self:GetStackCount())
        return stack_count * self:GetCaster():FindTalentValue("special_bonus_birzha_rat_1")
    end
    return 0
end

modifier_rat_passive_stack_buff = class({})
function modifier_rat_passive_stack_buff:IsHidden() return true end
function modifier_rat_passive_stack_buff:IsPurgable() return false end
function modifier_rat_passive_stack_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_rat_passive_stack_buff:OnCreated()
    if not IsServer() then return end
    local caster_modifier = self:GetCaster():FindModifierByName("modifier_rat_passive_caster_attack")
    if caster_modifier then
        caster_modifier:IncrementStackCount()
    end
end

function modifier_rat_passive_stack_buff:OnDestroy()
    if not IsServer() then return end
    local caster_modifier = self:GetCaster():FindModifierByName("modifier_rat_passive_caster_attack")
    if caster_modifier then
        if caster_modifier:GetStackCount() > 0 then
            caster_modifier:DecrementStackCount()
        end
    end
end

modifier_rat_passive_stack = class({})

function modifier_rat_passive_stack:IsPurgable() return false end

function modifier_rat_passive_stack:OnCreated()
    self.hp_lose = self:GetStackCount() * self:GetAbility():GetSpecialValueFor("strength_minus")
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_rat_passive_stack:OnIntervalThink()
    if not IsServer() then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_rat_passive_stack_buff")
    self:SetStackCount(#modifier)
end

function modifier_rat_passive_stack:OnStackCountChanged(iStackCount)
    if not IsServer() then return end
    local ABS = 0
    if self:GetStackCount() >= self:GetParent():GetStrength() - 1 then
        ABS = self:GetStackCount() - (self:GetParent():GetStrength() - 1)
    end
    self.hp_lose = (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("strength_minus")) - ABS
    self:GetParent():CalculateStatBonus(true)
end
    
function modifier_rat_passive_stack:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end

function modifier_rat_passive_stack:GetModifierBonusStats_Strength()
    return self.hp_lose * (-1)
end

function modifier_rat_passive_stack:OnDestroy()
    if not IsServer() then return end

    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local damage = self:GetAbility():GetSpecialValueFor("stack_damage")

    if self:GetCaster():HasScepter() then
        damage = damage + self:GetAbility():GetSpecialValueFor("scepter_bonus_damage")
    end

    if not self:GetParent():IsAlive() or self.ultimate ~= nil then
        self:GetParent():EmitSound("rat_poison")

        local particle = ParticleManager:CreateParticle("particles/rat/poison_explodeecon/items/sand_king/sandking_ti7_arms/sandking_ti7_caustic_finale_explode.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)

        local particle2 = ParticleManager:CreateParticle("particles/rat/explosion_poison_2.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(particle2, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(particle2, 1, Vector(radius,radius,radius))
        ParticleManager:ReleaseParticleIndex(particle2)

        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false )
        for _, unit in pairs(units) do
            ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = self:GetStackCount() * damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
        end

        if self:GetCaster():HasTalent("special_bonus_birzha_rat_7") then
            local units_talent = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetCaster():FindTalentValue("special_bonus_birzha_rat_7"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false )
            for _, unit in pairs(units_talent) do
                local stacks = self:GetCaster():FindTalentValue("special_bonus_birzha_rat_7", "valu2") / 100 * self:GetStackCount()
                AddNewStack(stacks, unit, self:GetCaster())
            end
        end
    end
end

function modifier_rat_passive_stack:GetEffectName()
    return "particles/econ/items/venomancer/veno_2021_immortal_arms/veno_2021_immortal_poison_debuff.vpcf"
end

function modifier_rat_passive_stack:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

-------------------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_rat_poison_explosion", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_rat_poison_explosion_damage", "abilities/heroes/rat", LUA_MODIFIER_MOTION_NONE)

rat_poison_explosion = class({})

function rat_poison_explosion:OnSpellStart()
    if not IsServer() then return end
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
    for _, unit in pairs(units) do
        local mod = unit:FindModifierByName("modifier_rat_passive_stack")
        if mod and not mod:IsNull() then
            mod.ultimate = true
            mod:Destroy()
            if unit:IsAlive() then
                local thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_rat_poison_explosion", {duration = duration, target_point_x = unit:GetAbsOrigin().x , target_point_y = unit:GetAbsOrigin().y}, unit:GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
            end
        end
    end    
end

modifier_rat_poison_explosion = class({})

function modifier_rat_poison_explosion:IsPurgable() return false end
function modifier_rat_poison_explosion:IsHidden() return true end
function modifier_rat_poison_explosion:IsAura() return true end

function modifier_rat_poison_explosion:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_rat_poison_explosion:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_rat_poison_explosion:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_rat_poison_explosion:GetModifierAura()
    return "modifier_rat_poison_explosion_damage"
end

function modifier_rat_poison_explosion:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("cloud_radius")
end

function modifier_rat_poison_explosion:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/rat/poison_smoke.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self:GetAbility():GetSpecialValueFor("cloud_radius"), self:GetAbility():GetSpecialValueFor("cloud_radius"), self:GetAbility():GetSpecialValueFor("cloud_radius")))
    self:AddParticle(particle, false, false, -1, false, false)
end

modifier_rat_poison_explosion_damage = class({})

function modifier_rat_poison_explosion_damage:IsPurgable() return false end
function modifier_rat_poison_explosion_damage:IsDebuff() return true end

function modifier_rat_poison_explosion_damage:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink( 1 )
end

function modifier_rat_poison_explosion_damage:OnIntervalThink()
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    if not IsServer() then return end
    ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
    AddNewStack(1, self:GetParent(), self:GetCaster())
end