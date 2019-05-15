-------------------------------------
-- class StructEventIllusion
-------------------------------------
StructEventIllusion = class({
        m_eventId = 'number',   -- 이벤트 아이디 ex) 1 = 삐에로 던전, 2 = 앙그라 던전....
        m_lEventDid = 'list',   -- 이벤트에서 체험 가능한 드래곤 아이디 리스트 
        m_stageId = 'number',   -- 이벤트 스테이지 아이디  ex) 1911001 죄악의 던전
        m_stageDiff = 'number', -- 1 = 쉬움, 2 = 보통 .. 등등
        m_eventType = 'string', -- legend or hero
    })

StructEventIllusion.STATE = {
	['INACTIVE'] = 1,	-- 이벤트 던전 비활성화
	['LOCK'] = 2,		-- 레벨 제한
	['OPEN'] = 3,		-- 이벤트 던전 입장 가능
	['REWARD'] = 4,		-- 보상 수령 가능
	['DONE'] = 5,		-- 보상 수령 후 
}

-------------------------------------
-- function init
-------------------------------------
function StructEventIllusion:init(event_id)
    self.m_eventId = tonumber(event_id)

    local table_illusion = TABLE:get('table_illusion')
    local t_illusion = table_illusion[self.m_eventId]
    
    if (not t_illusion) then
        return
    end
    
    local event_did_str = t_illusion['event_did'] or ''
    self.m_lEventDid = self:makeEventDidList(event_did_str)
    self.m_stageId = t_illusion['stage_id'] or 1911001
    self.m_eventType = t_illusion['event_type'] or 'hero'
end

-------------------------------------
-- function makeEventDidList
-------------------------------------
function StructEventIllusion:makeEventDidList(event_did_str) -- param : 120301, 120302, 120303, 120304, 120305
    local l_did = plSplit(event_did_str, ',')
    return l_did or {}
end

-------------------------------------
-- function getIllusionStageId
-------------------------------------
function StructEventIllusion:getIllusionStageId()
    return self.m_stageId
end

-------------------------------------
-- function getIllusionDragonList
-------------------------------------
function StructEventIllusion:getIllusionDragonList()
    return self.m_lEventDid
end

-------------------------------------
-- function getIllusionState
-- @brief 환상 던전의 상태 
-------------------------------------
function StructEventIllusion:getIllusionState()
    local illusion_key = string.format('event_illusion_%s', self.m_eventType)
	-- 이벤트 기간
	if (g_hotTimeData:isActiveEvent(illusion_key)) then
		--[[
		-- 레벨 체크
		if (g_contentLockData:isContentLock('challenge_mode')) then
			return ServerData_ChallengeMode.STATE['LOCK']

		else
        --]]
			return StructEventIllusion.STATE['OPEN']
		--end

	-- 보상 수령 기간
	elseif (g_hotTimeData:isActiveEvent(illusion_key .. '_reward')) then
		--[[
		-- 레벨 체크
		if (g_contentLockData:isContentLock('challenge_mode')) then
			return ServerData_ChallengeMode.STATE['LOCK']
        
		-- 보상 수령 전 (0 -> 이번 시즌 보상 받을게 있음)
		if (self.m_seasonRewardStatus == 0) then
			return StructEventIllusion.STATE['REWARD']

		-- 보상 수령 후 (1 -> 이번 시즌 보상 받음, 2 -> 이번 시즌 보상 받을게 없음)
		elseif (self.m_seasonRewardStatus == 1) or (self.m_seasonRewardStatus == 2) then
			return StructEventIllusion.STATE['DONE']

		end
        --]]
	end
    
    -- 해당 없으면 비활성화
	return ServerData_ChallengeMode.STATE['INACTIVE']
end




