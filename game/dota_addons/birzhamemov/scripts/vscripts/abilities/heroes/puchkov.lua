LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_puchkov_pigs_move", "abilities/heroes/puchkov", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_puchkov_pigs_plant", "abilities/heroes/puchkov", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_puchkov_pigs_pig_move", "abilities/heroes/puchkov", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_puchkov_pigs_pig_boom", "abilities/heroes/puchkov", LUA_MODIFIER_MOTION_NONE)

puchkov_pigs = class({}) 

function puchkov_pigs:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_puchkov_4")
end

function puchkov_pigs:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function puchkov_pigs:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function puchkov_pigs:OnSpellStart()
    if not IsServer() then return end
    local distance = self:GetSpecialValueFor("distance")
    local speed = self:GetSpecialValueFor("speed")
    local pigs = self:GetSpecialValueFor("pigs")
    local point = self:GetCursorPosition()
    local flying_time = distance / speed
    local point = self:GetCursorPosition()
    local dir = point - self:GetCaster():GetAbsOrigin()
    dir.z = 0
    dir = dir:Normalized()
    local pigs_copter = CreateUnitByName("npc_dummy_unit_gyro", self:GetCaster():GetAbsOrigin(), false, nil, nil, self:GetCaster():GetTeam())
    EmitSoundOn("Hero_Phoenix.IcarusDive.Cast", self:GetCaster()) 
    EmitSoundOn("PuchkovGoni", pigs_copter) 
    pigs_copter:SetForwardVector(dir)
    pigs_copter:AddNewModifier(self:GetCaster(), self, "modifier_puchkov_pigs_move", {})
    pigs_copter:AddNewModifier(self:GetCaster(), self, "modifier_puchkov_pigs_plant", {})
    pigs_copter:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = flying_time})
    pigs_copter:StartGesture(ACT_DOTA_RUN)
end

modifier_puchkov_pigs_move = class({})

function modifier_puchkov_pigs_move:IsPurgable()
    return false
end

function modifier_puchkov_pigs_move:IsHidden()
    return true
end

function modifier_puchkov_pigs_move:OnCreated( kv )
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_puchkov_pigs_move:OnIntervalThink()
    local speed = self:GetAbility():GetSpecialValueFor("speed")
    local actualspeed = speed / 30
    local fv = self:GetParent():GetForwardVector()
    local origin = self:GetParent():GetAbsOrigin()
    local new_position = origin + fv * actualspeed
    self:GetParent():SetAbsOrigin(new_position)
end

function modifier_puchkov_pigs_move:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
    }

    return decFuncs
end

function modifier_puchkov_pigs_move:GetVisualZDelta()
    return 350
end

function modifier_puchkov_pigs_move:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
    }
end

modifier_puchkov_pigs_plant = class({})

function modifier_puchkov_pigs_plant:IsPurgable()
    return false
end

function modifier_puchkov_pigs_plant:IsHidden()
    return true
end

function modifier_puchkov_pigs_plant:OnCreated( kv )
    if not IsServer() then return end
    local distance = self:GetAbility():GetSpecialValueFor("distance")
    local speed = self:GetAbility():GetSpecialValueFor("speed")
    self.pigs = self:GetAbility():GetSpecialValueFor("pigs") + 1



    local flying_time = distance / speed
    local pigs_interval = flying_time / self.pigs

    self:StartIntervalThink(pigs_interval)
end

function modifier_puchkov_pigs_plant:OnIntervalThink()
    if self.pigs <= 0 then return end
    self.pigs = self.pigs - 1
    local copter_position = self:GetParent():GetAbsOrigin()
    local pig_bomb = CreateUnitByName("npc_dota_puchkov_land_pig", copter_position, false, nil, nil, self:GetParent():GetTeam())
    EmitSoundOn("PuchkovPig", pig_bomb)
    EmitSoundOn("Hero_Techies.RemoteMine.Toss", pig_bomb)
    pig_bomb:SetAbsOrigin(copter_position + Vector(0,0,300))
    pig_bomb:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_puchkov_pigs_pig_move", {copter_position = copter_position})
