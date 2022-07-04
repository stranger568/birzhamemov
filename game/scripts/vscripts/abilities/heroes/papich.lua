LinkLuaModifier( "modifier_hellfire_blast_slow", "abilities/heroes/papich.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Papich_HellFire_Blast = class({})

function Papich_HellFire_Blast:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Papich_HellFire_Blast:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Papich_HellFire_Blast:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Papich_HellFire_Blast:OnAbilityPhaseStart()
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_warmup.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)
    return true
end

function Papich_HellFire_Blast:OnSpellStart()
    local target = self:GetCursorTarget()
    if not IsServer() then return end
    local info = {
        EffectName = "particles/papich/skeletonking_hellfireblast.vpcf",
        Ability = self,
        iMoveSpeed = 1000,
        Source = self:GetCaster(),
        Target = target,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
    }
    ProjectileManager:CreateTrackingProjectile( info )
    self:GetCaster():EmitSound("PapichHellfire_Blast")
end

function Papich_HellFire_Blast:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:TriggerSpellAbsorb( self ) ) then
        local stun_duration = self:GetSpecialValueFor( "duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_papich_2")
        local stun_damage = self:GetSpecialValueFor( "damage" )
        local slow_duration = stun_duration
        local damage = {
            victim = target,
            attacker = self:GetCaster(),
            damage = stun_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        ApplyDamage( damage )
        target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration})
        target:AddNewModifier( self:GetCaster(), self, "modifier_hellfire_blast_slow", { duration = (slow_duration*2) * (1 - target:GetStatusResistance())} )
        target:EmitSound("Hero_SkeletonKing.Hellfire_BlastImpact")
    end
    return true
end

modifier_hellfire_blast_slow = class({})

function modifier_hellfire_blast_slow:IsPurgable() return false end
function modifier_hellfire_blast_slow:IsPurgeException() return true end

function modifier_hellfire_blast_slow:OnCreated( kv )
    self.per_damage = self:GetAbility():GetSpecialValueFor( "per_damage" )
    self.move_slow = self:GetAbility():GetSpecialValueFor( "movespeed_slow" )
    self:StartIntervalThink( 1 )
    local particle = ParticleManager:CreateParticle("particles/papich/skeletonking_hellfireblast_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_hellfire_blast_slow:OnRefresh( kv )
    self.per_damage = self:GetAbility():GetSpecialValueFor( "per_damage" )
    self.move_slow = self:GetAbility():GetSpecialValueFor( "movespeed_slow" )
    self:StartIntervalThink( 1 )
end

function modifier_hellfire_blast_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_hellfire_blast_slow:GetModifierMoveSpeedBonus_Percentage( params )
    return self.move_slow
end

function modifier_hellfire_blast_slow:OnIntervalThink()
    if not IsServer() then return end
    local damage = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.per_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility()
    }
    ApplyDamage( damage )
end

function modifier_hellfire_blast_slow:GetEffectName()
    return "particles/papich/skeletonking_hellfireblast_debuff.vpcf"
end

function modifier_hellfire_blast_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

Papich_reincarnation = class({})
LinkLuaModifier("modifier_papich_reincarnation_wraith_form_buff",  "abilities/heroes/papich.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_reincarnation_wraith_form",  "abilities/heroes/papich.lua", LUA_MODIFIER_MOTION_NONE)

function Papich_reincarnation:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Papich_reincarnation:GetManaCost(level)
    if self:GetCaster():HasShard() then
        return 0
    end
    return self.BaseClass.GetManaCost(self, level)
end

function Papich_reincarnation:GetIntrinsicModifierName()
    return "modifier_papich_reincarnation_wraith_form_buff"
end

modifier_papich_reincarnation_wraith_form_buff = class({})

function modifier_papich_reincarnation_wraith_form_buff:IsHidden()
    return true
end

function modifier_papich_reincarnation_wraith_form_buff:IsPurgable()
    return false
end

function modifier_papich_reincarnation_wraith_form_buff:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MIN_HEALTH,
                      MODIFIER_EVENT_ON_TAKEDAMAGE}

    return decFuncs
end

