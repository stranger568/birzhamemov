LinkLuaModifier( "modifier_birzha_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )

local DEFAULT_ABILITIES = {"Overlord_one_book","Overlord_two_book","Overlord_three_book", "Overlord_passive", "overlord_hidden_2", "Overlord_spell_ultimate"}
local BOOK_TABLE_1 = {"overlord_spellbook_close","Overlord_spell_1","Overlord_spell_2","Overlord_spell_3","Overlord_spell_4","Overlord_spell_5"}
local BOOK_TABLE_2 = {"overlord_spellbook_close","Overlord_spell_6","Overlord_spell_7","Overlord_spell_8","Overlord_spell_9","Overlord_spell_10"}
local BOOK_TABLE_3 = {"overlord_spellbook_close","Overlord_spell_11","Overlord_spell_12","Overlord_spell_13","Overlord_spell_14","Overlord_spell_15"}

overlord_spellbook_close = class({})

function overlord_spellbook_close:GetAbilityTextureName()
    if self:GetCaster():GetModifierStackCount("modifier_Overlord_use_book", self:GetCaster()) == 1 then
        return "overlord_anime/one_book"
    end
    if self:GetCaster():GetModifierStackCount("modifier_Overlord_use_book", self:GetCaster()) == 2 then
        return "overlord_anime/two_book"
    end
    if self:GetCaster():GetModifierStackCount("modifier_Overlord_use_book", self:GetCaster()) == 3 then
        return "overlord_anime/three_book"
    end
end

function overlord_spellbook_close:OnSpellStart()
    if not IsServer() then return end
    local mod = self:GetCaster():FindModifierByName("modifier_Overlord_use_book")
    if mod then
        mod:Destroy()
    end
end

LinkLuaModifier( "modifier_Overlord_use_book", "abilities/heroes/overlord_anime.lua", LUA_MODIFIER_MOTION_NONE )

Overlord_one_book = class({})

function Overlord_one_book:GetCooldown(level)
    if self:GetCaster():HasScepter() then return self:GetSpecialValueFor("scepter_cooldown") end
    return self.BaseClass.GetCooldown( self, level )
end

function Overlord_one_book:OnSpellStart()
    if not IsServer() then return end
    self:EndCooldown()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Overlord_use_book", {book = 1})
end

Overlord_two_book = class({})

function Overlord_two_book:GetCooldown(level)
    if self:GetCaster():HasScepter() then return self:GetSpecialValueFor("scepter_cooldown") end
    return self.BaseClass.GetCooldown( self, level )
end

function Overlord_two_book:OnSpellStart()
    if not IsServer() then return end
    self:EndCooldown()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Overlord_use_book", {book = 2})
end

Overlord_three_book = class({})

function Overlord_three_book:GetCooldown(level)
    if self:GetCaster():HasScepter() then return self:GetSpecialValueFor("scepter_cooldown") end
    return self.BaseClass.GetCooldown( self, level )
end

function Overlord_three_book:OnSpellStart()
    if not IsServer() then return end
    self:EndCooldown()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Overlord_use_book", {book = 3})
end

modifier_Overlord_use_book = class({})

function modifier_Overlord_use_book:IsHidden()
    return true
end

function modifier_Overlord_use_book:IsPurgable()
    return false
end

function modifier_Overlord_use_book:RemoveOnDeath()
    return false
end

function modifier_Overlord_use_book:OnCreated(kv)
    if not IsServer() then return end
    self:SetStackCount(kv.book)
    if kv.book == 1 then
        for id, new_ability in pairs(BOOK_TABLE_1) do
            local old_ability = self:GetParent():GetAbilityByIndex(id-1)
            self:GetCaster():SwapAbilities(old_ability:GetAbilityName(), new_ability, false, true)
        end
    elseif kv.book == 2 then
        for id, new_ability in pairs(BOOK_TABLE_2) do
            local old_ability = self:GetParent():GetAbilityByIndex(id-1)
            self:GetCaster():SwapAbilities(old_ability:GetAbilityName(), new_ability, false, true)
        end
    elseif kv.book == 3 then
        for id, new_ability in pairs(BOOK_TABLE_3) do
            local old_ability = self:GetParent():GetAbilityByIndex(id-1)
            self:GetCaster():SwapAbilities(old_ability:GetAbilityName(), new_ability, false, true)
        end
    end
end

function modifier_Overlord_use_book:OnDestroy()
    if not IsServer() then return end
    for id, new_ability in pairs(DEFAULT_ABILITIES) do
        local old_ability = self:GetParent():GetAbilityByIndex(id-1)
        self:GetCaster():SwapAbilities(old_ability:GetAbilityName(), new_ability, false, true)
    end
    self:GetAbility():UseResources(false, false, false, true)
end

LinkLuaModifier( "modifier_Overlord_spell_1_buff", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_1_shield", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )

Overlord_spell_1 = class({}) 

function Overlord_spell_1:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Overlord_spell_1:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Overlord_spell_1:OnAbilityPhaseStart()
    if #(self:GetCursorTarget():FindAllModifiersByName("modifier_Overlord_spell_1_buff")) >= self:GetSpecialValueFor("count_max") then
        return false
    end
    return true
end

function Overlord_spell_1:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(self:GetCaster(), self, "modifier_Overlord_spell_1_buff", {duration = duration})
    self:GetCaster():EmitSound("overlord_spell1")
end

modifier_Overlord_spell_1_buff = class({})

function modifier_Overlord_spell_1_buff:IsPurgable() return false end

function modifier_Overlord_spell_1_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_Overlord_spell_1_buff:OnCreated()
    self.start_shield = self:GetAbility():GetSpecialValueFor( "health" ) + GetOverlordPassiveValue(self:GetCaster(), 100)
    if not IsServer() then return end
    self:GetParent():Purge( false, true, false, false, false)
    self.damage_absorb = self:GetAbility():GetSpecialValueFor( "health" ) + GetOverlordPassiveValue(self:GetCaster(), 100)
    self:SetStackCount(self.damage_absorb)
    local effect_cast = ParticleManager:CreateParticle( "particles/overlord_anime/shield_skelet.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControl( effect_cast, 3, Vector( 100, 0, 0 ) )
    self:AddParticle( effect_cast, false, false, -1, false, false )
end

function modifier_Overlord_spell_1_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
    }
    return funcs
end

function modifier_Overlord_spell_1_buff:GetModifierTotal_ConstantBlock(kv)
    if IsServer() then
        local target                    = self:GetParent()
        local original_shield_amount    = self.damage_absorb

        if self:GetParent():HasModifier("modifier_Overlord_spell_10_invul") then
            return
        end

        if self:GetParent():FindAllModifiersByName(self:GetName())[1] == self then
            if kv.damage > 0 and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS then
                if kv.damage < self.damage_absorb then
                    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, kv.damage, nil)
                    self.damage_absorb = self.damage_absorb - kv.damage
                    self:SetStackCount(self.damage_absorb)
                    return kv.damage
                else
                    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, original_shield_amount, nil)
                    self:Destroy() 
                    return self.damage_absorb
                end
            end
        end
    end
end

function modifier_Overlord_spell_1_buff:GetModifierIncomingDamageConstant(params)
    if (not IsServer()) then
        if params.report_max then
            return self.start_shield
        end
        return self:GetStackCount()
    end
end


LinkLuaModifier( "modifier_Overlord_spell_2_buff", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_2_passive", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_2_icon", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )

Overlord_spell_2 = class({}) 

Overlord_spell_2.unit = "npc_dota_overlord_skelet_melee"

function Overlord_spell_2:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Overlord_spell_2:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Overlord_spell_2:GetAbilityTextureName()
    if self:GetCaster():GetModifierStackCount("modifier_Overlord_spell_2_icon", self:GetCaster()) == 1 then
        return "overlord_anime/spell_2_2"
    end
    return "overlord_anime/spell_2"
