LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_face_ShopGucci", "abilities/heroes/face.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_face_ShopGucci_debuff", "abilities/heroes/face.lua", LUA_MODIFIER_MOTION_NONE)

Face_ShopGucci = class({})

function Face_ShopGucci:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Face_ShopGucci:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Face_ShopGucci:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    ParticleManager:CreateParticle( "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    self:GetCaster():EmitSound("face1")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_face_ShopGucci", { duration = duration } )
end

modifier_face_ShopGucci = class({})

function modifier_face_ShopGucci:IsPurgable()
    return true
end

function modifier_face_ShopGucci:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink( 0.1 )
end


function modifier_face_ShopGucci:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }

    return funcs
end

function modifier_face_ShopGucci:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_speed")
end

function modifier_face_ShopGucci:GetModifierMoveSpeed_Absolute()
    if not self:GetCaster():HasScepter() then return end
    return self:GetAbility():GetSpecialValueFor("scepter_speed")
end


function modifier_face_ShopGucci:GetModifierModelChange()
    return "models/heroes/nightstalker/nightstalker_night.vmdl"
end

function modifier_face_ShopGucci:CheckState()
    local funcs = 
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return funcs
end

function modifier_face_ShopGucci:OnIntervalThink()
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )

    local target = nil
    for _,enemy in pairs(enemies) do
        if not enemy:HasModifier("modifier_face_ShopGucci_debuff") then
            target = enemy
        end
    end

    if target then
        target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_face_ShopGucci_debuff", { duration = 1 } )
    end
end

modifier_face_ShopGucci_debuff = class({})

function modifier_face_ShopGucci_debuff:IsHidden()
    return true
end

function modifier_face_ShopGucci_debuff:IsPurgable()
    return false
end

function modifier_face_ShopGucci_debuff:OnCreated()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_face_2")
    local end_damage = damage + (self:GetCaster():GetStrength() * self:GetAbility():GetSpecialValueFor("str_multi"))
    local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")

    local knockback =
    {
        knockback_duration = stun_duration * (1 - self:GetParent():GetStatusResistance()),
        duration = stun_duration * (1 - self:GetParent():GetStatusResistance()),
        knockback_distance = 2,
        knockback_height = 25,
    }

    if self:GetParent():HasModifier("modifier_knockback") then
        self:GetParent():RemoveModifierByName("modifier_knockback")
    end

    ApplyDamage( { victim = self:GetParent(), attacker = self:GetCaster(), damage = end_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() } )

    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_knockback", knockback)
end

LinkLuaModifier("modifier_face_hate_debuff", "abilities/heroes/face.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_face_hate_buff", "abilities/heroes/face.lua", LUA_MODIFIER_MOTION_NONE)

Face_Hate = class({})

function Face_Hate:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Face_Hate:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_face_1")
end

function Face_Hate:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function Face_Hate:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Face_Hate:OnSpellStart()
    self:StartHate(self:GetCaster())
end

function Face_Hate:StartHate(caster)
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_face_5")
    if not IsServer() then return end
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
    caster:EmitSound("face2")
    for _,enemy in pairs(enemies) do
        if not enemy:IsDuel() then
            enemy:AddNewModifier( caster, self, "modifier_face_hate_debuff", { duration = duration } )
        end
    end
    if #enemies > 0 then
        caster:AddNewModifier( caster, self, "modifier_face_hate_buff", { duration = duration } )
    end
    local particle = ParticleManager:CreateParticle( "particles/face/1.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
    ParticleManager:SetParticleControlEnt( particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:ReleaseParticleIndex( particle )
end

modifier_face_hate_debuff = class({})

function modifier_face_hate_debuff:IsPurgable()
    return false
end

function modifier_face_hate_debuff:OnCreated( kv )
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( self:GetCaster() )
    self:GetParent():MoveToTargetToAttack( self:GetCaster() )
    self:StartIntervalThink(FrameTime())
end

function modifier_face_hate_debuff:OnIntervalThink( kv )
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_fountain_passive_invul") or (not self:GetCaster():IsAlive()) then
        if not self:IsNull() then
            self:Destroy()
        end
    else
        self:GetParent():SetForceAttackTarget( self:GetCaster() )
        self:GetParent():MoveToTargetToAttack( self:GetCaster() )
    end
end

function modifier_face_hate_debuff:OnRemoved()
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( nil )
end

function modifier_face_hate_debuff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_TAUNTED] = true,
    }
    return state
