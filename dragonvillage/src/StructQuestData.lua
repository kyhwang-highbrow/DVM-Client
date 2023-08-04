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
        is_end = 'bool',
        idx = 'number',
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
-- function getQid
-- @breif qid 리턴
-------------------------------------
function StructQuestData:getQid()
    return tonumber(self['qid'])
end

-------------------------------------
-- function hasReward
-- @breif 획득 가능한 보상이 있는지 여부
-------------------------------------
function StructQuestData:hasReward()
    return self['reward']
end

-------------------------------------
-- function isEnd
-- @breif 퀘스트의 모든 스탭이 종료되었는지 여부
-------------------------------------
function StructQuestData:isEnd()
    return self['is_end']
end

-------------------------------------
-- function isChallenge
-- @breif 퀘스트의 모든 스탭이 종료되었는지 여부
-------------------------------------
function StructQuestData:isChallenge()
    return (self['quest_type'] == TableQuest.CHALLENGE)
end

-------------------------------------
-- function isDailyType
-- @breif 일일 퀘스트 타입인지 확인
-------------------------------------
function StructQuestData:isDailyType()
    return (self['quest_type'] == TableQuest.DAILY)
end

-------------------------------------
-- function getTamerTitleStr
-- @breif
-------------------------------------
function StructQuestData:getTamerTitleStr()
    local tamer_title_id = self['t_quest']['title']
    return TableTamerTitle:getTamerTitleStr(tamer_title_id)
end

-------------------------------------
-- function getQuestClearType
-- @breif 퀘스트 key
-------------------------------------
function StructQuestData:getQuestClearType()
    return self['t_quest']['key']
end

-------------------------------------
-- function isQuest_ClearTen
-- @breif '일일 퀘스트 10개 클리어' 퀘스트 인지 확인
-------------------------------------
function StructQuestData:isQuest_ClearTen()
    local quest_key = self:getQuestClearType()
    
    -- quest_key == nil 일 경우 예외처리는
    -- 해당 함수가 값이 아니라 비교 결과를 리턴하기 때문에 따로 해주지 않음
    return (quest_key == 'dq_clear')

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
-- function getEventRewardInfoList
-- @breif 퀘스트의 이벤트 보상 정보 .. 이벤트 기간 중에만 데이터가 존재한다.
-------------------------------------
function StructQuestData:getEventRewardInfoList()
    local t_quest = self['t_quest']
    return t_quest['t_event_reward']
end

-------------------------------------
-- function getProgressInfo
-- @breif
-------------------------------------
function StructQuestData:getProgressInfo()
    local t_quest = self['t_quest']

    local goal = t_quest['clear_value']
    local raw_cnt = self['rawcnt'] or goal

    -- 진행 정도 표시
    local percentage = math_min((raw_cnt / goal) * 100, 100)
    local text = Str('{1}/{2}',comma_value(raw_cnt), comma_value(goal))

    return percentage, text
end

-------------------------------------
-- function getRewardClanExp
-- @breif
-------------------------------------
function StructQuestData:getRewardClanExp()
	local clan_exp = self['t_quest']['clan_exp']
	if (clan_exp == '') then
		return nil
	end
	return clan_exp
end

-------------------------------------
-- function getRewardIndivPassExp
-- @breif 개인 패스 경험치
-------------------------------------
function StructQuestData:getRewardIndivPassExp()
	local pass_exp = self['t_quest']['pass_exp']
	if (pass_exp == '') then
		return nil
	end
	return pass_exp
end