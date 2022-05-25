LinkLuaModifier("modifier_item_spinner", "items/spinner", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

item_spinner = class({})

function item_spinner:GetIntrinsicModifierName()
	return "modifier_item_spinner"
end

modifier_item_spinner = class({})

function modifier_item_spinner:IsHidden()		return true end
function modifier_item_spinner:IsPurgable()		return false end
function modifier_item_spinner:RemoveOnDeath()	return false end

function modifier_item_spinner:OnCreated()
	if not IsServer() then return end
	self.critProc = false
end

function modifier_item_spinner:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_RECORD
	}
end

function modifier_item_spinner:OnAttackRecord(keys)
	if keys.attacker == self:GetParent() then
		if keys.target:IsOther() then
            return nil
        end
		if self.critProc then
			self.critProc = false
		end
		self.chance = self:GetAbility():GetSpecialValueFor("minibash_chance")
        if self.chance >= RandomInt(1, 100) then
        	self.critProc = true
        end
	end
end

function modifier_item_spinner:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_spinner:OnAttackLanded(keys)
    if keys.attacker == self:GetParent() then
        if keys.target:IsOther() then
            return nil
        end
        self.chance = self:GetAbility():GetSpecialValueFor("minibash_chance")
        local damage = self:GetAbility():GetSpecialValueFor("bash_damage")
        if self.critProc then
            if self:GetParent():IsIllusion() then return end
            self:GetParent():EmitSound("DOTA_Item.MKB.Minibash")
            ApplyDamage({victim = keys.target, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
        end
    end
end

function modifier_item_spinner:CheckState()
	local state = {}
	
	if self.critProc then
		state = {[MODIFIER_STATE_CANNOT_MISS] = true}
	end

	return state
end

LinkLuaModifier("modifier_item_mega_spinner", "items/spinner", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mega_spinner_slow", "items/spinner", LUA_MODIFIER_MOTION_NONE)

item_mega_spinner = class({})

function item_mega_spinner:GetIntrinsicModifierName()
	return "modifier_item_mega_spinner"
end

modifier_item_mega_spinner = class({})

function modifier_item_mega_spinner:IsHidden()		return true end
function modifier_item_mega_spinner:IsPurgable()		return false end
function modifier_item_mega_spinner:RemoveOnDeath()	return false end

function modifier_item_mega_spinner:OnCreated()
	if not IsServer() then return end
	self.critProc = false
end

function modifier_item_mega_spinner:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_RECORD
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

function modifier_item_mega_spinner:OnAttackRecord(keys)
	if keys.attacker == self:GetParent() then
		if keys.target:IsOther() then
            return nil
        end
		if self.critProc then
			self.critProc = false
		end
		self.chance = self:GetAbility():GetSpecialValueFor("chance")
        if self.chance >= RandomInt(1, 100) then
        	self.critProc = true
        end
	end
end

function modifier_item_mega_spinner:OnAttackLanded(keys)
    if keys.attacker == self:GetParent() then
        if keys.target:IsOther() then
            return nil
        end
        if keys.attacker:GetUnitName() == "npc_palnoref_chariot_illusion" then return end
		if keys.attacker:GetUnitName() == "npc_palnoref_chariot_illusion_2" then return end
        if self:GetParent():IsIllusion() then return end
    	local duration = self:GetAbility():GetSpecialValueFor("duration")
        local damage = self:GetAbility():GetSpecialValueFor("damage")
        if self.critProc then
        	local caster = self:GetCaster()

		    if not self:GetCaster():IsHero() then
		        caster = caster:GetOwner()
		    end
        	local player = caster:GetPlayerID()
			if DonateShopIsItemBought(player, 51) then
				local particle = ParticleManager:CreateParticle("particles/econ/items/mega_spinner.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
				ParticleManager:SetParticleControl(particle, 0, keys.target:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 1, Vector(200,0,0))
			else
				local particle = ParticleManager:CreateParticle("particles/custom/items/hammer_of_titans_cleave.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
				ParticleManager:SetParticleControl(particle, 0, keys.target:GetAbsOrigin())
			end
            ApplyDamage({victim = keys.target, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
            keys.target:EmitSound("DOTA_Item.MKB.melee")
            keys.target:EmitSound("DOTA_Item.MKB.Minibash")
            keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_mega_spinner_slow", {duration = duration})
            self:GetAbility():UseResources(false, false, true)
        end
    end
end

function modifier_item_mega_spinner:CheckState()
	local state = {}
	
	if self.critProc then
		state = {[MODIFIER_STATE_CANNOT_MISS] = true}
	end

	return state
end

modifier_item_mega_spinner_slow = class({})

function modifier_item_mega_spinner_slow:IsHidden()		return false end
function modifier_item_mega_spinner_slow:IsPurgable()		return false end

function modifier_item_mega_spinner_slow:GetTexture()
    return "Items/mega_spinner"
end

function modifier_item_mega_spinner_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_item_mega_spinner_slow:OnCreated()
    self.move_speed = self:GetAbility():GetSpecialValueFor("movement_speed_slow")
end

function modifier_item_mega_spinner_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.move_speed
end









