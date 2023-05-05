LinkLuaModifier("modifier_blinoid_shop_move", "modifiers/modifier_blinoid_shop", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_blinoid_shop_sound", "modifiers/modifier_blinoid_shop", LUA_MODIFIER_MOTION_BOTH)

modifier_blinoid_shop = class({})

function modifier_blinoid_shop:IsHidden()
	return true
end

function modifier_blinoid_shop:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_blinoid_shop:OnIntervalThink()
	if not IsServer() then return end
	local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 75, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	if #targets > 0 then
		local distance = (self:GetParent():GetAbsOrigin() - targets[1]:GetAbsOrigin()):Length2D()
		local direction = self:GetParent():GetAbsOrigin() - targets[1]:GetAbsOrigin()
		direction.z = 0
		direction = direction:Normalized()
		self:GetParent():SetForwardVector(direction)
		if not self:GetParent():HasModifier("modifier_generic_knockback_lua") then
			self:GetParent():RemoveModifierByName("modifier_blinoid_shop_move")
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_blinoid_shop_move", {duration = 2.5})
			local knockback = self:GetParent():AddNewModifier( self:GetParent(), nil, "modifier_generic_knockback_lua", { duration = 0.25, distance = 300, direction_x = direction.x, direction_y = direction.y, IsFlail = false } )
			if not self:GetParent():HasModifier("modifier_blinoid_shop_sound") then
				self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_blinoid_shop_sound", {duration = 3})
				self:GetParent():EmitSound("blinoid_attack")
			end
		end
	end
end

function modifier_blinoid_shop:CheckState()
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

function modifier_blinoid_shop:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove(self:GetParent())
end

modifier_blinoid_shop_sound = class({})

function modifier_blinoid_shop_sound:IsHidden() return true end
function modifier_blinoid_shop_sound:IsPurgable() return false end

modifier_blinoid_shop_move = class({})

function modifier_blinoid_shop_move:IsHidden()
	return true
end

function modifier_blinoid_shop_move:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_blinoid_shop_move:OnIntervalThink()
    if self:GetParent():IsAncient() then return end
    local forward = self:GetParent():GetForwardVector()
    forward.z = 0
    local origin = self:GetParent():GetAbsOrigin() + forward * ((500 * self:GetRemainingTime()) * FrameTime())
    origin = GetGroundPosition(origin, self:GetParent())

    if not GridNav:CanFindPath(self:GetParent():GetAbsOrigin(), origin) then
    	local direction = self:GetParent():GetAbsOrigin() - origin
    	direction.z = 0
    	direction = direction:Normalized()
    	self:GetParent():SetForwardVector(direction)
    	return
    end

    if self:GetParent():HasModifier("modifier_generic_knockback_lua") then return end
    self:GetParent():SetAbsOrigin(origin)
end