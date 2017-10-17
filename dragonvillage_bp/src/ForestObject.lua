-------------------------------------
-- class ForestObject
-------------------------------------
ForestObject = class({
        m_rootNode = 'cc.Node',
        m_animator = 'Animator',
        m_objectType = 'string',
     })

-------------------------------------
-- function init
-------------------------------------
function ForestObject:init()
    -- rootNode 생성
    self.m_rootNode = cc.Node:create()
end

-------------------------------------
-- function initSchedule
-------------------------------------
function ForestObject:initSchedule()
    self.m_rootNode:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initAnimator
-------------------------------------
function ForestObject:initAnimator(file_name)
    error('상속받은 클래스에서 구현하세요.')
end

-------------------------------------
-- function releaseAnimator
-------------------------------------
function ForestObject:releaseAnimator()
    -- Animator 삭제
    if self.m_animator then
        if self.m_animator.m_node then
            self.m_animator.m_node:removeFromParent(true)
            self.m_animator.m_node = nil
        end
        self.m_animator = nil
    end
end

-------------------------------------
-- function setPosition
-------------------------------------
function ForestObject:setPosition(x, y)
    self.m_rootNode:setPosition(x, y)
end

-------------------------------------
-- function getPosition
-------------------------------------
function ForestObject:getPosition()
    return self.m_rootNode:getPosition()
end

-------------------------------------
-- function setForestZOrder
-------------------------------------
function ForestObject:setForestZOrder()
    local pos_y = self.m_rootNode:getPositionY()

    self.m_rootNode:setLocalZOrder(FOREST_ZORDER['CHAR'] - pos_y)
end

-------------------------------------
-- function release
-------------------------------------
function ForestObject:release()
    self:releaseAnimator()

    if self.m_rootNode then
        self.m_rootNode:removeFromParent(true)
    end
    
    self.m_rootNode = nil
end

-------------------------------------
-- function update
-------------------------------------
function ForestObject:update(dt)
end