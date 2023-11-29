LinkLuaModifier("modifier_weapon_shakal", "items/weapon_shakal.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_weapon_shakal_cooldown", "items/weapon_shakal.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_weapon_shakal_debuff", "items/weapon_shakal.lua", LUA_MODIFIER_MOTION_NONE)

item_weapon_shakal = class({})
item_weapon_shakal.projectiles = {}

function item_weapon_shakal:GetIntrinsicModifierName()
    return "modifier_weapon_shakal"
end

function item_weapon_shakal:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local damage = self:GetSpecialValueFor("damage")
    local damage_percent = self:GetSpecialValueFor("damage_percent")
    local bonus_damage_length = self:GetSpecialValueFor("bonus_damage_length")
    local bonus_damage_distance = self:GetSpecialValueFor("bonus_damage_distance")
    local damage_lifesteal = self:GetSpecialValueFor("damage_lifesteal")
    ------------------------------------------------------------------------------------------------------------
    self:Shoot(target, damage, damage_percent, bonus_damage_length, bonus_damage_distance, damage_lifesteal)
end

function item_weapon_shakal:OnProjectileHit(target, location)
    if not IsServer() then return end
    local data = table.remove(self.projectiles, 1)
    if target and not target:IsMagicImmune() then
        if data ~= nil then
            local damage = data["damage"] + (target:GetMaxHealth() / 100 * data["percent_damage"])
            local distance = (target:GetAbsOrigin() - Vector(data["x"], data["y"], 0)):Length2D()
            local distance_damage = (distance / data["distance_search"]) * data["distance_damage"]
            target:AddNewModifier(self:GetCaster(), self, "modifier_item_weapon_shakal_debuff", {duration = self:GetSpecialValueFor("debuff_duration")})
            local full_damage = ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage + distance_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
            if full_damage > 0 then
                self:GetParent():Heal(full_damage / 100 * data["lifesteal"], self)
            end
        end
    end
end

function item_weapon_shakal:Shoot(target, damage, percent_damage, distance_search, distance_damage, lifesteal)
    if not IsServer() then return end
    self:GetCaster():EmitSound("shakal_weapon")
    local info = 
    {
        Target = target,
        Source = self:GetCaster(),
        EffectName = "particles/shakal_proj_particle.vpcf",
        iMoveSpeed = self:GetSpecialValueFor("proj_speed"),
        vSourceLoc = target:GetAbsOrigin(),         
        bDodgeable = true,                        
        bReplaceExisting = false,                  
        flExpireTime = GameRules:GetGameTime() + 5,
        bProvidesVision = false,
        iUnitTargetFlags = 0, 
        Ability = self,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,                
    }
    ProjectileManager:CreateTrackingProjectile(info)
    local table_f = 
    {
        ["damage"] = damage,
        ["percent_damage"] = percent_damage,
        ["distance_search"] = distance_search,
        ["distance_damage"] = distance_damage,
        ["lifesteal"] = lifesteal,
        ["x"] = self:GetCaster():GetAbsOrigin().x,
        ["y"] = self:GetCaster():GetAbsOrigin().y,
    }
    table.insert(self.projectiles, table_f)
end

modifier_weapon_shakal = class({})
function modifier_weapon_shakal:IsHidden() return true end
function modifier_weapon_shakal:IsPurgable() return false end
function modifier_weapon_shakal:IsPurgeException() return false end
function modifier_weapon_shakal:RemoveOnDeath() return false end

function modifier_weapon_shakal:OnCreated()
    if not IsServer() then return end
    self.passive_damage = self:GetAbility():GetSpecialValueFor("passive_damage")
    self.passive_damage_percent = self:GetAbility():GetSpecialValueFor("passive_damage_percent")
    self.passive_bonus_damage_length = self:GetAbility():GetSpecialValueFor("passive_bonus_damage_length")
    self.passive_bonus_damage_distance = self:GetAbility():GetSpecialValueFor("passive_bonus_damage_distance")
    self.passive_damage_lifesteal = self:GetAbility():GetSpecialValueFor("passive_damage_lifesteal")
    ------------------------------------------------------------------------------------------------------------
    self.chance = self:GetAbility():GetSpecialValueFor("chance")
    self.chance_cooldown = self:GetAbility():GetSpecialValueFor("chance_cooldown")
    self.spell_lifesteal = self:GetAbility():GetSpecialValueFor("spell_lifesteal")
    self.chance_radius = self:GetAbility():GetSpecialValueFor("chance_radius")
end

function modifier_weapon_shakal:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
end

function modifier_weapon_shakal:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_attributes")
    end
end

function modifier_weapon_shakal:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_attributes")
    end
end

function modifier_weapon_shakal:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_attributes")
    end
end

function modifier_weapon_shakal:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.inflictor ~= nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local bonus_percentage = 0
        for _, mod in pairs(self:GetParent():FindAllModifiers()) do
            if mod.GetModifierSpellLifestealRegenAmplify_Percentage and mod:GetModifierSpellLifestealRegenAmplify_Percentage() then
                bonus_percentage = bonus_percentage + mod:GetModifierSpellLifestealRegenAmplify_Percentage()
            end
        end    
        local heal = self.spell_lifesteal / 100 * params.damage
        heal = heal * (bonus_percentage / 100 + 1)
        self:GetParent():Heal(heal, params.inflictor)
        local octarine = ParticleManager:CreateParticle( "particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( octarine )
    end
end

function modifier_weapon_shakal:OnAbilityFullyCast( params )
    if IsServer() then
        local hAbility = params.ability
        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
            return 0
        end
        if hAbility:IsToggle() or hAbility:IsItem() then
            return 0
        end
        if self:GetParent():HasModifier("modifier_weapon_shakal_cooldown") then return end
        if RollPercentage(self.chance) then
            local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.chance_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false )
            if #units > 0 then
                self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_weapon_shakal_cooldown", {duration = self.chance_cooldown})
                self:GetAbility():Shoot(units[1], self.passive_damage, self.passive_damage_percent, self.passive_bonus_damage_length, self.passive_bonus_damage_distance, self.passive_damage_lifesteal)
            end
        end
    end
end

modifier_weapon_shakal_cooldown = class({})
function modifier_weapon_shakal_cooldown:IsPurgable() return false end
function modifier_weapon_shakal_cooldown:IsHidden() return true end
function modifier_weapon_shakal_cooldown:RemoveOnDeath() return false end
function modifier_weapon_shakal_cooldown:IsPurgeException() return false end

modifier_item_weapon_shakal_debuff = class({})
function modifier_item_weapon_shakal_debuff:OnCreated()
    self.slow = self:GetAbility():GetSpecialValueFor("slow")
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_break.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 1, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.particle, false, false, -1, false, false)
end
function modifier_item_weapon_shakal_debuff:CheckState()
    return
    {
        [MODIFIER_STATE_PASSIVES_DISABLED] = true,
    }
end
function modifier_item_weapon_shakal_debuff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_item_weapon_shakal_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end





















