LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_migi_inside", "abilities/heroes/migi.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_migi_inside_parent", "abilities/heroes/migi.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_migi_inside_caster", "abilities/heroes/migi.lua", LUA_MODIFIER_MOTION_NONE )

migi_inside = class({})

function migi_inside:Precache(context)
    PrecacheResource("model", "models/update_heroes/migi/migi.vmdl", context)
    local particle_list = 
    {
        "particles/migi_shield.vpcf",
        "particles/migi_infected.vpcf",
        "particles/migi_pull.vpcf",
        "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function migi_inside:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function migi_inside:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function migi_inside:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end
 
function migi_inside:CastFilterResultTarget(target)
    if not target:IsRealHero() then
        return UF_FAIL
    end
    if target:HasModifier("modifier_kelthuzad_death_knight") then
        return UF_FAIL_CONSIDERED_HERO
    end
    local nResult = UnitFilter( target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, self:GetCaster():GetTeamNumber() )
    if nResult ~= UF_SUCCESS then
        return nResult
    end
    return UF_SUCCESS
end 

function migi_inside:OnSpellStart()
    self.target = self:GetCursorTarget()
    if self.target:TriggerSpellAbsorb( self ) then
        return
    end
    if self:GetCaster():GetUnitName() == "npc_dota_hero_migi" then
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_migi_inside", { target = self.target:entindex() } )
    end
end

modifier_migi_inside = class({})

function modifier_migi_inside:IsPurgable() return false end
function modifier_migi_inside:IsHidden() return true end

function modifier_migi_inside:OnCreated( kv )
    self.close_distance = 80
    self.far_distance = 2000
    self.speed = 800

    if not IsServer() then return end
    self.target = EntIndexToHScript(kv.target)
    self:GetCaster():SetForwardVector((self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized())
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)
    if self:ApplyHorizontalMotionController() == false then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_migi_inside:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)
    self:GetParent():InterruptMotionControllers( true )
    if not self.success then return end
    self.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_migi_inside_parent", {})
    self.target:EmitSound("Hero_LifeStealer.Infest")
end

function modifier_migi_inside:CheckState()
    local state = 
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

