-------------------------------------
-- class StructQuestData
-- @brief
-------------------------------------
StructQuestData = class({
        qid = 'number',
        m_type = 'string',
        rawcnt = 'number',      -- 조건 달성 횟수
        

        m_achieveCnt = 'number',

        m_clearStep = 'number',
        m_rewardStep = 'number',

        m_maxStep = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function StructQuestData:init(data)
    if data then
        self:applyTableData(data)
    end

    local table_quest = TableQuest()
    local qid = self.qid
    self.m_type = table_quest:getQuestType(qid)
    self.m_maxStep = table_quest:getMaxStep(qid)
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructQuestData:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    replacement['clearcnt'] = 'm_clearStep'
    replacement['rewardcnt'] = 'm_rewardStep'
    replacement['rawcnt'] = 'm_achieveCnt'
    


    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function isLock
-- @breif
-------------------------------------
function StructQuestData:isLock()
    if self:isNewbieQuest() then
        if (self.qid > g_questData.m_focusNewbieQid) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function hasReward
-- @breif 획득 가능한 보상이 있는지 여부
-------------------------------------
function StructQuestData:hasReward()
    if self:isLock() then
        return false
    end

    local has_reward = (self.m_clearStep > self.m_rewardStep)
    return has_reward
end

-------------------------------------
-- function isQuestEnded
-- @breif 퀘스트의 모든 스탭이 종료되었는지 여부
-------------------------------------
function StructQuestData:isQuestEnded()
    local is_quest_ended = (self.m_maxStep <= self.m_rewardStep)
    return is_quest_ended
end

-------------------------------------
-- function getQuestDesc
-- @breif 퀘스트 설명
-------------------------------------
function StructQuestData:getQuestDesc()
    local qid = self.qid

    local t_desc = TableQuest:getQuestDesc(qid)

    local unit = TableQuest:getQuestUnit(qid)
    local goal = (unit * self:getGoalStep())

    t_desc = Str(t_desc, goal)
    return t_desc
end

-------------------------------------
-- function getRewardInfoList
-- @breif
-------------------------------------
function StructQuestData:getRewardInfoList()
    local qid = self.qid
    local step = self:getGoalStep()

    local l_item_list = TableQuest:getRewardInfoList(qid, step)
    return l_item_list
end

-------------------------------------
-- function getProgressInfo
-- @breif
-------------------------------------
function StructQuestData:getProgressInfo()
    local qid = self.qid

    local unit = TableQuest:getQuestUnit(qid)
    local goal = (unit * self:getGoalStep())

    -- 진행 정도 표시
    local percentage = (self.m_achieveCnt / goal) * 100

    -- 목표치보다 초과 달성했을 경우 보정
    local achieve_cnt = math_min(self.m_achieveCnt, goal)
    local text = achieve_cnt .. ' / ' .. goal

    return percentage, text
end

-------------------------------------
-- function getGoalStep
-- @breif
-------------------------------------
function StructQuestData:getGoalStep()
    local goal_step = math_min(self.m_rewardStep + 1, self.m_maxStep)
    return goal_step
end

-------------------------------------
-- function isNewbieQuest
-- @breif
-------------------------------------
function StructQuestData:isNewbieQuest()
    return (self.m_type == 'newbie')
end