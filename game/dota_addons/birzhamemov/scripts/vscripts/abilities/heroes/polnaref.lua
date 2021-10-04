LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_polnaref_stand_caster", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_stand", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_disarm", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)

polnaref_stand = class({})

function polnaref_stand:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_stand:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_stand:OnUpgrade()
     if self.stand and IsValidEntity(self.stand) and self.stand:IsAlive() then
        self.stand:FindModifierByName("modifier_polnaref_stand"):ForceRefresh()
    end
end

function polnaref_stand:GetIntrinsicModifierName() 
    return "modifier_polnaref_stand_caster"
end

function polnaref_stand:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local player = caster:GetPlayerID()
    local ability = self
    local level = self:GetLevel()
    local origin = caster:GetAbsOrigin() + RandomVector(100)

    if self.stand and IsValidEntity(self.stand) and self.stand:IsAlive() then
        self.stand:Kill( self, self:GetCaster() )
        self:EndCooldown()
    elseif self.stand then
        self.stand:RespawnUnit() 
        FindClearSpaceForUnit(self.stand, origin, true)
        self.stand:AddNewModifier(self:GetCaster(), self, 'modifier_polnaref_stand', {})
        self.stand:SetForwardVector( self:GetCaster():GetForwardVector() )
        self.stand:EmitSound("PolnarefChariot")
        Timers:CreateTimer(0.1, function()         self.particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.stand)
        ParticleManager:SetParticleControl(self.particle, 0, self.stand:GetAbsOrigin()) end)
    else
        self.stand = CreateUnitByName("npc_palnoref_chariot", origin, true, caster, caster, caster:GetTeamNumber())
        self.stand:SetControllableByPlayer(player, true)
        self.stand:SetOwner(self:GetCaster())
        self.stand:AddNewModifier(self:GetCaster(), self, 'modifier_polnaref_stand', {})
        self.stand:SetForwardVector( self:GetCaster():GetForwardVector() )
        self.stand:EmitSound("PolnarefChariot")
        self.particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.stand)
        ParticleManager:SetParticleControl(self.particle, 0, self.stand:GetAbsOrigin())
        --for i = 0, 8 do
        --    local items_list = CustomNetTables:GetTableValue('stand_items', tostring(i))
        --    if items_list then
        --        local new_item = items_list.item
        --        if new_item then
        --            local item_created = CreateItem( new_item, self:GetCaster(), self:GetCaster())
        --            self.stand:AddItem(item_created)
        --            item_created:SetPurchaseTime(0)
        --            self.stand:SwapItems(item_created:GetItemSlot(), items_list.slot)
        --        end
        --    end
        --end 
        self.stand:SetUnitCanRespawn(true)  
    end
end

modifier_polnaref_stand = class({})

function modifier_polnaref_stand:IsHidden()
    return true
end

function modifier_polnaref_stand:IsPurgable()
    return false
end

function modifier_polnaref_stand:OnCreated(keys)
    if not IsServer() then return end
    local abilka_hp = 0
    if self:GetParent():GetOwner():FindModifierByName("modifier_polnaref_battle_exp") then
        abilka_hp = (self:GetParent():GetOwner():FindModifierByName("modifier_polnaref_battle_exp"):GetAbility():GetSpecialValueFor("bonus_health") + self:GetParent():GetOwner():FindTalentValue("special_bonus_birzha_polnaref_3")) / 100
    end
    self.b_damage = self:GetAbility():GetSpecialValueFor("stand_damage") + self:GetParent():GetOwner():GetBaseDamageMax()
    self.b_health = self:GetAbility():GetSpecialValueFor("stand_hp") + self:GetParent():GetOwner():GetMaxHealth() + (abilka_hp * self:GetParent():GetOwner():GetMaxHealth())
    self.b_armor = self:GetAbility():GetSpecialValueFor("stand_armor") + self:GetParent():GetOwner():GetPhysicalArmorValue(false)
    self.attack_speed = self:GetParent():GetOwner():GetAttackSpeed() * 100
    self.mana = self:GetParent():GetOwner():GetMaxMana()
    self.hp_regen = self:GetParent():GetOwner():GetHealthRegen()
    self:GetParent():SetBaseHealthRegen(self.hp_regen)
    self:GetParent():SetMaxMana(self.mana)
    self:GetParent():SetMana(self.mana)
    self:SetStackCount(self.attack_speed)
    self:GetParent():SetBaseDamageMin(self.b_damage)
    self:GetParent():SetBaseDamageMax(self.b_damage)
    self:GetParent():SetBaseMaxHealth(self.b_health)
    self:GetParent():SetMaxHealth(self.b_health)
    self:GetParent():SetHealth(self:GetParent():GetMaxHealth())
    self:GetParent():SetPhysicalArmorBaseValue(self.b_armor)
    self:GetParent():FindAbilityByName("polnaref_rapier"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_stand"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_chariotarmor"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_battle_exp"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_shoot"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_ragess"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_afterimage"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_requeim"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_sleep"):SetLevel(0)
    self:GetParent():FindAbilityByName("polnaref_regeneration"):SetLevel(0)
    self:GetParent():FindAbilityByName("polnaref_return"):SetLevel(0)
    self:GetParent():FindAbilityByName("polnaref_darkheart"):SetLevel(0)
    if self:GetParent():GetOwner():HasTalent("special_bonus_birzha_polnaref_5") then
        self.resist = 100
    else
        self.resist = 0
    end
    self:StartIntervalThink(FrameTime())
