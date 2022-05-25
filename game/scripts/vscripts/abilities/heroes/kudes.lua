LinkLuaModifier( "modifier_Kudes_GoldHook", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_Kudes_GoldHook_debuff", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_HORIZONTAL  )
LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_bashed", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

Kudes_GoldHook = class({})

function Kudes_GoldHook:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Kudes_GoldHook:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Kudes_GoldHook:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Kudes_GoldHook:OnAbilityPhaseStart()
    self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
    return true
end

function Kudes_GoldHook:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end

function Kudes_GoldHook:OnSpellStart()
	if not IsServer() then return end
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
	self:GetCaster():GetAbsOrigin(),
	nil,
	self:GetSpecialValueFor( "hook_distance" ),
	DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_HERO,
	DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	FIND_ANY_ORDER,
	false)
	local target = nil
	for _,enemy in pairs(enemies) do
		target = enemy
		break
	end
	if not target then
		target = enemies[1]
	end
	if not target then return end
    self.bChainAttached = false
    if self.hVictim ~= nil then
        self.hVictim:InterruptMotionControllers( true )
    end
    self.hook_damage = self:GetSpecialValueFor( "hook_damage" )
    self.hook_speed = self:GetSpecialValueFor( "hook_speed" )
    self.hook_width = self:GetSpecialValueFor( "hook_width" )
    self.hook_distance = self:GetSpecialValueFor( "hook_distance" )
    self.hook_followthrough_constant = 0.65

    self.vision_radius = self:GetSpecialValueFor( "vision_radius" )  
    self.vision_duration = self:GetSpecialValueFor( "vision_duration" )  
    
    if self:GetCaster() and self:GetCaster():IsHero() then
        local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
        if hHook ~= nil then
            hHook:AddEffects( EF_NODRAW )
        end
    end

    self.vStartPosition = self:GetCaster():GetOrigin()
    self.vProjectileLocation = vStartPosition
    local vDirection = target:GetAbsOrigin() - self.vStartPosition
    vDirection.z = 0.0

    local vDirection = ( vDirection:Normalized() ) * self.hook_distance
    self.vTargetPosition = self.vStartPosition + vDirection

    local flFollowthroughDuration = ( self.hook_distance / 10000 * self.hook_followthrough_constant )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_Kudes_GoldHook", { duration = flFollowthroughDuration } )

    self.vHookOffset = Vector( 0, 0, 96 )
    local vHookTarget = self.vTargetPosition + self.vHookOffset
    local vKillswitch = Vector( ( ( self.hook_distance / 10000 ) * 2 ), 0, 0 )

    self.nChainParticleFXIndex = ParticleManager:CreateParticle( "particles/pudge_meathook_2.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
    ParticleManager:SetParticleAlwaysSimulate( self.nChainParticleFXIndex )
    ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 1, vHookTarget )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 2, Vector( 10000, self.hook_distance, self.hook_width ) )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 3, vKillswitch )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 1, 0, 0 ) )
    ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 0, 0, 0 ) )
    ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetOrigin(), true )

	EmitSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )
    local info = {
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(),
        vVelocity = vDirection:Normalized() * 10000,
        fDistance = self.hook_distance,
        fStartRadius = self.hook_width ,
        fEndRadius = self.hook_width ,
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
    }
	ProjectileManager:CreateLinearProjectile( info )

    self.bRetracting = false
    self.hVictim = nil
    self.bDiedInHook = false
end

