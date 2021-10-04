LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

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
    local target = self:GetCursorTarget()
    if not IsServer() then return end
    local info = {
        EffectName = "particles/ethereal/ethereal_blade.vpcf",
        Ability = self,
        iMoveSpeed = 750,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
    }
    ProjectileManager:CreateTrackingProjectile( info )
    self:GetCaster():EmitSound("Hero_Puck.EtherealJaunt")
end

function Pocik_VerySmall:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:TriggerSpellAbsorb( self ) ) then
        local gold_to_damage_ratio = self:GetSpecialValueFor("gold_to_damage_ratio")
        local gold_damage = math.floor(target:GetGold() * gold_to_damage_ratio * 0.01)
        gold_damage = gold_damage + self:GetSpecialValueFor("base_damage")
        ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = gold_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self}) 
        target:EmitSound("pocikxyli")
        target:EmitSound("DOTA_Item.Hand_Of_Midas")
    end
    return true
end

LinkLuaModifier("modifier_pocik_bash", "abilities/heroes/boy.lua", LUA_MODIFIER_MOTION_NONE)

Pocik_pizda = class({})

function Pocik_pizda:GetCooldown(level)
    if self:GetCaster():HasTalent("special_bonus_birzha_boy_4") then
        return 0
    end
    return self.BaseClass.GetCooldown(self, level)
end

function Pocik_pizda:GetIntrinsicModifierName()
    return "modifier_pocik_bash"
end

modifier_pocik_bash = class({})

function modifier_pocik_bash:IsPurgable() return false end
function modifier_pocik_bash:IsHidden() return true end