end

modifier_puchkov_pigs_pig_move = class({})

function modifier_puchkov_pigs_pig_move:IsPurgable()
    return false
end

function modifier_puchkov_pigs_pig_move:IsHidden()
    return true
end

function modifier_puchkov_pigs_pig_move:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true,}

    return state
end

function modifier_puchkov_pigs_pig_move:OnCreated( kv )
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
    self.new_pos = kv.copter_position
end

function modifier_puchkov_pigs_pig_move:OnIntervalThink()
    local delay = 0.75
    local speed = 400 / delay
    local actualspeed = speed / 30
    local origin = self:GetParent():GetAbsOrigin()
    local new_position = origin + Vector(0,0,-actualspeed)


    if new_position.z < GetGroundHeight( self:GetParent():GetOrigin(), self:GetParent() ) then
        new_position.z = GetGroundHeight( self:GetParent():GetOrigin(), self:GetParent() )
        self:GetParent():SetAbsOrigin(new_position)
        self:Destroy()
        return
    end

    self:GetParent():SetAbsOrigin(new_position)
end

function modifier_puchkov_pigs_pig_move:OnDestroy( kv )
    if not IsServer() then return end
    local knockback =
    {
        knockback_duration = 0.03,
        duration = 0.03,
        knockback_height = 5,
    }
    --self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_knockback", knockback)
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_puchkov_pigs_pig_boom", {})
end

modifier_puchkov_pigs_pig_boom = class({})

function modifier_puchkov_pigs_pig_boom:IsPurgable()
    return false
end

function modifier_puchkov_pigs_pig_boom:IsHidden()
    return true
end

function modifier_puchkov_pigs_pig_boom:OnCreated()
    if not IsServer() then return end
    local particle_mine_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle_mine_fx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_mine_fx, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle_mine_fx, false, false, -1, false, false)
    self.triggered = false
    self:StartIntervalThink(FrameTime())
end

function modifier_puchkov_pigs_pig_boom:OnIntervalThink()
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
                                        self:GetParent():GetAbsOrigin(),
                                        nil,
                                        radius,
                                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                                        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                        FIND_ANY_ORDER,
                                        false)

    if #enemies > 0 then
        self.triggered = true
        EmitSoundOn("Hero_Techies.RemoteMine.Detonate", self:GetParent())
        EmitSoundOn("PuchkovPig", self:GetParent())
        local groundPos = GetGroundPosition(self:GetParent():GetAbsOrigin(), self:GetParent())
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
        ParticleManager:SetParticleControl( particle, 0, groundPos )
        ParticleManager:SetParticleControl( particle, 1, Vector(radius,0,0) )
        ParticleManager:SetParticleControl( particle, 2, groundPos)
        ParticleManager:SetParticleControl( particle, 3, groundPos)
        GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), radius, false)
        for _,enemy in pairs(enemies) do
            local damageTable = {victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() }
            ApplyDamage(damageTable)
        end
        self:GetParent():Destroy()
    end
end

function modifier_puchkov_pigs_pig_boom:CheckState()
    local state

    if not self.triggered then
        state = {[MODIFIER_STATE_INVISIBLE] = true,
                 [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
             [MODIFIER_STATE_NO_HEALTH_BAR] = true,}
    else
        state = {[MODIFIER_STATE_INVISIBLE] = false,
                 [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
             [MODIFIER_STATE_NO_HEALTH_BAR] = true,}
    end

    return state
end

LinkLuaModifier( "modifier_puchkov_small_debils", "abilities/heroes/puchkov", LUA_MODIFIER_MOTION_NONE)

puchkov_small_debils = class({}) 

function puchkov_small_debils:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function puchkov_small_debils:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function puchkov_small_debils:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function puchkov_small_debils:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    if target:TriggerSpellAbsorb(self) then return end
    self:GetCaster():EmitSound("Hero_ArcWarden.Flux.Cast")
    target:EmitSound("Hero_ArcWarden.Flux.Target")
    self:GetCaster():EmitSound("PuchkovDebil")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
    target:AddNewModifier(self:GetCaster(), self, "modifier_puchkov_small_debils", {duration = duration})
end

modifier_puchkov_small_debils = class({})

function modifier_puchkov_small_debils:IsPurgable()
    return true
end

function modifier_puchkov_small_debils:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.particle, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.particle, false, false, -1, false, false)
    ParticleManager:SetParticleControl(self.particle, 4, Vector(1, 0, 0))
    self:OnIntervalThink()
    self:StartIntervalThink(0.5)
end

function modifier_puchkov_small_debils:OnIntervalThink()
    local damage = self:GetAbility():GetSpecialValueFor("damage") * 0.5
    ApplyDamage({ victim = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, attacker = self:GetCaster(), ability = self:GetAbility() })
end

function modifier_puchkov_small_debils:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE

    }

    return decFuncs
