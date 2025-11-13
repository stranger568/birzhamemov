LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_V1lat_Crab", "abilities/heroes/v1lat", LUA_MODIFIER_MOTION_NONE)

V1lat_Crab = class({})

function V1lat_Crab:Precache(context)
    local particle_list = 
    {
        "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf",
        "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_initial.vpcf",
        "particles/v1lat/v1lat_aiaiai.vpcf",
        "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_debuff.vpcf",
        "particles/status_fx/status_effect_frost.vpcf",
        "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison.vpcf",
        "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison_end.vpcf",
        "particles/units/heroes/hero_queenofpain/queen_sonic_wave.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
    PrecacheResource("model", "models/items/courier/hermit_crab/hermit_crab_aegis.vmdl", context)
end

function V1lat_Crab:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function V1lat_Crab:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function V1lat_Crab:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function V1lat_Crab:CastFilterResultTarget(target)   
    if IsServer() then
        local caster = self:GetCaster()

        if not caster:HasTalent("special_bonus_birzha_v1lat_7") then
            if target:IsMagicImmune() then
                return UF_FAIL_MAGIC_IMMUNE_ENEMY
            end
        end

        local nResult = UnitFilter( target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber() )
        return nResult
    end
end

function V1lat_Crab:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb( self ) then
        return
    end

    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_v1lat_4")

    target:EmitSound("V1latRak")   

    local particle_hex_fx = ParticleManager:CreateParticle( "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf", PATTACH_CUSTOMORIGIN, target)     
    ParticleManager:SetParticleControl(particle_hex_fx, 0, target:GetAbsOrigin())      
    ParticleManager:ReleaseParticleIndex(particle_hex_fx)

    target:AddNewModifier(self:GetCaster(), self, "modifier_V1lat_Crab", {duration = duration * (1 - target:GetStatusResistance())})
end

modifier_V1lat_Crab = class({})

function modifier_V1lat_Crab:IsPurgable()    
    return true
end

function modifier_V1lat_Crab:OnCreated()
    if self:GetParent():IsIllusion() then
        self:GetParent():Kill(self:GetAbility(), self:GetCaster())
    end
end

function modifier_V1lat_Crab:IsHidden() return false end
function modifier_V1lat_Crab:IsPurgable() return false end
function modifier_V1lat_Crab:IsPurgeException() return true end
function modifier_V1lat_Crab:IsDebuff() return true end

function modifier_V1lat_Crab:CheckState()
    local state = 
    {
        [MODIFIER_STATE_HEXED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true
    }            
    return state
end

function modifier_V1lat_Crab:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
    }
    return decFuncs
end

function modifier_V1lat_Crab:GetModifierModelChange()
    return "models/items/courier/hermit_crab/hermit_crab_aegis.vmdl"
end

function modifier_V1lat_Crab:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor("move_speed")    
end

LinkLuaModifier("modifier_V1lat_AiAiAi_thinker", "abilities/heroes/v1lat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_V1lat_AiAiAi_debuff", "abilities/heroes/v1lat", LUA_MODIFIER_MOTION_NONE)

V1lat_AiAiAi = class({})

function V1lat_AiAiAi:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function V1lat_AiAiAi:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function V1lat_AiAiAi:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function V1lat_AiAiAi:OnUpgrade()
    if not self.release_ability then
        self.release_ability = self:GetCaster():FindAbilityByName("V1lat_AiAiAi_slam")
    end
    
    if self.release_ability and not self.release_ability:IsTrained() then
        self.release_ability:SetLevel(1)
    end
end

function V1lat_AiAiAi:OnSpellStart()
    if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
        self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
    end
    EmitSoundOnClient("Hero_Ancient_Apparition.IceBlast.Tracker", self:GetCaster():GetPlayerOwner())
    local velocity  = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * 1500
    self.ice_blast_dummy = CreateModifierThinker(self:GetCaster(), self, "modifier_V1lat_AiAiAi_thinker", {x = velocity.x, y = velocity.y}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)

    local linear_projectile = {
        Ability             = self,
        vSpawnOrigin        = self:GetCaster():GetAbsOrigin(),
        fDistance           = math.huge,
        fStartRadius        = 0,
        fEndRadius          = 0,
        Source              = self:GetCaster(),
        bDrawsOnMinimap     = true,
        bVisibleToEnemies   = false,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_NONE,
        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 30.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(velocity.x, velocity.y, 0),
        bProvidesVision     = true,
        iVisionRadius       = 650,
        iVisionTeamNumber   = self:GetCaster():GetTeamNumber(),
        
        ExtraData           =
        {
            direction_x     = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()).x,
            direction_y     = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()).y,
            direction_z     = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()).z,
            ice_blast_dummy = self.ice_blast_dummy:entindex(),
        }
    }

    self.initial_projectile = ProjectileManager:CreateLinearProjectile(linear_projectile)
    
    if not self.release_ability then
        self.release_ability = self:GetCaster():FindAbilityByName("V1lat_AiAiAi_slam")
    end 
    
    if self.release_ability then
        self:GetCaster():SwapAbilities(self:GetName(), self.release_ability:GetName(), false, true)
    end
