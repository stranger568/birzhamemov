LinkLuaModifier( "modifier_item_crysdalus", "items/boss_items", LUA_MODIFIER_MOTION_NONE )

item_crysdalus = class({})

function item_crysdalus:GetIntrinsicModifierName()
    return "modifier_item_crysdalus"
end

modifier_item_crysdalus = class({})

function modifier_item_crysdalus:IsHidden()
    return true
end

function modifier_item_crysdalus:IsPurgable()
    return false
end

function modifier_item_crysdalus:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_item_crysdalus:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE  }
end

function modifier_item_crysdalus:GetModifierPreAttack_BonusDamage()
	return self.damage
end

LinkLuaModifier( "modifier_item_bristback", "items/boss_items", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_bristback_ship", "items/boss_items", LUA_MODIFIER_MOTION_NONE )

item_bristback = class({})

function item_bristback:GetIntrinsicModifierName()
    return "modifier_item_bristback"
end

modifier_item_bristback = class({})

function modifier_item_bristback:IsHidden()
    return true
end

function modifier_item_bristback:IsPurgable()
    return false
end

function modifier_item_bristback:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_item_bristback_ship") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_bristback_ship", {})
	end
end

function modifier_item_bristback:OnDestroy()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_item_bristback") then
			self:GetCaster():RemoveModifierByName("modifier_item_bristback_ship")
		end
	end
end

function modifier_item_bristback:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS  }
end

function modifier_item_bristback:GetModifierPhysicalArmorBonus()
	return self.armor
end

modifier_item_bristback_ship = class({})

function modifier_item_bristback_ship:IsHidden()
    return true
end

function modifier_item_bristback_ship:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED  }
end

function modifier_item_bristback_ship:OnAttackLanded( keys )
    local chance = 25
    local damage = 250
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        if self:GetParent():IsIllusion() then return end
        if self:GetAbility():IsFullyCastable() then
            if RandomInt(1, 100) <= chance then
                self:GetParent():EmitSound("Hero_Bristleback.QuillSpray.Cast")
                local spray = ParticleManager:CreateParticle("particles/econ/items/bristleback/bristle_spikey_spray/bristle_spikey_quill_spray.vpcf", PATTACH_ABSORIGIN, self:GetParent())
				ParticleManager:SetParticleControl(spray, 0, self:GetParent():GetAbsOrigin())
				ParticleManager:SetParticleControl(spray, 60, Vector(RandomInt(0, 255), RandomInt(0, 255), RandomInt(0, 255)))
				ParticleManager:SetParticleControl(spray, 61, Vector(1, 0, 0))
                local heroes = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetParent():GetAbsOrigin(), nil, 625, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER, false)
                for _,hero in pairs(heroes) do
                	hero:EmitSound("Hero_Bristleback.QuillSpray.Target")
        		    local damageTable = {victim = hero,
                    attacker = self:GetCaster(),
                    damage = damage,
                    ability = self:GetAbility(),
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    }
		 			ApplyDamage(damageTable)
                end
            end
        end
    end
end
