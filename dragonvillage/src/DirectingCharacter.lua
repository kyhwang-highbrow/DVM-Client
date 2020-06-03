-------------------------------------
-- class DirectingCharacter
-------------------------------------
DirectingCharacter = class{
		m_rootNode = 'cc.Node',
		m_animator = 'Animator',
		m_shadow = '',
		m_scale = '',
		m_tData = '',
	}

DirectingCharacter.SHADOW_POS_Y = 105

-------------------------------------
-- function init
-------------------------------------
function DirectingCharacter:init(scale, t_data)
    -- rootNode 생성
    self.m_rootNode = cc.Node:create()
	self.m_scale = scale or 1
	self.m_tData = t_data or {}
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
-- function initAnimatorDragon
-------------------------------------
function DirectingCharacter:initAnimatorDragon(did, evolution)
    -- Animator 삭제
    self:releaseAnimator()

    local t_dragon
    if TableSlime:isSlimeID(did) then
        local table_slime = TableSlime()
        t_dragon = table_slime:get(did)
    else
        local table_dragon = TableDragon()
        t_dragon = table_dragon:get(did)
    end

	local res_name = t_dragon['res']
    local attr = t_dragon['attr']
    
	-- Animator 생성
    self.m_animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
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
	self.m_shadow = LobbyShadow(self.m_scale)
	self.m_shadow.m_rootNode:setPositionY(pos_y)
	self.m_rootNode:addChild(self.m_shadow.m_rootNode)
end

-------------------------------------
-- function setOpacityChildren
-- @brief 하위 UI가 모두 opacity값을 적용되도록
-------------------------------------
function DirectingCharacter:setOpacityChildren(b)
    doAllChildren(self.m_rootNode, function(node) node:setCascadeOpacityEnabled(b) end)
end

-------------------------------------
-- function setPosition
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

-------------------------------------
-- function actAscension
-- @brief 승천 액션
-------------------------------------
function DirectingCharacter:actAscension(duration, cb_func)
	-- 드래곤은 승천
	local moveby = cc.EaseOut:create(cc.MoveBy:create(duration, cc.p(0, 1000)), 0.5)
	local fadeout = cc.FadeOut:create(10)
	self.m_animator:runAction(cc.Sequence:create(cc.Spawn:create(moveby, fadeout)))

	-- 그림자는 희미해지며 작아짐
	if (self.m_shadow) then
		local scale_to = cc.ScaleTo:create(duration, 0)
		local fadeout2 = cc.FadeOut:create(duration)
		self.m_shadow.m_rootNode:runAction(cc.Sequence:create(cc.Spawn:create(scale_to, fadeout2)))
	end

	-- 객체 삭제
	local delay2 = cc.DelayTime:create(duration)
	local callback = cc.CallFunc:create(function()
		if (cb_func) then
			cb_func()
		end
		self:release()
	end)
	self.m_rootNode:runAction(cc.Sequence:create(delay2, callback))
end

-------------------------------------
-- function actMove
-- @brief duration동안 move_point로 움직인 후 delay 대기하고 cb_func실행
-------------------------------------
function DirectingCharacter:actMove(duration, move_point, delay, move_cb_func)
	self:changeAni('move', true)
	local moveby = cc.MoveBy:create(duration, move_point)
	local cb_func = cc.CallFunc:create(function()
		self:changeAni('idle', true)
	end)
	local delay = cc.DelayTime:create(delay)
	local cb_func2 = cc.CallFunc:create(function()
		if (move_cb_func) then
			move_cb_func()
		end
	end)
	self.m_rootNode:runAction(cc.Sequence:create(moveby, cb_func, delay, cb_func2))
end

-------------------------------------
-- function actMove_Fly
-- @brief 날면서 이동한다.
-------------------------------------
function DirectingCharacter:actMove_Fly(duration, move_point, delay, move_cb_func)
	local moveby = cc.MoveBy:create(duration, move_point)
	local delay = cc.DelayTime:create(delay)
	local cb_func = cc.CallFunc:create(function()
		if (move_cb_func) then
			move_cb_func()
		end
	end)
	self.m_rootNode:runAction(cc.Sequence:create(moveby, delay, cb_func))
end

-------------------------------------
-- function actSaying
-- @brief delay타임 후 말풍선 대화
-------------------------------------
function DirectingCharacter:actSaying(case_type, custom_str, delay, cb_func)
	local delay = cc.DelayTime:create(delay or 0)
	local cb_func = cc.CallFunc:create(function()
		
		local flv = (self.m_tData.getFlv) and self.m_tData:getFlv() or nil
		
		SensitivityHelper:doActionBubbleText_Extend{
			parent = self.m_rootNode,
			did = self.m_tData['did'],
			flv = flv,
			case_type = case_type,
			custom_str = custom_str,
			cb_func = function()
				if (cb_func) then
					cb_func()
				end
			end
		}
	end)

	self:runAction(cc.Sequence:create(delay, cb_func))
end

-------------------------------------
-- function actPose
-- @brief pose를 1회 취함
-------------------------------------
function DirectingCharacter:actPose()
	self:changeAni('pose_1', false)
	self.m_animator:addAniHandler(function()
		self:changeAni('idle', true)
	end)
end