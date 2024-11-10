LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_Pocik_VerySmall_buff", "abilities/heroes/boy.lua", LUA_MODIFIER_MOTION_NONE )

Pocik_VerySmall = class({})

function Pocik_VerySmall:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Pocik_VerySmall:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Pocik_VerySmall:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Pocik_VerySmall:OnSpellStart()
    if not IsServer() then return end

    local target = self:GetCursorTarget()

    local info = 
    {
        EffectName = "particles/ethereal/ethereal_blade.vpcf",
        Ability = self,
        iMoveSpeed = 750,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
        ExtraData = { scepter = false }
    }

    ProjectileManager:CreateTrackingProjectile( info )

    self:GetCaster():EmitSound("Hero_Puck.EtherealJaunt")
end

function Pocik_VerySmall:OnProjectileHit_ExtraData(target, vLocation, table)
    if not IsServer() then return end

    if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:TriggerSpellAbsorb( self ) ) then
        local gold_to_damage_ratio = self:GetSpecialValueFor("gold_to_damage_ratio")
        local gold_damage = 0
        if target:IsRealHero() then
            gold_damage = math.floor(target:GetGold() * gold_to_damage_ratio * 0.01)
        end
        if self:GetCaster():HasTalent("special_bonus_birzha_pocik_3") and target:IsRealHero() then
            local bonus_damage = math.floor(target:GetGold() * self:GetCaster():FindTalentValue("special_bonus_birzha_pocik_3") * 0.01)
            local modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Pocik_VerySmall_buff", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_pocik_3", "value2"), bonus_damage = bonus_damage})
        end
        gold_damage = math.min(gold_damage, 1000)
        if table.scepter == 1 or table.scepter == true then
            gold_damage = math.min(gold_damage, 250)
        end
        gold_damage = gold_damage + self:GetSpecialValueFor("base_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_pocik_6")
        ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = gold_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self}) 
        target:EmitSound("pocikxyli")
        target:EmitSound("DOTA_Item.Hand_Of_Midas")
    end

    return true
end

modifier_Pocik_VerySmall_buff = class({})

function modifier_Pocik_VerySmall_buff:OnCreated(params)
    if not IsServer() then return end
    self.bonus_damage = params.bonus_damage
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(FrameTime())
end

function modifier_Pocik_VerySmall_buff:AddCustomTransmitterData()
    return 
    {
        bonus_damage = self.bonus_damage,
    }
end

function modifier_Pocik_VerySmall_buff:HandleCustomTransmitterData( data )
    self.bonus_damage = data.bonus_damage
end


function modifier_Pocik_VerySmall_buff:OnIntervalThink()
    if not IsServer() then return end
    self:SendBuffRefreshToClients()

end

function modifier_Pocik_VerySmall_buff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
end

function modifier_Pocik_VerySmall_buff:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

LinkLuaModifier("modifier_pocik_bash", "abilities/heroes/boy.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pocik_bash_buff", "abilities/heroes/boy.lua", LUA_MODIFIER_MOTION_NONE)

Pocik_pizda = class({})

function Pocik_pizda:GetCooldown(level)
    return (self.BaseClass.GetCooldown(self, level) + self:GetCaster():FindTalentValue("special_bonus_birzha_pocik_7")) / ( self:GetCaster():GetCooldownReduction())
end

function Pocik_pizda:GetIntrinsicModifierName()
    return "modifier_pocik_bash"
end

modifier_pocik_bash = class({})

function modifier_pocik_bash:IsPurgable() return false end
function modifier_pocik_bash:IsHidden() return true end

function modifier_pocik_bash:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }

    return funcs
end

