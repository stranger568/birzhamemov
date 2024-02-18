LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gorin_choose_axe", "abilities/heroes/gorin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_gorin_choose_axe_ranged", "abilities/heroes/gorin", LUA_MODIFIER_MOTION_NONE)

gorin_choose_axe = class({})

function gorin_choose_axe:GetIntrinsicModifierName()
    return "modifier_gorin_choose_axe_ranged"
end

function gorin_choose_axe:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_gorin_choose_axe") then
        return "troll_warlord_berserkers_rage_active"
    else
        return "troll_warlord_berserkers_rage"
    end
end

function gorin_choose_axe:OnToggle()
    if not IsServer() then return end
    self:GetCaster():CalculateStatBonus(true)
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)

    if self:GetToggleState() then
        self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_gorin_choose_axe", {} )
    else
        if self.modifier then
            self.modifier:Destroy()
            self.modifier = nil
        end
    end
    self:GetCaster():EmitSound("Hero_TrollWarlord.BerserkersRage.Toggle")
end



modifier_gorin_choose_axe = class({})

function modifier_gorin_choose_axe:IsHidden() return true end
function modifier_gorin_choose_axe:IsPurgable() return false end
function modifier_gorin_choose_axe:RemoveOnDeath() return false end
function modifier_gorin_choose_axe:IsPurgeException() return false end

function modifier_gorin_choose_axe:OnCreated( kv )
    self.base_attack_time = self:GetAbility():GetSpecialValueFor( "base_attack_time" )
    self.bonus_move_speed = self:GetAbility():GetSpecialValueFor( "bonus_move_speed" )
    self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
    self.melee_range = 150
    self.stun_chance = self:GetAbility():GetSpecialValueFor( "stun_chance" )
    self.stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
    self.delta_attack_range = self.melee_range - self:GetParent():Script_GetAttackRange()
    if not IsServer() then return end
    self.pre_attack_capability = self:GetParent():GetAttackCapability()
    self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )
    self:GetParent():FadeGesture(ACT_DOTA_RUN)
    self.attack_melee = false
end

function modifier_gorin_choose_axe:OnRefresh( kv )
    self.base_attack_time = self:GetAbility():GetSpecialValueFor( "base_attack_time" )
    self.bonus_move_speed = self:GetAbility():GetSpecialValueFor( "bonus_move_speed" )
    self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
    self.stun_chance = self:GetAbility():GetSpecialValueFor( "stun_chance" )
    self.stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
end

function modifier_gorin_choose_axe:OnDestroy( kv )
    if not IsServer() then return end
    self:GetParent():SetAttackCapability(self.pre_attack_capability )
    self:GetParent():FadeGesture(ACT_DOTA_RUN)
end

function modifier_gorin_choose_axe:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_gorin_choose_axe:GetModifierBaseAttackTimeConstant()
    return self.base_attack_time + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_4")
end

function modifier_gorin_choose_axe:GetModifierAttackRangeBonus()
    return -350
end

function modifier_gorin_choose_axe:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_3")
end

function modifier_gorin_choose_axe:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_gorin_choose_axe:GetAttackSound()
    return "Hero_TrollWarlord.ProjectileImpact"
end

function modifier_gorin_choose_axe:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker == params.target then return end
    if params.target:IsWard() then return end
    if params.target:IsBuilding() then return end
    if params.attacker:IsIllusion() then return end
    if params.ranged_attack then return end

    local chance = self.stun_chance

    if RollPseudoRandomPercentage(chance, self:GetParent():entindex(), self:GetParent()) then
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self.stun_duration * (1-params.target:GetStatusResistance())})
    end
end

function modifier_gorin_choose_axe:GetActivityTranslationModifiers()
    return "melee"
end

function modifier_gorin_choose_axe:GetPriority()
    return 1
end

function modifier_gorin_choose_axe:GetEffectName()
    return "particles/units/heroes/hero_troll_warlord/troll_warlord_berserk_buff.vpcf"
end

function modifier_gorin_choose_axe:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

