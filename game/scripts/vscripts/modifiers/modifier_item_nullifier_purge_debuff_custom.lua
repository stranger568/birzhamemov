modifier_item_nullifier_purge_debuff_custom = class({})

function modifier_item_nullifier_purge_debuff_custom:IsPurgable() return false end
function modifier_item_nullifier_purge_debuff_custom:IsPurgeException() return false end

function modifier_item_nullifier_purge_debuff_custom:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.2)
		local overhead_particle = ParticleManager:CreateParticle("particles/items4_fx/nullifier_mute.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddParticle(overhead_particle, false, false, -1, false, false)
	end
end

function modifier_item_nullifier_purge_debuff_custom:OnIntervalThink()
	if IsServer() then
        if not self:GetParent():IsMagicImmune() then
		    self:GetParent():Purge(true, false, false, false, false)
        end
	end
end

function modifier_item_nullifier_purge_debuff_custom:GetEffectName()
	return "particles/items4_fx/nullifier_mute_debuff.vpcf"
end

function modifier_item_nullifier_purge_debuff_custom:GetStatusEffectName()
	return "particles/status_fx/status_effect_nullifier.vpcf"
end