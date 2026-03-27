LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_travoman_land_mines", "abilities/heroes/travoman", LUA_MODIFIER_MOTION_NONE)

travoman_land_mines = class({})

function travoman_land_mines:Precache(context)
    PrecacheResource("model", "models/travoman/travoman_head.vmdl", context)
    local particle_list = 
    {
        "particles/econ/items/techies/techies_arcana/techies_land_mine_arcana.vpcf",
        "particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf",
        "particles/econ/items/techies/techies_arcana/techies_stasis_trap_arcana.vpcf",
        "particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf",
        "particles/status_fx/status_effect_techies_stasis.vpcf",
        "particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf",
        "particles/econ/items/techies/techies_arcana/techies_suicide_arcana.vpcf",
        "particles/units/heroes/hero_techies/techies_blast_off.vpcf",
        "particles/generic_gameplay/generic_silence.vpcf",
        "particles/travoman_plant_arcana.vpcf",
        "particles/econ/items/techies/techies_arcana/techies_remote_mine_arcana.vpcf",
        "particles/ui_mouseactions/range_display.vpcf",
        "particles/econ/items/techies/techies_arcana/techies_remote_mines_detonate_arcana.vpcf",
    }
    for _, particle_name in pairs(particle_list) do
        PrecacheResource("particle", particle_name, context)
    end
end

function travoman_land_mines:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function travoman_land_mines:GetCastRange(location, target)
    if self:GetCaster():HasScepter() then
        return self.BaseClass.GetCastRange(self, location, target) + self:GetSpecialValueFor("cast_range_scepter_bonus")
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

travoman_land_mines.mine_sausage = {}

function travoman_land_mines:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    if point == self:GetCaster():GetAbsOrigin() then
        point = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector()
    end
	self:GetCaster():EmitSound("travoman_cast_red")

    if self:GetCaster():HasTalent("special_bonus_birzha_nameplate_duplication_mines") then
        local npc_dota_travoman_minefield_sign = nil
        local travoman_signs = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
        for _, sign_search in pairs(travoman_signs) do
            if sign_search and sign_search:GetUnitName() == "npc_dota_travoman_minefield_sign" then
                self:CreateMine(sign_search:GetAbsOrigin() + RandomVector(RandomInt(50, 100)))
            end
        end
    end

    local shard_activate = false
    
    if self:GetCaster():HasShard() then
        local travoman_sausage = self:GetCaster():FindAbilityByName("travoman_sausage")
        if travoman_sausage and travoman_sausage:GetLevel() > 0 and travoman_sausage:IsFullyCastable() and self:GetAutoCastState() == false then
            shard_activate = true
            local direction = point - self:GetCaster():GetAbsOrigin()
            direction.z = 0
            direction = direction:Normalized()
            local distance = 150
            local bonus = 0
            if travoman_sausage.bonus ~= nil then
                bonus = travoman_sausage.bonus
                travoman_sausage.bonus = math.min(travoman_sausage.bonus + 1, 20)
            else
                travoman_sausage.bonus = 1
            end
            if travoman_land_mines.mine_sausage then
                for _, mine in pairs(travoman_land_mines.mine_sausage) do
                    if mine and not mine:IsNull() and mine:IsAlive() then
                        UTIL_Remove(mine)
                    end
                end
                travoman_land_mines.mine_sausage = {}
            end
            for i=1, 10+bonus do
                local new_point = self:GetCaster():GetAbsOrigin() + direction * (i * distance)
                if i % 5 == 0 then
                    local travoman_stasis_trap = self:GetCaster():FindAbilityByName("travoman_stasis_trap")
                    if travoman_stasis_trap and travoman_stasis_trap:GetLevel() > 0 then
                        local planted_mine = travoman_stasis_trap:CreateMine(new_point)
                        if planted_mine then
                            table.insert(self.mine_sausage, planted_mine)
                        end
                    end
                elseif RollPercentage(50) then
                    local travoman_remote_mines = self:GetCaster():FindAbilityByName("travoman_remote_mines")
                    if travoman_remote_mines and travoman_remote_mines:GetLevel() > 0 then
                        local planted_mine = travoman_remote_mines:CreateMine(new_point)
                        if planted_mine then
                            table.insert(self.mine_sausage, planted_mine)
                        end
                    end
                else
                    local planted_mine = self:CreateMine(new_point)
                    if planted_mine then
                        table.insert(self.mine_sausage, planted_mine)
                    end
                end
            end
            travoman_sausage:UseResources(false, false, false, true)
        end
    end
    if not shard_activate then
        self:CreateMine(point)
    end
end

