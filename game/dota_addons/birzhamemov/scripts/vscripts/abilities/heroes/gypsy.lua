gypsy_tabor = class({})

LinkLuaModifier("modifier_gypsy_tabor_illusion","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_tabor_samosud","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
function gypsy_tabor:OnSpellStart()
	if IsServer() then
		self.target = self:GetCursorTarget()
		self.caster = self:GetCaster()
		self.caster:EmitSound("GypsyTabor")
		local main_illusion_damage = self:GetSpecialValueFor("illusion_damage")
		local illusion_duration = self:GetSpecialValueFor("illusion_duration")
		local illusion_damage_in = self:GetSpecialValueFor("illusion_damage_in")
		main_illusions = CreateIllusions( self:GetCaster(), self.target, {duration=illusion_duration,outgoing_damage=main_illusion_damage,incoming_damage=illusion_damage_in}, 1, 1, true, true ) 
		for k, main_illusion in pairs(main_illusions) do
			main_illusion:RemoveDonate()
			main_illusion:AddNewModifier(self:GetCaster(), self, "modifier_gypsy_tabor_samosud", {})
		end

		local chance = self:GetSpecialValueFor( "chance" )
		local count_chance_illusions = self:GetSpecialValueFor( "illusion_count" )
		local damage_chance_illusions = self:GetSpecialValueFor( "illusion_damage_out" )
		if RandomInt(1, 100) <= chance then
			chance_illusions = CreateIllusions( self:GetCaster(), self.target, {duration=illusion_duration,outgoing_damage=damage_chance_illusions,incoming_damage=illusion_damage_in}, count_chance_illusions, 1, true, true ) 
			for k, chance_illusion in pairs(chance_illusions) do
				chance_illusion:RemoveDonate()
				chance_illusion:AddNewModifier(self:GetCaster(), self, "modifier_gypsy_tabor_illusion", {})
				chance_illusion:AddNewModifier(self:GetCaster(), self, "modifier_gypsy_tabor_samosud", {})
			end
		end
	end
end

modifier_gypsy_tabor_illusion = class({})

function modifier_gypsy_tabor_illusion:IsHidden()
	return true
end

function modifier_gypsy_tabor_illusion:GetStatusEffectName()
	return "particles/status_fx/status_effect_phantom_lancer_illusion.vpcf"
end

modifier_gypsy_tabor_samosud = class({})

function modifier_gypsy_tabor_samosud:IsHidden()
	return true
end

function modifier_gypsy_tabor_samosud:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
	
function modifier_gypsy_tabor_samosud:OnTakeDamage(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attacker = keys.attacker
		local target = keys.unit

		if attacker:GetTeamNumber() ~= parent:GetTeamNumber() and parent == target and not attacker:IsOther() then
			if keys.damage > parent:GetHealth() then
				if self:GetCaster():HasTalent("special_bonus_unique_sand_king_4") then
					self:GetCaster():FindModifierByName("modifier_gypsy_samosud_count"):SetStackCount(self:GetCaster():FindModifierByName("modifier_gypsy_samosud_count"):GetStackCount() + 1)
				end
			end
		end
	end
end


LinkLuaModifier("modifier_gypsy_gipnoz_attack","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_gipnoz_buff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_gipnoz_debuff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_gipnoz_buff_hud","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_gipnoz_debuff_hud","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)


gypsy_gipnoz = class({})

modifier_gypsy_gipnoz_attack = class({})
modifier_gypsy_gipnoz_buff = class({})
modifier_gypsy_gipnoz_debuff = class({})
modifier_gypsy_gipnoz_buff_hud = class({})
modifier_gypsy_gipnoz_debuff_hud = class({})

function gypsy_gipnoz:GetIntrinsicModifierName() 
return "modifier_gypsy_gipnoz_attack"
end

function modifier_gypsy_gipnoz_attack:IsHidden()
	return true
end

function modifier_gypsy_gipnoz_attack:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_gypsy_gipnoz_attack:OnAttackLanded( keys )
	if IsServer() then
		local attacker = self:GetParent()

		if attacker ~= keys.attacker then
			return
		end

		if attacker:IsIllusion() then
			return
		end

		if not keys.target:IsRealHero() then
			return
		end

		if keys.target:IsIllusion() then
			return
		end

		local target = keys.target
		if attacker:GetTeam() == target:GetTeam() then
			return
		end	

		self.stats = self:GetAbility():GetSpecialValueFor("stats_steal")

		attacker:AddNewModifier(attacker, self:GetAbility(), "modifier_gypsy_gipnoz_buff", {duration = self:GetAbility():GetSpecialValueFor("duration_debuff")})
		target:AddNewModifier(attacker, self:GetAbility(), "modifier_gypsy_gipnoz_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration_debuff")})

		if attacker:HasModifier("modifier_gypsy_gipnoz_buff_hud") then
			attacker:FindModifierByName("modifier_gypsy_gipnoz_buff_hud"):SetStackCount(attacker:FindModifierByName("modifier_gypsy_gipnoz_buff_hud"):GetStackCount() + 1)
		else
			attacker:AddNewModifier(attacker, self:GetAbility(), "modifier_gypsy_gipnoz_buff_hud", {})
		end

		if target:HasModifier("modifier_gypsy_gipnoz_debuff_hud") then
			target:FindModifierByName("modifier_gypsy_gipnoz_debuff_hud"):SetStackCount(target:FindModifierByName("modifier_gypsy_gipnoz_debuff_hud"):GetStackCount() + 1)
		else
			target:AddNewModifier(attacker, self:GetAbility(), "modifier_gypsy_gipnoz_debuff_hud", {})
		end
	end
end

function modifier_gypsy_gipnoz_buff_hud:OnCreated()
	self:SetStackCount(1)
	self:StartIntervalThink(0.1)
end

function modifier_gypsy_gipnoz_buff_hud:OnIntervalThink()
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end


function modifier_gypsy_gipnoz_debuff_hud:OnCreated()
	self:SetStackCount(1)
	self:StartIntervalThink(0.1)
end

function modifier_gypsy_gipnoz_debuff_hud:OnIntervalThink()
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end


function modifier_gypsy_gipnoz_buff:IsHidden()
	return true
end

function modifier_gypsy_gipnoz_buff:OnCreated()
	self.stats = self:GetAbility():GetSpecialValueFor("stats_steal")
	self.armor = self:GetAbility():GetSpecialValueFor("armor_steal")
end

function modifier_gypsy_gipnoz_buff:OnDestroy()
	if self:GetParent():HasModifier("modifier_gypsy_gipnoz_buff_hud") then
		self:GetParent():FindModifierByName("modifier_gypsy_gipnoz_buff_hud"):SetStackCount(self:GetParent():FindModifierByName("modifier_gypsy_gipnoz_buff_hud"):GetStackCount() - 1)
	end
end

function modifier_gypsy_gipnoz_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_gypsy_gipnoz_buff:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

	}
