LinkLuaModifier( "modifier_garold_pain_debuff", "abilities/heroes/garold.lua", LUA_MODIFIER_MOTION_NONE )

Garold_pain = class({})

function Garold_pain:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_garold_3")
end

function Garold_pain:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Garold_pain:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Garold_pain:GetAOERadius()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_garold_1")
end

function Garold_pain:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetSpecialValueFor("damage")
    if target:TriggerSpellAbsorb( self ) then return end
    target:EmitSound("Ability.FrostNova")

    local radius = 100

    if self:GetCaster():HasTalent("special_bonus_birzha_garold_1") then
        radius = self:GetCaster():FindTalentValue("special_bonus_birzha_garold_1")
    end

    local particle = ParticleManager:CreateParticle( "particles/garold/garold_pain.vpcf", PATTACH_POINT_FOLLOW, target )
    ParticleManager:SetParticleControl( particle, 1, Vector( radius, 0, 0 ) )
    ParticleManager:ReleaseParticleIndex( particle )

    if self:GetCaster():HasTalent("special_bonus_birzha_garold_1") then
        local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
        for _, hero in pairs(targets) do
            ApplyDamage({victim = hero, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        end
    else
        ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
    end

    target:AddNewModifier(self:GetCaster(), self, "modifier_garold_pain_debuff", {duration = duration * (1-target:GetStatusResistance()) })
end

modifier_garold_pain_debuff = class({})

function modifier_garold_pain_debuff:IsPurgable()
    return true
end

function modifier_garold_pain_debuff:IsPurgeException()
    return true
end

function modifier_garold_pain_debuff:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_queenofpain/queen_shadow_strike_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
    self:AddParticle( particle, false,  false, -1, false, false )
end

function modifier_garold_pain_debuff:GetEffectName()
    return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_garold_pain_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_garold_pain_debuff:CheckState()
    local funcs = 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }
    return funcs
end

LinkLuaModifier( "modifier_Garold_StealPain_stack", "abilities/heroes/garold.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Garold_StealPain_stack_cooldown", "abilities/heroes/garold.lua", LUA_MODIFIER_MOTION_NONE )

Garold_StealPain = class({})

function Garold_StealPain:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Garold_StealPain:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_garold_7")
end

function Garold_StealPain:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Garold_StealPain:GetIntrinsicModifierName()
    return "modifier_Garold_StealPain_stack"
end

function Garold_StealPain:OnSpellStart()
    if not IsServer() then return end
    local modifier = self:GetCaster():FindModifierByName( "modifier_Garold_StealPain_stack" )
    local stack_count = modifier:GetStackCount() / 100
    local damage_persentage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_garold_5")
    local radius = self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_garold_7")

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

    for _,unit in pairs(targets) do
        ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = stack_count * damage_persentage, damage_type = DAMAGE_TYPE_PURE, ability = self})
        local particle = ParticleManager:CreateParticle("particles/garold/garold_stealpain.vpcf", PATTACH_POINT_FOLLOW, unit)
        ParticleManager:SetParticleControlEnt(particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true)
        ParticleManager:SetParticleControl(particle, 1, Vector(radius,0,0))
        ParticleManager:ReleaseParticleIndex(particle)
        self:GetCaster():EmitSound( "Hero_Antimage.ManaVoid" )
    end

    self:GetCaster():SetModifierStackCount("modifier_Garold_StealPain_stack", self, 0)
end

function Garold_StealPain:StartScepter(damage)
    if not IsServer() then return end
    local stack_count = damage / 100
    local damage_persentage = self:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_garold_5")
    local radius = self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_garold_7")
    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for _,unit in pairs(targets) do
        ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = stack_count * damage_persentage, damage_type = DAMAGE_TYPE_PURE, ability = self})
        local particle = ParticleManager:CreateParticle("particles/garold/garold_stealpain.vpcf", PATTACH_POINT_FOLLOW, unit)
        ParticleManager:SetParticleControlEnt(particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true)
        ParticleManager:SetParticleControl(particle, 1, Vector(radius,0,0))
        ParticleManager:ReleaseParticleIndex(particle)
        self:GetCaster():EmitSound( "Hero_Antimage.ManaVoid" )
    end
end

modifier_Garold_StealPain_stack_cooldown = class({})
function modifier_Garold_StealPain_stack_cooldown:IsPurgable() return false end
function modifier_Garold_StealPain_stack_cooldown:RemoveOnDeath() return false end

modifier_Garold_StealPain_stack = class({})

function modifier_Garold_StealPain_stack:IsHidden() return self:GetStackCount() == 0 end

function modifier_Garold_StealPain_stack:IsPurgable()
    return false
end

function modifier_Garold_StealPain_stack:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

function modifier_Garold_StealPain_stack:OnCreated()
    if not IsServer() then return end
    self.scepter_damage = 0
