LinkLuaModifier( "modifier_never_shadowraze", "abilities/heroes/never/never_shadowraze.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_never_shadowraze_shard", "abilities/heroes/never/never_shadowraze.lua", LUA_MODIFIER_MOTION_NONE )

never_shadowraze_a = class({})
never_shadowraze_b = class({})
never_shadowraze_c = class({})

function never_shadowraze_a:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/never_shadowraze1_arcana"
	end
	return "Never/never_shadowraze1"
end

function never_shadowraze_b:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/never_shadowraze2_arcana"
	end
	return "Never/never_shadowraze2"
end

function never_shadowraze_c:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		return "Never/never_shadowraze3_arcana"
	end
	return "Never/never_shadowraze3"
end

function never_shadowraze_a:OnSpellStart()
	shadowraze.OnSpellStart( self )
end

function never_shadowraze_b:OnSpellStart()
	shadowraze.OnSpellStart( self )
end
function never_shadowraze_c:OnSpellStart()
	shadowraze.OnSpellStart( self )
end

if shadowraze==nil then
	shadowraze = {}
end

function never_shadowraze_a:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_double.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_triple.vpcf", context)
	PrecacheResource("particle", "particles/never/never_shadowraze_tripletriple.vpcf", context)
	PrecacheResource("particle", "particles/never/never_shadowraze_doubledouble.vpcf", context)
	PrecacheResource("particle", "particles/never/never_shadowraze_debuff.vpcf", context)
end

function shadowraze.GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function shadowraze.GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function shadowraze.GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function shadowraze.OnSpellStart( abil )
	if not IsServer() then return end
	local distance = abil:GetSpecialValueFor("shadowraze_range")
	local front = abil:GetCaster():GetForwardVector():Normalized()
	local target_pos = abil:GetCaster():GetOrigin() + front * distance
	local target_radius = abil:GetSpecialValueFor("shadowraze_radius")
	local base_damage = abil:GetSpecialValueFor("shadowraze_damage")
	local stack_damage = abil:GetSpecialValueFor("stack_bonus_damage")
	local stack_duration = abil:GetSpecialValueFor("duration")
	local cooldown_shard = abil:GetSpecialValueFor("shadowraze_cooldown_shard")
	local shard_check = false

	local enemies = FindUnitsInRadius(
		abil:GetCaster():GetTeamNumber(),
		target_pos,
		nil,
		target_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in pairs(enemies) do
		local modifier = enemy:FindModifierByNameAndCaster("modifier_never_shadowraze", abil:GetCaster())
		local shard_modifier = abil:GetCaster():FindModifierByName("modifier_never_shadowraze_shard")
		local stack = 0

		if modifier~=nil then
			stack = modifier:GetStackCount()
		end

		local damageTable = {
			victim = enemy,
			attacker = abil:GetCaster(),
			damage = base_damage + stack*stack_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = abil,
		}
		ApplyDamage( damageTable )

		abil:GetCaster():PerformAttack(enemy, true, true, true, false, true, false, true)

		if modifier==nil then
			enemy:AddNewModifier(
				abil:GetCaster(),
				abil,
				"modifier_never_shadowraze",
				{duration = stack_duration * (1 - enemy:GetStatusResistance())}
			)
		else
			modifier:IncrementStackCount()
			modifier:ForceRefresh()
		end

		if enemy:IsRealHero() then
			if not shard_check then 
				if abil:GetCaster():HasShard() then
					if shard_modifier == nil then
						abil:GetCaster():AddNewModifier(abil:GetCaster(), abil, "modifier_never_shadowraze_shard", {duration = abil:GetSpecialValueFor("shard_duration")})
					else
						shard_modifier:IncrementStackCount()
						shard_modifier:ForceRefresh()
						if shard_modifier:GetStackCount() == 2 then 
							shadowraze.PlayEffects1( abil, abil:GetCaster():GetAbsOrigin() )
						elseif shard_modifier:GetStackCount() >= 3 then
							local abilities = {
								abil1 = abil:GetCaster():FindAbilityByName("never_shadowraze_a"),
								abil2 = abil:GetCaster():FindAbilityByName("never_shadowraze_b"),
								abil3 = abil:GetCaster():FindAbilityByName("never_shadowraze_c")
							}
							shadowraze.PlayEffects2( abil, abil:GetCaster():GetAbsOrigin() )
							for _, v in pairs(abilities) do
								local cooldown = v:GetCooldownTimeRemaining()
								if cooldown - cooldown_shard <= 0 then
    							    v:EndCooldown()
    							else
    							    v:EndCooldown()
    							    v:StartCooldown(cooldown - cooldown_shard)
    							end
							end
							shard_modifier:Destroy()
						end
					end
				end
				shard_check = true
			end
		end
	end

	shadowraze.PlayEffects( abil, target_pos, target_radius )
end

function shadowraze.PlayEffects( abil, position, radius )
	local particle_cast = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"
	local sound_cast = "Hero_Nevermore.Shadowraze"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( effect_cast, 0, position )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, 1, 1 ) )
	if abil:GetCaster():HasModifier("modifier_bp_never_reward") then
		ParticleManager:SetParticleControl( effect_cast, 60, Vector( 0, 246, 255 ) )
		ParticleManager:SetParticleControl( effect_cast, 61, Vector( 1, 1, 1 ) )
	end
	EmitSoundOnLocationWithCaster( position, sound_cast, abil:GetCaster() )
end

function shadowraze.PlayEffects1( abil, pos )
	local particle_cast = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_double.vpcf"
	if abil:GetCaster():HasModifier("modifier_bp_never_reward") then
		particle_cast = "particles/never/never_shadowraze_doubledouble.vpcf"
	end
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, abil:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, pos)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function shadowraze.PlayEffects2( abil, pos )
	local particle_cast = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_triple.vpcf"
	if abil:GetCaster():HasModifier("modifier_bp_never_reward") then
		particle_cast = "particles/never/never_shadowraze_tripletriple.vpcf"
	end
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, abil:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, pos)
	ParticleManager:ReleaseParticleIndex( effect_cast )
	abil:GetCaster():EmitSound("shadowraze_coil")
end

modifier_never_shadowraze = class({})

function modifier_never_shadowraze:IsHidden() return false end
function modifier_never_shadowraze:IsDebuff() return true end
function modifier_never_shadowraze:IsPurgable() return false end
function modifier_never_shadowraze:GetEffectName() 
	local projectile_name = "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
	if self:GetCaster():HasModifier("modifier_bp_never_reward") then
		projectile_name = "particles/never/never_shadowraze_debuff.vpcf"
	end
	return projectile_name
end
function modifier_never_shadowraze:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_never_shadowraze:OnCreated( kv ) self:SetStackCount(1) end
function modifier_never_shadowraze:OnRefresh( kv ) end

function modifier_never_shadowraze:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_never_shadowraze:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("shadowraze_slow") * self:GetStackCount()
end

modifier_never_shadowraze_shard = class({})

function modifier_never_shadowraze_shard:IsHidden() return false end
function modifier_never_shadowraze_shard:IsDebuff() return false end
function modifier_never_shadowraze_shard:IsPurgable() return false end
function modifier_never_shadowraze_shard:OnCreated( kv ) self:SetStackCount(1) end
function modifier_never_shadowraze_shard:OnRefresh( kv ) end