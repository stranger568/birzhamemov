LinkLuaModifier("modifier_item_liquid", "items/bond", LUA_MODIFIER_MOTION_NONE)

item_bond = class({})

function item_bond:GetCooldown(level)
    local bonus = 0
    if self:GetCaster():HasModifier("modifier_travoman_focused_detonate_debuff") then
        bonus = 10
    end
    return self.BaseClass.GetCooldown( self, level ) + bonus
end

function item_bond:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("bondt")
end

function item_bond:OnChannelFinish( bInterrupted )
	if not IsServer() then return end
	if bInterrupted then self:GetCaster():StopSound("bondt") return end
	local mana_regen = self:GetSpecialValueFor("reg")
    local intellect_reg = self:GetSpecialValueFor("intellect_reg") / 100

	local manafromintellect = self:GetCaster():GetIntellect() * intellect_reg
	local mana = mana_regen + manafromintellect

	self:GetCaster():GiveMana(mana)
	self:GetCaster():EmitSound("Hero_Riki.Smoke_Screen")

    local particle = ParticleManager:CreateParticle("particles/boss/riki_smokebomb.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(200, 0, 200))

    if self:GetCaster():HasAbility("shelby_shard") then
        if self:GetCaster():HasShard() then
            local modifier_shelby = self:GetCaster():FindModifierByName("modifier_shelby_shard")
            if modifier_shelby then
                modifier_shelby:AddCharge(self:GetName())
            end
        end
    end

    Timers:CreateTimer(1, function()
        if particle then
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
        end
    end)

	self:SpendCharge()
end

item_kolba = class({})

function item_kolba:GetIntrinsicModifierName()
    return "modifier_item_liquid"
end

item_vape = class({})

function item_vape:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("vapenat")
end

function item_vape:GetIntrinsicModifierName()
    return "modifier_item_liquid"
end

function item_vape:OnChannelFinish( bInterrupted )
	if not IsServer() then return end
	if bInterrupted then self:GetCaster():StopSound("vapenat") return end
    local mana_regen = self:GetSpecialValueFor("reg")
    local intellect_reg = self:GetSpecialValueFor("intellect_reg") / 100

    local manafromintellect = self:GetCaster():GetIntellect() * intellect_reg
    local mana = mana_regen + manafromintellect

    self:GetCaster():GiveMana(mana)
	self:GetCaster():EmitSound("Hero_Riki.Smoke_Screen")
    local particle = ParticleManager:CreateParticle("particles/vape/vape.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(200, 0, 200))

    Timers:CreateTimer(1, function()
        if particle then
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
        end
    end)
end

modifier_item_liquid = class({})

function modifier_item_liquid:IsHidden() return true end
function modifier_item_liquid:IsPurgable() return false end
function modifier_item_liquid:IsPurgeException() return false end
function modifier_item_liquid:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_liquid:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_item_liquid:GetModifierManaBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('mana')
end

function modifier_item_liquid:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('str')
end

function modifier_item_liquid:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('agi')
end

function modifier_item_liquid:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('int')
end
