-------------------------------------
-- class DirectingCharacter
-------------------------------------
DirectingCharacter = class{
		m_rootNode = 'cc.Node',
		m_animator = 'Animator',
		m_shadow = '',
		m_scale = '',
	}

-------------------------------------
-- function init
-------------------------------------
function DirectingCharacter:init(scale)
    -- rootNode 생성
    self.m_rootNode = cc.Node:create()
	self.m_scale = scale or 1
end

-------------------------------------
-- function initAnimator
-------------------------------------
function DirectingCharacter:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    self.m_animator = MakeAnimator(file_name)
    if self.m_animator.m_node then
        self.m_animator.m_node:setScale(self.m_scale)
		self.m_rootNode:addChild(self.m_animator.m_node, 2)
    end
end

-------------------------------------
-- function initAnimator
-------------------------------------
function DirectingCharacter:initAnimatorDragon(did, evolution)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeDragonAnimator_usingDid(did, evolution)
    if self.m_animator.m_node then
        self.m_animator.m_node:setScale(self.m_scale)
        
		self.m_rootNode:addChild(self.m_animator.m_node, 1)
    end
end

-------------------------------------
-- function initShadow
-------------------------------------
function DirectingCharacter:initShadow(pos_y)
	local pos_y = pos_y or 0

	-- 그림자 생성
	local lobby_shadow = LobbyShadow(self.m_scale)
	lobby_shadow.m_rootNode:setPositionY(pos_y)
	self.m_rootNode:addChild(lobby_shadow.m_rootNode)
end

-------------------------------------
-- function initShadow
-------------------------------------
function DirectingCharacter:setPosition(x, y)
	self.m_rootNode:setPosition(x, y)
end

-------------------------------------
-- function changeAni
-------------------------------------
function DirectingCharacter:changeAni(ani_name, loop)
	self.m_animator:changeAni(ani_name, loop)
end

-------------------------------------
-- function runAction
-------------------------------------
function DirectingCharacter:runAction(action)
	self.m_rootNode:runAction(action)
end

-------------------------------------
-- function releaseAnimator
-------------------------------------
function DirectingCharacter:releaseAnimator()
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
function DirectingCharacter:release()
    self:releaseAnimator()

    if self.m_rootNode then
        self.m_rootNode:removeFromParent(true)
    end
    
    self.m_rootNode = nil

    if self.m_shadow then
        self.m_shadow:release()
        self.m_shadow = nil
    end
end