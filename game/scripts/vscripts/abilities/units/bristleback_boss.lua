LinkLuaModifier( "modifier_quill_spray_boss", "abilities/units/bristleback_boss.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_quill_spray_boss_debuff", "abilities/units/bristleback_boss.lua", LUA_MODIFIER_MOTION_NONE )

quill_spray_boss = class({})

function quill_spray_boss:GetIntrinsicModifierName()
    return "modifier_quill_spray_boss"
end

modifier_quill_spray_boss = class({})

function modifier_quill_spray_boss:IsHidden()
    return true
end

function modifier_quill_spray_boss:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_quill_spray_boss:OnIntervalThink()
	if not IsServer() then return end
	local duration = self:GetAbility():GetSpecialValueFor("quill_stack_duration")
	local base_damage = self:GetAbility():GetSpecialValueFor("quill_base_damage")
	local stack_damage = self:GetAbility():GetSpecialValueFor("quill_stack_damage")
	local max_damage = self:GetAbility():GetSpecialValueFor("max_damage")
	if self:GetAbility():IsFullyCastable() then
		self:GetAbility():UseResources(false, false, false, true)
		if not self:GetParent():IsAlive() then return end
		local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
		self:GetParent():GetAbsOrigin(),
		nil,
		self:GetAbility():GetSpecialValueFor("radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_ANY_ORDER,
		false)
		if #targets == 0 then return end
		local spray = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_quill_spray.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(spray, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(spray, 60, Vector(RandomInt(0, 255), RandomInt(0, 255), RandomInt(0, 255)))
		ParticleManager:SetParticleControl(spray, 61, Vector(1, 0, 0))
		self:GetParent():EmitSound("Hero_Bristleback.QuillSpray.Cast")
		local damageTable = {
			attacker = self:GetParent(),
			damage_type = DAMAGE_TYPE_PHYSICAL,
			ability = self:GetAbility(),
		}
		for _,unit in pairs(targets) do
			local stack = 0
			local modifier = unit:FindModifierByNameAndCaster( "modifier_quill_spray_boss_debuff", self:GetParent() )
			if modifier~=nil then
				stack = modifier:GetStackCount()
			end
			damageTable.victim = unit
			damageTable.damage = math.min( base_damage + stack * stack_damage, max_damage )
			ApplyDamage( damageTable )
			unit:EmitSound("Hero_Bristleback.QuillSpray.Target")
	        if unit:HasModifier("modifier_quill_spray_boss_debuff") then
	            unit:SetModifierStackCount( "modifier_quill_spray_boss_debuff", self:GetAbility(), stack + 1 )
	            unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_quill_spray_boss_debuff", { duration = duration } )
	        else
	            unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_quill_spray_boss_debuff", { duration = duration } )
	            unit:SetModifierStackCount( "modifier_quill_spray_boss_debuff", self:GetAbility(), 1 )
	        end
		end
	end
end

modifier_quill_spray_boss_debuff = class({})

function modifier_quill_spray_boss_debuff:IsPurgable()
    return true
end