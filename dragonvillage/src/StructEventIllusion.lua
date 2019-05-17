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




