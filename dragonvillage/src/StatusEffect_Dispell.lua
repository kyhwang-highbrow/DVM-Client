local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Dispell
-- @breif 디버프 해제
-------------------------------------
StatusEffect_Dispell = class(PARENT, {
        m_resDispellEffect = 'string',
		m_releaseCnt = 'number', 

        m_bDispellAll = 'boolean',
        m_dispellTarget = 'table',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Dispell:init(file_name, body, ...)
    self.m_bDispellAll = false
    self.m_dispellTarget = {}

    self.m_bStopUntilSkillEnd = false
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
        self.m_dispellTarget[i] = {}

        local str = t_status_effect['val_' .. i]
        if (str and str ~= '')then 
            if (str == 'all') then
                self.m_bDispellAll = true
                break
            else
                local temp = pl.stringx.split(str, ';')
                local column = temp[1]
                local value = temp[2]
        
                self.m_dispellTarget[i][column] = value
            end
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
-- function onApplyOverlab
-------------------------------------
function StatusEffect_Dispell:onApplyOverlab(unit)
    local b = false

    if (self.m_bDispellAll) then
        if (self:dispellAll()) then b = true end

    else
        for i, map in ipairs(self.m_dispellTarget) do
            for column, value in pairs(map) do
                if (column == 'category') then
                    if (value == 'good') then
                        if (self:dispellBuff()) then b = true end
                
                    elseif(value == 'bad') then
                        if (self:dispellDebuff()) then b = true end
                    end
                else
                    if (self:dispell(column, value)) then b = true end
                end
                
                if (self.m_releaseCnt <= 0) then break end
            end

            if (self.m_releaseCnt <= 0) then break end
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
-- function dispell
-------------------------------------
function StatusEffect_Dispell:dispell(column, value)
    local b = false

    for name, status_effect in pairs(self.m_owner:getStatusEffectList()) do
        if (status_effect:isErasable()) then
            local t_status_effect = status_effect.m_statusEffectTable
            if (t_status_effect[column] == value) then
                -- 중첩 수만큼 순회하면서 하나씩 삭제
                local overlap_cnt = status_effect:getOverlabCount()
                for i = 1, overlap_cnt do
                    if (status_effect:removeOverlabUnit()) then
                        b = true
                        self.m_releaseCnt = self.m_releaseCnt - 1

                        if (self.m_releaseCnt <= 0) then break end
                    else
                        break
                    end
                end
            end
        end

        if (self.m_releaseCnt <= 0) then break end
    end

    return b
end

-------------------------------------
-- function dispellDebuff
-- @brief 디버프 해제
-------------------------------------
function StatusEffect_Dispell:dispellDebuff(name)
    local b, release_cnt = StatusEffectHelper:releaseStatusEffectDebuff(self.m_owner, self.m_releaseCnt, name)

    self.m_releaseCnt = self.m_releaseCnt - release_cnt

    return b
end

-------------------------------------
-- function dispellBuff
-- @brief 버프 해제
-------------------------------------
function StatusEffect_Dispell:dispellBuff(name)
	local b, release_cnt = StatusEffectHelper:releaseStatusEffectBuff(self.m_owner, self.m_releaseCnt, name)

    self.m_releaseCnt = self.m_releaseCnt - release_cnt

    return b
end

-------------------------------------
-- function dispellAll
-- @brief 전부 해제, 버프 숫자도 제한이 없다.
-------------------------------------
function StatusEffect_Dispell:dispellAll()
	return StatusEffectHelper:releaseStatusEffectAll(self.m_owner)
end