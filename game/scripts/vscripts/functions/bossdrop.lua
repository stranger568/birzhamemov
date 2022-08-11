
LinkLuaModifier( "modifier_boss_drop", "functions/bossdrop.lua", LUA_MODIFIER_MOTION_NONE )

Boss_Drop = class({})

function Boss_Drop:GetIntrinsicModifierName()
    return "modifier_boss_drop"
end

modifier_boss_drop = class({})

function modifier_boss_drop:IsHidden()
    return true
end

function modifier_boss_drop:StatusEffectPriority()
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_boss_drop:GetPriority()
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_boss_drop:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_boss_drop:OnDeath(params)
	if params.unit == self:GetParent() then
		if self:GetParent():GetUnitName() == "npc_dota_bristlekek" then
			local spawnPointChest = self:GetParent():GetAbsOrigin()
			local BossDrop = CreateItem( "item_bristback", nil, nil )
			local DropItem = CreateItemOnPositionForLaunch( spawnPointChest, BossDrop )
			local dropRadiusChest = RandomFloat( 100, 200 )
			local attacker = params.attacker
			local team = attacker:GetTeam()
			local AllHeroes = HeroList:GetAllHeroes()
			for count, hero in ipairs(AllHeroes) do
				if hero:GetTeam() == team and hero:IsRealHero() then
					hero:ModifyGold( 500, true, 0 )
				end
			end
			EmitGlobalSound("conquest.stinger.capture_radiant")
			BossDrop:LaunchLootInitialHeight( false, 0, 300, 0.75, spawnPointChest + RandomVector( dropRadiusChest ) )
			CustomGameEventManager:Send_ServerToAllClients("bristlekek_killed_true", {} )
			BirzhaGameMode:AddScoreToTeam( team, 5 )
			Timers:CreateTimer(180, function()
				local RoshanSpawnPoint = Entities:FindByName( nil, "RoshanSpawn" ):GetAbsOrigin()
				local Boss = CreateUnitByName("npc_dota_bristlekek", RoshanSpawnPoint, false, nil, nil, DOTA_TEAM_NEUTRALS)
			end)
		elseif self:GetParent():GetUnitName() == "npc_dota_LolBlade" then
			local spawnPointChest = self:GetParent():GetAbsOrigin()
			local BossDrop = CreateItem( "item_crysdalus", nil, nil )
			local DropItem = CreateItemOnPositionForLaunch( spawnPointChest, BossDrop )
			local dropRadiusChest = RandomFloat( 100, 200 )
			local attacker = params.attacker
			local team = attacker:GetTeam()
			local AllHeroes = HeroList:GetAllHeroes()
			for count, hero in ipairs(AllHeroes) do
				if hero:GetTeam() == team and hero:IsRealHero() then
					hero:ModifyGold( 500, true, 0 )
				end
			end
			EmitGlobalSound("conquest.stinger.capture_radiant")
			BossDrop:LaunchLootInitialHeight( false, 0, 300, 0.75, spawnPointChest + RandomVector( dropRadiusChest ) )
			CustomGameEventManager:Send_ServerToAllClients("lolblade_killed_true", {} )
			BirzhaGameMode:AddScoreToTeam( team, 5 )
			Timers:CreateTimer(180, function()
				local RoshanSpawnPoint = Entities:FindByName( nil, "RoshanSpawn2" ):GetAbsOrigin()
				local Boss = CreateUnitByName("npc_dota_LolBlade", RoshanSpawnPoint, false, nil, nil, DOTA_TEAM_NEUTRALS)
			end)
		end
	end	
end

function modifier_boss_drop:CheckState()
    return {
        [MODIFIER_STATE_STUNNED]            = false,
        [MODIFIER_STATE_HEXED]       = false,
        [MODIFIER_STATE_DISARMED]  = false,
        [MODIFIER_STATE_CANNOT_MISS] = true,
        
    }
end

LinkLuaModifier( "modifier_lolblade_Reflection", "functions/bossdrop.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_reflection_invulnerability", "functions/bossdrop.lua", LUA_MODIFIER_MOTION_NONE )

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
		self:GetAbility():UseResources(false, false, true)
		for _,hero in pairs(heroes) do
			local illusions = CreateIllusions( self:GetCaster(), hero, {duration=3,outgoing_damage=0,incoming_damage=0}, 1, 1, true, true ) 
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



LinkLuaModifier( "modifier_quill_spray_boss", "functions/bossdrop.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_quill_spray_boss_debuff", "functions/bossdrop.lua", LUA_MODIFIER_MOTION_NONE )

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
		self:GetAbility():UseResources(false, false, true)
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


