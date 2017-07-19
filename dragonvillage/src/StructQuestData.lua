-------------------------------------
-- class StructQuestData
-- @brief
-------------------------------------
StructQuestData = class({
        qid = 'number',
        rawcnt = 'number',      -- 조건 달성 횟수
        quest_type = 'string',
        t_quest = 'quest table info',
        reward = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function StructQuestData:init(data)
    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructQuestData:applyTableData(data)
    for i,v in pairs(data) do
        self[i] = v
    end
end

-------------------------------------
-- function hasReward
-- @breif 획득 가능한 보상이 있는지 여부
-------------------------------------
function StructQuestData:hasReward()
    return self['reward']
end

-------------------------------------
-- function isQuestEnded
-- @breif 퀘스트의 모든 스탭이 종료되었는지 여부
-------------------------------------
function StructQuestData:isQuestEnded()
    return false
end

-------------------------------------
-- function getQuestDesc
-- @breif 퀘스트 설명
-------------------------------------
function StructQuestData:getQuestDesc()
    local t_quest = self['t_quest']
    local t_desc = t_quest['t_desc']
    local value = t_quest['clear_value']

    t_desc = Str(t_desc, value)
    return t_desc
end

-------------------------------------
-- function getRewardInfoList
-- @breif
-------------------------------------
function StructQuestData:getRewardInfoList()
    local t_quest = self['t_quest']
    return t_quest['t_reward']
end

-------------------------------------
-- function getProgressInfo
-- @breif
-------------------------------------
function StructQuestData:getProgressInfo()
    local t_quest = self['t_quest']

    local goal = t_quest['clear_value']
    local raw_cnt = self['rawcnt']

    -- 진행 정도 표시
    local percentage = (raw_cnt / goal) * 100

    -- 목표치보다 초과 달성했을 경우 보정
    local achieve_cnt = math_min(raw_cnt, goal)
    local text = achieve_cnt .. ' / ' .. goal

    return percentage, text
end