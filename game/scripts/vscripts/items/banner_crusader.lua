LinkLuaModifier( "modifier_item_banner_crusader", "items/banner_crusader", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_banner_crusader_aura", "items/banner_crusader", LUA_MODIFIER_MOTION_NONE )

item_banner_crusader = class({})

function item_banner_crusader:OnSpellStart()
	if not IsServer() then return end
	local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(),nil,self:GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
	for _,target in pairs(targets) do
		for _, mod in pairs(target:FindAllModifiersByName("modifier_item_sphere_target")) do
			if mod then
				mod:Destroy()
			end
		end
		target:AddNewModifier(self:GetCaster(), self, "modifier_item_sphere_target", {duration = 15})
		target:AddNewModifier(self:GetCaster(), self, "modifier_item_banner_crusader_aura", {duration = 15})
		self:GetCaster():EmitSound("Hero_LegionCommander.Overwhelming.Cast")
		target:EmitSound("Hero_LegionCommander.Overwhelming.Buff")
		local particle = ParticleManager:CreateParticle( "particles/econ/items/legion/legion_overwhelming_odds_ti7/legion_commander_odds_ti7.vpcf", PATTACH_ABSORIGIN, target )
		ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle, 4, Vector(100*1.5, 100*1.5, 100*1.5))
	end
end

function item_banner_crusader:GetIntrinsicModifierName() 
	return "modifier_item_banner_crusader"
end

modifier_item_banner_crusader = class({})

function modifier_item_banner_crusader:IsHidden() return true end
function modifier_item_banner_crusader:IsPurgable() return false end
function modifier_item_banner_crusader:IsPurgeException() return false end
function modifier_item_banner_crusader:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_banner_crusader:DeclareFunctions()
	return 	
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK_SPECIAL,
	}
end

function modifier_item_banner_crusader:GetModifierPhysicalArmorBonus()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_banner_crusader:GetModifierHealthBonus()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_banner_crusader:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_banner_crusader:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_banner_crusader:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_banner_crusader:GetModifierConstantHealthRegen()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_hp_regen")
end

function modifier_item_banner_crusader:GetModifierConstantManaRegen()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_banner_crusader:GetModifierPhysical_ConstantBlockSpecial()
	if not self:GetAbility() then return end
	if RollPercentage(self:GetAbility():GetSpecialValueFor("damage_block_chance")) then
   		return self:GetAbility():GetSpecialValueFor("damage_block")
   	end
end

modifier_item_banner_crusader_aura = class({})

function modifier_item_banner_crusader_aura:OnCreated()
	if not IsServer() then return end

	self.crimson_guard_pfx = ParticleManager:CreateParticle("particles/banner_crusader_shield_from_felix_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	if self:GetParent():ScriptLookupAttachment( "attach_hitloc" ) == 0 then
		ParticleManager:SetParticleControl(self.crimson_guard_pfx, 1, self:GetParent():GetAbsOrigin() + Vector(0,0,120))
	else
		ParticleManager:SetParticleControlEnt(self.crimson_guard_pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	end

	self:AddParticle(self.crimson_guard_pfx, false, false, -1, false, false)
end

function modifier_item_banner_crusader_aura:DeclareFunctions()
	return 	
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK_SPECIAL,
	}
end

function modifier_item_banner_crusader_aura:GetModifierPhysicalArmorBonus()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_armor_active")
end

function modifier_item_banner_crusader_aura:GetModifierAttackSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_banner_crusader_aura:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_item_banner_crusader_aura:GetModifierPhysical_ConstantBlockSpecial()
	if not self:GetAbility() then return end
   	return self:GetAbility():GetSpecialValueFor("damage_block")
end

function modifier_item_banner_crusader_aura:GetTexture()
  	return "items/banner_crusader"
end