end

function Overlord_spell_2:GetIntrinsicModifierName()
    return "modifier_Overlord_spell_2_icon"
end

function Overlord_spell_2:OnSpellStart()
    if IsServer() then
        local skelet = CreateUnitByName(self.unit, self:GetCaster():GetAbsOrigin() + (self:GetCaster():GetForwardVector() * 300), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
        skelet:SetOwner(self:GetCaster())
        skelet:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
        FindClearSpaceForUnit(skelet, skelet:GetAbsOrigin(), true)
        skelet:SetForwardVector(self:GetCaster():GetForwardVector())
        skelet:AddNewModifier(self:GetCaster(), self, "modifier_Overlord_spell_2_buff", {})
        skelet:AddNewModifier(self:GetCaster(), self, "modifier_Overlord_spell_2_passive", {})
        skelet:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
        local mod = self:GetCaster():FindModifierByName("modifier_Overlord_spell_2_icon")
        if self.unit == "npc_dota_overlord_skelet_ranged" then
            self:GetCaster():EmitSound("overlord_spell2_2")
            self.unit = "npc_dota_overlord_skelet_melee"
            if mod then
                mod:SetStackCount(0)
            end
        else
            self.unit = "npc_dota_overlord_skelet_ranged"
            self:GetCaster():EmitSound("overlord_spell2_1")
            if mod then
                mod:SetStackCount(1)
            end
        end
    end
end

modifier_Overlord_spell_2_icon = class({})

function modifier_Overlord_spell_2_icon:IsHidden() return true end
function modifier_Overlord_spell_2_icon:OnCreated() self:SetStackCount(0) end

modifier_Overlord_spell_2_passive = class({})

function modifier_Overlord_spell_2_passive:IsHidden()
    return true
end

function modifier_Overlord_spell_2_passive:OnCreated()
    if not IsServer() then return end
    self.attack = 0
end

function modifier_Overlord_spell_2_passive:DeclareFunctions()
    local decFuncs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
    return decFuncs
end

function modifier_Overlord_spell_2_passive:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() then
        if params.target:IsWard() then return end
        self.attack = self.attack + 1
        if self.attack >= 5 then
            local modifier_passive = self:GetCaster():FindModifierByName("modifier_Overlord_passive")
            if modifier_passive then
                modifier_passive:IncrementStackCount()
            end
            self.attack = 0
        end
    end
end

modifier_Overlord_spell_2_buff = class({})

function modifier_Overlord_spell_2_buff:IsPurgable()
    return false
end

function modifier_Overlord_spell_2_buff:IsHidden()
    return true
end

function modifier_Overlord_spell_2_buff:OnCreated()
    if not IsServer() then return end
    local health = self:GetAbility():GetSpecialValueFor( "health" )
    local damage = self:GetAbility():GetSpecialValueFor( "damage" )
    self:GetParent():SetBaseDamageMin(damage)
    self:GetParent():SetBaseDamageMax(damage)
    self:GetParent():SetBaseMaxHealth(health)
    self:GetParent():SetHealth(health)
end 

LinkLuaModifier( "modifier_overlord_spell_3_main", "abilities/heroes/overlord_anime.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_spell_3_invis", "abilities/heroes/overlord_anime.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_spell_3_illusion", "abilities/heroes/overlord_anime.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_spell_3_cheat", "abilities/heroes/overlord_anime.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_spell_3_illusion_aura", "abilities/heroes/overlord_anime.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_spell_3_cheat_aura", "abilities/heroes/overlord_anime.lua", LUA_MODIFIER_MOTION_NONE )

Overlord_spell_3 = class({})

function Overlord_spell_3:GetIntrinsicModifierName()
    return "modifier_overlord_spell_3_main"
end

function Overlord_spell_3:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("radius")
end

modifier_overlord_spell_3_main = class({})

function modifier_overlord_spell_3_main:IsHidden() return true end

function modifier_overlord_spell_3_main:OnCreated()
    if not IsServer() then return end
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_overlord_spell_3_invis", {})
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_overlord_spell_3_illusion", {})
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_overlord_spell_3_cheat", {})
end

modifier_overlord_spell_3_invis = class({})

function modifier_overlord_spell_3_invis:RemoveOnDeath() return false end

function modifier_overlord_spell_3_invis:IsHidden() 
    return true
end

function modifier_overlord_spell_3_invis:IsPurgable() return false end
function modifier_overlord_spell_3_invis:IsDebuff() return false end

function modifier_overlord_spell_3_invis:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_overlord_spell_3_invis:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_overlord_spell_3_invis:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_overlord_spell_3_invis:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_overlord_spell_3_invis:GetModifierAura()
    return "modifier_truesight"
end

function modifier_overlord_spell_3_invis:IsAura()
    return true
end

modifier_overlord_spell_3_illusion = class({})

function modifier_overlord_spell_3_illusion:RemoveOnDeath() return false end

function modifier_overlord_spell_3_illusion:IsHidden() 
    return true
end

function modifier_overlord_spell_3_illusion:IsPurgable() return false end
function modifier_overlord_spell_3_illusion:IsDebuff() return false end

function modifier_overlord_spell_3_illusion:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_overlord_spell_3_illusion:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_overlord_spell_3_illusion:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_overlord_spell_3_illusion:GetAuraEntityReject(target)
    if target:IsIllusion() then
        return false
    else
        return true
    end
end

function modifier_overlord_spell_3_illusion:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_overlord_spell_3_illusion:GetModifierAura()
    return "modifier_overlord_spell_3_illusion_aura"
end

function modifier_overlord_spell_3_illusion:IsAura()
    return true
end

modifier_overlord_spell_3_cheat = class({})

function modifier_overlord_spell_3_cheat:RemoveOnDeath() return false end

function modifier_overlord_spell_3_cheat:IsHidden() 
    return true
end

function modifier_overlord_spell_3_cheat:IsPurgable() return false end
function modifier_overlord_spell_3_cheat:IsDebuff() return false end

function modifier_overlord_spell_3_cheat:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_overlord_spell_3_cheat:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_overlord_spell_3_cheat:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_overlord_spell_3_cheat:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_overlord_spell_3_cheat:GetModifierAura()
    return "modifier_overlord_spell_3_cheat_aura"
end

function modifier_overlord_spell_3_cheat:IsAura()
    return true
end

modifier_overlord_spell_3_illusion_aura = class({})

function modifier_overlord_spell_3_illusion_aura:IsHidden() return true end

function modifier_overlord_spell_3_illusion_aura:GetStatusEffectName()
    return "particles/status_fx/status_effect_phantom_lancer_illusion.vpcf"
end

modifier_overlord_spell_3_cheat_aura = class({})

function modifier_overlord_spell_3_cheat_aura:IsHidden() return true end

function modifier_overlord_spell_3_cheat_aura:OnCreated()
    if not IsServer() then return end
    if self:GetParent():IsRealHero() then
        self:GetParent().VisionAbilities = WorldPanels:CreateWorldPanelForTeam(self:GetCaster():GetTeamNumber(), {
            layout = "file://{resources}/layout/custom_game/overlord/abilitycooldowns.xml",
            entity = self:GetParent(),
            entityHeight = 275,
            data = {hasHealthBar = true}
        })
    end
end

function modifier_overlord_spell_3_cheat_aura:OnDestroy()
    if not IsServer() then return end
    if self:GetParent().VisionAbilities then
        self:GetParent().VisionAbilities:Delete()
        self:GetParent().VisionAbilities = nil
    end
end

LinkLuaModifier( "modifier_overlord_spell_4", "abilities/heroes/overlord_anime.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_spell_4_aura", "abilities/heroes/overlord_anime.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_overlord_spell_4_buff", "abilities/heroes/overlord_anime.lua", LUA_MODIFIER_MOTION_NONE )

Overlord_spell_4 = class({})

function Overlord_spell_4:GetIntrinsicModifierName()
    return "modifier_overlord_spell_4"
end

function Overlord_spell_4:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("radius")
end

modifier_overlord_spell_4 = class({})

function modifier_overlord_spell_4:IsHidden() 
    return true
end

function modifier_overlord_spell_4:IsPurgable() return false end
function modifier_overlord_spell_4:IsDebuff() return false end

function modifier_overlord_spell_4:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_overlord_spell_4:GetAuraEntityReject(target)
    if target:HasModifier("modifier_overlord_spell_4_buff") then
        return true 
    end
    if target ~= self:GetCaster() then
        return true
    end

    return false    
end

function modifier_overlord_spell_4:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

function modifier_overlord_spell_4:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_overlord_spell_4:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_overlord_spell_4:GetModifierAura()
    return "modifier_overlord_spell_4_aura"
end

function modifier_overlord_spell_4:IsAura()
    return true
end

modifier_overlord_spell_4_aura = class({})

function modifier_overlord_spell_4_aura:IsHidden() return true end

function modifier_overlord_spell_4_aura:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return decFuncs
end

function modifier_overlord_spell_4_aura:GetMinHealth()
    return 1
end

function modifier_overlord_spell_4_aura:OnTakeDamage(keys)
    if IsServer() then
        local attacker = keys.attacker
        local target = keys.unit 
        local damage = keys.damage

        local mod_invuls = 
        {
            "modifier_Overlord_spell_10_invul",
            "modifier_Overlord_spell_10_buff",
            "modifier_item_uebator_active",
            "modifier_LenaGolovach_Radio_god",
            "modifier_kurumi_god",
            "modifier_Felix_WaterShield",
            "modifier_ExplosionMagic_immunity",
            "modifier_haku_help",
            "modifier_invulnerable",
            "modifier_item_aeon_disk_buff",
            "modifier_papich_reincarnation_wraith_form",
        }

        if self:GetParent() == target then
            if self:GetParent():GetHealth() <= 1 then
                for _, mod in pairs(mod_invuls) do
                    if self:GetParent():HasModifier(mod) then
                        return
                    end
                end

                for i = 0, 5 do 
                    local item = target:GetItemInSlot(i)
                    if item then
                        if item:GetName() == "item_aeon_disk" then
                            if item:IsFullyCastable() then
                                return false
                            end
                        end
                    end        
                end

                if not self:GetParent():HasModifier("modifier_item_uebator_cooldown") and self:GetParent():HasModifier("modifier_item_uebator") then
                    return
                end

                local wraith_form_modifier_handler = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_overlord_spell_4_buff", {duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_anime_3")})
                if wraith_form_modifier_handler then
                    wraith_form_modifier_handler.original_killer = attacker
                    wraith_form_modifier_handler.ability_killer = keys.inflictor
                end                
            end
        end
    end
