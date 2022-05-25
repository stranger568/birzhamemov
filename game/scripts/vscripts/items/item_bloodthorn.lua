LinkLuaModifier("modifier_item_bloodthorn_arena", "items/item_bloodthorn", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bloodthorn_arena_silence", "items/item_bloodthorn", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bloodthorn_arena_crit", "items/item_bloodthorn", LUA_MODIFIER_MOTION_NONE)

item_bloodthorn_baseclass = {
	GetIntrinsicModifierName = function() return "modifier_item_bloodthorn_arena" end,
}

if IsServer() then
	function item_bloodthorn_baseclass:OnSpellStart()
		local target = self:GetCursorTarget()
		if not target:TriggerSpellAbsorb(self) then
			target:TriggerSpellReflect(self)
			target:EmitSound("DOTA_Item.Orchid.Activate")
			target:AddNewModifier(self:GetCaster(), self, "modifier_item_bloodthorn_arena_silence", {duration = self:GetSpecialValueFor("duration")})
			target:Purge(true, false, false, false, false)
			if self:GetCaster():GetUnitName() == "npc_dota_hero_void_spirit" then
		        self:GetCaster():EmitSound("van_orchid")
		    end
		end
	end
end

item_bloodthorn_2 = class(item_bloodthorn_baseclass)


modifier_item_bloodthorn_arena = class({
	IsHidden      = function() return true end,
	IsPurgable    = function() return false end,
})

function modifier_item_bloodthorn_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, 
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_item_bloodthorn_arena:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_bloodthorn_arena:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_bloodthorn_arena:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_regenhp")
end

function modifier_item_bloodthorn_arena:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_bloodthorn_arena:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_bloodthorn_arena:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_bloodthorn_arena:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_regenmana")
end

if IsServer() then
	function modifier_item_bloodthorn_arena:GetModifierPreAttack_CriticalStrike(k)
		local ability = self:GetAbility()
		if RollPercentage(ability:GetSpecialValueFor("passive_chance")) then
			return ability:GetSpecialValueFor("passive_crit")
		end
	end
	
	function modifier_item_bloodthorn_arena:OnAttackLanded(params)
		local target = params.target
		
		if params.attacker == self:GetParent() then
			if not target:IsMagicImmune() then
				if self:GetParent():IsIllusion() then
					target:ReduceMana(25)
				else
					target:ReduceMana(50)
				end
			end
		end
	end
end

modifier_item_bloodthorn_arena_silence = class({
	IsDebuff =            function() return true end,
	GetEffectAttachType = function() return PATTACH_OVERHEAD_FOLLOW end,
	GetEffectName =       function() return "particles/items2_fx/orchid.vpcf" end,
})

function modifier_item_bloodthorn_arena_silence:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_EVADE_DISABLED] = true,
		[MODIFIER_STATE_MUTED] = true,
	}
end

function modifier_item_bloodthorn_arena_silence:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_item_bloodthorn_arena_silence:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("crit_active")
end

function modifier_item_bloodthorn_arena_silence:GetModifierMoveSpeedBonus_Percentage()
	return -80
end


if IsServer() then
	function modifier_item_bloodthorn_arena_silence:OnTakeDamage(keys)
		local parent = self:GetParent()
		if parent == keys.unit then
			ParticleManager:SetParticleControl(ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.unit), 1, Vector(keys.damage))
			self.damage = (self.damage or 0) + keys.damage
		end
	end

	function modifier_item_bloodthorn_arena_silence:OnAttackStart(keys)
		local parent = self:GetParent()
		if parent == keys.target then
			local ability = self:GetAbility()
			keys.attacker:AddNewModifier(parent, self:GetAbility(), "modifier_item_bloodthorn_arena_crit", {duration = 1.5})
		end
	end

	function modifier_item_bloodthorn_arena_silence:OnDestroy()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local damage = (self.damage or 0) * ability:GetSpecialValueFor("damage_pct") * 0.01
		ParticleManager:SetParticleControl(ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent), 1, Vector(damage))
		if damage > 0 then
			ApplyDamage({
				attacker = self:GetCaster(),
				victim = parent,
				damage = damage,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				ability = ability
			})
		end
	end
end


modifier_item_bloodthorn_arena_crit = class({
	IsHidden =   function() return true end,
	IsPurgable = function() return false end,
})

if IsServer() then
	function modifier_item_bloodthorn_arena_crit:DeclareFunctions()
		return {
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
			MODIFIER_EVENT_ON_ATTACK_LANDED
		}
	end

	function modifier_item_bloodthorn_arena_crit:GetModifierPreAttack_CriticalStrike(keys)
		if keys.target == self:GetCaster() and keys.target:HasModifier("modifier_item_bloodthorn_arena_silence") then
			return self:GetAbility():GetSpecialValueFor("crit_active")
		else
			if not self:IsNull() then
                self:Destroy()
            end
		end
	end

	function modifier_item_bloodthorn_arena_crit:OnAttackLanded(keys)
		if self:GetParent() == keys.attacker then
			keys.attacker:RemoveModifierByName("modifier_item_bloodthorn_arena_crit")
		end
	end
end