function Kudes_GoldHook:OnProjectileHit( hTarget, vLocation )
	if not IsServer() then return end
    if hTarget == self:GetCaster() then
        return false
    end

    if self.bRetracting == false then
        if hTarget ~= nil and ( not ( hTarget:IsCreep() or hTarget:IsConsideredHero() ) ) then
            print( "Target was invalid")
            return false
        end

        local bTargetPulled = false
        if hTarget ~= nil then
            if hTarget:HasModifier("modifier_Daniil_LaughingRush_debuff") or hTarget:HasModifier("modifier_modifier_eul_cyclone_birzha") then
                return false
            end
            if hTarget:GetUnitName() == "npc_dota_zerkalo" then return false end
            EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_Pudge.AttackHookImpact", self:GetCaster())

            hTarget:AddNewModifier( self:GetCaster(), self, "modifier_Kudes_GoldHook_debuff", nil )
            
            if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
                local damage = {
                        victim = hTarget,
                        attacker = self:GetCaster(),
                        damage = self.hook_damage,
                        damage_type = DAMAGE_TYPE_MAGICAL,     
                        ability = self
                    }

                if self:GetCaster():HasTalent("special_bonus_birzha_kudes_1") then
                	damage.damage_type = DAMAGE_TYPE_PURE
                end

                ApplyDamage( damage )

                if not hTarget:IsAlive() then
                    self.bDiedInHook = true
                end

                if not hTarget:IsMagicImmune() then
                    hTarget:Interrupt()
                end
        
                local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
                ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
                ParticleManager:ReleaseParticleIndex( nFXIndex )
            end

            AddFOWViewer( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), self.vision_radius, self.vision_duration, false )
            self.hVictim = hTarget
            bTargetPulled = true
        end

        local vHookPos = self.vTargetPosition
        local flPad = self:GetCaster():GetPaddedCollisionRadius()
        if hTarget ~= nil then
            vHookPos = hTarget:GetOrigin()
            flPad = flPad + hTarget:GetPaddedCollisionRadius()
        end

        local vVelocity = self.vStartPosition - vHookPos
        vVelocity.z = 0.0

        local flDistance = vVelocity:Length2D() - flPad
        vVelocity = vVelocity:Normalized() * 10000

        local info = {
            Ability = self,
            vSpawnOrigin = vHookPos,
            vVelocity = vVelocity,
            fDistance = flDistance,
            Source = self:GetCaster(),
        }

        ProjectileManager:CreateLinearProjectile( info )
        self.vProjectileLocation = vHookPos

        if hTarget ~= nil and ( not hTarget:IsInvisible() ) and bTargetPulled then
            ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin() + self.vHookOffset, true )
            ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 0, 0, 0 ) )
            ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 1, 0, 0 ) )
        else
            ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + self.vHookOffset, true);
        end

        if hTarget ~= nil then
            EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_Pudge.AttackHookRetract", self:GetCaster())
        end

        if self:GetCaster():IsAlive() then
            self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
            self:GetCaster():StartGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
        end

        self.bRetracting = true
    else
        if self:GetCaster() and self:GetCaster():IsHero() then
            local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
            if hHook ~= nil then
                hHook:RemoveEffects( EF_NODRAW )
            end
        end

        if self.hVictim ~= nil then
            local vFinalHookPos = vLocation
            self.hVictim:InterruptMotionControllers( true )
            self.hVictim:RemoveModifierByName( "modifier_Kudes_GoldHook_debuff" )

            local vVictimPosCheck = self.hVictim:GetOrigin() - vFinalHookPos 
            local flPad = self:GetCaster():GetPaddedCollisionRadius() + self.hVictim:GetPaddedCollisionRadius()
            if vVictimPosCheck:Length2D() > flPad then
                FindClearSpaceForUnit( self.hVictim, self.vStartPosition, false )
            end
        end

        self.hVictim = nil
        if self.nChainParticleFXIndex then
            ParticleManager:DestroyParticle( self.nChainParticleFXIndex, true )
        end
        EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", self:GetCaster() )
    end

    return true
end

function Kudes_GoldHook:OnProjectileThink( vLocation )
    self.vProjectileLocation = vLocation
end

function Kudes_GoldHook:OnOwnerDied()
    self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
    self:GetCaster():RemoveGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
end

modifier_Kudes_GoldHook = class({})

function modifier_Kudes_GoldHook:IsPurgable() return false end
function modifier_Kudes_GoldHook:IsHidden() return true end

function modifier_Kudes_GoldHook:IsHidden()
    return true
end

function modifier_Kudes_GoldHook:IsPurgable()
    return false
end

