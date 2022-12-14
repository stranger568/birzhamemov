LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_gypsy_tabor_illusion","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)

gypsy_tabor = class({})

function gypsy_tabor:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_2")
end

function gypsy_tabor:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	local main_illusion_damage = self:GetSpecialValueFor("illusion_damage") - 100
	local illusion_duration = self:GetSpecialValueFor("illusion_duration")
	local illusion_damage_in = self:GetSpecialValueFor("illusion_damage_in") - 100
	local chance = self:GetSpecialValueFor( "chance" )
	local count_chance_illusions = self:GetSpecialValueFor( "illusion_count" )
	local damage_chance_illusions = self:GetSpecialValueFor( "illusion_damage_out" ) - 100

	self:GetCaster():EmitSound("GypsyTabor")

	local main_illusions = BirzhaCreateIllusion( self:GetCaster(), target, {duration=illusion_duration,outgoing_damage=main_illusion_damage,incoming_damage=illusion_damage_in}, 1, 100, true, true ) 
	for _, main_illusion in pairs(main_illusions) do
		main_illusion:RemoveDonate()
		main_illusion:AddNewModifier(self:GetCaster(), self, "modifier_gypsy_tabor_illusion", {})
	end

	if RollPercentage(chance) then
		local chance_illusions = BirzhaCreateIllusion( self:GetCaster(), target, {duration=illusion_duration,outgoing_damage=damage_chance_illusions,incoming_damage=illusion_damage_in}, count_chance_illusions, 100, true, true ) 
		for _, chance_illusion in pairs(chance_illusions) do
			chance_illusion:RemoveDonate()
			chance_illusion:AddNewModifier(self:GetCaster(), self, "modifier_gypsy_tabor_illusion", {})
		end
	end
end

modifier_gypsy_tabor_illusion = class({})

function modifier_gypsy_tabor_illusion:IsHidden()
	return true
end

function modifier_gypsy_tabor_illusion:GetPriority() return 100000000 end
function modifier_gypsy_tabor_illusion:HeroEffectPriority() return 100000000 end
function modifier_gypsy_tabor_illusion:StatusEffectPriority() return 100000000 end

function modifier_gypsy_tabor_illusion:GetStatusEffectName()
    return "particles/status_fx/status_effect_phantom_lancer_illusion.vpcf"
end

