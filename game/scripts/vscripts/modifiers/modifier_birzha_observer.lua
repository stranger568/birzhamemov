LinkLuaModifier("modifier_birzha_observer_animation_idle", "modifiers/modifier_birzha_observer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_birzha_observer_animation_sleep", "modifiers/modifier_birzha_observer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_birzha_observer_animation_cast", "modifiers/modifier_birzha_observer", LUA_MODIFIER_MOTION_NONE)

TEAMS_COLORS = 
{
	[DOTA_TEAM_GOODGUYS] = Vector(61, 210, 150),
	[DOTA_TEAM_BADGUYS]  = Vector(243, 201, 9),
	[DOTA_TEAM_CUSTOM_1] = Vector(197, 77, 168),
	[DOTA_TEAM_CUSTOM_2] = Vector(255, 108, 0),
	[DOTA_TEAM_CUSTOM_3] = Vector(52, 85, 255),
	[DOTA_TEAM_CUSTOM_4] = Vector(101, 212, 19),
	[DOTA_TEAM_CUSTOM_5] = Vector(129, 83, 54),
	[DOTA_TEAM_CUSTOM_6] = Vector(27, 192, 216),
	[DOTA_TEAM_CUSTOM_7] = Vector(199, 228, 13),
	[DOTA_TEAM_CUSTOM_8] = Vector(140, 42, 244),
	[DOTA_TEAM_NEUTRALS] = Vector(220,220,220),
}

modifier_birzha_observer = class({})
function modifier_birzha_observer:IsHidden() return false end
function modifier_birzha_observer:IsPurgable() return false end
function modifier_birzha_observer:DestroyOnExpire() return false end

function modifier_birzha_observer:OnCreated(kv)
	if IsServer() then
		local parent = self:GetParent()
		self.rate = 0
		self.progress = 0
		self.current_team = -1
		self.num_heroes = 1
		self:StartSearch()
		self:ChangeAnimation("sleep")
	else
		self:StartIntervalThink(0)
	end
end

function modifier_birzha_observer:IsAura()
    return true
end

function modifier_birzha_observer:GetAuraRadius()
    return 600
end

function modifier_birzha_observer:GetModifierAura()
    return "modifier_truesight"
end
   
function modifier_birzha_observer:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_birzha_observer:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_birzha_observer:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_birzha_observer:GetAuraDuration()
    return 0
end

function modifier_birzha_observer:StartSearch()
	if self.ring_fx then return end
	local parent = self:GetParent()
    self:ReloadParticleSearch()
	self.vPosition = parent:GetAbsOrigin()
	self:StartIntervalThink(0)
	self:SetHasCustomTransmitterData(true)
end

