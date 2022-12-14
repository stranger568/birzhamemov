LinkLuaModifier( "modifier_item_angel_boots", "items/angel", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_angel_boots_aura", "items/angel", LUA_MODIFIER_MOTION_NONE )

item_angel_boots = class({})

function item_angel_boots:OnSpellStart()
    if not IsServer() then return end
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")


    local mana = self:GetSpecialValueFor("restore_mana")
    local health = self:GetSpecialValueFor("restore_health")

    local mana_percent = self:GetSpecialValueFor("restore_mana_percent") / 100
    local health_percent = self:GetSpecialValueFor("restore_health_percent") / 100

    local restore_mana_target = 0
    local restore_heal_target = 0

    local caster = self:GetCaster()

    if not self:GetCaster():IsHero() then
        caster = caster:GetOwner()
    end

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
    for _,target in pairs(targets) do
        local particle_effect = nil
        if DonateShopIsItemBought(caster:GetPlayerID(), 48) then
            particle_effect = "particles/birzhapass/angel_boots_effect.vpcf"
        else
            particle_effect = "particles/units/heroes/hero_omniknight/omniknight_purification.vpcf"
        end
        target:AddNewModifier(self:GetCaster(), self, "modifier_rune_regen", {duration = duration})
        self:GetCaster():EmitSound("Item.GuardianGreaves.Activate")
        self:GetCaster():EmitSound("Hero_Chen.HandOfGodHealHero")
        local particle = ParticleManager:CreateParticle( particle_effect, PATTACH_CUSTOMORIGIN, self:GetCaster() )
        ParticleManager:SetParticleControlEnt( particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true  );
        ParticleManager:SetParticleControl( particle, 1, Vector( 200, 200, 200 ) );
        ParticleManager:ReleaseParticleIndex( particle );

        restore_mana_target = (target:GetMaxMana() * mana_percent) + mana
        restore_heal_target = (target:GetMaxHealth() * health_percent) + health

        target:GiveMana(restore_mana_target)
        target:Heal(restore_heal_target, self)

        target:Purge( false, true, false, true, true)
    end
end

function item_angel_boots:GetIntrinsicModifierName() 
    return "modifier_item_angel_boots"
end

modifier_item_angel_boots = class({})

function modifier_item_angel_boots:IsHidden() return true end
function modifier_item_angel_boots:IsPurgable() return false end
function modifier_item_angel_boots:IsPurgeException() return false end
function modifier_item_angel_boots:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_angel_boots:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_BONUS
    }
end

function modifier_item_angel_boots:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
    end
end

function modifier_item_angel_boots:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_armor")
    end
end

function modifier_item_angel_boots:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_mana")
    end
end

function modifier_item_angel_boots:GetModifierConstantHealthRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_regen")
    end
end

function modifier_item_angel_boots:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_health")
    end
end

function modifier_item_angel_boots:IsAura() return true end

function modifier_item_angel_boots:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY 
end

function modifier_item_angel_boots:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_angel_boots:GetModifierAura()
    return "modifier_item_angel_boots_aura"
end

function modifier_item_angel_boots:GetAuraRadius()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

function modifier_item_angel_boots:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_item_angel_boots_aura = class({})

function modifier_item_angel_boots_aura:IsPurgable()
    return false
end

function modifier_item_angel_boots_aura:OnCreated()
    self.regen_aura = self:GetAbility():GetSpecialValueFor("bonus_regen_aura")
    self.armor_aura = self:GetAbility():GetSpecialValueFor("bonus_armor_aura")
    self.bonus_regen = self:GetAbility():GetSpecialValueFor("bonus_regen_aura")
    self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor_aura")
    self:StartIntervalThink(FrameTime())
end

function modifier_item_angel_boots_aura:OnIntervalThink()
    if self:GetParent():GetHealthPercent() > 30 then
        self.bonus_regen = self.regen_aura
        self.bonus_armor = self.armor_aura
    else
        self.bonus_regen = self.regen_aura * 2
        self.bonus_armor = self.armor_aura * 3
    end
end

function modifier_item_angel_boots_aura:DeclareFunctions()
return  {
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        }
end

function modifier_item_angel_boots_aura:GetModifierConstantHealthRegen()
    return self.bonus_regen 
end

function modifier_item_angel_boots_aura:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end