end

function modifier_gypsy_gipnoz_buff:GetModifierPhysicalArmorBonus()
    return self.armor
end

function modifier_gypsy_gipnoz_buff:GetModifierBonusStats_Strength()
    return self.stats
end

function modifier_gypsy_gipnoz_buff:GetModifierBonusStats_Agility()
    return self.stats
end

function modifier_gypsy_gipnoz_buff:GetModifierBonusStats_Intellect()
    return self.stats
end

function modifier_gypsy_gipnoz_debuff:IsHidden()
	return true
end

function modifier_gypsy_gipnoz_debuff:OnCreated()
	self.stats = self:GetAbility():GetSpecialValueFor("stats_steal") * (-1)
	self.armor = self:GetAbility():GetSpecialValueFor("armor_steal") * (-1)
end

function modifier_gypsy_gipnoz_debuff:OnDestroy()
	if self:GetParent():HasModifier("modifier_gypsy_gipnoz_debuff_hud") then
		self:GetParent():FindModifierByName("modifier_gypsy_gipnoz_debuff_hud"):SetStackCount(self:GetParent():FindModifierByName("modifier_gypsy_gipnoz_debuff_hud"):GetStackCount() - 1)
	end
end

function modifier_gypsy_gipnoz_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_gypsy_gipnoz_debuff:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

	}
