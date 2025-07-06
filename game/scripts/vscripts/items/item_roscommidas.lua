LinkLuaModifier("modifier_item_roscom_midas", "items/item_roscommidas", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_roscom_midas_cooldown", "items/item_roscommidas", LUA_MODIFIER_MOTION_NONE)

item_roscom_midas = class({})

function item_roscom_midas:GetIntrinsicModifierName()
    return "modifier_item_roscom_midas"
end

function item_roscom_midas:CastFilterResultTarget(target)
    if target:HasModifier("modifier_item_roscom_midas_cooldown") then
        return UF_FAIL_CUSTOM
    end
    if not target:IsRealHero() then
        return UF_FAIL_CUSTOM
    end
    if target:HasModifier("modifier_kelthuzad_death_knight") then
        return UF_FAIL_CONSIDERED_HERO
    end
    local nResult = UnitFilter( target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, self:GetCaster():GetTeamNumber() )
    if nResult ~= UF_SUCCESS then
        return nResult
    end
    return UF_SUCCESS
end 

function item_roscom_midas:GetCustomCastErrorTarget(target)
    if target:HasModifier("modifier_item_roscom_midas_cooldown") then
        return "#dota_hud_error_roscom_midas"
    end
end

function item_roscom_midas:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local gold_percent = self:GetSpecialValueFor("gold")
    local gold_base = self:GetSpecialValueFor("gold_b")
    local gold = math.floor(target:GetGold() / 100 * gold_percent) + gold_base
    if target:TriggerSpellAbsorb(self) then return end
	target:EmitSound("DOTA_Item.Hand_Of_Midas")
	local midas_particle = ParticleManager:CreateParticle("particles/roscommidas/roscom_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)	
	ParticleManager:SetParticleControlEnt(midas_particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), false)
	SendOverheadEventMessage(self:GetCaster(), OVERHEAD_ALERT_GOLD, self:GetCaster(), gold, nil)
    if gold > 400 then
        self:GetCaster():EmitSound("midas_special")
    end
	target:ModifyGold(-gold, false, 0)
	self:GetCaster():ModifyGold(gold, false, 0)
    target:AddNewModifier(self:GetCaster(), self, "modifier_item_roscom_midas_cooldown", {duration = 15})
end

modifier_item_roscom_midas_cooldown = class({})

function modifier_item_roscom_midas_cooldown:IsHidden()
    return false
end

function modifier_item_roscom_midas_cooldown:IsPurgable()
    return false
end

function modifier_item_roscom_midas_cooldown:IsPurgeException()
    return false
end

function modifier_item_roscom_midas_cooldown:GetTexture()
    return "items/roscommidas"
end

modifier_item_roscom_midas = class({})

function modifier_item_roscom_midas:IsHidden() return true end
function modifier_item_roscom_midas:IsPurgable() return false end
function modifier_item_roscom_midas:IsPurgeException() return false end
function modifier_item_roscom_midas:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_roscom_midas:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_item_roscom_midas:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('Attackspeed')
end

function modifier_item_roscom_midas:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('atribute')
end

function modifier_item_roscom_midas:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('atribute')
end

function modifier_item_roscom_midas:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('atribute')
end

function modifier_item_roscom_midas:OnCreated()
    if not IsServer() then return end
    self.bonus_gold_min = self:GetAbility():GetSpecialValueFor("passive_bonus") / 60
    self:StartIntervalThink(1)
end

function modifier_item_roscom_midas:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_roscom_midas")[1] ~= self then return end

    if self:GetParent():IsRealHero() then
        self:GetParent():ModifyGold(self.bonus_gold_min, true, DOTA_ModifyXP_Outpost)
    end

    if not self:GetParent():IsHero() and not self:GetParent():IsRealHero() and self:GetParent():GetOwner() ~= nil then
        self:GetParent():GetOwner():ModifyGold(self.bonus_gold_min, true, DOTA_ModifyXP_Outpost)
    end
end

LinkLuaModifier("modifier_item_hand_of_midas_custom", "items/item_roscommidas", LUA_MODIFIER_MOTION_NONE)

item_hand_of_midas_custom = class({})

function item_hand_of_midas_custom:GetIntrinsicModifierName()
    return "modifier_item_hand_of_midas_custom"
end

modifier_item_hand_of_midas_custom = class({})

function modifier_item_hand_of_midas_custom:IsHidden() return true end
function modifier_item_hand_of_midas_custom:IsPurgable() return false end
function modifier_item_hand_of_midas_custom:IsPurgeException() return false end
function modifier_item_hand_of_midas_custom:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_hand_of_midas_custom:OnCreated()
    if not IsServer() then return end
    self.bonus_gold_min = self:GetAbility():GetSpecialValueFor("passive_bonus") / 60
    self:StartIntervalThink(1)
end

function modifier_item_hand_of_midas_custom:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_hand_of_midas_custom")[1] ~= self then return end
    if self:GetParent():HasModifier("modifier_item_roscom_midas") then return end

    if self:GetParent():IsRealHero() then
        self:GetParent():ModifyGold(self.bonus_gold_min, true, DOTA_ModifyXP_Outpost)
    end

    if not self:GetParent():IsHero() and not self:GetParent():IsRealHero() and self:GetParent():GetOwner() ~= nil then
        self:GetParent():GetOwner():ModifyGold(self.bonus_gold_min, true, DOTA_ModifyXP_Outpost)
    end
end

function modifier_item_hand_of_midas_custom:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_item_hand_of_midas_custom:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_attackspeed')
end