modifier_gorin_choose_axe_ranged = class({})
function modifier_gorin_choose_axe_ranged:IsHidden() return true end
function modifier_gorin_choose_axe_ranged:IsPurgable() return false end
function modifier_gorin_choose_axe_ranged:RemoveOnDeath() return false end
function modifier_gorin_choose_axe_ranged:IsPurgeException() return false end
function modifier_gorin_choose_axe_ranged:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_gorin_choose_axe_ranged:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker == params.target then return end
    if params.target:IsWard() then return end
    if params.target:IsBuilding() then return end
    if params.attacker:IsIllusion() then return end
    if not params.ranged_attack then return end
    if not self:GetCaster():HasTalent("special_bonus_birzha_gorin_6") then return end

    local chance = self:GetAbility():GetSpecialValueFor( "stun_chance" )

    if RollPseudoRandomPercentage(chance, self:GetParent():entindex(), self:GetParent()) then
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration") * (1-params.target:GetStatusResistance())})
    end
end

Gorin_TwinBrother = class({})

function Gorin_TwinBrother:GetCooldown(level)
    if self:GetCaster():HasShard() then
        return self:GetSpecialValueFor("shard_cooldown")
    end
    return self.BaseClass.GetCooldown( self, level )
end

function Gorin_TwinBrother:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Gorin_TwinBrother:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("illusion_duration")
    local damage_in = self:GetSpecialValueFor("illusion_incoming") - 100
    local damage_out = (self:GetSpecialValueFor("illusion_outgoing") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_1")) - 100
    self:GetCaster():EmitSound("gitelmanbrat")
    local illusion = BirzhaCreateIllusion( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=damage_out,incoming_damage=damage_in}, 1, 1, true, true ) 
end

LinkLuaModifier( "modifier_gorin_resourcefulness", "abilities/heroes/gorin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_gorin_resourcefulness_buff", "abilities/heroes/gorin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_gorin_resourcefulness_stack", "abilities/heroes/gorin", LUA_MODIFIER_MOTION_NONE)

Gorin_Resourcefulness = class({})

function Gorin_Resourcefulness:GetIntrinsicModifierName()
    return "modifier_gorin_resourcefulness"
end

modifier_gorin_resourcefulness = class({})

function modifier_gorin_resourcefulness:IsHidden()
    return true
end

function modifier_gorin_resourcefulness:IsPurgable()
    return false
end

function modifier_gorin_resourcefulness:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }

    return funcs
end

