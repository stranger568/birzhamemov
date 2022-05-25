LinkLuaModifier("modifier_penguin_shop_move", "modifiers/modifier_penguin_shop", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_penguin_shop_knockback", "modifiers/modifier_penguin_shop", LUA_MODIFIER_MOTION_BOTH)

modifier_penguin_shop = class({})

function modifier_penguin_shop:IsHidden()
	return true
end

function modifier_penguin_shop:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_penguin_shop:OnIntervalThink()
	if not IsServer() then return end
	local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 100, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	if #targets > 0 then
		local distance = (self:GetParent():GetAbsOrigin() - targets[1]:GetAbsOrigin()):Length2D()
		local direction = (self:GetParent():GetAbsOrigin() - targets[1]:GetAbsOrigin()):Normalized()
		direction.z = 0
		self:GetParent():SetForwardVector(direction)
		self:GetParent():RemoveModifierByName("modifier_penguin_shop_knockback")
		self:GetParent():AddNewModifier( self:GetParent(), nil, "modifier_penguin_shop_knockback", { duration = 0.25, distance = 300, direction_x = direction.x, direction_y = direction.y, IsFlail = false, } )
	end
end

function modifier_penguin_shop:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
    }

    return state
end

function modifier_penguin_shop:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_penguin_shop:GetOverrideAnimation()
	return ACT_DOTA_SLIDE_LOOP
end

function modifier_penguin_shop:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove(self:GetParent())
end

modifier_penguin_shop_move = class({})

function modifier_penguin_shop_move:IsHidden()
	return true
end

function modifier_penguin_shop_move:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_penguin_shop_move:OnIntervalThink()
    if self:GetParent():IsAncient() then return end
    local forward = self:GetParent():GetForwardVector()
    forward.z = 0
    local origin = self:GetParent():GetAbsOrigin() + forward * (20 * self:GetRemainingTime())
    origin = GetGroundPosition(origin, self:GetParent())

    if not GridNav:CanFindPath(self:GetParent():GetAbsOrigin(), origin) then
    	local direction = (self:GetParent():GetAbsOrigin() - origin):Normalized()
    	self:GetParent():SetForwardVector(direction)
    	return
    end
    self:GetParent():SetAbsOrigin(origin)
end

function modifier_penguin_shop_move:OnDestroy()
	if not IsServer() then return end
	local forward = self:GetParent():GetForwardVector()
    forward.z = 0
	self:GetParent():SetForwardVector(forward)
end

modifier_penguin_shop_knockback = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_penguin_shop_knockback:IsHidden()
	return true
end

function modifier_penguin_shop_knockback:IsPurgable()
	return false
end

function modifier_penguin_shop_knockback:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_penguin_shop_knockback:OnCreated( kv )
	if IsServer() then
		-- creation data (default)
			-- kv.distance (0)
			-- kv.height (-1)
			-- kv.duration (0)
			-- kv.direction_x, kv.direction_y, kv.direction_z (xy:-forward vector, z:0)
			-- kv.tree_destroy_radius (hull-radius), can be null if -1 
			-- kv.IsStun (false)
			-- kv.IsFlail (true)
			-- kv.IsPurgable() // later 
			-- kv.IsMultiple() // later

		-- references

		self:GetParent():RemoveModifierByName("modifier_penguin_shop_move")

		self.distance = kv.distance or 0
		self.height = kv.height or -1
		self.duration = kv.duration or 0
		self.direction = Vector(kv.direction_x,kv.direction_y,0):Normalized()

		self.tree = kv.tree_destroy_radius or self:GetParent():GetHullRadius()

		if kv.IsStun then self.stun = kv.IsStun==1 else self.stun = false end
		if kv.IsFlail then self.flail = kv.IsFlail==1 else self.flail = true end

		-- check duration
		if self.duration == 0 then
			self:Destroy()
			return
		end

		-- load data
		self.parent = self:GetParent()
		self.origin = self.parent:GetOrigin()

		-- horizontal init
		self.hVelocity = self.distance/self.duration

		-- vertical init
		local half_duration = self.duration/2
		self.gravity = 2*self.height/(half_duration*half_duration)
		self.vVelocity = self.gravity*half_duration

		-- apply motion controllers
		if self.distance>0 then
			if self:ApplyHorizontalMotionController() == false then 
				self:Destroy()
				return
			end
		end
		if self.height>=0 then
			if self:ApplyVerticalMotionController() == false then 
				self:Destroy()
				return
			end
		end

		-- tell client of activity
		if self.flail then
			self:SetStackCount( 1 )
		elseif self.stun then
			self:SetStackCount( 2 )
		end
	else
		self.anim = self:GetStackCount()
		self:SetStackCount( 0 )
	end
end

function modifier_penguin_shop_knockback:OnRefresh( kv )
	if not IsServer() then return end
end

function modifier_penguin_shop_knockback:OnDestroy( kv )
	if not IsServer() then return end

	if not self.interrupted then

	end

	if self.EndCallback then
		self.EndCallback( self.interrupted )
	end

	self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_penguin_shop_move", {duration = 1})

	self:GetParent():InterruptMotionControllers( true )
end

--------------------------------------------------------------------------------
-- Setter
function modifier_penguin_shop_knockback:SetEndCallback( func ) 
	self.EndCallback = func
end

function modifier_penguin_shop_knockback:UpdateHorizontalMotion( me, dt )
	local parent = self:GetParent()

	local target = self.direction*self.distance*(dt/self.duration)

    if not GridNav:CanFindPath(self:GetParent():GetAbsOrigin(), target) then
		self.interrupted = true
		self:Destroy()
    	return
    end

	parent:SetOrigin( parent:GetOrigin() + target )
end

function modifier_penguin_shop_knockback:OnHorizontalMotionInterrupted()
	if IsServer() then
		self.interrupted = true
		self:Destroy()
	end
end

function modifier_penguin_shop_knockback:UpdateVerticalMotion( me, dt )
	-- set time
	local time = dt/self.duration

	-- change height
	self.parent:SetOrigin( self.parent:GetOrigin() + Vector( 0, 0, self.vVelocity*dt ) )

	-- calculate vertical velocity
	self.vVelocity = self.vVelocity - self.gravity*dt
end

function modifier_penguin_shop_knockback:OnVerticalMotionInterrupted()
	if IsServer() then
		self.interrupted = true
		self:Destroy()
	end
end