function travoman_land_mines:CreateMine(point)
    self:GetCaster():EmitSound("Hero_Techies.RemoteMine.Plant")
    self:GetCaster():EmitSound("travoman_cast_red")
    local mine = CreateUnitByName("travoman_land_mine", point, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
    mine:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)

    mine:AddNewModifier(self:GetCaster(), self, "modifier_travoman_land_mines", {})
    return mine
end

function travoman_land_mines:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_extra_mines_land_mine" )
end

modifier_travoman_land_mines = class({})

function modifier_travoman_land_mines:IsPurgable() return false end
function modifier_travoman_land_mines:IsHidden() return true end

function modifier_travoman_land_mines:OnCreated()
    if not IsServer() then return end

    local delay_mine = self:GetAbility():GetSpecialValueFor("proximity_threshold")
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.sound = true
    self.gogo_damage = 0
    self.activation_delay = self:GetAbility():GetSpecialValueFor("activation_delay")

    local particle_mine_fx = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_land_mine_arcana.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle_mine_fx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_mine_fx, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle_mine_fx, false, false, -1, false, false)

    self:StartIntervalThink(FrameTime())
end

function modifier_travoman_land_mines:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetParent():IsAlive() then return end

    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )

    if #enemies <= 0 then
        self.gogo_damage = 0
        self.sound = true
        return
    end

    if self.sound and not self:GetCaster():HasTalent("special_bonus_birzha_travoman_land_mine_no_sounds") then
        self.sound = false
        EmitSoundOn("Hero_Techies.StickyBomb.Priming", self:GetParent())
    end

    for _, hero in pairs(enemies) do
        self:GetParent():AddNewModifier(hero, self:GetAbility(), "modifier_truesight", {duration = FrameTime()+FrameTime()})
    end

    if #enemies > 0 then
        self.gogo_damage = self.gogo_damage + FrameTime()
    end

    if self.gogo_damage >= self.activation_delay + self:GetCaster():FindTalentValue("special_bonus_birzha_delay_before_explosion_land_mine") then
        self:Explosion()
    end
end

function modifier_travoman_land_mines:Explosion()
    if not IsServer() then return end

    -- self:GetParent():EmitSound("travoman_land_boom")
	-- EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Techies.StickyBomb.Detonate", self:GetCaster())
	EmitSoundOn("Hero_Techies.StickyBomb.Detonate", self:GetParent())

    local particle_explosion_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_explosion_fx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_explosion_fx, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_explosion_fx, 2, Vector(self.radius, 1, 1))
    ParticleManager:ReleaseParticleIndex(particle_explosion_fx)

    local flag = 0
    local damage_type = DAMAGE_TYPE_MAGICAL

    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, FIND_ANY_ORDER, false)

    for _,enemy in pairs(enemies) do
        ApplyDamage({ victim = enemy, attacker = self:GetCaster(), damage = self.damage, damage_type = damage_type, ability = self:GetAbility(), damage_flags = DOTA_DAMAGE_FLAG_REFLECTION, })
    end

    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self.radius, 1, false)

    self:GetParent():ForceKill(false)
    self:Destroy()
end

function modifier_travoman_land_mines:CheckState()
    local state = 
    {
		[MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ROOTED] = not self:GetCaster():HasTalent("special_bonus_birzha_travoman_move_mines"),
    }
    return state
end

function modifier_travoman_land_mines:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return decFuncs
end

function modifier_travoman_land_mines:GetModifierMoveSpeed_Absolute()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_travoman_move_mines")
end

function modifier_travoman_land_mines:GetModifierIncomingDamage_Percentage()
    return -100
end

function modifier_travoman_land_mines:OnTakeDamage(keys)
    local unit = keys.unit
    local attacker = keys.attacker
    if keys.inflictor ~= nil then return end
    if unit == self:GetParent() then
        self:GetParent():Kill(self:GetAbility(), attacker)
    end
end

function modifier_travoman_land_mines:GetPriority()
    return MODIFIER_PRIORITY_NORMAL
end


