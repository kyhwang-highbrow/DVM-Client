-------------------------------------
-- class StructAdventureChapterAchieveInfo
-- @instance chap_achieve_info
-------------------------------------
StructAdventureChapterAchieveInfo = class({
        chapter_id = 'number',
        star = 'number',
        m_receivedList = 'List[boolean]',
    })

-------------------------------------
-- function init
-------------------------------------
function StructAdventureChapterAchieveInfo:init(data)
    self.m_receivedList = {}

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructAdventureChapterAchieveInfo:applyTableData(data)    
    for i,v in pairs(data) do
        if pl.stringx.startswith(i, 'received_') then
            local idx_str = pl.stringx.replace(i, 'received_', '', 1)
            local idx_num = tonumber(idx_str)
            self.m_receivedList[idx_num] = v
        else
            self[i] = v
        end
    end
end

-------------------------------------
-- function getAchievedStars
-------------------------------------
function StructAdventureChapterAchieveInfo:getAchievedStars()
    local stars = (self.star or 0)
    return stars
end

-------------------------------------
-- function getAchievedStarsPercent
-------------------------------------
function StructAdventureChapterAchieveInfo:getAchievedStarsPercent()
    local stars = self:getAchievedStars()
    local max = MAX_ADVENTURE_STAGE * 3 -- 스테이지 1개당 별 3개

    local percent = (stars / max) * 100
    return percent
end

-------------------------------------
-- function isExist
-------------------------------------
function StructAdventureChapterAchieveInfo:isExist(star)
    if (self.m_receivedList[star] ~= nil) then
        return true
    end

    local t_chap_achieve_data = g_adventureData:getChapterAchieveData(self.chapter_id)
    if (not t_chap_achieve_data) then
        return false
    end

    local reward_str = t_chap_achieve_data['reward_' .. star]
    if reward_str and (reward_str ~= '') then
        return true
    end

    return false
end

-------------------------------------
-- function isReceived
-------------------------------------
function StructAdventureChapterAchieveInfo:isReceived(star)
    local is_received = (self.m_receivedList[star] or false)
    return is_received
end

-------------------------------------
-- function getRewardBoxState
-------------------------------------
function StructAdventureChapterAchieveInfo:getRewardBoxState(star)
    local achieved_stars = self:getAchievedStars()
    local is_received = self:isReceived(star)

    -- 별 갯수를 달성하지 못한 경우
    if (achieved_stars < star) then
        return 'lock'

    -- 별 갯수를 달성하였지만 보상을 받지 않은 경우
    elseif (achieved_stars >= star) and (is_received == false) then
        return 'open'

    -- 보상까지 받은 경우
    else
        return 'received'
    end
end