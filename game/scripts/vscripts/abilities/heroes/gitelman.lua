LinkLuaModifier( "modifier_gitelman_kaif_smoke", "abilities/heroes/gitelman.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gitelman_kaif_smoke_buff", "abilities/heroes/gitelman.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Gitelman_Kaif = class({})

function Gitelman_Kaif:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Gitelman_Kaif:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Gitelman_Kaif:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Gitelman_Kaif:GetAOERadius()
    local bonus_radius = 0
    if self:GetCaster():HasShard() then
        bonus_radius = self:GetSpecialValueFor("shard_radius")
    end
    return self:GetSpecialValueFor("radius") + bonus_radius
end

function Gitelman_Kaif:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local thinker = CreateModifierThinker(caster, self, "modifier_gitelman_kaif_smoke", {duration = duration, target_point_x = point.x , target_point_y = point.y}, point, caster:GetTeamNumber(), false)
    caster:EmitSound("gorinbaldezh")
end

modifier_gitelman_kaif_smoke = class({})

function modifier_gitelman_kaif_smoke:IsPurgable() return false end
function modifier_gitelman_kaif_smoke:IsHidden() return true end
function modifier_gitelman_kaif_smoke:IsAura() return true end

function modifier_gitelman_kaif_smoke:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    if self:GetCaster():HasShard() then
        self.radius = self.radius + self:GetAbility():GetSpecialValueFor("shard_radius")
    end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_smokebomb.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, self.radius))  
    self:AddParticle(particle, false, false, -1, false, false)  
end

function modifier_gitelman_kaif_smoke:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY 
end

function modifier_gitelman_kaif_smoke:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_gitelman_kaif_smoke:GetModifierAura()
    return "modifier_gitelman_kaif_smoke_buff"
end

function modifier_gitelman_kaif_smoke:GetAuraRadius()
    return self.radius
end

modifier_gitelman_kaif_smoke_buff = class({})

function modifier_gitelman_kaif_smoke_buff:IsPurgable() return false end

function modifier_gitelman_kaif_smoke_buff:DeclareFunctions()
    local funcs = 
    { 
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL, 
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
    }
    return funcs
end

function modifier_gitelman_kaif_smoke_buff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
    }
    return state
end

function modifier_gitelman_kaif_smoke_buff:GetModifierInvisibilityLevel()
    return 1
end

function modifier_gitelman_kaif_smoke_buff:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("hp_regen")
end

function modifier_gitelman_kaif_smoke_buff:GetModifierStatusResistanceStacking()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_gitelman_7")
end


LinkLuaModifier( "modifier_gitelman_chain_damage", "abilities/heroes/gitelman.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gitelman_chain_manabreak", "abilities/heroes/gitelman.lua", LUA_MODIFIER_MOTION_NONE )

gitelman_chain = class({})

function gitelman_chain:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function gitelman_chain:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function gitelman_chain:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function gitelman_chain:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local projectile_speed = self:GetSpecialValueFor( "arrow_speed" )
    local location = self:GetCaster():GetOrigin()
    local info = 
    {
        Target = target,
        Source = self:GetCaster(),
        Ability = self, 
        EffectName = "particles/gitelman/gitelman_chain.vpcf",
        iMoveSpeed = projectile_speed,
        bDodgeable = true,
        ExtraData = 
        {
            location_x = location.x,
            location_y = location.y,
            location_z = location.z,
        }
    }
    ProjectileManager:CreateTrackingProjectile(info)
    self:GetCaster():EmitSound("Hero_Windrunner.ShackleshotCast")
end