end

modifier_overlord_spell_4_buff = class({})

function modifier_overlord_spell_4_buff:IsHidden() return true end
function modifier_overlord_spell_4_buff:IsDebuff() return false end
function modifier_overlord_spell_4_buff:IsPurgable() return false end

function modifier_overlord_spell_4_buff:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }

    return decFuncs
end

function modifier_overlord_spell_4_buff:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_overlord_spell_4_buff:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_overlord_spell_4_buff:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_overlord_spell_4_buff:GetDisableHealing()
    return 1
end

function modifier_overlord_spell_4_buff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return state
end

function modifier_overlord_spell_4_buff:OnDestroy()
    if IsServer() then
        self:GetParent().overlord_kill = true
        self:GetParent():BirzhaTrueKill(self.ability_killer, self.original_killer)
    end
end

function modifier_overlord_spell_4_buff:GetStatusEffectName()
    return "particles/overlord_anime/overlord_status_death.vpcf"
end

LinkLuaModifier( "modifier_overlord_spell_5", "abilities/heroes/overlord_anime.lua", LUA_MODIFIER_MOTION_NONE )

Overlord_spell_5 = class({})

function Overlord_spell_5:GetIntrinsicModifierName()
    return "modifier_overlord_spell_5"
end

modifier_overlord_spell_5 = class({})

function modifier_overlord_spell_5:IsHidden()
    return true
end

function modifier_overlord_spell_5:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE
    }

    return decFuncs
end

function modifier_overlord_spell_5:GetModifierIncomingPhysicalDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_incoming")
end

Overlord_spell_6 = class({}) 

function Overlord_spell_6:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_anime_4")
end

function Overlord_spell_6:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("radius")
end

function Overlord_spell_6:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Overlord_spell_6:GetAOERadius(level)
    return self:GetSpecialValueFor("radius")
end

LinkLuaModifier( "modifier_generic_ring_lua", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_NONE )

function Overlord_spell_6:OnSpellStart()
    if not IsServer() then return end
    local delay = self:GetSpecialValueFor("delay")
    local radius = self:GetSpecialValueFor("radius")
    local perc_damage = self:GetSpecialValueFor("perc_damage")
    local base_damage = self:GetSpecialValueFor("base_damage") + GetOverlordPassiveValue(self:GetCaster(), perc_damage)
    local point = self:GetCursorPosition()

    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_brewmaster/brewmaster_void_pulse.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( effect_cast, 0, point )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius*2, radius*2, radius*2 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    self:GetCaster():EmitSound("overlord_spell6")

    local pulse = CreateModifierThinker( self:GetCaster(), self, "modifier_generic_ring_lua", { end_radius = radius, speed = 1200, target_team = DOTA_UNIT_TARGET_TEAM_ENEMY, target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, }, point, self:GetCaster():GetTeamNumber(), false )
    pulse = pulse:FindModifierByName( "modifier_generic_ring_lua" )

    pulse:SetCallback( function( enemy )
        local damageTable = {victim = enemy, attacker = self:GetCaster(), damage = base_damage, ability = self, damage_type = DAMAGE_TYPE_MAGICAL}
        ApplyDamage(damageTable)
        if enemy:IsRealHero() then
            AddPassiveStack(self:GetCaster())
        end
    end)
end

modifier_generic_ring_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_ring_lua:IsHidden()
    return true
end

function modifier_generic_ring_lua:IsDebuff()
    return false
end

function modifier_generic_ring_lua:IsStunDebuff()
    return false
end

function modifier_generic_ring_lua:IsPurgable()
    return false
end

function modifier_generic_ring_lua:RemoveOnDeath()
    return false
end

function modifier_generic_ring_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_generic_ring_lua:OnCreated( kv )

    if not IsServer() then return end

    -- references
    self.start_radius = kv.start_radius or 0
    self.end_radius = kv.end_radius or 0
    self.width = kv.width or 100
    self.speed = kv.speed or 0
    self.outward = self.end_radius>=self.start_radius
    if not self.outward then
        self.speed = -self.speed
    end

    self.target_team = kv.target_team or 0
    self.target_type = kv.target_type or 0
    self.target_flags = kv.target_flags or 0

    self.IsCircle = kv.IsCircle or 1

    self.targets = {}
end

function modifier_generic_ring_lua:OnRemoved()
end

function modifier_generic_ring_lua:OnDestroy()
    if self.EndCallback then
        self.EndCallback()
    end
    if not IsServer() then return end

    -- kill if thinker
    if self:GetParent():GetClassname()=="npc_dota_thinker" then
        UTIL_Remove( self:GetParent() )
    end
end

