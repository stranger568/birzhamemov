LinkLuaModifier( "modifier_lolblade_Reflection", "abilities/units/terrorblade_boss.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_reflection_invulnerability", "abilities/units/terrorblade_boss.lua", LUA_MODIFIER_MOTION_NONE )

terror_ability = class({})

function terror_ability:GetIntrinsicModifierName()
    return "modifier_lolblade_Reflection"
end

modifier_lolblade_Reflection = class({})

function modifier_lolblade_Reflection:IsHidden()
    return true
end

function modifier_lolblade_Reflection:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_lolblade_Reflection:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,FIND_ANY_ORDER, false)
	if #heroes == 0 then return end
	if self:GetAbility():IsFullyCastable() then
		self:GetAbility():UseResources(false, false, false, true)
		for _,hero in pairs(heroes) do
			local illusions = BirzhaCreateIllusion( self:GetCaster(), hero, {duration=3,outgoing_damage=0,incoming_damage=0}, 1, 1, true, true ) 
			for k, illusion in pairs(illusions) do
				illusion:AddNewModifier(caster, ability, "modifier_reflection_invulnerability", {})
				illusion:MoveToTargetToAttack(hero)
				illusion:EmitSound("Hero_Terrorblade.Reflection")
			end
		end
	end
end

modifier_reflection_invulnerability = class({})

function modifier_reflection_invulnerability:IsHidden()
    return true
end

function modifier_reflection_invulnerability:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE}
    return decFuncs
end

function modifier_reflection_invulnerability:GetModifierMoveSpeed_Absolute()
    return 522   
end

function modifier_reflection_invulnerability:GetStatusEffectName()
    return "particles/status_fx/status_effect_terrorblade_reflection.vpcf"
end

function modifier_reflection_invulnerability:StatusEffectPriority()
    return 10
end

function modifier_reflection_invulnerability:CheckState()
    local state = {
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,}
    
    return state
end