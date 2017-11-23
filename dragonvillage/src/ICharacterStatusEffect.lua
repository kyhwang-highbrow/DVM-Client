-------------------------------------
-- interface ICharacterStatusEffect
-------------------------------------
ICharacterStatusEffect = {
    m_mStatusEffect = 'table',
    m_mHiddenStatusEffect = 'table',-- 숨겨져서 노출되지 않는 상태효과(리더, 패시브)

    m_lStatusIcon = 'sprite table',

    m_mStatusEffectGroggy = 'table',    -- 그로기 효과를 가진 status effect
    
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

    self.m_mStatusEffectGroggy = {}
    
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
    -------------------------------------------------------
    -- 아이콘
    -------------------------------------------------------
	local count = 1

	for type, status_effect in pairs(self.m_mStatusEffect) do
        local status_effect_type = status_effect:getTypeName()
        local icon = self.m_lStatusIcon[status_effect_type]
        if (status_effect.m_bApply and not status_effect:isHidden()) then
		    count = self:setStatusIcon(status_effect, count)
            if (icon and icon.m_icon) then
                icon.m_icon:setVisible(true)
            end
        else
            if (icon and icon.m_icon) then
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
	
    if (status_effect:isHidden()) then
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

    if (status_effect:isHidden()) then
        self.m_mHiddenStatusEffect[effect_name] = nil
    else
	    self.m_mStatusEffect[effect_name] = nil
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
        --[[
        for type, status_effect in pairs(self:getHiddenStatusEffectList()) do
            local t_status_effect = TableStatusEffect():get(type)
            if (t_status_effect and t_status_effect[column] == value) then
                count = count + status_effect:getOverlabCount()
            end
        end
        ]]--
    else
        for type, status_effect in pairs(self:getStatusEffectList()) do
            if (string.find(type, value)) then
                count = count + status_effect:getOverlabCount()
            end
        end
        --[[
        for type, status_effect in pairs(self:getHiddenStatusEffectList()) do
            if (string.find(type, value)) then
                count = count + status_effect:getOverlabCount()
            end
        end
        ]]--
    end

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

    local disable_skill = self:hasStatusEffectToDisableSkill()

	self.m_isGroggy = b

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
-- function setProtection
-------------------------------------
function ICharacterStatusEffect:setProtected(b)
    self.m_isProtected = b
end

-------------------------------------
-- function setImmuneSE
-------------------------------------
function ICharacterStatusEffect:setImmune(b)
	self.m_isImmune = b
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