function modifier_pocik_bash:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_pocik_bash:OnAttackLanded(params)
    if params.attacker == self:GetParent() then
		if params.attacker:GetTeam() == params.target:GetTeam() then
			return
		end 
        if self:GetParent():PassivesDisabled() then return end
        if not self:GetCaster():HasTalent("special_bonus_birzha_boy_3") then
            if self:GetParent():IsIllusion() then return end
        end
        if params.target:IsOther() then
            return nil
        end
        local chance = self:GetAbility():GetSpecialValueFor("chance")
        local damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
        local duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_boy_1")
        if chance >= RandomInt(1, 100) then
            if self:GetAbility():IsFullyCastable() then
                self:GetParent():EmitSound("pocikpizdaa")
                local crit_pfx = ParticleManager:CreateParticle("particles/econ/items/troll_warlord/troll_warlord_ti7_axe/troll_ti7_axe_bash_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
                ParticleManager:SetParticleControl(crit_pfx, 0, params.target:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(crit_pfx)
                if not self:GetCaster():HasTalent("special_bonus_birzha_boy_4") then
                    self:GetAbility():UseResources(false, false, true)
                end
                params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_bashed", {duration = duration})
                ApplyDamage({victim = params.target, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self:GetAbility()})
            end
        end 
    end
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
                    if modifier:GetCaster() == self:GetCaster() then
                        modifier:Destroy()
                    end
                end
            end
        end
        for _, modifier in pairs( caster:FindAllModifiersByName("modifier_ThisMyPoint_buff") ) do
            modifier:Destroy()
        end
        return
    end

    if target:TriggerSpellAbsorb(self) then return end
    EmitSoundOn("pociktochka", caster)
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

    EmitSoundOn("Ability.XMarksTheSpot.Target", caster)
    EmitSoundOn("Ability.XMark.Target_Movement", parent)
    self:StartIntervalThink(0.25)
    self.x_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_x_spot.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControlEnt(self.x_pfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.x_pfx, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
end

function modifier_ThisMyPoint_debuff:OnIntervalThink()
    if not IsServer() then return end
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
    EmitSoundOn("Ability.XMarksTheSpot.Return", parent)
    ParticleManager:DestroyParticle(self.x_pfx, false)
    ParticleManager:ReleaseParticleIndex(self.x_pfx)
    self:GetAbility():UseResources(false, false, true)
    if not ( parent:IsInvulnerable() ) then
        local stopOrder =
        {
            UnitIndex = parent:entindex(),
            OrderType = DOTA_UNIT_ORDER_STOP
        }
        ExecuteOrderFromTable( stopOrder )

        FindClearSpaceForUnit(parent, self.position, true)
        ability.positions[self.position_id] = nil
        if self:GetCaster():HasTalent("special_bonus_birzha_boy_2") then
            if not parent:IsMagicImmune() then
                parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_boy_2")})
            end
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
    local duration = self:GetSpecialValueFor('duration')
    local radius = self:GetSpecialValueFor( "radius" )
    caster:EmitSound("pocikpenek")
    GridNav:DestroyTreesAroundPoint(point, radius, false)
    self.penek = CreateUnitByName("npc_penek_"..self:GetLevel(), point, true, caster, nil, caster:GetTeamNumber())
    self.penek:SetOwner(caster)
    FindClearSpaceForUnit(self.penek, self.penek:GetAbsOrigin(), true)
    self.penek:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
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

    Timers:CreateTimer(duration, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
end

function modifier_Pocik_penek_passive:OnIntervalThink()
    local radius = self:GetAbility():GetSpecialValueFor( "radius" ) 
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    self:SpawnEffect()
    for i,unit in ipairs(units) do
        local radius = self:GetAbility():GetSpecialValueFor( "radius" )
        local heal_pct = self:GetAbility():GetSpecialValueFor( "pct_heal" )
        local heal = unit:GetMaxHealth() / 100 * heal_pct
        local damage_pct = self:GetAbility():GetSpecialValueFor( "pct_damage" )
        local target_health_percentage = unit:GetMaxHealth() / 100
        local damage_percentage = target_health_percentage * damage_pct
        local base_damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
        local total_damage = damage_percentage + base_damage
        local caster_team = self:GetCaster():GetTeamNumber()
        if unit:IsAncient() then return end
        if unit:GetTeamNumber() ~= caster_team then
            ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = total_damage, ability = self:GetParent(), damage_type = self:GetAbility():GetAbilityDamageType() })
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
    EmitSoundOn("Hero_Pugna.NetherBlast", self:GetParent())
end

function modifier_Pocik_penek_passive:CheckState()
    local state = { [MODIFIER_STATE_STUNNED] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
[MODIFIER_STATE_ATTACK_IMMUNE] = true,
[MODIFIER_STATE_SILENCED] = true,
[MODIFIER_STATE_MUTED] = true,
[MODIFIER_STATE_ROOTED] = true,
[MODIFIER_STATE_DISARMED] = true,
[MODIFIER_STATE_UNSELECTABLE] = true,
[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
[MODIFIER_STATE_NO_HEALTH_BAR] = true,
[MODIFIER_STATE_INVULNERABLE] = true,}
    return state
end

function modifier_Pocik_penek_passive:IsAura() return true end

function modifier_Pocik_penek_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_Pocik_penek_passive:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_Pocik_penek_passive:GetModifierAura()
    return "modifier_Pocik_penek_passive_aura"
end

function modifier_Pocik_penek_passive:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
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
    self:StartIntervalThink(0.1)
end

function modifier_Pocik_penek_passive_aura:OnIntervalThink()
    if self:GetParent():IsAncient() then return end
    local unit_location = self:GetParent():GetAbsOrigin()
    local vector_distance = self:GetAuraOwner():GetAbsOrigin() - unit_location
    local distance = (vector_distance):Length2D()
    local direction = (vector_distance):Normalized()
    if distance >= 50 then
        self:GetParent():SetAbsOrigin(unit_location + direction * 6)
    else
        self:GetParent():SetAbsOrigin(unit_location)
    end
end

function modifier_Pocik_penek_passive_aura:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,}
    return state
end