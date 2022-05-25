LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_mum_meat_hook", "abilities/heroes/mum.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_mum_meat_hook_debuff", "abilities/heroes/mum.lua", LUA_MODIFIER_MOTION_HORIZONTAL  )

mum_meat_hook = class({})
mum_meat_hook.hooks = {}

function mum_meat_hook:OnAbilityPhaseStart()
    self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
    return true
end

function mum_meat_hook:GetCastRange(location, target)
    return self:GetSpecialValueFor( "hook_distance" ) + self:GetCaster():GetCastRangeBonus()
end

function mum_meat_hook:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end

function mum_meat_hook:OnSpellStart()
    for id, hook in pairs(self.hooks) do
        if hook ~= nil then

            if self.hooks[id].hVictim and not self.hooks[id].hVictim:IsNull() then
                

                self.hooks[id].hVictim:RemoveModifierByName("modifier_mum_meat_hook_debuff")
            
                if self.hooks[id].hVictim and self.hooks[id].hVictim:GetUnitName() == "npc_dota_companion" then 
                    UTIL_Remove(self.hooks[id].hVictim)
                end

                 if self.hooks[id].thinker then 
                    UTIL_Remove(self.hooks[id].thinker)
                end
            end
            ProjectileManager:DestroyLinearProjectile(id)
        end
    end

    self.hooks = {}
    
    local caster_position = self:GetCaster():GetOrigin()

    local point = self:GetCursorPosition()
    if point == caster_position then 
        point = point + self:GetCaster():GetForwardVector()*5
    end
    local direction = CalculateDirection(point, caster_position)
    self:UseHook(direction)

    if self:GetCaster() and self:GetCaster():IsHero() then
        local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
        if hHook ~= nil then
            hHook:AddEffects( EF_NODRAW )
        end
    end

    if self:GetCaster():HasScepter() then
        local angle = 10
        local hook_count = 2
        for i = 1, hook_count do
            local newAngle = angle * math.ceil(i / 2) * (-1)^i
            local newDir = RotateVector2DPudge( direction, ToRadians( newAngle ) )
            self:UseHook( newDir )
        end
    end
end

------------------------ Функции


function RotateVector2DPudge(vector, theta)
    local xp = vector.x*math.cos(theta)-vector.y*math.sin(theta)
    local yp = vector.x*math.sin(theta)+vector.y*math.cos(theta)
    return Vector(xp,yp,vector.z):Normalized()
end

function ToRadians(degrees)
    return degrees * math.pi / 180
end

function CalculateDirection(ent1, ent2)
    local pos1 = ent1
    local pos2 = ent2
    if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
    if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
    local direction = (pos1 - pos2)
    direction.z = 0
    return direction:Normalized()
end

------------------------------------

function mum_meat_hook:UseHook( direction )
    self.hook_damage = self:GetSpecialValueFor( "damage" )
    self.hook_speed = self:GetSpecialValueFor( "hook_speed" )
    self.hook_width = self:GetSpecialValueFor( "hook_width" )
    self.hook_distance = self:GetSpecialValueFor( "hook_distance" ) + self:GetCaster():GetCastRangeBonus()
    self.hook_followthrough_constant = 0.65
    self.vision_radius = self:GetSpecialValueFor( "vision_radius" )  
    self.vision_duration = self:GetSpecialValueFor( "vision_duration" )  
    local caster_location = self:GetCaster():GetOrigin()
    local flFollowthroughDuration = ( self.hook_distance / self.hook_speed * self.hook_followthrough_constant )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_mum_meat_hook", { duration = flFollowthroughDuration } )
    self.vHookOffset = Vector( 0, 0, 96 )
    local vHookTarget = (caster_location + (direction * self.hook_distance)) + self.vHookOffset
    local vKillswitch = Vector( ( ( self.hook_distance / self.hook_speed ) * 2 ), 0, 0 )

    local hook_particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleAlwaysSimulate( hook_particle )
    ParticleManager:SetParticleControlEnt( hook_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true )
    ParticleManager:SetParticleControl( hook_particle, 1, vHookTarget )
    ParticleManager:SetParticleControl( hook_particle, 2, Vector( self.hook_speed, self.hook_distance, self.hook_width ) )
    ParticleManager:SetParticleControl( hook_particle, 3, vKillswitch )
    ParticleManager:SetParticleControl( hook_particle, 4, Vector( 1, 0, 0 ) )
    ParticleManager:SetParticleControl( hook_particle, 5, Vector( 0, 0, 0 ) )
    ParticleManager:SetParticleControlEnt( hook_particle, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetOrigin(), true )

    local thinker = CreateModifierThinker(
        self:GetCaster(),
        self,
        "modifier_invulnerable",
        {},
        self:GetCaster():GetOrigin(),
        self:GetCaster():GetTeamNumber(),
        false
    )

    local info = {
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(),
        vVelocity = direction * self.hook_speed,
        fDistance = self.hook_distance,
        fStartRadius = self.hook_width ,
        fEndRadius = self.hook_width ,
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,

    }

    local projectileIndex = ProjectileManager:CreateLinearProjectile( info )

    self.hooks[projectileIndex] = {}
    self.hooks[projectileIndex].particleIndex = hook_particle
    self.hooks[projectileIndex].hook_speed = self.hook_speed
    self.hooks[projectileIndex].hook_width = self.hook_width
    self.hooks[projectileIndex].bRetracting = false
    self.hooks[projectileIndex].hVictim = nil
    self.hooks[projectileIndex].bDiedInHook = false
    self.hooks[projectileIndex].direction = caster_location * (direction * self.hook_distance)
    self.hooks[projectileIndex].start_position = caster_location
    self.hooks[projectileIndex].proj_location = nil
    self.hooks[projectileIndex].thinker = thinker
    self.hooks[projectileIndex].thinker:EmitSound("Hero_Pudge.AttackHookExtend")