end

function modifier_puchkov_small_debils:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("reduce_movement_speed")
end

function modifier_puchkov_small_debils:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_puchkov_small_debils:GetModifierModelScale()
    return -50
end

LinkLuaModifier( "modifier_puchkov_smeh_thinker", "abilities/heroes/puchkov", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_puchkov_smeh_thinker_vision", "abilities/heroes/puchkov", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_generic_custom_indicator", "abilities/heroes/puchkov", LUA_MODIFIER_MOTION_NONE)

puchkov_smeh = class({}) 

function puchkov_smeh:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_puchkov_3")
end

function puchkov_smeh:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function puchkov_smeh:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function puchkov_smeh:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end



function puchkov_smeh:GetIntrinsicModifierName()
    return "modifier_generic_custom_indicator"
end

function puchkov_smeh:CastFilterResultLocation( vLoc )
    if IsClient() then
        if self.custom_indicator then
            self.custom_indicator:Register( vLoc )
        end
    end

    return UF_SUCCESS
end

function puchkov_smeh:CreateCustomIndicator()
    local particle_cast = "particles/units/heroes/hero_dark_willow/dark_willow_bramble_range_finder_aoe.vpcf"
    local radius = self:GetSpecialValueFor( "radius" )
    self.effect_indicator = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl( self.effect_indicator, 1, Vector( radius, radius, radius ) )
end

function puchkov_smeh:UpdateCustomIndicator( loc )
    local radius = self:GetSpecialValueFor( "radius" )
    local delay = self:GetSpecialValueFor( "delay" )
    local r = radius
    local c = math.sqrt( 2 ) * 0.5 * r 
    local x_offset = { -r, -c, 0.0, c, r, c, 0.0, -c }
    local y_offset = { 0.0, c, r, c, 0.0, -c, -r, -c }
    ParticleManager:SetParticleControl( self.effect_indicator, 0, loc )
    ParticleManager:SetParticleControl( self.effect_indicator, 2, loc + Vector( x_offset[1], y_offset[1], 0.0 ) )
    ParticleManager:SetParticleControl( self.effect_indicator, 3, loc + Vector( x_offset[2], y_offset[2], 0.0 ) )
    ParticleManager:SetParticleControl( self.effect_indicator, 4, loc + Vector( x_offset[3], y_offset[3], 0.0 ) )
    ParticleManager:SetParticleControl( self.effect_indicator, 5, loc + Vector( x_offset[4], y_offset[4], 0.0 ) )
    ParticleManager:SetParticleControl( self.effect_indicator, 6, loc + Vector( x_offset[5], y_offset[5], 0.0 ) )
    ParticleManager:SetParticleControl( self.effect_indicator, 7, loc + Vector( x_offset[6], y_offset[6], 0.0 ) )
    ParticleManager:SetParticleControl( self.effect_indicator, 8, loc + Vector( x_offset[7], y_offset[7], 0.0 ) )
    ParticleManager:SetParticleControl( self.effect_indicator, 9, loc + Vector( x_offset[8], y_offset[8], 0.0 ) )
end

