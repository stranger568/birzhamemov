LinkLuaModifier( "modifier_naval_meeting_talent", "abilities/heroes/navalny.lua", LUA_MODIFIER_MOTION_NONE )

Naval_meeting = class({})

function Naval_meeting:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Naval_meeting:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Naval_meeting:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local level = self:GetLevel()
    local count = self:GetSpecialValueFor('schoolboys_number')
    caster:EmitSound("navalmit")
    for i = 1, count do
        self.schoolboy = CreateUnitByName("npc_schoolboy_"..level, caster:GetAbsOrigin() + RandomVector(300), true, caster, nil, caster:GetTeamNumber())
        self.schoolboy:SetOwner(caster)
        self.schoolboy:SetControllableByPlayer(caster:GetPlayerID(), true)
        FindClearSpaceForUnit(self.schoolboy, self.schoolboy:GetAbsOrigin(), true)
        self.schoolboy:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("schoolboys_duration")})
        if caster:HasTalent("special_bonus_birzha_navalny_5") then
            self.schoolboy:AddNewModifier(caster, self, "modifier_magic_immune", {})
        end
        if caster:HasTalent("special_bonus_birzha_navalny_3") then
            self.schoolboy:SetBaseDamageMin(self.schoolboy:GetBaseDamageMin() + 100)
            self.schoolboy:SetBaseDamageMax(self.schoolboy:GetBaseDamageMax() + 100)
        end
        if caster:HasTalent("special_bonus_birzha_navalny_4") then
            self.schoolboy:AddNewModifier(caster, self, "modifier_naval_meeting_talent", {})
        end
    end
end

modifier_naval_meeting_talent = class({})

function modifier_naval_meeting_talent:IsPurgable()
    return false
end

function modifier_naval_meeting_talent:IsHidden()
    return true
end

function modifier_naval_meeting_talent:OnCreated()
    self:GetParent():SetBaseDamageMin(self:GetParent():GetBaseDamageMin() * 2)
    self:GetParent():SetBaseDamageMax(self:GetParent():GetBaseDamageMax() * 2)
    self:GetParent():SetBaseMaxHealth(self:GetParent():GetMaxHealth() * 2)
    self:GetParent():SetHealth(self:GetParent():GetMaxHealth())
end


LinkLuaModifier( "modifier_naval_acid_spray", "abilities/heroes/navalny.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_naval_acid_spray_debuff", "abilities/heroes/navalny.lua", LUA_MODIFIER_MOTION_NONE )

naval_acid_spray = class({})

function naval_acid_spray:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function naval_acid_spray:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function naval_acid_spray:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function naval_acid_spray:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function naval_acid_spray:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor( "duration" )

    CreateModifierThinker( caster, self, "modifier_naval_acid_spray", { duration = duration }, point, caster:GetTeamNumber(), false )
end

modifier_naval_acid_spray = class({})

function modifier_naval_acid_spray:IsPurgable()
    return false
end

function modifier_naval_acid_spray:OnCreated( kv )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( particle, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( particle, 1, Vector( self.radius, 1, 1 ) )
    self:AddParticle(particle, false, false, -1, false, false )
    self:GetParent():EmitSound("Hero_Alchemist.AcidSpray")
end

modifier_naval_acid_spray_debuff = class({})

function modifier_naval_acid_spray_debuff:OnCreated( kv )
    local interval = self:GetAbility():GetSpecialValueFor( "tick_rate" )
    local damage = self:GetAbility():GetSpecialValueFor( "damage" )
    self.armor = -(self:GetAbility():GetSpecialValueFor( "armor_reduction" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_navalny_1"))
    if not IsServer() then return end
    self.damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
    }
    self:StartIntervalThink( interval )
end

function modifier_naval_acid_spray_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

function modifier_naval_acid_spray_debuff:GetModifierPhysicalArmorBonus()
    return self.armor
end

function modifier_naval_acid_spray_debuff:OnIntervalThink()
    self.damageTable.victim = self:GetParent()
    ApplyDamage( self.damageTable )
    self:GetParent():EmitSound("Hero_Alchemist.AcidSpray.Damage")
end

function modifier_naval_acid_spray:IsAura()
    return true
end

function modifier_naval_acid_spray:GetModifierAura()
    return "modifier_naval_acid_spray_debuff"
end

function modifier_naval_acid_spray:GetAuraRadius()
    return self.radius
end

function modifier_naval_acid_spray:GetAuraDuration()
    return 0.5
end

function modifier_naval_acid_spray:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_naval_acid_spray:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_naval_acid_spray:GetAuraSearchFlags()
    return 0
end

function modifier_naval_acid_spray_debuff:GetEffectName()
    return "particles/units/heroes/hero_alchemist/alchemist_acid_spray_debuff.vpcf"
end

function modifier_naval_acid_spray_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_Naval_Youtube", "abilities/heroes/navalny.lua", LUA_MODIFIER_MOTION_NONE )

Naval_Youtube = class({})

function Naval_Youtube:GetIntrinsicModifierName()
    return "modifier_Naval_Youtube"
end

function Naval_Youtube:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

modifier_Naval_Youtube = class({})

function modifier_Naval_Youtube:IsHidden()
    return true
end

function modifier_Naval_Youtube:IsPurgable() return false end

function modifier_Naval_Youtube:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_Naval_Youtube:OnIntervalThink()
    if not IsServer() then return end
    local money = self:GetAbility():GetSpecialValueFor( "Gold_Tick" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_navalny_2")
    if self:GetCaster():IsIllusion() then return end
    if self:GetAbility():IsFullyCastable() then
        self:GetAbility():UseResources(false, false, true)
        self:GetCaster():ModifyGold( money, true, 0 )
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red_spotlight.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
    end
end


LinkLuaModifier( "modifier_naval_president", "abilities/heroes/navalny.lua", LUA_MODIFIER_MOTION_NONE )

Naval_President = class({})

function Naval_President:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Naval_President:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Naval_President:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor( "duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_navalny_6")
    caster:AddNewModifier( caster, self, "modifier_naval_president", { duration = duration } )
    caster:EmitSound("navalprez")
end

modifier_naval_president = class({})

function modifier_naval_president:OnCreated()
    local particle = ParticleManager:CreateParticle( "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_eztzhok.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
    self:AddParticle(particle, false, false, -1, false, false )
end

function modifier_naval_president:IsPurgable() return false end

function modifier_naval_president:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("navalprez")
end

function modifier_naval_president:DeclareFunctions()
    local funcs = {
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_PROPERTY_MODEL_SCALE,
    }

    return funcs
end

function modifier_naval_president:CheckState()
    if not self:GetParent():HasScepter() then return end
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }
end

function modifier_naval_president:GetModifierModelScale()
    return 75
end

function modifier_naval_president:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor( "bonus_damage" )
end
function modifier_naval_president:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor( "hp_regen" )
end
function modifier_naval_president:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
end

function modifier_naval_president:GetEffectName()
    if not self:GetParent():HasScepter() then return end
    return "particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8.vpcf"
end

function modifier_naval_president:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