end




















function mum_meat_hook:OnProjectileHitHandle( target, position, projectileIndex )
    if not IsServer() then return end
    local caster = self:GetCaster()

    if target == caster then return false end


    if not self.hooks[projectileIndex].thinker or  self.hooks[projectileIndex].thinker:IsNull() then return end

    if self.hooks[projectileIndex] == nil then return true end


    if self.hooks[projectileIndex].bRetracting == false then
        if target ~= nil and ( not ( target:IsCreep() or target:IsConsideredHero() ) ) then
            return false
        end

        local bTargetPulled = false
        if target ~= nil then
            if target:HasModifier("modifier_Daniil_LaughingRush_debuff") or target:HasModifier("modifier_modifier_eul_cyclone_birzha") then return false  end
            if target:GetUnitName() == "npc_dota_zerkalo" then return false end

            self.hooks[projectileIndex].thinker:StopSound("Hero_Pudge.AttackHookExtend")

            if self:GetCaster():HasModifier("modifier_mum_meat_hook") then 
                self:GetCaster():RemoveModifierByName("modifier_mum_meat_hook")
            end

            target:EmitSound("Hero_Pudge.AttackHookImpact")


            target:AddNewModifier( self:GetCaster(), self, "modifier_mum_meat_hook_debuff", {} )

            if target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then

                local damage = self.hook_damage

                local damage_table = {  victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self }

                ApplyDamage( damage_table )


                if not target:IsAlive() then self.hooks[projectileIndex].bDiedInHook = true end

                if not target:IsMagicImmune() then target:Interrupt() end

                local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, target )
                ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
                ParticleManager:ReleaseParticleIndex( nFXIndex )
            end
            AddFOWViewer( self:GetCaster():GetTeamNumber(), target:GetOrigin(), self.vision_radius, self.vision_duration, false )
            self.hooks[projectileIndex].hVictim = target
            bTargetPulled = true
        end



        if self.hooks[projectileIndex].hVictim == nil then
            local dummy = CreateUnitByName("npc_dota_companion", position, false, nil, nil, self:GetCaster():GetTeamNumber())
            dummy:AddNewModifier(self:GetCaster(), self, "modifier_phased", {})
            dummy:AddNewModifier(self:GetCaster(), self, "modifier_no_healthbar", {})
            dummy:AddNewModifier(self:GetCaster(), self, "modifier_invulnerable", {})
            self.hooks[projectileIndex].hVictim = dummy
            target = dummy
        end

        local vHookPos = self.hooks[projectileIndex].direction
        local flPad = self:GetCaster():GetPaddedCollisionRadius()

        if target ~= nil then
            vHookPos = target:GetOrigin()
            flPad = flPad + target:GetPaddedCollisionRadius()
        end

        local vVelocity = self.hooks[projectileIndex].start_position - vHookPos
        vVelocity.z = 0.0

        local flDistance = vVelocity:Length2D() - flPad
        vVelocity = vVelocity:Normalized() * self.hook_speed

        --self.vProjectileLocation = vHookPos

        if bTargetPulled then

            ParticleManager:SetParticleControlEnt( self.hooks[projectileIndex].particleIndex, 0, self:GetCaster(), PATTACH_ABSORIGIN, "attach_weapon_chain_rt", self.hooks[projectileIndex].start_position + self.vHookOffset, true )
            ParticleManager:SetParticleControl( self.hooks[projectileIndex].particleIndex, 0, self.hooks[projectileIndex].start_position + self.vHookOffset )

            ParticleManager:SetParticleControlEnt( self.hooks[projectileIndex].particleIndex, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin() + self.vHookOffset, true )
            ParticleManager:SetParticleControl( self.hooks[projectileIndex].particleIndex, 4, Vector( 0, 0, 0 ) )
            ParticleManager:SetParticleControl( self.hooks[projectileIndex].particleIndex, 5, Vector( 1, 0, 0 ) )
        else
            ParticleManager:SetParticleControlEnt( self.hooks[projectileIndex].particleIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true);
        end


        self.hooks[projectileIndex].thinker:EmitSound("Hero_Pudge.AttackHookRetract")
     

        if self:GetCaster():IsAlive() then
            self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
            self:GetCaster():StartGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
        end

        self.hooks[projectileIndex].bRetracting = true

        local info = {
            Ability = self,
            vSpawnOrigin = vHookPos,
            vVelocity = vVelocity,
            fDistance = flDistance,
            Source = self:GetCaster(),
        }

        local back_proj = ProjectileManager:CreateLinearProjectile( info )

        self.hooks[back_proj] = {}

        self.hooks[back_proj].hook_speed = self.hooks[projectileIndex].hook_speed
        self.hooks[back_proj].hook_width = self.hooks[projectileIndex].hook_width
        self.hooks[back_proj].particleIndex = self.hooks[projectileIndex].particleIndex
        self.hooks[back_proj].bRetracting =  self.hooks[projectileIndex].bRetracting
        self.hooks[back_proj].hVictim = self.hooks[projectileIndex].hVictim
        self.hooks[back_proj].bDiedInHook = self.hooks[projectileIndex].bDiedInHook
        self.hooks[back_proj].direction = self.hooks[projectileIndex].direction
        self.hooks[back_proj].start_position = self.hooks[projectileIndex].start_position
        self.hooks[back_proj].thinker = self.hooks[projectileIndex].thinker 
        self.hooks[back_proj].proj_location = position

        self.hooks[projectileIndex] = nil
    else


        if self:GetCaster() and self:GetCaster():IsHero() then
            local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
            if hHook ~= nil then
                hHook:RemoveEffects( EF_NODRAW )
            end
        end

        if self.hooks[projectileIndex].hVictim ~= nil and not self.hooks[projectileIndex].hVictim:IsNull() then

            local vFinalHookPos = position
            self.hooks[projectileIndex].hVictim:InterruptMotionControllers( true )
            
            self.hooks[projectileIndex].thinker:StopSound("Hero_Pudge.AttackHookRetract")

            self.hooks[projectileIndex].hVictim:RemoveModifierByName( "modifier_mum_meat_hook_debuff" )

            local vVictimPosCheck = self.hooks[projectileIndex].hVictim:GetOrigin() - vFinalHookPos 
            local flPad = self:GetCaster():GetPaddedCollisionRadius() + self.hooks[projectileIndex].hVictim:GetPaddedCollisionRadius()
            if vVictimPosCheck:Length2D() > flPad then
                local check_dir = (self.hooks[projectileIndex].start_position - self.hooks[projectileIndex].hVictim:GetAbsOrigin()):Normalized()
                local origin = self.hooks[projectileIndex].start_position + (check_dir * 75)
                origin.z = 0
                FindClearSpaceForUnit( self.hooks[projectileIndex].hVictim, origin, false )

             


                local angel =(self.hooks[projectileIndex].start_position - self.hooks[projectileIndex].hVictim:GetAbsOrigin())
                angel.z = 0.0
                angel = angel:Normalized()
                self.hooks[projectileIndex].hVictim:SetForwardVector(angel)
            end
        end

        if not self.hooks[projectileIndex].hVictim:IsNull() and self.hooks[projectileIndex].hVictim:GetUnitName() == "npc_dota_companion" then 
            UTIL_Remove(self.hooks[projectileIndex].hVictim)
        end

        self.hooks[projectileIndex].thinker:StopSound("Hero_Pudge.AttackHookRetract")
        UTIL_Remove(self.hooks[projectileIndex].thinker)

        self.hooks[projectileIndex].hVictim = nil

        if self.hooks[projectileIndex].particleIndex then
            ParticleManager:DestroyParticle( self.hooks[projectileIndex].particleIndex, true )
        end
        self:GetCaster():EmitSound("Hero_Pudge.AttackHookRetractStop")


    end

    return true