function gitelman_chain:OnProjectileHit_ExtraData( target, location, ExtraData )
    if not target then return end
    if target:TriggerSpellAbsorb( self ) then return end
    if target:IsMagicImmune() then return end
    local search_radius = self:GetSpecialValueFor( "shackle_distance" )
    local stun_duration = self:GetSpecialValueFor( "stun_duration" )
    local fail_duration = self:GetSpecialValueFor( "fail_stun_duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gitelman_4")
    local search_angle = self:GetSpecialValueFor( "shackle_angle" )
    local search_count = self:GetSpecialValueFor( "shackle_count" )
    local shackled = 0
    local location = Vector( ExtraData.location_x, ExtraData.location_y, ExtraData.location_z )
    local target_origin = target:GetOrigin()
    local target_angle = VectorToAngles( target_origin-location ).y

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetOrigin(), nil, search_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false )

    for _,enemy in pairs(enemies) do
        if enemy~=target then
            local enemy_angle = VectorToAngles( enemy:GetOrigin()-target_origin ).y
            if math.abs( AngleDiff( target_angle, enemy_angle ) ) <= search_angle then
                shackled = shackled + 1
                target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = stun_duration * (1 - target:GetStatusResistance()) } )
                enemy:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = stun_duration * (1 - enemy:GetStatusResistance()) } )
                if self:GetCaster():HasTalent("special_bonus_birzha_gitelman_1") then
                    target:AddNewModifier( self:GetCaster(), self, "modifier_gitelman_chain_manabreak", { duration = stun_duration * (1 - target:GetStatusResistance()) } )
                    enemy:AddNewModifier( self:GetCaster(), self, "modifier_gitelman_chain_manabreak", { duration = stun_duration * (1 - enemy:GetStatusResistance()) } )
                end
                if self:GetCaster():HasTalent("special_bonus_birzha_gitelman_2") then
                    target:AddNewModifier( self:GetCaster(), self, "modifier_gitelman_chain_damage", { duration = stun_duration * (1 - target:GetStatusResistance()) } )
                    enemy:AddNewModifier( self:GetCaster(), self, "modifier_gitelman_chain_damage", { duration = stun_duration * (1 - enemy:GetStatusResistance()) } )
                end
                local effect_cast = ParticleManager:CreateParticle( "particles/gitelman/gitelman_chain_pair.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
                ParticleManager:SetParticleControlEnt( effect_cast, 1, enemy, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
                ParticleManager:SetParticleControl( effect_cast, 2, Vector( stun_duration, 0, 0 ) )
                ParticleManager:ReleaseParticleIndex( effect_cast )
                target:EmitSound("Hero_Windrunner.ShackleshotBind")
                target:EmitSound("Hero_Windrunner.ShackleshotStun")
                enemy:EmitSound("Hero_Windrunner.ShackleshotStun")
            end
            if shackled>=search_count then break end
        end
    end
    if shackled>=search_count then return end
    local trees = GridNav:GetAllTreesAroundPoint( target_origin, search_radius, false )
    for _,tree in pairs(trees) do
        local tree_angle = VectorToAngles( tree:GetOrigin()-target_origin ).y
        if math.abs( AngleDiff( target_angle, tree_angle ) ) <= search_angle then
            shackled = shackled + 1
            target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = stun_duration * (1 - target:GetStatusResistance()) } )
            if self:GetCaster():HasTalent("special_bonus_birzha_gitelman_1") then
                target:AddNewModifier( self:GetCaster(), self, "modifier_gitelman_chain_manabreak", { duration = stun_duration * (1 - target:GetStatusResistance()) } )  
            end
            if self:GetCaster():HasTalent("special_bonus_birzha_gitelman_2") then
                target:AddNewModifier( self:GetCaster(), self, "modifier_gitelman_chain_damage", { duration = stun_duration * (1 - target:GetStatusResistance()) } )  
            end
            local effect_cast = ParticleManager:CreateParticle( "particles/gitelman/gitelman_chain_pair_tree.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
            ParticleManager:SetParticleControl( effect_cast, 1, tree:GetOrigin() )
            ParticleManager:SetParticleControl( effect_cast, 2, Vector( stun_duration, 0, 0 ) )
            ParticleManager:ReleaseParticleIndex( effect_cast )
            target:EmitSound("Hero_Windrunner.ShackleshotBind")
            target:EmitSound("Hero_Windrunner.ShackleshotStun")
            break
        end
    end
    if shackled>=search_count then return end
    target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned", { duration = fail_duration * (1 - target:GetStatusResistance()) } )
    if self:GetCaster():HasTalent("special_bonus_birzha_gitelman_1") then
        target:AddNewModifier( self:GetCaster(), self, "modifier_gitelman_chain_manabreak", { duration = fail_duration * (1 - target:GetStatusResistance()) } )
    end
    if self:GetCaster():HasTalent("special_bonus_birzha_gitelman_2") then
        target:AddNewModifier( self:GetCaster(), self, "modifier_gitelman_chain_damage", { duration = fail_duration * (1 - target:GetStatusResistance()) } )
    end
    local point = target_origin-location
    point.z = 0
    point = target_origin + point:Normalized()*search_radius
    local effect_cast = ParticleManager:CreateParticle( "particles/gitelman/gitelman_chain_single.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
    ParticleManager:SetParticleControlForward( effect_cast, 2, (point-target:GetOrigin()):Normalized() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    target:EmitSound("Hero_Windrunner.ShackleshotStun")
end

modifier_gitelman_chain_manabreak = class({})

function modifier_gitelman_chain_manabreak:IsHidden() return true end

function modifier_gitelman_chain_manabreak:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_gitelman_chain_manabreak:OnIntervalThink()
    if not IsServer() then return end
    local mana = self:GetCaster():GetMaxMana() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_gitelman_1")
    self:GetParent():Script_ReduceMana(mana*0.5, self:GetAbility())
end

modifier_gitelman_chain_damage = class({})

function modifier_gitelman_chain_damage:IsHidden() return true end

function modifier_gitelman_chain_damage:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_gitelman_chain_damage:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetCaster():FindTalentValue("special_bonus_birzha_gitelman_2")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

Gitelman_PhysicalCulture = class({})

function Gitelman_PhysicalCulture:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Gitelman_PhysicalCulture:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Gitelman_PhysicalCulture:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Gitelman_PhysicalCulture:OnAbilityPhaseStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local knockback =
    {
        should_stun = false,
        knockback_duration = self:GetCastPoint(),
        duration = self:GetCastPoint(),
        knockback_distance = 0,
        knockback_height = 250,
    }
    caster:AddNewModifier(caster, self, "modifier_knockback", knockback)
    caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)
    return true
end

function Gitelman_PhysicalCulture:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    local caster = self:GetCaster()
    caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_5)
    caster:RemoveModifierByName("modifier_knockback")
    return true
end

function Gitelman_PhysicalCulture:OnSpellStart()
    if not IsServer() then return end
    local radius = self:GetSpecialValueFor("radius")

    local flag = 0

    if self:GetCaster():HasScepter() then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false )

    local animation_pfx = ParticleManager:CreateParticle("particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_ti7_magical.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(animation_pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(animation_pfx, 1, Vector(radius, 0, 0))
    ParticleManager:SetParticleControl(animation_pfx, 2, Vector(self:GetCastPoint(), 0, 0))
    ParticleManager:SetParticleControl(animation_pfx, 3, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(animation_pfx)

    self:GetCaster():EmitSound("Hero_Magnataur.ReversePolarity.Cast")

    self:GetCaster():EmitSound("Hero_ElderTitan.EchoStomp")

    for _,enemy in pairs(enemies) do

        local stun_duration = self:GetSpecialValueFor("stun_duration")

        if self:GetCaster():HasScepter() and enemy:IsMagicImmune() then
            stun_duration = stun_duration / 2
        end

        local damage = self:GetSpecialValueFor("damage")

        local caster_angle = self:GetCaster():GetForwardVector()

        local caster_origin = self:GetCaster():GetAbsOrigin()

        local offset_vector = caster_angle * 150

        local new_location = caster_origin + offset_vector

        enemy:SetAbsOrigin(new_location)

        FindClearSpaceForUnit(enemy, new_location, true)

        enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration * (1 - enemy:GetStatusResistance()) })

        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})

        local pull_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_reverse_polarity_pull.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(pull_pfx, 0, enemy:GetAbsOrigin())
        ParticleManager:SetParticleControl(pull_pfx, 1, new_location)
        ParticleManager:ReleaseParticleIndex(pull_pfx)
    end