function modifier_migi_inside:UpdateHorizontalMotion( me, dt )
    local origin = self:GetParent():GetOrigin()
    if not self.target:IsAlive() then
        self:EndCharge( false )
    end
    local direction = self.target:GetOrigin() - origin
    direction.z = 0
    local distance = direction:Length2D()
    direction = direction:Normalized()

    if distance<self.close_distance then
        self:EndCharge( true )
    elseif distance>self.far_distance then
        self:EndCharge( false )
    end

    local target = origin + direction * self.speed * dt
    self:GetParent():SetOrigin( target )
    self:GetParent():FaceTowards( (self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized() )
end

function modifier_migi_inside:OnHorizontalMotionInterrupted()
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_migi_inside:EndCharge( success )
    if success then
        self.success = true
    end
    if not self:IsNull() then
        self:Destroy()
    end
end

modifier_migi_inside_parent = class({})

function modifier_migi_inside_parent:IsPurgable() return false end
function modifier_migi_inside_parent:IsHidden() return true end

function modifier_migi_inside_parent:OnCreated()
    if not IsServer() then return end

    local bonus_damage_perc = self:GetAbility():GetSpecialValueFor("bonus_damage")
    local bonus_magical_perc = self:GetAbility():GetSpecialValueFor("bonus_magic_amplify")
    local bonus_health_perc = 0 + self:GetCaster():FindTalentValue("special_bonus_birzha_migi_5")
    local health_regen_perc = 0 + self:GetCaster():FindTalentValue("special_bonus_birzha_migi_6")
    local bonus_armor_perc = 0

    if self:GetCaster():HasShard() then
        bonus_armor_perc = self:GetAbility():GetSpecialValueFor("armor_percent")
    end

    self.damage = self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * bonus_damage_perc
    self.health = self:GetCaster():GetMaxHealth() / 100 * bonus_health_perc
    self.magic_amplify = self:GetCaster():GetSpellAmplification(false) * bonus_magical_perc
    self.health_regen = self:GetCaster():GetHealthRegen() / 100 * health_regen_perc
    self.strength_bonus = 0
    self.agility_bonus = 0
    self.intellect_bonus = 0

    local get_armor = self:GetCaster():GetPhysicalArmorValue(false)
    if get_armor < 0 then
        get_armor = 0
    end

    self.armor = get_armor / 100 * bonus_armor_perc

    if self:GetCaster():HasModifier("modifier_migi_mutation_active") then
        self.strength_bonus = self:GetParent():GetStrength() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_migi_8")
        self.agility_bonus = self:GetParent():GetAgility() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_migi_8")
        self.intellect_bonus = self:GetParent():GetIntellect(false) / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_migi_8")
    end

    self:SetHasCustomTransmitterData(true)

    if not self:GetCaster():HasModifier("modifier_migi_inside_caster") then
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_migi_inside_caster", {target = self:GetParent():entindex()})
    end

    self:StartIntervalThink(FrameTime())
end

function modifier_migi_inside_parent:OnRefresh()
    self:OnCreated()
end

function modifier_migi_inside_parent:AddCustomTransmitterData() 
    return 
    {
        armor = self.armor,
        damage = self.damage,
        health = self.health,
        magic_amplify = self.magic_amplify,
        health_regen = self.health_regen,
        strength_bonus = self.strength_bonus,
        agility_bonus = self.agility_bonus,
        intellect_bonus = self.intellect_bonus,
    } 
end

function modifier_migi_inside_parent:HandleCustomTransmitterData(data)
    self.damage = data.damage
    self.health = data.health
    self.magic_amplify = data.magic_amplify
    self.health_regen = data.health_regen
    self.armor = data.armor
    self.strength_bonus = data.strength_bonus
    self.agility_bonus = data.agility_bonus
    self.intellect_bonus = data.intellect_bonus
end

function modifier_migi_inside_parent:OnIntervalThink()
    self:AddCustomTransmitterData()
    if not IsServer() then return end

    local bonus_damage_perc = self:GetAbility():GetSpecialValueFor("bonus_damage")
    local bonus_magical_perc = self:GetAbility():GetSpecialValueFor("bonus_magic_amplify")
    local bonus_health_perc =0 + self:GetCaster():FindTalentValue("special_bonus_birzha_migi_5")
    local health_regen_perc = 0 + self:GetCaster():FindTalentValue("special_bonus_birzha_migi_6")
    local bonus_armor_perc = 0

    if self:GetCaster():HasShard() then
        bonus_armor_perc = self:GetAbility():GetSpecialValueFor("armor_percent")
    end

    self.damage = self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * bonus_damage_perc
    self.health = self:GetCaster():GetMaxHealth() / 100 * bonus_health_perc
    self.magic_amplify = self:GetCaster():GetSpellAmplification(false) * bonus_magical_perc
    self.health_regen = self:GetCaster():GetHealthRegen() / 100 * health_regen_perc

    self.strength_bonus = 0
    self.agility_bonus = 0
    self.intellect_bonus = 0

    local get_armor = self:GetCaster():GetPhysicalArmorValue(false)
    if get_armor < 0 then
        get_armor = 0
    end

    if self:GetCaster():HasModifier("modifier_migi_mutation_active") then
        self.strength_bonus = self:GetParent():GetStrength() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_migi_8")
        self.agility_bonus = self:GetParent():GetAgility() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_migi_8")
        self.intellect_bonus = self:GetParent():GetIntellect(false) / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_migi_8")
    end

    self.armor = get_armor / 100 * bonus_armor_perc

    self:ForceRefresh()
    self:GetParent():CalculateStatBonus(true)
end

function modifier_migi_inside_parent:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():RemoveModifierByName("modifier_migi_inside_caster")
    if self:GetCaster():HasTalent("special_bonus_birzha_migi_3") then
        
    else
        self:GetCaster():BirzhaTrueKill(nil, self:GetCaster())
    end
end

function modifier_migi_inside_parent:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_AVOID_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,

        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_migi_inside_parent:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_migi_inside_parent:GetModifierHealthBonus()
    return self.health
end

function modifier_migi_inside_parent:GetModifierConstantHealthRegen()
    return self.health_regen
end

function modifier_migi_inside_parent:GetModifierSpellAmplify_Percentage()
    return self.magic_amplify
end

function modifier_migi_inside_parent:GetModifierBonusStats_Strength()
    return self.strength_bonus
end

function modifier_migi_inside_parent:GetModifierBonusStats_Agility()
    return self.agility_bonus
end

function modifier_migi_inside_parent:GetModifierBonusStats_Intellect()
    return self.intellect_bonus
end

function modifier_migi_inside_parent:GetModifierPhysicalArmorBonus()
    if self:GetCaster():HasShard() then
        return self.armor
    end
    return 0
end

function modifier_migi_inside_parent:GetModifierAvoidDamage(params)
    local ab = self:GetCaster():FindAbilityByName("migi_bubble")
    if ab and ab:GetLevel() > 0 then
        if ab:IsFullyCastable() then
            local nFXIndex = ParticleManager:CreateParticle( "particles/migi_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() );
            ParticleManager:SetParticleControl( nFXIndex, 0, Vector( 0, 0, -1000 ) )
            ParticleManager:SetParticleControlEnt(nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
            ab:UseResources(false, false, false, true)
            if self:GetCaster():HasTalent("special_bonus_birzha_migi_4") then
                if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
                    local damage_return = self:GetCaster():FindTalentValue("special_bonus_birzha_migi_4") * params.original_damage / 100
                    ApplyDamage({victim = params.attacker, attacker = self:GetParent(), damage = damage_return, damage_type = params.damage_type,  damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION, ability = self:GetAbility()})
                end
            end
            return 1
        else
            return 0
        end
    end
    return 0
end

function modifier_migi_inside_parent:GetModifierMoveSpeedBonus_Percentage()
    local ab = self:GetCaster():FindAbilityByName("migi_speed")
    if ab and ab:GetLevel() > 0 then
        return ab:GetSpecialValueFor("movespeed")
    end
    return 0
end

function modifier_migi_inside_parent:GetModifierEvasion_Constant()
    local ab = self:GetCaster():FindAbilityByName("migi_speed")
    if ab and ab:GetLevel() > 0 then
        return ab:GetSpecialValueFor("evasion") + self:GetCaster():FindTalentValue("special_bonus_birzha_migi_1")
    end
    return 0
end

function modifier_migi_inside_parent:GetEffectName()
    return "particles/migi_infected.vpcf"
end

function modifier_migi_inside_parent:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_migi_inside_caster = class({})

function modifier_migi_inside_caster:IsPurgable() return false end
function modifier_migi_inside_caster:IsHidden() return true end

function modifier_migi_inside_caster:OnCreated(kv)
    if not IsServer() then return end
    self:GetParent():AddNoDraw()
    self.target = EntIndexToHScript(kv.target)
    self:StartIntervalThink(FrameTime())

    local ab = self:GetParent():FindAbilityByName("migi_inside")
    if ab then
        ab:SetActivated(false)
    end
end

function modifier_migi_inside_caster:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveNoDraw()
    local ab = self:GetParent():FindAbilityByName("migi_inside")
    if ab then
        ab:SetActivated(true)
    end
end

function modifier_migi_inside_caster:OnIntervalThink()
    if not IsServer() then return end
    local abs = self.target:GetAbsOrigin()
    abs.z = 0
    self:GetParent():SetAbsOrigin(abs)
end

function modifier_migi_inside_caster:CheckState()
    local state = 
    {
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
    }

    if self:GetCaster():HasTalent("special_bonus_birzha_migi_7") then
        state = 
        {
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_INVULNERABLE] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_OUT_OF_GAME] = true,
        }
    end

    return state
end

function modifier_migi_inside_caster:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_ORDER
    }