end

function V1lat_AiAiAi:OnProjectileThink_ExtraData(location, data)
    if data.ice_blast_dummy then
        EntIndexToHScript(data.ice_blast_dummy):SetAbsOrigin(location)
    end
    
    if not self:GetCaster():IsAlive() and self.release_ability then
        self.release_ability:OnSpellStart()
    end
end

function V1lat_AiAiAi:OnProjectileHit_ExtraData(target, location, data)
    if not target and data.ice_blast_dummy then
        local ice_blast_thinker_modifier = EntIndexToHScript(data.ice_blast_dummy):FindModifierByNameAndCaster("modifier_V1lat_AiAiAi_thinker", self:GetCaster())
        
        if ice_blast_thinker_modifier and not ice_blast_thinker_modifier:IsNull() then
            ice_blast_thinker_modifier:Destroy()
        end
    end
end

modifier_V1lat_AiAiAi_thinker = class({})

function modifier_V1lat_AiAiAi_thinker:IsPurgable()    return false end

function modifier_V1lat_AiAiAi_thinker:OnCreated(params)
    if not IsServer() then return end
    local ice_blast_particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_initial.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
    ParticleManager:SetParticleControl(ice_blast_particle, 1, Vector(params.x, params.y, 0))
    self:AddParticle(ice_blast_particle, false, false, -1, false, false)
end

function modifier_V1lat_AiAiAi_thinker:OnDestroy()
    if not IsServer() then return end
    self.release_ability    = self:GetCaster():FindAbilityByName("V1lat_AiAiAi_slam")
    if self:GetAbility() and self:GetAbility():IsHidden() and self.release_ability then 
        self:GetCaster():SwapAbilities("V1lat_AiAiAi_slam", "V1lat_AiAiAi", false, true)
    end
    self:GetParent():RemoveSelf()
end

V1lat_AiAiAi_slam = class({})

function V1lat_AiAiAi_slam:OnSpellStart()
    if not self.ice_blast_ability then
        self.ice_blast_ability  = self:GetCaster():FindAbilityByName("V1lat_AiAiAi")
    end
    
    if self.ice_blast_ability then
        if self.ice_blast_ability.ice_blast_dummy and self.ice_blast_ability.initial_projectile then
            local vector    = self.ice_blast_ability.ice_blast_dummy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
            local velocity  = vector:Normalized() * math.max(vector:Length2D() / 2, 25000)
            local final_radius  = math.min(400 + ((vector:Length2D() / 1500) * 50), 1200)
            self:GetCaster():EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Cast")
            AddFOWViewer(self:GetCaster():GetTeamNumber(), self.ice_blast_ability.ice_blast_dummy:GetAbsOrigin(), 650, 4, false)

            local linear_projectile = {
                Ability             = self,
                vSpawnOrigin        = self:GetCaster():GetAbsOrigin(),
                fDistance           = vector:Length2D(),
                fStartRadius        = 300,
                fEndRadius          = 300,
                Source              = self:GetCaster(),
                bHasFrontalCone     = false,
                bReplaceExisting    = false,
                iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_NONE,
                iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                fExpireTime         = GameRules:GetGameTime() + 10.0,
                bDeleteOnHit        = true,
                vVelocity           = velocity,
                bProvidesVision     = true,
                iVisionRadius       = 500,
                iVisionTeamNumber   = self:GetCaster():GetTeamNumber(),
                
                ExtraData           =
                {
                    marker_particle = marker_particle,
                    final_radius    = final_radius
                }
            }

            self.initial_projectile = ProjectileManager:CreateLinearProjectile(linear_projectile)
            self.ice_blast_ability.ice_blast_dummy:Destroy()
            ProjectileManager:DestroyLinearProjectile(self.ice_blast_ability.initial_projectile)
            self.ice_blast_ability.ice_blast_dummy      = nil
            self.ice_blast_ability.initial_projectile   = nil
        end
        --self:GetCaster():SwapAbilities(self:GetName(), self.ice_blast_ability:GetName(), false, true)
    end
