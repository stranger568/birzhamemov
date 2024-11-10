LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_Knuckles_army", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)

Knuckles_army = class({})

function Knuckles_army:GetIntrinsicModifierName()
    return "modifier_Knuckles_army"
end

function Knuckles_army:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function Knuckles_army:GetCooldown(level)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_cooldown")
    end
end

function Knuckles_army:GetManaCost(level)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_manacost")
    end
end

function Knuckles_army:OnSpellStart()
    if not IsServer() then return end

    local modifier = self:GetCaster():FindModifierByName("modifier_Knuckles_army")
    local max_illusions = self:GetSpecialValueFor("max_illusions") + self:GetSpecialValueFor("scepter_bonus_illusions") + self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_6")
    local illusion_duration = self:GetSpecialValueFor("illusion_duration") + self:GetSpecialValueFor("scepter_bonus_duration")
    local illusion_damage_out_pct = (self:GetSpecialValueFor("illusion_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_4")) - 100
    local illusion_damage_in_pct = self:GetSpecialValueFor("illusion_damage_in_pct") - 100

    if modifier then
        for ill = #modifier.owner.juxtapose_table, 1, -1 do
            local illusion_entity = EntIndexToHScript(modifier.owner.juxtapose_table[ill])
            if illusion_entity then
                illusion_entity:ForceKill(false)
            end
            table.remove(modifier.owner.juxtapose_table, ill)
        end

        local Knuckles_GetInTheTank = self:GetCaster():FindAbilityByName("Knuckles_GetInTheTank")

        for i = 1, max_illusions do
            local illusions = BirzhaCreateIllusion(modifier.owner, self:GetCaster(), 
            {
                outgoing_damage = illusion_damage_out_pct,
                incoming_damage = illusion_damage_in_pct,
                bounty_base     = 5,
                bounty_growth   = 0,
                outgoing_damage_structure   = 0,
                outgoing_damage_roshan      = 0,
                duration        = illusion_duration
            }
            , 1, 72, false, true)
            
            for _, illusion in pairs(illusions) do
                self.spawn_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_spawn_illusion.vpcf", PATTACH_ABSORIGIN_FOLLOW, illusion)
                ParticleManager:SetParticleControlEnt(self.spawn_particle, 0, illusion, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", illusion:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(self.spawn_particle, 1, illusion, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", illusion:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(self.spawn_particle)
                illusion:AddNewModifier(self:GetCaster(), self, "modifier_phantom_lancer_juxtapose_illusion", {})
                illusion:MoveToPositionAggressive(illusion:GetAbsOrigin())
                illusion:SetMinimumGoldBounty(5)
                illusion:SetMaximumGoldBounty(5)
                table.insert(modifier.owner.juxtapose_table, illusion:entindex())
                if Knuckles_GetInTheTank then
                    Knuckles_GetInTheTank:IllusionAbuse(illusion)
                end
            end
        end
    end
end

modifier_Knuckles_army = class({})

function modifier_Knuckles_army:IsHidden() return true end
function modifier_Knuckles_army:IsPurgable() return false end

function modifier_Knuckles_army:OnCreated()
    self.duration = 0
    
    self.directional_vectors = 
    {
        Vector(72, 0, 0),
        Vector(0, -72, 0),
        Vector(-72, 0, 0),
        Vector(0, 72, 0)
    }
    
    if not IsServer() then return end
    
    if self:GetParent():IsRealHero() then
        self.owner = self:GetParent()
        
        self.owner.juxtapose_table = {}
    elseif not self:GetParent():IsRealHero() and self:GetParent():GetOwner() and self:GetParent():GetOwner():GetAssignedHero() then
        self.owner = self:GetParent():GetOwner():GetAssignedHero()
    end
end

function modifier_Knuckles_army:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_DEATH
    }
end

