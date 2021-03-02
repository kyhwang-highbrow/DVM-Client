local PARENT = Structure

-------------------------------------
-- class StructBattlePassInfo
-- @brief 
-------------------------------------
StructBattlePassInfo = class(PARENT, {
        
        m_curExp = 'number',
        m_maxExp = 'number',

        m_normalRewardInfo = 'table',     -- 일반 보상
        m_specialRewardInfo = 'table',    -- 스페셜 보상

    })


-------------------------------------
-- function init
-------------------------------------
function StructBattlePassInfo:init()
    self.m_normalRewardInfo = {}
    self.m_specialRewardInfo = {}


end

-------------------------------------
-- function updateInfo
-- 전체 데이터 업뎃
-------------------------------------
function StructBattlePassInfo:updateInfo(data)
    self.m_curExp = data['cur_exp']
    self.m_maxExp = data['max_exp']

    self.m_normalRewardInfo = data['item_list_normal']
    self.m_specialRewardInfo = data['item_list_special']
end

-------------------------------------
-- function getNormalRewardInfo
-------------------------------------
function StructBattlePassInfo:getNormalRewardInfo()
    local tResult = {}
    if (not self.m_normalRewardInfo) then return tResult end

    return self.m_normalRewardInfo
end


-------------------------------------
-- function getSpecialRewardInfo
-------------------------------------
function StructBattlePassInfo:getSpecialRewardInfo()
    local tResult = {}
    if (not self.m_specialRewardInfo) then return tResult end

    return self.m_specialRewardInfo
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