end

function modifier_polnaref_stand:OnRefresh(keys)
    if not IsServer() then return end
    local abilka_hp = 0
    if self:GetParent():GetOwner():FindModifierByName("modifier_polnaref_battle_exp") then
        abilka_hp = (self:GetParent():GetOwner():FindModifierByName("modifier_polnaref_battle_exp"):GetAbility():GetSpecialValueFor("bonus_health") + self:GetParent():GetOwner():FindTalentValue("special_bonus_birzha_polnaref_3")) / 100
    end
    self.b_damage = self:GetAbility():GetSpecialValueFor("stand_damage") + self:GetParent():GetOwner():GetBaseDamageMax()
    self.b_health = self:GetAbility():GetSpecialValueFor("stand_hp") + self:GetParent():GetOwner():GetMaxHealth() + (abilka_hp * self:GetParent():GetOwner():GetMaxHealth())
    self.b_armor = self:GetAbility():GetSpecialValueFor("stand_armor") + self:GetParent():GetOwner():GetPhysicalArmorValue(false)
    self.hp_regen = self:GetParent():GetOwner():GetHealthRegen()
    self.attack_speed = self:GetParent():GetOwner():GetAttackSpeed() * 100
    self.mana = self:GetParent():GetOwner():GetMaxMana()
    self:GetParent():SetBaseHealthRegen(self.hp_regen)  
    self:GetParent():SetMaxMana(self.mana)
    self:SetStackCount(self.attack_speed)
    self:GetParent():SetBaseAttackTime(self:GetParent():GetOwner():GetBaseAttackTime())
    self:GetParent():SetBaseDamageMin(self.b_damage)
    self:GetParent():SetBaseDamageMax(self.b_damage)
    self:GetParent():SetBaseMaxHealth(self.b_health)
    self:GetParent():SetMaxHealth(self.b_health)
    self:GetParent():SetPhysicalArmorBaseValue(self.b_armor)
    self:GetParent():FindAbilityByName("polnaref_rapier"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_stand"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_chariotarmor"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_battle_exp"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_shoot"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_ragess"):GetLevel())
    self:GetParent():FindAbilityByName("polnaref_afterimage"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_requeim"):GetLevel())
    --for i = 0, 8 do
    --    CustomNetTables:SetTableValue('stand_items', tostring(i), {item = nil})
    --    local item = self:GetParent():GetItemInSlot(i)
    --    if item then
    --        CustomNetTables:SetTableValue('stand_items', tostring(i), {item = item:GetName(), slot = item:GetItemSlot()})
    --    end
    --end
    if self:GetParent():GetOwner():HasTalent("special_bonus_birzha_polnaref_5") then
        self.resist = 100
    else
        self.resist = 0
    end
end

function modifier_polnaref_stand:OnIntervalThink()
    if not IsServer() then return end
    self:OnRefresh()
    if self:GetCaster():HasScepter() or self:GetCaster():HasModifier("modifier_polnaref_requeim") then self:GetParent():RemoveModifierByName("modifier_polnaref_disarm") return end
    local friends = FindUnitsInRadius(
	    self:GetCaster():GetTeamNumber(),
	    self:GetParent():GetOrigin(),
	    nil,
	    1300,
	    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	    DOTA_UNIT_TARGET_HERO,
	    0,
	    FIND_CLOSEST,
	    false
    )
    for _,target in pairs(friends) do
    	if self:GetParent():GetOwner() == target then
    		self:GetParent():RemoveModifierByName("modifier_polnaref_disarm")
    		return
    	end
    end
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_polnaref_disarm', {})
end

function modifier_polnaref_stand:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }

    return funcs
end

function modifier_polnaref_stand:OnDeath( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        --for i = 0, 8 do
        --    local items_list = CustomNetTables:GetTableValue('stand_items', tostring(i))
        --    if items_list then
        --        local new_item = items_list.item
        --        if new_item then
        --            if new_item == "item_rapier" then
        --                CustomNetTables:SetTableValue('stand_items', tostring(i), {item = nil})
        --            end
        --        end
        --    end
        --end 
        if self:GetCaster():HasScepter() then return end
        if params.attacker == self:GetCaster() then return end
		ApplyDamage({ victim = self:GetCaster(), attacker = params.attacker, damage = 1000000, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE })
    end
end

function modifier_polnaref_stand:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetStackCount()
end

function modifier_polnaref_stand:GetModifierManaBonus( params )
    return self.mana
end

function modifier_polnaref_stand:GetModifierMagicalResistanceBonus( params )
    return self.resist
end

function modifier_polnaref_stand:GetModifierMoveSpeed_Absolute( params )
    if self:GetCaster():HasModifier("modifier_polnaref_requeim") then
        return 300
    end
    return self:GetAbility():GetSpecialValueFor("stand_ms")
end

modifier_polnaref_disarm = class({})

function modifier_polnaref_disarm:IsHidden()
    return true
end

function modifier_polnaref_disarm:IsPurgable()
    return false
end

function modifier_polnaref_disarm:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end

modifier_polnaref_stand_caster = class({})

function modifier_polnaref_stand_caster:IsHidden()
    return true
end

function modifier_polnaref_stand_caster:IsPurgable()
    return false
end

function modifier_polnaref_stand_caster:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_MIN_HEALTH
    }

    return funcs
end

function modifier_polnaref_stand_caster:GetMinHealth()
    if not self:GetParent():HasModifier("modifier_polnaref_requeim") then return end
    return 1
end

function modifier_polnaref_stand_caster:CheckState()
    if not self:GetParent():HasModifier("modifier_polnaref_requeim") then return end
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end

function modifier_polnaref_stand_caster:OnDeath( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        if self:GetCaster():HasScepter() or self:GetCaster():HasModifier("modifier_polnaref_requeim") then return end
        local friends = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            self:GetParent():GetOrigin(),
            nil,
            FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            0,
            FIND_CLOSEST,
            false
        )
        for _,target in pairs(friends) do
            if target:GetUnitName() == "npc_palnoref_chariot" then
                if self:GetCaster():IsIllusion() then return end
                ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = 1000000, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE })
            end
        end
    end