function modifier_pocik_bash:GetModifierProcAttack_BonusDamage_Physical(params)
    if not IsServer() then return end
    if self:GetParent():PassivesDisabled() then return end
    if self:GetParent():IsIllusion() then return end
    if not self:GetAbility():IsFullyCastable() then return end
    if params.target:IsWard() then return end
    if params.no_attack_cooldown then return end

    local damage = self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_pocik_1")
    local duration = self:GetAbility():GetSpecialValueFor("duration")

    self:GetParent():EmitSound("pocikpizdaa")

    local crit_pfx = ParticleManager:CreateParticle("particles/econ/items/troll_warlord/troll_warlord_ti7_axe/troll_ti7_axe_bash_explosion.vpcf", PATTACH_OVERHEAD_FOLLOW, params.target)
    ParticleManager:SetParticleControl(crit_pfx, 0, params.target:GetAbsOrigin())
    ParticleManager:SetParticleControl( crit_pfx, 1, params.target:GetOrigin() )
    ParticleManager:ReleaseParticleIndex(crit_pfx)

    self:GetAbility():UseResources(false, false, false, true)

    if self:GetParent():HasModifier("modifier_bp_dangerous_boy") then
        local crit_pfx_item = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_jump_stomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
        ParticleManager:SetParticleControl(crit_pfx_item, 0, params.target:GetAbsOrigin())
        ParticleManager:SetParticleControl( crit_pfx_item, 1, self:GetParent():GetOrigin() )
        ParticleManager:ReleaseParticleIndex(crit_pfx_item)
    end

    if self:GetCaster():HasTalent("special_bonus_birzha_pocik_4") then
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pocik_bash_buff", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_pocik_4", "value2")})
    end

    params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_bashed", {duration = duration})

    if self:GetCaster():HasScepter() then
        local ability = self:GetCaster():FindAbilityByName("Pocik_VerySmall")
        if ability and ability:GetLevel() > 0 then
            local info = 
            {
                EffectName = "particles/ethereal/ethereal_blade.vpcf",
                Ability = ability,
                iMoveSpeed = 750,
                Source = self:GetCaster(),
                Target = params.target,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
                ExtraData = { scepter = true }
            }
            ProjectileManager:CreateTrackingProjectile( info )
            self:GetCaster():EmitSound("Hero_Puck.EtherealJaunt")
        end
    end

    return damage
end

modifier_pocik_bash_buff = class({})
function modifier_pocik_bash_buff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end
function modifier_pocik_bash_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_pocik_4")
end
function modifier_pocik_bash_buff:GetEffectName()
    return "particles/dangerous_boy_speed_buff.vpcf"
end

LinkLuaModifier("modifier_ThisMyPoint_debuff", "abilities/heroes/boy.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ThisMyPoint_buff", "abilities/heroes/boy.lua", LUA_MODIFIER_MOTION_NONE)

Pocik_ThisMyPoint = class({})

function Pocik_ThisMyPoint:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function Pocik_ThisMyPoint:GetManaCost(level)
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_ThisMyPoint_buff") then
        return 0
    end
    return self.BaseClass.GetManaCost(self, level)
end

function Pocik_ThisMyPoint:GetBehavior()
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_ThisMyPoint_buff") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function Pocik_ThisMyPoint:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Pocik_ThisMyPoint:OnUpgrade()
    self.positions = self.positions or {}
end

function Pocik_ThisMyPoint:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")

    if caster:HasModifier("modifier_ThisMyPoint_buff") then
        local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
        for _,target in pairs(targets) do
            if target:HasModifier("modifier_ThisMyPoint_debuff") then
                local modifiers = target:FindAllModifiersByName("modifier_ThisMyPoint_debuff")
                for _, modifier in pairs( modifiers ) do
                    if modifier:GetCaster() == self:GetCaster() and not modifier:IsNull() then
                        modifier:Destroy()
                    end
                end
            end
        end
        for _, modifier in pairs( caster:FindAllModifiersByName("modifier_ThisMyPoint_buff") ) do
            if not modifier:IsNull() then
                modifier:Destroy()
            end
        end
        return
    end

    if target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
        if target:TriggerSpellAbsorb(self) then return end
    else
        duration = duration * 2
    end
    
    caster:EmitSound("pociktochka")
    caster:AddNewModifier(caster, self, "modifier_ThisMyPoint_buff", {duration = duration})
    target:AddNewModifier(caster, self, "modifier_ThisMyPoint_debuff", {duration = duration})
    self:EndCooldown()
end

modifier_ThisMyPoint_debuff = class({})

function modifier_ThisMyPoint_debuff:IsPurgable()
    return false
end