end

function modifier_gypsy_gipnoz_debuff:GetModifierPhysicalArmorBonus()
    return self.armor
end

function modifier_gypsy_gipnoz_debuff:GetModifierBonusStats_Strength()
    return self.stats
end

function modifier_gypsy_gipnoz_debuff:GetModifierBonusStats_Agility()
    return self.stats
end

function modifier_gypsy_gipnoz_debuff:GetModifierBonusStats_Intellect()
    return self.stats
end


LinkLuaModifier("modifier_gypsy_lucky", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_lucky_proc", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE)


gypsy_lucky = class({})
modifier_gypsy_lucky = class({})
modifier_gypsy_lucky_proc = class({})

function gypsy_lucky:GetIntrinsicModifierName()
	return "modifier_gypsy_lucky"
end

function modifier_gypsy_lucky:IsHidden()
	return true
end

function modifier_gypsy_lucky_proc:IsHidden()
	return true
end

function modifier_gypsy_lucky_proc:IsDebuff() return true end
function modifier_gypsy_lucky_proc:IsHidden() return true end
function modifier_gypsy_lucky_proc:IsPurgable() return false end
function modifier_gypsy_lucky_proc:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end


function modifier_gypsy_lucky:IsDebuff() return false end
function modifier_gypsy_lucky:IsHidden() return true end
function modifier_gypsy_lucky:IsPurgable() return false end
function modifier_gypsy_lucky:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_gypsy_lucky:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE
	}
	return funcs
end

function modifier_gypsy_lucky:GetModifierPercentageCasttime()
	return 100
end

function modifier_gypsy_lucky:GetModifierIgnoreCastAngle()
	return 1
end

