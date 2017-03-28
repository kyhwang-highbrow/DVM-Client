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
        if self.m_animator.m_node then
            self.m_animator.m_node:removeFromParent(true)
            self.m_animator.m_node = nil
        end
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
    self:addState('idle', DropItem.st_idle, 'idle', true)
    self:addState('wait', DropItem.st_wait, 'idle', true)
    self:addState('dying', DropItem.st_dying, 'disappear', false)

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
        --cclog('DropItem.st_appear')
    end

    if (owner.m_stateTimer >= owner:getAniDuration()) then
        owner:changeState('idle')
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
        --cclog('DropItem.st_dying')
    end

    if (owner.m_stateTimer >= owner:getAniDuration()) then
        return true
    end
end

-------------------------------------
-- function setObtained
-------------------------------------
function DropItem:setObtained(item_type, item_count)
    self.m_bObtained = true
    self.m_itemType = item_type
    self.m_itemCount = item_count
end

-------------------------------------
-- function makeObtainEffect
-- @brief
-------------------------------------
function DropItem:makeObtainEffect()
    local type, count = self.m_itemType, self.m_itemCount

    local res = 'res/ui/icon/inbox/inbox_' .. type .. '.png'
    if (res) then
        local node = cc.Node:create()
        node:setPosition(self.pos.x, self.pos.y)
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

        node:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
        node:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveBy:create(1, cc.p(0, 80)), 1)))
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
-- @brief 캐릭터 부유중 효과
-------------------------------------
function DropItem:runAction_Floating()
    Character.runAction_Floating(self)
end

-------------------------------------
-- function runAction_Floating
-- @brief 캐릭터 부유중 효과
-------------------------------------
function DropItem:runAction_Floating()
    Character.runAction_Floating(self)
end