function puchkov_smeh:DestroyCustomIndicator()
    ParticleManager:DestroyParticle( self.effect_indicator, false )
    ParticleManager:ReleaseParticleIndex( self.effect_indicator )
end


















function puchkov_smeh:OnSpellStart()
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor( "radius" )
    local delay = self:GetSpecialValueFor( "delay" )
    local r = radius
    local c = math.sqrt( 2 ) * 0.5 * r 
    local x_offset = { -r, -c, 0.0, c, r, c, 0.0, -c }
    local y_offset = { 0.0, c, r, c, 0.0, -c, -r, -c }
    self:GetCaster():EmitSound("PuchkovSmeh")
    for i = 1,8 do
        CreateModifierThinker( self:GetCaster(), self, "modifier_puchkov_smeh_thinker", { duration = delay }, point + Vector( x_offset[i], y_offset[i], 0.0 ), self:GetCaster():GetTeamNumber(), false )
    end
end

modifier_puchkov_smeh_thinker = class({})

function modifier_puchkov_smeh_thinker:IsPurgable()
    return false
end

function modifier_puchkov_smeh_thinker:IsHidden()
    return true
end

function modifier_puchkov_smeh_thinker:OnCreated( kv )
    if not IsServer() then return end
    local radius_boom = self:GetAbility():GetSpecialValueFor( "radius_boom" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_puchkov_1")
    self.particle = ParticleManager:CreateParticle( "particles/puchkov/smeh_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin()) 
    ParticleManager:SetParticleControl(self.particle, 1, Vector(radius_boom*2, 0, 0))
    ParticleManager:ReleaseParticleIndex(self.particle)
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_puchkov_smeh_thinker:OnRemoved()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    local radius_boom = self:GetAbility():GetSpecialValueFor( "radius_boom" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_puchkov_1")
    local duration = self:GetAbility():GetSpecialValueFor( "duration" )
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_aoe.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin()) 
    ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius_boom, radius_boom, radius_boom ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    local damage = self:GetAbility():GetSpecialValueFor("damage")
        local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        radius_boom,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        0,
        false
    )

    for _,enemy in pairs(enemies) do
        ApplyDamage({ victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, attacker = self:GetCaster(), ability = self:GetAbility() })
    end
    CreateModifierThinker( self:GetCaster(), self:GetAbility(), "modifier_puchkov_smeh_thinker_vision", { duration = duration }, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false )
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), radius_boom, duration, false)
    EmitSoundOn( "Hero_Grimstroke.InkSwell.Stun", self:GetParent() )
end

modifier_puchkov_smeh_thinker_vision = class({})

function modifier_puchkov_smeh_thinker_vision:IsPurgable()
    return false
end

function modifier_puchkov_smeh_thinker_vision:IsHidden()
    return true
end

function modifier_puchkov_smeh_thinker_vision:IsAura()
    return true
end