end

LinkLuaModifier("modifier_polnaref_battle_exp", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)

polnaref_battle_exp = class({})

function polnaref_battle_exp:GetIntrinsicModifierName()
    return "modifier_polnaref_battle_exp"
end

modifier_polnaref_battle_exp = class({})

function modifier_polnaref_battle_exp:IsHidden()
    return true
end

function modifier_polnaref_battle_exp:OnCreated()
    self.armor = self:GetParent():GetPhysicalArmorValue(false) / 100 * (self:GetAbility():GetSpecialValueFor("bonus_armor"))
    self:StartIntervalThink(FrameTime())
    if not IsServer() then return end
end

function modifier_polnaref_battle_exp:OnIntervalThink()
    self.armor = self:GetParent():GetPhysicalArmorValue(false) / 100 * (self:GetAbility():GetSpecialValueFor("bonus_armor"))
    if not IsServer() then return end
end

function modifier_polnaref_battle_exp:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
    return declfuncs
end

function modifier_polnaref_battle_exp:GetModifierPhysicalArmorBonus()
    if self:GetParent():PassivesDisabled() then return end
    return self.armor
end

LinkLuaModifier("modifier_polnaref_ragess", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)

polnaref_ragess = class({})

function polnaref_ragess:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_polnaref_2")
end

function polnaref_ragess:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_ragess:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_polnaref_1")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_ragess", { duration = duration } ) 
    self:GetCaster():EmitSound("PolnarefRage") 
end

modifier_polnaref_ragess = class({})

function modifier_polnaref_ragess:IsHidden()
    return false
end

function modifier_polnaref_ragess:IsPurgable()
    return false
end

function modifier_polnaref_ragess:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_polnaref_ragess:GetModifierBaseAttackTimeConstant()
    return 0.001
end

function modifier_polnaref_ragess:GetModifierAttackSpeedBonus_Constant()
    return 350
end

function modifier_polnaref_ragess:GetEffectName()
    return "particles/polnaref/polnaref_rage.vpcf"
end

function modifier_polnaref_ragess:GetStatusEffectName()
    return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

LinkLuaModifier("modifier_polnaref_requeim", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_requeim_aura", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)

polnaref_requeim = class({})

function polnaref_requeim:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_requeim:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_requeim:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    if self:GetCaster():HasTalent("special_bonus_birzha_polnaref_4") then
        behavior = behavior + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
    end
    return behavior
end

function polnaref_requeim:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_polnaref_7")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_requeim", { duration = duration } )  
end

modifier_polnaref_requeim = ({})

function modifier_polnaref_requeim:IsPurgable()
    return false
end

function modifier_polnaref_requeim:RemoveOnDeath()
    return false
end

function modifier_polnaref_requeim:IsAura() return true end

function modifier_polnaref_requeim:GetAuraRadius()
    return FIND_UNITS_EVERYWHERE
end
function modifier_polnaref_requeim:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_polnaref_requeim:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end


function modifier_polnaref_requeim:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_polnaref_requeim:GetModifierAura()
    return "modifier_polnaref_requeim_aura"
end

modifier_polnaref_requeim_aura = ({})

function modifier_polnaref_requeim_aura:IsHidden()
    return true
end