LinkLuaModifier("modifier_gypsy_gipnoz_attack","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_gipnoz_buff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_gipnoz_debuff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_gipnoz_buff_hud","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_gipnoz_debuff_hud","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)

gypsy_gipnoz = class({})

function gypsy_gipnoz:GetIntrinsicModifierName() 
	return "modifier_gypsy_gipnoz_attack"
end

modifier_gypsy_gipnoz_attack = class({})

function modifier_gypsy_gipnoz_attack:IsHidden()
	return true
end

function modifier_gypsy_gipnoz_attack:DeclareFunctions()
	return 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_gypsy_gipnoz_attack:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.attacker:IsIllusion() then return end
	if params.attacker:PassivesDisabled() then return end
	if params.target:IsWard() then return end	
	if not params.target:IsRealHero() then return end

	local stats_steal = self:GetAbility():GetSpecialValueFor("stats_steal")
	local armor_steal = self:GetAbility():GetSpecialValueFor("armor_steal")
	local duration = self:GetAbility():GetSpecialValueFor("duration_debuff") + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_6")

	params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_gypsy_gipnoz_buff", {duration = duration})
	params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_gypsy_gipnoz_debuff", {duration = duration})
	params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_gypsy_gipnoz_buff_hud", {duration = duration})
	params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_gypsy_gipnoz_debuff_hud", {duration = duration})
end

modifier_gypsy_gipnoz_buff_hud = class({})

function modifier_gypsy_gipnoz_buff_hud:OnCreated(kv)
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_gypsy_gipnoz_buff_hud:OnIntervalThink()
	if not IsServer() then return end
	local modifiers = self:GetParent():FindAllModifiersByName("modifier_gypsy_gipnoz_buff")
	self:SetStackCount(#modifiers)
end

function modifier_gypsy_gipnoz_buff_hud:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

	}
end

function modifier_gypsy_gipnoz_buff_hud:GetModifierPhysicalArmorBonus()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor_steal")
end

function modifier_gypsy_gipnoz_buff_hud:GetModifierBonusStats_Strength()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stats_steal")
end

function modifier_gypsy_gipnoz_buff_hud:GetModifierBonusStats_Agility()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stats_steal")
end

function modifier_gypsy_gipnoz_buff_hud:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stats_steal")
end

modifier_gypsy_gipnoz_debuff_hud = class({})

function modifier_gypsy_gipnoz_debuff_hud:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_gypsy_gipnoz_debuff_hud:OnIntervalThink()
	if not IsServer() then return end
	local modifiers = self:GetParent():FindAllModifiersByName("modifier_gypsy_gipnoz_debuff")
	self:SetStackCount(#modifiers)
end

function modifier_gypsy_gipnoz_debuff_hud:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

	}
end

function modifier_gypsy_gipnoz_debuff_hud:GetModifierPhysicalArmorBonus()
    return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor_steal") ) * -1
end

function modifier_gypsy_gipnoz_debuff_hud:GetModifierBonusStats_Strength()
    return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stats_steal") ) * -1
end

function modifier_gypsy_gipnoz_debuff_hud:GetModifierBonusStats_Agility()
    return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stats_steal") ) * -1
end

function modifier_gypsy_gipnoz_debuff_hud:GetModifierBonusStats_Intellect()
    return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stats_steal") ) * -1
end

modifier_gypsy_gipnoz_buff = class({})

function modifier_gypsy_gipnoz_buff:IsHidden()
	return true
end

function modifier_gypsy_gipnoz_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_gypsy_gipnoz_debuff = class({})

function modifier_gypsy_gipnoz_debuff:IsHidden()
	return true
end

function modifier_gypsy_gipnoz_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier( "modifier_gypsy_lucky", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gypsy_lucky_use", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE )

gypsy_lucky = class({})

function gypsy_lucky:GetIntrinsicModifierName()
	return "modifier_gypsy_lucky"
end

modifier_gypsy_lucky = class({})

modifier_gypsy_lucky.one_target = 
{
	["ogre_magi_fireblast_custom"] = true,
	["ogre_magi_unrefined_fireblast_custom"] = true,
}

function modifier_gypsy_lucky:IsPurgable()
	return false
end

function modifier_gypsy_lucky:IsHidden()
	return true
end

function modifier_gypsy_lucky:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end

function modifier_gypsy_lucky:OnAbilityFullyCast( params )
	if params.unit~=self:GetCaster() then return end
	if params.ability==self:GetAbility() then return end
	if self:GetCaster():PassivesDisabled() then return end

	if not params.target then return end
	if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_POINT ) ~= 0 then return end
	if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET ) ~= 0 then return end
	if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_CHANNELLED ) ~= 0 then return end

	if params.ability:GetAbilityName() == "gypsy_steal" then return end

	local target = params.target
	local multicast_multi = 1

	self.chance_2 = self:GetAbility():GetSpecialValueFor( "chance_multi_1" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_8")
	self.chance_3 = self:GetAbility():GetSpecialValueFor( "chance_multi_2" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_8")
	self.chance_4 = self:GetAbility():GetSpecialValueFor( "chance_multi_3" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_8")
	self.chance_5 = self:GetAbility():GetSpecialValueFor( "chance_multi_4" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_8")

	if RollPseudoRandomPercentage(self.chance_5, 6, self:GetParent()) then 
		multicast_multi = 5 
	else 
		if RollPseudoRandomPercentage(self.chance_4, 7, self:GetParent()) then 
			multicast_multi = 4 
		else 
			if RollPseudoRandomPercentage(self.chance_3, 8, self:GetParent()) then
				multicast_multi = 3 
			else
				if RollPseudoRandomPercentage(self.chance_2, 9, self:GetParent()) then
					multicast_multi = 2 
				end
			end
		end
	end


	local delay = FrameTime()
	local single = self.one_target[params.ability:GetAbilityName()] or false

	self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_gypsy_lucky_use", { ability = params.ability:entindex(), target = target:entindex(), multicast = multicast_multi, delay = delay, single = single, } )
end

modifier_gypsy_lucky_use = class({})

function modifier_gypsy_lucky_use:IsHidden()
	return true
end

function modifier_gypsy_lucky_use:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_gypsy_lucky_use:IsPurgable()
	return false
end

function modifier_gypsy_lucky_use:RemoveOnDeath()
	return false
end

function modifier_gypsy_lucky_use:OnCreated( kv )
	if not IsServer() then return end
	self.caster = self:GetParent()
	self.ability = EntIndexToHScript( kv.ability )
	self.target = EntIndexToHScript( kv.target )
	self.multicast = kv.multicast
	self.delay = kv.delay
	self.single = kv.single==1
	self.buffer_range = 600
	self:SetStackCount( self.multicast )

	self.casts = 0
	if self.multicast==1 then
		self:Destroy()
		return
	end

	self.targets = {}
	self.targets[self.target] = true
	self.radius = self.ability:GetCastRange( self.target:GetOrigin(), self.target ) + self.buffer_range
	self.target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY

	if self.target:GetTeamNumber()~=self.caster:GetTeamNumber() then
		self.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	end

	self.target_type = self.ability:GetAbilityTargetType()
	if self.target_type==DOTA_UNIT_TARGET_CUSTOM then
		self.target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	end

	self.target_flags = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	if bit.band( self.ability:GetAbilityTargetFlags(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES ) ~= 0 then
		self.target_flags = self.target_flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end

	self:PlayEffects( self.multicast )
	self:StartIntervalThink( self.delay )
end

function modifier_gypsy_lucky_use:OnIntervalThink()
	local current_target = nil

	if self.single then
		current_target = self.target
	else
		local units = FindUnitsInRadius( self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, self.radius, self.target_team, self.target_type, self.target_flags, FIND_CLOSEST, false )
		if #units <= 0 then
			self:StartIntervalThink( -1 )
			self:Destroy()
			return
		end
		
		local unit = units[RandomInt(1, #units)]

		local filter = false
		if self.ability.CastFilterResultTarget then
			filter = self.ability:CastFilterResultTarget( unit ) == UF_SUCCESS
		else
			filter = true
		end

		if filter then
			current_target = unit
		end


		if not current_target then
			self:StartIntervalThink( -1 )
			self:Destroy()
			return
		end
	end

	self.caster:SetCursorCastTarget( current_target )
	self.ability:OnSpellStart()

	self.casts = self.casts + 1
	if self.casts>=(self.multicast-1) then
		self:StartIntervalThink( -1 )
		self:Destroy()
	end
end

function modifier_gypsy_lucky_use:PlayEffects( value )
	local nFXIndex = ParticleManager:CreateParticle( "particles/gypsy/gypsy_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( value, 2, 1 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	self:GetParent():EmitSound("GypsyMulticast")
end

LinkLuaModifier( "gypsy_steal_lua", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "gypsy_steal_hidden", "abilities/heroes/gypsy.lua", LUA_MODIFIER_MOTION_NONE )

gypsy_steal = class({})
gypsy_steal_slot1 = class({})
gypsy_steal.failState = nil
gypsy_steal.stolenSpell = nil
gypsy_steal.heroesData = {}
gypsy_steal.currentSpell = nil
gypsy_steal.slot1 = "gypsy_steal_slot1"

function gypsy_steal:GetIntrinsicModifierName()
	return "gypsy_steal_hidden"
end

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

function gypsy_steal:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb( self ) then
		return
	end

	local duration_silence = self:GetSpecialValueFor("duration_silence") + self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_5")

	if caster:GetTeamNumber() ~= target:GetTeamNumber() then
		target:AddNewModifier(caster, self, "modifier_silence", {duration = duration_silence * (1-target:GetStatusResistance())})
	end

	self.stolenSpell = {}
	self.stolenSpell.lastSpell = self:GetLastSpell( target )

	local info = {
		Target = caster,
		Source = target,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf",
		iMoveSpeed = 1200,
		vSourceLoc = target:GetAbsOrigin(),             
		bDrawsOnMinimap = false,                         
		bDodgeable = false,                               
		bVisibleToEnemies = true,                        
		bReplaceExisting = false,                         
	}

	ProjectileManager:CreateTrackingProjectile(info)

	self:GetCaster():EmitSound("GypsyUltimate")
	target:EmitSound("Hero_Rubick.SpellSteal.Target")
end

function gypsy_steal:OnProjectileHit( target, location )
	if target == nil then return end
	if not target:IsAlive() then return end
	self:SetStolenSpell( self.stolenSpell )
	self.stolenSpell = nil

	local steal_duration = self:GetSpecialValueFor("duration")
	if IsInToolsMode() then
		steal_duration = 5
	end
	target:AddNewModifier( self:GetCaster(), self, "gypsy_steal_lua", { duration = steal_duration } )
	target:EmitSound("Hero_Rubick.SpellSteal.Complete")
end

function gypsy_steal:SetLastSpell( hHero, hSpell )
	local heroData = nil
	for _,data in pairs(gypsy_steal.heroesData) do
		if data.handle==hHero then
			heroData = data
			break
		end
	end

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

function gypsy_steal:SetStolenSpell( spellData )
	local spell = spellData.lastSpell
	local interaction = spellData.interaction

	if self.currentSpell~=nil then 
		if self.currentSpell:GetAbilityName() ~= spell:GetAbilityName() then
			self:ForgetSpell()
		else
			return
		end
	end

    local old_spell = false
    for _,hSpell in pairs(self:GetCaster().spell_steal_history) do
        if hSpell ~= nil and hSpell:GetAbilityName() == spell:GetAbilityName() then
            old_spell = true
            break
        end
    end

    if old_spell then
	    for id,hSpell in pairs(self:GetCaster().spell_steal_history) do
	        if hSpell ~= nil and hSpell:GetAbilityName() == spell:GetAbilityName() then
	            table.remove(self:GetCaster().spell_steal_history, id)
	        end
	    end
        self.currentSpell = self:GetCaster():FindAbilityByName(spell:GetAbilityName())
    else
        self.currentSpell = self:GetCaster():AddAbility( spell:GetAbilityName() )
        self.currentSpell:SetStolen(true)
        self.currentSpell:SetRefCountsModifiers(true)
    end
    self.currentSpell:SetHidden(false)
	self.currentSpell:SetLevel( spell:GetLevel() )
	if self.currentSpell.OnStolen then self.currentSpell:OnStolen( spell ) end
	self:GetCaster():SwapAbilities( self.slot1, self.currentSpell:GetAbilityName(), false, true )
end

function gypsy_steal:ForgetSpell()
	if self.currentSpell~=nil then
		self.currentSpell:SetRefCountsModifiers(true)
		table.insert(self:GetCaster().spell_steal_history, self.currentSpell)
		if self.currentSpell.OnUnStolen then self.currentSpell:OnUnStolen() end
		self.currentSpell:SetHidden(true)
		self:GetCaster():SwapAbilities( self.currentSpell:GetAbilityName(), self.slot1, false, true )
		self.currentSpell = nil
	end
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

function gypsy_steal:FlagExist(a,b)
	local p,c,d=1,0,b
	while a>0 and b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>1 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	return c==d
end

function gypsy_steal:FlagAdd(a,b)
	if FlagExist(a,b) then
		return a
	else
		return a+b
	end
end

function gypsy_steal:FlagMin(a,b)
	if FlagExist(a,b) then
		return a-b
	else
		return a
	end
end

function gypsy_steal:BitXOR(a,b)
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

function gypsy_steal:BitOR(a,b)
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

function gypsy_steal:BitAND(a,b)
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

function gypsy_steal_lua:RemoveOnDeath()
	return not self:GetCaster():HasTalent("special_bonus_birzha_gypsy_1")
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

function gypsy_steal_hidden:OnCreated()
    if IsServer() then
        self:GetParent().spell_steal_history = {}
        self:StartIntervalThink(FrameTime())
    end
end

function gypsy_steal_hidden:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_EVENT_ON_MODIFIER_ADDED,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}

	return funcs
end

function gypsy_steal_hidden:OnIntervalThink()
    if IsServer() then
        local caster = self:GetParent()
        for i=#caster.spell_steal_history,1,-1 do
            local hSpell = caster.spell_steal_history[i]
            if hSpell and not hSpell:IsNull() then
	            if hSpell:NumModifiersUsingAbility() <= 0 and not hSpell:IsChanneling() then
	            	hSpell:SetHidden(true)
	                self:GetCaster():RemoveAbility(hSpell:GetAbilityName())
	                table.remove(caster.spell_steal_history,i)
	            end
	        end
        end
    end
end

function gypsy_steal_hidden:OnAbilityFullyCast( params )
	if IsServer() then

		if params.unit == self:GetParent() then
			if self:GetParent():HasTalent("special_bonus_birzha_gypsy_3") then
				if params.ability then
					if params.ability == self:GetAbility().currentSpell then
						if params.ability:GetCooldownTimeRemaining() > 0 then
							if params.ability:GetCooldownTimeRemaining() - (params.ability:GetCooldown(params.ability:GetLevel() - 1) / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_3")) > 0 then
								local new_cooldown = params.ability:GetCooldownTimeRemaining() - (params.ability:GetCooldown(params.ability:GetLevel() - 1) / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_3"))
								params.ability:EndCooldown()
								params.ability:StartCooldown(new_cooldown)
							else
								params.ability:EndCooldown()
							end
						end
					end
				end
			end
		end

		if params.unit==self:GetParent() and (not params.ability:IsItem()) then
			return
		end
		if params.ability:IsItem() then
			return
		end
		if params.unit:IsIllusion() then
			return
		end

		if params.ability:IsStolen() then
			return
		end

		local useless_abilities = 
		{
			"haku_mask",
			"aang_quas",
			"aang_wex",
			"aang_exort",
			"aang_invoke",
			"aang_lunge",
			"aang_ice_wall",
			"aang_vacuum",
			"aang_fast_hit",
			"aang_jumping",
			"aang_agility",
			"aang_fire_hit",
			"aang_lightning",
			"aang_firestone",
			"aang_avatar",
			"kakashi_quas",
			"kakashi_wex",
			"kakashi_exort",
			"kakashi_invoke",
			"kakashi_lightning",
			"kakashi_raikiri",
			"kakashi_lightning_hit",
			"kakashi_shadow_clone",
			"kakashi_tornado",
			"kakashi_graze_wave",
			"kakashi_susano",
			"kakashi_ligning_sphere",
			"kakashi_meteor",
			"kakashi_sharingan",
			"rin_satana_explosion",
			"travoman_remote_mines",
			"travoman_focused_detonate",
			"jull_light_future",
			"jull_steal_time",
			"pyramide_passive",
			"pucci_restart_world",
			"haku_help",
			"pucci_time_acceleration",
			"Overlord_one_book",
			"Overlord_two_book",
			"Overlord_three_book",
			"overlord_spellbook_close",
			"migi_inside",
			"polnaref_stand",
			"polnaref_stand_inside",
			"horo_ultimate",
			"Miku_DanceSong_cancel",
			"Dio_TheWorld",
			"V1lat_ItsNotNormal",
			"V1lat_AiAiAi_slam",
			"yakubovich_roll",
			"yakubovich_roll_scepter",
			"yakubovich_roll_return",
			"yakubovich_roll_return_scepter",
			"Slidan_ReallyClassic",
			"Zema_cosmo_ray_stop",
			"monika_perception_teleport",
			"Robi_WeAreNumberOneTeleport",
			"goku_saiyan",
			"gypsy_tabor",
			"gypsy_gipnoz",
			"gypsy_lucky",
			"gypsy_debosh",
			"gypsy_steal_slot1",
			"gypsy_steal",
			"thomas_ability_two_one",
			"thomas_ability_three",
			"thomas_ability_two_two",
		}

		local stop_please = false

		for _, useless in pairs(useless_abilities) do
			if params.ability:GetAbilityName() == useless then
				stop_please = true
				break
			end
		end

		if stop_please then
			return
		end

		self:GetAbility():SetLastSpell( params.unit, params.ability )
	end
end


function gypsy_steal_hidden:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then 
		if params.inflictor ~= nil then
			if params.inflictor == self:GetAbility().currentSpell then
				if self:GetParent():HasTalent("special_bonus_birzha_gypsy_7") then
					return self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_7")
				end
			end
		end
	end
end

function gypsy_steal_hidden:OnModifierAdded(params)
	if not IsServer() then return end
	if params.unit == self:GetParent() then return end
	if params.added_buff:GetCaster() ~= self:GetParent() then return end
	if not params.added_buff:IsDebuff() then return end
	if params.added_buff:GetDuration() <= 0 then return end
	if params.added_buff:GetName() == "modifier_cyclone" then return end
	if params.added_buff:GetName() == "modifier_eul_cyclone" then return end
	if params.added_buff:GetName() == "modifier_eul_cyclone_thinker" then return end
	if params.added_buff:GetName() == "modifier_eul_wind_waker_thinker" then return end
	if params.added_buff:GetName() == "modifier_wind_waker" then return end
	if params.added_buff:GetAbility() ~= self:GetAbility().currentSpell then return end
	if not self:GetParent():HasTalent("special_bonus_birzha_gypsy_4") then return end
	local new_duration = params.added_buff:GetDuration() + (params.added_buff:GetDuration() / 100 * self:GetCaster():FindTalentValue("special_bonus_birzha_gypsy_4"))
	params.added_buff:SetDuration(new_duration, true)
end






























LinkLuaModifier("modifier_gypsy_debosh_caster_debuff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gypsy_debosh_target_debuff","abilities/heroes/gypsy.lua",LUA_MODIFIER_MOTION_NONE)

gypsy_debosh = class({})

function gypsy_debosh:OnInventoryContentsChanged()
    if self:GetCaster():HasShard() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function gypsy_debosh:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	local debuff_duration = self:GetSpecialValueFor( "debuff_duration" )

	local info = 
	{
		EffectName = "particles/gypsy/skill_debosh.vpcf",
		Dodgeable = true,
		Ability = self,
		ProvidesVision = true,
		VisionRadius = 600,
		bVisibleToEnemies = true,
		iMoveSpeed = 1500,
		Source = self:GetCaster(),
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		Target = target,
		bReplaceExisting = false,
	}

	local bottle = ProjectileManager:CreateTrackingProjectile(info)

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gypsy_debosh_caster_debuff", {duration = debuff_duration * (1-self:GetCaster():GetStatusResistance())})

	self:GetCaster():EmitSound("GypsyDebosh")
end

function gypsy_debosh:OnProjectileHit(target,_)
	if target ~= nil and target:IsAlive() then

		local stun_duration = self:GetSpecialValueFor( "stun_duration" )

		target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned", {duration = stun_duration * (1 - target:GetStatusResistance())})

		local bonus_damage = self:GetSpecialValueFor( "bonus_damage" )

		local damage = self:GetSpecialValueFor( "damage" )

		local modifier = target:FindModifierByName( "modifier_gypsy_debosh_target_debuff" )

		local effect_duration = self:GetSpecialValueFor( "effect_duration" )

		target:AddNewModifier(self:GetCaster(), self, "modifier_gypsy_debosh_target_debuff", {duration = effect_duration * (1-target:GetStatusResistance())})

		local modifier = target:FindModifierByName("modifier_gypsy_debosh_target_debuff")

		local full_damage = damage
		if modifier then
			full_damage = full_damage + (bonus_damage * modifier:GetStackCount())
		end

		target:EmitSound("GypsyDebosh")

		ApplyDamage({attacker = self:GetCaster(), victim = target, ability = self, damage = full_damage, damage_type = DAMAGE_TYPE_PURE})
	end
end

modifier_gypsy_debosh_target_debuff = class({})

function modifier_gypsy_debosh_target_debuff:IsHidden()
	return false
end

function modifier_gypsy_debosh_target_debuff:IsPurgable() return false end

function modifier_gypsy_debosh_target_debuff:OnCreated()
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_gypsy_debosh_target_debuff:OnRefresh()
	if not IsServer() then return end
	self:IncrementStackCount()
end

modifier_gypsy_debosh_caster_debuff = class({})

function modifier_gypsy_debosh_caster_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_MISS_PERCENTAGE }
end

function modifier_gypsy_debosh_caster_debuff:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor( "magic_resist" )
end

function modifier_gypsy_debosh_caster_debuff:GetModifierMiss_Percentage()
	return 100
end