end

function modifier_migi_inside_caster:OnOrder(keys)
    if not IsServer() then return end
    
    if keys.unit == self:GetParent() then
        local cancel_commands = 
        {
            [DOTA_UNIT_ORDER_HOLD_POSITION]     = true,
            [DOTA_UNIT_ORDER_STOP]              = true
        }
        
        if cancel_commands[keys.order_type] and self:GetElapsedTime() >= 0.1 then
        	self.target:RemoveModifierByName("modifier_migi_inside_parent")
            local caster = self:GetCaster()
            if not self:IsNull() then
                self:Destroy()
            end
            caster:BirzhaTrueKill(nil, caster)
        end
    end
end

-------------------------------
migi_bubble = class({})

function migi_bubble:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_migi_2")
end

migi_speed = class({})


LinkLuaModifier( "modifier_migi_mutation", "abilities/heroes/migi.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_migi_mutation_active", "abilities/heroes/migi.lua", LUA_MODIFIER_MOTION_NONE )

migi_mutation = class({})

function migi_mutation:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_birzha_migi_8") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function migi_mutation:GetCooldown(iLevel)
    if self:GetCaster():HasTalent("special_bonus_birzha_migi_8") then
        return 30
    end
    return 0
end

function migi_mutation:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_migi_mutation_active", {duration = 10})
end