function modifier_papich_reincarnation_wraith_form_buff:OnTakeDamage(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.unit 
    local damage = keys.damage
    local caster_health = self:GetParent():GetMaxHealth() / 2
    if self:GetCaster():HasTalent("special_bonus_birzha_papich_3") then
        caster_health = self:GetParent():GetMaxHealth() * 0.8
    end
    local duration = self:GetAbility():GetSpecialValueFor("duration")

    if self:GetParent() == target then



        for i = 0, 5 do 
            local item = self:GetParent():GetItemInSlot(i)
            if item then
                if item:GetName() == "item_uebator" or item:GetName() == "item_aeon_disk" then
                    if item:IsFullyCastable() then
                        return
                    end
                end
            end        
        end

        if self:GetParent():HasModifier("modifier_item_uebator_active") then
            return
        end
        
        if self:GetParent():HasModifier("modifier_item_aeon_disk_buff") then
            return
        end

        if self:GetParent():IsIllusion() then return end
        if self:GetParent():GetHealth() <= 1 then


            if self:GetAbility():IsFullyCastable() then
                self:GetParent():SetHealth(caster_health)
                self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_papich_reincarnation_wraith_form", {duration = duration})
                self:GetAbility():UseResources(true,false,true)
            end             
        end
    end
end

function modifier_papich_reincarnation_wraith_form_buff:GetMinHealth()
    if self:GetAbility():IsFullyCastable() and not self:GetParent():IsIllusion() then
        return 1
    end
end

function LaunchWraithblastProjectile(caster, ability, source, target, main)    
    local wraithblast_projectile = {
        Target = target,
        Source = source,
        Ability = ability,
        EffectName = "particles/papich/skeletonking_hellfireblast.vpcf",
        iMoveSpeed = 800,
        bDodgeable = true, 
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        bProvidesVision = false,  
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,                          
    }
    ProjectileManager:CreateTrackingProjectile(wraithblast_projectile)
end

function Papich_reincarnation:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self
    local duration = caster:FindAbilityByName("Papich_HellFire_Blast"):GetSpecialValueFor( "duration" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_papich_2")
    local damage = caster:FindAbilityByName("Papich_HellFire_Blast"):GetSpecialValueFor( "damage" )
    if target ~= nil and ( not target:IsMagicImmune() ) then
        target:EmitSound("Hero_SkeletonKing.Hellfire_BlastImpact")  
        local damageTable = {victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability } 
        ApplyDamage(damageTable)
        target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = duration})
        target:AddNewModifier( caster, caster:FindAbilityByName("Papich_HellFire_Blast"), "modifier_hellfire_blast_slow", { duration = (duration*2) * (1 - target:GetStatusResistance())} )
    end
    return true
end

modifier_papich_reincarnation_wraith_form = class({})

function modifier_papich_reincarnation_wraith_form:OnCreated()
    if not IsServer() then return end
    self:GetParent():EmitSound("PapichReincarnate")
    if self:GetCaster():HasScepter() then
        self.scepter_attacks = true
        self:StartIntervalThink(3)
    else
        self.scepter_attacks = false
    end
end

function modifier_papich_reincarnation_wraith_form:OnIntervalThink()
    if not IsServer() then return end
    self.scepter_attacks = false 
    self:StartIntervalThink(-1)
end

function modifier_papich_reincarnation_wraith_form:IsPurgable() return false end

function modifier_papich_reincarnation_wraith_form:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
                      MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
                      MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
                      MODIFIER_PROPERTY_DISABLE_HEALING,
                    }

    return decFuncs
end

function modifier_papich_reincarnation_wraith_form:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_papich_reincarnation_wraith_form:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_papich_reincarnation_wraith_form:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_papich_reincarnation_wraith_form:GetDisableHealing()
    return 1
end

