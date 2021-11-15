-------------------------------------
-- interface ICharacterStatusEffect
-------------------------------------
ICharacterStatusEffect = {
    m_statusIconNode = 'cc.Node',

    m_mStatusEffect = 'table',
    m_mHiddenStatusEffect = 'table',-- 숨겨져서 노출되지 않는 상태효과(리더, 패시브)

    m_lStatusIcon = 'table',
    m_mStatusIcon = 'table',

    m_mStatusEffectGroggy = 'table',-- 그로기 효과를 가진 status effect
    m_mStatusEffectCntPerSubject = 'table',   -- status effect 수(table_status_effect의 type명을 키로 사용)
    
    m_isGroggy      = 'boolean',    -- 그로기(행동 불가 상태)
    m_isSilence     = 'boolean',    -- 침묵 (스킬 사용 불가 상태)
	m_isImmortal    = 'boolean',    -- 불사 (체력이 1이하로 내려가지 않는 상태)
    m_isZombie      = 'boolean',    -- 좀비 (죽지 않는 상태)
    m_isProtected   = 'boolean',    -- 피해면역 (피격시 데미지 0)
    m_isImmune      = 'boolean',    -- 상태효과 면역
}

-------------------------------------
-- function init
-------------------------------------
function ICharacterStatusEffect:init()
    self.m_mStatusEffect = {}
    self.m_mHiddenStatusEffect = {}

    self.m_lStatusIcon = {}
	self.m_mStatusIcon = {}

    self.m_mStatusEffectGroggy = {}
    self.m_mStatusEffectCntPerSubject = {}
    
    self.m_isGroggy = false
    self.m_isSilence = false
	self.m_isImmortal = false
    self.m_isZombie = false
    self.m_isProtected = false
    self.m_isImmune = false
end

-------------------------------------
-- function updateStatusEffect
-------------------------------------
function ICharacterStatusEffect:updateStatusEffect(dt)
    if (not self.m_statusIconNode) then return end
    
    -- 아이콘 추가
    for type, status_effect in pairs(self.m_mStatusEffect) do
        -- 아이콘이 저징되지 않은 경우 표시하지 않음
        local t_status_effect = TableStatusEffect():get(type)
        if (not t_status_effect) then
        elseif (not t_status_effect['res_icon'] or t_status_effect['res_icon'] == '') then
        elseif (not status_effect:isHidden()) then
            local status_effect_type = status_effect:getTypeName()
            local status_icon = self.m_mStatusIcon[status_effect_type]

            if (not status_icon) then
                self:addStatusIcon(status_effect)
            end
        end
	end

    -- 아이콘별 업데이트
    do
        local t_remove = {}
        local pos_idx = 1

	    for i, v in ipairs(self.m_lStatusIcon) do
            local status_effect_type = v:getStatusEffectName()
            local b_remove = true

            if (self.m_mStatusEffect[status_effect_type]) then
                b_remove = v:update(dt)
            end

            if (v.m_typeSTr ~= nil and not self:isDead()) then
                b_remove = false
            else
                v:setOverlabLabel(0)
            end

            if (b_remove) then
                table.insert(t_remove, 1, i)
                v:release()

                self.m_mStatusIcon[status_effect_type] = nil

            elseif (v:isVisible()) then
                self:setStatusIconPosition(v, pos_idx)
                
                pos_idx = pos_idx + 1

            end
	    end

        for i, v in ipairs(t_remove) do
            table.remove(self.m_lStatusIcon, v)
        end
    end
end


-------------------------------------
-- function makeStatusIconNode
-------------------------------------
function ICharacterStatusEffect:makeStatusIconNode(icon_node)
    if (icon_node) then
        if (self.m_statusIconNode) then
            self.m_statusIconNode:removeFromParent()
        end

        self.m_statusIconNode = cc.Node:create()
        self.m_statusIconNode:setDockPoint(cc.p(0.5, 0.5))
        self.m_statusIconNode:setAnchorPoint(cc.p(0.5, 0.5))
        icon_node:addChild(self.m_statusIconNode)
    end
end

-------------------------------------
-- function setStatusIconPosition
-- @brief 파라미터의 상태효과 아이콘과 해당 아이콘의 인덱스 값으로 직접 위치나 스케일을 변경(하위 클래스에서 재정의 필요)
-------------------------------------
function ICharacterStatusEffect:setStatusIconPosition(status_icon, idx)
end

-------------------------------------
-- function addStatusIcon
-------------------------------------
function ICharacterStatusEffect:addStatusIcon(status_effect)
    local status_effect_type = status_effect:getTypeName()

    -- StatusEffectIcon 생성
	local status_icon = StatusEffectIcon(self.m_statusIconNode, status_effect)
    table.insert(self.m_lStatusIcon, status_icon)

    self.m_mStatusIcon[status_effect_type] = status_icon
	
    return status_icon
end

