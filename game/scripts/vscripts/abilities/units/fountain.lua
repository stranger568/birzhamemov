LinkLuaModifier( "modifier_birzha_fountain_passive", "abilities/units/fountain.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_fountain_passive_invul", "abilities/units/fountain.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_fountain_attacked", "abilities/units/fountain.lua", LUA_MODIFIER_MOTION_NONE )

ability_fountain = class({})

function ability_fountain:GetIntrinsicModifierName()
	return "modifier_birzha_fountain_passive"
end

modifier_birzha_fountain_passive = class({})

function modifier_birzha_fountain_passive:IsHidden()
	return true
end

function modifier_birzha_fountain_passive:GetModifierAura()
	return "modifier_fountain_passive_invul"
end

function modifier_birzha_fountain_passive:IsAura()
	return true
end

function modifier_birzha_fountain_passive:GetAuraRadius()
	return 1150
end

function modifier_birzha_fountain_passive:GetAuraDuration()
	return 0.1
end

function modifier_birzha_fountain_passive:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_birzha_fountain_passive:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

function modifier_birzha_fountain_passive:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_birzha_fountain_passive:GetAuraEntityReject(target)
	if IsServer() then
		if target:HasModifier("modifier_birzha_fountain_attacked") then
			return true
		else
			return false
		end
	end
end

function modifier_birzha_fountain_passive:OnCreated()
	self:StartIntervalThink(0.5)
end

function modifier_birzha_fountain_passive:OnIntervalThink()
	if not IsServer() then return end
    self:GetParent():RemoveModifierByName("modifier_fountain_aura")
    if BIRZHA_FOUNTAIN_GAME_TIMER <= 0 then return end
	local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 1150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false )
	for _,target in pairs(units) do
        if target:IsRealHero() then
		    target:EmitSound("Ability.LagunaBlade")
        end
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetOrigin() + Vector( 0, 0, 96 ), true )
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		ApplyDamage({attacker = self:GetParent(), victim = target, ability = self:GetAbility(), damage = target:GetMaxHealth() * 0.2, damage_type = DAMAGE_TYPE_PURE})
        if not target:IsRealHero() then
            target:Kill(self:GetAbility(), self:GetParent())
        end
	end
end

modifier_fountain_passive_invul = class({})
function modifier_fountain_passive_invul:IsPurgable() return false end
function modifier_fountain_passive_invul:IsPurgeException() return false end

function modifier_fountain_passive_invul:OnCreated()
	if not IsServer() then return end
    if self:GetParent():IsRealHero() then
        local player = self:GetParent():GetPlayerOwnerID()
        if DonateShopIsItemBought(player, 44) then
            local particle = ParticleManager:CreateParticle("particles/abilities/shengminghuifuguanghuan.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
            self:AddParticle(particle, false, false, -1, false, false)
            local particle2 = ParticleManager:CreateParticle("particles/birzhapass/fountain_regen_birzha.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(particle2, 0, self:GetParent():GetAbsOrigin())
            self:AddParticle(particle2, false, false, -1, false, false)
        end
    end
    self:OnIntervalThink()
	self:StartIntervalThink(1)
end

function modifier_fountain_passive_invul:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_birzha_disconnect") then
		self:GetParent():RemoveModifierByName("modifier_fountain_invulnerability")
	end
end

function modifier_fountain_passive_invul:DeclareFunctions()
	local funcs = 
    {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_fountain_passive_invul:GetAbsoluteNoDamagePhysical()
	if BIRZHA_FOUNTAIN_GAME_TIMER and BIRZHA_FOUNTAIN_GAME_TIMER <= 0 then return end
	return 1
end

function modifier_fountain_passive_invul:GetAbsoluteNoDamageMagical()
	if BIRZHA_FOUNTAIN_GAME_TIMER and BIRZHA_FOUNTAIN_GAME_TIMER <= 0 then return end
	return 1
end

function modifier_fountain_passive_invul:GetAbsoluteNoDamagePure()
	if BIRZHA_FOUNTAIN_GAME_TIMER and BIRZHA_FOUNTAIN_GAME_TIMER <= 0 then return end
	return 1
end

function modifier_fountain_passive_invul:CheckState()
	if BIRZHA_FOUNTAIN_GAME_TIMER and BIRZHA_FOUNTAIN_GAME_TIMER <= 0 then return end
	return 
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true, 
    }
end

function modifier_fountain_passive_invul:OnTakeDamage( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() and params.attacker ~= self:GetParent() then
    	if BIRZHA_FOUNTAIN_GAME_TIMER and BIRZHA_FOUNTAIN_GAME_TIMER <= 0 then return end
    	params.unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_fountain_attacked", { duration = 5 } )
    end
end

function modifier_fountain_passive_invul:GetTexture()
	return "rune_regen"
end

function modifier_fountain_passive_invul:GetModifierHealthRegenPercentage( params )
	return 20
end

function modifier_fountain_passive_invul:GetModifierTotalPercentageManaRegen( params )
	return 20
end

function modifier_fountain_passive_invul:GetModifierConstantManaRegen( params )
	return 30
end

modifier_birzha_fountain_attacked = class({})
function modifier_birzha_fountain_attacked:IsHidden() return true end
function modifier_birzha_fountain_attacked:IsPurgable() return false end
function modifier_birzha_fountain_attacked:IsPurgeException() return false end
function modifier_birzha_fountain_attacked:DeclareFunctions()
	local funcs = 
    {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end
function modifier_birzha_fountain_attacked:OnTakeDamage( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() and params.attacker ~= self:GetParent() then
    	params.unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_fountain_attacked", { duration = 5 } )
    end
end