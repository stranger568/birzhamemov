modifier_birzhapass_sound = class({})

function modifier_birzhapass_sound:IsHidden() return true end
function modifier_birzhapass_sound:IsPurgeException() return false end
function modifier_birzhapass_sound:IsPurgable() return false end
function modifier_birzhapass_sound:RemoveOnDeath() return false end

function  modifier_birzhapass_sound:OnCreated()
    if not IsServer() then return end   
    self.sound_table = 
    {
        npc_dota_hero_ogre_magi = 
        {
            sound = 'Silverdeath',
            bp_lvl = 23,
        },
		npc_dota_hero_earthshaker = 
        {
            sound = 'Valakasdeath',
            bp_lvl = 28,
        }
    }
end    

function modifier_birzhapass_sound:DeclareFunctions()
return {MODIFIER_EVENT_ON_HERO_KILLED }
end

function  modifier_birzhapass_sound:OnHeroKilled(params)
    if params.attacker ~= self:GetParent() then return end
    if params.target == self:GetParent() then return end
    if DonateShopIsItemBought(self:GetParent():GetPlayerOwnerID(), self.sound_table[self:GetParent():GetUnitName()].bp_lvl) then
        self:GetParent():EmitSound(tostring(self.sound_table[self:GetParent():GetUnitName()].sound))
    end
end