end


function mum_meat_hook:OnProjectileThinkHandle( projectileIndex )
if not IsServer() then return end
    if self.hooks[projectileIndex] then

        if not self.hooks[projectileIndex].thinker or self.hooks[projectileIndex].thinker:IsNull() then return end

        local position = ProjectileManager:GetLinearProjectileLocation( projectileIndex )

        self.hooks[projectileIndex].thinker:SetAbsOrigin(position)

        if self.hooks[projectileIndex].bRetracting then
            local caster = self:GetCaster()
            local speed = self.hooks[projectileIndex].hook_speed or 0
            local width = self.hooks[projectileIndex].hook_width or 0
            local position = ProjectileManager:GetLinearProjectileLocation( projectileIndex )

            self.hooks[projectileIndex].thinker:SetAbsOrigin(position)

            if self.hooks[projectileIndex].hVictim then
                if not self.hooks[projectileIndex].hVictim:HasModifier("modifier_mum_meat_hook_debuff") then
                    self.hooks[projectileIndex].hVictim:AddNewModifier( self:GetCaster(), self, "modifier_mum_meat_hook_debuff", {} )
                end


                local check_dir_2 = (self.hooks[projectileIndex].start_position - self.hooks[projectileIndex].hVictim:GetAbsOrigin()):Normalized()

                self.hooks[projectileIndex].hVictim:SetOrigin(GetGroundPosition(position, self.hooks[projectileIndex].hVictim))
                self.hooks[projectileIndex].hVictim:SetForwardVector(check_dir_2)


                local vFinalHookPos = self.hooks[projectileIndex].start_position 

                local vVictimPosCheck = vFinalHookPos - self.hooks[projectileIndex].hVictim:GetOrigin() 
                local flPad = self:GetCaster():GetPaddedCollisionRadius() + self.hooks[projectileIndex].hVictim:GetPaddedCollisionRadius()
                if vVictimPosCheck:Length2D() < flPad then

                    local check_dir = (self.hooks[projectileIndex].start_position - self.hooks[projectileIndex].hVictim:GetAbsOrigin()):Normalized()


                    local origin = self.hooks[projectileIndex].start_position + (check_dir * 150)
                    origin.z = 0

                    FindClearSpaceForUnit( self.hooks[projectileIndex].hVictim, origin, false )

                    local angel = (self.hooks[projectileIndex].start_position - self.hooks[projectileIndex].hVictim:GetAbsOrigin())
                    angel.z = 0.0
                    angel = angel:Normalized()
                    self.hooks[projectileIndex].hVictim:SetForwardVector(angel)




                    self.hooks[projectileIndex].hVictim:InterruptMotionControllers( true )
                    self.hooks[projectileIndex].hVictim:RemoveModifierByName( "modifier_mum_meat_hook_debuff" )
                    if self.hooks[projectileIndex].hVictim:GetUnitName() == "npc_dota_companion" then
                        UTIL_Remove(self.hooks[projectileIndex].hVictim)
                    end
                end
            end
            ParticleManager:SetParticleControl(self.hooks[projectileIndex].particleIndex, 1, self:GetCaster():GetAbsOrigin())
        end
    end
