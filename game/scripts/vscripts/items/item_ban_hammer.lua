LinkLuaModifier("modifier_item_ban_hammer", "items/item_ban_hammer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_phylactery_custom_debuff", "items/item_phylactery_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ban_hammer_phylactery_cooldown", "items/item_ban_hammer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ban_hammer_debuff_damage", "items/item_ban_hammer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

item_ban_hammer = class({})

function item_ban_hammer:GetIntrinsicModifierName()
	return "modifier_item_ban_hammer"
end

function item_ban_hammer:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function item_ban_hammer:OnSpellStart()
	if not IsServer() then return end
	local position	= self:GetCursorPosition()
	AddFOWViewer(self:GetCaster():GetTeam(), position, self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("land_time")+0.5, false)
	self:GetCaster():EmitSound("DOTA_Item.MeteorHammer.Cast")
	local land_time = self:GetSpecialValueFor("land_time")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local radius = self:GetSpecialValueFor("radius")
	local burn_duration = self:GetSpecialValueFor("damage_duration")
	local start_damage = self:GetSpecialValueFor("damage_per_hit")

	local ground_particle = ParticleManager:CreateParticleForTeam("particles/ban_hammer_aoe.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeam())
	ParticleManager:SetParticleControl(ground_particle, 0, position)
	ParticleManager:SetParticleControl(ground_particle, 1, Vector(radius, 1, 1))

	local meteor_hammer	= ParticleManager:CreateParticle("particles/ban_hammer_cast_spell.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(meteor_hammer, 0, position + Vector(0, 0, 1000))
	ParticleManager:SetParticleControl(meteor_hammer, 1, position)
	ParticleManager:SetParticleControl(meteor_hammer, 2, Vector(land_time, 0, 0))
	ParticleManager:ReleaseParticleIndex(meteor_hammer)

	Timers:CreateTimer(land_time, function()
		if not self:IsNull() then
			ParticleManager:DestroyParticle(ground_particle, false)
			GridNav:DestroyTreesAroundPoint(position, radius, true)
			EmitSoundOnLocationWithCaster(position, "DOTA_Item.MeteorHammer.Impact", self:GetCaster())
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				enemy:EmitSound("DOTA_Item.MeteorHammer.Damage")
				enemy:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = stun_duration * (1 - enemy:GetStatusResistance())})
				enemy:AddNewModifier(self:GetCaster(), self, "modifier_item_ban_hammer_debuff_damage", {duration = burn_duration * (1 - enemy:GetStatusResistance())})
				ApplyDamage({ victim = enemy, damage = start_damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, attacker = self:GetCaster(), ability = self })
			end
		end
	end)
end

modifier_item_ban_hammer = class({})
function modifier_item_ban_hammer:IsPurgable() return false end
function modifier_item_ban_hammer:IsHidden() return true end
function modifier_item_ban_hammer:IsPurgeException() return false end
function modifier_item_ban_hammer:IsPurgable() return false end
function modifier_item_ban_hammer:RemoveOnDeath() return false end

function modifier_item_ban_hammer:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end

function modifier_item_ban_hammer:OnTakeDamage(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if not self:GetParent():IsRealHero() then return end
	if params.unit == self:GetParent() then return end
	if params.inflictor == nil then return end
	if params.inflictor == self:GetAbility() then return end
	if params.inflictor:IsItem() then return end
	if params.damage < self:GetAbility():GetSpecialValueFor("min_damage_to_activate") then return end
	if self:GetParent():HasModifier("modifier_item_ban_hammer_phylactery_cooldown") then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_ban_hammer")[1] ~= self then return end
	if (self:GetParent():GetAbsOrigin() - params.unit:GetAbsOrigin()):Length2D() > 1200 then return end
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_ban_hammer_phylactery_cooldown", {duration = self:GetAbility():GetSpecialValueFor("phylactery_cooldown")})
	ApplyDamage({attacker = self:GetCaster(), victim = params.unit, ability = self:GetAbility(), damage = self:GetAbility():GetSpecialValueFor("bonus_spell_damage"), damage_type = DAMAGE_TYPE_MAGICAL})
	params.unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_ban_hammer_debuff", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
	local particle = ParticleManager:CreateParticle("particles/ban_hammer_phylactery.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.unit)
	ParticleManager:SetParticleControlEnt(particle, 0, params.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", params.unit:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)
	local particle_2 = ParticleManager:CreateParticle("particles/ban_hammer_phylactery_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(particle_2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle_2, 1, params.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", params.unit:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle_2)
	params.unit:EmitSound("Item.Phylactery.Target")
end

function modifier_item_ban_hammer:GetModifierManaBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_mana")
	end
end

function modifier_item_ban_hammer:GetModifierHealthBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_health")
	end
end

function modifier_item_ban_hammer:GetModifierConstantManaRegen()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("mana_regen")
	end
end


function modifier_item_ban_hammer:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
	end
end

function modifier_item_ban_hammer:GetModifierBonusStats_Agility()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
	end
end

function modifier_item_ban_hammer:GetModifierBonusStats_Intellect()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
	end
end

function modifier_item_ban_hammer:GetModifierConstantHealthRegen()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("health_regen")
	end
end

modifier_item_ban_hammer_phylactery_cooldown = class({})
function modifier_item_ban_hammer_phylactery_cooldown:IsDebuff() return true end
function modifier_item_ban_hammer_phylactery_cooldown:IsPurgable() return false end
function modifier_item_ban_hammer_phylactery_cooldown:IsPurgeException() return false end
function modifier_item_ban_hammer_phylactery_cooldown:RemoveOnDeath() return false end

modifier_item_ban_hammer_debuff_damage = class({})

function modifier_item_ban_hammer_debuff_damage:GetEffectName()
	return "particles/ban_hammer_debuff.vpcf"
end

function modifier_item_ban_hammer_debuff_damage:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(1)
end

function modifier_item_ban_hammer_debuff_damage:OnIntervalThink()
	if not IsServer() then return end	
	local damage_in = ApplyDamage({attacker = self:GetCaster(), victim = self:GetParent(), ability = self:GetAbility(), damage = self:GetAbility():GetSpecialValueFor("period_damage"), damage_type = DAMAGE_TYPE_MAGICAL})
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), damage_in, nil)
end