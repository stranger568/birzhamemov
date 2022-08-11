LinkLuaModifier( "modifier_item_excalibur", "items/excalibur", LUA_MODIFIER_MOTION_NONE )

item_excalibur = class({})

function item_excalibur:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local direction
    if target_loc == caster_loc then
        direction = caster:GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end

    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/econ/items/magnataur/shock_of_the_anvil/magnataur_shockanvil.vpcf",
        vSpawnOrigin        = self:GetCaster():GetAbsOrigin(),
        fDistance           = 800,
        fStartRadius        = 150,
        fEndRadius          = 150,
        Source              = self:GetCaster(),
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 2.5,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 1200,
        bProvidesVision     = false,
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    self:GetParent():EmitSound("excalibur_cast")
end

function item_excalibur:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil then
        ApplyDamage({victim = target, attacker = self:GetCaster(), damage = self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_PHYSICAL, ability = self})
    end
end

function item_excalibur:GetIntrinsicModifierName() 
    return "modifier_item_excalibur"
end

modifier_item_excalibur = class({})

function modifier_item_excalibur:IsHidden()
    return true
end

function modifier_item_excalibur:IsPurgable()
    return false
end

function modifier_item_excalibur:DeclareFunctions()
return  {
            MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
            MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
            MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
end

function modifier_item_excalibur:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_excalibur:GetModifierConstantHealthRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_hp_regen')
    end
end

function modifier_item_excalibur:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
    end
end

function modifier_item_excalibur:OnCreated()
    self.true_attack = true
end

function modifier_item_excalibur:OnAttackLanded(kv)
    if kv.attacker == self:GetParent() then
        if kv.attacker:GetUnitName() == "npc_palnoref_chariot_illusion" then return end
        if kv.attacker:GetUnitName() == "npc_palnoref_chariot_illusion_2" then return end
        if not self:GetParent():IsRangedAttacker() then
            DoCleaveAttack( kv.attacker, kv.target, self:GetAbility(), kv.damage * (self:GetAbility():GetSpecialValueFor("cleave") / 100), 150, 360, 650, "particles/items_fx/battlefury_cleave.vpcf" )
        end
        if RollPseudoRandomPercentage(self:GetAbility():GetSpecialValueFor("chance"), 4, self:GetParent()) and not self:GetParent():IsIllusion() and self.true_attack then
            if self:IsNull() then return end
            local direction = self:GetParent():GetForwardVector()
            local projectile =
            {
                Ability             = self:GetAbility(),
                EffectName          = "particles/econ/items/magnataur/shock_of_the_anvil/magnataur_shockanvil.vpcf",
                vSpawnOrigin        = self:GetParent():GetAbsOrigin(),
                fDistance           = 800,
                fStartRadius        = 150,
                fEndRadius          = 150,
                Source              = self:GetParent(),
                bHasFrontalCone     = false,
                bReplaceExisting    = false,
                iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                fExpireTime         = GameRules:GetGameTime() + 2.5,
                bDeleteOnHit        = false,
                vVelocity           = Vector(direction.x,direction.y,0) * 1200,
                bProvidesVision     = false,
            }
            ProjectileManager:CreateLinearProjectile(projectile)
            self:GetParent():EmitSound("excalibur_cast")
            self.true_attack = false
            self:StartIntervalThink(0.5)
        end
    end
end

function modifier_item_excalibur:OnIntervalThink()
    if not IsServer() then return end
    self.true_attack = true
    self:StartIntervalThink(-1)
end