LinkLuaModifier( "modifier_travoman_stasis_trap", "abilities/heroes/travoman", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_travoman_stasis_trap_debuff", "abilities/heroes/travoman", LUA_MODIFIER_MOTION_NONE)

travoman_stasis_trap = class({})

function travoman_stasis_trap:GetCastRange(location, target)
    if self:GetCaster():HasScepter() then
        return self.BaseClass.GetCastRange(self, location, target) + self:GetSpecialValueFor("cast_range_scepter_bonus")
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function travoman_stasis_trap:GetAOERadius()
    return self:GetSpecialValueFor("stun_radius")
end

function travoman_stasis_trap:OnAbilityPhaseStart()
    local point = self:GetCursorPosition()
    self.particle_cast_fx = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_stasis_trap_arcana.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(self.particle_cast_fx, 0, point)
    ParticleManager:SetParticleControl(self.particle_cast_fx, 1, point)
    ParticleManager:ReleaseParticleIndex(self.particle_cast_fx)
    return true
end

function travoman_stasis_trap:OnAbilityPhaseInterrupted()
    if self.particle_cast_fx then
        ParticleManager:DestroyParticle(self.particle_cast_fx, true)
        ParticleManager:ReleaseParticleIndex(self.particle_cast_fx)
    end
end

function travoman_stasis_trap:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    self:GetCaster():EmitSound("Hero_Techies.StasisTrap.Plant")
	self:GetCaster():EmitSound("travoman_cast")
    self:CreateMine(point)
    if self:GetCaster():HasTalent("special_bonus_birzha_nameplate_duplication_mines") then
        local npc_dota_travoman_minefield_sign = nil
        local travoman_signs = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
        for _, sign_search in pairs(travoman_signs) do
            if sign_search and sign_search:GetUnitName() == "npc_dota_travoman_minefield_sign" then
                self:CreateMine(sign_search:GetAbsOrigin() + RandomVector(RandomInt(50, 100)))
            end
        end
    end
end

function travoman_stasis_trap:CreateMine(point)
    self:GetCaster():EmitSound("Hero_Techies.StasisTrap.Plant")
    local mine = CreateUnitByName("travoman_stasis_mine", point, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
    mine:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
    mine:AddNewModifier(self:GetCaster(), self, "modifier_travoman_stasis_trap", {})
    mine:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
    return mine
end

modifier_travoman_stasis_trap = class({})

function modifier_travoman_stasis_trap:IsPurgable() return false end
function modifier_travoman_stasis_trap:IsHidden() return true end

function modifier_travoman_stasis_trap:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("activation_radius")
    self.radius_boom = self:GetAbility():GetSpecialValueFor("stun_radius")
    self.stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
    self.activation_delay = self:GetAbility():GetSpecialValueFor("activation_time")
    
    -- Задержка после создания ловушки
    self.creation_time = GameRules:GetGameTime()
    self.ready = false  -- Ловушка еще не готова к активации
    
    self:StartIntervalThink(FrameTime())
end

function modifier_travoman_stasis_trap:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetParent():IsAlive() then return end
    
    -- Проверяем прошла ли задержка после создания
    if not self.ready then
        local time_since_creation = GameRules:GetGameTime() - self.creation_time
        if time_since_creation >= self.activation_delay then
            self.ready = true
            -- Визуальный эффект что ловушка готова
            local particle_ready_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_stasis_trap_arm.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(particle_ready_fx, 0, self:GetParent():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle_ready_fx)
        else
            return  -- Ловушка еще не готова, выходим
        end
    end
    
    -- Если ловушка готова, ищем врагов
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false )

    if #enemies <= 0 then
        self.activated = false
        self.activation_time = nil
        return
    end
    
    -- Если враг в радиусе и ловушка готова
    if not self.activated then
        self.activated = true
        self.activation_time = GameRules:GetGameTime()
        
        -- Визуальный эффект активации
        local particle_warning_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_stasis_trap_activate.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(particle_warning_fx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_warning_fx)
        
        -- Звук активации
        -- self:GetParent():EmitSound("Hero_Techies.StasisTrap.Activate")
		-- EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "Hero_Techies.ReactiveTazer.Detonate", self:GetCaster())
    end
    if self.activated then
        self:Explosion()
    end
end
function modifier_travoman_stasis_trap:Explosion()
    if not IsServer() then return end

	-- EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "travoman_trap", self:GetCaster())
	EmitSoundOn("travoman_trap", self:GetParent())
	EmitSoundOn("Hero_Techies.ReactiveTazer.Detonate", self:GetParent())

    local particle_explode_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_explode_fx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_explode_fx, 1, Vector(self.radius_boom, 1, 1))
    ParticleManager:SetParticleControl(particle_explode_fx, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_explode_fx)

    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius_boom, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_travoman_stasis_trap_debuff", {duration = self.stun_duration})
    end

    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self.radius, 1, false)

    self:GetParent():ForceKill(false)
    self:Destroy()
end

function modifier_travoman_stasis_trap:CheckState()
    local state = 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ROOTED] = not self:GetCaster():HasTalent("special_bonus_birzha_travoman_move_mines"),
    }
    return state
end

function modifier_travoman_stasis_trap:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return decFuncs
end

function modifier_travoman_stasis_trap:GetModifierMoveSpeed_Absolute()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_travoman_move_mines")
end