function modifier_birzha_observer:ReloadParticleSearch()
    if self.ring_fx == nil then
	    self.ring_fx = ParticleManager:CreateParticle("particles/shrine/capture_point_ring_overthrow.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	    local pos = GetGroundPosition(self:GetParent():GetAbsOrigin(), nil)
	    ParticleManager:SetParticleControl(self.ring_fx, 0, pos)
	    ParticleManager:SetParticleControl(self.ring_fx, 3, Vector(220,220,220))
	    ParticleManager:SetParticleControl(self.ring_fx, 9, Vector(250, 0, 0))
    end
end

local function dt(rate)
	return GameRules:GetGameFrameTime() * rate
end

function modifier_birzha_observer:ValidCapturingUnit(unit)
	if unit:IsInvulnerable() then return false end
	if unit:IsRealHero() then
		return true
	else
		return false
	end
end

function modifier_birzha_observer:OnIntervalThink()
    if IsServer() then
        local targets = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, self.vPosition, nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false )
        self.heroes_in_radius = {}
        local total_heroes_counts = 0
        local teams_count = 0
		local temp_team = DOTA_TEAM_NEUTRALS

        -- Количество героев
		for _, target in pairs(targets) do
			if self:ValidCapturingUnit(target) then
				if not self.heroes_in_radius[target:GetTeamNumber()] then
					self.heroes_in_radius[target:GetTeamNumber()] = {}
				end
				table.insert(self.heroes_in_radius[target:GetTeamNumber()], target)
				total_heroes_counts = total_heroes_counts + 1
			end
		end

        -- Количество команд
        for team_number, units in pairs(self.heroes_in_radius) do
			temp_team = team_number
			teams_count = teams_count + 1
		end

        -- Проверка зяблов
        local should_refresh = false
		local is_contesting = teams_count > 1
		if self.is_contesting ~= is_contesting then
			self.is_contesting = is_contesting
			should_refresh = true
		end
		local is_capturing = teams_count == 1
		if self.is_capturing ~= is_capturing then
			self.is_capturing = is_capturing
			should_refresh = true
		end
		local is_recapturing = self.current_team ~= temp_team and self.progress > 0
		if self.is_recapturing ~= is_recapturing then
			self.is_recapturing = is_recapturing
			should_refresh = true
		end
		local num_heroes = 0
		if self.heroes_in_radius[temp_team] then
			num_heroes = #self.heroes_in_radius[temp_team]
		end
		if self.num_heroes ~= num_heroes then
			self.num_heroes = num_heroes
			should_refresh = true
		end

        -- Скорость
        local rate = 0
        if not self:IsCaptured(self.current_team) then
            if not is_contesting then
                if is_capturing then
                    if self.progress < 1 then
                        self:ChangeAnimation("cast")
                    end
                    if self.current_team == DOTA_TEAM_NEUTRALS then
                        self.current_team = temp_team
                        self:UpdateRingColor()
                        should_refresh = true
                    end
                    rate = 1 / 0.75
                    self.progress = self.progress + dt(rate)
                    if self.progress >= 1 then
                        self:CaptureObserver(self.current_team)
                    end
                else
                    self.progress = 0
                end
            else
                self.progress = 0
            end
        else
            if self.progress > 0 then
                rate = -(1 / 60)
                self.progress = Clamp(self.progress + dt(rate), 0, 1)
            end
        end

        -- Апдейты
        if self.progress <= 0 and self.current_team ~= DOTA_TEAM_NEUTRALS then
			self.current_team = DOTA_TEAM_NEUTRALS
			self:UpdateRingColor()
			should_refresh = true
			self:ChangeAnimation("sleep")
			self:GetParent():SetTeam(self.current_team)
            if self.effect then 
                ParticleManager:DestroyParticle(self.effect, false)
                ParticleManager:ReleaseParticleIndex(self.effect)
                self.effect = nil
            end 
            self:ReloadParticleSearch()
            self:GetParent():EmitSound("watcher_reset")
		end
		if rate ~= self.rate then
			self.rate = rate
			should_refresh = true
		end
		if should_refresh then
			self:ForceRefresh()
		end
    else
		if self.clock_fx and self.capturing_fx then
			self.progress = Clamp(self.progress + dt(self.rate), 0, 1)
			if self.progress <= 0 then
				ParticleManager:DestroyParticle(self.capturing_fx, false)
				ParticleManager:ReleaseParticleIndex(self.capturing_fx)
				self.capturing_fx = nil
				ParticleManager:DestroyParticle(self.clock_fx, false)
				ParticleManager:ReleaseParticleIndex(self.clock_fx)
				self.clock_fx = nil
				return
			end

			ParticleManager:SetParticleControl(self.clock_fx, 17, Vector(self.progress, 0, 0))
		end
	end
end

function modifier_birzha_observer:AddCustomTransmitterData()
	local data = 
	{
		is_capturing = self.is_capturing,
		is_contesting = self.is_contesting,
		is_recapturing = self.is_recapturing,
		progress = self.progress,
		current_team = self.current_team,
		num_heroes = self.num_heroes,
		rate = self.rate,
	}
	return data
end

function modifier_birzha_observer:HandleCustomTransmitterData( data )
	self.is_contesting = data.is_contesting
	self.is_capturing = data.is_capturing
	self.is_recapturing = data.is_recapturing
	self.progress = data.progress
	self.num_heroes = data.num_heroes
	self.rate = data.rate
	if data.is_capturing == 1 and data.current_team ~= -1 then
		if not self.capturing_fx then
			self.capturing_fx = ParticleManager:CreateParticle("particles/shrine/capture_point_ring_capturing.vpcf", PATTACH_ABSORIGIN, self:GetParent())
			ParticleManager:SetParticleControl(self.capturing_fx, 9, Vector(250, 0, 0))
		end
		ParticleManager:SetParticleControl(self.capturing_fx, 3, TEAMS_COLORS[data.current_team])
		if not self.clock_fx then
			self.clock_fx = ParticleManager:CreateParticle("particles/shrine/capture_point_ring_clock_overthrow.vpcf", PATTACH_ABSORIGIN, self:GetParent())
			ParticleManager:SetParticleControl(self.clock_fx, 9, Vector(250, 0, 0))
			ParticleManager:SetParticleControl(self.clock_fx, 11, Vector(0, 0, 1))
		end
		ParticleManager:SetParticleControl(self.clock_fx, 3, TEAMS_COLORS[data.current_team])
		ParticleManager:SetParticleControl(self.clock_fx, 17, Vector(self.progress, 0, 0))
	end