end

function V1lat_AiAiAi_slam:OnProjectileThink_ExtraData(location, data)
    if self.ice_blast_ability then
        AddFOWViewer(self:GetCaster():GetTeamNumber(), location, 500, 3, false)
        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
        local duration      = self.ice_blast_ability:GetSpecialValueFor("frostbite_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_v1lat_2")
        local stun_duration      = self.ice_blast_ability:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_v1lat_5")
        for _, enemy in pairs(enemies) do
            local ice_blast_modifier = nil
            
            if enemy:IsInvulnerable() then
                ice_blast_modifier = enemy:AddNewModifier(enemy, self.ice_blast_ability, "modifier_V1lat_AiAiAi_debuff", 
                    {
                        duration        = duration * (1 - enemy:GetStatusResistance()),
                        caster_entindex = self:GetCaster():entindex()
                    }
                )
            else
                ice_blast_modifier = enemy:AddNewModifier(self:GetCaster(), self.ice_blast_ability, "modifier_V1lat_AiAiAi_debuff", 
                    {
                        duration        = duration * (1 - enemy:GetStatusResistance()),
                    }
                )
            end
        end
    end
end

function V1lat_AiAiAi_slam:OnProjectileHit_ExtraData(target, location, data)
    if not target and self.ice_blast_ability then
        EmitSoundOnLocationWithCaster(location, "V1latAiaiai", self:GetCaster())

        local particle = ParticleManager:CreateParticle("particles/v1lat/v1lat_aiaiai.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(particle, 0, location)
        ParticleManager:ReleaseParticleIndex(particle)
    
        if data.marker_particle then
            ParticleManager:DestroyParticle(data.marker_particle, false)
            ParticleManager:ReleaseParticleIndex(data.marker_particle)
        end

        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, data.final_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
    
        local damageTable = {
            victim          = nil,
            damage          = self.ice_blast_ability:GetSpecialValueFor("damage"),
            damage_type     = self.ice_blast_ability:GetAbilityDamageType(),
            damage_flags    = DOTA_DAMAGE_FLAG_NONE,
            attacker        = self:GetCaster(),
            ability         = self
        }
        
        local duration      = self.ice_blast_ability:GetSpecialValueFor("frostbite_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_v1lat_2")
        local stun_duration      = self.ice_blast_ability:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_v1lat_5")
    
        for _, enemy in pairs(enemies) do
            local ice_blast_modifier = nil
            
            if enemy:IsInvulnerable() then
                ice_blast_modifier = enemy:AddNewModifier(enemy, self.ice_blast_ability, "modifier_V1lat_AiAiAi_debuff", 
                    {
                        duration        = duration * (1 - enemy:GetStatusResistance()),
                        caster_entindex = self:GetCaster():entindex()
                    }
                )
            else
                ice_blast_modifier = enemy:AddNewModifier(self:GetCaster(), self.ice_blast_ability, "modifier_V1lat_AiAiAi_debuff", 
                    {
                        duration        = duration * (1 - enemy:GetStatusResistance()),
                    }
                )
            end

            if not enemy:IsMagicImmune() then
                damageTable.victim = enemy
                ApplyDamage(damageTable)
                enemy:AddNewModifier( self:GetCaster(), self.ice_blast_ability, "modifier_birzha_stunned_purge", { duration = stun_duration * (1-enemy:GetStatusResistance()) } )
            end
        end
    end
end

modifier_V1lat_AiAiAi_debuff = class({})

function modifier_V1lat_AiAiAi_debuff:IsDebuff()      return true end
function modifier_V1lat_AiAiAi_debuff:IsPurgable()    return false end
function modifier_V1lat_AiAiAi_debuff:IsPurgeException()    return true end

function modifier_V1lat_AiAiAi_debuff:GetEffectName()
    return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_debuff.vpcf"
end

function modifier_V1lat_AiAiAi_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_V1lat_AiAiAi_debuff:OnCreated(params)
    if not IsServer() then return end
    self.dot_damage = self:GetAbility():GetSpecialValueFor("dot_damage")
    if params.caster_entindex then
        self.caster = EntIndexToHScript(params.caster_entindex)
    else
        self.caster = self:GetCaster()
    end
    
    self.damage_table   = 
    {
        victim          = self:GetParent(),
        damage          = self.dot_damage,
        damage_type     = DAMAGE_TYPE_MAGICAL,
        damage_flags    = DOTA_DAMAGE_FLAG_NONE,
        attacker        = self.caster,
        ability         = self:GetAbility()
    }
    
    self:StartIntervalThink(1)
end

function modifier_V1lat_AiAiAi_debuff:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_V1lat_AiAiAi_debuff:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Tick")
    ApplyDamage(self.damage_table)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), self.dot_damage, nil)
    if self:GetCaster():HasTalent("special_bonus_birzha_v1lat_8") then
        if self:GetParent():GetHealthPercent() <= self:GetCaster():FindTalentValue("special_bonus_birzha_v1lat_8") then
            self:GetParent():Kill(self:GetAbility(), self:GetCaster())
        end
    end
