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

    -- val 값은 all이거나 category;good/bad 이거나 name;이름, type;타입 의 형태.
    for i = 1, 4 do
        local str = t_status_effect['val_' .. i]
        self.m_dispellTarget[i] = {}
        if (str and str ~= '')then 
            if (str == 'all') then
                self.m_dispellTarget[i]['all'] = str
                break
            end
            local temp = pl.stringx.split(str, ';')
            local column = temp[1]
            local value = temp[2]
        
            self.m_dispellTarget[i][column] = value
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
    local b = false

    for i, v0 in ipairs(self.m_dispellTarget) do
        for k, v in pairs(v0) do
		    -- 디스펠 시전
            if (k == 'all') then
                if (self:dispellAll()) then b = true end

            elseif (k == 'category') then
                if (v == 'good') then
                    if (self:dispellBuff()) then b = true end
                
                elseif(v == 'bad') then
                    if (self:dispellDebuff()) then b = true end
                
                end

            elseif (k == 'name') then
                local t_status_effect = TABLE:get('status_effect')
                if (StatusEffectHelper:isHarmful(t_status_effect[v]['category'])) then
                    if (self:dispellDebuff(v)) then b = true end
                else
                    if (self:dispellBuff(v)) then b = true end
                
                end
            elseif (k == 'type') then
                -- 추후 구현예정
            end
        end
    end

    -- 해제된 상태효과가 없다면 이펙트가 발생하지 않도록 함
    if (not b) then
        self.m_resDispellEffect = nil
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
	    return StatusEffectHelper:releaseStatusEffectDebuff(self.m_owner, self.m_releaseCnt)
    else 
        return StatusEffectHelper:releaseStatusEffectDebuff(self.m_owner, self.m_releaseCnt, name)
    end
end

-------------------------------------
-- function dispellBuff
-- @brief 버프 해제
-------------------------------------
function StatusEffect_Dispell:dispellBuff(name)
	if (not name) then
	    return StatusEffectHelper:releaseStatusEffectBuff(self.m_owner, self.m_releaseCnt)
    else 
        return StatusEffectHelper:releaseStatusEffectBuff(self.m_owner, self.m_releaseCnt, name)
    end
end

-------------------------------------
-- function dispellAll
-- @brief 전부 해제, 버프 숫자도 제한이 없다.
-------------------------------------
function StatusEffect_Dispell:dispellAll()
	return StatusEffectHelper:releaseStatusEffectAll(self.m_owner)
end