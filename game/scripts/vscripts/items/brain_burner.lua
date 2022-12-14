LinkLuaModifier( "modifier_item_brain_burner", "items/brain_burner", LUA_MODIFIER_MOTION_NONE )

item_brain_burner = class({})

function item_brain_burner:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function item_brain_burner:OnSpellStart()
	if not IsServer() then return end
	local radius = self:GetSpecialValueFor("radius")

	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)

	for _,target in pairs(enemies) do
		local mana = target:GetMana() / 100 * self:GetSpecialValueFor("mana_burn_active")
		target:ReduceMana(mana)
	end

	local particle = ParticleManager:CreateParticle("particles/a_item_burner/item_burner.vpcf",  PATTACH_ABSORIGIN, self:GetCaster()) 
	ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0, 0)) 

	self:GetCaster():EmitSound("Hero_Invoker.EMP.Discharge")
end

function item_brain_burner:GetIntrinsicModifierName() 
	return "modifier_item_brain_burner"
end

modifier_item_brain_burner = class({})

function modifier_item_brain_burner:IsHidden() return true end
function modifier_item_brain_burner:IsPurgable() return false end
function modifier_item_brain_burner:IsPurgeException() return false end
function modifier_item_brain_burner:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_brain_burner:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_item_brain_burner:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_brain_burner:GetModifierAttackSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_brain_burner:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_brain_burner:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_brain_burner")[1] ~= self then return end
	
	local target = params.target

	print("aa")

	if target:IsMagicImmune() then return end

	local manaburn_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(manaburn_pfx, 0, target:GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex(manaburn_pfx)

	local mana_burn_percent = self:GetAbility():GetSpecialValueFor("mana_burn") / 100
	local mana_burn_illusion = self:GetAbility():GetSpecialValueFor("mana_burn_illusion") / 100

	local manaBurn = target:GetMaxMana() * mana_burn_percent

	if self:GetParent():IsIllusion() then
		manaBurn = target:GetMaxMana() * mana_burn_illusion
	end

    local damageTable = {attacker = self:GetParent(), victim = target, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()}

	if (target:GetMana() >= manaBurn) then
		damageTable.damage = manaBurn
		target:ReduceMana(manaBurn)
	else
		damageTable.damage = target:GetMana()
		target:ReduceMana(target:GetMana())
	end

	target:EmitSound("ItemBurn")
	ApplyDamage(damageTable)
end