function modifier_Kudes_GoldHook:CheckState()
    local state = {
    [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

modifier_Kudes_GoldHook_debuff = class({})

function modifier_Kudes_GoldHook_debuff:IsPurgable() return false end
function modifier_Kudes_GoldHook_debuff:IsHidden() return true end

function modifier_Kudes_GoldHook_debuff:IsDebuff()
    return true
end

function modifier_Kudes_GoldHook_debuff:RemoveOnDeath()
    return false
end

function modifier_Kudes_GoldHook_debuff:IsPurgable()
    return false
end


function modifier_Kudes_GoldHook_debuff:OnCreated( kv )
    if not IsServer() then return end
    if self:ApplyHorizontalMotionController() == false then 
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_Kudes_GoldHook_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_Kudes_GoldHook_debuff:GetOverrideAnimation( params )
    return ACT_DOTA_FLAIL
end

function modifier_Kudes_GoldHook_debuff:CheckState()
   if not IsServer() then return end
    if self:GetCaster() ~= nil and self:GetParent() ~= nil then
        if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() and ( not self:GetParent():IsMagicImmune() ) then
            local state = {
            [MODIFIER_STATE_STUNNED] = true,
            }

            return state
        end
    end
    local state = {}
    return state
end

function modifier_Kudes_GoldHook_debuff:UpdateHorizontalMotion( me, dt )
	if not IsServer() then return end
    if self:GetAbility().hVictim ~= nil then
        self:GetAbility().hVictim:SetOrigin( self:GetAbility().vProjectileLocation )
        local vToCaster = self:GetAbility().vStartPosition - self:GetCaster():GetOrigin()
        local flDist = vToCaster:Length2D()
        if self:GetAbility().bChainAttached == false and flDist > 128.0 then 
            self:GetAbility().bChainAttached = true  
            ParticleManager:SetParticleControlEnt( self:GetAbility().nChainParticleFXIndex, 0, self:GetCaster(), PATTACH_CUSTOMORIGIN, "attach_hitloc", self:GetCaster():GetOrigin(), true )
            ParticleManager:SetParticleControl( self:GetAbility().nChainParticleFXIndex, 0, self:GetAbility().vStartPosition + self:GetAbility().vHookOffset )
        end                     
    end
end

function modifier_Kudes_GoldHook_debuff:OnHorizontalMotionInterrupted()
    if not IsServer() then return end
    if self:GetAbility().hVictim ~= nil then
        ParticleManager:SetParticleControlEnt( self:GetAbility().nChainParticleFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetAbsOrigin() + self:GetAbility().vHookOffset, true )
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

LinkLuaModifier("modifier_JumpInHead_arena","abilities/heroes/kudes.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_JumpInHead_arena_debuff","abilities/heroes/kudes.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kudes_leap", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_BOTH )

Kudes_JumpInHead = class({})

function Kudes_JumpInHead:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Kudes_JumpInHead:GetCastRange(location, target)
    local bonus_cast_range = 0
    if self:GetCaster():HasShard() then
        bonus_cast_range = 1100
    end
    return self.BaseClass.GetCastRange(self, location, target) + bonus_cast_range
end

function Kudes_JumpInHead:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Kudes_JumpInHead:GetAOERadius()
    return 300
end

function Kudes_JumpInHead:OnSpellStart()
	local caster = self:GetCaster()
	local position = caster:GetAbsOrigin()
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")
	local position_target = self:GetCursorPosition()
	local kv =
	{
		vLocX = position_target.x,
		vLocY = position_target.y,
		vLocZ = position_target.z
	}
	if not IsServer() then return end
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_kudes_leap", kv )
	ProjectileManager:ProjectileDodge(caster)
end

modifier_JumpInHead_arena = class({})
modifier_JumpInHead_arena_debuff = class({})

function modifier_JumpInHead_arena:IsPurgable() return false end
function modifier_JumpInHead_arena:IsHidden() return true end

function modifier_JumpInHead_arena_debuff:IsPurgable() return false end
function modifier_JumpInHead_arena_debuff:IsHidden() return true end

function modifier_JumpInHead_arena:OnCreated(kv)
	if not IsServer() then return end
	local caster = self:GetAbility():GetCaster()
	local pos = self:GetParent():GetAbsOrigin()
	local duration = self:GetDuration()-0.05
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	self.particle = ParticleManager:CreateParticle("particles/kudes/kudes_arena.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(self.particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, Vector(radius,0,0))
	ParticleManager:SetParticleControl(self.particle, 2, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 3, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 4, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 5, caster:GetAbsOrigin())

    self.targets = {}

	local entities = FindEntities(caster,pos,radius)

	for k,v in pairs(entities) do
		if v:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
			ApplyDamage({attacker = caster, victim = v, ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
            v:AddNewModifier(caster, self:GetAbility(), "modifier_JumpInHead_arena_debuff", {duration=duration + 1})
            table.insert(self.targets, v)
		end
	end

    local particle_damage = ParticleManager:CreateParticle("particles/kudes/arena_shard.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_damage, 0, self:GetParent():GetAbsOrigin())

	caster:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact")
	self:StartIntervalThink(0.03)
end

function modifier_JumpInHead_arena:OnDestroy()
    if not IsServer() then return end
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
    end
end

function modifier_JumpInHead_arena:OnIntervalThink()
	if not IsServer() then return end
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local damage = self:GetAbility():GetSpecialValueFor("damage_on_block")

    for _, target in pairs(self.targets) do
        if target:HasModifier("modifier_JumpInHead_arena_debuff") then
            local target_pos = target:GetAbsOrigin()
            local arena_pos = self:GetParent():GetAbsOrigin()
            local direction = ( target_pos - arena_pos ):Normalized()
            if target:IsMagicImmune() then
                local modifier = v:FindModifierByName("modifier_JumpInHead_arena_debuff")
                if modifier and not modifier:IsNull() then
                    modifier:Destroy()
                    return
                end
            end
            if ( target:GetRangeToUnit(self:GetParent()) > ( radius ) ) then
                ApplyDamage({attacker = self:GetCaster(), victim = target, ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_arena_of_blood_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
                ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
                target:EmitSound("Hero_Mars.Spear.Knockback")
                local new_point = GetGroundPosition((direction*(radius-100))+self:GetParent():GetAbsOrigin(), target)
                FindClearSpaceForUnit(target, new_point, true)
                target:Stop()
            end
        end
    end

    local enemies_out = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _, target in pairs(enemies_out) do
        if not target:HasModifier("modifier_JumpInHead_arena_debuff") then
            local target_pos = target:GetAbsOrigin()
            local arena_pos = self:GetParent():GetAbsOrigin()
            local direction = ( target_pos - arena_pos ):Normalized()
            ApplyDamage({attacker = self:GetCaster(), victim = target, ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_arena_of_blood_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
            target:EmitSound("Hero_Mars.Spear.Knockback")
            local new_point = GetGroundPosition((direction*(radius+200))+self:GetParent():GetAbsOrigin(), target)
            FindClearSpaceForUnit(target, new_point, true)
            target:Stop()
        end
    end
end

modifier_kudes_leap = class({})

function modifier_kudes_leap:IsHidden()
	return true
end

function modifier_kudes_leap:IsPurgable()
	return false
end

function modifier_kudes_leap:RemoveOnDeath()
	return false
end

function modifier_kudes_leap:OnCreated( kv )
	if IsServer() then
		self.bHorizontalMotionInterrupted = false
		self.bDamageApplied = false
		self.bTargetTeleported = false
		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
			if not self:IsNull() then
                self:Destroy()
            end
			return
		end
		self.vStartPosition = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )
		self.flCurrentTimeHoriz = 0.0
		self.flCurrentTimeVert = 0.0
		self.vLoc = Vector( kv.vLocX, kv.vLocY, kv.vLocZ )
		self.vLastKnownTargetPos = self.vLoc
		local duration = 0.3
		local flDesiredHeight = 200 * duration * duration
		local flLowZ = math.min( self.vLastKnownTargetPos.z, self.vStartPosition.z )
		local flHighZ = math.max( self.vLastKnownTargetPos.z, self.vStartPosition.z )
		local flArcTopZ = math.max( flLowZ + flDesiredHeight, flHighZ + 200 )
		local flArcDeltaZ = flArcTopZ - self.vStartPosition.z
		self.flInitialVelocityZ = math.sqrt( 2.0 * flArcDeltaZ * 10000 )
		local flDeltaZ = self.vLastKnownTargetPos.z - self.vStartPosition.z
		local flSqrtDet = math.sqrt( math.max( 0, ( self.flInitialVelocityZ * self.flInitialVelocityZ ) - 2.0 * 10000 * flDeltaZ ) )
		self.flPredictedTotalTime = math.max( ( self.flInitialVelocityZ + flSqrtDet) / 10000, ( self.flInitialVelocityZ - flSqrtDet) / 10000 )
		self.vHorizontalVelocity = ( self.vLastKnownTargetPos - self.vStartPosition ) / self.flPredictedTotalTime
		self.vHorizontalVelocity.z = 0.0
	end
end

function modifier_kudes_leap:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )
		self:GetParent():RemoveVerticalMotionController( self )
	end
end

function modifier_kudes_leap:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

function modifier_kudes_leap:CheckState()
	local state =
	{
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_kudes_leap:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		self.flCurrentTimeHoriz = math.min( self.flCurrentTimeHoriz + dt, self.flPredictedTotalTime )
		local t = self.flCurrentTimeHoriz / self.flPredictedTotalTime
		local vStartToTarget = self.vLastKnownTargetPos - self.vStartPosition
		local vDesiredPos = self.vStartPosition + t * vStartToTarget

		local vOldPos = me:GetOrigin()
		local vToDesired = vDesiredPos - vOldPos
		vToDesired.z = 0.0
		local vDesiredVel = vToDesired / dt
		local vVelDif = vDesiredVel - self.vHorizontalVelocity
		local flVelDif = vVelDif:Length2D()
		vVelDif = vVelDif:Normalized()
		local flVelDelta = math.min( flVelDif, 3000 )

		self.vHorizontalVelocity = self.vHorizontalVelocity + vVelDif * flVelDelta * dt
		local vNewPos = vOldPos + self.vHorizontalVelocity * dt
		me:SetOrigin( vNewPos )
	end
end

function modifier_kudes_leap:UpdateVerticalMotion( me, dt )
	if IsServer() then
		self.flCurrentTimeVert = self.flCurrentTimeVert + dt
		local bGoingDown = ( -10000 * self.flCurrentTimeVert + self.flInitialVelocityZ ) < 0
		
		local vNewPos = me:GetOrigin()
		vNewPos.z = self.vStartPosition.z + ( -0.5 * 10000 * ( self.flCurrentTimeVert * self.flCurrentTimeVert ) + self.flInitialVelocityZ * self.flCurrentTimeVert )

		local flGroundHeight = GetGroundHeight( vNewPos, self:GetParent() )
		local bLanded = false
		if ( vNewPos.z < flGroundHeight and bGoingDown == true ) then
			vNewPos.z = flGroundHeight
			bLanded = true
		end

		me:SetOrigin( vNewPos )
		if bLanded == true then
			if self.bHorizontalMotionInterrupted == false then
				self:GetParent():EmitSound("Hero_ElderTitan.EchoStomp")
				local duration = self:GetAbility():GetSpecialValueFor("duration")
				CreateModifierThinker( self:GetParent(), self:GetAbility(), "modifier_JumpInHead_arena", {duration = duration}, self:GetParent():GetAbsOrigin(), self:GetParent():GetTeamNumber(), false )
			end

			self:GetParent():RemoveHorizontalMotionController( self )
			self:GetParent():RemoveVerticalMotionController( self )

			self:SetDuration( 0.15, false)
		end
	end
end

function modifier_kudes_leap:OnHorizontalMotionInterrupted()
	if IsServer() then
		self.bHorizontalMotionInterrupted = true
	end
end

function modifier_kudes_leap:OnVerticalMotionInterrupted()
	if IsServer() then
		if not self:IsNull() then
            self:Destroy()
        end
	end
end

LinkLuaModifier( "modifier_Kudes_Fat", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_Kudes_Fat_shard", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE  )

Kudes_Fat = class({})

function Kudes_Fat:GetCooldown(level)
    if self:GetCaster():HasScepter() then 
        return 30
    end
    return 0
end

function Kudes_Fat:GetBehavior()
    local caster = self:GetCaster()
    if self:GetCaster():HasScepter() then 
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function Kudes_Fat:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Kudes_Fat_shard", {duration = 6})
    self:GetCaster():EmitSound("kudes_shard")
end

modifier_Kudes_Fat_shard = class({})

function modifier_Kudes_Fat_shard:IsPurgable() return true end

function modifier_Kudes_Fat_shard:OnCreated()
    if not IsServer() then return end
    self.particle_1 = "particles/units/heroes/hero_pangolier/pangolier_tailthump_buff.vpcf"
    self.particle_2 = "particles/units/heroes/hero_pangolier/pangolier_tailthump_buff_egg.vpcf"
    self.particle_3 = "particles/units/heroes/hero_pangolier/pangolier_tailthump_buff_streaks.vpcf"

    self.buff_particles = {}

    self.buff_particles[1] = ParticleManager:CreateParticle(self.particle_1, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.buff_particles[1], 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, Vector(0,0,0), false) 
    self:AddParticle(self.buff_particles[1], false, false, -1, true, false)
    ParticleManager:SetParticleControl( self.buff_particles[1], 3, Vector( 255, 255, 255 ) )

    self.buff_particles[2] = ParticleManager:CreateParticle(self.particle_2, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.buff_particles[2], 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, Vector(0,0,0), false) 
    self:AddParticle(self.buff_particles[2], false, false, -1, true, false)

    self.buff_particles[3] = ParticleManager:CreateParticle(self.particle_3, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.buff_particles[3], 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, Vector(0,0,0), false) 
    self:AddParticle(self.buff_particles[3], false, false, -1, true, false)

end

modifier_Kudes_Fat = class({})

function Kudes_Fat:GetIntrinsicModifierName()
    return "modifier_Kudes_Fat"
end

function modifier_Kudes_Fat:IsPurgable()
	return false
end


function modifier_Kudes_Fat:OnCreated()
	self.hp_stack = self:GetAbility():GetSpecialValueFor( "hp_stack" )

    if IsServer() then
        self:SetStackCount( 1 )
		self:StartIntervalThink(0.1) 
    end
end

function modifier_Kudes_Fat:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local oldStackCount = self:GetStackCount()
		local health_one_percent = caster:GetMaxHealth() / 100 * self.hp_stack
		local stack = math.floor(caster:GetHealth() / health_one_percent)

		if not self:GetCaster():HasTalent("special_bonus_birzha_kudes_3") then
			if self:GetCaster():PassivesDisabled() then 
				self:SetStackCount( 0 )
				self:ForceRefresh()	
				return
			end
		end

    	self:SetStackCount( stack )
    	self:ForceRefresh()		
	end
end

function modifier_Kudes_Fat:OnRefresh()
	self.damage_armor = self:GetAbility():GetSpecialValueFor( "damage_min" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_2")
	local StackCount = self:GetStackCount()
	local caster = self:GetParent()

    if IsServer() then
        self:GetParent():CalculateStatBonus(true)
    end
end

function modifier_Kudes_Fat:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}

	return funcs
end

function modifier_Kudes_Fat:GetModifierIncomingDamage_Percentage( params )
    local multi = 1
    if self:GetCaster():HasModifier('modifier_Kudes_Fat_shard') then
        multi = 2
    end
    print(multi)
	return self:GetStackCount() * self.damage_armor * multi
end

LinkLuaModifier( "modifier_Kudes_Items", "abilities/heroes/kudes.lua", LUA_MODIFIER_MOTION_NONE  )

Kudes_Items = class({})

modifier_Kudes_Items = class({})

function Kudes_Items:GetIntrinsicModifierName()
    return "modifier_Kudes_Items"
end

function modifier_Kudes_Items:IsPurgable()
	return false
end

function modifier_Kudes_Items:OnCreated()
	self.gold_attribute = self:GetAbility():GetSpecialValueFor( "attribute" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_4")

    if IsServer() then
        self:SetStackCount( 1 )
		self:GetParent():CalculateStatBonus(true)
		self:StartIntervalThink(0.1) 
    end
end

function modifier_Kudes_Items:OnIntervalThink()
	if IsServer() then
        local item_stack = {
            "item_ward_observer",
            "item_ward_sentry",
            "item_ward_dispenser",
            "item_tango",
            "item_dust",
            "item_clarity",
            "item_flask",
            "item_bond",
            "item_burger_sobolev",
            "item_burger_oblomoff",
            "item_burger_larin"
        }
		self.gold = self:GetAbility():GetSpecialValueFor( "gold" ) 
		local caster = self:GetParent()
		local oldStackCount = self:GetStackCount()

		local price = 0
	    for i = 0, 5 do 
	        local item = caster:GetItemInSlot(i)
            if item then
                local item_price = item:GetCost()
                for _,item_stac in pairs(item_stack) do
                    if item:GetName() == item_stac then
                        item_price = 0
                    end
                end
                price = price + item_price
           	end        
	    end
		local stack = price / self.gold

    	self:SetStackCount( stack )
    	self:ForceRefresh()		
	end
end

function modifier_Kudes_Items:OnRefresh()
	self.gold_attribute = self:GetAbility():GetSpecialValueFor( "attribute" ) + self:GetCaster():FindTalentValue("special_bonus_birzha_kudes_4")
	local StackCount = self:GetStackCount()
	local caster = self:GetParent()

    if IsServer() then
        self:GetParent():CalculateStatBonus(true)
    end
end

function modifier_Kudes_Items:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}

	return funcs
end

function modifier_Kudes_Items:GetModifierBonusStats_Strength ( params )
	return self:GetStackCount() * self.gold_attribute
end

function modifier_Kudes_Items:GetModifierBonusStats_Agility ( params )
	return self:GetStackCount() * self.gold_attribute
end

function modifier_Kudes_Items:GetModifierBonusStats_Intellect ( params )
	return self:GetStackCount() * self.gold_attribute
end