end

function modifier_Garold_StealPain_stack:OnTakeDamage( params )
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if params.attacker == self:GetParent() then return end
    if params.attacker:GetUnitName() == "dota_fountain" then return end
    if params.attacker:IsBoss() then return end
    if self:GetParent():IsIllusion() then return end
    if not self:GetParent():IsAlive() then return end

    if self:GetCaster():HasScepter() and not self:GetCaster():HasModifier("modifier_Garold_StealPain_stack_cooldown") then
        if self.scepter_damage <= self:GetAbility():GetSpecialValueFor("damage_stack_scepter") then
            self.scepter_damage = self.scepter_damage + params.damage
        end

        if (self.scepter_damage + params.damage) > self:GetAbility():GetSpecialValueFor("damage_stack_scepter") then
            self.scepter_damage = self:GetAbility():GetSpecialValueFor("damage_stack_scepter")
        end

        if self.scepter_damage >= self:GetAbility():GetSpecialValueFor("damage_stack_scepter") then
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Garold_StealPain_stack_cooldown", {duration = self:GetAbility():GetSpecialValueFor("scepter_cooldown")})
            self:GetAbility():StartScepter(self.scepter_damage)
            self.scepter_damage = 0
        end
    end

    local max_stacks = self:GetAbility():GetSpecialValueFor("damagestack")

    if (self:GetStackCount() + params.damage) > max_stacks then
        self:SetStackCount(max_stacks)
        return
    end

    if self:GetStackCount() <= max_stacks then
        self:SetStackCount(self:GetStackCount() + params.damage)
    end
end

function modifier_Garold_StealPain_stack:OnDeath( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        self:SetStackCount(0)
    end
end

LinkLuaModifier("modifier_Garold_HidePain_passive", "abilities/heroes/garold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Garold_HidePain_stats", "abilities/heroes/garold", LUA_MODIFIER_MOTION_NONE )

Garold_HidePain = class({}) 

function Garold_HidePain:GetIntrinsicModifierName()
    return "modifier_Garold_HidePain_passive"
end

modifier_Garold_HidePain_passive = class({}) 

function modifier_Garold_HidePain_passive:IsHidden() return self:GetStackCount() == 0 end

function modifier_Garold_HidePain_passive:IsPurgable()
    return false
end

function modifier_Garold_HidePain_passive:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
    return funcs
end

function modifier_Garold_HidePain_passive:OnAttackLanded( params )
    if not IsServer() then return end

    if params.target ~= self:GetParent() then return end

    if self:GetParent():IsIllusion() then return end

    if self:GetParent():PassivesDisabled() then return end

    if not self:GetParent():IsAlive() then return end

    local max_stack = self:GetAbility():GetSpecialValueFor("maxstack") + self:GetCaster():FindTalentValue("special_bonus_birzha_garold_2")

    local duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_garold_4")

    if self:GetStackCount() < max_stack then
        self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_Garold_HidePain_stats", { duration = duration } )
        self:IncrementStackCount()
    end
end

function modifier_Garold_HidePain_passive:GetModifierPhysicalArmorBonus()
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_Garold_HidePain_passive:GetModifierConstantHealthRegen()
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("regen")
end

function modifier_Garold_HidePain_passive:GetModifierMagicalResistanceBonus()
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("magicarmor")
end

function modifier_Garold_HidePain_passive:RemoveStack()
    self:DecrementStackCount()
end

modifier_Garold_HidePain_stats = class({})

function modifier_Garold_HidePain_stats:IsHidden()
    return true
end

function modifier_Garold_HidePain_stats:IsPurgable()
    return false
end

function modifier_Garold_HidePain_stats:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_Garold_HidePain_stats:OnDestroy()
    if not IsServer() then return end
    local modifier = self:GetParent():FindModifierByName( "modifier_Garold_HidePain_passive" )
    if modifier then
        modifier:RemoveStack()
    end
end

LinkLuaModifier( "modifier_joy_stats", "abilities/heroes/garold.lua", LUA_MODIFIER_MOTION_NONE )

Garold_Joy = class({})

function Garold_Joy:GetIntrinsicModifierName()
    return "modifier_joy_stats"
end

modifier_joy_stats = class({})

function modifier_joy_stats:IsPurgable()
    return false
end

function modifier_joy_stats:IsHidden() return self:GetStackCount() == 0 end

function modifier_joy_stats:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_joy_stats:OnCreated()
    if not IsServer() then return end
    self.damage_hero = 0
end

function modifier_joy_stats:OnTakeDamage( params )
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    if params.attacker == self:GetParent() then return end
    if params.attacker:GetUnitName() == "dota_fountain" then return end
    if params.attacker:IsBoss() then return end
    if self:GetParent():IsIllusion() then return end
    if not self:GetParent():IsAlive() then return end

    local damage_need = self:GetAbility():GetSpecialValueFor("damageforstack")
    local max_stacks = self:GetAbility():GetSpecialValueFor("maxstacks") + self:GetCaster():FindTalentValue("special_bonus_birzha_garold_6")

    self.damage_hero = self.damage_hero + params.damage

    if self.damage_hero >= damage_need then  

        if self:GetStackCount() < max_stacks then
            self:IncrementStackCount()
        end

        self.damage_hero = 0
    end
end

function modifier_joy_stats:GetModifierBonusStats_Strength()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("atribute") + self:GetCaster():FindTalentValue("special_bonus_birzha_garold_8"))
end