function modifier_generic_ring_lua:SetCallback( callback )
    self.Callback = callback

    -- Start interval
    self:StartIntervalThink( 0.03 )
    self:OnIntervalThink()
end

function modifier_generic_ring_lua:SetEndCallback( callback )
    self.EndCallback = callback
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_generic_ring_lua:OnIntervalThink()
    local radius = self.start_radius + self.speed * self:GetElapsedTime()
    if not self.outward and radius<self.end_radius then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    elseif self.outward and radius>self.end_radius then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end

    -- Find targets in ring
    local targets = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),   -- int, your team number
        self:GetParent():GetOrigin(),   -- point, center point
        nil,    -- handle, cacheUnit. (not known)
        radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
        self.target_team,   -- int, team filter
        self.target_type,   -- int, type filter
        self.target_flags,  -- int, flag filter
        0,  -- int, order filter
        false   -- bool, can grow cache
    )

    for _,target in pairs(targets) do

        -- only unaffected unit
        if not self.targets[target] then

            -- check if it is within circle/chakram
            if (not self.IsCircle) or (target:GetOrigin()-self:GetParent():GetOrigin()):Length2D()>(radius-self.width) then

                self.targets[target] = true

                -- do something
                self.Callback( target )
            end
        end

    end
end

LinkLuaModifier( "modifier_Overlord_spell_7_buff", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )

Overlord_spell_7 = class({}) 

function Overlord_spell_7:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Overlord_spell_7:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Overlord_spell_7:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("overlord_spell7")
    local duration_perc = self:GetSpecialValueFor("duration_perc")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Overlord_spell_7_buff", {duration = self:GetSpecialValueFor("duration") + GetOverlordPassiveValue(self:GetCaster(), duration_perc)})
end

modifier_Overlord_spell_7_buff = class({}) 

function modifier_Overlord_spell_7_buff:GetEffectName()
    return "particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_shroud.vpcf"
end

function modifier_Overlord_spell_7_buff:IsHidden() return false end
function modifier_Overlord_spell_7_buff:IsPurgable() return true end

function modifier_Overlord_spell_7_buff:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return decFuncs
end

function modifier_Overlord_spell_7_buff:OnCreated()
    if not IsServer() then return end
    self.damage = 0
end

function modifier_Overlord_spell_7_buff:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        local damage = params.damage
        self.damage = self.damage + damage
        self:SetStackCount(self.damage)
    end
end

function modifier_Overlord_spell_7_buff:OnDestroy()
    if not IsServer() then return end
    local radius_perc = self:GetAbility():GetSpecialValueFor("radius_perc")
    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius") + GetOverlordPassiveValue(self:GetCaster(), radius_perc), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false )
    for i = #units, 1, -1 do
        if units[i] ~= nil and (units[i] == self:GetParent()) then
            table.remove(units, i)
        end
    end
    if #units > 0 then
        self.damage = self.damage / #units
        for _, unit in pairs(units) do
            local damageTable = {victim = unit, attacker = self:GetCaster(), damage = self.damage, ability = self:GetAbility(), damage_type = DAMAGE_TYPE_PURE}
            ApplyDamage(damageTable)
            if self.damage > 0 then
                if unit:IsRealHero() then
                    AddPassiveStack(self:GetCaster())
                end
            end
        end
    end
end