function modifier_travoman_stasis_trap:GetModifierIncomingDamage_Percentage()
    return -100
end

function modifier_travoman_stasis_trap:OnTakeDamage(keys)
    local unit = keys.unit
    local attacker = keys.attacker
    if keys.inflictor ~= nil then return end
    if unit == self:GetParent() then
        self:GetParent():Kill(self:GetAbility(), attacker)
    end
end

function modifier_travoman_stasis_trap:GetPriority()
    return MODIFIER_PRIORITY_NORMAL
end

modifier_travoman_stasis_trap_debuff = class({})

function modifier_travoman_stasis_trap_debuff:CheckState()
    local state = {[MODIFIER_STATE_ROOTED] = true}
    if self:GetCaster():HasTalent("special_bonus_birzha_trap_muted_item") then
        state = 
        {
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_MUTED] = true
        }
    end
    return state
end

function modifier_travoman_stasis_trap_debuff:IsHidden() return false end
function modifier_travoman_stasis_trap_debuff:IsPurgable() return true end
function modifier_travoman_stasis_trap_debuff:IsDebuff() return true end

function modifier_travoman_stasis_trap_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_techies_stasis.vpcf"
end

LinkLuaModifier("modifier_travoman_suicide", "abilities/heroes/travoman.lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_travoman_suicide_debuff", "abilities/heroes/travoman.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_travoman_suicide_buff", "abilities/heroes/travoman.lua", LUA_MODIFIER_MOTION_NONE)

travoman_suicide = class({})

function travoman_suicide:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():EmitSound("travoman_cast_suicide_02")  -- Звук при начале каста
        return true
    end
end
function travoman_suicide:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function travoman_suicide:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function travoman_suicide:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function travoman_suicide:GetIntrinsicModifierName()
    return "modifier_travoman_suicide_buff"
end

modifier_travoman_suicide_buff = class({})

function modifier_travoman_suicide_buff:IsPurgable() return false end
function modifier_travoman_suicide_buff:IsHidden() return self:GetStackCount() == 0 end

function modifier_travoman_suicide_buff:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_DEATH
    }
end

function modifier_travoman_suicide_buff:OnDeath(params)
    -- Проверяем что убийца - наш кастер
    if params.attacker ~= self:GetParent() then return end
    
    -- Проверяем что способность - наша suicide способность
    if params.inflictor ~= self:GetAbility() then return end
    
    -- Проверяем что убитый юнит - ГЕРОЙ (а не крип или суммон)
    if not params.unit:IsRealHero() then return end
    
    -- Проверяем что это вражеский герой
    if params.unit:GetTeamNumber() == self:GetParent():GetTeamNumber() then return end
    
    -- Увеличиваем стаки только за убийство вражеских героев
    self:IncrementStackCount()
end

function travoman_suicide:OnSpellStart()
    if IsServer() then
        local vLocation = self:GetCursorPosition()
        local kv =
        {
            vLocX = vLocation.x,
            vLocY = vLocation.y,
            vLocZ = vLocation.z
        }
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_travoman_suicide", kv )
        self:GetCaster():EmitSound("Hero_Techies.BlastOff.Cast")
        self:GetCaster():EmitSound("travoman_cast_suicide")
    end
end

function travoman_suicide:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target) + self:GetCaster():FindTalentValue("special_bonus_birzha_range_cast_suicide")
end

modifier_travoman_suicide = class({})

local TECHIES_MINIMUM_HEIGHT_ABOVE_LOWEST = 200
local TECHIES_MINIMUM_HEIGHT_ABOVE_HIGHEST = 200
local TECHIES_ACCELERATION_Z = 4000
local TECHIES_MAX_HORIZONTAL_ACCELERATION = 3000

function modifier_travoman_suicide:IsHidden()
    return true
end

function modifier_travoman_suicide:IsPurgable()
    return false
end

function modifier_travoman_suicide:RemoveOnDeath()
    return false
end