function modifier_gypsy_lucky:OnAbilityFullyCast(keys)
	if IsServer() then
		if keys.unit == self:GetParent() then

			local items_useless = 
			{
				"item_bag_of_gold",
				"item_ward_sentry",
				"item_ward_observer",
				"item_ward_dispenser",
				"item_treasure_chest",
				"item_treasure_chest_bp_fake",
				"item_bag_of_gold_bp_fake",
				"item_tpscroll",
				"item_tome_of_knowledge",
				"item_refresher_shard",
				"item_burger_sobolev",
				"item_burger_oblomoff",
				"item_burger_larin",
				"item_abakan",
				"item_bond",
				"item_gem_datadriven",
				"item_ultimate_mem",
				"item_stone_mask",
				"gypsy_steal",
				"Zema_Cosmo_Ray",
				"rin_satana_explosion",
				"Yakubovich_Car",
				"Face_ShopGucci",
				"Guts_DarkArmor",
				"Knuckles_GetInTheTank",
				"JesusAVGN_GangstaAlexey",
				"Rem_DemonicForm",
				"Bogdan_Cower",
				"Versuta_dog_change",
				"Ns_KBU",
				"SilverName_Owl",
				"Dio_TheWorld",
				"Pistoletov_DeathFight",
				"BigRussianBoss_test",
				"kaneki_rage",
				"Illidan_Brutality",
			}
			for _,items_useles in pairs(items_useless) do
				if keys.ability:GetName() == items_useles then
					return
				end
			end


			if keys.unit:HasModifier("modifier_gypsy_lucky_proc") then
				keys.unit:FindModifierByName("modifier_gypsy_lucky_proc"):DecrementStackCount()
			else
				self.casts = 1
				if RandomInt( 0,100 ) < self:GetAbility():GetSpecialValueFor( "chance_multi_1" ) then self.casts = 1 end
				if RandomInt( 0,100 ) < self:GetAbility():GetSpecialValueFor( "chance_multi_2" ) then self.casts = 2 end
				if RandomInt( 0,100 ) < self:GetAbility():GetSpecialValueFor( "chance_multi_3" ) then self.casts = 3 end
				if RandomInt( 0,100 ) < self:GetAbility():GetSpecialValueFor( "chance_multi_4" ) then self.casts = 4 end
				keys.unit:AddNewModifier(keys.unit, nil, "modifier_gypsy_lucky_proc", {}):SetStackCount(self.casts)
				self.effect = true
			end

			if keys.unit:FindModifierByName("modifier_gypsy_lucky_proc"):GetStackCount() <= 0 then
				keys.unit:RemoveModifierByName("modifier_gypsy_lucky_proc")
			else
				local ability = keys.unit:FindAbilityByName(keys.ability:GetAbilityName())

				for i = 0, 5 do 
			        local item = keys.unit:GetItemInSlot(i)
		            if item then
		            	if item:GetName() == keys.ability:GetName() then
		            		ability = keys.ability
		            	end
		           	end        
			    end

			    if ability == nil then
			    	keys.unit:RemoveModifierByName("modifier_gypsy_lucky_proc")
					return
				end

				local cursor_position = keys.ability:GetCursorPosition() + RandomVector(100)
				local target_flags = ability:GetAbilityTargetFlags()
				local target_team = ability:GetAbilityTargetTeam()
				local target_type = ability:GetAbilityTargetType()
				local ability_behavior = ability:GetBehavior()
				local cast_range = ability:GetCastRange(keys.unit:GetAbsOrigin(), keys.unit)

				if bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_TOGGLE ) ~= 0 then
					keys.unit:RemoveModifierByName("modifier_gypsy_lucky_proc")
					return nil
				elseif bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_CHANNELLED ) ~= 0 then
					keys.unit:RemoveModifierByName("modifier_gypsy_lucky_proc")
					return nil
				elseif bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_POINT ) ~= 0 then
					print("point")
					Timers:CreateTimer(0.5, function()
					keys.unit:GiveMana(keys.cost)
					ability:EndCooldown()
					keys.unit:CastAbilityOnPosition(cursor_position, ability, keys.unit:GetPlayerID())
					end)
				elseif bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET ) ~= 0 then
					print("target")
					local units = FindUnitsInRadius(keys.unit:GetTeam(), keys.unit:GetAbsOrigin(), nil, cast_range + 200, target_team, target_type, target_flags, FIND_ANY_ORDER, false)
					if #units > 0 then
						Timers:CreateTimer(0.5, function()
						keys.unit:GiveMana(keys.cost)
						ability:EndCooldown()
						keys.unit:CastAbilityOnTarget(units[1], ability, keys.unit:GetPlayerID())
						end)
					end
				elseif bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET ) ~= 0 then
					print("no target")
					Timers:CreateTimer(0.5, function()
						keys.unit:GiveMana(keys.cost)
						ability:EndCooldown()
						keys.unit:CastAbilityNoTarget(ability, keys.unit:GetPlayerID())
					end)
				end
				if self.effect then
					local nFXIndex = ParticleManager:CreateParticle( "particles/gypsy/gypsy_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, keys.unit )
					ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.casts+1, 2, 1 ) )
					ParticleManager:ReleaseParticleIndex( nFXIndex )
					keys.unit:EmitSound("GypsyMulticast")
				end

				self.effect = false
			end
		end
	end
end



gypsy_steal = class({})
gypsy_steal_slot1 = class({})



LinkLuaModifier( "gypsy_steal_lua", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "gypsy_steal_hidden", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE )

gypsy_steal.firstTime = true
function gypsy_steal:OnHeroCalculateStatBonus()
	if self.firstTime then
		self:GetCaster():AddNewModifier(
			self:GetCaster(),
			self,
			"gypsy_steal_hidden",
			{}
		)
		self.firstTime = false
	end
end

gypsy_steal.failState = nil
function gypsy_steal:CastFilterResultTarget( hTarget )
	if IsServer() then
		if self:GetLastSpell( hTarget )==nil then
			return UF_FAIL_OTHER
		end
	end

	local nResult = UnitFilter(
		hTarget,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
		self:GetCaster():GetTeamNumber()
	)

	if self:GetCaster():HasScepter() then
		nResult = UnitFilter(
			hTarget,
			DOTA_UNIT_TARGET_TEAM_BOTH,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
			self:GetCaster():GetTeamNumber()
		)
	end

	if hTarget == self:GetCaster() then
		return UF_FAIL_OTHER
	end

	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

