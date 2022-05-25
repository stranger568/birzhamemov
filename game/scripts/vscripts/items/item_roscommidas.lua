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
    local nResult = UnitFilter( target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber() )
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
    target:AddNewModifier(self:GetCaster(), self, "modifier_item_roscom_midas_cooldown", {duration = 30})
end

modifier_item_roscom_midas_cooldown = class({})

function modifier_item_roscom_midas_cooldown:IsHidden()
    return false
end

function modifier_item_roscom_midas_cooldown:IsPurgable()
    return false
end

function modifier_item_roscom_midas_cooldown:GetTexture()
    return "items/roscommidas"
end

modifier_item_roscom_midas = class({})

function modifier_item_roscom_midas:IsHidden()
    return true
end

function modifier_item_roscom_midas:IsPurgable()
    return false
end

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
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('Attackspeed')
    end
end

function modifier_item_roscom_midas:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('atribute')
    end
end

function modifier_item_roscom_midas:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('atribute')
    end
end

function modifier_item_roscom_midas:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('atribute')
    end
end