LinkLuaModifier( "modifier_Overlord_spell_8_buff", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_8_debuff", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )

Overlord_spell_8 = class({}) 

function Overlord_spell_8:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Overlord_spell_8:GetManaCost(level)
    if self:GetCaster():HasModifier("modifier_Overlord_spell_8_buff") then return 0 end
    return self.BaseClass.GetManaCost(self, level)
end

function Overlord_spell_8:GetBehavior()
    local caster = self:GetCaster()
    if self:GetCaster():HasModifier("modifier_Overlord_spell_8_buff") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_HIDDEN
end

function Overlord_spell_8:OnSpellStart()
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_Overlord_spell_8_buff") then
        if self.target then
            local mod = self.target:FindModifierByName("modifier_Overlord_spell_8_debuff")
            if mod then
                mod:Destroy()
            end
            return
        end
    end
    self:GetCaster():EmitSound("overlord_spell8")
    self.target = self:GetCursorTarget()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Overlord_spell_8_buff", {duration = self:GetSpecialValueFor("duration") * (1-self.target:GetStatusResistance())})
    self.target:AddNewModifier(self:GetCaster(), self, "modifier_Overlord_spell_8_debuff", {duration = self:GetSpecialValueFor("duration") * (1-self.target:GetStatusResistance())})
    self:EndCooldown()
end

modifier_Overlord_spell_8_buff = class({})

function modifier_Overlord_spell_8_buff:IsPurgable() return false end

function modifier_Overlord_spell_8_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_Overlord_spell_8_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor('slow')
end

modifier_Overlord_spell_8_debuff = class({})

function modifier_Overlord_spell_8_debuff:IsPurgable() return false end

function modifier_Overlord_spell_8_debuff:OnCreated()
    if not IsServer() then return end

    local effect_cast = ParticleManager:CreateParticle("particles/overlord_anime/overlord_heart.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle( effect_cast, false, false, -1, false, false )

    local effect_cast = ParticleManager:CreateParticle("particles/overlord_anime/overlord_heart_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle( effect_cast, false, false, -1, false, true )

    self:StartIntervalThink(1)
end

function modifier_Overlord_spell_8_debuff:OnIntervalThink()
    if not IsServer() then return end
    local perc_damage = self:GetAbility():GetSpecialValueFor("perc_damage")
    if self:GetParent():IsRealHero() then
        AddPassiveStack(self:GetCaster())
    end
    local damage = self:GetAbility():GetSpecialValueFor("base_damage") + GetOverlordPassiveValue(self:GetCaster(), perc_damage)
    local damageTable = {victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, ability = self:GetAbility(), damage_type = DAMAGE_TYPE_MAGICAL}
    ApplyDamage(damageTable)
end

function modifier_Overlord_spell_8_debuff:OnDestroy()
    if not IsServer() then return end
    local mod = self:GetCaster():FindModifierByName("modifier_Overlord_spell_8_buff")
    if mod then
        mod:Destroy()
    end
    self:GetAbility():UseResources(false, false, false, true)
end

function modifier_Overlord_spell_8_debuff:CheckState()
    return 
    {
        [MODIFIER_STATE_ROOTED] = true,
    }
end

LinkLuaModifier( "modifier_Overlord_spell_9_metka", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_9_buff", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_9_debuff", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )

Overlord_spell_9 = class({}) 

function Overlord_spell_9:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Overlord_spell_9:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Overlord_spell_9:GetIntrinsicModifierName()
    return "modifier_Overlord_spell_9_buff"
end

function Overlord_spell_9:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    target:AddNewModifier(self:GetCaster(), self, "modifier_Overlord_spell_9_metka", {duration = self:GetSpecialValueFor("duration") * (1-target:GetStatusResistance())})
    self:GetCaster():EmitSound("overlord_spell9")
    if target:IsRealHero() then
        AddPassiveStack(self:GetCaster())
    end
end

modifier_Overlord_spell_9_metka = class({})

function modifier_Overlord_spell_9_metka:OnCreated()
    if not IsServer() then return end
    self.nfx = ParticleManager:CreateParticle("particles/wraith_king_custom.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle( self.nfx, false, false, -1, false, false )
end

function modifier_Overlord_spell_9_metka:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_Overlord_spell_9_metka:IsHidden() return false end

function modifier_Overlord_spell_9_metka:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_Overlord_spell_9_metka:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

function modifier_Overlord_spell_9_metka:OnDeath( params )
    if params.unit == self:GetParent() then

        local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

        for _, hero in pairs(units) do
            if hero:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
                hero:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_nevermore_requiem_fear", {duration = self:GetAbility():GetSpecialValueFor("fear_duration")})
            end
        end

        local modifier_buff = self:GetCaster():FindModifierByName("modifier_Overlord_spell_9_buff")
        local modifier_debuff = self:GetParent():FindModifierByName("modifier_Overlord_spell_9_debuff")

        if modifier_buff then
            modifier_buff:SetStackCount(modifier_buff:GetStackCount()+self:GetAbility():GetSpecialValueFor("intellect_gain"))
        else
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Overlord_spell_9_buff", {})
        end

        if modifier_debuff then
            modifier_debuff:SetStackCount(modifier_debuff:GetStackCount()+self:GetAbility():GetSpecialValueFor("intellect_gain"))
        else
            self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Overlord_spell_9_debuff", {})
        end
    end
end

modifier_Overlord_spell_9_buff = class({})

function modifier_Overlord_spell_9_buff:IsHidden() return self:GetStackCount() == 0 end

function modifier_Overlord_spell_9_buff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(0)
end

function modifier_Overlord_spell_9_buff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MANA_BONUS,
    }
    return funcs
end

function modifier_Overlord_spell_9_buff:GetModifierManaBonus( params )
    return self:GetStackCount()
end

modifier_Overlord_spell_9_debuff = class({})

function modifier_Overlord_spell_9_debuff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(self:GetAbility():GetSpecialValueFor("intellect_gain"))
end

function modifier_Overlord_spell_9_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MANA_BONUS,
    }
    return funcs
end

function modifier_Overlord_spell_9_debuff:GetModifierManaBonus( params )
    return self:GetStackCount() * -1
end

LinkLuaModifier( "modifier_Overlord_spell_10_buff", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_10_invul", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )

Overlord_spell_10 = class({})

function Overlord_spell_10:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("overlord_spell10")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Overlord_spell_10_buff", {duration = self:GetSpecialValueFor("duration")})
end

modifier_Overlord_spell_10_buff = class({})

function modifier_Overlord_spell_10_buff:IsHidden() return false end


function modifier_Overlord_spell_10_buff:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return decFuncs
end

function modifier_Overlord_spell_10_buff:OnTakeDamage(keys)
    if keys.unit == self:GetParent() then
        if keys.unit:IsRealHero() then
            AddPassiveStack(self:GetCaster())
        end
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Overlord_spell_10_invul", {duration = self:GetAbility():GetSpecialValueFor("duration_invul")})
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

modifier_Overlord_spell_10_invul = class({})

function modifier_Overlord_spell_10_invul:IsPurgable() return true end

function modifier_Overlord_spell_10_invul:GetEffectName()
    return "particles/repel_overlord_custom/omniknight_repel_buff_ti8_2.vpcf"
end

function modifier_Overlord_spell_10_invul:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier( "modifier_Overlord_spell_11", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )

Overlord_spell_11 = class({})

function Overlord_spell_11:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Overlord_spell_11:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level) + (self:GetCaster():GetMaxMana() / 100 * 3)
end

function Overlord_spell_11:OnToggle()
    local caster = self:GetCaster()
    local toggle = self:GetToggleState()
    if not IsServer() then return end
    if toggle then
        self:GetCaster():EmitSound("overlord_spell11")
        self.modifier = caster:AddNewModifier( caster, self, "modifier_Overlord_spell_11", {} )
    else
        if self.modifier and not self.modifier:IsNull() then
            self.modifier:Destroy()
        end
        self.modifier = nil
    end
end

modifier_Overlord_spell_11 = class({})

function modifier_Overlord_spell_11:IsHidden()
    return true
end

function modifier_Overlord_spell_11:IsPurgable()
    return false
end

function modifier_Overlord_spell_11:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_Overlord_spell_11:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.damageTable = 
    {
        attacker = self:GetParent(),
        damage = self:GetAbility():GetSpecialValueFor("base_damage"),
        damage_type = DAMAGE_TYPE_PURE,
        ability = self:GetAbility(),
    }
    self.bonus_damage = 0
    self:SetStackCount(0)
    self.nfx = ParticleManager:CreateParticle("particles/overlord_anime/overlord_flame.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.nfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.nfx, 2, Vector(self.radius,self.radius,self.radius))
    self:AddParticle( self.nfx, false, false, -1, false, false )
    self:OnIntervalThink()
    self:StartIntervalThink(0.5)
end

function modifier_Overlord_spell_11:OnIntervalThink()
    if not IsServer() then return end

    if self:GetParent():GetMana() < self:GetAbility():GetSpecialValueFor("manacost") then
        if self:GetAbility():GetToggleState() then
            self:GetAbility():ToggleAbility()
        end
        return
    end

    local flag = 0

    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false)
    local enemies_heroes = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, flag, 0, false)

    if #enemies_heroes > 0 then
        self.bonus_damage = self.bonus_damage + self:GetAbility():GetSpecialValueFor("damage_increase")
        self:SetStackCount(self.bonus_damage)
    end

    for _,enemy in pairs(enemies) do
        self.damageTable.damage = self:GetAbility():GetSpecialValueFor("base_damage") + self.bonus_damage
        self.damageTable.victim = enemy
        if GetTargetHealthCheck(enemy) or GetOverlordPassiveGetStacks(self:GetCaster()) then
            ApplyDamage( self.damageTable )
        end
        if enemy:IsRealHero() and not enemy:HasModifier("modifier_fountain_passive_invul") then
            AddPassiveStack(self:GetCaster())
        end
    end

    self:GetParent():SpendMana(self:GetAbility():GetSpecialValueFor("manacost") + (self:GetCaster():GetMaxMana() / 100 * 3), self:GetAbility() )
end

LinkLuaModifier("modifier_generic_knockback_lua", "modifiers/modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_12", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )

Overlord_spell_12 = class({})

function Overlord_spell_12:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Overlord_spell_12:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Overlord_spell_12:GetManaCost(level)
    return self:GetCaster():GetMaxMana() / 100 * self:GetSpecialValueFor("manacost")
end

function Overlord_spell_12:OnSpellStart()
    if not IsServer() then return end
    local perc_range = self:GetSpecialValueFor("perc_range")
    local radius = self:GetSpecialValueFor("radius")
    local range = self:GetSpecialValueFor("range") + GetOverlordPassiveValue(self:GetCaster(), perc_range)

    local flag = 0

    if self:GetCaster():HasTalent("special_bonus_birzha_overlord_anime_5") then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end

    local tornado = 
    {
        Ability = self,
        bDeleteOnHit   = false,
        EffectName =  "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf",
        vSpawnOrigin = self:GetCaster():GetOrigin(),
        fDistance = range,
        fStartRadius = radius,
        fEndRadius = radius,
        iMoveSpeed = 1500,
        Source = self:GetCaster(),
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        bVisibleToEnemies = true,
        iUnitTargetFlags = flag,
        bProvidesVision = true,
        iVisionRadius = 250,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        ExtraData = { x = self:GetCaster():GetOrigin().x, y = self:GetCaster():GetOrigin().y }
    }

    local target_point = self:GetCursorPosition()
    local caster_point = self:GetCaster():GetAbsOrigin() 
    local point_difference_normalized   = (target_point - caster_point):Normalized()

    if target_point == caster_point then
        point_difference_normalized = self:GetCaster():GetForwardVector()
    else
        point_difference_normalized = (target_point - caster_point):Normalized()
    end

    local projectile_vvelocity = point_difference_normalized * 1500

    projectile_vvelocity.z = 0

    tornado.vVelocity  = projectile_vvelocity

    local tornado_projectile = ProjectileManager:CreateLinearProjectile(tornado)

    self:GetCaster():EmitSound("overlord_spell12")
end

function Overlord_spell_12:OnProjectileHit_ExtraData(target, vLocation, extradata)
    if not IsServer() then return end
    if target ~= nil then
        local start_location = Vector(extradata.x,extradata.y,0)
        local perc_range = self:GetSpecialValueFor("perc_range")
        local range = self:GetSpecialValueFor("range") + GetOverlordPassiveValue(self:GetCaster(), perc_range)
        local distance = (vLocation - start_location):Length2D()
        local knockback_distance = range - distance
        local direction = (target:GetAbsOrigin() - vLocation):Normalized()

        local knockback = target:AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", { duration = 0.75, distance = knockback_distance, height = 0, direction_x = direction.x, direction_y = direction.y})
        local perc_damage = self:GetSpecialValueFor("perc_damage")
        local duration = self:GetSpecialValueFor( "blood_duration" )
        target:AddNewModifier( self:GetCaster(), self, "modifier_Overlord_spell_12", { duration = duration * (1-target:GetStatusResistance()) } )

        local damageTable = { attacker = self:GetCaster(), damage = self:GetSpecialValueFor("damage") + GetOverlordPassiveValue(self:GetCaster(), perc_damage), damage_type = DAMAGE_TYPE_MAGICAL, ability = self, victim = target }

        if GetTargetHealthCheck(target) or GetOverlordPassiveGetStacks(self:GetCaster()) then
            ApplyDamage( damageTable )
        end
        if target:IsRealHero() then
            AddPassiveStack(self:GetCaster())
        end
    end
end

modifier_Overlord_spell_12 = class({})

function modifier_Overlord_spell_12:IsPurgable()
    return false
end

function modifier_Overlord_spell_12:OnCreated()
    if not IsServer() then return end
    self.prevLoc = self:GetParent():GetAbsOrigin()
    self.blood_damage = self:GetAbility():GetSpecialValueFor("blood_damage") / 100
    self:StartIntervalThink( 0.25 )
end

function modifier_Overlord_spell_12:GetEffectName() return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf" end

function modifier_Overlord_spell_12:OnRefresh()
    self:OnCreated()
end

function modifier_Overlord_spell_12:OnIntervalThink()
    if not IsServer() then return end
    local move_damage = CalculateDistance(self.prevLoc, self:GetParent()) * self.blood_damage
    if move_damage > 0 then
        local damageTable = 
        {
            attacker = self:GetCaster(),
            damage = move_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility(),
            victim = self:GetParent()
        }
        if GetTargetHealthCheck(self:GetParent()) or GetOverlordPassiveGetStacks(self:GetCaster()) then
            ApplyDamage( damageTable )
        end
    end
    self.prevLoc = self:GetParent():GetAbsOrigin()
end

Overlord_spell_13 = class({})

function Overlord_spell_13:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) / self:GetCaster():GetCooldownReduction()
end

