local PARENT = Structure

-------------------------------------
-- class StructBattlePassInfo
-- @brief 
-------------------------------------
StructBattlePassInfo = class(PARENT, {
        
        m_curExp = 'number',
        m_maxExp = 'number',

        
    })


-------------------------------------
-- function init
-------------------------------------
function StructBattlePassInfo:init(data)
    self.m_RewardList = {}
end

-------------------------------------
-- function updateInfo
-- 전체 데이터 업뎃
-------------------------------------
function StructBattlePassInfo:updateInfo(data)
    self.m_battlePassData = data
end

-------------------------------------
-- function getRewardList
-------------------------------------
function StructBattlePassInfo:getRewardList(passId)
    local tResult = {}
    if (not self.m_RewardList) then return tResult end

    return self.m_RewardList
end

-------------------------------------
-- function getExp
-- curExp, maxExp 반환
-------------------------------------
function StructBattlePassInfo:getExp()
    if (not self.m_curExp or not self.m_maxExp) then return 0, 0 end

    return self.m_curExp, self.m_maxExp
end


local THIS = StructBattlePassInfo