function modifier_gorin_resourcefulness:GetModifierProcAttack_BonusDamage_Physical( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:PassivesDisabled() then return end
    if params.attacker:IsIllusion() then return end
    if params.target:IsWard() then return end

    local stack = params.target:FindModifierByName("modifier_gorin_resourcefulness_stack")

    local duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_8")

    params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_gorin_resourcefulness_buff", { duration = duration * (1-params.target:GetStatusResistance()) })
    params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_gorin_resourcefulness_stack", { duration = duration * (1-params.target:GetStatusResistance()) })


    if stack == nil then return end
    
    return stack:GetStackCount() * (self:GetAbility():GetSpecialValueFor("damage_per_stack") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_2"))
end

modifier_gorin_resourcefulness_buff = class({})

function modifier_gorin_resourcefulness_buff:IsHidden() return true end
function modifier_gorin_resourcefulness_buff:IsPurgable() return false end
function modifier_gorin_resourcefulness_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

modifier_gorin_resourcefulness_stack = class({})

function modifier_gorin_resourcefulness_stack:IsPurgable()
    return false
end

function modifier_gorin_resourcefulness_stack:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
    self:StartIntervalThink(FrameTime())
end

function modifier_gorin_resourcefulness_stack:OnIntervalThink()
    if not IsServer() then return end
    local stack = self:GetParent():FindAllModifiersByName("modifier_gorin_resourcefulness_buff")
    self:SetStackCount(#stack)
end

function modifier_gorin_resourcefulness_stack:GetEffectName()
    return "particles/gorin/resor_debuff.vpcf"
end

function modifier_gorin_resourcefulness_stack:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

LinkLuaModifier( "modifier_gorin_rabies_primary", "abilities/heroes/gorin", LUA_MODIFIER_MOTION_NONE )

Gorin_rabies = class({})

function Gorin_rabies:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Gorin_rabies:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_5")
end

function Gorin_rabies:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Gorin_rabies:GetChannelTime()
    return self:GetSpecialValueFor("channel_duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_7")
end

function Gorin_rabies:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local origin = caster:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("radius")
    caster:AddNewModifier(caster, self, "modifier_gorin_rabies_primary", {})
    EmitSoundOnLocationWithCaster(origin, "gorinult", caster)
    self.illusions = {}
    if not self:GetCaster():HasScepter() then return end
    local illusions = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, 0, false )
    for _, illusion in pairs(illusions) do
        if illusion:IsIllusion() then
            table.insert(self.illusions, illusion)
            illusion:AddNewModifier(caster, self, "modifier_gorin_rabies_primary", {})
        end
    end
end

function Gorin_rabies:OnChannelFinish()
    if not IsServer() then return end
    local caster = self:GetCaster()
    caster:RemoveModifierByName("modifier_gorin_rabies_primary")
    StopSoundEvent("gorinult", caster)
    if not self:GetCaster():HasScepter() then return end
    for _, illusion in pairs(self.illusions) do
        illusion:RemoveModifierByName("modifier_gorin_rabies_primary")
        illusion:ForceKill(false)
    end
end

modifier_gorin_rabies_primary = class({})

function modifier_gorin_rabies_primary:OnCreated()
    if not IsServer() then return end

    self.origin = self:GetCaster():GetAbsOrigin()

    self:GetParent():EmitSound("Hero_Riki.TricksOfTheTrade")

    local radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_5")

    local cast_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_tricks_cast.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(cast_particle, 0, self:GetParent():GetAbsOrigin())

    local particle = ParticleManager:CreateParticle("particles/gorin/gorin_rabits.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0, radius))
    ParticleManager:SetParticleControl(particle, 2, Vector(radius, 0, radius))
    self:AddParticle(particle, false, false, -1, false, false)

    self:GetParent():AddNoDraw()

    self.has_donate_items = false

    if self:GetCaster().GorinStools then
        self.has_donate_items = true
        if self:GetParent().GorinStools
        and self:GetParent().TrollHead
        and self:GetParent().TrollShoulders
        and self:GetParent().TrollLod then
            self:GetParent().GorinStools:Destroy()
            self:GetParent().TrollHead:Destroy()
            self:GetParent().TrollShoulders:Destroy()
            self:GetParent().TrollLod:Destroy()
        end
    end

    local attack_per_second = self:GetParent():GetAttackSpeed(true) / self:GetParent():GetBaseAttackTime()
    local interval = 1 / attack_per_second
    self:StartIntervalThink(interval)
end

function modifier_gorin_rabies_primary:OnDestroy()
    if not IsServer() then return end
    if self.has_donate_items then
        self:GetCaster().GorinStools = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/troll_warlord_gorin_stool.vmdl"})
        self:GetCaster().GorinStools:FollowEntity(self:GetCaster(), true)
        self:GetCaster().TrollHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/troll_warlord/troll_warlord_head.vmdl"})
        self:GetCaster().TrollHead:FollowEntity(self:GetCaster(), true)
        self:GetCaster().TrollShoulders = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/troll_warlord/troll_warlord_shoulders.vmdl"})
        self:GetCaster().TrollShoulders:FollowEntity(self:GetCaster(), true)
        self:GetCaster().TrollLod = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/troll_warlord/mesh/troll_warlord_armor_model_lod0.vmdl"})
        self:GetCaster().TrollLod:FollowEntity(self:GetCaster(), true)
    end
    FindClearSpaceForUnit(self:GetParent(), self.origin, true)
    self:GetParent():RemoveNoDraw()
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_riki/riki_tricks_end.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_gorin_rabies_primary:IsPurgable() return false end

function modifier_gorin_rabies_primary:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
    return funcs
end

function modifier_gorin_rabies_primary:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_gorin_rabies_primary:CheckState()
    local state = 
    {   
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return state
end

function modifier_gorin_rabies_primary:OnIntervalThink()
    if IsServer() then
        self:GetCaster():SetAbsOrigin(self.origin)
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local origin = self:GetParent():GetAbsOrigin()
        local radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_gorin_5")
        local targets = FindUnitsInRadius(caster:GetTeamNumber(), origin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_HERO , DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER , false)
        for _,unit in pairs(targets) do
            if unit:IsAlive() and not unit:IsAttackImmune() and self:GetCaster():CanEntityBeSeenByMyTeam(unit) then
                if self:GetParent():IsRangedAttacker() then
                    self:GetParent():PerformAttack(unit, true, true, true, false, true, false, false)
                else
                    self:GetParent():PerformAttack(unit, true, true, true, false, false, false, true)
                end
            end
        end
    end
end