gypsy_steal.stolenSpell = nil
function gypsy_steal:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb( self ) then
		return
	end
	local duration_silence = self:GetSpecialValueFor("duration_silence")
	if caster:GetTeamNumber() ~= target:GetTeamNumber() then
		print("SILENCED")
		target:AddNewModifier(caster, self, "modifier_silence", {duration = duration_silence})
	end

	self.stolenSpell = {}
	self.stolenSpell.lastSpell = self:GetLastSpell( target )
	local projectile_name = "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf"
	local projectile_speed = 1200

	local info = {
		Target = caster,
		Source = target,
		Ability = self,	
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		vSourceLoc = target:GetAbsOrigin(),             
		bDrawsOnMinimap = false,                         
		bDodgeable = false,                               
		bVisibleToEnemies = true,                        
		bReplaceExisting = false,                         
	}
	ProjectileManager:CreateTrackingProjectile(info)

	local sound_cast = "GypsyUltimate"
	EmitSoundOn( sound_cast, caster )
	local sound_target = "Hero_Rubick.SpellSteal.Target"
	EmitSoundOn( sound_target, target )
end

function gypsy_steal:OnProjectileHit( target, location )
	self:SetStolenSpell( self.stolenSpell )
	self.stolenSpell = nil
	local steal_duration = self:GetSpecialValueFor("duration")
	target:AddNewModifier(
		self:GetCaster(),
		self,
		"gypsy_steal_lua",
		{ duration = steal_duration }
	)

	local sound_cast = "Hero_Rubick.SpellSteal.Complete"
	EmitSoundOn( sound_cast, target )
end

gypsy_steal.heroesData = {}

function gypsy_steal:SetLastSpell( hHero, hSpell )
	local heroData = nil
	for _,data in pairs(gypsy_steal.heroesData) do
		if data.handle==hHero then
			heroData = data
			break
		end
	end

	-- store data
	if heroData then
		heroData.lastSpell = hSpell
	else
		local newData = {}
		newData.handle = hHero
		newData.lastSpell = hSpell
		table.insert( gypsy_steal.heroesData, newData )
	end
end

function gypsy_steal:GetLastSpell( hHero )
	local heroData = nil
	for _,data in pairs(gypsy_steal.heroesData) do
		if data.handle==hHero then
			heroData = data
			break
		end
	end

	if heroData then
		return heroData.lastSpell
	end

	return nil
end

function gypsy_steal:PrintStatus()
	print("Heroes and spells:")
	for _,heroData in pairs(gypsy_steal.heroesData) do
		print( heroData.handle:GetUnitName(), heroData.handle, heroData.lastSpell:GetAbilityName(), heroData.lastSpell )
	end
end

gypsy_steal.currentSpell = nil
gypsy_steal.slot1 = "gypsy_steal_slot1"

function gypsy_steal:SetStolenSpell( spellData )
	local spell = spellData.lastSpell
	local interaction = spellData.interaction
	self:ForgetSpell()
	self.currentSpell = self:GetCaster():AddAbility( spell:GetAbilityName() )
	self.currentSpell:SetStolen( true )
	self.currentSpell:SetLevel( spell:GetLevel() )
	if self.currentSpell.OnStolen then self.currentSpell:OnStolen( spell ) end
	self:GetCaster():SwapAbilities( self.slot1, self.currentSpell:GetAbilityName(), false, true )
end

function gypsy_steal:ForgetSpell()
	if self.currentSpell~=nil then
		if self.currentSpell.OnUnStolen then self.currentSpell:OnUnStolen() end
		self:GetCaster():SwapAbilities( self.slot1, self.currentSpell:GetAbilityName(), true, false )
		self:GetCaster():RemoveAbility( self.currentSpell:GetAbilityName() )
		self.currentSpell = nil
	end
end

function gypsy_steal:AbilityConsiderations()
	local bScepter = caster:HasScepter()
	local bBlocked = target:TriggerSpellAbsorb( self )
	local bBroken = caster:PassivesDisabled()
	local bInvulnerable = target:IsInvulnerable()
	local bInvisible = target:IsInvisible()
	local bHexed = target:IsHexed()
	local bMagicImmune = target:IsMagicImmune()
	local bIllusion = target:IsIllusion()
