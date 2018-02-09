-------------------------------------
-- class StatusEffectIcon
-------------------------------------
StatusEffectIcon = class({
		m_statusEffect = 'status effect',
		m_char = 'Character',
		m_icon = 'icon',

		m_label = 'cc.Label',
		m_statusEffectName = 'str',

		m_bBlink = 'bool',
     })

-------------------------------------
-- function init
-------------------------------------
function StatusEffectIcon:init(char, status_effect)
	self.m_statusEffect = status_effect
	self.m_char = char
	self.m_bBlink = false

	local status_effect_type = status_effect:getTypeName()
	self.m_statusEffectName = status_effect_type

	if (char.m_statusNode) then
		local icon, is_exist = IconHelper:getStatusEffectIcon(status_effect_type)
        if (icon == nil or is_exist == false) then return nil end

		icon:setScale(0.375)

        char.m_statusNode:addChild(icon, 0)
		self.m_icon = icon
	
	    local label = cc.Label:createWithTTF('', Translate:getFontPath(), 40, 0)
        if (label) then
		    label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		    label:setAnchorPoint(cc.p(0.5, 0.5))
		    label:setDockPoint(cc.p(0.5, 0.5))
		    label:setPosition(0, 0)
		    label:enableOutline(cc.c4b(0, 0, 0, 255), 3)

		    self.m_icon:addChild(label)
		    self.m_label = label
        end
    end
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffectIcon:update(dt)
    -- 주체 대상이 해당 statusEffect를 가지고 있지 않은 상태라면 삭제 시킴
    if (self.m_char.m_mStatusEffect[self.m_statusEffectName] == nil or self.m_statusEffect.m_state == 'end') then
        return true
    end

    -- 해당 상태효과가 활성화 중인지 체크
    local is_active = self.m_statusEffect.m_bApply
    self:setVisible(is_active)

    if (not is_active) then
        return false    
    end

    -- 남은 시간에 따른 점멸 처리
    do
        -- 점멸 설정 함수
        local function setBlink(b)
            if (not self.m_icon) then return end
            if (b == self.m_bBlink) then return end

            if (b) then
                local sequence = cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5))
			    self.m_icon:runAction(cc.RepeatForever:create(sequence))
            else
                self.m_icon:setOpacity(255)
		        self.m_icon:stopAllActions()
            end

            self.m_bBlink = b
        end
    
	    -- 1. 제한 시간이 없는 상태인 경우
	    if (self.m_statusEffect:isInfinity()) then 
            setBlink(false)
        else
		    -- 2. 남은 시간이 3초 이상인데 점멸 상태인 경우 -> 점멸 해제
		    if (self.m_statusEffect:getLatestTimer() > 3) then
			    setBlink(false)
		    -- 3. 남은 시간이 3초 이하인데 점멸 상태가 아닌 경우 -> 점멸 시킴
		    elseif (self.m_statusEffect:getLatestTimer() < 3) then 
			    setBlink(true)
		    end
	    end
    end

    -- 중첩 표시
    self:setOverlabText()
end

-------------------------------------
-- function updatePositionFromIndex
-------------------------------------
function StatusEffectIcon:updatePositionFromIndex(idx)
    local owner = self.m_char

    if (owner.m_infoUI) then
        local x, y = owner.m_infoUI:getPositionForStatusIcon(owner.m_bLeftFormation, idx)
        local scale = owner.m_infoUI:getScaleForStatusIcon()

        if (self.m_icon) then
            self.m_icon:setPosition(x, y)
            self.m_icon:setScale(scale)
        end
    end
end

-------------------------------------
-- function setOverlabText
-------------------------------------
function StatusEffectIcon:setOverlabText()
	local overlab_cnt = self.m_statusEffect:getOverlabCount()

    if (self.m_label) then
	    if (overlab_cnt > 1) then
		    self.m_label:setString(overlab_cnt)
        else
            self.m_label:setString('')
	    end
    end
end

-------------------------------------
-- function release
-------------------------------------
function StatusEffectIcon:release()
    if (self.m_label) then
	    self.m_label:removeFromParent(true)
	    self.m_label = nil
    end
	if (self.m_icon) then
	    self.m_icon:removeFromParent(true)
	    self.m_icon = nil
    end
end

-------------------------------------
-- function getStatusEffectName
-------------------------------------
function StatusEffectIcon:getStatusEffectName()
    return self.m_statusEffectName
end

-------------------------------------
-- function setPosition
-------------------------------------
function StatusEffectIcon:setPosition(x, y)
    if (not self.m_icon) then return end

    self.m_icon:setPosition(x, y)
end

-------------------------------------
-- function setScale
-------------------------------------
function StatusEffectIcon:setScale(scale)
    if (not self.m_icon) then return end

    self.m_icon:setScale(scale)
end

-------------------------------------
-- function setVisible
-------------------------------------
function StatusEffectIcon:setVisible(b)
    if (not self.m_icon) then return end

    self.m_icon:setVisible(b)
end

-------------------------------------
-- function setVisible
-------------------------------------
function StatusEffectIcon:setVisible(b)
    if (not self.m_icon) then return end

    self.m_icon:setVisible(b)
end

-------------------------------------
-- function isVisible
-------------------------------------
function StatusEffectIcon:isVisible()
    if (not self.m_icon) then return false end

    return self.m_icon:isVisible()
end