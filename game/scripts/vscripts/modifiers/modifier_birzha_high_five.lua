LinkLuaModifier("modifier_birzha_high_five_thinker", "modifiers/modifier_birzha_high_five", LUA_MODIFIER_MOTION_NONE)

modifier_birzha_high_five = class({})
function modifier_birzha_high_five:IsHidden() return true end
function modifier_birzha_high_five:IsPurgable() return false end
function modifier_birzha_high_five:IsPurgeException() return false end
function modifier_birzha_high_five:OnCreated()
    if not IsServer() then return end
    self.overhead_effect = "particles/econ/events/plus/high_five/high_five_lvl1_overhead.vpcf"
    self.proj_effect = "particles/econ/events/plus/high_five/high_five_lvl1_travel.vpcf"
    self.target_proj = "particles/econ/events/plus/high_five/high_five_lvl1_travel.vpcf"
    if BirzhaData.PLAYERS_GLOBAL_INFORMATION[self:GetParent():GetPlayerOwnerID()] and BirzhaData.PLAYERS_GLOBAL_INFORMATION[self:GetParent():GetPlayerOwnerID()].server_data then
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[self:GetParent():GetPlayerOwnerID()].server_data.five_id == 184 then
            self.overhead_effect = "particles/econ/events/plus/high_five/high_five_lvl3_overhead.vpcf"
            self.proj_effect = "particles/econ/events/plus/high_five/high_five_lvl3_travel.vpcf"
        end
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[self:GetParent():GetPlayerOwnerID()].server_data.five_id == 402 then
            self.overhead_effect = "particles/econ/events/diretide_2020/high_five/high_five_lvl1_overhead.vpcf"
            self.proj_effect = "particles/econ/events/diretide_2020/high_five/high_five_lvl1_travel.vpcf"
        end
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[self:GetParent():GetPlayerOwnerID()].server_data.five_id == 322 then
            self.overhead_effect = "particles/econ/events/ti9/high_five/high_five_lvl3_overhead.vpcf"
            self.proj_effect = "particles/econ/events/ti9/high_five/high_five_lvl3_travel.vpcf"
        end
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[self:GetParent():GetPlayerOwnerID()].server_data.five_id == 323 then
            self.overhead_effect = "particles/econ/events/spring_2021/high_five_spring_2021_overhead.vpcf"
            self.proj_effect = "particles/econ/events/spring_2021/high_five_spring_2021_travel.vpcf"
        end
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[self:GetParent():GetPlayerOwnerID()].server_data.five_id == 324 then
            self.overhead_effect = "particles/econ/events/plus/high_five/high_five_lvl2_overhead.vpcf"
            self.proj_effect = "particles/econ/events/plus/high_five/high_five_lvl2_travel.vpcf"
        end
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[self:GetParent():GetPlayerOwnerID()].server_data.five_id == 325 then
            self.overhead_effect = "particles/econ/events/fall_2022/high_five/high_five_fall_2022_overhead.vpcf"
            self.proj_effect = "particles/econ/events/fall_2022/high_five/high_five_fall2022_travel.vpcf"
        end
    end
    self:GetParent():EmitSound("high_five.cast")
    local particle = ParticleManager:CreateParticle(self.overhead_effect, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(particle, false, false, -1, false, false)
    self:StartIntervalThink(0.1)
end

function modifier_birzha_high_five:StartProj(caster, target, vPoint)
    if not IsServer() then return end
    if BirzhaData.PLAYERS_GLOBAL_INFORMATION[target:GetPlayerOwnerID()] and BirzhaData.PLAYERS_GLOBAL_INFORMATION[target:GetPlayerOwnerID()].server_data then
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[target:GetPlayerOwnerID()].server_data.five_id == 184 then
            self.target_proj = "particles/econ/events/plus/high_five/high_five_lvl3_travel.vpcf"
        end
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[target:GetPlayerOwnerID()].server_data.five_id == 402 then
            self.target_proj = "particles/econ/events/diretide_2020/high_five/high_five_lvl1_travel.vpcf"
        end
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[target:GetPlayerOwnerID()].server_data.five_id == 322 then
            self.target_proj = "particles/econ/events/ti9/high_five/high_five_lvl3_travel.vpcf"
        end
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[target:GetPlayerOwnerID()].server_data.five_id == 323 then
            self.target_proj = "particles/econ/events/spring_2021/high_five_spring_2021_travel.vpcf"
        end
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[target:GetPlayerOwnerID()].server_data.five_id == 324 then
            self.target_proj = "particles/econ/events/plus/high_five/high_five_lvl2_travel.vpcf"
        end
        if BirzhaData.PLAYERS_GLOBAL_INFORMATION[target:GetPlayerOwnerID()].server_data.five_id == 325 then
            self.target_proj = "particles/econ/events/fall_2022/high_five/high_five_fall2022_travel.vpcf"
        end
    end

    ProjectileManager:CreateLinearProjectile(
    {
        Source = caster,
        Ability = nil,
        vSpawnOrigin = caster:GetAbsOrigin(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_NONE,
        EffectName = self.proj_effect,
        fDistance = (vPoint - caster:GetOrigin()):Length2D(),
        fStartRadius = 10,
        fEndRadius = 10,
        vVelocity = (vPoint - caster:GetOrigin()):Normalized() * 700,
    })

    ProjectileManager:CreateLinearProjectile(
    {
        Source = target,
        Ability = nil,
        vSpawnOrigin = target:GetAbsOrigin(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_NONE,
        EffectName = self.target_proj,
        fDistance = (vPoint - target:GetOrigin()):Length2D(),
        fStartRadius = 10,
        fEndRadius = 10,
        vVelocity = (vPoint - target:GetOrigin()):Normalized() * 700,
    })
end

function modifier_birzha_high_five:OnIntervalThink()
	if not IsServer() then return end
    local target = nil
    local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
	for k, hero in pairs(units) do
		if hero ~= self:GetParent() then
			if hero:HasModifier("modifier_birzha_high_five") then
                target = hero
                break
            end
        end
    end
    if target == nil then return end
	local vPoint = (target:GetOrigin() + self:GetParent():GetOrigin()) / 2
    self:StartProj(self:GetParent(), target, vPoint)
	CreateModifierThinker(self:GetParent(), nil, "modifier_birzha_high_five_thinker", {duration = (vPoint - target:GetOrigin()):Length2D()/700}, vPoint, self:GetParent():GetTeamNumber(), false)
	target:RemoveModifierByName("modifier_birzha_high_five")
	self:Destroy()
end

modifier_birzha_high_five_thinker = class({})

function modifier_birzha_high_five_thinker:OnDestroy()
	if not IsServer() then return end
	self:GetParent():EmitSound('high_five.impact')
end