end

function modifier_face_hate_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function modifier_face_hate_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }

    return funcs
end

function modifier_face_hate_debuff:GetModifierDamageOutgoing_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_face_3")
end


modifier_face_hate_buff = class({})

function modifier_face_hate_buff:IsPurgable()
    return false
end

function modifier_face_hate_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }

    return funcs
end

function modifier_face_hate_buff:OnTakeDamage( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        self:GetParent():Heal(params.damage*2, self:GetAbility())
    end
end

LinkLuaModifier("modifier_face_tombstone", "abilities/heroes/face.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_birzha_undying_tombstone_zombie_modifier", "abilities/heroes/face.lua", LUA_MODIFIER_MOTION_NONE)

face_tombstone = class({})

function face_tombstone:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function face_tombstone:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function face_tombstone:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function face_tombstone:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function face_tombstone:OnSpellStart()
    if not IsServer() then return end
    local Tombstone = CreateUnitByName( "npc_dota_face_tombstone", self:GetCursorPosition(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
    if Tombstone ~= nil then
        Tombstone:SetMinimumGoldBounty(200)
        local duration = self:GetSpecialValueFor( "duration" )
        Tombstone:AddNewModifier( self:GetCaster(), self, "modifier_face_tombstone", { duration = duration } )
        Tombstone:AddNewModifier( self:GetCaster(), self, "modifier_kill", { duration = duration } )
        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_undying/undying_tombstone.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( particle, 0, self:GetCursorPosition() ) 
        ParticleManager:SetParticleControlEnt( particle, 1, self:GetCaster(), duration, "attach_attack1", self:GetCaster():GetOrigin(), true )
        ParticleManager:SetParticleControl( particle, 2, Vector( duration, duration, duration ) )
        ParticleManager:ReleaseParticleIndex( particle )
        Tombstone:EmitSound("Hero_Undying.Tombstone")
        local Face_Hate = self:GetCaster():FindAbilityByName("Face_Hate")
        if Face_Hate and Face_Hate:GetLevel() > 0 and self:GetCaster():HasTalent("special_bonus_birzha_face_8") then
            Face_Hate:StartHate(Tombstone)
        end
    end
end

modifier_face_tombstone = class({})

function modifier_face_tombstone:IsHidden()
    return true
end

function modifier_face_tombstone:IsPurgable()
    return false
end

function modifier_face_tombstone:CheckState()
    local state =
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
    return state
end

function modifier_face_tombstone:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
    return decFuncs
end

function modifier_face_tombstone:GetDisableHealing()
    return 1
end

function modifier_face_tombstone:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_face_tombstone:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_face_tombstone:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_face_tombstone:GetModifierHealthBarPips()
    return self:GetAbility():GetSpecialValueFor( "tombstone_health" )
end

function modifier_face_tombstone:OnAttackLanded(keys)
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        if self:GetCaster():HasTalent("special_bonus_birzha_face_8") then return end
        self.health = self.health - 1
        if self.health <= 0 then
            self:GetParent():Kill(nil, keys.attacker)
        else
            self:GetParent():SetHealth(self.health)
        end
    end
end

function modifier_face_tombstone:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.health = self:GetAbility():GetSpecialValueFor( "tombstone_health" )
    self.zombie_interval = self:GetAbility():GetSpecialValueFor( "zombie_interval" )
    self:GetParent():SetBaseMaxHealth(self.health)
    self:StartIntervalThink( self.zombie_interval )
end

function modifier_face_tombstone:OnDestroy()
    if not IsServer() then return end
    local zombies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    for _,zombie in pairs( zombies ) do
        if zombie:GetUnitName() == "npc_dota_face_zombie" then
            zombie:ForceKill(false)
        end
    end
end

function modifier_face_tombstone:OnIntervalThink()
    if not IsServer() then return end
    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    for _,enemy in pairs( enemies ) do
        if enemy ~= nil and enemy:IsAlive() then
            local Zombie = CreateUnitByName( "npc_dota_face_zombie", enemy:GetOrigin() + RandomVector( 50 ), true, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber() )
            ParticleManager:ReleaseParticleIndex( ParticleManager:CreateParticle( "particles/neutral_fx/skeleton_spawn.vpcf", PATTACH_ABSORIGIN, Zombie ) )
            Zombie:FindAbilityByName( "undying_tombstone_zombie_deathstrike" ):SetLevel(self:GetAbility():GetLevel())
            Zombie:SetAggroTarget(enemy)
            Zombie:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_undying_tombstone_zombie_modifier", {enemy_entindex = enemy:entindex()})
            Zombie:SetBaseDamageMax(Zombie:GetBaseDamageMax() + (self:GetCaster():GetStrength() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_face_6")) )
            Zombie:SetBaseDamageMax(Zombie:GetBaseDamageMax() + (self:GetCaster():GetStrength() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_face_6")) )
        end
    end
end

modifier_birzha_undying_tombstone_zombie_modifier = class({})

function modifier_birzha_undying_tombstone_zombie_modifier:IsPurgable()   return false end
function modifier_birzha_undying_tombstone_zombie_modifier:IsHidden()   return true end

function modifier_birzha_undying_tombstone_zombie_modifier:OnCreated(keys)
    if not IsServer() then return end
    self.aggro_target = EntIndexToHScript(keys.enemy_entindex)
    self:StartIntervalThink(FrameTime())
end

function modifier_birzha_undying_tombstone_zombie_modifier:OnIntervalThink()
    if IsServer() then
        if not self.aggro_target:IsAlive() or self.aggro_target == nil then
            self:GetParent():Kill(nil, self:GetParent())
        end
        if not self:GetParent():CanEntityBeSeenByMyTeam(self.aggro_target) then
            ExecuteOrderFromTable({
                UnitIndex   = self:GetParent():entindex(),
                OrderType   = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position    = self.aggro_target:GetAbsOrigin()
            })
        elseif self:GetParent():GetAggroTarget() ~= self.aggro_target then
            ExecuteOrderFromTable({
                UnitIndex   = self:GetParent():entindex(),
                OrderType   = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = self.aggro_target
            })
        end
    end
end











LinkLuaModifier("modifier_face_esketit", "abilities/heroes/face.lua", LUA_MODIFIER_MOTION_NONE)

face_esketit = class({})

function face_esketit:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function face_esketit:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function face_esketit:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function face_esketit:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_howl_cast.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0 , caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1 , caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 2 , caster:GetAbsOrigin())

    local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false )
    EmitGlobalSound("faceeskatit")

    for _, ally in pairs(allies) do
        ally:AddNewModifier(caster, self, "modifier_face_esketit", {duration = duration})   
    end
end

modifier_face_esketit = class({})

function modifier_face_esketit:IsPurgable()
    return true
end

function modifier_face_esketit:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
end

function modifier_face_esketit:OnIntervalThink()
    if not IsServer() then return end
    if self:GetCaster():HasScepter() then
        self:GetParent():Heal(self:GetParent():GetMaxHealth() / 100 * self:GetAbility():GetSpecialValueFor("scepter_regen"), self:GetAbility())
    end
end

function modifier_face_esketit:GetEffectName()
    return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
end

function modifier_face_esketit:DeclareFunctions()     
    local decFuncs =    
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }       
    return decFuncs         
end

function modifier_face_esketit:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_face_esketit:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_face_esketit:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("hp_regen")
end

LinkLuaModifier("modifier_face_newsong", "abilities/heroes/face.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_face_newsong_shard", "abilities/heroes/face.lua", LUA_MODIFIER_MOTION_NONE)

Face_NewSong = class({})

function Face_NewSong:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_face_7")
end

function Face_NewSong:GetIntrinsicModifierName()
    return "modifier_face_newsong_shard"
end

function Face_NewSong:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Face_NewSong:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Face_NewSong:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("faceult")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_face_newsong", {duration = duration}) 
end

modifier_face_newsong_shard = class({})

function modifier_face_newsong_shard:IsPurgable() return false end
function modifier_face_newsong_shard:IsHidden() return true end

function modifier_face_newsong_shard:OnCreated()
    if not IsServer() then return end
    self.prevLoc = self:GetParent():GetAbsOrigin()
    self.move_range = 0
    self:StartIntervalThink( FrameTime() )
end

function modifier_face_newsong_shard:OnIntervalThink()
    if not IsServer() then return end
    if self:GetCaster():HasShard() then
        self.move_range = self.move_range + CalculateDistance(self.prevLoc, self:GetParent())
        if self.move_range >= 700 then
            self:Knock()
            self.move_range = 0
        end
        self.prevLoc = self:GetParent():GetAbsOrigin()
    end
end

function modifier_face_newsong_shard:Knock()
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    damage = damage + (self:GetCaster():GetStrength() * self:GetAbility():GetSpecialValueFor("str_multi"))
    if self:GetParent():HasScepter() then self.radius = 900 else self.radius = 700 end
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, 1))
    ParticleManager:ReleaseParticleIndex(particle)

    local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)

    for _,unit in pairs(targets) do
        ApplyDamage({victim = unit, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})

        local distance = (unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
        local direction = (unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
        local bump_point = self:GetParent():GetAbsOrigin() + direction * (distance + 150)

        local knockbackProperties =
        {
             center_x = bump_point.x,
             center_y = bump_point.y,
             center_z = bump_point.z,
             duration = 0.1,
             knockback_duration = 0.1,
             knockback_distance = 0,
             knockback_height = 50
        }
     
        if unit:HasModifier("modifier_knockback") then
            unit:RemoveModifierByName("modifier_knockback")
        end
        unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_knockback", knockbackProperties)
    end
end















modifier_face_newsong = class({})

function modifier_face_newsong:IsPurgable()
    return false
end

function modifier_face_newsong:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("faceult")
end

function modifier_face_newsong:OnCreated()
    if not IsServer() then return end
    self.prevLoc = self:GetParent():GetAbsOrigin()
    self.move_range = 0
    self:StartIntervalThink( 0.25 )
end

function modifier_face_newsong:OnIntervalThink()
    if not IsServer() then return end
    self:Knock()
end

function modifier_face_newsong:Knock()
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_face_4")
    damage = damage + (self:GetCaster():GetStrength() * self:GetAbility():GetSpecialValueFor("str_multi"))
    if self:GetParent():HasScepter() then self.radius = 900 else self.radius = 700 end
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, 1))
    ParticleManager:ReleaseParticleIndex(particle)

    local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)

    for _,unit in pairs(targets) do
        ApplyDamage({victim = unit, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})

        local distance = (unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
        local direction = (unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
        local bump_point = self:GetParent():GetAbsOrigin() + direction * (distance + 150)

        local knockbackProperties =
        {
             center_x = bump_point.x,
             center_y = bump_point.y,
             center_z = bump_point.z,
             duration = 0.1,
             knockback_duration = 0.1,
             knockback_distance = 0,
             knockback_height = 50
        }
     
        if unit:HasModifier("modifier_knockback") then
            unit:RemoveModifierByName("modifier_knockback")
        end
        unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_knockback", knockbackProperties)
    end
end