end

LinkLuaModifier( "modifier_gitelman_MixedIngridients_buff", "abilities/heroes/gitelman.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gitelman_MixedIngridients_talent_debuff", "abilities/heroes/gitelman.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gitelman_MixedIngridients_talent_buff", "abilities/heroes/gitelman.lua", LUA_MODIFIER_MOTION_NONE )

Gitelman_MixedIngridients = class({})

function Gitelman_MixedIngridients:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Gitelman_MixedIngridients:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Gitelman_MixedIngridients:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor( "duration" )

    self:GetCaster():EmitSound("gitelmancoctel")

    local cast_pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControlEnt( cast_pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc" , self:GetCaster():GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex(cast_pfx)

    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_gitelman_MixedIngridients_buff", { duration = duration } )
end

modifier_gitelman_MixedIngridients_buff = class({})

function modifier_gitelman_MixedIngridients_buff:IsPurgable()
    return false
end

function modifier_gitelman_MixedIngridients_buff:AllowIllusionDuplicate()
    return true
end

function modifier_gitelman_MixedIngridients_buff:OnCreated( kv )
    if not IsServer() then return end
    ProjectileManager:ProjectileDodge( self:GetParent() )
    self:GetParent():Purge( false, true, false, false, false )
end

function modifier_gitelman_MixedIngridients_buff:OnRefresh( kv )
    if not IsServer() then return end
    ProjectileManager:ProjectileDodge( self:GetParent() )
    self:GetParent():Purge( false, true, false, false, false )
end

function modifier_gitelman_MixedIngridients_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,  
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_gitelman_MixedIngridients_buff:GetHeroEffectName()
    return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end

function modifier_gitelman_MixedIngridients_buff:GetEffectName()
    return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end

function modifier_gitelman_MixedIngridients_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_gitelman_MixedIngridients_buff:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor( "base_attack_time" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gitelman_5")
end

function modifier_gitelman_MixedIngridients_buff:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor( "bonus_health_regen" )
end

function modifier_gitelman_MixedIngridients_buff:GetModifierPhysicalArmorBonus()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_gitelman_3")
end

function modifier_gitelman_MixedIngridients_buff:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )
end

function modifier_gitelman_MixedIngridients_buff:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end

    if self:GetParent():HasTalent("special_bonus_birzha_gitelman_6") then
        DoCleaveAttack(params.attacker, params.target, self:GetAbility(), params.original_damage / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_gitelman_6"), 150, 360, 650, "particles/items_fx/battlefury_cleave.vpcf") 
    end

    if self:GetParent():HasTalent("special_bonus_birzha_gitelman_8") then
        if RollPercentage(self:GetCaster():FindTalentValue("special_bonus_birzha_gitelman_8")) then
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gitelman_MixedIngridients_talent_debuff", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_gitelman_8", "value4")})
            self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gitelman_MixedIngridients_talent_buff", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_gitelman_8", "value4")})
        end
    end
end

modifier_gitelman_MixedIngridients_talent_debuff = class({})

function modifier_gitelman_MixedIngridients_talent_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_gitelman_MixedIngridients_talent_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_gitelman_8", "value2")
end

modifier_gitelman_MixedIngridients_talent_buff = class({})

function modifier_gitelman_MixedIngridients_talent_buff:IsHidden() return true end

function modifier_gitelman_MixedIngridients_talent_buff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_gitelman_MixedIngridients_talent_buff:GetModifierDamageOutgoing_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_gitelman_8", "value3")
end