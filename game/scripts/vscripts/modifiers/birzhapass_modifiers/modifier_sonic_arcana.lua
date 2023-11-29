LinkLuaModifier( "modifier_mum_meat_hook_hook_thinker", "abilities/heroes/mum.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )

modifier_sonic_arcana = class({})

function modifier_sonic_arcana:IsHidden()
	return true
end

function modifier_sonic_arcana:IsPurgable()
	return false
end

function modifier_sonic_arcana:IsPurgeException()
	return false
end

function modifier_sonic_arcana:RemoveOnDeath()
	return false
end

function modifier_sonic_arcana:AllowIllusionDuplicate()
	return true
end

function modifier_sonic_arcana:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_sonic_arcana:OnDeath(params)
	if not IsServer() then return end
	if params.unit ~= self:GetParent() then return end
	self:GetParent():EmitSound("sonic_death")
	for i=1, RandomInt(2, 6) do
		local dummy = CreateUnitByName("npc_dota_creep_badguys_melee", self:GetCaster():GetAbsOrigin(), false, nil, nil, self:GetCaster():GetTeamNumber())
        dummy:AddNewModifier(self:GetCaster(), self, "modifier_mum_meat_hook_hook_thinker", {})
        dummy:SetModel("models/sonic_arcana/sonic_ring.vmdl")
        dummy:SetOriginalModel("models/sonic_arcana/sonic_ring.vmdl")
        dummy:AddNewModifier(dummy, nil, "modifier_kill", {duration = 10})
        dummy:StartGesture(ACT_DOTA_IDLE)
        dummy:SetDayTimeVisionRange(0)
        dummy:SetNightTimeVisionRange(0)
        local point = self:GetCaster():GetAbsOrigin() + RandomVector(100)
		local direction = point - self:GetCaster():GetAbsOrigin()
		direction.z = 0
		direction = direction:Normalized()
		local knockback = dummy:AddNewModifier(
	        dummy,
	        nil,	
	        "modifier_generic_knockback_lua",
	        {
	            direction_x = direction.x,
	            direction_y = direction.y,
	            distance = 400,
	            height = 100,	
	            duration = 0.5,
	            IsStun = true,
	        }
	    )
	end
end

function modifier_sonic_arcana:OnCreated()
	if not IsServer() then return end
	--local particle2 = ParticleManager:CreateParticle( "particles/sonic/sonic_arcana_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	--ParticleManager:SetParticleControlEnt( particle2, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true )
	--ParticleManager:SetParticleControlEnt( particle2, 3, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true )
	--self:AddParticle(particle2, false, false, -1, false, false)
end

function modifier_sonic_arcana:GetEffectName()
	return "particles/sonic/sonic_arcana_ambient.vpcf"
end

function modifier_sonic_arcana:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end