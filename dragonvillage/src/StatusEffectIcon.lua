-------------------------------------
-- class StatusEffectIcon
-------------------------------------
StatusEffectIcon = class({
        m_statusEffectName = 'str',
		m_statusEffect = 'status effect',
		
        m_parentNode = 'cc.Node',

        m_icon = 'cc.Sprite',
		m_overlabNode = 'cc.Node',
        m_overlabCount = 'number',

		m_bBlink = 'bool',

        m_typeSTr = 'string',
     })

-------------------------------------
-- function init
-------------------------------------
function StatusEffectIcon:init(parent_node, status_effect, type_str)
    local status_effect_type = status_effect and status_effect:getTypeName() or type_str
    self.m_typeSTr = type_str
	
    self.m_statusEffectName = status_effect_type
    self.m_statusEffect = status_effect
    self.m_parentNode = parent_node
    self.m_overlabCount = 1
	self.m_bBlink = false
        
	self.m_icon = IconHelper:getStatusEffectIcon(status_effect_type)

    if (not self.m_icon) then return nil end

	self.m_icon:setScale(0.375)

    if (self.m_parentNode) then
        self.m_parentNode:addChild(self.m_icon, 1)
    end
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffectIcon:update(dt)
    if (self.m_typeSTr) then return false end

    -- 해당 상태효과가 종료 상태라면 삭제
    if (isExistValue(self.m_statusEffect.m_state, 'end', 'dying')) then
        return true
    end

    -- 해당 상태효과가 활성화 중인지 체크
    local is_active = self.m_statusEffect:isActiveIcon()

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
    do
        local overlab_cnt = self.m_statusEffect:getOverlabCount()

        self:setOverlabLabel(overlab_cnt)
    end
end

-------------------------------------
-- function setOverlabLabel
-------------------------------------
function StatusEffectIcon:setOverlabLabel(overlab_cnt)
    if (self.m_overlabCount == overlab_cnt) then return end
    self.m_overlabCount = overlab_cnt

    -- 이미 중첩 표시를 위한 노드가 존재했다면 삭제
    if (self.m_overlabNode) then
        self.m_overlabNode:setVisible(false)
        self.m_overlabNode:removeFromParent(true)
        self.m_overlabNode = nil
    end

    -- 1 중첩의 경우는 숫자를 표시하지 않음
    if (overlab_cnt <= 1) then return end

    -- 중첩 표시를 위한 노드 생성
    local x_offset = 0
    local str = comma_value(overlab_cnt)
    local length = #str
    self.m_overlabNode = cc.Node:create()
    
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_status_effect/ingame_status_effect.plist')
    for i = 1, #str do
        local v = str:sub(i, i)

        if (tonumber(v)) then
            local sprite = self:createSpriteWithSpriteFrameName('ingame_status_effect_num_'.. v.. '.png')
        
            sprite:setPosition(x_offset, 0)
            self.m_overlabNode:addChild(sprite)

            x_offset = x_offset + (sprite:getContentSize()['width'] / 2)
        end
    end
    
    self.m_overlabNode:setPosition(-(x_offset/2), 0)
    self.m_overlabNode:setCascadeOpacityEnabled(true)

    self.m_parentNode:addChild(self.m_overlabNode, 2)
end

-------------------------------------
-- function release
-------------------------------------
function StatusEffectIcon:release()
    if (self.m_icon) then
	    self.m_icon:removeFromParent(true)
	    self.m_icon = nil
    end
    if (self.m_overlabNode) then
	    self.m_overlabNode:removeFromParent(true)
	    self.m_overlabNode = nil
    end
end

-------------------------------------
-- function createSpriteWithSpriteFrameName
-------------------------------------
function StatusEffectIcon:createSpriteWithSpriteFrameName(res_name)
	local sprite = cc.Sprite:createWithSpriteFrameName(res_name)
    if (not sprite) then
        -- @E.T.
		g_errorTracker:appendFailedRes(res_name)

        cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_status_effect/ingame_status_effect.plist')
        sprite = cc.Sprite:createWithSpriteFrameName(res_name)
    end

	sprite:setDockPoint(CENTER_POINT)
	sprite:setAnchorPoint(CENTER_POINT)
	return sprite
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
    if (self.m_icon) then
        self.m_icon:setPosition(x, y)
    end

    if (self.m_overlabNode) then
        self.m_overlabNode:setPosition(x, y)
    end
end

-------------------------------------
-- function setScale
-------------------------------------
function StatusEffectIcon:setScale(scale)
    if (self.m_icon) then
        self.m_icon:setScale(scale)
    end

    if (self.m_overlabNode) then
        self.m_overlabNode:setScale(scale)
    end
end

-------------------------------------
-- function setVisible
-------------------------------------
function StatusEffectIcon:setVisible(b)
    if (self.m_icon) then
        self.m_icon:setVisible(b)
    end

    if (self.m_overlabNode) then
        self.m_overlabNode:setVisible(b)
    end
end

-------------------------------------
-- function isVisible
-------------------------------------
function StatusEffectIcon:isVisible()
    if (not self.m_icon) then return false end

    return self.m_icon:isVisible()
end