function modifier_travoman_suicide:OnCreated( kv )
    if IsServer() then
        self.bHorizontalMotionInterrupted = false
        self.bDamageApplied = false
        self.bTargetTeleported = false
		self:StartIntervalThink(0.03)

        if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then
            if not self:IsNull() then
                self:Destroy()
            end
            return
        end

        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_2_ES_ROLL_START)

        self.vStartPosition = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )
        self.flCurrentTimeHoriz = 0.0
        self.flCurrentTimeVert = 0.0

        self.vLoc = Vector( kv.vLocX, kv.vLocY, kv.vLocZ )
        self.vLastKnownTargetPos = self.vLoc

        local duration = 0
        local flDesiredHeight = TECHIES_MINIMUM_HEIGHT_ABOVE_LOWEST * duration * duration
        local flLowZ = math.min( self.vLastKnownTargetPos.z, self.vStartPosition.z )
        local flHighZ = math.max( self.vLastKnownTargetPos.z, self.vStartPosition.z )
        local flArcTopZ = math.max( flLowZ + flDesiredHeight, flHighZ + TECHIES_MINIMUM_HEIGHT_ABOVE_HIGHEST )

        local flArcDeltaZ = flArcTopZ - self.vStartPosition.z
        self.flInitialVelocityZ = math.sqrt( 2.0 * flArcDeltaZ * TECHIES_ACCELERATION_Z )

        local flDeltaZ = self.vLastKnownTargetPos.z - self.vStartPosition.z
        local flSqrtDet = math.sqrt( math.max( 0, ( self.flInitialVelocityZ * self.flInitialVelocityZ ) - 2.0 * TECHIES_ACCELERATION_Z * flDeltaZ ) )
        self.flPredictedTotalTime = math.max( ( self.flInitialVelocityZ + flSqrtDet) / TECHIES_ACCELERATION_Z, ( self.flInitialVelocityZ - flSqrtDet) / TECHIES_ACCELERATION_Z )

        self.vHorizontalVelocity = ( self.vLastKnownTargetPos - self.vStartPosition ) / self.flPredictedTotalTime
        self.vHorizontalVelocity.z = 0.0

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
        self:AddParticle( nFXIndex, false, false, -1, false, false )
    end
end

function modifier_travoman_suicide:OnIntervalThink()
    if not IsServer() then return end
    
    -- Проверяем, есть ли у кастера модификатор отталкивания
    if self:GetParent():HasModifier("modifier_generic_knockback_lua") then
        self:InterruptSuicide()
    end
end

function modifier_travoman_suicide:InterruptSuicide()
    if self.interrupted then return end
    self.interrupted = true
    
    -- Останавливаем движение
    self:GetParent():RemoveHorizontalMotionController(self)
    self:GetParent():RemoveVerticalMotionController(self)
    
    -- Воспроизводим звук прерывания
    self:GetParent():EmitSound("Hero_Techies.BlastOff.Interrupted")
    
    -- Визуальный эффект прерывания
    local interrupt_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off_interrupt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:ReleaseParticleIndex(interrupt_particle)
    
    -- Удаляем модификатор
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_travoman_suicide:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveHorizontalMotionController( self )
        self:GetParent():RemoveVerticalMotionController( self )
        self.radius  = self:GetAbility():GetSpecialValueFor("radius")
		self.damage  = self:GetAbility():GetSpecialValueFor("damage")
		if self:GetCaster():HasTalent("special_bonus_birzha_suicide_bonus_damage") then
            self.damage = self.damage + self:GetCaster():FindAbilityByName("special_bonus_birzha_suicide_bonus_damage"):GetSpecialValueFor("value")
        end
        self.duration  = self:GetAbility():GetSpecialValueFor("silence_duration")
        self:GetCaster():EmitSound("Hero_Techies.Suicide")

        local particle_explosion_fx = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_suicide_arcana.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(particle_explosion_fx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_explosion_fx, 2, Vector(self.radius, 1, 1))
        ParticleManager:ReleaseParticleIndex(particle_explosion_fx)

        local particle_explosion_fx_1 = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(particle_explosion_fx_1, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_explosion_fx_1)

        local stack = 0

        local mod = self:GetCaster():FindModifierByName("modifier_travoman_suicide_buff")
        if mod then
            stack = mod:GetStackCount()
        end
		
		local damage_type = DAMAGE_TYPE_MAGICAL
        if self:GetCaster():HasTalent("special_bonus_birzha_travoman_suicide_pure_damage") then
            damage_type = DAMAGE_TYPE_PURE
        end
		
        local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
        for i,unit in ipairs(units) do
            ApplyDamage({ victim = unit, attacker = self:GetCaster(), ability = self:GetAbility(), damage = self.damage + self:GetAbility():GetSpecialValueFor("damage_per_charge") * stack, damage_type = damage_type })
            unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_travoman_suicide_debuff", {duration = self.duration * (1 - unit:GetStatusResistance())})
            if self:GetCaster():HasTalent("special_bonus_birzha_suicide_stun") then
                unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self:GetCaster():FindTalentValue("special_bonus_birzha_suicide_stun") * (1-unit:GetStatusResistance())})
            end
        end
		
		local self_damage = self.damage + self:GetAbility():GetSpecialValueFor("damage_per_charge") * stack
		if self:GetCaster():HasTalent("special_bonus_birzha_suicide_ignore_self_damage") and self:GetAbility():GetAutoCastState() then
			self_damage = nil
		end
			ApplyDamage({
			victim = self:GetCaster(),
			attacker = self:GetCaster(), 
			ability = self:GetAbility(),
			damage = self_damage,
			damage_type = DAMAGE_TYPE_MAGICAL
		})
	end
