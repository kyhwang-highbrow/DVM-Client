-------------------------------------
-- class TriggerHpPercent
-------------------------------------
TriggerHpPercent = class({
        m_owner = 'Character',
        m_bActive = 'boolean',
        m_priority = 'number',
        m_lPatternList = 'table',
        m_currIdx = 'number',
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

    self.m_bActive = true
    self.m_currIdx = self.m_currIdx + 1

    do -- 변경된 패턴 지정
        self.m_owner.m_tOrgPattern = {}
        
        -- 원본 패턴 리스트(반복을 위한) 변경
        for i, pattern in ipairs(t_data['pattern']) do
            local pattern_info = {
                priority = self.m_priority,
                pattern = pattern
            }

            table.insert(self.m_owner.m_tOrgPattern, pattern_info)
        end

        -- 현재 패턴 리스트에서 트리거보다 우선순위가 낮은 패턴을 모두 삭제 시킴
        local t_remove = {}
        local tCurrPattern = clone(self.m_owner.m_tCurrPattern)

        for i, pattern_info in ipairs(tCurrPattern) do
            if pattern_info['priority'] <= self.m_priority then
                table.insert(t_remove, 1, i)
            end
        end

        for _, v in ipairs(t_remove) do
		    table.remove(tCurrPattern, v)
	    end

        for i, v in ipairs(self.m_owner.m_tOrgPattern) do
            table.insert(tCurrPattern, v)
        end

        self.m_owner.m_tCurrPattern = tCurrPattern
    end

	-- @TEST 보스 패턴 정보 출력
	if g_constant:get('DEBUG', 'PRINT_BOSS_PATTERN') then 
        cclog('##############################################################')
        cclog('## checkTrigger() HP ' .. t_data['hp_percent'] .. ' 패턴 발동!')
        cclog('##############################################################')

        cclog('현재 패턴 정보 : ' .. luadump(self.m_owner.m_tCurrPattern))
    end
end