end

function modifier_birzha_observer:UpdateRingColor()
	if self.current_team and self.current_team >= DOTA_TEAM_GOODGUYS then
        if self.ring_fx then
		    ParticleManager:SetParticleControl(self.ring_fx, 3, TEAMS_COLORS[self.current_team])
        end
	end
end

function modifier_birzha_observer:OnDestroy()
	local particles = 
	{
		self.clock_fx,
		self.capturing_fx,
		self.ring_fx,
	}
	for _, particle in pairs(particles) do
		if particle then
			ParticleManager:DestroyParticle(particle, false)
			ParticleManager:ReleaseParticleIndex(particle)
		end
	end
	if not IsServer() then return end
	local parent = self:GetParent()
end

function modifier_birzha_observer:CaptureObserver(team_number)
	if not IsServer() then return end
	self:GetParent():SetTeam(team_number)
    if self.ring_fx then
        ParticleManager:DestroyParticle(self.ring_fx, false)
        ParticleManager:ReleaseParticleIndex(self.ring_fx)
        self.ring_fx = nil
    end
    local AllHeroes = HeroList:GetAllHeroes()
    for count, hero in ipairs(AllHeroes) do
        if hero:GetTeam() == team_number and hero:IsRealHero() then
            hero:ModifyGold( 100, true, 0 )
            SendOverheadEventMessage(hero, 0, hero, 100, nil)
        end
    end

    if self.effect then return end 
    self:GetParent():EmitSound("watcher_captured")
    self.effect = ParticleManager:CreateParticle("particles/econ/items/items_fx/lantern_of_sight_controlled.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.effect, 11, Vector(600,0,0))
    ParticleManager:SetParticleControl(self.effect, 12, Vector(0,0,0))
end

function modifier_birzha_observer:IsCaptured(team_number)
	if team_number == DOTA_TEAM_NEUTRALS then
		self:ChangeAnimation("sleep")
		return false
	end
	if self:GetParent():GetTeamNumber() == team_number then
		self:ChangeAnimation("idle")
		return true
	end
	return false
end

function modifier_birzha_observer:CheckState()
	return 
	{
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
	}
end

function modifier_birzha_observer:ChangeAnimation(anim)
	if not IsServer() then return end

	if anim ~= "idle" then
		self:GetParent():RemoveModifierByName("modifier_birzha_observer_animation_idle")
	end
	if anim == "idle" and not self:GetParent():HasModifier("modifier_birzha_observer_animation_idle") then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_birzha_observer_animation_idle", {})
	end
	if anim ~= "sleep" then
		self:GetParent():RemoveModifierByName("modifier_birzha_observer_animation_sleep")
	end
	if anim == "sleep" and not self:GetParent():HasModifier("modifier_birzha_observer_animation_sleep") then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_birzha_observer_animation_sleep", {})
	end
	if anim ~= "cast" then
		self:GetParent():RemoveModifierByName("modifier_birzha_observer_animation_cast")
	end
	if anim == "cast" and not self:GetParent():HasModifier("modifier_birzha_observer_animation_cast") then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_birzha_observer_animation_cast", {})
	end
end

modifier_birzha_observer_animation_idle = class({})
function modifier_birzha_observer_animation_idle:IsHidden() return true end
function modifier_birzha_observer_animation_idle:IsPurgable() return false end
function modifier_birzha_observer_animation_idle:IsPurgeException() return false end
function modifier_birzha_observer_animation_idle:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end
function modifier_birzha_observer_animation_idle:GetOverrideAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_2
end

modifier_birzha_observer_animation_sleep = class({})
function modifier_birzha_observer_animation_sleep:IsHidden() return true end
function modifier_birzha_observer_animation_sleep:IsPurgable() return false end
function modifier_birzha_observer_animation_sleep:IsPurgeException() return false end
function modifier_birzha_observer_animation_sleep:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end
function modifier_birzha_observer_animation_sleep:GetOverrideAnimation()
	return ACT_DOTA_IDLE
end

modifier_birzha_observer_animation_cast = class({})
function modifier_birzha_observer_animation_cast:IsHidden() return true end
function modifier_birzha_observer_animation_cast:IsPurgable() return false end
function modifier_birzha_observer_animation_cast:IsPurgeException() return false end
function modifier_birzha_observer_animation_cast:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end
function modifier_birzha_observer_animation_cast:GetOverrideAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_1
end

