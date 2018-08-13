-------------------------------------
-- table MasteryHelper
-------------------------------------
MasteryHelper = {}

MasteryHelper.MAX_TIER = 4
MasteryHelper.LAST_TIER = MasteryHelper.MAX_TIER
MasteryHelper.MAX_NUM = 3

MasteryHelper.MAX_LEVEL_IN_TIER = 3


-------------------------------------
-- function getMasteryTierState
-- @brief
-- @return
-------------------------------------
function MasteryHelper:getMasteryTierState(dragon_obj, tier)
    -- 이전 단계 완료 후 가능
    if (1 < tier) then
        local total_level = self:getMasteryTierTotalLevel(dragon_obj, tier-1)
        if (total_level < self:getMaxLevelInTier(tier - 1)) then
            return -1
        end
    end

    -- 스킬 레벨업 가능
    local total_level = self:getMasteryTierTotalLevel(dragon_obj, tier)
    if (total_level < self:getMaxLevelInTier(tier)) then
        return 0
    end

    -- 스킬 레벨업 완료
    if (total_level == self:getMaxLevelInTier(tier)) then
        return 1
    end

    error()
end

-------------------------------------
-- function getMasteryTierStateStr
-- @brief
-- @return
-------------------------------------
function MasteryHelper:getMasteryTierStateStr(dragon_obj, tier, is_rich_text)
    local state = self:getMasteryTierState(dragon_obj, tier)

    local str = ''

    if (state == -1) then
        str = Str('이전 단계 완료 후 가능')

    elseif (state == 0) then
        str = Str('스킬 레벨업 가능')

    elseif (state == 1) then
        str = Str('스킬 레벨업 완료')

    end

    local curr_total_lv = self:getMasteryTierTotalLevel(dragon_obj, tier)
    local max_total_lv = self:getMaxLevelInTier(tier)
    str = str .. Str(' {1}/{2}', curr_total_lv, max_total_lv)

    if is_rich_text then
        if (state == 0) then
            str = '{@green}' .. str
        else
            str = '{@dark_brown}' .. str
        end
    end

    return str
end

-------------------------------------
-- function getMasteryTierTotalLevel
-- @brief
-- @return
-------------------------------------
function MasteryHelper:getMasteryTierTotalLevel(dragon_obj, tier)
    local total_lv = 0

    local max_num = self:getMaxNum(tier)
    for num=1, max_num do
        local mastery_skill_id = self:makeMasterySkillID(dragon_obj, tier, num)
        local mastery_skill_lv = dragon_obj:getMasterySkilLevel(mastery_skill_id)
        total_lv = (total_lv + mastery_skill_lv)
    end

    return total_lv
end

-------------------------------------
-- function makeMasterySkillID
-- @brief
-- @return
-------------------------------------
function MasteryHelper:makeMasterySkillID(dragon_obj, tier, num)
    local rarity_str = dragon_obj:getRarity()
    local role_str = dragon_obj:getRole()

    -- 특성 스킬 ID
    local mastery_skill_id = TableMasterySkill:makeMasterySkillID(rarity_str, role_str, tier, num)
    return mastery_skill_id
end

-------------------------------------
-- function getMaxNum
-- @brief
-- @return
-------------------------------------
function MasteryHelper:getMaxNum(tier)
    local max_num = MasteryHelper.MAX_NUM
    return max_num
end

-------------------------------------
-- function getMaxLevelInTier
-- @brief
-- @return
-------------------------------------
function MasteryHelper:getMaxLevelInTier(tier)
    -- 마지막 티어는 1개만 찍을 수 있음
    local max_level_in_tier = MasteryHelper.MAX_LEVEL_IN_TIER

    if (tier == MasteryHelper.LAST_TIER) then
        max_level_in_tier = 1
    end
    return max_level_in_tier
end

-------------------------------------
-- function possibleMasteryReset
-- @brief 특성 초기화가 가능한지 여부 리턴
-- @return boolean 초기화가 가능하면 true
-------------------------------------
function MasteryHelper:possibleMasteryReset(dragon_obj)
    if (not dragon_obj) then
        return false
    end

    local t_skill_lv_map = dragon_obj:getMasterySkillsTable()
    local used_skill_point = 0
    for _,lv in pairs(t_skill_lv_map) do
        used_skill_point = (used_skill_point + lv)
    end

    -- 사용한 스킬 포인트가 있을 경우 초기화 가능
    if (0 < used_skill_point) then
        return true
    end

    return false
end

-------------------------------------
-- function getMasteryResetPrice
-- @brief 특성 초기화 가격 (망각의 서 수량)
-- @return number
-------------------------------------
function MasteryHelper:getMasteryResetPrice(dragon_obj)

-- 서버에서 사용하는
-- table_management_variable.csv에서 정의되어있음
-- mastery_reset_common, mastery_reset_rare, mastery_reset_hero, mastery_reset_legend

    local rarity = dragon_obj:getRarity()

    local price = 0

    if (rarity == 'common') then
        price = 1

    elseif (rarity == 'rare') then
        price = 2

    elseif (rarity == 'hero') then
        price = 8

    elseif (rarity == 'legend') then
        price = 10

    else
        error('rarity: ' .. rarity)
    end

    return price
end