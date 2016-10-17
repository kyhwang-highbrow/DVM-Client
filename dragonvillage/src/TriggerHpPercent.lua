-------------------------------------
-- class TriggerHpPercent
-------------------------------------
TriggerHpPercent = class({
        m_owner = 'Character',
        m_bActive = 'boolean',
        m_priority = 'number',
        m_lPatternList = 'table',
        m_currIdx = 'number',

        m_tCurrPattern = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function TriggerHpPercent:init(owner, t_hp_trriger)
    self.m_owner = owner

    self.m_bActive = false
    self.m_priority = (t_hp_trriger['priority'] or 0)

    self.m_lPatternList = {}
    for i,v in pairs(t_hp_trriger['list']) do
        table.insert(self.m_lPatternList, v)
    end

    table.sort(self.m_lPatternList, function(a, b)
        return (a['hp_percent'] > b['hp_percent'])
    end)

    self.m_currIdx = 1
end

-------------------------------------
-- function checkTrigger
-------------------------------------
function TriggerHpPercent:checkTrigger(hp_percent)
    local t_data = self.m_lPatternList[self.m_currIdx]

    if (not t_data) then
        return
    end

    if (t_data['hp_percent'] < hp_percent) then
        return
    end

    self.m_tCurrPattern = t_data['pattern']
    self.m_bActive = true
    self.m_currIdx = self.m_currIdx + 1

    do -- 변경된 패턴 지정
        self.m_owner.m_currPatternIdx = 0
        self.m_owner.m_tCurrPattern = self.m_tCurrPattern
    end

    cclog('##############################################################')
    cclog('## checkTrigger() HP ' .. t_data['hp_percent'] .. ' 패턴 발동!')
    cclog('##############################################################')
end