end

function modifier_travoman_suicide:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_travoman_suicide:CheckState()
    local state =
    {
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

function modifier_travoman_suicide:UpdateHorizontalMotion( me, dt )
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
        local flVelDelta = math.min( flVelDif, TECHIES_MAX_HORIZONTAL_ACCELERATION )

        self.vHorizontalVelocity = self.vHorizontalVelocity + vVelDif * flVelDelta * dt
        local vNewPos = vOldPos + self.vHorizontalVelocity * dt
        me:SetOrigin( vNewPos )
    end
end

function modifier_travoman_suicide:UpdateVerticalMotion( me, dt )
    if IsServer() then
        self.flCurrentTimeVert = self.flCurrentTimeVert + dt
        local bGoingDown = ( -TECHIES_ACCELERATION_Z * self.flCurrentTimeVert + self.flInitialVelocityZ ) < 0

        local vNewPos = me:GetOrigin()
        vNewPos.z = self.vStartPosition.z + ( -0.5 * TECHIES_ACCELERATION_Z * ( self.flCurrentTimeVert * self.flCurrentTimeVert ) + self.flInitialVelocityZ * self.flCurrentTimeVert )

        local flGroundHeight = GetGroundHeight( vNewPos, self:GetParent() )
        local bLanded = false
        if ( vNewPos.z < flGroundHeight and bGoingDown == true ) then
            vNewPos.z = flGroundHeight
            bLanded = true
        end

        me:SetOrigin( vNewPos )
        if bLanded == true then
            if self.bHorizontalMotionInterrupted == false then
               --- self:GetAbility():BlowUp()
            end

            self:GetParent():RemoveHorizontalMotionController( self )
            self:GetParent():RemoveVerticalMotionController( self )

            self:SetDuration( 0.01, false)
        end
    end
end


function modifier_travoman_suicide:OnHorizontalMotionInterrupted()
    if IsServer() then
        self.bHorizontalMotionInterrupted = true
    end
end

function modifier_travoman_suicide:OnVerticalMotionInterrupted()
    if IsServer() then
        self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
        self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_2_END)
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_travoman_suicide:GetOverrideAnimation( params )
    return ACT_DOTA_CAST_ABILITY_2
end

modifier_travoman_suicide_debuff = class({})

function modifier_travoman_suicide_debuff:IsPurgable() return true end

function modifier_travoman_suicide_debuff:CheckState()
    local state = {[MODIFIER_STATE_SILENCED] = true}
    return state
end

function modifier_travoman_suicide_debuff:GetEffectName()
    return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_travoman_suicide_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end


LinkLuaModifier("modifier_travoman_remote_mines", "abilities/heroes/travoman.lua", LUA_MODIFIER_MOTION_NONE)

travoman_remote_mines = class({})

function travoman_remote_mines:GetCastRange(location, target)
    if self:GetCaster():HasScepter() then
        return self.BaseClass.GetCastRange(self, location, target) + self:GetSpecialValueFor("cast_range_scepter_bonus")
    end
    return self.BaseClass.GetCastRange(self, location, target)
end