end

function gypsy_steal:GetAT()
	if self.abilityTable==nil then
		self.abilityTable = {}
	end
	return self.abilityTable
end

function gypsy_steal:GetATEmptyKey()
	local table = self:GetAT()
	local i = 1
	while table[i]~=nil do
		i = i+1
	end
	return i
end

function gypsy_steal:AddATValue( value )
	local table = self:GetAT()
	local i = self:GetATEmptyKey()
	table[i] = value
	return i
end

function gypsy_steal:RetATValue( key )
	local table = self:GetAT()
	local ret = table[key]
	table[key] = nil
	return ret
end

function gypsy_steal:DisplayAT()
	local table = self:GetAT()
	for k,v in pairs(table) do
		print(k,v)
	end
end

-- Helper: Flag operations
function gypsy_steal:FlagExist(a,b)--Bitwise Exist
	local p,c,d=1,0,b
	while a>0 and b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>1 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	return c==d
end

function gypsy_steal:FlagAdd(a,b)--Bitwise and
	if FlagExist(a,b) then
		return a
	else
		return a+b
	end
end

function gypsy_steal:FlagMin(a,b)--Bitwise and
	if FlagExist(a,b) then
		return a-b
	else
		return a
	end
end

-- Helper: Bitwise operations
function gypsy_steal:BitXOR(a,b)--Bitwise xor
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra~=rb then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    if a<b then a=b end
    while a>0 do
        local ra=a%2
        if ra>0 then c=c+p end
        a,p=(a-ra)/2,p*2
    end
    return c
end

function gypsy_steal:BitOR(a,b)--Bitwise or
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>0 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

function gypsy_steal:BitNOT(n)
    local p,c=1,0
    while n>0 do
        local r=n%2
        if r<1 then c=c+p end
        n,p=(n-r)/2,p*2
    end
    return c
end

function gypsy_steal:BitAND(a,b)--Bitwise and
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

gypsy_steal_lua = class({})

function gypsy_steal_lua:IsHidden()
	return false
end

function gypsy_steal_lua:IsDebuff()
	return false
end

function gypsy_steal_lua:IsPurgable()
	return false
end

function gypsy_steal_lua:OnDestroy( kv )
	self:GetAbility():ForgetSpell()
end

gypsy_steal_hidden = class({})

function gypsy_steal_hidden:IsHidden()
	return true
end

function gypsy_steal_hidden:IsDebuff()
	return false
end

function gypsy_steal_hidden:IsPurgable()
	return false
end

function gypsy_steal_hidden:RemoveOnDeath()
	return false
end

function gypsy_steal_hidden:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}

	return funcs
end

function gypsy_steal_hidden:OnAbilityFullyCast( params )
	if IsServer() then
		if params.unit==self:GetParent() and (not params.ability:IsItem()) then
			print("IsItem")
			return
		end
		if params.ability:IsItem() then
			print("IsItem")
			return
		end
		if params.unit:IsIllusion() then
			return
		end
		self:GetAbility():SetLastSpell( params.unit, params.ability )
	end
end