function modifier_puchkov_smeh_thinker_vision:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor( "radius_boom" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_puchkov_1")
end

function modifier_puchkov_smeh_thinker_vision:GetModifierAura()
    return "modifier_truesight"
end
   
function modifier_puchkov_smeh_thinker_vision:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_puchkov_smeh_thinker_vision:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_puchkov_smeh_thinker_vision:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_puchkov_smeh_thinker_vision:GetAuraDuration()
    return 0.1
end

LinkLuaModifier( "modifier_puchkov_shiza", "abilities/heroes/puchkov", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_puchkov_shiza_thinker", "abilities/heroes/puchkov", LUA_MODIFIER_MOTION_NONE)

puchkov_shiza = class({}) 

function puchkov_shiza:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function puchkov_shiza:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function puchkov_shiza:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function puchkov_shiza:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function puchkov_shiza:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")

    local center = CreateModifierThinker( self:GetCaster(), self, "modifier_puchkov_shiza_thinker", { duration = duration }, point, self:GetCaster():GetTeamNumber(), false )

    local enemies = FindUnitsInRadius( caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )

    for _,enemy in pairs(enemies) do
        local modifier = enemy:AddNewModifier( caster, self, "modifier_puchkov_shiza", { duration = duration, coil_x = point.x, coil_y = point.y, coil_z = point.z, } )
    end
    EmitSoundOnLocationWithCaster( point, "Hero_Puck.Dream_Coil", self:GetCaster() )
    EmitSoundOnLocationWithCaster( point, "PuchkovUltimate", self:GetCaster() )
end

modifier_puchkov_shiza_thinker = class({})

function modifier_puchkov_shiza_thinker:IsHidden()
    return false
end

function modifier_puchkov_shiza_thinker:IsPurgable()
    return false
end

function modifier_puchkov_shiza_thinker:OnCreated( kv )
    if IsServer() then
        self:PlayEffects()
    end
end

function modifier_puchkov_shiza_thinker:OnDestroy( kv )
    if IsServer() then
        ParticleManager:DestroyParticle( self.effect_cast, false )
        ParticleManager:ReleaseParticleIndex( self.effect_cast )
        UTIL_Remove( self:GetParent() )
    end
end

function modifier_puchkov_shiza_thinker:PlayEffects()
    self.effect_cast = ParticleManager:CreateParticle( "particles/puchkov/puchkov_ultimate.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
end

modifier_puchkov_shiza = class({})

function modifier_puchkov_shiza:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_puchkov_shiza:IsPurgable()
    return false
end

function modifier_puchkov_shiza:OnCreated( kv )
    self.center = Vector( kv.coil_x, kv.coil_y, kv.coil_z )
    if IsServer() then
        self:PlayEffects()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_puchkov_shiza:OnIntervalThink()
    for i=0,5 do
        for p=0,5 do
            self:GetParent():SwapItems(i, p)
        end
    end
end

function modifier_puchkov_shiza:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_UNIT_MOVED,
    }

    return funcs
end

function modifier_puchkov_shiza:OnUnitMoved( params )
    if IsServer() then
        if params.unit~=self:GetParent() then
            return
        end
        local radius = self:GetAbility():GetSpecialValueFor("radius")
        local damage = self:GetAbility():GetSpecialValueFor("damage")
        local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_puchkov_2")

        if (params.new_pos-self.center):Length2D()>radius then
            local damageTable = {
                victim = self:GetParent(),
                attacker = self:GetCaster(),
                damage = damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self:GetAbility(),
            }
            ApplyDamage(damageTable)

            self:GetParent():AddNewModifier(
                self:GetCaster(),
                self:GetAbility(),
                "modifier_birzha_stunned",
                { duration = stun_duration }
            )
            EmitSoundOn( "Hero_Puck.Dream_Coil_Snap", self:GetParent() )
            self:Destroy()
        end
    end
end

function modifier_puchkov_shiza:PlayEffects()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_puck/puck_dreamcoil_tether.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 0, self.center )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        1,
        self:GetParent(),
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        self:GetParent():GetOrigin(),
        true
    )

    self:AddParticle(
        effect_cast,
        false,
        false,
        -1,
        false,
        false
    )
end

modifier_generic_custom_indicator = class({})

function modifier_generic_custom_indicator:IsHidden()
    return true
end

function modifier_generic_custom_indicator:IsPurgable()
    return true
end

function modifier_generic_custom_indicator:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_generic_custom_indicator:OnCreated( kv )
    if IsServer() then return end
    self:GetAbility().custom_indicator = self
end

function modifier_generic_custom_indicator:OnIntervalThink()
    if IsClient() then
        self:StartIntervalThink(-1)
        local ability = self:GetAbility()
        if self.init and ability.DestroyCustomIndicator then
            self.init = nil
            ability:DestroyCustomIndicator()
        end
    end
end

function modifier_generic_custom_indicator:Register( loc )
    local ability = self:GetAbility()
    if (not self.init) and ability.CreateCustomIndicator then
        self.init = true
        ability:CreateCustomIndicator()
    end
    if ability.UpdateCustomIndicator then
        ability:UpdateCustomIndicator( loc )
    end
    self:StartIntervalThink( 0.05 )
end