function Overlord_spell_13:GetManaCost(level)
    return self:GetCaster():GetMaxMana() / 100 * self:GetSpecialValueFor("manacost")
end

function Overlord_spell_13:CastFilterResultTarget( hTarget )
    if hTarget:IsMagicImmune() and (not self:GetCaster():HasTalent("special_bonus_birzha_overlord_anime_6")) then
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

function Overlord_spell_13:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end

    local mana = self:GetCaster():GetMaxMana() - target:GetMaxMana()

    local base_mana = self:GetSpecialValueFor("base_mana")
    local perc_mana = self:GetSpecialValueFor("perc_mana")

    local damage = self:GetSpecialValueFor("damage") + (math.abs(mana) * (base_mana + GetOverlordPassiveValue(self:GetCaster(), perc_mana)))

    Timers:CreateTimer(0.4, function()
        local damageTable = 
        {
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
            victim = target
        }
        local effect_cast = ParticleManager:CreateParticle("particles/econ/items/outworld_devourer/od_ti8/od_ti8_santies_eclipse_area.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl( effect_cast, 0, target:GetAbsOrigin() )
        ParticleManager:SetParticleControl( effect_cast, 1, Vector( 100, 100, 0 ) )
        ParticleManager:SetParticleControl( effect_cast, 2, Vector( 100, 100, 100 ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        target:EmitSound("Hero_ObsidianDestroyer.SanityEclipse.Cast")

        if not self:GetCaster():HasTalent("special_bonus_birzha_overlord_anime_6") then
            if target:IsMagicImmune() then return end
        end

        if GetTargetHealthCheck(target) or GetOverlordPassiveGetStacks(self:GetCaster()) then
            ApplyDamage( damageTable )
        end

        if target:IsRealHero() then
            AddPassiveStack(self:GetCaster())
        end
    end)
end

LinkLuaModifier( "modifier_Overlord_spell_14", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_14_use", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_14_debuff_phys", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_14_debuff_magic", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )

Overlord_spell_14 = class({})

function Overlord_spell_14:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_anime_7")
end

function Overlord_spell_14:IsRefreshable()
    return false
end

function Overlord_spell_14:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function Overlord_spell_14:GetManaCost(level)
    if self:GetCaster():HasModifier("modifier_Overlord_spell_14_use") then return 0 end
    return self:GetCaster():GetMana() / 100 * self:GetSpecialValueFor("manacost")
end

function Overlord_spell_14:GetAOERadius()
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_anime_1")
end

function Overlord_spell_14:GetBehavior()
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_Overlord_spell_14_use") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_HIDDEN
end

function Overlord_spell_14:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_Overlord_spell_14_use") then
        return "overlord_anime/spell_14_1"
    end
    return "overlord_anime/spell_14"
end

function Overlord_spell_14:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local delay = self:GetSpecialValueFor("delay")

    if self.thinker and not self.thinker:IsNull() then
        self.thinker:Destroy()
        return
    end

    EmitGlobalSound("overlord_spell_14")

    self.effect = ParticleManager:CreateParticle( "particles/econ/courier/courier_trail_international_2014/courier_international_2014.vpcf", PATTACH_RENDERORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl( self.effect, 15, Vector( 0, 255, 255 ) )
    ParticleManager:SetParticleControl( self.effect, 16, Vector( 1, 0, 0 ) )
end

function Overlord_spell_14:OnChannelFinish( bInterrupted )
    if self.effect then
        ParticleManager:DestroyParticle(self.effect, true)
    end
    if bInterrupted then self:EndCooldown() return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local delay = self:GetSpecialValueFor("delay")
    self.thinker = CreateModifierThinker( caster, self, "modifier_Overlord_spell_14", { duration = duration }, point, caster:GetTeamNumber(), false )
    self:EndCooldown()
end

modifier_Overlord_spell_14 = class({})

function modifier_Overlord_spell_14:OnCreated()
    if not IsServer() then return end

    self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Overlord_spell_14_use", {})

    self.radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_anime_1")

    self.damage = GetOverlordPassiveValue(self:GetCaster(), self:GetAbility():GetSpecialValueFor("damage")) / 2

    self.origin = self:GetParent():GetOrigin()

    local name = "particles/particle_overlord_boom.vpcf"

    --if self:GetCaster():HasTalent("special_bonus_birzha_overlord_anime_6") then
    --    name = "particles/particle_overlord_boom_talent.vpcf"
    --end

    self.range_pfx = ParticleManager:CreateParticleForTeam(name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
    ParticleManager:SetParticleControl(self.range_pfx, 1, Vector(255,255,255))
    ParticleManager:SetParticleControl(self.range_pfx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.range_pfx, 5, Vector(self.radius,self.radius,self.radius))
    self:AddParticle( self.range_pfx, false, false, -1, false, false )
end

function modifier_Overlord_spell_14:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():RemoveModifierByName("modifier_Overlord_spell_14_use")
    local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
    ParticleManager:SetParticleControl( pfx, 0, self:GetParent():GetAbsOrigin() )
    ParticleManager:SetParticleControl( pfx, 1, Vector(1.5,1.5,1.5) )
    ParticleManager:SetParticleControl( pfx, 3, self:GetParent():GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex(pfx)
    EmitSoundOnLocationWithCaster( self.origin, "Hero_Phoenix.SuperNova.Explode", self:GetCaster() )
    self:MagicalDamage()
    self:PhysicalDamage()
    self:GetAbility():UseResources(false, false, false, true)
end

function modifier_Overlord_spell_14:MagicalDamage()
    if not IsServer() then return end
    local damageTable = 
    {
        attacker = self:GetCaster(),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    }

    local flag = 0

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self.origin, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false)
    for _,enemy in pairs(enemies) do
        damageTable.damage = self.damage
        damageTable.victim = enemy
        if GetTargetHealthCheck(enemy) or GetOverlordPassiveGetStacks(self:GetCaster()) then
            ApplyDamage( damageTable )
        end
        if enemy:IsRealHero() then
            AddPassiveStack(self:GetCaster())
        end
        enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Overlord_spell_14_debuff_magic", {duration = self:GetAbility():GetSpecialValueFor("duration_debuff") * (1-enemy:GetStatusResistance())})
    end
end

function modifier_Overlord_spell_14:PhysicalDamage()
    if not IsServer() then return end

    local damageTable = 
    {
        attacker = self:GetCaster(),
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self:GetAbility(),
    }

    local flag = 0

    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self.origin, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false )

    for _,enemy in pairs(enemies) do
        damageTable.damage = self.damage
        damageTable.victim = enemy
        if GetTargetHealthCheck(enemy) or GetOverlordPassiveGetStacks(self:GetCaster()) then
            ApplyDamage( damageTable )
        end
        enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_Overlord_spell_14_debuff_phys", {duration = self:GetAbility():GetSpecialValueFor("duration_debuff") * (1-enemy:GetStatusResistance())})
    end
end

modifier_Overlord_spell_14_debuff_magic = class({})

function modifier_Overlord_spell_14_debuff_magic:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
    return decFuncs
end

function modifier_Overlord_spell_14_debuff_magic:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("magic_resistance")
end

modifier_Overlord_spell_14_debuff_phys = class({})

function modifier_Overlord_spell_14_debuff_phys:OnCreated()
    self.armor = (self:GetParent():GetPhysicalArmorValue(false) / 100 * self:GetAbility():GetSpecialValueFor("armor")) * -1
end

function modifier_Overlord_spell_14_debuff_phys:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
    return decFuncs
end

function modifier_Overlord_spell_14_debuff_phys:GetModifierPhysicalArmorBonus()
    return self.armor
end

modifier_Overlord_spell_14_use = class({})
function modifier_Overlord_spell_14_use:IsHidden() return true end
function modifier_Overlord_spell_14_use:IsPurgable() return false end
function modifier_Overlord_spell_14_use:RemoveOnDeath() return false end

LinkLuaModifier( "modifier_Overlord_spell_15_debuff", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_15_cast", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )

Overlord_spell_15 = class({})

function Overlord_spell_15:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function Overlord_spell_15:GetCastRange(location, target)
    local perc_radius = self:GetSpecialValueFor("perc_radius")
    return self:GetSpecialValueFor("radius") + GetOverlordPassiveValue(self:GetCaster(), perc_radius)
end

function Overlord_spell_15:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function Overlord_spell_15:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_Overlord_spell_15_cast", {duration = 3.25})
    EmitGlobalSound("overlord_spell15_1")
end

function Overlord_spell_15:OnChannelFinish( bInterrupted )
    if not IsServer() then return end

    self:GetCaster():RemoveModifierByName("modifier_Overlord_spell_15_cast")

    if bInterrupted then return end
    local perc_radius = self:GetSpecialValueFor("perc_radius")
    
    local radius = self:GetSpecialValueFor("radius") + GetOverlordPassiveValue(self:GetCaster(), perc_radius)

    local point = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100

    local flag = 0

    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, flag, FIND_CLOSEST, false )

    if self.pfx then
        ParticleManager:DestroyParticle( self.pfx, false )
    end

    -- Разрушение вардов
    if self:GetCaster():HasTalent("special_bonus_birzha_overlord_anime_2") then
        local wards_check = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
        for _, ward in pairs(wards_check) do
            if ward:GetUnitName() == "npc_dota_observer_wards" or ward:GetUnitName() == "npc_dota_sentry_wards" then
                ward:Kill(self, self:GetCaster())
            end 
        end
    end

    if #units > 0 then
        local last_unit = units[#units]
        local duration = (last_unit:GetAbsOrigin() - point):Length2D() / 500
        self.pfx = ParticleManager:CreateParticle( "particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.pfx, 0, point )
        Timers:CreateTimer(duration, function()
            if self.pfx then
                ParticleManager:DestroyParticle( self.pfx, false )
            end
        end)
    else
        self.pfx = ParticleManager:CreateParticle( "particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.pfx, 0, point )
        Timers:CreateTimer(0.5, function()
            if self.pfx then
                ParticleManager:DestroyParticle( self.pfx, false )
            end
        end)
    end

    for _, unit in pairs(units) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_Overlord_spell_15_debuff", {x=point.x, y=point.y, z=point.z, duration = ((unit:GetAbsOrigin() - point):Length2D() / 500) + 0.25})
    end 
end

modifier_Overlord_spell_15_cast = class({})
function modifier_Overlord_spell_15_cast:IsHidden() return true end
function modifier_Overlord_spell_15_cast:IsPurgable() return false end

modifier_Overlord_spell_15_debuff = class({})

function modifier_Overlord_spell_15_debuff:IsHidden()
  return false
end

function modifier_Overlord_spell_15_debuff:IsDebuff()
  return true
end

function modifier_Overlord_spell_15_debuff:IsStunDebuff()
  return true
end

function modifier_Overlord_spell_15_debuff:IsPurgable()
  return true
end

function modifier_Overlord_spell_15_debuff:OnCreated( kv )
    self.pull_speed = 3000
    if not IsServer() then return end
    self.center = Vector( kv.x, kv.y, kv.z )
    if self:ApplyHorizontalMotionController() == false then
        self:Destroy()
    end
end

function modifier_Overlord_spell_15_debuff:OnDestroy()
    if not IsServer() then return end

    local perc_damage = self:GetAbility():GetSpecialValueFor("perc_damage")

    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)

    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_birzha_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration") * (1-self:GetParent():GetStatusResistance())})

    local damageTable = 
    {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self:GetParent():GetMaxHealth() / 100 * (self:GetAbility():GetSpecialValueFor("damage") + GetOverlordPassiveValue(self:GetCaster(), perc_damage)),
        damage_type = DAMAGE_TYPE_PURE,
        ability = self:GetAbility(),
    }

    if GetTargetHealthCheck(self:GetParent()) or GetOverlordPassiveGetStacks(self:GetCaster()) then
        ApplyDamage( damageTable )
    end
    if self:GetParent():IsRealHero() then
        AddPassiveStack(self:GetCaster())
    end

    self:GetParent():InterruptMotionControllers( true )
end

function modifier_Overlord_spell_15_debuff:UpdateHorizontalMotion( me, dt )
    local target = self:GetParent():GetOrigin()-self.center
    target.z = 0
    local distance = target:Length2D()
    local targetL = target:Length2D()-500*dt
    local targetN = target:Normalized()
    if distance < 100 then
        self:Destroy()
    end
    self:GetParent():SetOrigin( self.center + targetN * targetL )
end

LinkLuaModifier( "modifier_Overlord_passive", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_NONE )

Overlord_passive = class({})

function Overlord_passive:GetIntrinsicModifierName()
    return "modifier_Overlord_passive"
end

modifier_Overlord_passive = class({})

function modifier_Overlord_passive:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(0)
    self.attack = 0
end

function modifier_Overlord_passive:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED}
    return decFuncs
end

function modifier_Overlord_passive:GetModifierManaBonus()
    if not self:GetCaster():HasShard() then return 0 end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("shard_mana")
end

function modifier_Overlord_passive:OnAttackLanded(params)
    if params.attacker == self:GetParent() then
        if params.attacker:IsIllusion() then return end
        self.attack = self.attack + 1
        if self.attack >= 5 then
            local modifier_passive = self:GetCaster():FindModifierByName("modifier_Overlord_passive")
            if modifier_passive then
                modifier_passive:IncrementStackCount()
            end
            self.attack = 0
        end
    end
end

LinkLuaModifier( "modifier_Overlord_spell_ultimate", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_ultimate_aura_thinker", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_Overlord_spell_ultimate_aura", "abilities/heroes/overlord_anime", LUA_MODIFIER_MOTION_BOTH )

Overlord_spell_ultimate = class({})

function Overlord_spell_ultimate:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function Overlord_spell_ultimate:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) + self:GetCaster():FindTalentValue("special_bonus_birzha_overlord_anime_8")
end

function Overlord_spell_ultimate:IsRefreshable()
    return false
end

function Overlord_spell_ultimate:OnAbilityPhaseStart()
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_fountain_passive_invul") then
        return false
    end
    self.mana = self:GetCaster():GetMana()
    self:GetCaster():EmitSound("overlord_ultimate_start")
    return true
end

function Overlord_spell_ultimate:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    self:GetCaster():StopSound("overlord_ultimate_start")
end

function Overlord_spell_ultimate:GetManaCost(level)
    return self:GetCaster():GetMana()
end

function Overlord_spell_ultimate:OnSpellStart()
    if not IsServer() then return end
    local health_damage = self:GetCaster():GetMaxHealth() / 100 * self:GetSpecialValueFor("health")
    local mana_damage = self.mana
    local damage = (health_damage + mana_damage) / 100 * self:GetSpecialValueFor("damage")

    local damageTable =
     {
        victim = self:GetCaster(),
        attacker = self:GetCaster(),
        damage = health_damage,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
    }

    ApplyDamage(damageTable)

    local point = self:GetCursorPosition()

    local clock = CreateUnitByName("npc_dummy_unit", point, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
    clock:AddNewModifier(self:GetCaster(), self, "modifier_Overlord_spell_ultimate", {damage = damage})
end

modifier_Overlord_spell_ultimate = class({})

function modifier_Overlord_spell_ultimate:IsHidden() return true end
function modifier_Overlord_spell_ultimate:IsPurgable() return false end

function modifier_Overlord_spell_ultimate:OnCreated(table)
    if not IsServer() then return end
    self.alive_time = self:GetAbility():GetSpecialValueFor("damage_duration")
    self.damage = table.damage + GetOverlordPassiveValue(self:GetCaster(), self:GetAbility():GetSpecialValueFor("damage_perc"))
    local interval = 1
    self.damage = self.damage / self:GetAbility():GetSpecialValueFor("damage_duration")
    self.effect_check = 0
    self.talent = false
    self:StartIntervalThink(interval)
    local vector = self:GetParent():GetForwardVector()
    vector.y = vector.y-90
    self:GetParent():SetForwardVector(vector)
    local thinker = CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_Overlord_spell_ultimate_aura_thinker", {duration = self:GetAbility():GetSpecialValueFor("damage_duration") + 0.1, damage = self.damage}, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
    self.effect_cast = ParticleManager:CreateParticle( "particles/overlord_anime/ultimate_timer.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( 0, self.alive_time, 0 ) )
    ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( 2, 0, 0 ) )
    EmitSoundOn("overlord_ultimate_time", self:GetParent())
end

function modifier_Overlord_spell_ultimate:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("overlord_ultimate_time", self:GetParent())
end

function modifier_Overlord_spell_ultimate:OnIntervalThink(table)
    if not IsServer() then return end

    self.alive_time = self.alive_time - 1

    self.effect_cast = ParticleManager:CreateParticle( "particles/overlord_anime/ultimate_timer.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )

    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( 0, self.alive_time, 0 ) )
    if self.alive_time < 10 then
        ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( 1, 0, 0 ) )
    else
        ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( 2, 0, 0 ) )
    end

    if self.alive_time <= 0 then
        self:GetParent():Destroy()
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_Overlord_spell_ultimate:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MODEL_SCALE
    }
    return decFuncs
end

function modifier_Overlord_spell_ultimate:GetVisualZDelta()
    return 300
end

function modifier_Overlord_spell_ultimate:GetModifierModelChange()
    return "models/clock_overlord.vmdl"
end

function modifier_Overlord_spell_ultimate:GetModifierModelScale( params )
    return 160
end

function modifier_Overlord_spell_ultimate:CheckState()
    return 
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
    }
end

modifier_Overlord_spell_ultimate_aura_thinker = class({})

function modifier_Overlord_spell_ultimate_aura_thinker:OnCreated(table)
    if not IsServer() then return end
    self.damage = table.damage
    --self.pfx = ParticleManager:CreateParticle("particles/overlord_anime/overlord_screen_white.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    --self:AddParticle( self.pfx, false, false, -1, false, false )
    self:StartIntervalThink(1)
end

function modifier_Overlord_spell_ultimate_aura_thinker:OnIntervalThink(table)
    if not IsServer() then return end
    if not self:GetCaster():IsAlive() then self:GetParent():Destroy() return end
    local flag = 0
    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, flag, FIND_CLOSEST, false )
    if not self:GetCaster():HasModifier("modifier_fountain_passive_invul") then
        self:GetParent():EmitSound("overlord_ultimate_damage")
        for _, unit in pairs(units) do
            if not unit:IsBoss() and not unit:HasModifier("modifier_fountain_passive_invul") then
                local damageTable = 
                {
                    victim = unit,
                    attacker = self:GetCaster(),
                    damage =  self.damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self:GetAbility(),
                }
                ApplyDamage( damageTable )
            end
        end
    end
end

function modifier_Overlord_spell_ultimate_aura_thinker:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_Overlord_spell_ultimate_aura_thinker:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_Overlord_spell_ultimate_aura_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_Overlord_spell_ultimate_aura_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_Overlord_spell_ultimate_aura_thinker:GetModifierAura()
    return "modifier_Overlord_spell_ultimate_aura"
end

function modifier_Overlord_spell_ultimate_aura_thinker:IsAura()
    return true
end

modifier_Overlord_spell_ultimate_aura = class({})

function modifier_Overlord_spell_ultimate_aura:IsPurgable()
    return false
end

function GetOverlordPassiveValue(caster, value)
    local modifier_count = caster:GetModifierStackCount("modifier_Overlord_passive", caster)
    if modifier_count then
        return modifier_count / 100 * value
    end
    return 0
end

function GetOverlordPassiveGetStacks(caster)
    local modifier = caster:FindModifierByName("modifier_Overlord_passive")
    if modifier then
        if modifier:GetStackCount() >= 250 then
            return true
        end
    end
    return false
end

function GetTargetHealthCheck(target)
    if target:GetMaxHealth() / 100 * 70 > target:GetHealth() then
        return true
    end
    return false
end

function AddPassiveStack(caster)
    if caster:HasModifier("modifier_fountain_passive_invul") then return end
    local modifier_passive = caster:FindModifierByName("modifier_Overlord_passive")
    if modifier_passive then
        modifier_passive:IncrementStackCount()
    end
end