function modifier_polnaref_requeim_aura:OnCreated()
    if not IsServer() then return end
    if self:GetParent():GetUnitName() == "npc_palnoref_chariot" then
        self:GetParent():SwapAbilities("polnaref_rapier", "polnaref_sleep", false, true)
        self:GetParent():SwapAbilities("polnaref_chariotarmor", "polnaref_regeneration", false, true)
        self:GetParent():SwapAbilities("polnaref_shoot", "polnaref_return", false, true)
        self:GetParent():SwapAbilities("polnaref_afterimage", "polnaref_darkheart", false, true)
        self:GetParent():FindAbilityByName("polnaref_rapier"):SetLevel(0)
        self:GetParent():FindAbilityByName("polnaref_chariotarmor"):SetLevel(0)
        self:GetParent():FindAbilityByName("polnaref_shoot"):SetLevel(0)
        self:GetParent():FindAbilityByName("polnaref_afterimage"):SetLevel(0)
        self:GetParent():FindAbilityByName("polnaref_sleep"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_requeim"):GetLevel())
        self:GetParent():FindAbilityByName("polnaref_regeneration"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_requeim"):GetLevel())
        self:GetParent():FindAbilityByName("polnaref_return"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_requeim"):GetLevel())
        self:GetParent():FindAbilityByName("polnaref_darkheart"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_requeim"):GetLevel())
        self:GetParent():SetRenderColor(0, 0, 0)
    end
end

function modifier_polnaref_requeim_aura:OnDestroy()
    if not IsServer() then return end
    if self:GetParent():GetUnitName() == "npc_palnoref_chariot" then
        self:GetParent():SwapAbilities("polnaref_sleep", "polnaref_rapier", false, true)
        self:GetParent():SwapAbilities("polnaref_regeneration", "polnaref_chariotarmor", false, true)
        self:GetParent():SwapAbilities("polnaref_return", "polnaref_shoot", false, true)
        self:GetParent():SwapAbilities("polnaref_darkheart", "polnaref_afterimage", false, true)
        self:GetParent():FindAbilityByName("polnaref_rapier"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_stand"):GetLevel())
        self:GetParent():FindAbilityByName("polnaref_chariotarmor"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_battle_exp"):GetLevel())
        self:GetParent():FindAbilityByName("polnaref_shoot"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_ragess"):GetLevel())
        self:GetParent():FindAbilityByName("polnaref_afterimage"):SetLevel(self:GetParent():GetOwner():FindAbilityByName("polnaref_requeim"):GetLevel())
        self:GetParent():FindAbilityByName("polnaref_sleep"):SetLevel(0)
        self:GetParent():FindAbilityByName("polnaref_regeneration"):SetLevel(0)
        self:GetParent():FindAbilityByName("polnaref_return"):SetLevel(0)
        self:GetParent():FindAbilityByName("polnaref_darkheart"):SetLevel(0)
        self:GetParent():SetRenderColor(255, 255, 255)
    end
end

LinkLuaModifier("modifier_polnaref_rapier", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)

polnaref_rapier = class({})

function polnaref_rapier:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_rapier:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_rapier:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor( "range" )
end

function polnaref_rapier:GetChannelTime()
    return self.BaseClass.GetChannelTime(self)
end

function polnaref_rapier:OnSpellStart() 
    self.target = self:GetCursorPosition()
    local duration = self:GetChannelTime()
    if self.target == nil then
        return
    end
    if self:GetCaster():HasModifier("modifier_polnaref_shoot_debuff") then
        self:GetCaster():GiveMana(self:GetManaCost(self:GetLevel()))
        self:EndCooldown()
        self:EndChannel( false )
        return
    end
    self.modifier_caster = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_rapier", { duration = self:GetChannelTime() } )
    self:GetCaster():EmitSound("PolnarefRapier")
end

function polnaref_rapier:OnChannelFinish( bInterrupted )
    if self:GetCaster():HasModifier("modifier_polnaref_shoot_debuff") then
        return
    end
    self.modifier_caster:Destroy()
end

modifier_polnaref_rapier = class({}) 

function modifier_polnaref_rapier:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.2)
    self.point = self:GetAbility().target
    self.origin = self:GetParent():GetOrigin()
    self.dist = self:GetAbility():GetSpecialValueFor( "range" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.attack_count = self:GetAbility():GetSpecialValueFor( "attack_count" ) + self:GetParent():GetOwner():FindTalentValue("special_bonus_birzha_polnaref_6")
    local direction = (self.point-self.origin)
    local dist = math.max( math.min( self.dist, direction:Length2D() ), self.dist )
    direction.z = 0
    direction = direction:Normalized()
    self.main_point = GetGroundPosition( self.origin + direction*dist, nil )
    self.particle_point = self.main_point
    self.particle_point.z = self.main_point.z + 128
end

function modifier_polnaref_rapier:IsHidden()
    return true
end

function modifier_polnaref_rapier:IsPurgable()
    return false
end

function modifier_polnaref_rapier:OnIntervalThink()
    if self.attack_count <= 0 and self:GetAbility():IsChanneling() then
        self:GetAbility():EndChannel( false )
        self:Destroy()
        return
    end
    self.attack_count = self.attack_count - 1
    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 5)
    local enemies = FindUnitsInLine(
        self:GetCaster():GetTeamNumber(),
        self.origin,
        self.main_point,
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    )

    self.zap_particle = ParticleManager:CreateParticle("particles/polnaref/attack_particle.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.zap_particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.zap_particle, 1, nil, PATTACH_POINT_FOLLOW, "attach_hitloc", self.particle_point, true)
    ParticleManager:SetParticleControl(self.zap_particle, 2, Vector(1, 1, 1))
    ParticleManager:ReleaseParticleIndex(self.zap_particle)

    for _,enemy in pairs(enemies) do
        self:GetCaster():PerformAttack( enemy, true, true, true, true, false, false, true )
    end
end

function modifier_polnaref_rapier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }

    return funcs
end

function modifier_polnaref_rapier:GetModifierProcAttack_BonusDamage_Physical( params )
    local damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
    return damage
end


LinkLuaModifier("modifier_polnaref_chariotarmor", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)

polnaref_chariotarmor = class({})

function polnaref_chariotarmor:GetIntrinsicModifierName()
    return "modifier_polnaref_chariotarmor"
end

modifier_polnaref_chariotarmor = class({})

function modifier_polnaref_chariotarmor:IsHidden()
    return true
end

function modifier_polnaref_chariotarmor:IsPurgable()
    return false
end

function modifier_polnaref_chariotarmor:OnCreated()
    if not IsServer() then return end
    self.max_effect = self:GetAbility():GetSpecialValueFor( "max_effect" )
    self:StartIntervalThink(FrameTime())
end

function modifier_polnaref_chariotarmor:OnIntervalThink()
    if not IsServer() then return end
    self.attackspeed = self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )
    local max_health = self:GetParent():GetMaxHealth()
    local health = self:GetParent():GetHealth()
    local stack = self:GetParent():GetHealth() / self:GetParent():GetMaxHealth() * 100
    if stack < self.max_effect then
        stack = 25
    end
    local perc = 100 - stack
    self:SetStackCount(perc)
end

function modifier_polnaref_chariotarmor:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
    return declfuncs
end

function modifier_polnaref_chariotarmor:GetModifierAttackSpeedBonus_Constant()
    if self:GetParent():HasModifier("modifier_polnaref_requeim_aura") then return 0 end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )
end

LinkLuaModifier( "modifier_polnaref_shoot", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_polnaref_shoot_debuff", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE )

polnaref_shoot = class({})

function polnaref_shoot:GetCooldown(level) 
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_shoot:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function polnaref_shoot:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_shoot:OnAbilityPhaseStart()
    self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_3 )
    return true
end

function polnaref_shoot:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_3 )
end

function polnaref_shoot:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local cast_direction = (point - caster_loc):Normalized()
    if self:GetCaster():HasModifier("modifier_polnaref_shoot_debuff") then
        self:GetCaster():GiveMana(self:GetManaCost(self:GetLevel()))
        self:EndCooldown()
        return
    end
    if point == caster_loc then
        cast_direction = caster:GetForwardVector()
    else
        cast_direction = (point - caster_loc):Normalized()
    end

    local info = {
        Source = caster,
        Ability = self,
        vSpawnOrigin = caster:GetOrigin(),
        bDeleteOnHit = true,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName = "particles/polnaref_sword.vpcf",
        fDistance = 3000,
        fStartRadius = 75,
        fEndRadius =75,
        vVelocity = cast_direction * 1800,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bProvidesVision = false,
    }
    ProjectileManager:CreateLinearProjectile(info)
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_shoot_debuff", {} )
    self:GetCaster():EmitSound("PolnarefLaunch")
    self:SetActivated(false)
    self:GetCaster():FindAbilityByName("polnaref_rapier"):SetActivated(false)
end

function polnaref_shoot:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil then
        local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_shoot", {} )
        self:GetCaster():PerformAttack ( target, true, true, true, true, false, false, true )
        modifier:Destroy()
    end
end

modifier_polnaref_shoot = class({})

function modifier_polnaref_shoot:IsHidden()
    return true
end

function modifier_polnaref_shoot:IsPurgable()
    return false
end

function modifier_polnaref_shoot:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,

    }

    return funcs
end

function modifier_polnaref_shoot:GetModifierPreAttack_CriticalStrike( params )
    if IsServer() then
        return self:GetAbility():GetSpecialValueFor( "damage_crit" )
    end
end

function modifier_polnaref_shoot:GetModifierProcAttack_BonusDamage_Physical( params )
    local damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
    return damage
end

modifier_polnaref_shoot_debuff = class({})

function modifier_polnaref_shoot_debuff:IsHidden()
    return true
end

function modifier_polnaref_shoot_debuff:IsPurgable()
    return false
end

function modifier_polnaref_shoot_debuff:OnCreated()
    if not IsServer() then return end
    if self:GetParent().chariot_sword then
        self:GetParent().chariot_sword:Destroy()
    end
end

function modifier_polnaref_shoot_debuff:OnDestroy()
    if not IsServer() then return end
    self:GetAbility():SetActivated(true)
    self:GetCaster():FindAbilityByName("polnaref_rapier"):SetActivated(true)
end

function modifier_polnaref_shoot_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end

LinkLuaModifier("modifier_polnaref_afterimage", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_afterimage_illusion", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)

polnaref_afterimage = class({})

function polnaref_afterimage:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_afterimage:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_afterimage:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_polnaref_afterimage", { duration = duration } )  
    self:GetCaster():EmitSound("PolnarefAfterimage")
end

modifier_polnaref_afterimage = class({})

function modifier_polnaref_afterimage:IsHidden()
    return false
end

function modifier_polnaref_afterimage:IsPurgable()
    return false
end

function modifier_polnaref_afterimage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }

    return funcs
end

function modifier_polnaref_afterimage:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_polnaref_afterimage:OnCreated( params )
    if not IsServer() then return end
    self.position = self:GetParent():GetAbsOrigin()
    self:StartIntervalThink(FrameTime())
end

function modifier_polnaref_afterimage:OnIntervalThink()
    if not IsServer() then return end
    local vector_distance = self.position - self:GetParent():GetAbsOrigin()
    local distance = (vector_distance):Length2D()
    if distance >= 300 and distance > 0 then
        self.position = self:GetParent():GetAbsOrigin()
        local dummy = CreateUnitByName( "npc_palnoref_chariot_illusion", self:GetParent():GetAbsOrigin(), true, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber() )
        dummy:SetOwner(self:GetCaster())
        dummy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_polnaref_afterimage_illusion", {})
        dummy:SetForwardVector( self:GetParent():GetForwardVector() )
    end
end

function modifier_polnaref_afterimage:GetEffectName()
    return "particles/polnaref/polnaref_windrun.vpcf"
end

function modifier_polnaref_afterimage:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_polnaref_afterimage_illusion = class({})

function modifier_polnaref_afterimage_illusion:IsHidden()
    return false
end

function modifier_polnaref_afterimage_illusion:IsPurgable()
    return false
end

function modifier_polnaref_afterimage_illusion:OnCreated()
    if not IsServer() then return end
    local perc_damage = self:GetAbility():GetSpecialValueFor("damage")
    local damage = self:GetParent():GetOwner():GetBaseDamageMax() * perc_damage
    self:GetParent():SetBaseDamageMin(damage)
    self:GetParent():SetBaseDamageMax(damage)
    self:GetParent():SetRenderColor(0, 0, 0)
    self:StartIntervalThink(FrameTime())
end

function modifier_polnaref_afterimage_illusion:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetCaster() then self:GetParent():Destroy() return end
    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        self:GetParent():GetOrigin(),
        nil,
        190,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        0,
        false
    )
    if #enemies > 0 then
        for enemy = 1, #enemies do
            if enemies[enemy] and enemies[enemy]:IsAlive() and not enemies[enemy]:IsAttackImmune() and not enemies[enemy]:IsInvulnerable() then
                if self.attack_true then return end
                self.attack_true = true
                self:GetParent():MoveToTargetToAttack(enemies[1])
                self:GetParent():SetForwardVector( (enemies[1]:GetOrigin()-self:GetParent():GetOrigin()):Normalized() )
                self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1)
                Timers:CreateTimer(0.5,function()
                    if self:GetCaster():GetOwner():HasTalent("special_bonus_birzha_polnaref_8") then
                        local direction = enemies[1]:GetOrigin()-self:GetParent():GetOrigin()
                        direction.z = 0
                        direction = direction:Normalized()
                        local point = self:GetParent():GetOrigin() + direction*900
                        local enemies = FindUnitsInLine(
                            self:GetParent():GetTeamNumber(),
                            self:GetParent():GetOrigin(),
                            point,
                            nil,
                            125,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
                        )

                        local particle_point = point
                        particle_point.z = point.z + 128
                        self.zap_particle = ParticleManager:CreateParticle("particles/polnaref/attack_particle.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
                        ParticleManager:SetParticleControlEnt(self.zap_particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
                        ParticleManager:SetParticleControlEnt(self.zap_particle, 1, nil, PATTACH_POINT_FOLLOW, "attach_hitloc", particle_point, true)
                        ParticleManager:SetParticleControl(self.zap_particle, 2, Vector(1, 1, 1))
                        ParticleManager:ReleaseParticleIndex(self.zap_particle)

                        for _,enemy in pairs(enemies) do
                            self:GetParent():PerformAttack( enemy, true, true, true, false, false, false, true)
                        end
                    else
                        self:GetParent():PerformAttack( enemies[1], true, true, true, false, false, false, true)
                    end
                    self:GetParent():Destroy()
                end)
            end
        end
    end
end

function modifier_polnaref_afterimage_illusion:CheckState()
    local state = {
    [MODIFIER_STATE_ROOTED] = true,
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_CANNOT_MISS] = true,
    [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = false,
    [MODIFIER_STATE_OUT_OF_GAME] = true,
    }

    return state
end

function modifier_polnaref_afterimage_illusion:GetEffectName()
    return "particles/polnaref/polnaref_windrun.vpcf"
end

function modifier_polnaref_afterimage_illusion:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier("modifier_polnaref_sleep", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_sleep_debuff", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)

polnaref_sleep = class({})

function polnaref_sleep:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_sleep:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_sleep:OnSpellStart()
    if IsServer() then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_polnaref_sleep", {duration = 0.7})
        self:GetCaster():EmitSound("PolnarefSon")
        Timers:CreateTimer(self:GetSpecialValueFor("sleep_duration"),function()
            self:GetCaster():StopSound("PolnarefSon")
        end)
    end
end

modifier_polnaref_sleep = class({})

function modifier_polnaref_sleep:IsHidden()
    return true
end

function modifier_polnaref_sleep:OnCreated()
    self.parent = self:GetParent()
    self:StartIntervalThink(0.1)
    self.radius_effect = 0
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    self.particle = ParticleManager:CreateParticle("particles/econ/items/razor/razor_ti6/razor_plasmafield_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 1, Vector(1200, radius, 0))
    self:GetAbility().heroes = {}
end

function modifier_polnaref_sleep:OnIntervalThink()
    self.radius_effect = self.radius_effect + 120
    if self.radius_effect >= 600 then
        self.radius_effect = 600
    end
end

function modifier_polnaref_sleep:OnDestroy()
    ParticleManager:DestroyParticle(self.particle,true)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

function modifier_polnaref_sleep:IsAura() return true end

function modifier_polnaref_sleep:GetAuraRadius()
    return self.radius_effect
end
function modifier_polnaref_sleep:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_polnaref_sleep:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_polnaref_sleep:GetModifierAura()
    return "modifier_polnaref_sleep_debuff"
end

modifier_polnaref_sleep_debuff = ({})

function modifier_polnaref_sleep_debuff:IsHidden()
    return true
end

function modifier_polnaref_sleep_debuff:OnCreated()
    if not IsServer() then return end
    if not self:GetParent():IsAlive() then return end
    local info = {
        Target = self:GetCaster(),
        Source = self:GetParent(),
        Ability = self:GetAbility(), 
        EffectName = "particles/polnaref/polnaref_sleep.vpcf",
        iMoveSpeed = 800,
        vSourceLoc = self:GetParent():GetAbsOrigin(),       
        bDrawsOnMinimap = false,                         
        bDodgeable = false,                               
        bVisibleToEnemies = true,                        
        bReplaceExisting = false,                         
    }
    ProjectileManager:CreateTrackingProjectile(info)
    local duration = self:GetAbility():GetSpecialValueFor("sleep_duration")
    self:GetParent():AddNewModifier(self:GetCaster(), self, 'modifier_birzha_stunned', {duration = duration})
    table.insert(self:GetAbility().heroes, self:GetParent():GetAbsOrigin())
end

function modifier_polnaref_sleep_debuff:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SetAbsOrigin(table.remove(self:GetAbility().heroes, RandomInt(1, #self:GetAbility().heroes)))
end

LinkLuaModifier("modifier_polnaref_regeneration", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)

polnaref_regeneration = class({})

function polnaref_regeneration:GetIntrinsicModifierName()
    return "modifier_polnaref_regeneration"
end

modifier_polnaref_regeneration = class({})

function modifier_polnaref_regeneration:IsHidden()
    return true
end

function modifier_polnaref_regeneration:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
    return declfuncs
end

function modifier_polnaref_regeneration:GetModifierHealthRegenPercentage()
    if not self:GetParent():HasModifier("modifier_polnaref_requeim_aura") then return 0 end
    return self:GetAbility():GetSpecialValueFor("regen") / 10
end

LinkLuaModifier("modifier_polnaref_return", "abilities/heroes/polnaref.lua", LUA_MODIFIER_MOTION_NONE)

polnaref_return = class({})

function polnaref_return:GetIntrinsicModifierName()
    return "modifier_polnaref_return"
end

modifier_polnaref_return = class({})

function modifier_polnaref_return:IsHidden()
    return true
end

function modifier_polnaref_return:DeclareFunctions()
    local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}

    return decFuncs
end

function modifier_polnaref_return:OnTakeDamage(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.unit
    local original_damage = keys.original_damage
    local damage_type = keys.damage_type
    local damage_flags = keys.damage_flags
    if keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then  
        if not keys.unit:IsOther() then
            if not self:GetParent():HasModifier("modifier_polnaref_requeim_aura") then return 0 end
            EmitSoundOnClient("DOTA_Item.BladeMail.Damage", keys.attacker:GetPlayerOwner())
            local damage = self:GetAbility():GetSpecialValueFor("return_damage") / 100
            local damageTable = {
                victim          = keys.attacker,
                damage          = keys.original_damage * damage,
                damage_type     = keys.damage_type,
                damage_flags    = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
                attacker        = self:GetParent(),
                ability         = self:GetAbility()
            }
            ApplyDamage(damageTable)
        end
    end
end

LinkLuaModifier("modifier_polnaref_darkheart", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_darkheart_buff", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polnaref_darkheart_illusion_debuff", "abilities/heroes/polnaref", LUA_MODIFIER_MOTION_NONE)

polnaref_darkheart = class({}) 

function polnaref_darkheart:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function polnaref_darkheart:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function polnaref_darkheart:GetChannelTime()
    return self:GetSpecialValueFor("duration")
end

function polnaref_darkheart:OnAbilityPhaseStart()
    if self:GetCaster():GetOwner():HasModifier("modifier_polnaref_ragess") then
        return false
    end
    return true
end

function polnaref_darkheart:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    EmitGlobalSound("")
    GameRules:SetTimeOfDay(duration)
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false)
    for _, enemy in pairs(enemies) do
        if enemy:GetUnitName() == "npc_dota_hero_faceless_void" then return end
        enemy:AddNewModifier(self:GetCaster(), self, "modifier_polnaref_darkheart", {duration = duration})
    end
end

function polnaref_darkheart:OnChannelFinish( bInterrupted )
    if not IsServer() then return end
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false)
    for _, enemy in pairs(enemies) do
        if enemy:HasModifier("modifier_polnaref_darkheart") then
            enemy:RemoveModifierByName( "modifier_polnaref_darkheart" )
        end
    end
end

modifier_polnaref_darkheart = class({})

function modifier_polnaref_darkheart:IsHidden()
    return true
end

function modifier_polnaref_darkheart:OnCreated()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    local origin = self:GetParent():GetAbsOrigin() + RandomVector(100)
    self.dummy = CreateUnitByName( "npc_palnoref_chariot_illusion_2", self:GetParent():GetAbsOrigin(), true, self:GetCaster():GetOwner(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber() )
    self.dummy:SetOwner(self:GetCaster():GetOwner())
    self.dummy:SetAbsOrigin(origin)
    self.dummy:SetForwardVector(self:GetParent():GetAbsOrigin() - self.dummy:GetAbsOrigin())
    self.dummy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_polnaref_darkheart_buff", {enemy_entindex = self:GetParent():entindex()})
    self.dummy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration = duration})
    self.dummy:MoveToTargetToAttack(self:GetParent())
    self.dummy:SetAggroTarget(self:GetParent())
end

function modifier_polnaref_darkheart:OnRefresh()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    local origin = self:GetParent():GetAbsOrigin() + RandomVector(100)
    self.dummy = CreateUnitByName( "npc_palnoref_chariot_illusion_2", self:GetParent():GetAbsOrigin(), true, self:GetCaster():GetOwner(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber() )
    self.dummy:SetOwner(self:GetCaster():GetOwner())
    self.dummy:SetAbsOrigin(origin)
    self.dummy:SetForwardVector(self:GetParent():GetAbsOrigin() - self.dummy:GetAbsOrigin())
    self.dummy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_polnaref_darkheart_buff", {enemy_entindex = self:GetParent():entindex()})
    self.dummy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration = duration})
    self.dummy:MoveToTargetToAttack(self:GetParent())
    self.dummy:SetAggroTarget(self:GetParent())
end

function modifier_polnaref_darkheart:OnDestroy()
    if not IsServer() then return end
    self.dummy:Destroy()
end

modifier_polnaref_darkheart_buff = class({})

function modifier_polnaref_darkheart_buff:IsHidden()
    return true
end

function modifier_polnaref_darkheart_buff:OnCreated(keys)
    if not IsServer() then return end
    self.aggro_target = EntIndexToHScript(keys.enemy_entindex)
    self:GetParent():SetRenderColor(0, 0, 0)
    local apm = self:GetCaster():GetOwner():GetAttacksPerSecond()
    print(apm, 1/apm)
    self:StartIntervalThink(1/apm)
end

function modifier_polnaref_darkheart_buff:OnIntervalThink()
    if not IsServer() then return end
    if not self.aggro_target:IsAlive() then self:Destroy() self:GetParent():Destroy() return end
    if not self:GetParent():GetOwner():HasModifier("modifier_polnaref_requeim") then self:Destroy() self:GetParent():Destroy() return end
    local pos = self.aggro_target:GetAbsOrigin() + RandomVector(100)
    self:GetParent():SetAbsOrigin(pos)
    local angle_vector = self.aggro_target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()
    self:GetParent():SetAngles(0, VectorToAngles(angle_vector).y, 0)
    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 2)
    self:GetCaster():PerformAttack(self.aggro_target, true, true, true, true, false, false, true)
end

function modifier_polnaref_darkheart_buff:CheckState()
    local state = {
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_CANNOT_MISS] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = false,
    [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
    return state
end