end

function mum_meat_hook:OnOwnerDied()
    self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
    self:GetCaster():RemoveGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
end

modifier_mum_meat_hook = class({})

function modifier_mum_meat_hook:IsHidden()
    return true
end

function modifier_mum_meat_hook:IsPurgable()
    return false
end

function modifier_mum_meat_hook:CheckState()
    local state = {
    [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

modifier_mum_meat_hook_debuff = class({})

function modifier_mum_meat_hook_debuff:IsDebuff()
    return true
end

function modifier_mum_meat_hook_debuff:RemoveOnDeath()
    return false
end

function modifier_mum_meat_hook_debuff:OnDestroy()
    if not IsServer() then return end
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
    local angel = (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin())
    angel.z = 0.0
    angel = angel:Normalized()
    self:GetParent():SetForwardVector(angel)
end

function modifier_mum_meat_hook_debuff:IsPurgable()
    return false
end

function modifier_mum_meat_hook_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_mum_meat_hook_debuff:GetOverrideAnimation( params )
    return ACT_DOTA_FLAIL
end

function modifier_mum_meat_hook_debuff:CheckState()
    --if IsServer() then
        if self:GetCaster() ~= nil and self:GetParent() ~= nil then
            if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() and ( not self:GetParent():IsMagicImmune() ) then
                local state = {
                [MODIFIER_STATE_STUNNED] = true,
                }

                return state
            end
        end
    --end

    local state = {}

    return state
end





























mum_arrows_of_death = class({})

function mum_arrows_of_death:GetCooldown(level) 
    return self.BaseClass.GetCooldown( self, level )
end

function mum_arrows_of_death:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function mum_arrows_of_death:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function mum_arrows_of_death:OnAbilityPhaseStart()
    self:GetCaster():StartGesture( ACT_DOTA_CHANNEL_ABILITY_1 )
    return true
end

function mum_arrows_of_death:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture( ACT_DOTA_CHANNEL_ABILITY_1 )
end

function mum_arrows_of_death:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local cast_direction = (point - caster_loc):Normalized()
    if point == caster_loc then
        cast_direction = caster:GetForwardVector()
    else
        cast_direction = (point - caster_loc):Normalized()
    end

    local index = DoUniqueString("arrow_mums")
    self[index] = {}

    local info = {
        Source = caster,
        Ability = self,
        vSpawnOrigin = caster:GetOrigin(),
        bDeleteOnHit = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName = "particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf",
        fDistance = 1400,
        fStartRadius = 115,
        fEndRadius =115,
        vVelocity = cast_direction * 600,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bProvidesVision = true,
        iVisionRadius = 650,
        iVisionTeamNumber = caster:GetTeamNumber(),
        ExtraData           = {index = index, arrows = 20}
    }
    caster:EmitSound("Hero_Mirana.ArrowCast")

    local first_angle = -6 * (20 - 1) / 2
    for i = 1, 20 do
        local angle = first_angle + (i-1) * 6
        info.vVelocity = RotateVector2D(cast_direction,angle,true) * 600
        ProjectileManager:CreateLinearProjectile(info)
    end
end

function mum_arrows_of_death:OnProjectileHit_ExtraData(target, location, ExtraData)
    if not IsServer() then return end
    if target ~= nil then
        local was_hit = false
        for _, stored_target in ipairs(self[ExtraData.index]) do
            if target == stored_target then
                was_hit = true
                break
            end
        end
        if was_hit then
            return true
        end
        table.insert(self[ExtraData.index],target)
        local stun_duration = self:GetSpecialValueFor( "arrow_stun" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_mum_3")
        target:AddNewModifier(self:GetCaster(), self, "modifier_birzha_stunned_purge", {duration = stun_duration})
        target:EmitSound("Hero_Mirana.ArrowImpact")
        ApplyDamage({ victim = target, attacker = self:GetCaster(), ability = self, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL })
        return true
    else
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] or 0
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] + 1
        if self[ExtraData.index]["count"] == ExtraData.arrows then
            self[ExtraData.index] = nil
        end
    end
end

LinkLuaModifier( "modifier_mum_fart", "abilities/heroes/mum.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_fart_aura", "abilities/heroes/mum.lua", LUA_MODIFIER_MOTION_NONE )

mum_fart = class({})

function mum_fart:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function mum_fart:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function mum_fart:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")

    local thinker = CreateModifierThinker(caster, self, "modifier_mum_fart", {duration = duration, target_point_x = point.x , target_point_y = point.y}, point, caster:GetTeamNumber(), false)
    caster:EmitSound("pudgepuk")
end

modifier_mum_fart = class({})

function modifier_mum_fart:IsPurgable() return false end
function modifier_mum_fart:IsHidden() return true end
function modifier_mum_fart:IsAura() return true end

function modifier_mum_fart:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.particle = ParticleManager:CreateParticle("particles/perdezh/riki_smokebomb.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius, self.radius, self.radius))
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_mum_fart:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY end

function modifier_mum_fart:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_mum_fart:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_mum_fart:GetModifierAura()
    return "modifier_fart_aura"
end

function modifier_mum_fart:GetAuraRadius()
    return self.radius
end

modifier_fart_aura = class({})

function modifier_fart_aura:IsPurgable() return false end
function modifier_fart_aura:IsDebuff() return true end

function modifier_fart_aura:OnCreated()
    self.slow = self:GetAbility():GetSpecialValueFor("movespeed")
    if not IsServer() then return end
    self:StartIntervalThink( 0.2 )
    if DonateShopIsItemBought(self:GetCaster():GetPlayerID(), 25) then
        if self:GetParent():IsHero() then
            self:GetParent().FartEffect = ParticleManager:CreateParticle("particles/econ/items/pudge/pudge_arcana/pudge_arcana_dismember_default.vpcf", PATTACH_ABSORIGIN, self:GetParent())
            ParticleManager:SetParticleControl(self:GetParent().FartEffect, 1, self:GetParent():GetAbsOrigin())
            ParticleManager:SetParticleControl(self:GetParent().FartEffect, 8, Vector(1, 1, 1))
            ParticleManager:SetParticleControl(self:GetParent().FartEffect, 15, Vector(255, 140, 1))
            self:AddParticle(self:GetParent().FartEffect, false, false, -1, false, false)
        end
    end
end

function modifier_fart_aura:OnIntervalThink()
    local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_birzha_mum_2")
    if not IsServer() then return end
    ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage * 0.2, damage_type = DAMAGE_TYPE_MAGICAL })
