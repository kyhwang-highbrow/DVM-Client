local PARENT = class(ForestObject, IEventDispatcher:getCloneTable(), IEventListener:getCloneTable())

-------------------------------------
-- class ForestShadow
-------------------------------------
ForestShadow = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function ForestShadow:init()
    self.m_objectType = 'shadow'
    self.m_rootNode:setLocalZOrder(FOREST_ZORDER['SHADOW'])
end

-------------------------------------
-- function initAnimator
-------------------------------------
function ForestShadow:initAnimator(scale)
    -- 그림자 이미지 생성
    self.m_animator = MakeAnimator('res/character/char_shadow.png')
    self.m_animator:setDockPoint(cc.p(0.5, 0.5))
    self.m_animator:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_animator:setScale(scale)
    self.m_animator:setOpacity(0.5 * 255)
    self.m_rootNode:addChild(self.m_animator.m_node)
end

-------------------------------------
-- function release
-------------------------------------
function ForestShadow:release()
    PARENT.release(self)

    PARENT.release_EventDispatcher(self)
    PARENT.release_EventListener(self)
end

-------------------------------------
-- function onEvent
-------------------------------------
function ForestShadow:onEvent(event_name, struct_event, ...)
    -- 그림자 이동
    if (event_name == 'forest_character_move') then
        local Forest_char = struct_event:getObject()
        local x, y = struct_event:getPosition()

        self:setPosition(x, y)

    -- y 좌표가 움직일 때 그림자 스케일 변경
    elseif (event_name == 'forest_dragon_jump') then
        local dragon = struct_event:getObject()
        local _, cur_y = dragon.m_animator:getPosition()
        local scale = 1 - ((cur_y - ForestDragon.OFFSET_Y)/ForestDragon.OFFSET_Y_MAX)

        self.m_rootNode:setScale(scale)

    end
end