-------------------------------------
-- function addStatusIcon
-------------------------------------
function ICharacterStatusEffect:addStatusIcon_direct(status_effect_type)
	local status_icon = StatusEffectIcon(self.m_statusIconNode, nil, status_effect_type)

    table.insert(self.m_lStatusIcon, status_icon)

    self.m_mStatusIcon[status_effect_type] = status_icon

    return status_icon
end

-------------------------------------
-- function removeStatusIconAll
-------------------------------------
function ICharacterStatusEffect:removeStatusIconAll()
    for i, v in ipairs(self.m_lStatusIcon) do
        v:release()
    end

	self.m_lStatusIcon = {}
    self.m_mStatusIcon = {}
end


-------------------------------------
-- function insertStatusEffect
-------------------------------------
function ICharacterStatusEffect:insertStatusEffect(status_effect)
	local effect_name = status_effect.m_statusEffectName
	
    if (status_effect:isHidden()) then
        self.m_mHiddenStatusEffect[effect_name] = status_effect
    else
        self.m_mStatusEffect[effect_name] = status_effect
    end

    -- 카운트 갱신
    do
        local subject = status_effect.m_statusEffectTable['type']
        if (not self.m_mStatusEffectCntPerSubject[subject]) then
            self.m_mStatusEffectCntPerSubject[subject] = 0
        end

        self.m_mStatusEffectCntPerSubject[subject] = self.m_mStatusEffectCntPerSubject[subject] + 1
    end
end

-------------------------------------
-- function removeStatusEffect
-------------------------------------
function ICharacterStatusEffect:removeStatusEffect(status_effect)
	local effect_name = status_effect.m_statusEffectName
    if (not effect_name) then return end

    if (status_effect:isHidden()) then
        self.m_mHiddenStatusEffect[effect_name] = nil
    else
	    self.m_mStatusEffect[effect_name] = nil
    end

    -- 카운트 갱신
    do
        local subject = status_effect.m_statusEffectTable['type']
        local count = self.m_mStatusEffectCntPerSubject[subject]

        count = count - 1
        count = math_max(count, 0)
    
        self.m_mStatusEffectCntPerSubject[subject] = count
    end
end

-------------------------------------
-- function getStatusEffect
-------------------------------------
function ICharacterStatusEffect:getStatusEffect(status_effect_type, check_hidden)
    local status_effect = self.m_mStatusEffect[status_effect_type]

    if (not status_effect and check_hidden) then
        status_effect = self.m_mHiddenStatusEffect[status_effect_type]
    end

	return status_effect
end

-------------------------------------
-- function getStatusEffectList
-------------------------------------
function ICharacterStatusEffect:getStatusEffectList()
	return self.m_mStatusEffect
end

-------------------------------------
-- function getStatusEffectList_Positive
-------------------------------------
function ICharacterStatusEffect:getStatusEffectList_Positive()
    local result = {}

    for type, status_effect in pairs(self.m_mStatusEffect) do
         if (status_effect:isErasable()) and (not status_effect:isHarmful()) then
            result[type] = status_effect
         end
    end

	return result
end


-------------------------------------
-- function getStatusEffectList_Negative
-------------------------------------
function ICharacterStatusEffect:getStatusEffectList_Negative()
    local result = {}

    for type, status_effect in pairs(self.m_mStatusEffect) do
         if (status_effect:isErasable()) and (status_effect:isHarmful()) then
            result[type] = status_effect
         end
    end

	return result
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

    else
        for type, status_effect in pairs(self:getStatusEffectList()) do
            if (string.find(type, value)) then
                count = count + status_effect:getOverlabCount()
            end
        end
    end

    return count
end

-------------------------------------
-- function getStatusEffectCountBySubject
-------------------------------------
function ICharacterStatusEffect:getStatusEffectCountBySubject(subject)
    local count = self.m_mStatusEffectCntPerSubject[subject] or 0
    return count
end

-------------------------------------
-- function isExistStatusEffectName
-- @breif 해당 이름을 포함한 상태효과가 존재하는지 여부
-------------------------------------
function ICharacterStatusEffect:isExistStatusEffectName(name, except_name, check_hidden)
    local b = false

    for type, status_effect in pairs(self:getStatusEffectList()) do
        if (string.find(type, name) and type ~= except_name) then
            b = true
            break
        end
    end

    if (check_hidden) then
        for type, status_effect in pairs(self:getHiddenStatusEffectList()) do
            if (string.find(type, name) and type ~= except_name) then
                b = true
                break
            end
        end
    end

    return b
end