end

function modifier_fart_aura:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, }
    return funcs
end

function modifier_fart_aura:GetModifierMoveSpeedBonus_Percentage()
    if self:GetParent():IsMagicImmune() then return 0 end
    return self.slow
end

fut_mum_eat = class({})

LinkLuaModifier( "modifier_fut_mum_eat_caster", "abilities/heroes/mum.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_fut_mum_eat_target", "abilities/heroes/mum.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_silence_item", "abilities/heroes/mum.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_fut_mum_eat_passive", "abilities/heroes/mum.lua",LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function fut_mum_eat:GetIntrinsicModifierName()
    return "modifier_fut_mum_eat_passive"
end

function fut_mum_eat:OnSpellStart()
    local duration = self:GetSpecialValueFor( "duration" )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_fut_mum_eat_caster", { duration = duration } )
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_silence_item", {duration=duration})
    self:EmitSound("pudgemeat")
end

modifier_fut_mum_eat_caster = class({})

function modifier_fut_mum_eat_caster:IsHidden()
    return false
end

function modifier_fut_mum_eat_caster:IsPurgable()
    return false
end

function modifier_fut_mum_eat_caster:OnCreated()
    if not IsServer() then return end
    self:GetAbility():SetActivated(false)
    self.eat_bool = true
    self.stack_particle = ParticleManager:CreateParticle("particles/mum/pudge_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl( self.stack_particle, 0, self:GetParent():GetAbsOrigin())         
    self:AddParticle( self.stack_particle, false, false, -1, false, true )
    self.victims = 0
end

function modifier_fut_mum_eat_caster:OnDestroy()
    if not IsServer() then return end
    self.model_scale = 1
    self:GetAbility():SetActivated(true)
    self:GetCaster():SetModelScale(self.model_scale)
    self:GetCaster():SetRenderColor(255, 255, 255)
    self:GetCaster():EmitSound("mumend")
    local caster_pos = self:GetCaster():GetAbsOrigin()
    self.victims = nil
    ParticleManager:DestroyParticle(self.stack_particle, true)
end

function modifier_fut_mum_eat_caster:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

function modifier_fut_mum_eat_caster:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_START,
    }
    return funcs
end

function modifier_fut_mum_eat_caster:OnAttackStart( params )
    if not IsServer() then return end
    if params.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) then
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)
        local target = params.target
        local duration = self:GetRemainingTime()
        if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
            if not target:IsRealHero() or params.target:HasModifier("modifier_fut_mum_eat_caster") then
                return nil
            else
              self:GetCaster():SetModelScale(self:GetCaster():GetModelScale() + 0.1)
              if self.stack_particle then
               ParticleManager:DestroyParticle(self.stack_particle, true)
              end
              target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_fut_mum_eat_target", { duration = duration } )
              local caster = self:GetParent() 
              self.stack_particle = ParticleManager:CreateParticle("particles/mum/pudge_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())            
              self.victims = self.victims + 1
              self:GetCaster():SetModifierStackCount("modifier_fut_mum_eat_caster", self:GetAbility(), self.victims)
              ParticleManager:SetParticleControl( self.stack_particle, 1, Vector(1, self.victims, 0))
              self:AddParticle( self.stack_particle, false, false, -1, false, true )
              if self.victims > 9 then
                 ParticleManager:SetParticleControl( self.stack_particle, 2, Vector(2, 1, 0))
              else
                 ParticleManager:SetParticleControl( self.stack_particle, 2, Vector(1, 1, 0))
              end
              self:GetCaster():Stop()
            end
        end
    end
    return 0
end

modifier_fut_mum_eat_target = class({})

function modifier_fut_mum_eat_target:IsPurgable()
    return false
end

function modifier_fut_mum_eat_target:OnCreated( kv )
    self:StartIntervalThink(0.03)
    self.kill_chance = self:GetAbility():GetSpecialValueFor( "kill_chance" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_mum_1")
    if not IsServer() then return end
    self.model_scale = self:GetParent():GetModelScale()
    self:StartIntervalThink(0.1)
    self:GetParent():AddNoDraw()
    self.particle = ParticleManager:CreateParticleForPlayer("particles/pudge/pudgerage.vpcf", PATTACH_EYES_FOLLOW, self:GetParent(), self:GetParent():GetPlayerOwner())
    self:AddParticle( self.particle, false, false, -1, false, true )        
    self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
end

function modifier_fut_mum_eat_target:OnIntervalThink()
    if not IsServer() then return end
    local target = self:GetParent ()
    local target_pos = target:GetAbsOrigin ()
    local caster = self:GetAbility ():GetCaster ()
    target:SetAbsOrigin (self:GetCaster ():GetAbsOrigin ())
    if not caster:IsAlive() then
        target:RemoveModifierByName ("modifier_fut_mum_eat_target")
    end
end

function modifier_fut_mum_eat_target:OnDestroy( kv )
self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
if not IsServer() then return end
self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = 0.5})
local point = self:GetCaster():GetAbsOrigin()
local bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
FindClearSpaceForUnit(self:GetParent(), self:GetCaster():GetAbsOrigin(), true)
    local chance = math.random(100)
    local npcName = self:GetParent():GetUnitName()
    
    self:GetParent():RemoveNoDraw()
    
    local distance = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
    local direction = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
    local bump_point = self:GetCaster():GetAbsOrigin() - direction * distance
    local knockbackProperties =
    {
        center_x = bump_point.x,
        center_y = bump_point.y,
        center_z = bump_point.z,
        duration = 0.5,
        knockback_duration = 0.5,
        knockback_distance = 400,
        knockback_height = 350
    }
    self:GetParent():RemoveModifierByName("modifier_knockback")
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_knockback", knockbackProperties)
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE})
end

function modifier_fut_mum_eat_target:CheckState()
    local state = {
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_NIGHTMARED] = true,
        [MODIFIER_STATE_HEXED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

modifier_silence_item = class({})

function modifier_silence_item:CheckState() 
    if self:GetParent():HasShard() then return end
  local state =
      {
   [MODIFIER_STATE_MUTED] = true
      }
  return state
end

function modifier_silence_item:IsPurgable()
    return false
end

function modifier_silence_item:IsHidden()
    return true
end

modifier_fut_mum_eat_passive = class({})

function modifier_fut_mum_eat_passive:IsPurgable() return false end

function modifier_fut_mum_eat_passive:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
end

function modifier_fut_mum_eat_passive:OnDeath(params)
    if params.unit == self:GetParent() then return end
    if params.inflictor == nil then return end
    if params.attacker ~= self:GetParent() then return end
    if params.inflictor ~= self:GetAbility() then return end
    self:IncrementStackCount()
    params.unit:SetBaseStrength(params.unit:GetBaseStrength() - (self:GetAbility():GetSpecialValueFor( "bonus_strength" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_mum_1"))   )
end

function modifier_fut_mum_eat_passive:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor( "bonus_strength" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_mum_1"))
    end
end