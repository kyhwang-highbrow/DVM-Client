local PARENT = Structure

-------------------------------------
-- class StructEventIllusion
-------------------------------------
StructEventIllusion = class(PARENT,{     
        score = 'number',
        last_stage = 'number',
        token = 'number',
        event_id = 'number',   -- 이벤트 아이디 ex) 1 = 삐에로 던전, 2 = 앙그라 던전....
        rank = 'number',
        remain_token = 'number', -- 일일 최대 획득량 - 획득량
        daily_max_token = 'number', -- 일일 최대 획득량
        
        ---------------------------------------------------------------------------------------
        -- 토컬 테이블로 필요한 정보 가공
        ---------------------------------------------------------------------------------------       
        m_lEventDid = 'list',   -- 이벤트에서 체험 가능한 드래곤 아이디 리스트 
        m_l_stageId = 'number',   -- 이벤트 스테이지 아이디  ex) 1911001 죄악의 던전
        m_stageDiff = 'number', -- 1 = 쉬움, 2 = 보통 .. 등등
        m_eventType = 'string', -- legend or hero

        m_curStageId = 'number', -- 선택한 스테이지     
    })

local MAX_STAGE = 4

local THIS = StructEventIllusion

-------------------------------------
-- function init
-------------------------------------
function StructEventIllusion:init(t_data)
    local table_illusion = TABLE:get('table_illusion')
    local t_illusion = table_illusion[self.event_id]
    
    if (not t_illusion) then
        return
    end
    
    local event_did_str = tostring(t_illusion['event_did']) or ''
    self.m_lEventDid = self:makeEventDidList(event_did_str)
    self.m_eventType = 1 -- 레전드 던전으로 고정
    
    self.m_l_stageId = {}
    local first_stage = t_illusion['stage_id']
    for i = 0, MAX_STAGE-1 do
        local stage_id = first_stage + i * 1000
        local t_stage = {}
        t_stage['stage'] = stage_id
        table.insert(self.m_l_stageId, t_stage)
    end 

    -- 디폴트로 현재 스테이지 설정
    self.m_curStageId = self.m_l_stageId[1]['stage']
end

-------------------------------------
-- function getThis
-- @brief 클래스를 리턴 (classDef)
-------------------------------------
function StructEventIllusion:getThis()
    return THIS
end

-------------------------------------
-- function getClassName
-- @brief 클래스명 리턴
-------------------------------------
function StructEventIllusion:getClassName()
    return 'StructEventIllusion'
end

-------------------------------------
-- function makeEventDidList
-------------------------------------
function StructEventIllusion:makeEventDidList(event_did_str) -- param : 120301, 120302, 120303, 120304, 120305
    local l_did = plSplit(event_did_str, ',')
    return l_did or {}
end







----------------------------------------------------------------------------------------------------
-- get/set 함수
----------------------------------------------------------------------------------------------------


-------------------------------------
-- function getIllusionStageId
-------------------------------------
function StructEventIllusion:getCurIllusionStageId()
    return self.m_curStageId
end

-------------------------------------
-- function getIllusionStageId
-------------------------------------
function StructEventIllusion:setCurIllusionStageId(stage_id)
    self.m_curStageId = stage_id
end

-------------------------------------
-- function getIllusionDragonList
-------------------------------------
function StructEventIllusion:getIllusionDragonList()
    return self.m_lEventDid
end

-------------------------------------
-- function getIllusionStageList
-------------------------------------
function StructEventIllusion:getIllusionStageList()
    return self.m_l_stageId or {}
end

-------------------------------------
-- function getIllusionHighestScore
-------------------------------------
function StructEventIllusion:getIllusionHighestScore()
    return self.score or 0
end

-------------------------------------
-- function getIllusionLastStage
-------------------------------------
function StructEventIllusion:getIllusionLastStage()
    return self.last_stage or self.m_curStageId
end