function modifier_joy_stats:GetModifierBonusStats_Agility()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("atribute") + self:GetCaster():FindTalentValue("special_bonus_birzha_garold_8"))
end

function modifier_joy_stats:GetModifierBonusStats_Intellect()
    if self:GetParent():PassivesDisabled() then return end
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("atribute") + self:GetCaster():FindTalentValue("special_bonus_birzha_garold_8"))
end

LinkLuaModifier( "modifier_garold_cloud_thinker", "abilities/heroes/garold.lua", LUA_MODIFIER_MOTION_NONE )

garold_cloud = class({})

function garold_cloud:OnInventoryContentsChanged()
    if self:GetCaster():HasShard() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function garold_cloud:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function garold_cloud:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function garold_cloud:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")

    local cloud = CreateUnitByName("npc_dota_zeus_cloud", Vector(point.x, point.y, 450), false, caster, nil, caster:GetTeam())
    cloud:SetOriginalModel("models/development/invisiblebox.vmdl")
    cloud:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    cloud:AddNewModifier(caster, self, "modifier_garold_cloud_thinker", {duration = duration})
    EmitSoundOnLocationWithCaster(point, "Hero_Zuus.Cloud.Cast", caster)
end

modifier_garold_cloud_thinker = class({})

function modifier_garold_cloud_thinker:OnCreated( kv )
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.damage = self.ability:GetSpecialValueFor( "damage" )
    self.radius = self.ability:GetSpecialValueFor( "radius" )
    if not IsServer() then return end

    self.zuus_nimbus_particle = ParticleManager:CreateParticle("particles/garold_shard_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.zuus_nimbus_particle, 0, Vector(self:GetParent():GetAbsOrigin().x, self:GetParent():GetAbsOrigin().y, 450))
    ParticleManager:SetParticleControl(self.zuus_nimbus_particle, 1, Vector(self.radius, 0, 0))
    ParticleManager:SetParticleControl(self.zuus_nimbus_particle, 2, Vector(self:GetParent():GetAbsOrigin().x, self:GetParent():GetAbsOrigin().y, self:GetParent():GetAbsOrigin().z + 450))  
    self:AddParticle( self.zuus_nimbus_particle, false,  false, -1, false, false )

    self.effect_cast = ParticleManager:CreateParticle("particles/garold_shard_cloudamp_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.effect_cast,0,self:GetParent(),PATTACH_ABSORIGIN_FOLLOW,nil,self:GetParent():GetOrigin(),true)
    ParticleManager:SetParticleControlEnt(self.effect_cast,1,self:GetParent(),PATTACH_ABSORIGIN_FOLLOW,nil,self:GetParent():GetOrigin(),true)
    ParticleManager:SetParticleControlEnt(self.effect_cast,2,self:GetParent(),PATTACH_ABSORIGIN_FOLLOW,nil,self:GetParent():GetOrigin(),true)
    self:AddParticle(self.effect_cast,false,false,-1,false,true)


    self:OnIntervalThink()
    self:StartIntervalThink( 1 )
end

function modifier_garold_cloud_thinker:OnIntervalThink()
    local enemies = FindUnitsInRadius( self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    for _,enemy in pairs(enemies) do
        ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
    end
    self:PlayEffects()
end

function modifier_garold_cloud_thinker:PlayEffects()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 4, Vector( self.radius, 0, 0 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    self.parent:EmitSound("Hero_AbyssalUnderlord.Firestorm")
end

function modifier_garold_cloud_thinker:CheckState()
    local funcs = 
    {
        [MODIFIER_STATE_NO_TEAM_MOVE_TO]    = true,
        [MODIFIER_STATE_NO_TEAM_SELECT]     = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE]      = true,
        [MODIFIER_STATE_MAGIC_IMMUNE]       = true,
        [MODIFIER_STATE_INVULNERABLE]       = true,
        [MODIFIER_STATE_UNSELECTABLE]       = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP]     = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]      = true,
        [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return funcs
end

function modifier_garold_cloud_thinker:GetVisualZDelta()
    return 450
end




