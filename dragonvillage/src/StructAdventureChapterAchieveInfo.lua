-------------------------------------
-- class StructAdventureChapterAchieveInfo
-- @instance chap_achieve_info
-------------------------------------
StructAdventureChapterAchieveInfo = class({
        chapter_id = 'number',
        star = 'number',
        received_8 = 'boolean',
        received_16 = 'boolean',
        received_24 = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function StructAdventureChapterAchieveInfo:init(data)
    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructAdventureChapterAchieveInfo:applyTableData(data)
    for i,v in pairs(data) do
        self[i] = v
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
    local max = 24

    local percent = (stars / max) * 100
    return percent
end

-------------------------------------
-- function isReceived
-------------------------------------
function StructAdventureChapterAchieveInfo:isReceived(star)
    local is_received = (self['received_' .. star] or false)
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