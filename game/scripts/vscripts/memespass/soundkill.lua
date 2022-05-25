modifier_birzhapass_sound = class({})

function  modifier_birzhapass_sound:OnCreated()
if not IsServer() then return end   
self.p_id = self:GetParent():GetPlayerID()
self.sound_table = {
npc_dota_hero_ogre_magi = {
                        sound = 'Silverdeath',
                        bp_lvl = 23,
                        },
						npc_dota_hero_earthshaker = {
                        sound = 'Valakasdeath',
                        bp_lvl = 28,
                        }
}
end    

function modifier_birzhapass_sound:DeclareFunctions()
return {MODIFIER_EVENT_ON_HERO_KILLED }
end

function modifier_birzhapass_sound:RemoveOnDeath()
	return false
end

function modifier_birzhapass_sound:IsHidden()
	return true
end
    
function  modifier_birzhapass_sound:OnHeroKilled(table)
	
    if self:GetParent() == table.attacker and self:GetParent() ~= table.target then
        if DonateShopIsItemBought(self.p_id, self.sound_table[self:GetParent():GetUnitName()].bp_lvl) then
            self:GetParent():EmitSound(tostring(self.sound_table[self:GetParent():GetUnitName()].sound))
        end    
    end
end