LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_item_mega_spinner", "items/spinner", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mega_spinner_slow", "items/spinner", LUA_MODIFIER_MOTION_NONE)

item_mega_spinner = class({})

function item_mega_spinner:GetIntrinsicModifierName()
	return "modifier_item_mega_spinner"
end

modifier_item_mega_spinner = class({})

function modifier_item_mega_spinner:IsHidden() return true end
function modifier_item_mega_spinner:IsPurgable() return false end
function modifier_item_mega_spinner:IsPurgeException() return false end
function modifier_item_mega_spinner:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mega_spinner:OnCreated()
	if not IsServer() then return end
	self.critProc = false
end

function modifier_item_mega_spinner:CheckState()
	local state = {}
	if IsServer() then
		state[MODIFIER_STATE_CANNOT_MISS] = self.critProc
	end
	return state
end

function modifier_item_mega_spinner:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_START
	}
end

function modifier_item_mega_spinner:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end
end

function modifier_item_mega_spinner:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end

function modifier_item_mega_spinner:OnAttackStart(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_mega_spinner")[1] ~= self then return end
	if RollPercentage( self:GetAbility():GetSpecialValueFor("chance") ) then
		self.critProc = true
	else
		self.critProc = false
	end
end

function modifier_item_mega_spinner:OnAttackLanded(params)
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_mega_spinner")[1] ~= self then return end
	if not params.attacker:IsIllusion() and self.critProc and params.attacker:GetUnitName() ~= "npc_palnoref_chariot_illusion" and params.attacker:GetUnitName() ~= "npc_palnoref_chariot_illusion_2" then
		local duration = self:GetAbility():GetSpecialValueFor("duration")
        local damage = self:GetAbility():GetSpecialValueFor("damage")
		local caster = self:GetCaster()

	    if not self:GetCaster():IsHero() then
	        caster = caster:GetOwner()
	    end

	    local player = caster:GetPlayerID()

		if DonateShopIsItemBought(player, 51) then
			local particle = ParticleManager:CreateParticle("particles/econ/items/mega_spinner.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
			ParticleManager:SetParticleControl(particle, 0, params.target:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(200,0,0))
		else
			local particle = ParticleManager:CreateParticle("particles/custom/items/hammer_of_titans_cleave.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
			ParticleManager:SetParticleControl(particle, 0, params.target:GetAbsOrigin())
		end

        ApplyDamage({victim = params.target, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
        params.target:EmitSound("DOTA_Item.MKB.melee")
        params.target:EmitSound("DOTA_Item.MKB.Minibash")
        params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_mega_spinner_slow", {duration = duration})
    end
end

modifier_item_mega_spinner_slow = class({})

function modifier_item_mega_spinner_slow:IsHidden() return false end
function modifier_item_mega_spinner_slow:IsPurgable() return false end

function modifier_item_mega_spinner_slow:GetTexture()
    return "Items/mega_spinner"
end

function modifier_item_mega_spinner_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_item_mega_spinner_slow:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("movement_speed_slow")
end









