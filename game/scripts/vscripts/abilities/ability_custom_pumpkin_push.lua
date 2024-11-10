ability_custom_pumpkin_push = class({})

function ability_custom_pumpkin_push:GetChannelAnimation()
    return ACT_DOTA_GENERIC_CHANNEL_1
end

function ability_custom_pumpkin_push:GetChannelTime()
    local modifier_hallowen_birzha_candy = self:GetCaster():GetModifierStackCount("modifier_hallowen_birzha_candy", self:GetCaster())
    return modifier_hallowen_birzha_candy * 0.5 
end

function ability_custom_pumpkin_push:StartProjectile(target)
    if not IsServer() then return end
    local info = 
    {
        Target = target,
        Source = self:GetCaster(),
        EffectName = "particles/hallowen/hw_candy_projectile.vpcf",
        iMoveSpeed = 400,
        vSourceLoc= target:GetAbsOrigin(),         
        bDodgeable = false,                        
        bReplaceExisting = false,                  
        flExpireTime = GameRules:GetGameTime() + 5,
        bProvidesVision = false,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,                   
    }
    BirzhaData:AddCandyes(self:GetCaster():GetPlayerOwnerID())
    ProjectileManager:CreateTrackingProjectile(info)
end

function ability_custom_pumpkin_push:OnChannelThink(flInterval)
    if not IsServer() then return end
    if self:GetCaster().ChannelCandy == nil then
        self:GetCaster().ChannelCandy = 0
    end
    self:GetCaster().ChannelCandy = self:GetCaster().ChannelCandy + flInterval
    local modifier_hallowen_birzha_candy = self:GetCaster():FindModifierByName("modifier_hallowen_birzha_candy")
    if self:GetCaster().ChannelCandy >= 0.45 then
        if modifier_hallowen_birzha_candy then
            modifier_hallowen_birzha_candy:DecrementStackCount()
            self:StartProjectile(self.target)
        end
        self:GetCaster().ChannelCandy = 0
    end
    if modifier_hallowen_birzha_candy then
        if modifier_hallowen_birzha_candy:GetStackCount() <= 0 then
            self:EndChannel(true)
            self:GetCaster():Interrupt()
            modifier_hallowen_birzha_candy:Destroy()
        end
    end
end

function ability_custom_pumpkin_push:OnChannelFinish(bInterrupted)
    if not IsServer() then return end
    if self:GetCaster().ChannelCandy then
        self:GetCaster().ChannelCandy = 0
    end
end