LinkLuaModifier("modifier_birzha_high_five_thinker", "modifiers/modifier_birzha_high_five", LUA_MODIFIER_MOTION_NONE)

modifier_birzha_high_five = class({})

function modifier_birzha_high_five:OnCreated()
	if not IsServer() then return end
	self:GetParent():EmitSound("high_five.cast")
	self:StartIntervalThink(FrameTime())
end

function modifier_birzha_high_five:IsHidden() return true end
function modifier_birzha_high_five:IsPurgable() return false end
function modifier_birzha_high_five:IsPurgeException() return false end

function modifier_birzha_high_five:OnIntervalThink()
	if not IsServer() then return end
	local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
	for k, hero in pairs(units) do
		if hero ~= self:GetParent() then
			if hero:HasModifier("modifier_birzha_high_five") then
				local vPoint = (hero:GetOrigin() + self:GetParent():GetOrigin()) / 2

				ProjectileManager:CreateLinearProjectile(
				{
					Source = self:GetParent(),
					Ability = nil,
					vSpawnOrigin = self:GetParent():GetAbsOrigin(),
				    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
				    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				    iUnitTargetType = DOTA_UNIT_TARGET_NONE,
				    EffectName = 'particles/econ/events/plus/high_five/high_five_lvl3_travel.vpcf',
				    fDistance = (vPoint - self:GetParent():GetOrigin()):Length2D(),
				    fStartRadius = 10,
				    fEndRadius = 10,
					vVelocity = (vPoint - self:GetParent():GetOrigin()):Normalized() * 700,
				})

				ProjectileManager:CreateLinearProjectile(
				{
					Source = hero,
					Ability = nil,
					vSpawnOrigin = hero:GetAbsOrigin(),
				    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
				    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				    iUnitTargetType = DOTA_UNIT_TARGET_NONE,
				    EffectName = 'particles/econ/events/plus/high_five/high_five_lvl3_travel.vpcf',
				    fDistance = (vPoint - hero:GetOrigin()):Length2D(),
				    fStartRadius = 10,
				    fEndRadius = 10,
					vVelocity = (vPoint - hero:GetOrigin()):Normalized() * 700,
				})

				CreateModifierThinker(self:GetParent(), nil, "modifier_birzha_high_five_thinker", {duration = (vPoint - hero:GetOrigin()):Length2D()/700}, vPoint, self:GetParent():GetTeamNumber(), false)

				hero:RemoveModifierByName("modifier_birzha_high_five")
				self:Destroy()
				break
			end
		end
	end
end

function modifier_birzha_high_five:GetEffectName()
	return "particles/econ/events/plus/high_five/high_five_lvl3_overhead.vpcf"
end

function modifier_birzha_high_five:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end


modifier_birzha_high_five_thinker = class({})

function modifier_birzha_high_five_thinker:OnDestroy()
	if not IsServer() then return end
	self:GetParent():EmitSound('high_five.impact')
end