function modifier_ThisMyPoint_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_ThisMyPoint_debuff:OnCreated( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    self.position = parent:GetAbsOrigin()
    self.position_id = params.position_id or 0

    if self.position_id == 0 then
        table.insert(ability.positions , self.position)
        self.position_id = #ability.positions
    end

    caster:EmitSound("Ability.XMarksTheSpot.Target")
    parent:EmitSound("Ability.XMark.Target_Movement")

    self:StartIntervalThink(0.25)
    self.x_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_x_spot.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControlEnt(self.x_pfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.x_pfx, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    self:AddParticle(self.x_pfx, false, false, -1, false, false)
end

function modifier_ThisMyPoint_debuff:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then return end
    local movement_damage_pct = self:GetAbility():GetSpecialValueFor("damage") / 100 
    local damage = 0
    
    if self:GetParent().position == nil then
        self:GetParent().position = self:GetParent():GetAbsOrigin()
    end

    local vector_distance = self:GetParent().position - self:GetParent():GetAbsOrigin()
    local distance = (vector_distance):Length2D()
    if distance <= 1500 and distance > 0 then
        damage = distance * movement_damage_pct
    end
    self:GetParent().position = self:GetParent():GetAbsOrigin()
    if damage ~= 0 then
        ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType()})
    end
end

function modifier_ThisMyPoint_debuff:OnDestroy( params )
    if not IsServer() then return end
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local position = self.position
    self:GetParent().position = nil
    parent:StopSound("Ability.XMark.Target_Movement")
    parent:EmitSound("Ability.XMarksTheSpot.Return")

    self:GetAbility():UseResources(false, false, false, true)
    if not ( parent:IsInvulnerable() ) then
        local stopOrder =
        {
            UnitIndex = parent:entindex(),
            OrderType = DOTA_UNIT_ORDER_STOP
        }
        ExecuteOrderFromTable( stopOrder )

        FindClearSpaceForUnit(parent, self.position, true)
        ability.positions[self.position_id] = nil
    end

    if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then return end

    if self:GetCaster():HasTalent("special_bonus_birzha_pocik_2") then
        if not parent:IsMagicImmune() then
            parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_pocik_2") * (1 - parent:GetStatusResistance()) })
        end
    end
end

modifier_ThisMyPoint_buff = class({})

function modifier_ThisMyPoint_buff:IsHidden()
    return true
end

function modifier_ThisMyPoint_buff:IsPurgable()
    return false
end

function modifier_ThisMyPoint_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier( "modifier_Pocik_penek_passive", "abilities/heroes/boy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Pocik_penek_passive_aura", "abilities/heroes/boy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Pocik_penek_passive_shard", "abilities/heroes/boy.lua", LUA_MODIFIER_MOTION_NONE )

Pocik_penek = class({})

function Pocik_penek:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Pocik_penek:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Pocik_penek:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Pocik_penek:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Pocik_penek:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector()
    end
    local duration = self:GetSpecialValueFor('duration')
    local radius = self:GetSpecialValueFor( "radius" )
    caster:EmitSound("pocikpenek")
    GridNav:DestroyTreesAroundPoint(point, radius, false)
    self.penek = CreateUnitByName("npc_penek_"..self:GetLevel(), point, true, caster, nil, caster:GetTeamNumber())
    self.penek:SetOwner(caster)
    self.penek.shard_list = {}
    FindClearSpaceForUnit(self.penek, self.penek:GetAbsOrigin(), true)
    self.penek:AddNewModifier(self:GetCaster(), self, "modifier_Pocik_penek_passive", {duration = duration})
end

modifier_Pocik_penek_passive = class({})

function modifier_Pocik_penek_passive:IsHidden()
    return true
end

function modifier_Pocik_penek_passive:IsPurgable()
    return false
end

function modifier_Pocik_penek_passive:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
    local duration = self:GetAbility():GetSpecialValueFor('duration')
    local radius = self:GetAbility():GetSpecialValueFor( "radius" )
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_eyesintheforest.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_Pocik_penek_passive:OnIntervalThink()
    local radius = self:GetAbility():GetSpecialValueFor( "radius" ) 
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    self:SpawnEffect()

    for i,unit in ipairs(units) do
        local radius = self:GetAbility():GetSpecialValueFor( "radius" )
        local heal_pct = self:GetAbility():GetSpecialValueFor( "pct_heal" )
        local heal = unit:GetMaxHealth() / 100 * heal_pct
        local damage_pct = self:GetCaster():FindTalentValue("special_bonus_birzha_pocik_5")
        local target_health_percentage = unit:GetMaxHealth() / 100
        local damage_percentage = target_health_percentage * damage_pct
        local base_damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
        local total_damage = damage_percentage + base_damage
        local caster_team = self:GetCaster():GetTeamNumber()

        local end_damage = base_damage

        if self:GetCaster():HasTalent("special_bonus_birzha_pocik_5") then
            end_damage = total_damage
        end

        print(end_damage)

        if unit:GetTeamNumber() ~= caster_team then
            if not unit:IsBoss() then
                ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = end_damage, ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType() })
            end
        else
            unit:Heal(heal, self:GetAbility())
        end
    end