end

function modifier_V1lat_AiAiAi_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DISABLE_HEALING,
    }
end

function modifier_V1lat_AiAiAi_debuff:GetDisableHealing()
    return 1
end

LinkLuaModifier("modifier_V1lat_ItsNotNormal", "abilities/heroes/v1lat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_V1lat_ItsNotNormal_target", "abilities/heroes/v1lat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_V1lat_ItsNotNormal_caster", "abilities/heroes/v1lat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_V1lat_ItsNotNormal_target_buff", "abilities/heroes/v1lat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_V1lat_ItsNotNormal_caster_buff", "abilities/heroes/v1lat", LUA_MODIFIER_MOTION_NONE)

V1lat_ItsNotNormal = class({})

function V1lat_ItsNotNormal:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function V1lat_ItsNotNormal:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function V1lat_ItsNotNormal:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function V1lat_ItsNotNormal:OnSpellStart()
    if not IsServer() then return end
    local flag = 0
    local radius = self:GetSpecialValueFor("radius")
    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, flag, FIND_ANY_ORDER, false)
    local duration = self:GetSpecialValueFor("duration")

    for _,unit in pairs(targets) do
        unit:AddNewModifier( self:GetCaster(), self, "modifier_V1lat_ItsNotNormal", { duration = duration * (1-unit:GetStatusResistance()) } )
    end

    self:GetCaster():EmitSound("V1latNo")
end

modifier_V1lat_ItsNotNormal = class({})

function modifier_V1lat_ItsNotNormal:IsPurgable()    return false end

function modifier_V1lat_ItsNotNormal:CheckState()
    local state = 
    {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
     }            
    return state
end

function modifier_V1lat_ItsNotNormal:DeclareFunctions()
	local funcs = 
    {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
	}

	return funcs
end

function modifier_V1lat_ItsNotNormal:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_V1lat_ItsNotNormal:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_V1lat_ItsNotNormal:GetAbsoluteNoDamagePure()
	return 1
end

function modifier_V1lat_ItsNotNormal:OnCreated()
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 2, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
    self:GetParent():AddNoDraw()
end

function modifier_V1lat_ItsNotNormal:OnDestroy()
    if not IsServer() then return end

    local duration = self:GetAbility():GetSpecialValueFor("duration_stack") + self:GetCaster():FindTalentValue("special_bonus_birzha_v1lat_6")

    self:GetParent():RemoveNoDraw()

    local particle_end = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison_end.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle_end, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_end)

    self:GetParent():EmitSound("Hero_ObsidianDestroyer.AstralImprisonment.End")

    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_V1lat_ItsNotNormal_target_buff", { duration = duration * (1-self:GetParent():GetStatusResistance()) } )
    self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_V1lat_ItsNotNormal_caster_buff", { duration = duration } )
    
    if self:GetCaster():HasTalent("special_bonus_birzha_v1lat_3") then
        self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_V1lat_ItsNotNormal_target_buff", { duration = duration * (1-self:GetParent():GetStatusResistance()) } )
        self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_V1lat_ItsNotNormal_caster_buff", { duration = duration } )
    end

    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_V1lat_ItsNotNormal_target", { duration = duration * (1-self:GetParent():GetStatusResistance()) } )
    self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_V1lat_ItsNotNormal_caster", { duration = duration } )

    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
end

modifier_V1lat_ItsNotNormal_caster = class ({})

