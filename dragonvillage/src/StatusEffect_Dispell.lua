local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Dispell
-- @breif 디버프 해제
-------------------------------------
StatusEffect_Dispell = class(PARENT, {
        m_resDispellEffect = 'string',
		m_releaseCnt = 'number', 
        m_dispellTarget = 'table',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Dispell:init(file_name, body, ...)
    self.m_dispellTarget = {}
end

-------------------------------------
-- function init_status
-------------------------------------
function StatusEffect_Dispell:init_status(status_effect_type, status_effect_value)
	self.m_releaseCnt = status_effect_value
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_Dispell:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    -- 이펙트 이름을 얻어옴
    if (t_status_effect['res_2'] and t_status_effect['res_2'] ~= '') then
        self.m_resDispellEffect = t_status_effect['res_2']
    end

    -- val 값은 all이거나 category;good/bad 이거나 name;이름 의 형태.
    for i = 1, 4 do
        local str = t_status_effect['val_' .. i]
        if (str and str ~= '')then 
            if (str == 'all') then
                self.m_dispellTarget['all'] = str
                break
            end
            local temp = pl.stringx.split(str, ';')
            local column = temp[1]
            local value = temp[2]
        
            self.m_dispellTarget[column] = value
        end
    end
end

-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_Dispell:onEnd()
    if (self.m_resDispellEffect) then
        self.m_world:addInstantEffect(self.m_resDispellEffect, 'center_idle', self.m_owner.pos.x, self.m_owner.pos.y)
    end
end

-------------------------------------
-- function onStart
-------------------------------------
function StatusEffect_Dispell:onApplyOverlab(unit)
    for k, v in pairs(self.m_dispellTarget) do
		-- 디스펠 시전
        if (k == 'all') then
            self:dispellAll()

        elseif (k == 'category') then
            if (v == 'good') then
                self:dispellBuff()
            elseif(v == 'bad') then
                self:dispellDebuff()
            end

        elseif (k == 'name') then
            if (StatusEffectHelper:isHarmful(v)) then
                self:dispellBuff(v)
            else
                self:dispellDebuff(v)
            end
        end
    end

    -- !! unit을 바로 삭제하여 해당 상태효과 종료시킴
    unit:finish()
end

-------------------------------------
-- function dispellDebuff
-- @brief 디버프 해제
-------------------------------------
function StatusEffect_Dispell:dispellDebuff(name)
    if (not name) then
	    StatusEffectHelper:releaseStatusEffectDebuff(self.m_owner, self.m_releaseCnt)
    else 
        StatusEffectHelper:releaseStatusEffectDebuff(self.m_owner, self.m_releaseCnt, name)
    end
end

-------------------------------------
-- function dispellBuff
-- @brief 버프 해제
-------------------------------------
function StatusEffect_Dispell:dispellBuff(name)
	if (not name) then
	    StatusEffectHelper:releaseStatusEffectBuff(self.m_owner, self.m_releaseCnt)
    else 
        StatusEffectHelper:releaseStatusEffectBuff(self.m_owner, self.m_releaseCnt, name)
    end
end

-------------------------------------
-- function dispellAll
-- @brief 전부 해제, 버프 숫자도 제한이 없다.
-------------------------------------
function StatusEffect_Dispell:dispellAll()
	StatusEffectHelper:releaseStatusEffectAll(self.m_owner)
end