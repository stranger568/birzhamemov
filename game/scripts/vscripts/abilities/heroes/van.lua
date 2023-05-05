LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_van_latexglove_debuff", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_van_latexglove_rooted", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )

van_threehundredbucks = class({})

function van_threehundredbucks:CastFilterResultTarget( hTarget )
    if hTarget:IsMagicImmune() and (not self:GetCaster():HasShard()) then
        return UF_FAIL_MAGIC_IMMUNE_ENEMY
    end

    if not IsServer() then return UF_SUCCESS end

    local nResult = UnitFilter(
        hTarget,
        self:GetAbilityTargetTeam(),
        self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(),
        self:GetCaster():GetTeamNumber()
    )

    if nResult ~= UF_SUCCESS then
        return nResult
    end

    return UF_SUCCESS
end

function van_threehundredbucks:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_van_5")
end

function van_threehundredbucks:OnSpellStart()
    if not IsServer() then return end

    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb( self ) then return end

    if not self:GetCaster():HasShard() then
        if target:IsMagicImmune() then return end
    end

    self:GetCaster():EmitSound("VanFisting")

    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetSpecialValueFor("damage")
    local money_accept = self:GetSpecialValueFor("money_accept")
    local agility_damage = self:GetSpecialValueFor("agility_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_van_2")
    local teleport_distance = self:GetSpecialValueFor("teleport_distance")

    local tp_one = target:GetAbsOrigin()+RandomVector(300)

    local particle = ParticleManager:CreateParticle("particles/van/van_bind_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 7, target:GetAbsOrigin())

    local particle_2 = ParticleManager:CreateParticle("particles/van/van_bind_overhead_2.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle_2, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_2, 7, self:GetCaster():GetAbsOrigin())

    if not target:IsIllusion() then
        self:GetCaster():ModifyGold(money_accept, true, 0)
    end

    if not self:GetAutoCastState() then
        self:Effect(tp_one)
        if (target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() <= 1000 then
            FindClearSpaceForUnit(self:GetCaster(), tp_one, true)
        end
        self:GetCaster():MoveToTargetToAttack(target)
        self:Effect2(tp_one, target)
    end

    target:AddNewModifier(self:GetCaster(), self, "modifier_van_latexglove_rooted", {duration = duration * (1-target:GetStatusResistance())})

    local damage = self:GetSpecialValueFor("damage")
    damage = damage + (self:GetCaster():GetAgility() * (agility_damage / 100))

    ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})

    if target:HasModifier("modifier_van_takeitboy_debuff") then
        target:AddNewModifier(self:GetCaster(), self, "modifier_van_latexglove_debuff", {duration = duration * (1-target:GetStatusResistance())})
    end
end

function van_threehundredbucks:Effect(point)
    local direction = (point - self:GetCaster():GetAbsOrigin())
    direction = direction:Normalized()
    local particle_one = ParticleManager:CreateParticle( "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blink_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_one, 0, self:GetCaster():GetAbsOrigin() )
    ParticleManager:SetParticleControlForward( particle_one, 0, direction:Normalized() )
    ParticleManager:SetParticleControl( particle_one, 1, self:GetCaster():GetAbsOrigin() + direction )
    ParticleManager:ReleaseParticleIndex( particle_one )
end

function van_threehundredbucks:Effect2(point, target)
    local direction = (point - self:GetCaster():GetAbsOrigin())
    direction = direction:Normalized()
    local particle_two = ParticleManager:CreateParticle( "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blink_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_two, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControlForward( particle_two, 0, direction:Normalized() )
    ParticleManager:ReleaseParticleIndex( particle_two )
    local particleID= ParticleManager:CreateParticle("particles/van/attack_van.vpcf",PATTACH_POINT_FOLLOW,self:GetCaster())
    ParticleManager:SetParticleControl(particleID,0,self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particleID,1,target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particleID)
end

modifier_van_latexglove_rooted = class({})

function modifier_van_latexglove_rooted:CheckState()
    local state = 
    {
        [MODIFIER_STATE_ROOTED] = true,
    }
    return state
end

function modifier_van_latexglove_rooted:GetEffectName()
    return "particles/van/van_bind.vpcf"
end

function modifier_van_latexglove_rooted:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_van_latexglove_debuff = class({})

function modifier_van_latexglove_debuff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }
    return state
end

LinkLuaModifier( "modifier_van_leatherstuff", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_van_leatherstuff_buff", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )

van_leatherstuff = class({})

function van_leatherstuff:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_van_1")
end

function van_leatherstuff:GetManaCost(level)
    if self:GetCaster():HasModifier("modifier_van_leatherstuff") then
        return 0
    end
    return self.BaseClass.GetManaCost(self, level)
end

function van_leatherstuff:OnSpellStart()
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_van_leatherstuff") then
        self:GiveEffect()
        if self:GetCaster():HasTalent("special_bonus_birzha_van_8") then
            self:KnockBack()
        end
        self:UseResources(false, false, false, true)
        self:GetCaster():RemoveModifierByName("modifier_van_leatherstuff")
    else
        self:EndCooldown()
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_van_leatherstuff", {})
    end
end

function van_leatherstuff:KnockBack()

    local stun_duration = self:GetSpecialValueFor("stun_duration")

    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )

    for _,unit in pairs(units) do
        local distance = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
        local direction = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
        local bump_point = self:GetCaster():GetAbsOrigin() - direction * (distance + 250)
        local knockbackProperties =
        {
            center_x = bump_point.x,
            center_y = bump_point.y,
            center_z = bump_point.z,
            duration = stun_duration * (1-unit:GetStatusResistance()),
            knockback_duration = 0.25,
            knockback_distance = 200,
            knockback_height = 0,
            should_stun = true,
        }

        unit:RemoveModifierByName("modifier_knockback")

        local p = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_attack_normal_punch.vpcf", PATTACH_ABSORIGIN,self:GetCaster())
        ParticleManager:SetParticleControl(p, 0,self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(p, 2, unit:GetAbsOrigin())
        ParticleManager:SetParticleControlForward( p, 0, (unit:GetOrigin()-self:GetCaster():GetOrigin()):Normalized() )
        ParticleManager:SetParticleControlForward( p, 2, (unit:GetOrigin()-self:GetCaster():GetOrigin()):Normalized() )
        ParticleManager:SetParticleControlForward( p, 3, (unit:GetOrigin()-self:GetCaster():GetOrigin()):Normalized() )
        ParticleManager:SetParticleControlForward( p, 4, (unit:GetOrigin()-self:GetCaster():GetOrigin()):Normalized() )
        ParticleManager:ReleaseParticleIndex( p )

        unit:AddNewModifier( self:GetCaster(), self, "modifier_knockback", knockbackProperties )

        for i = 0, 23 do
            local current_ability = unit:GetAbilityByIndex(i)
            if current_ability and not current_ability:IsPassive() and not current_ability:IsAttributeBonus() and not current_ability:IsCooldownReady() then
                current_ability:StartCooldown( current_ability:GetCooldownTimeRemaining() + self:GetSpecialValueFor("cooldown_increased") )
            end
        end
    end

    local illusion_count = 1 + self:GetCaster():FindTalentValue("special_bonus_birzha_van_4")

    local illusions = BirzhaCreateIllusion( self:GetCaster(), self:GetCaster(), {duration=self:GetSpecialValueFor("illusion_duration"),outgoing_damage=self:GetSpecialValueFor("illusion_damage")-100,incoming_damage=75}, illusion_count, 200, false, false ) 

    for k, illusion in pairs(illusions) do
        illusion:AddNewModifier(self:GetCaster(), self, "modifier_phased", {duration = FrameTime()})
    end
end

function van_leatherstuff:GiveEffect()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_van_leatherstuff_buff", {duration = self:GetSpecialValueFor("effect_duration")})
end

modifier_van_leatherstuff = class({})

function modifier_van_leatherstuff:IsPurgable()
    return false
end

function modifier_van_leatherstuff:OnCreated()
    self.damage = self:GetAbility():GetSpecialValueFor("damage_resist")
    self.chance = self:GetAbility():GetSpecialValueFor("chance")
    if not IsServer() then return end
    self:GetCaster():EmitSound("VanLeatheron")
end

function modifier_van_leatherstuff:OnRefresh()
    self:OnCreated()
end

function modifier_van_leatherstuff:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():EmitSound("VanLeatheroff")
    local particle = ParticleManager:CreateParticle("particles/van/vanboommain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_van_leatherstuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }

    return funcs
end

function modifier_van_leatherstuff:GetStatusEffectName()
    return "particles/van/staff_status_effect.vpcf"
end

function modifier_van_leatherstuff:OnAttackLanded( params )
    if params.target ~= self:GetParent() then return end
    if RollPercentage(self.chance) then
        self:GetAbility():KnockBack()
        if self:GetCaster():HasTalent("special_bonus_birzha_van_8") then
            self:GetAbility():GiveEffect()
        end
        self:GetAbility():UseResources(false, false, false, true)
        self:Destroy()
    end
end

function modifier_van_leatherstuff:GetModifierIncomingDamage_Percentage()
    return self.damage
end

modifier_van_leatherstuff_buff = class({})

function modifier_van_leatherstuff_buff:IsPurgable()
    return false
end

function modifier_van_leatherstuff_buff:OnCreated()
    self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_van_leatherstuff_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_van_leatherstuff_buff:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed
end

function modifier_van_leatherstuff_buff:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_van_leatherstuff_buff:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end

function modifier_van_leatherstuff_buff:GetEffectName()
    return "particles/kanade_buff.vpcf"
end

function modifier_van_leatherstuff_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_birzha_orb_effect_lua", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_van_takeitboy_debuff", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )

van_takeitboy = class({})

function van_takeitboy:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_van_3")
end

function van_takeitboy:GetIntrinsicModifierName()
    return "modifier_birzha_orb_effect_lua"
end

function van_takeitboy:OnOrbFire( params )
    local duration = self:GetSpecialValueFor( "burn_duration" )
    local stun_duration = self:GetSpecialValueFor( "ministun_duration" )
    if params.target:IsBoss() then return end
    params.target:AddNewModifier( self:GetCaster(), self, "modifier_van_takeitboy_debuff", { duration = duration*(1-params.target:GetStatusResistance()) } )
    params.target:AddNewModifier( self:GetCaster(), self, "modifier_birzha_stunned_purge", { duration = stun_duration * (1-params.target:GetStatusResistance()) })
end

modifier_van_takeitboy_debuff = class({})

function modifier_van_takeitboy_debuff:OnCreated( kv )
    if not IsServer() then return end

    self:GetCaster():EmitSound("VanTakeitboy")
    self.damage = self:GetAbility():GetSpecialValueFor( "burn_damage" )
    self.damage_pct = self:GetAbility():GetSpecialValueFor( "burn_damage_pct" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_van_6")
    self.damageTable = 
    {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
    }
    self:StartIntervalThink( 1 )
    local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_loadout.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( effect_cast )              
    self:GetCaster():EmitSound("Item.PickUpGemWorld")
    if self:GetParent():IsHero() then
        local newItem = CreateItem( "item_bag_of_gold_van", nil, nil )
        local drop = CreateItemOnPositionForLaunch( self:GetCaster():GetAbsOrigin(), newItem )
        newItem:LaunchLootInitialHeight( false, 0, 500, 0.75, self:GetCaster():GetAbsOrigin() + RandomVector( 100 ) )
        Timers:CreateTimer(10, function() 
            if drop:IsNull() then
                return
            end
            UTIL_Remove( item )
            UTIL_Remove( drop )
        end)
    end
end

function modifier_van_takeitboy_debuff:OnRefresh( kv )
    if not IsServer() then return end
    self:OnCreated()
end

function modifier_van_takeitboy_debuff:OnIntervalThink()
    self.damageTable.damage = self.damage + ((self.damage_pct/100)*self:GetParent():GetMaxHealth())
    ApplyDamage( self.damageTable )
end

function modifier_van_takeitboy_debuff:GetEffectName()
    return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end

function modifier_van_takeitboy_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_van_ultimate_debuff", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_van_ultimate_buff", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_van_ultimate_stunned", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )

van_ultimate = class({})

function van_ultimate:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_van_7")
end

function van_ultimate:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function van_ultimate:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local abs = target:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("damage_radius")
    local duration = self:GetSpecialValueFor("duration")
    local buff_duration = self:GetSpecialValueFor("movement_speed_duration")
    local damage = self:GetSpecialValueFor("damage")

    if target:TriggerSpellAbsorb( self ) then
        return
    end

    target:AddNewModifier(self:GetCaster(), self, "modifier_van_ultimate_stunned", {duration = duration * (1-target:GetStatusResistance())})

    local particle = ParticleManager:CreateParticle("particles/van/van_ultimate.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_head", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(particle, 1, abs)
    ParticleManager:SetParticleControl(particle, 50, Vector(RandomInt(1, 256),RandomInt(1, 256),RandomInt(1, 256)))

    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_van_ultimate_buff", {duration = buff_duration} )

    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), abs, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )

    self:GetCaster():EmitSound("VanSpit")

    for _,unit in pairs(units) do
        ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        if unit ~= target then
            local distance = (unit:GetAbsOrigin() - abs):Length2D()
            local direction = (unit:GetAbsOrigin() - abs):Normalized()
            local bump_point = abs - direction * (distance + 250)
            local knockbackProperties =
            {
                center_x = bump_point.x,
                center_y = bump_point.y,
                center_z = bump_point.z,
                duration = self:GetSpecialValueFor("push_duration"),
                knockback_duration = self:GetSpecialValueFor("push_duration"),
                knockback_distance = 250,
                knockback_height = 0
            }
            unit:RemoveModifierByName("modifier_knockback")
            unit:RemoveModifierByName("modifier_van_ultimate_stunned")
            unit:AddNewModifier( self:GetCaster(), self, "modifier_van_ultimate_stunned", {duration = (1+FrameTime()) * (1 - unit:GetStatusResistance())} )
            unit:AddNewModifier( self:GetCaster(), self, "modifier_knockback", knockbackProperties )
        end
    end
end

modifier_van_ultimate_stunned = class({})

function modifier_van_ultimate_stunned:IsHidden()
    return true
end

function modifier_van_ultimate_stunned:OnDestroy()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("slow_duration")
    self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_van_ultimate_debuff", {duration = duration} )
end

function modifier_van_ultimate_stunned:IsStunDebuff()
    return true
end

function modifier_van_ultimate_stunned:IsPurgable()
    return false
end

function modifier_van_ultimate_stunned:IsPurgeException()
    return true
end

function modifier_van_ultimate_stunned:CheckState()
    local state = 
    {
        [MODIFIER_STATE_STUNNED] = true,
    }
    return state
end

function modifier_van_ultimate_stunned:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_van_ultimate_stunned:GetOverrideAnimation( params )
    return ACT_DOTA_DISABLED
end

modifier_van_ultimate_debuff = class({})

function modifier_van_ultimate_debuff:IsPurgeException()
    return true
end

function modifier_van_ultimate_debuff:OnCreated()
    self.damage = self:GetAbility():GetSpecialValueFor("slow_damage")
    self.movespeed = self:GetAbility():GetSpecialValueFor("slow_movement_speed_pct")
    self.attackspeed = self:GetAbility():GetSpecialValueFor("slow_attack_speed_pct")
end

function modifier_van_ultimate_debuff:OnRefresh()
    self:OnCreated()
end

function modifier_van_ultimate_debuff:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return decFuncs
end


function modifier_van_ultimate_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end

function modifier_van_ultimate_debuff:GetModifierAttackSpeedBonus_Constant()
    return self.attackspeed
end

function modifier_van_ultimate_debuff:GetModifierDamageOutgoing_Percentage()
    return self.damage
end

function modifier_van_ultimate_debuff:GetEffectName()
    return "particles/van/van_ultimate_overhead.vpcf"
end

function modifier_van_ultimate_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_van_ultimate_buff = class({})

function modifier_van_ultimate_buff:IsPurgeException()
    return true
end

function modifier_van_ultimate_buff:OnCreated()
    self.movespeed = self:GetAbility():GetSpecialValueFor("movement_speed")
end

function modifier_van_ultimate_buff:OnRefresh()
    self:OnCreated()
end

function modifier_van_ultimate_buff:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return decFuncs
end

function modifier_van_ultimate_buff:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end

LinkLuaModifier( "modifier_van_swallowmycum_passive", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_van_swallowmycum_damage", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_van_swallowmycum_debuff", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_van_swallowmycum_agility", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_van_swallowmycum_illusion", "abilities/heroes/van.lua", LUA_MODIFIER_MOTION_NONE )

van_swallowmycum = class({})

function van_swallowmycum:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function van_swallowmycum:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function van_swallowmycum:GetCastRange(location, target)
    return self:GetCaster():Script_GetAttackRange()+50
end

function van_swallowmycum:OnAbilityPhaseStart()
    local stack = self:GetCaster():GetModifierStackCount("modifier_van_swallowmycum_passive", self:GetCaster()) 
    if stack <= 0 then
        DisplayError(self:GetCaster():GetPlayerOwnerID(), "#dota_hud_error_van_swallowmycum")
        return false
    end
    return true
end

function van_swallowmycum:GetAbilityTextureName()
    local stack = self:GetCaster():GetModifierStackCount("modifier_van_swallowmycum_passive", self:GetCaster()) + 1
    return "Van/cum"..stack
end

function van_swallowmycum:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function van_swallowmycum:GetManaCost(level)
    return self:GetCaster():GetMaxMana()*0.15
end

function van_swallowmycum:GetIntrinsicModifierName()
    return "modifier_van_swallowmycum_passive"
end

function van_swallowmycum:OnSpellStart()
    if not IsServer() then return end

    local modifier_stack = self:GetCaster():FindModifierByName("modifier_van_swallowmycum_passive")

    local modifier_damage = self:GetCaster():FindModifierByName("modifier_van_swallowmycum_damage")

    local target = self:GetCursorTarget()

    self:GetCaster():EmitSound("van_cum")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_demonic_purge_finale.vpcf", PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())

    if modifier_stack then
        local percent_agility = modifier_stack:GetStackCount() * 150
        local percent_heal = 30 + (modifier_stack:GetStackCount() * 20)
        local damage = (percent_agility / 100) * self:GetCaster():GetAgility()
        ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self })
        local heal = modifier_damage:GetStackCount() / 100 * percent_heal
        self:GetCaster():Heal(heal, self)
        modifier_stack:SetStackCount(0)
        modifier_damage:SetStackCount(0)
    end
end

modifier_van_swallowmycum_passive = class({})

function modifier_van_swallowmycum_passive:IsHidden() return self:GetStackCount() == 0 end
function modifier_van_swallowmycum_passive:IsPurgable() return false end
function modifier_van_swallowmycum_passive:IsPurgeException() return false end

function modifier_van_swallowmycum_passive:OnCreated()
    if not IsServer() then return end
    self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_van_swallowmycum_damage", {})
    self.modifier = self:GetCaster():FindModifierByName("modifier_van_swallowmycum_damage")
end

function modifier_van_swallowmycum_passive:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_van_swallowmycum_passive:OnTakeDamage(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.unit:IsWard() then return end

    local one_stack = 300 + self:GetCaster():GetLevel() * 20
    local two_stack = 500 + self:GetCaster():GetLevel() * 40
    local three_stack = 700 + self:GetCaster():GetLevel() * 60

    if self.modifier then
        self.damage = self.modifier:GetStackCount()
    end

    self:StartIntervalThink(5)

    if self.damage < three_stack then
        self.modifier:SetStackCount(self.damage + params.damage)
    end

    if self.modifier:GetStackCount() > three_stack then
        self.modifier:SetStackCount(three_stack)
    end

    if self:GetStackCount() == 0 and self.damage >= one_stack then
        self:SetStackCount(1)
    elseif self:GetStackCount() == 1 and self.damage >= two_stack then
        self:SetStackCount(2)
    elseif self:GetStackCount() == 2 and self.damage >= three_stack then
        self:SetStackCount(3)
    end
end

function modifier_van_swallowmycum_passive:OnDeath( params )
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        self:SetStackCount(0)
        self.modifier:SetStackCount(0)
    end
end

function modifier_van_swallowmycum_passive:OnIntervalThink()
    if IsServer() then
        self:SetStackCount(0)
        self.modifier:SetStackCount(0)
    end
end

modifier_van_swallowmycum_damage = class({})

function modifier_van_swallowmycum_damage:IsHidden() return self:GetStackCount() == 0 end
function modifier_van_swallowmycum_damage:RemoveOnDeath() return false end
function modifier_van_swallowmycum_damage:IsPurgable() return false end
function modifier_van_swallowmycum_damage:IsPurgeException() return false end

function modifier_van_swallowmycum_damage:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(0)
end

function modifier_van_swallowmycum_damage:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_van_swallowmycum_damage:OnTooltip()
    return self:GetStackCount()
end