function travoman_remote_mines:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function travoman_remote_mines:OnAbilityPhaseStart()
    local point = self:GetCursorPosition()
    self:GetCaster():EmitSound("Hero_Techies.RemoteMine.Toss")
    self.particle_plant_fx = ParticleManager:CreateParticle("particles/travoman_plant_arcana.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.particle_plant_fx, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.particle_plant_fx, 1, point)
    ParticleManager:SetParticleControl(self.particle_plant_fx, 4, point)
    return true
end

function travoman_remote_mines:OnAbilityPhaseInterrupted()
    if self.particle_plant_fx then
        ParticleManager:DestroyParticle(self.particle_plant_fx, true)
        ParticleManager:ReleaseParticleIndex(self.particle_plant_fx)
    end
end

function travoman_remote_mines:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    self:CreateMine(point)
    if self:GetCaster():HasTalent("special_bonus_birzha_nameplate_duplication_mines") then
        local npc_dota_travoman_minefield_sign = nil
        local travoman_signs = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
        for _, sign_search in pairs(travoman_signs) do
            if sign_search and sign_search:GetUnitName() == "npc_dota_travoman_minefield_sign" then
                self:CreateMine(sign_search:GetAbsOrigin() + RandomVector(RandomInt(50, 100)))
            end
        end
    end
    self:GetCaster():EmitSound("travoman_cast_green")
end

function travoman_remote_mines:CreateMine(point)
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Techies.StickyBomb.Plant")
    local mine = CreateUnitByName("npc_travoman_remote_mines", point, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
    mine:AddNewModifier(self:GetCaster(), self, "modifier_travoman_remote_mines", {})
    mine:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
    mine:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
    local ability = mine:FindAbilityByName("travoman_remote_mines_self_detonate")
    if ability then
        ability:SetLevel(1)
    end
    return mine
end

modifier_travoman_remote_mines = class({})

function modifier_travoman_remote_mines:IsHidden() return true end
function modifier_travoman_remote_mines:IsPurgable() return false end

function modifier_travoman_remote_mines:OnCreated()
    if not IsServer() then return end
    local particle_mine_fx = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_remote_mine_arcana.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle_mine_fx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_mine_fx, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_mine_fx)

    local radius = self:GetAbility():GetSpecialValueFor("radius")

    local particle_radius = ParticleManager:CreateParticleForTeam("particles/ui_mouseactions/range_display.vpcf", PATTACH_WORLDORIGIN, self:GetParent(), self:GetParent():GetTeamNumber())
    ParticleManager:SetParticleControl(particle_radius, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_radius, 1, Vector(radius,0,0))
    self:AddParticle(particle_mine_fx, true, false, -1, false, false)
    self:AddParticle(particle_radius, true, false, -1, false, false)
end

function modifier_travoman_remote_mines:CheckState()
    local state = 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ROOTED] = not self:GetCaster():HasTalent("special_bonus_birzha_travoman_move_mines"),
    }
    return state
end

function modifier_travoman_remote_mines:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }

    return decFuncs
end


function modifier_travoman_remote_mines:GetModifierMoveSpeed_Absolute()
    return self:GetCaster():FindTalentValue("special_bonus_birzha_travoman_move_mines")
end

function modifier_travoman_remote_mines:GetModifierIncomingDamage_Percentage()
    return -100
end

function modifier_travoman_remote_mines:OnTakeDamage(keys)
    local unit = keys.unit
    local attacker = keys.attacker

    if keys.inflictor ~= nil then return end

    if unit == self:GetParent() then
        self:GetParent():Kill(self:GetAbility(), attacker)
    end
end

LinkLuaModifier("modifier_travoman_focused_detonate_debuff", "abilities/heroes/travoman.lua", LUA_MODIFIER_MOTION_NONE)

travoman_focused_detonate = class({})

function travoman_focused_detonate:GetIntrinsicModifierName()
    return "modifier_travoman_focused_detonate_debuff"
end

modifier_travoman_focused_detonate_debuff = class({})

function modifier_travoman_focused_detonate_debuff:IsPurgable() return false end
function modifier_travoman_focused_detonate_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_EVENT_ON_HERO_KILLED
    }
end

function modifier_travoman_focused_detonate_debuff:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_travoman_focused_detonate_debuff:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_int_per_kill")
end

function modifier_travoman_focused_detonate_debuff:OnHeroKilled( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if parent == params.attacker and target:GetTeamNumber() ~= parent:GetTeamNumber() then
        self:IncrementStackCount()
        self:GetCaster():CalculateStatBonus(true)
    end
end

function travoman_focused_detonate:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function travoman_focused_detonate:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local remote_mines = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    
    for i = 1, #remote_mines do
        Timers:CreateTimer(0.02*(i-1), function()
            local detonate_ability_handler = remote_mines[i]:FindAbilityByName("travoman_remote_mines_self_detonate")
            if detonate_ability_handler then
                detonate_ability_handler:OnSpellStart(true)
            end
        end)
    end
end


travoman_remote_mines_self_detonate = class({})

function travoman_remote_mines_self_detonate:Spawn()
    if not IsServer() then return end
    if self and not self:IsTrained() then
        self:SetLevel(1)
    end
end

function travoman_remote_mines_self_detonate:OnSpellStart(use_ability, bonus_delay)
    if not IsServer() then return end
    local owner = self:GetCaster():GetOwner()
    local ability = owner:FindAbilityByName("travoman_remote_mines")
    local scepter = owner:HasShard()
    local damage = ability:GetSpecialValueFor("damage")
    local radius = ability:GetSpecialValueFor("radius")

    local techies_caster = ability:GetCaster()
    if not use_ability then
        local units = PlayerResource:GetSelectedEntities(self:GetCaster():GetPlayerOwnerID())
        for _, id in pairs(units) do
            local unit = EntIndexToHScript(id)
            if unit and unit ~= self:GetCaster() and unit:HasAbility("travoman_remote_mines_self_detonate") and unit:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() then
                local travoman_remote_mines_self_detonate = unit:FindAbilityByName("travoman_remote_mines_self_detonate")
                if travoman_remote_mines_self_detonate then
                    travoman_remote_mines_self_detonate:OnSpellStart(true)
                end
            end
        end
    end

    self:GetCaster():EmitSound("Hero_Techies.RemoteMine.Activate")
    self:GetCaster():EmitSound("travoman_ultimate")
    self:GetCaster():EmitSound("Hero_Techies.RemoteMine.Detonate")

    local particle_explosion_fx = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_remote_mines_detonate_arcana.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_explosion_fx, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_explosion_fx, 1, Vector(radius+100, 1, 1))
    ParticleManager:SetParticleControl(particle_explosion_fx, 3, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_explosion_fx)
    
    local flag = 0
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, FIND_ANY_ORDER, false)
    for _,enemy in pairs(enemies) do
        local damage_type = DAMAGE_TYPE_MAGICAL
        ApplyDamage({victim = enemy, attacker = owner, damage = damage, damage_type = damage_type, ability = ability, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION })
    end
    self:GetCaster():ForceKill(true)
