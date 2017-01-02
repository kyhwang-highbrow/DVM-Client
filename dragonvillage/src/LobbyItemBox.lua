local PARENT = class(IEventDispatcher:getCloneClass(), IEventListener:getCloneTable())

-------------------------------------
-- class LobbyItemBox
-------------------------------------
LobbyItemBox = class(PARENT, {
        m_rootNode = 'cc.Node',
        m_animator = '',
     })

-------------------------------------
-- function init
-------------------------------------
function LobbyItemBox:init(scale)
    -- rootNode 생성
    self.m_rootNode = cc.Node:create()
end

-------------------------------------
-- function initAnimator
-------------------------------------
function LobbyItemBox:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    self.m_animator = MakeAnimator(file_name)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node, 2)
        self.m_animator.m_node:setScale(0.6)
        self.m_animator.m_node:setPositionY(40)

        --self.m_animator.m_node:setMix('idle', 'skill_idle', 0.1)
        --self.m_animator.m_node:setMix('skill_idle', 'idle', 0.1)
    end
end

-------------------------------------
-- function releaseAnimator
-------------------------------------
function LobbyItemBox:releaseAnimator()
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
-- function release
-------------------------------------
function LobbyItemBox:release()
    self:releaseAnimator()

    if self.m_rootNode then
        self.m_rootNode:removeFromParent(true)
    end
    
    self.m_rootNode = nil
end