LinkLuaModifier("modifier_gypsy_debosh_caster_debuff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_debosh_target_debuff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
gypsy_debosh = class({})
modifier_gypsy_debosh_caster_debuff = class({})
modifier_gypsy_debosh_target_debuff = class({})

function gypsy_debosh:OnSpellStart()
	local debuff_duration = self:GetSpecialValueFor( "debuff_duration" )
	self:GetCaster():EmitSound("GypsyDebosh")



	if self:GetCaster():HasModifier("modifier_gypsy_debosh_caster_debuff") then
		self:GetCaster():FindModifierByName("modifier_gypsy_debosh_caster_debuff"):ForceRefresh()
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gypsy_debosh_caster_debuff", {duration = debuff_duration})
	end

	local info = {
	EffectName = "particles/gypsy/skill_debosh.vpcf",
	Dodgeable = true,
	Ability = self,
	ProvidesVision = true,
	VisionRadius = 600,
	bVisibleToEnemies = true,
	iMoveSpeed = 1500,
	Source = self:GetCaster(),
	iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
	Target = self:GetCursorTarget(),
	bReplaceExisting = false,
	}
	local bottle = ProjectileManager:CreateTrackingProjectile(info)
end

function gypsy_debosh:OnProjectileHit(target,_)
	if target ~= nil and target:IsAlive() then

		local stun_duration = self:GetSpecialValueFor( "stun_duration" )
		target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = stun_duration})

		local bonus_damage = self:GetSpecialValueFor( "bonus_damage" )
		local damage = self:GetSpecialValueFor( "damage" )
		local modifier = target:FindModifierByName( "modifier_gypsy_debosh_target_debuff" )
		local effect_duration = self:GetSpecialValueFor( "effect_duration" )

		if modifier == nil then
			modifier = target:AddNewModifier(self:GetCaster(), self, "modifier_gypsy_debosh_target_debuff", {duration = effect_duration})
			if modifier ~= nil then
				modifier:SetStackCount( 0 )
			end	
		end

		if modifier ~= nil then
			modifier:SetStackCount( modifier:GetStackCount() + 1 )  
			modifier:ForceRefresh()
		end

		local full_damage = damage + (bonus_damage * modifier:GetStackCount())
		target:EmitSound("GypsyDebosh")
		print(full_damage)
		print(damage)
		ApplyDamage({attacker = self:GetCaster(), victim = target, ability = self, damage = full_damage, damage_type = DAMAGE_TYPE_PURE})
	end
end

function modifier_gypsy_debosh_target_debuff:IsHidden()
	return false
end

function modifier_gypsy_debosh_caster_debuff:OnCreated()
	self.magic_resist = self:GetAbility():GetSpecialValueFor( "magic_resist" )
end

function modifier_gypsy_debosh_caster_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_MISS_PERCENTAGE }
end

function modifier_gypsy_debosh_caster_debuff:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_gypsy_debosh_caster_debuff:GetModifierMiss_Percentage()
	return 100
end

gypsy_samosud = class({})