end

function modifier_Pocik_penek_passive:SpawnEffect()
    local radius = self:GetAbility():GetSpecialValueFor( "radius" )
    local particle_pre_blast_fx = ParticleManager:CreateParticle("particles/pocik/penek_effect.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(particle_pre_blast_fx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_pre_blast_fx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 0.25, 1))
    ParticleManager:ReleaseParticleIndex(particle_pre_blast_fx)
    local particle_blast_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_netherblast.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle_blast_fx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_blast_fx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 0, 0))
    ParticleManager:ReleaseParticleIndex(particle_blast_fx)
    self:GetParent():EmitSound("Hero_Pugna.NetherBlast")
end

function modifier_Pocik_penek_passive:CheckState()
    local state = 
    { 
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true
    }
    return state
end

function modifier_Pocik_penek_passive:IsAura() return true end

function modifier_Pocik_penek_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_Pocik_penek_passive:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_Pocik_penek_passive:GetModifierAura()
    return "modifier_Pocik_penek_passive_aura"
end

function modifier_Pocik_penek_passive:GetAuraDuration() return 0 end

function modifier_Pocik_penek_passive:GetAuraRadius()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

function modifier_Pocik_penek_passive:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())
end

modifier_Pocik_penek_passive_aura = class({})

function modifier_Pocik_penek_passive_aura:IsHidden()
    return true
end

function modifier_Pocik_penek_passive_aura:IsPurgable()
    return false
end

function modifier_Pocik_penek_passive_aura:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
    local modifier_kill = self:GetAuraOwner():FindModifierByName("modifier_Pocik_penek_passive")
    if modifier_kill then
        if self:GetCaster():HasShard() then
            if self:GetAuraOwner().shard_list ~= nil and self:GetAuraOwner().shard_list[self:GetParent():entindex()] == nil then
                self:GetAuraOwner().shard_list[self:GetParent():entindex()] = true
                local modifier = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Pocik_penek_passive_shard", {duration = modifier_kill:GetRemainingTime(), unit = self:GetAuraOwner():entindex()})
            end
        end
    end
end

modifier_Pocik_penek_passive_shard = class({})

function modifier_Pocik_penek_passive_shard:IsHidden() return true end
function modifier_Pocik_penek_passive_shard:IsPurgable() return false end

function modifier_Pocik_penek_passive_shard:OnCreated(params)
    if not IsServer() then return end
    self.center = EntIndexToHScript(params.unit):GetAbsOrigin()
    self.current_pos = self:GetParent():GetAbsOrigin()
    self:PlayEffects()
    self:StartIntervalThink(FrameTime())
end

function modifier_Pocik_penek_passive_shard:OnIntervalThink()
    if not IsServer() then return end

    if self:GetParent():IsMagicImmune() then
        self:Destroy()
        return
    end

    if (self.current_pos-self.center):Length2D() > self:GetAbility():GetSpecialValueFor("radius") then
        self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", { duration = self:GetAbility():GetSpecialValueFor("shard_stun_duration") * ( 1 - self:GetParent():GetStatusResistance()) } )
        self:Destroy()
        return
    end

    self.current_pos = self:GetParent():GetAbsOrigin()
end