modifier_migi_mutation_active = class({})

function modifier_migi_mutation_active:IsPurgable() return false end
function modifier_migi_mutation_active:RemoveOnDeath() return false end

function migi_mutation:GetIntrinsicModifierName()
    return "modifier_migi_mutation"
end

modifier_migi_mutation = class({})

function modifier_migi_mutation:IsPurgable() return false end
function modifier_migi_mutation:IsHidden() return true end

function modifier_migi_mutation:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }
    return funcs
end

function modifier_migi_mutation:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_migi_mutation:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_migi_mutation:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_hp_regen")
end

function modifier_migi_mutation:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_amplify")
end

LinkLuaModifier( "modifier_migi_death", "abilities/heroes/migi.lua", LUA_MODIFIER_MOTION_NONE )

migi_death = class({})

function migi_death:OnOwnerSpawned()
    if not IsServer() then return end
    self:StartCooldown(60)
end

function migi_death:GetIntrinsicModifierName()
    return "modifier_migi_death"
end

modifier_migi_death = class({})

function modifier_migi_death:IsPurgable() return false end
function modifier_migi_death:IsHidden() return true end

function modifier_migi_death:OnCreated()
    if not IsServer() then return end
    self:GetAbility():StartCooldown(60)
    self:StartIntervalThink(FrameTime())
end

function modifier_migi_death:OnIntervalThink()
    if self:GetParent():HasModifier("modifier_birzha_start_game") then
         self:GetAbility():StartCooldown(60)
        return
    end
    if self:GetParent():HasModifier("modifier_migi_inside_caster") then
         self:GetAbility():StartCooldown(60)
        return
    end
    if self:GetAbility():IsFullyCastable() then
        self:GetParent():BirzhaTrueKill(nil, self:GetParent())
        self:GetAbility():StartCooldown(60)
    end
end

function modifier_migi_death:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_STATUS_RESISTANCE
    }
    return funcs
end

function modifier_migi_death:GetModifierStatusResistance()
    return self:GetAbility():GetSpecialValueFor("effect_resistance")
end

LinkLuaModifier( "modifier_migi_aghanim_ability", "abilities/heroes/migi.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_migi_weapon", "abilities/heroes/migi.lua", LUA_MODIFIER_MOTION_NONE )

migi_aghanim_ability = class({})

function migi_aghanim_ability:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function migi_aghanim_ability:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function migi_aghanim_ability:GetIntrinsicModifierName()
    if self:GetCaster():IsIllusion() then return end
    return "modifier_migi_aghanim_ability"
end

modifier_migi_aghanim_ability = class({})

function modifier_migi_aghanim_ability:IsPurgable() return false end
function modifier_migi_aghanim_ability:IsHidden() return true end

