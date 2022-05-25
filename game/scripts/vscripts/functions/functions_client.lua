--function C_DOTA_BaseNPC:HasTalent(talentName)
--    talentName = string.lower(talentName)   
--    if self:HasModifier("modifier_birzha_"..talentName) then
--        return true 
--    end
--    return false
--end
--
--function C_DOTA_BaseNPC:FindTalentValue(talentName, key)
--    talentName = string.lower(talentName)
--    if self:HasModifier("modifier_birzha_"..talentName) then
--        local value_name = key or "value"
--        local specialVal = AbilityKV[talentName]["AbilitySpecial"]
--        for l,m in pairs(specialVal) do
--            if m[value_name] then
--                return m[value_name]
--            end
--        end
--    end  
--    return 0
--end


function C_DOTA_BaseNPC:HasTalent(talentName)
    talentName = string.lower(talentName)
    local ability = self:FindAbilityByName(talentName)
    if ability and ability:GetLevel() > 0 then
        --local modifier = "modifier_birzha_"..talentName
        --if not self:HasModifier(modifier) then
        --    LinkLuaModifier( modifier, "modifiers/modifier_talents", LUA_MODIFIER_MOTION_NONE )
        --    self:AddNewModifier(self, ability, modifier, {})
        --end
        return true
    end
    return false
end

function C_DOTA_BaseNPC:FindTalentValue(talentName, key)
    talentName = string.lower(talentName)
    if self:HasTalent(talentName) then
        local value_name = key or "value"
        return self:FindAbilityByName(talentName):GetSpecialValueFor(value_name)
    end
    return 0
end

function C_DOTA_BaseNPC:HasShard()
    if self:HasModifier("modifier_item_aghanims_shard") then
        return true
    end

    return false
end