function modifier_Pocik_penek_passive_shard:PlayEffects()
    local effect_cast = ParticleManager:CreateParticle( "particles/pocik_tether.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 0, self.center )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
    self:AddParticle( effect_cast, false, false, -1, false, false )
end

function modifier_Pocik_penek_passive_aura:OnDestroy()
    if not IsServer() then return end
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
end

function modifier_Pocik_penek_passive_aura:OnIntervalThink()
    if self:GetParent():IsBoss() then return end
    if self:GetAuraOwner() == nil then return end
    local unit_location = self:GetParent():GetAbsOrigin()
    local vector_distance = self:GetAuraOwner():GetAbsOrigin() - unit_location
    local distance = (vector_distance):Length2D()
    local direction = (vector_distance):Normalized()

    local pull = 8

    if distance >= 150 then
        self:GetParent():SetAbsOrigin(unit_location + direction * pull)
    else
        self:GetParent():SetAbsOrigin(unit_location)
    end
end

function modifier_Pocik_penek_passive_aura:CheckState()
    local state = 
    { 
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return state
end

LinkLuaModifier( "modifier_Pocik_uebu", "abilities/heroes/boy.lua", LUA_MODIFIER_MOTION_NONE )

Pocik_uebu = class({})

function Pocik_uebu:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Pocik_uebu:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Pocik_uebu:OnInventoryContentsChanged()
    if self:GetCaster():HasTalent("special_bonus_birzha_pocik_8") then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function Pocik_uebu:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end

function Pocik_uebu:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    caster:EmitSound("Hero_MonkeyKing.Strike.Cast")
    self.pre_particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControl(self.pre_particleID, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(self.pre_particleID, 1, caster, PATTACH_POINT_FOLLOW, "attach_weapon_bot", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.pre_particleID, 2, caster, PATTACH_POINT_FOLLOW, "attach_weapon_top", caster:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(self.pre_particleID)
    return true
end

function Pocik_uebu:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    if self.pre_particleID ~= nil then
        ParticleManager:DestroyParticle(self.pre_particleID, true)
        self.pre_particleID = nil
    end
    return true
end

function Pocik_uebu:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():EmitSound("pocik_uebu")

    local point = self:GetCursorPosition()

    if point == self:GetCaster():GetAbsOrigin() then 
        point = point + self:GetCaster():GetForwardVector()*6
    end

    if self.pre_particleID ~= nil then
        ParticleManager:DestroyParticle(self.pre_particleID, false)
        self.pre_particleID = nil
    end

    self:Strike(self:GetCaster():GetAbsOrigin(), point, self:GetCaster())
end

function Pocik_uebu:Strike(start_point, end_point, caster)
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local strike_radius = self:GetSpecialValueFor("strike_radius")
    local strike_cast_range = self:GetSpecialValueFor("strike_cast_range")
    local stun = self:GetSpecialValueFor('stun')
    local vStartPosition = start_point
    local vTargetPosition = end_point
    local vDirection = vTargetPosition - vStartPosition
    vDirection.z = 0
    vStartPosition = GetGroundPosition(vStartPosition+vDirection:Normalized()*(strike_radius/2), caster)
    vTargetPosition = GetGroundPosition(vStartPosition+vDirection:Normalized()*(strike_cast_range-strike_radius/2), caster)
    EmitSoundOnLocationWithCaster(vStartPosition, "Hero_MonkeyKing.Strike.Impact", caster)
    EmitSoundOnLocationWithCaster(vTargetPosition, "Hero_MonkeyKing.Strike.Impact.EndPos", caster)
    local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particleID, 0, vStartPosition)
    ParticleManager:SetParticleControlForward(particleID, 0, vDirection:Normalized())
    ParticleManager:SetParticleControl(particleID, 1, vTargetPosition)
    ParticleManager:ReleaseParticleIndex(particleID)

    local crit_mod = caster:AddNewModifier(caster, self, "modifier_Pocik_uebu", {})

    local enemies = FindUnitsInLine(self:GetCaster():GetTeamNumber(), vStartPosition , vTargetPosition, nil, strike_radius,  DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE)

    for _,enemy in pairs(enemies) do
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike_slow_impact.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControlEnt(particleID, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(particleID)

        enemy:AddNewModifier(caster, self, "modifier_birzha_stunned", {duration = stun * (1 - enemy:GetStatusResistance())})
        caster:PerformAttack(enemy, true, true, true, true, true, false, true)
    end

    if crit_mod then 
        crit_mod:Destroy()
    end
end

modifier_Pocik_uebu = class({})

function modifier_Pocik_uebu:DeclareFunctions() 
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
    } 
end

function modifier_Pocik_uebu:GetModifierPreAttack_CriticalStrike()
    return self:GetAbility():GetSpecialValueFor("strike_crit_mult")
end

function modifier_Pocik_uebu:IsHidden()
    return true
end