function modifier_migi_aghanim_ability:OnCreated(params)
    if IsServer() then
        self.spirits_num_spirits        = 0
        self.spirits_spiritsSpawned     = {}
        self.spirit_radius              = 600
        self:GetAbility().update_timer  = 0
        self.time_to_update             = 0.8
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_migi_aghanim_ability:OnIntervalThink()
    if IsServer() then
        if self:GetCaster():IsAlive() then
            local caster                    = self:GetCaster()
            local caster_position           = caster:GetAbsOrigin()
            local ability                   = self:GetAbility()
            local elapsedTime               = GameRules:GetGameTime() - 1
            local idealNumSpiritsSpawned    = elapsedTime / 1

            idealNumSpiritsSpawned  = math.min(idealNumSpiritsSpawned, 5)

            if self.spirits_num_spirits < idealNumSpiritsSpawned then
                local newSpirit = CreateUnitByName("npc_dota_wisp_spirit", caster_position, false, caster, caster, caster:GetTeam())
                local spiritIndex = self.spirits_num_spirits + 1
                newSpirit.spirit_index = spiritIndex
                self.spirits_num_spirits = spiritIndex
                self.spirits_spiritsSpawned[spiritIndex] = newSpirit
                newSpirit:AddNewModifier( caster, ability, "modifier_migi_weapon", {} )
            end
            

            local currentRadius = self.spirit_radius
            local deltaRadius   = 12
            currentRadius       = currentRadius + deltaRadius
            currentRadius       = math.min( math.max( currentRadius, 350 ), 350 )
            self.spirit_radius  = currentRadius
            local currentRotationAngle  = elapsedTime * 150
            local rotationAngleOffset   = 360 / 5

            for k,spirit in pairs( self.spirits_spiritsSpawned ) do
                if not spirit:IsNull() and spirit:IsAlive() then
                    local rotationAngle = currentRotationAngle - rotationAngleOffset * (k - 1)
                    local relPos        = Vector(0, currentRadius, 0)
                    relPos              = RotatePosition(Vector(0,0,0), QAngle( 0, -rotationAngle, 0 ), relPos)
                    local absPos        = GetGroundPosition( relPos + caster_position, spirit)
                    spirit:SetAbsOrigin(absPos)
                end
            end

            if ability.update_timer > self.time_to_update then
                for k,spirit in pairs( self.spirits_spiritsSpawned ) do
                    if spirit:IsNull() or not spirit:IsAlive() then
                        local rotationAngle = currentRotationAngle - rotationAngleOffset * (k - 1)
                        local relPos        = Vector(0, currentRadius, 0)
                        relPos              = RotatePosition(Vector(0,0,0), QAngle( 0, -rotationAngle, 0 ), relPos)
                        local absPos        = GetGroundPosition( relPos + caster_position, self:GetParent())
                        local newSpirit = CreateUnitByName("npc_dota_wisp_spirit", absPos, false, caster, caster, caster:GetTeam())
                        newSpirit.spirit_index = k
                        self.spirits_spiritsSpawned[k] = newSpirit
                        newSpirit:AddNewModifier( caster, ability, "modifier_migi_weapon", {} )
                        ability.update_timer = 0
                        break
                    end
                end
            end

            for k,spirit in pairs( self.spirits_spiritsSpawned ) do
                if spirit:IsNull() or not spirit:IsAlive() then
                    ability.update_timer    = ability.update_timer + FrameTime()
                    break
                end
            end
        end
    end
end

modifier_migi_weapon = class({})

function modifier_migi_weapon:CheckState()
    local state = {
        [MODIFIER_STATE_NO_TEAM_MOVE_TO]    = true,
        [MODIFIER_STATE_NO_TEAM_SELECT]     = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE]      = true,
        [MODIFIER_STATE_MAGIC_IMMUNE]       = true,
        [MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_UNSELECTABLE]       = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP]     = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]      = true,
    }

    return state
end

function modifier_migi_weapon:OnCreated(params)
    if IsServer() then
        local pfx_pull = ParticleManager:CreateParticle("particles/migi_pull.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt( pfx_pull, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( pfx_pull, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
        self:AddParticle(pfx_pull, true, false, -1, false, false)
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_migi_weapon:OnIntervalThink()
    if IsServer() then
        if not self:GetCaster():IsAlive() then self:GetParent():ForceKill(false) return end 
        if not self:GetCaster():HasScepter() then self:GetParent():ForceKill(false) return end 
        local spirit = self:GetParent()
        local nearby_enemy_units = FindUnitsInRadius( self:GetCaster():GetTeam(), spirit:GetAbsOrigin(),  nil,  100,  DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,  DOTA_UNIT_TARGET_FLAG_NONE,  FIND_ANY_ORDER,  false )
        if nearby_enemy_units ~= nil and #nearby_enemy_units > 0 then
            local damage = self:GetAbility():GetSpecialValueFor("base_damage") + (self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * self:GetAbility():GetSpecialValueFor("perc_damage"))
            modifier_migi_weapon:OnHit(self:GetCaster(), spirit, nearby_enemy_units, damage, self:GetAbility())
        end
    end
end

function modifier_migi_weapon:OnHit(caster, spirit, enemies_hit, damage, ability) 
    local damage_table          = {}
    damage_table.attacker       = caster
    damage_table.ability        = nil
    damage_table.damage_type    = DAMAGE_TYPE_PURE
    damage_table.damage = damage
    for _,enemy in pairs(enemies_hit) do
        if enemy:IsAlive() and not spirit:IsNull() then 
            damage_table.victim = enemy
            ApplyDamage(damage_table)
            local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControlEnt( nFXIndex, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true )
            ParticleManager:SetParticleControl( nFXIndex, 1, enemy:GetOrigin() )
            ParticleManager:SetParticleControlForward( nFXIndex, 1, (spirit:GetOrigin()-enemy:GetOrigin()):Normalized() )
            ParticleManager:SetParticleControlEnt( nFXIndex, 10, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true )
            ParticleManager:ReleaseParticleIndex( nFXIndex )
            enemy:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
            spirit:ForceKill(false)
            break
        end
    end
end