end

LinkLuaModifier("modifier_travoman_minefield_sign", "abilities/heroes/travoman.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_travoman_minefield_sign_aura", "abilities/heroes/travoman.lua", LUA_MODIFIER_MOTION_NONE)

travoman_minefield_sign = class({})

function travoman_minefield_sign:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) / self:GetCaster():GetCooldownReduction()
end

function travoman_minefield_sign:GetAOERadius()
    return self:GetSpecialValueFor("aura_radius")
end

function travoman_minefield_sign:IsRefreshable() return false end

function travoman_minefield_sign:OnSpellStart()
    if not IsServer() then return end

    local point = self:GetCursorPosition()
    self:GetCaster():EmitSound("Hero_Techies.Sign")
	self:GetCaster():EmitSound("travoman_cast_tablichka")

    local sign = CreateUnitByName("npc_dota_travoman_minefield_sign", point, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
    sign:AddNewModifier(self:GetCaster(), self, "modifier_travoman_minefield_sign", {})
    sign:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("lifetime")})
    sign:SetForwardVector(self:GetCaster():GetForwardVector() * -1)

    self.assigned_sign = sign
end

modifier_travoman_minefield_sign = class({})

function modifier_travoman_minefield_sign:OnCreated()
    self.radius = self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_travoman_minefield_sign:IsHidden() return false end
function modifier_travoman_minefield_sign:IsPurgable() return false end
function modifier_travoman_minefield_sign:IsDebuff() return false end

function modifier_travoman_minefield_sign:CheckState()
    local state = 
    {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true
    }
    return state
end

function modifier_travoman_minefield_sign:GetAuraEntityReject(target)
    if target:GetUnitName() == "travoman_land_mine" or target:GetUnitName() == "travoman_stasis_mine" or target:GetUnitName() == "npc_travoman_remote_mines" then
        return false
    end
    return true
end

function modifier_travoman_minefield_sign:GetAuraRadius()
    return self.radius
end

function modifier_travoman_minefield_sign:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_travoman_minefield_sign:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_travoman_minefield_sign:GetAuraSearchType()
    return DOTA_UNIT_TARGET_OTHER
end

function modifier_travoman_minefield_sign:GetModifierAura()
    if not self:GetCaster():HasScepter() then return end
    return "modifier_travoman_minefield_sign_aura"
end

function modifier_travoman_minefield_sign:IsAura()
    return true
end

modifier_travoman_minefield_sign_aura = class({})

function modifier_travoman_minefield_sign_aura:IsHidden() return true end

function modifier_travoman_minefield_sign_aura:CheckState()
    local state = {[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true}
    return state
end

function modifier_travoman_minefield_sign_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
    }
end

function modifier_travoman_minefield_sign_aura:GetModifierInvisibilityLevel()
    return 1
end

travoman_sausage = class({})

function travoman_sausage:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) / ( self:GetCaster():GetCooldownReduction())
end

function travoman_sausage:OnInventoryContentsChanged()
    if self:GetCaster():HasTalent("special_bonus_birzha_travoman_sausage") then
        self:SetHidden(false)       
        if not self:IsTrained() then
            self:SetLevel(1)
        end
    else
        self:SetHidden(true)
    end
end

function travoman_sausage:OnHeroCalculateStatBonus()
    self:OnInventoryContentsChanged()
end
