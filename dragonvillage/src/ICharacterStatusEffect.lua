-------------------------------------
-- interface ICharacterStatusEffect
-------------------------------------
ICharacterStatusEffect = {
    m_mStatusEffect = 'table',
    m_mHiddenStatusEffect = 'table',-- 숨겨져서 노출되지 않는 상태효과(리더, 패시브)

    m_lStatusIcon = 'sprite table',
    m_mStatusEffectCC = 'table',    -- 적용중인 cc효과를 가진 status effect
}

-------------------------------------
-- function init
-------------------------------------
function ICharacterStatusEffect:init()
    self.m_mStatusEffect = {}
    self.m_mHiddenStatusEffect = {}
	self.m_lStatusIcon = {}
    self.m_mStatusEffectCC = {}
end

-------------------------------------
-- function updateStatusEffect
-------------------------------------
function ICharacterStatusEffect:updateStatusEffect(dt)
	local count = 1
	for type, status_effect in pairs(self.m_mStatusEffect) do
        local status_effect_type = status_effect:getTypeName()
        local icon = self.m_lStatusIcon[status_effect_type]
        if (status_effect.m_bApply) then
		    self:setStatusIcon(status_effect, count)
		    count = count + 1
            if (icon) then
                icon.m_icon:setVisible(true)
            end
        else
            if (icon) then
                icon.m_icon:setVisible(false)
            end
        end
	end

	for i, v in pairs(self.m_lStatusIcon) do
		v:update(dt)
	end
end


-------------------------------------
-- function setStatusIcon
-------------------------------------
function ICharacterStatusEffect:setStatusIcon(status_effect, idx)
	local status_effect_type = status_effect:getTypeName()
	local idx = idx 

	-- icon 생성 또는 있는것에 접근
	local icon = nil
	if (self.m_lStatusIcon[status_effect_type]) then 
		icon = self.m_lStatusIcon[status_effect_type]
	else
		icon = StatusEffectIcon(self, status_effect)

        self.m_lStatusIcon[status_effect_type] = icon
	end
end

-------------------------------------
-- function removeStatusIcon
-------------------------------------
function ICharacterStatusEffect:removeStatusIcon(status_effect)
	local status_effect_type = status_effect:getTypeName()
	self.m_lStatusIcon[status_effect_type] = nil
end


-------------------------------------
-- function insertStatusEffect
-------------------------------------
function ICharacterStatusEffect:insertStatusEffect(status_effect)
	local effect_name = status_effect.m_statusEffectName
	
    -- 해제되지 않고 계속 유지되는 것들은 리스트에 추가하지 않음
	if (StatusEffectHelper:isHidden(effect_name)) then
        self.m_mHiddenStatusEffect[effect_name] = status_effect
    else
        self.m_mStatusEffect[effect_name] = status_effect
    end
end

-------------------------------------
-- function removeStatusEffect
-------------------------------------
function ICharacterStatusEffect:removeStatusEffect(status_effect)
	local effect_name = status_effect.m_statusEffectName
    if (not effect_name) then return end

	self.m_mStatusEffect[effect_name] = nil
end

-------------------------------------
-- function getStatusEffect
-------------------------------------
function ICharacterStatusEffect:getStatusEffect(status_effect_type)
	return self.m_mStatusEffect[status_effect_type]
end

-------------------------------------
-- function getStatusEffectList
-------------------------------------
function ICharacterStatusEffect:getStatusEffectList()
	return self.m_mStatusEffect
end

-------------------------------------
-- function getHiddenStatusEffectList
-------------------------------------
function ICharacterStatusEffect:getHiddenStatusEffectList()
	return self.m_mHiddenStatusEffect
end

