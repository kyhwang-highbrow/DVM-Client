local PARENT = Entity

-------------------------------------
-- class DropItem
-------------------------------------
DropItem = class(PARENT, {
    m_world = '',
    m_type = 'string',
    m_bObtained = 'boolean',
    m_itemType = 'string',
    m_itemCount = 'number',
    m_checkSprite = 'Animator',
})

-------------------------------------
-- function init
-------------------------------------
function DropItem:init(file_name, body)
    self.m_bObtained = false
end

-------------------------------------
-- function init_item
-------------------------------------
function DropItem:init_item(type)
    self.m_type = type

    local file_name
        
    if (self.m_type == 'item_marbl') then
        file_name = 'res/item/item_marble/item_marble.vrp'
    elseif (self.m_type == 'item_marbl_gold') then
        file_name = 'res/item/item_marble_goldragora/item_marble_goldragora.vrp'
    end

    self:initAnimatorItem(file_name)
end

-------------------------------------
-- function initAnimator
-------------------------------------
function DropItem:initAnimator(file_name)
end

-------------------------------------
-- function initAnimatorItem
-------------------------------------
function DropItem:initAnimatorItem(file_name)
    -- Animator 삭제
    if self.m_animator then
        self.m_animator:release()
        self.m_animator = nil
    end

    -- Animator 생성
    self.m_animator = MakeAnimator(file_name)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node)
    end
end

-------------------------------------
-- function initState
-------------------------------------
function DropItem:initState()
    self:addState('appear', DropItem.st_appear, 'appear', false)
    self:addState('appear_auto_obtain', DropItem.st_appear_auto_obtain, 'appear', false)
    self:addState('idle', DropItem.st_idle, 'idle', true)
    self:addState('wait', DropItem.st_wait, 'idle', true)
    self:addState('dying', DropItem.st_dying, 'disappear', false)
    self:addState('dead', function(owner, dt) return true end, nil, false)

    self:changeState('appear')
end

-------------------------------------
-- function release
-------------------------------------
function DropItem:release()
    PARENT.release(self)
end

-------------------------------------
-- function update
-------------------------------------
function DropItem:update(dt)
    self:setPosition(self.m_rootNode:getPosition())
    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_appear
-------------------------------------
function DropItem.st_appear(owner, dt)
    if (owner.m_stateTimer == 0) then
        local function ani_handler()
            owner:changeState('idle')
        end
        owner:addAniHandler(ani_handler)
    end
end

-------------------------------------
-- function st_appear_auto_obtain
-------------------------------------
function DropItem.st_appear_auto_obtain(owner, dt)
    if (owner.m_stateTimer == 0) then
        local function ani_handler()
            owner:makeObtainEffect()
            owner:changeState('dying')
        end
        owner:addAniHandler(ani_handler)
    end
end

-------------------------------------
-- function st_idle
-------------------------------------
function DropItem.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        --cclog('DropItem.st_idle')

        owner:runAction_Floating()
    end
end

-------------------------------------
-- function st_wait
-------------------------------------
function DropItem.st_wait(owner, dt)
    if (owner.m_stateTimer >= 0.3) then
        owner:changeState('dying')
    end
end


-------------------------------------
-- function st_dying
-------------------------------------
function DropItem.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then
        if owner.m_checkSprite then
            owner.m_checkSprite:release()
            owner.m_checkSprite = nil
        end

        local function ani_handler()
            owner:changeState('dead')
        end
        owner:addAniHandler(ani_handler)
    end
end

-------------------------------------
-- function setObtained
-------------------------------------
function DropItem:setObtained(item_type, item_count)
    self.m_bObtained = true
    self.m_itemType = item_type
    self.m_itemCount = item_count

    if (not self.m_checkSprite) then
        -- 체크 표시 일단 제거 sgkim 2017-08-22
        --local sprite = MakeAnimator('res/ui/icons/stage_box_check.png')
        --sprite:setDockPoint(cc.p(0.5, 0.5))
        --sprite:setAnchorPoint(cc.p(0.5, 0.5))
        --self.m_animator:addChild(sprite.m_node)
        --self.m_checkSprite = sprite
        --
        --cca.uiReactionSlow(sprite.m_node, 1, 1, 2)
    end
end

-------------------------------------
-- function makeObtainEffect
-- @brief
-------------------------------------
function DropItem:makeObtainEffect()
    local type, count = self.m_itemType, self.m_itemCount

    local res = 'res/ui/icons/inbox/inbox_' .. type .. '.png'
    if (res) then
        local node = cc.Node:create()
        node:setPosition(self.pos.x, self.pos.y)
		node:setOpacity(0)
		node:setCascadeOpacityEnabled(true)
        self.m_world:addChild3(node, DEPTH_ITEM_GOLD)

        local icon = cc.Sprite:create(res)
        if (icon) then
            icon:setPositionX(-15)
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            node:addChild(icon)
        end

        local label = cc.Label:createWithBMFont('res/font/normal.fnt', '+' .. count)
        if (label) then
            local string_width = label:getStringWidth()
            local offset_x = (string_width / 2)
            label:setPositionX(offset_x)
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            label:setColor(cc.c3b(255, 255, 255))
            node:addChild(label)
        end

        node:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.5), cc.FadeOut:create(0.2), cc.RemoveSelf:create()))
        node:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveBy:create(1, cc.p(0, 80)), 1)))

		SoundMgr:playEffect('UI', 'ui_in_item_get')
    end
end

-------------------------------------
-- function isObtained
-------------------------------------
function DropItem:isObtained()
    return self.m_bObtained
end

-------------------------------------
-- function runAction_Floating
-- @brief 부유중 효과
-------------------------------------
function DropItem:runAction_Floating()
    local target_node = self.m_animator.m_node
    if (not target_node) then
        return
    end

    target_node:setPosition(0, 0)

	local floating_x_max = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_MAX_X_SCOPE')
	local floating_y_max = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_MAX_Y_SCOPE')
	local floating_x_min = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_MIN_X_SCOPE')
	local floating_y_min = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_MIN_Y_SCOPE')
	local floating_time = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_TIME')

    local function getTime()
        return math_random(5, 15) * 0.1 * floating_time / 2
    end

    local sequence = cc.Sequence:create(
        cc.MoveTo:create(getTime(), cc.p(math_random(-floating_x_max, -floating_x_min), math_random(-floating_y_max, -floating_y_min))),
        cc.MoveTo:create(getTime(), cc.p(math_random(floating_x_min, floating_x_max), math_random(floating_y_min, floating_y_max)))
    )

    local action = cc.RepeatForever:create(sequence)
    target_node:runAction(action)
end