function modifier_V1lat_ItsNotNormal_caster:IsPurgable()
    return false
end

function modifier_V1lat_ItsNotNormal_caster:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_V1lat_ItsNotNormal_caster:OnIntervalThink()
    if not IsServer() then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_V1lat_ItsNotNormal_caster_buff")
    self:SetStackCount(#modifier)
end

function modifier_V1lat_ItsNotNormal_caster:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
    return declfuncs
end

function modifier_V1lat_ItsNotNormal_caster:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_int")
end

modifier_V1lat_ItsNotNormal_target = class ({})

function modifier_V1lat_ItsNotNormal_target:IsPurgable()
    return false
end

function modifier_V1lat_ItsNotNormal_target:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_V1lat_ItsNotNormal_target:OnIntervalThink()
    if not IsServer() then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_V1lat_ItsNotNormal_target_buff")
    self:SetStackCount(#modifier)
end

function modifier_V1lat_ItsNotNormal_target:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
    return declfuncs
end

function modifier_V1lat_ItsNotNormal_target:GetModifierBonusStats_Intellect()
    return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_int")) * -1
end

modifier_V1lat_ItsNotNormal_target_buff = class({})
function modifier_V1lat_ItsNotNormal_target_buff:IsHidden() return true end
function modifier_V1lat_ItsNotNormal_target_buff:IsPurgable() return false end
function modifier_V1lat_ItsNotNormal_target_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

modifier_V1lat_ItsNotNormal_caster_buff = class({})
function modifier_V1lat_ItsNotNormal_caster_buff:IsHidden() return true end
function modifier_V1lat_ItsNotNormal_caster_buff:IsPurgable() return false end
function modifier_V1lat_ItsNotNormal_caster_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

LinkLuaModifier("modifier_v1lat_eminem", "abilities/heroes/v1lat", LUA_MODIFIER_MOTION_NONE)

V1lat_Eminem = class({})

function V1lat_Eminem:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function V1lat_Eminem:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function V1lat_Eminem:GetChannelTime()
    if self:GetCaster():HasShard() then
        return 0
    end
    return self.BaseClass.GetChannelTime(self)
end

function V1lat_Eminem:GetBehavior()
    if self:GetCaster():HasShard() then
        return DOTA_ABILITY_BEHAVIOR_DIRECTIONAL + DOTA_ABILITY_BEHAVIOR_POINT
    end
    return DOTA_ABILITY_BEHAVIOR_DIRECTIONAL + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end

function V1lat_Eminem:OnSpellStart()
    if not IsServer() then return end
    self.point = self:GetCursorPosition()
    local caster = self:GetCaster()
    caster:EmitSound("V1latUltimate")
    if self:GetCaster():HasShard() then
        self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_v1lat_eminem", {duration = 5} )
        return
    end
    self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_v1lat_eminem", {duration = self:GetChannelTime()} )
end

function V1lat_Eminem:OnChannelFinish( bInterrupted )
    if not IsServer() then return end
    if self:GetCaster():HasShard() then return end
    if self.modifier and not self.modifier:IsNull() then
        self.modifier:Destroy()
    end
end

modifier_v1lat_eminem = class ({})

function modifier_v1lat_eminem:IsPurgable()
    return false
end

function modifier_v1lat_eminem:IsHidden()
    return not self:GetCaster():HasShard()
end

function modifier_v1lat_eminem:OnCreated()
    if not IsServer() then return end
    self.shard = false
    if self:GetCaster():HasShard() then
        self.shard = true
    end
    self.parent = self:GetParent()
    self.turn_rate = 120
    self:SetDirection( Vector(self:GetAbility().point.x, self:GetAbility().point.y, 0) ) 
    self.current_dir = self.target_dir
    self.turn_speed = FrameTime()*self.turn_rate
    self.proj_time = 0
    self:StartIntervalThink(FrameTime())
    self:OnIntervalThink()
end

function modifier_v1lat_eminem:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("V1latUltimate")
end

function modifier_v1lat_eminem:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_DISABLE_TURNING,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }
    return funcs
end

function modifier_v1lat_eminem:GetModifierMoveSpeed_Limit()
    return 0.1
end

function modifier_v1lat_eminem:GetModifierDisableTurning()
    return 1
end

function modifier_v1lat_eminem:OnOrder( params )
    if params.unit~=self:GetParent() then return end

    if params.order_type == DOTA_UNIT_ORDER_STOP or params.order_type == DOTA_UNIT_ORDER_HOLD_POSITION or params.order_type == DOTA_UNIT_ORDER_CONTINUE then
        self:Destroy()
        self:GetParent():Stop()
        return
    end

    if  params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION or
        params.order_type==DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
    then
        self:SetDirection( params.new_pos )
    elseif 
        params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
        params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
    then
        self:SetDirection( params.target:GetOrigin() )
    end
end

function modifier_v1lat_eminem:SetDirection( vec )
    if vec.x == self:GetCaster():GetAbsOrigin().x and vec.y == self:GetCaster():GetAbsOrigin().y then 
        vec = self:GetCaster():GetAbsOrigin() + 100*self:GetCaster():GetForwardVector()
    end
    self.target_dir = ((vec-self.parent:GetOrigin())*Vector(1,1,0)):Normalized()
    self.face_target = false
end

function modifier_v1lat_eminem:TurnLogic()
    if self.face_target then return end
    local current_angle = VectorToAngles( self.current_dir ).y
    local target_angle = VectorToAngles( self.target_dir ).y
    local angle_diff = AngleDiff( current_angle, target_angle )
    local sign = -1
    if angle_diff<0 then sign = 1 end
    if math.abs( angle_diff )<1.1*self.turn_speed then
        self.current_dir = self.target_dir
        self.face_target = true
    else
        self.current_dir = RotatePosition( Vector(0,0,0), QAngle(0, sign*self.turn_speed, 0), self.current_dir )
    end
    local a = self.parent:IsCurrentlyHorizontalMotionControlled()
    local b = self.parent:IsCurrentlyVerticalMotionControlled()
    if not (a or b) then
        self.parent:SetForwardVector( self.current_dir )
    end
end

function modifier_v1lat_eminem:OnIntervalThink()
    if not IsServer() then return end
    local projectile_name = "particles/units/heroes/hero_queenofpain/queen_sonic_wave.vpcf"
    local projectile_distance = self:GetAbility():GetSpecialValueFor("distance")
    local projectile_speed = self:GetAbility():GetSpecialValueFor("speed")
    local projectile_start_radius = self:GetAbility():GetSpecialValueFor("starting_aoe")
    local projectile_end_radius = self:GetAbility():GetSpecialValueFor("final_aoe")
    local projectile_direction = self:GetParent():GetForwardVector()

    if self:GetCaster():IsStunned() or self:GetCaster():IsSilenced() then
        self:Destroy()
        return
    end

    if self:GetCaster():HasShard() then
        self.shard = true
        self:TurnLogic()
    end

    local info = 
    {
        Source = self:GetCaster(),
        Ability = self:GetAbility(),
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        fDistance = projectile_distance,
        fStartRadius = projectile_start_radius,
        fEndRadius = projectile_end_radius,
        bHasFrontalCone = false,
        vVelocity = projectile_direction * projectile_speed,
        bDeleteOnHit = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bProvidesVision = false,
    }

    self.proj_time = self.proj_time + FrameTime()

    if self.proj_time >= 0.25 then
        self.proj_time = 0
        self:GetAbility():PlayProjectile( info )
        ProjectileManager:CreateLinearProjectile(info)
    end
end

function modifier_v1lat_eminem:CheckState()
    if not self.shard then return end
    return{[MODIFIER_STATE_DISARMED] = true,
    [MODIFIER_STATE_ROOTED] = true,}
end

function V1lat_Eminem:PlayProjectile( info )
    local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_sonic_wave.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControlForward( effect_cast, 0, self:GetCaster():GetForwardVector() )
    ParticleManager:SetParticleControl( effect_cast, 1, info.vVelocity )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

function V1lat_Eminem:OnProjectileHit( target, location )
    if not IsServer() then return end

    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_v1lat_1")

    local multi = self:GetSpecialValueFor("int_mul")

    local typedamage = DAMAGE_TYPE_MAGICAL

    if self:GetCaster():HasScepter() then
        typedamage = DAMAGE_TYPE_PURE
    end

    damage = damage + (self:GetCaster():GetIntellect(false) / 100 * multi)

    if not target then return end

    local damageTable = 
    {
        victim          = target,
        damage          = damage,
        damage_type     = typedamage,
        attacker        = self:GetCaster(),
        ability         = self
    }

    if not self:GetCaster():HasScepter() then
        if target:IsMagicImmune() then return end
    end
    
    ApplyDamage(damageTable)
end