LinkLuaModifier("modifier_gypsy_samosud_count","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_samosud_debuff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)

modifier_gypsy_samosud_count = class({})
modifier_gypsy_samosud_debuff = class({})

function gypsy_samosud:GetIntrinsicModifierName() 
return "modifier_gypsy_samosud_count"
end

function modifier_gypsy_samosud_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_gypsy_samosud_count:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end

function modifier_gypsy_samosud_count:OnAttackLanded( keys )
	if IsServer() then
		local attacker = self:GetParent()

		if attacker ~= keys.attacker then
			return
		end

		if attacker:IsIllusion() then
			return
		end

		if not keys.target:IsRealHero() then
			return
		end

		if keys.target:IsIllusion() then
			return
		end

		local target = keys.target
		if attacker:GetTeam() == target:GetTeam() then
			return
		end
		if self:GetStackCount() > 0 then
			self:SetStackCount(self:GetStackCount() - 1)
			local duration = self:GetAbility():GetSpecialValueFor( "duration" )
			target:AddNewModifier(attacker, self:GetAbility(), "modifier_gypsy_samosud_debuff", {duration = duration})
		end
	end
end

function modifier_gypsy_samosud_count:GetModifierPreAttack_CriticalStrike()
    if IsServer() then
    	if self:GetStackCount() > 0 then
    		print("rabotatet")
        	return self:GetAbility():GetSpecialValueFor("critical_damage")
        end
    end
end

function modifier_gypsy_samosud_debuff:OnCreated()
    if IsServer() then
    	self.target = self:GetParent()
    	self.caster = self:GetCaster()
    	self.target_health = self.target:GetMaxHealth()/10
    	self.target:SetMaxHealth(self.target:GetMaxHealth()-self.target_health)
    	self.caster:SetMaxHealth(self.caster:GetMaxHealth()+self.target_health)
    	self.caster:Heal(self.target_health, self.caster)
    end
end

function modifier_gypsy_samosud_debuff:OnDestroy()
    if IsServer() then
    	self.target = self:GetParent()
    	self.caster = self:GetCaster()
    	self.target:SetMaxHealth(self.target:GetMaxHealth()+self.target_health)
    	self.target:Heal(self.target_health, self.caster)
    	self.caster:SetMaxHealth(self.caster:GetMaxHealth()-self.target_health)
    end
end

gypsy_talents = class({})

LinkLuaModifier("modifier_gypsy_talents","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_talents_return_damage","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)

modifier_gypsy_talents = class({})
modifier_gypsy_talents_return_damage = class({})

function gypsy_talents:GetIntrinsicModifierName() 
return "modifier_gypsy_talents"
end

function modifier_gypsy_talents:OnCreated()
	self:StartIntervalThink(0.1)
end

function modifier_gypsy_talents:OnIntervalThink()
	if self:GetCaster():HasTalent("special_bonus_unique_chen_2") then
		self.agility = 2 * self:GetParent():GetLevel()
	end

	if self:GetCaster():HasTalent("special_bonus_unique_chen_1") then
		self:GetParent():SetPrimaryAttribute(2)
		self.castrange = 150
	end

	if self:GetCaster():HasTalent("special_bonus_unique_oracle_4") then
		self.amplify = 30
		if self.swap_1 == nil then
			self:GetParent():SwapAbilities("gypsy_tabor", "gypsy_debosh", false, true)
			self:GetParent():FindAbilityByName("gypsy_debosh"):SetLevel(1)
			self.swap_1 = true
		end
	end


	if self:GetCaster():HasTalent("special_bonus_unique_sand_king_4") then
		if self.swap_2 == nil then
			self:GetParent():SwapAbilities("gypsy_steal", "gypsy_samosud", false, true)
			self:GetParent():FindAbilityByName("gypsy_samosud"):SetLevel(1)
			self.swap_2 = true
		end
	end
end

function modifier_gypsy_talents:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
	}
end

function modifier_gypsy_talents:GetModifierCastRangeBonus()
    return self.castrange
end

function modifier_gypsy_talents:GetModifierSpellAmplify_Percentage()
    return self.amplify
end

function modifier_gypsy_talents:GetModifierPreAttack_CriticalStrike()
	if self:GetCaster():HasTalent("special_bonus_unique_sand_king_4") then
		if RandomInt(1, 100) <= 50 then
	    	return 150
	    end
	end
end

function modifier_gypsy_talents:GetModifierBonusStats_Agility()
    return self.agility
end

function modifier_gypsy_talents:IsHidden()
	return true
end

function modifier_gypsy_talents:OnTakeDamage(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attacker = keys.attacker
		local target = keys.unit
		if attacker:GetTeamNumber() ~= parent:GetTeamNumber() and parent == target and not attacker:IsOther() then
			if target:IsIllusion() then return end
			if self:GetCaster():HasTalent("special_bonus_unique_chen_4") then
				if RandomInt(1, 100) <= 12 then
					parent:AddNewModifier(parent, self:GetAbility(), "modifier_gypsy_talents_return_damage", {duration = 3})
				end
			end
			if self:GetCaster():HasTalent("special_bonus_unique_chen_3") then
				if RandomInt(1, 100) <= 16 then
					talent_illusions = CreateIllusions( self:GetCaster(), self:GetCaster(), {Duration=10,outgoing_damage=100,incoming_damage=200}, 1, 1, true, true ) 
					for k, talent_illusion in pairs(talent_illusions) do
						talent_illusion:RemoveModifierByName("modifier_admin")
						talent_illusion:RemoveModifierByName("modifier_gob")
						talent_illusion:RemoveModifierByName("modifier_vip")
						talent_illusion:RemoveModifierByName("modifier_sponsor")
						talent_illusion:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gypsy_tabor_samosud", {})
					end
				end
			end
		end
	end
end

function modifier_gypsy_talents_return_damage:IsHidden()
	return true
end

function modifier_gypsy_talents_return_damage:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_gypsy_talents_return_damage:OnTakeDamage(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attacker = keys.attacker
		local target = keys.unit

		if attacker:GetTeamNumber() ~= parent:GetTeamNumber() and parent == target and not attacker:IsOther() then
			ApplyDamage({victim = attacker, attacker = self:GetParent(), damage = keys.damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
			self:Destroy()
		end
	end
end