-------------------------------------
-- class EffectBezierLink
-------------------------------------
EffectBezierLink = class({
        m_node = 'CCNode',
        m_res = '',
        m_bar_visual = '',
        m_lEffectNode = 'CCNode',
		m_isAppear = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function EffectBezierLink:init(res, visual_name)
    self.m_lEffectNode = {}
    self.m_res = res
    self.m_bar_visual = visual_name
	self.m_isAppear = true

    -- node 생성
    self.m_node = cc.Node:create()
end

-------------------------------------
-- function setVisible
-------------------------------------
function EffectBezierLink:setVisible(visible)
    self.m_node:setVisible(visible)
end

-------------------------------------
-- function refreshEffect
-------------------------------------
function EffectBezierLink:refreshEffect(tar_x, tar_y, pos_x, pos_y, dir)
    local x = tar_x - pos_x
    local y = tar_y - pos_y

	-- 1. 베지어는 상대좌표로 계산
    local t_bezier_pos = getBezierPosList(x, y, 0, 0, dir)

	-- 2. 일단 전부 끈다 
	for i, effectNode in pairs(self.m_lEffectNode) do
		effectNode:setVisible(false)
	end
	
	-- 3. 각 이미지를 rotate 하기 위해서 이전 좌표 저장
	local pre_pos_x = 0
	local pre_pos_y = 0
	local effectNode = nil
	local degree = nil 

	-- 4. 이펙트 생성 밑 불러오기
	for i, bezier_pos in ipairs(t_bezier_pos) do
		if (nil == self.m_lEffectNode[i]) then
			-- 없을 경우 생성
			effectNode = self:createWithParent(self.m_node, bezier_pos['x'], bezier_pos['y'], 0, self.m_res, self.m_bar_visual, true)
			effectNode.m_node:setAnchorPoint(cc.p(0.5, 0))
			table.insert(self.m_lEffectNode, effectNode)
		else
			-- 있을 경우 꺼내와서 위치 지정
			effectNode = self.m_lEffectNode[i]
			effectNode:setVisible(true)
            effectNode:setPosition(bezier_pos['x'], bezier_pos['y'])
		end

		degree = getDegree(pre_pos_x, pre_pos_y, bezier_pos['x'], bezier_pos['y'])
		effectNode:setRotation(degree)
		pre_pos_x = bezier_pos['x']
		pre_pos_y = bezier_pos['y']
    end

	-- 5. 이펙트 등장 연출
	if (self.m_isAppear) then 
		for i, effectNode in ipairs(self.m_lEffectNode) do 
			effectNode:setAlpha(0)
			effectNode:runAction(cc.FadeIn:create(g_constant:get('SKILL', 'LEAF_INDICATOR_EFFECT_DELAY') * i))
		end
		self.m_isAppear = false
	end
end

-------------------------------------
-- function createWithParent
-------------------------------------
function EffectBezierLink:createWithParent(parent, x, y, z_order, res_name, visual_name, is_repeat)
    local animator = MakeAnimator(res_name)
    animator:changeAni(visual_name, is_repeat)
    animator.m_node:setPosition(x, y)
    parent:addChild(animator.m_node, z_order)

    return animator
end

-------------------------------------
-- function registCommonAppearAniHandler
-- @brief 공통 등장 에니메이션 핸들러 등록
-------------------------------------
function EffectBezierLink:registCommonAppearAniHandler()
    -- local function bar_ani_handler() self.m_effectNode:changeAni('bar_idle', true) end
    -- self.m_effectNode:addAniHandler(bar_ani_handler)

    -- local function start_ani_handler() self.m_startPointNode:changeAni('start_idle', true) end
    -- self.m_startPointNode:addAniHandler(start_ani_handler)

    -- local function end_ani_handler() self.m_endPointNode:changeAni('end_idle', true) end
    -- self.m_endPointNode:addAniHandler(end_ani_handler)
end

-------------------------------------
-- function changeAni
-------------------------------------
function EffectBezierLink:changeAni(ani_name, loop)
    local loop = (loop or false)

    for i, v in pairs(self.m_lEffectNode) do
		v:changeAni(ani_name, loop)
	end
end

-------------------------------------
-- function release
-------------------------------------
function EffectBezierLink:release()
    for i, node in pairs(self.m_lEffectNode) do
        node:removeFromParent(true)
    end
    self.m_lEffectNode = nil
    
    if self.m_node then
        self.m_node:removeFromParent(true)
        self.m_node = nil
    end
end