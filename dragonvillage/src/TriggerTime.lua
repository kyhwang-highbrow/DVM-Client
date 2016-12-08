-------------------------------------
-- class TriggerTime
-------------------------------------
TriggerTime = class({
        m_owner = 'Character',
        m_bActive = 'boolean',
        m_bUsed = 'boolean',    -- 사용되었는지 여부

        m_priority = 'number',
        m_lPatternList = 'table',
        m_currIdx = 'number',

        m_tCurrPattern = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function TriggerTime:init(owner, t_time_trriger)
    self.m_owner = owner

    self.m_bActive = false
    self.m_bUsed = false
    self.m_priority = (t_time_trriger['priority'] or 0)

    self.m_lPatternList = {}
    for i,v in pairs(t_time_trriger['list']) do
        table.insert(self.m_lPatternList, v)
    end

    table.sort(self.m_lPatternList, function(a, b)
        return (a['time'] < b['time'])
    end)

    self.m_currIdx = 1
end

-------------------------------------
-- function checkTrigger
-------------------------------------
function TriggerTime:checkTrigger(time)
    local t_data = self.m_lPatternList[self.m_currIdx]

    if (self.m_bUsed) then
        return
    end

    if (not t_data) then
        return
    end

    if (t_data['time'] > time) then
        return
    end

    self.m_tCurrPattern = t_data['pattern']
    self.m_bActive = true
    self.m_bUsed = true
    self.m_currIdx = self.m_currIdx + 1

    do -- 변경된 패턴을 패턴 리스트에 추가
        local idx = self.m_owner.m_currPatternIdx

        for i, v in ipairs(self.m_tCurrPattern) do
            table.insert(self.m_owner.m_tCurrPattern, idx + i, v)
        end
    end
end