function modifier_Knuckles_army:OnAttackLanded(keys)
    if keys.attacker == self:GetParent() and not self:GetParent():PassivesDisabled() and not keys.target:IsBuilding() and self.owner and self.owner.juxtapose_table and not self.owner:PassivesDisabled() then

        if keys.no_attack_cooldown then return end
        if self:GetParent():IsIllusion() then return end

        if self:GetParent():IsRealHero() and RollPercentage(self:GetAbility():GetSpecialValueFor("proc_chance_pct")) then
            self.duration = self:GetAbility():GetSpecialValueFor("illusion_duration")
        elseif not self:GetParent():IsRealHero() and RollPercentage(self:GetAbility():GetSpecialValueFor("illusion_proc_chance_pct")) then
            self.duration = self:GetAbility():GetSpecialValueFor("illusion_from_illusion_duration")
        end

        local max_illusions = self:GetAbility():GetSpecialValueFor("max_illusions") + self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_6")

        if self:GetParent():HasScepter() then
            self.duration = self.duration + 10
            max_illusions = max_illusions + 1
        end

        local Knuckles_GetInTheTank = self:GetCaster():FindAbilityByName("Knuckles_GetInTheTank")
        
        for ill = #self.owner.juxtapose_table, 1, -1 do
            local illusion_entity = EntIndexToHScript(self.owner.juxtapose_table[ill])
            if illusion_entity == nil or (illusion_entity and illusion_entity:IsNull()) or (illusion_entity and not illusion_entity:IsAlive()) then
                table.remove(self.owner.juxtapose_table, ill)
            end
        end

        if #(self.owner.juxtapose_table) < max_illusions and self.duration > 0 and self.owner.juxtapose_table then
            
            local illusions = BirzhaCreateIllusion(self.owner, self:GetParent(), 
            {
                outgoing_damage = (self:GetAbility():GetSpecialValueFor("illusion_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_4")) - 100,
                incoming_damage = self:GetAbility():GetSpecialValueFor("illusion_damage_in_pct") - 100,
                bounty_base     = 5,
                bounty_growth   = 0,
                outgoing_damage_structure   = 0,
                outgoing_damage_roshan      = 0,
                duration        = self.duration
            }
            , 1, 72, false, true)
            
            for _, illusion in pairs(illusions) do
                self.spawn_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_spawn_illusion.vpcf", PATTACH_ABSORIGIN_FOLLOW, illusion)
                ParticleManager:SetParticleControlEnt(self.spawn_particle, 0, illusion, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", illusion:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(self.spawn_particle, 1, illusion, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", illusion:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(self.spawn_particle)
            
                illusion:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_phantom_lancer_juxtapose_illusion", {})
                illusion:SetAggroTarget(keys.target)

                illusion:SetMinimumGoldBounty(5)
                illusion:SetMaximumGoldBounty(5)
                
                table.insert(self.owner.juxtapose_table, illusion:entindex())

                if Knuckles_GetInTheTank then
                    Knuckles_GetInTheTank:IllusionAbuse(illusion)
                end
            end
        end
        self.duration = 0
    end
end

function modifier_Knuckles_army:OnDeath(keys)
    if keys.unit == self:GetParent() and self.owner and not self.owner:IsNull() and self.owner.juxtapose_table then
        Custom_ArrayRemove(self.owner.juxtapose_table, function(i, j)
            return self.owner.juxtapose_table[i] ~= self:GetParent():entindex()
        end)
    end
end

function Custom_ArrayRemove(t, fnKeep)
    local j, n = 1, #t;

    for i=1,n do
        if (fnKeep(i, j)) then
            if (i ~= j) then
                t[j] = t[i];
                t[i] = nil;
            end
            j = j + 1;
        else
            t[i] = nil;
        end
    end

    return t;
end

LinkLuaModifier( "modifier_Knuckles_Spit", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_knuckles_spit_debuff", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)

Knuckles_Spit = class({}) 

function Knuckles_Spit:GetIntrinsicModifierName()
    return "modifier_Knuckles_Spit"
end

modifier_Knuckles_Spit = class({}) 

function modifier_Knuckles_Spit:IsHidden()      return true end
function modifier_Knuckles_Spit:IsPurgable()    return false end

function modifier_Knuckles_Spit:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_Knuckles_Spit:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:PassivesDisabled() then return end
    if params.target:IsWard() then return end

    local chance = self:GetAbility():GetSpecialValueFor('chance') + self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_2")
    local duration = self:GetAbility():GetSpecialValueFor('duration')    

    if RollPercentage(chance) then        
        params.attacker:EmitSound("ugandaplevok")
        params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_knuckles_spit_debuff", {duration = duration * (1-params.target:GetStatusResistance()) })
        if self:GetCaster():HasTalent("special_bonus_birzha_knuckles_5") then
            local modifier_knuckles_spit_debuff = params.target:FindModifierByName("modifier_knuckles_spit_debuff")
            if modifier_knuckles_spit_debuff then
                if modifier_knuckles_spit_debuff:GetStackCount() < self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_5") then
                    modifier_knuckles_spit_debuff:IncrementStackCount()
                end
            end
        end
    end
end

modifier_knuckles_spit_debuff = class({}) 

function modifier_knuckles_spit_debuff:OnCreated()
   if not IsServer() then return end
   self:StartIntervalThink(1)
   self:SetStackCount(1)
end

function modifier_knuckles_spit_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor('damage') + self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_3")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage * self:GetStackCount(), damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_knuckles_spit_debuff:IsPurgable() return true end

function modifier_knuckles_spit_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_knuckles_spit_debuff:GetModifierMoveSpeedBonus_Percentage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('movespeed_slow')
    end
end

Knuckles_queens = class({}) 

function Knuckles_queens:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Knuckles_queens:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

LinkLuaModifier("modifier_heal_uganda_aura", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)

function Knuckles_queens:OnSpellStart()
    if not IsServer() then return end
    local Quuens = 
    {
        "npc_knuckles_crystal_maiden",
        "npc_knuckles_lina",
        "npc_knuckles_windrunner"
    }
    local duration = self:GetSpecialValueFor('duration')
    local quuen_random = Quuens[RandomInt(1, #Quuens)]
    self:GetCaster():EmitSound("queen")
    local queen = CreateUnitByName(quuen_random, self:GetCaster():GetAbsOrigin() + RandomVector(600), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
    queen:SetControllableByPlayer( self:GetCaster():GetPlayerOwnerID(), true )
    queen:SetOwner(self:GetCaster())
    queen:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    queen:AddNewModifier(self:GetCaster(), self, "modifier_heal_uganda_aura", {duration = duration})
end

modifier_heal_uganda_aura = class({})

function modifier_heal_uganda_aura:IsHidden()
    return true
end

function modifier_heal_uganda_aura:IsPurgeException() return false end
function modifier_heal_uganda_aura:IsPurgable() return false end

function modifier_heal_uganda_aura:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
    }
end

function modifier_heal_uganda_aura:OnCreated()
    if not IsServer() then return end
    self:GetParent():SetBaseMaxHealth(5)
    self:GetParent():SetMaxHealth(5)
    self:GetParent():SetHealth(5)
end

function modifier_heal_uganda_aura:GetModifierHealthBarPips()
    return 5
end

function modifier_heal_uganda_aura:GetDisableHealing()
    return 1
end

function modifier_heal_uganda_aura:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_heal_uganda_aura:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_heal_uganda_aura:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_heal_uganda_aura:OnAttacked(keys)
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        local new_health = self:GetParent():GetHealth() - 1
        if keys.attacker:IsRealHero() then
            new_health = self:GetParent():GetHealth() - 1
        end
        if new_health <= 0 then
            self:GetParent():Kill(nil, keys.attacker)
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

function modifier_heal_uganda_aura:OnDeath(keys)
    if not IsServer() then return end
    local target = keys.unit
    if target == self:GetParent() then 
        local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

        for _,unit in pairs(units) do
            local heal = unit:GetMaxHealth() / 100 * (self:GetAbility():GetSpecialValueFor("heal") + self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_1"))
            unit:Heal(heal, self:GetAbility())
        end
    end
end

powershot_uganda = class({})

function powershot_uganda:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function powershot_uganda:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function powershot_uganda:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function powershot_uganda:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition() + 5
    local caster_loc = caster:GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,caster)
    local direction = (target_loc - caster_loc):Normalized()
    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("bow_mid"))
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/econ/items/windrunner/windrunner_weapon_rainmaker/windrunner_spell_powershot_rainmaker.vpcf",
        vSpawnOrigin        = point,
        fDistance           = 1300,
        fStartRadius        = 125,
        fEndRadius          = 250,
        Source              = caster,
        bHasFrontalCone     = true,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 1600,
        iVisionRadius =     100,
        bProvidesVision     = true,
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    projectile.vVelocity = Vector(direction.x,direction.y,0) * 1200
    projectile.EffectName = "particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_ti6.vpcf"
    ProjectileManager:CreateLinearProjectile(projectile)
    projectile.vVelocity = Vector(direction.x,direction.y,0) * 800
    projectile.EffectName = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf"
    ProjectileManager:CreateLinearProjectile(projectile)
    caster:EmitSound("Ability.Powershot")
end

function powershot_uganda:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor('damage')
    if target then
        ApplyDamage({victim = target, attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
    end
end

lina_dragon_slave_uganda = class({})

function lina_dragon_slave_uganda:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function lina_dragon_slave_uganda:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function lina_dragon_slave_uganda:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function lina_dragon_slave_uganda:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition() + 5
    local caster_loc = caster:GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,caster)
    local direction = (target_loc - caster_loc):Normalized()
    local point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1"))
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
        vSpawnOrigin        = point,
        fDistance           = 1300,
        fStartRadius        = 300,
        fEndRadius          = 500,
        Source              = caster,
        bHasFrontalCone     = true,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 1200,
        bProvidesVision     = false,
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    caster:EmitSound("Hero_Lina.DragonSlave")
end

function lina_dragon_slave_uganda:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor('damage')
    if target then
        ApplyDamage({victim = target, attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
    end
end

LinkLuaModifier("modifier_knuckles_crystal_maiden_aura", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knuckles_crystal_maiden", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)

CrystalQueen_Damage = class({})

function CrystalQueen_Damage:GetIntrinsicModifierName()
    return "modifier_knuckles_crystal_maiden_aura"
end

modifier_knuckles_crystal_maiden_aura = class({})

function modifier_knuckles_crystal_maiden_aura:IsPurgable() return false end
function modifier_knuckles_crystal_maiden_aura:IsHidden() return true end
function modifier_knuckles_crystal_maiden_aura:IsAura() return true end

function modifier_knuckles_crystal_maiden_aura:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( self.particle, 1, Vector( 750, 750, 1 ) )
    self:AddParticle( self.particle,  false, false, -1,  false, false )
    self:GetParent():EmitSound("hero_Crystal.freezingField.wind")
end

function modifier_knuckles_crystal_maiden_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_knuckles_crystal_maiden_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_knuckles_crystal_maiden_aura:GetModifierAura()
    return "modifier_knuckles_crystal_maiden"
end

function modifier_knuckles_crystal_maiden_aura:GetAuraRadius()
    return 750
end

modifier_knuckles_crystal_maiden = class({})

function modifier_knuckles_crystal_maiden:IsPurgable() return false end

function modifier_knuckles_crystal_maiden:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
end

function modifier_knuckles_crystal_maiden:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_knuckles_crystal_maiden:GetEffectName()
    return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_knuckles_crystal_maiden:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_knuckles_crystal_maiden:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_knuckles_crystal_maiden:StatusEffectPriority()
    return 1000
end

function modifier_knuckles_crystal_maiden:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_knuckles_crystal_maiden:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("movespeed_slow")
end

LinkLuaModifier("modifier_Knuckles_GetInTheTank", "abilities/heroes/knuckles", LUA_MODIFIER_MOTION_NONE)

Knuckles_GetInTheTank = class({}) 

function Knuckles_GetInTheTank:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Knuckles_GetInTheTank:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Knuckles_GetInTheTank:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("tank")
    local duration = self:GetSpecialValueFor('duration')  + self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_7")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Knuckles_GetInTheTank", {duration = duration})
end

function Knuckles_GetInTheTank:IllusionAbuse(target)
    if not IsServer() then return end
    if not self:GetCaster():HasShard() then return end
    if not self:GetCaster():HasModifier("modifier_Knuckles_GetInTheTank") then return end
    local duration = self:GetSpecialValueFor('duration')  + self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_7")
    target:AddNewModifier(self:GetCaster(), self, "modifier_Knuckles_GetInTheTank", {duration = duration})
end

modifier_Knuckles_GetInTheTank = class({}) 

function modifier_Knuckles_GetInTheTank:IsPurgable() return false end

function modifier_Knuckles_GetInTheTank:AllowIllusionDuplicate() return self:GetCaster():HasShard() end

function modifier_Knuckles_GetInTheTank:OnCreated()
    if not IsServer() then return end
    local playerID = self:GetParent():GetPlayerID()
    if self:GetParent():GetUnitName() == "npc_dota_hero_winter_wyvern" then
       --self:GetParent():SetModelScale(2)
    end
    if DonateShopIsItemActive(playerID, 35) then
        self:GetParent():SetMaterialGroup("event")
    end
end

function modifier_Knuckles_GetInTheTank:OnDestroy()
    if not IsServer() then return end
    local playerID = self:GetParent():GetPlayerID()
    self:GetCaster():StopSound("tank")
    if self:GetParent():GetUnitName() == "npc_dota_hero_winter_wyvern" then
        --self:GetParent():SetModelScale(0.5)
    end
    if DonateShopIsItemActive(playerID, 35) then
        if self:GetParent():GetUnitName() == "npc_dota_hero_winter_wyvern" then
            self:GetParent():SetMaterialGroup("event")
        end
    end
end

function modifier_Knuckles_GetInTheTank:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
    }
    return decFuncs
end

function modifier_Knuckles_GetInTheTank:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor('mv') + self:GetCaster():FindTalentValue("special_bonus_birzha_knuckles_8")
end

function modifier_Knuckles_GetInTheTank:GetModifierPhysicalArmorBonus()
    if self:GetParent():IsIllusion() then
        return self:GetAbility():GetSpecialValueFor('armor_illusion')
    end
    return self:GetAbility():GetSpecialValueFor('armor')
end

function modifier_Knuckles_GetInTheTank:GetModifierBaseAttack_BonusDamage()
    if self:GetParent():IsIllusion() then
        return self:GetAbility():GetSpecialValueFor('dmg_illusion')
    end
    return self:GetAbility():GetSpecialValueFor('dmg')
end

function modifier_Knuckles_GetInTheTank:GetModifierAttackRangeBonus()
    if self:GetParent():IsIllusion() then
        return self:GetAbility():GetSpecialValueFor('range_illusion')
    end
    return self:GetAbility():GetSpecialValueFor('range')
end

function modifier_Knuckles_GetInTheTank:GetModifierModelChange()
    return "models/update_heroes/knuckles/knuckles_tank.vmdl"
end

function modifier_Knuckles_GetInTheTank:GetModifierProjectileName()
    return "particles/units/heroes/hero_techies/techies_base_attack.vpcf"
end