-------------------------------------
-- function getStatusEffectCount
-- @breif 파라미터의 칼럼과 값으로부터 동일한 상태효과가 존재하는 카운트를 리턴
-------------------------------------
function ICharacterStatusEffect:getStatusEffectCount(column, value)
    local count = 0

    if (column) then
        for type, status_effect in pairs(self:getStatusEffectList()) do
            local t_status_effect = TableStatusEffect():get(type)
            if (t_status_effect and t_status_effect[column] == value) then
                count = count + status_effect:getOverlabCount()
            end
        end

        for type, status_effect in pairs(self:getHiddenStatusEffectList()) do
            local t_status_effect = TableStatusEffect():get(type)
            if (t_status_effect and t_status_effect[column] == value) then
                count = count + status_effect:getOverlabCount()
            end
        end
    else
        for type, status_effect in pairs(self:getStatusEffectList()) do
            if (string.find(type, value)) then
                count = count + status_effect:getOverlabCount()
            end
        end

        for type, status_effect in pairs(self:getHiddenStatusEffectList()) do
            if (string.find(type, value)) then
                count = count + status_effect:getOverlabCount()
            end
        end
    end

    return count
end

-------------------------------------
-- function isExistStatusEffectName
-- @breif 해당 이름을 포함한 상태효과가 존재하는지 여부
-------------------------------------
function ICharacterStatusEffect:isExistStatusEffectName(name, except_name)
    local b = false

    for type, status_effect in pairs(self:getStatusEffectList()) do
        if (string.find(type, name) and type ~= except_name) then
            b = true
            break
        end
    end

    for type, status_effect in pairs(self:getHiddenStatusEffectList()) do
        if (string.find(type, name) and type ~= except_name) then
            b = true
            break
        end
    end

    return b
end

-------------------------------------
-- function isExistStatusEffect
-- @breif 파라미터의 칼럼과 값으로부터 동일한 상태효과가 존재하는지 여부
-------------------------------------
function ICharacterStatusEffect:isExistStatusEffect(column, value)
    local b = false

    for type, status_effect in pairs(self:getStatusEffectList()) do
        local t_status_effect = TableStatusEffect():get(type)
        if (t_status_effect and t_status_effect[column] == value) then
            b = true
            break
        end
    end

    for type, status_effect in pairs(self:getHiddenStatusEffectList()) do
        local t_status_effect = TableStatusEffect():get(type)
        if (t_status_effect and t_status_effect[column] == value) then
            b = true
            break
        end
    end

    return b
end

-------------------------------------
-- function hasHarmfulStatusEffect
-- @breif 해로운 상태효과가 있는지 검사한다.
-------------------------------------
function ICharacterStatusEffect:hasHarmfulStatusEffect()
	for _, status_effect in pairs(self.m_mStatusEffect) do
		if StatusEffectHelper:isHarmful(status_effect) then
			return true
		end
	end

	return false
end

-------------------------------------
-- function hasHelpfulStatusEffect
-- @breif 이로운 상태효과가 있는지 검사한다.
-------------------------------------
function ICharacterStatusEffect:hasHelpfulStatusEffect()
	for _, status_effect in pairs(self.m_mStatusEffect) do
		if StatusEffectHelper:isHelpful(status_effect) then
			return true
		end
	end

	return false
end

-------------------------------------
-- function addGroggy
-------------------------------------
function ICharacterStatusEffect:addGroggy(statusEffectName)
    self.m_mStatusEffectCC[statusEffectName] = true
end

-------------------------------------
-- function removeGroggy
-------------------------------------
function ICharacterStatusEffect:removeGroggy(statusEffectName)
    if (statusEffectName) then
        self.m_mStatusEffectCC[statusEffectName] = nil
    else
        self.m_mStatusEffectCC = {}
    end
end

-------------------------------------
-- function hasGroggyStatusEffect
-------------------------------------
function ICharacterStatusEffect:hasGroggyStatusEffect()
    return (table.count(self.m_mStatusEffectCC) > 0)
end

-------------------------------------
-- function getCloneTable
-------------------------------------
function ICharacterStatusEffect:getCloneTable()
	return clone(ICharacterStatusEffect)
end

-------------------------------------
-- function getCloneClass
-------------------------------------
function ICharacterStatusEffect:getCloneClass()
	return class(clone(ICharacterStatusEffect))
end