function modifier_papich_reincarnation_wraith_form:CheckState()
    local state = {[MODIFIER_STATE_NO_HEALTH_BAR] = true,
                   [MODIFIER_STATE_INVULNERABLE] = true,
                   [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                   [MODIFIER_STATE_DISARMED] = true,
                   [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
    if self.scepter_attacks then            
    state = {[MODIFIER_STATE_NO_HEALTH_BAR] = true,
                   [MODIFIER_STATE_INVULNERABLE] = true,
                   [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                   [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
    end
    return state
end

function modifier_papich_reincarnation_wraith_form:GetStatusEffectName()
    return "particles/papich/status_effect_wraithking_ghosts.vpcf"
end

function modifier_papich_reincarnation_wraith_form:OnDestroy()
    if not IsServer() then return end
    if self:GetParent():HasTalent("special_bonus_birzha_papich_5") and (self:GetParent():FindAbilityByName("Papich_HellFire_Blast"):GetLevel()>0) then
        local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
          self:GetParent():GetAbsOrigin(),
          nil,
          525,
          DOTA_UNIT_TARGET_TEAM_ENEMY,
          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
          DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
          FIND_ANY_ORDER,
          false)

        for _,enemy in pairs(enemies) do
            LaunchWraithblastProjectile(self:GetParent(), self:GetAbility(), self:GetParent(), enemy, false)
        end
    end
end











Papich_StreamSnipers = class({})
LinkLuaModifier("modifier_streamsnipers_buff",  "abilities/heroes/papich.lua", LUA_MODIFIER_MOTION_NONE)

function Papich_StreamSnipers:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Papich_StreamSnipers:GetAOERadius()
    return self:GetSpecialValueFor( "aura_radius" )
end

function Papich_StreamSnipers:GetIntrinsicModifierName()
    return "modifier_streamsnipers_buff"
end

function Papich_StreamSnipers:OnUpgrade()
    if not IsServer() then return end
    self.modifier = self:GetCaster():FindModifierByName( "modifier_streamsnipers_buff" )
    if self.modifier then
        self.modifier:ForceRefresh()
    end
end

modifier_streamsnipers_buff = class({})

function modifier_streamsnipers_buff:IsPurgable() return false end

function modifier_streamsnipers_buff:OnCreated( kv )
    self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed_pct" )
    self.attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed" )
    self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
    self:StartIntervalThink(0.1)
end

function modifier_streamsnipers_buff:OnRefresh( kv )
    self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed_pct" )
    self.attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed" )
    self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
    self:StartIntervalThink(0.1)
end

function modifier_streamsnipers_buff:OnIntervalThink( kv )
    if not IsServer() then return end
    if self:GetParent():IsIllusion() then return end
    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self:GetAbility():GetSpecialValueFor( "aura_radius" ),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        0,
        false
    )
    self:SetStackCount( #enemies )
end

function modifier_streamsnipers_buff:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
                      MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                      MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                    }

    return decFuncs
end

function modifier_streamsnipers_buff:GetEffectName()
    return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end

function modifier_streamsnipers_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_streamsnipers_buff:GetModifierMoveSpeedBonus_Percentage()
    if self:GetParent():IsIllusion() then return end
    return self:GetStackCount() * self.move_speed
end

function modifier_streamsnipers_buff:GetModifierAttackSpeedBonus_Constant()
    if self:GetParent():IsIllusion() then return end
    return self:GetStackCount() * self.attack_speed
end

function modifier_streamsnipers_buff:GetModifierPhysicalArmorBonus()
    if self:GetParent():IsIllusion() then return end
    return self:GetStackCount() * self.armor
end

Papich_in_solo = class({})
LinkLuaModifier("modifier_Papich_in_solo",  "abilities/heroes/papich.lua", LUA_MODIFIER_MOTION_NONE)

function Papich_in_solo:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) / ( self:GetCaster():GetCooldownReduction())
end

function Papich_in_solo:GetIntrinsicModifierName()
    return "modifier_Papich_in_solo"
end

modifier_Papich_in_solo = class({})

function modifier_Papich_in_solo:IsPurgable() return false end
function modifier_Papich_in_solo:IsHidden() return true end

function modifier_Papich_in_solo:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
    }

    return funcs
end








function modifier_Papich_in_solo:OnAttack( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() or target:IsBoss() then return end
        if target:IsOther() then
            return nil
        end
        if not self:GetAbility():IsFullyCastable() then return end
        if self.attack_chance == nil then
            self.attack_chance = 1
        else
            if self.attack_chance <= 4 then
                self.attack_chance = self.attack_chance + 1
            end
        end
        if self.attach_sound == nil then
            self.attach_sound = 0
        else
            if self.attach_sound < 5 then
                self.attach_sound = self.attach_sound + 1
            else
                self:GetParent():EmitSound("papichwherecrit") 
                self.attach_sound = 0
            end
        end
    end
end

function modifier_Papich_in_solo:GetModifierPreAttack_CriticalStrike( params )
    local chance = self:GetAbility():GetSpecialValueFor("crit_chance") + self:GetCaster():FindTalentValue("special_bonus_birzha_papich_6")
    local crit = self:GetAbility():GetSpecialValueFor("crit_mult")
    if not IsServer() then return end
    if params.target:IsOther() then
        return nil
    end
    if self.attack_chance == nil then
        self.attack_chance = 1
    end
    if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() or params.target:IsBoss() then return end
    --if self.attack_chance >= RandomInt(1, 100) then
    --    if not self:GetAbility():IsFullyCastable() then return end
    --    if self:GetParent():HasModifier("modifier_papich_reincarnation_wraith_form") then return end
    --    self.attack_chance = nil
    --    self.attach_sound = 0
    --    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, self:GetParent():GetSecondsPerAttack())
    --    self:GetAbility():UseResources(false, false, true)
    --    self:GetParent():StopSound("papichwherecrit")
    --    self:GetParent():EmitSound("papichcreet")
    --    if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 29) then
    --        local niia = ParticleManager:CreateParticle("particles/birzhapass/papich_critical_effect.vpcf", PATTACH_OVERHEAD_FOLLOW, params.target)
    --        ParticleManager:SetParticleControl(niia, 0, params.target:GetAbsOrigin())
    --        ParticleManager:SetParticleControl(niia, 7, params.target:GetAbsOrigin())
    --    end
    --    return 1000000
    --end 

    if RollPercentage(self.attack_chance) then
        if self:GetAbility():IsFullyCastable() then
            if self:GetParent():HasTalent("special_bonus_birzha_papich_1") then
                if not self:GetParent():HasModifier("modifier_papich_reincarnation_wraith_form") then
                    self.attack_chance = nil
                    self.attach_sound = 0
                    self:GetParent():RemoveGesture(ACT_DOTA_ATTACK_EVENT)
                    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, self:GetParent():GetAttackSpeed())
                    self:GetAbility():UseResources(false, false, true)
                    self:GetParent():StopSound("papichwherecrit")
                    self:GetParent():EmitSound("papichcreet")
                    if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 29) then
                        local niia = ParticleManager:CreateParticle("particles/birzhapass/papich_critical_effect.vpcf", PATTACH_OVERHEAD_FOLLOW, params.target)
                        ParticleManager:SetParticleControl(niia, 0, params.target:GetAbsOrigin())
                        ParticleManager:SetParticleControl(niia, 7, params.target:GetAbsOrigin())
                    end
                    return 1000000
                end
            else
                self:GetParent():RemoveGesture(ACT_DOTA_ATTACK_EVENT)
                self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, self:GetParent():GetAttackSpeed())
                self.attack_record = params.record
                return
            end
        end
    end


    if RollPercentage(chance) then
        self:GetParent():RemoveGesture(ACT_DOTA_ATTACK_EVENT)
        self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, self:GetParent():GetAttackSpeed())
        self:GetParent():StopSound("papichwherecrit")
        self:GetParent():EmitSound("papichsolo_new")
        self.attach_sound = 0
        return crit
    end
    return 0
end

function modifier_Papich_in_solo:GetModifierProcAttack_Feedback( params )
    if IsServer() then

        local pass = false

        if self.attack_record and params.record==self.attack_record then
            pass = true
            self.attack_record = nil
        end

        if pass then
            if not self:GetParent():HasModifier("modifier_papich_reincarnation_wraith_form") then
                self.attack_chance = nil
                self.attach_sound = 0
                --self:GetParent():RemoveGesture(ACT_DOTA_ATTACK_EVENT)
                --self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, self:GetParent():GetAttackSpeed())
                self:GetAbility():UseResources(false, false, true)
                self:GetParent():StopSound("papichwherecrit")
                self:GetParent():EmitSound("papichcreet")
                if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 29) then
                    local niia = ParticleManager:CreateParticle("particles/birzhapass/papich_critical_effect.vpcf", PATTACH_OVERHEAD_FOLLOW, params.target)
                    ParticleManager:SetParticleControl(niia, 0, params.target:GetAbsOrigin())
                    ParticleManager:SetParticleControl(niia, 7, params.target:GetAbsOrigin())
                end
                ApplyDamage({victim = params.target, attacker = self:GetParent(), damage = params.target:GetMaxHealth() / 2, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()}) 
            end
        end
    end
end