-------------------------------------
-- function isExistStatusEffect
-- @breif 파라미터의 칼럼과 값으로부터 동일한 상태효과가 존재하는지 여부
-------------------------------------
function ICharacterStatusEffect:isExistStatusEffect(column, value, check_hidden)
    local b = false

    for type, status_effect in pairs(self:getStatusEffectList()) do
        local t_status_effect = TableStatusEffect():get(type)
        if (t_status_effect and t_status_effect[column] == value) then
            b = true
            break
        end
    end

    if (check_hidden) then
        for type, status_effect in pairs(self:getHiddenStatusEffectList()) do
            local t_status_effect = TableStatusEffect():get(type)
            if (t_status_effect and t_status_effect[column] == value) then
                b = true
                break
            end
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
    self.m_mStatusEffectGroggy[statusEffectName] = true

    self:setGroggy(true)
end

-------------------------------------
-- function removeGroggy
-------------------------------------
function ICharacterStatusEffect:removeGroggy(statusEffectName)
    if (statusEffectName) then
        self.m_mStatusEffectGroggy[statusEffectName] = nil
    else
        self.m_mStatusEffectGroggy = {}
    end

    if (table.count(self.m_mStatusEffectGroggy) == 0) then
        self:setGroggy(false)
    end
end

-------------------------------------
-- function setGroggy
-------------------------------------
function ICharacterStatusEffect:setGroggy(b)
    if (self.m_isGroggy == b) then return end

    local disable_behavior = self:hasStatusEffectToDisableBehavior()
    local disable_skill = self:hasStatusEffectToDisableSkill()

	self.m_isGroggy = b

    if (disable_behavior ~= self:hasStatusEffectToDisableBehavior()) then
        if (b) then
            self:onDisabledBehavior()
        else
            self:onEnabledBehavior()
        end
    end

    if (disable_skill ~= self:hasStatusEffectToDisableSkill()) then
        if (b) then
            self:onDisabledSkill()
        else
            self:onEnabledSkill()
        end
    end
end

-------------------------------------
-- function setSilence
-------------------------------------
function ICharacterStatusEffect:setSilence(b)
    if (self.m_isSilence == b) then return end

    local disable_skill = self:hasStatusEffectToDisableSkill()

	self.m_isSilence = b

    if (disable_skill ~= self:hasStatusEffectToDisableSkill()) then
        if (b) then
            self:onDisabledSkill()
        else
            self:onEnabledSkill()
        end
    end
end

-------------------------------------
-- function setImmortal
-------------------------------------
function ICharacterStatusEffect:setImmortal(b)
	self.m_isImmortal = b
end

-------------------------------------
-- function setZombie
-------------------------------------
function ICharacterStatusEffect:setZombie(b)
	self.m_isZombie = b
end

-------------------------------------
-- function setProtected
-------------------------------------
function ICharacterStatusEffect:setProtected(b)
    self.m_isProtected = b
end

-------------------------------------
-- function setImmune
-------------------------------------
function ICharacterStatusEffect:setImmune(b)
	self.m_isImmune = b
end

-------------------------------------
-- function onEnabledBehavior
-- @brief 행동 가능 상태가 되었을 때 호출
-------------------------------------
function ICharacterStatusEffect:onEnabledBehavior()
end

-------------------------------------
-- function onDisabledBehavior
-- @brief 행동 불가능 상태가 되었을 때 호출
-------------------------------------
function ICharacterStatusEffect:onDisabledBehavior()
end

-------------------------------------
-- function onEnabledSkill
-- @brief 상태효과 해제로 스킬 사용 가능 상태가 되었을 때 호출
-------------------------------------
function ICharacterStatusEffect:onEnabledSkill()
end

-------------------------------------
-- function onDisabledSkill
-- @brief 상태효과 적용으로 스킬 사용 불가능 상태가 되었을 때 호출
-------------------------------------
function ICharacterStatusEffect:onDisabledSkill()
end


-------------------------------------
-- function hasStatusEffectToDisableSkill
-- @breif 스킬을 사용 못하게 하는 상태효과가 있는지 체크
-------------------------------------
function ICharacterStatusEffect:hasStatusEffectToDisableSkill()
    if (self.m_isGroggy or self.m_isSilence) then
        return true
    end

    return false
end

-------------------------------------
-- function hasStatusEffectToDisableBehavior
-- @breif 행동을 못하게 하는 상태효과가 있는지 체크
-------------------------------------
function ICharacterStatusEffect:hasStatusEffectToDisableBehavior()
    if (self.m_isGroggy) then
        return true
    end

    return false
end

-------------------------------------
-- function hasStatusEffectToResurrect
-- @breif 부활 상태효과가 있는지 검사한다.
-------------------------------------
function ICharacterStatusEffect:hasStatusEffectToResurrect()
    return self:isExistStatusEffect('type', 'resurrect_time')
end

-------------------------------------
-- function checkSpecialImmune
-- @brief 특정 상태효과 면역 체크
-------------------------------------
function ICharacterStatusEffect:checkSpecialImmune(t_status_effect)
    return false
end

-------------------------------------
-- function setPositionStatusIcons
-------------------------------------
function ICharacterStatusEffect:setPositionStatusIcons(x, y)
    if (self.m_statusIconNode) then
        self.m_statusIconNode:setPosition(x, y)
    end
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
