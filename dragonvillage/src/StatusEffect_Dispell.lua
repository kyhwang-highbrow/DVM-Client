local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Dispell
-- @breif 디버프 해제
-------------------------------------
StatusEffect_Dispell = class(PARENT, {
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
-- function initState
-------------------------------------
function StatusEffect_Dispell:initState()
    PARENT.initState(self)
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_Dispell:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)
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
-- function onStart
-------------------------------------
function StatusEffect_Dispell:onStart()
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
		-- 애니 1회 동작후 종료
		self.m_animator:addAniHandler(function()
			self:changeState('end')
		end)
    end
    self:changeState('end')
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