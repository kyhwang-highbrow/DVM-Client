-------------------------------------
-- class TutorialManager
-------------------------------------
TutorialManager = class({
    m_tutorialNode = '',
    m_tutorialClippingNode = '',
    m_tTutorialBtnInfoTable = '',
    m_tutorialStencilEffect = '',
    m_tutorialPlayer = '',
})

local private_obj
-------------------------------------
-- function startTutorial
-- @brief 튜토리얼 실행
-------------------------------------
function TutorialManager:getInstance()
    if (not private_obj) then
        private_obj = TutorialManager() 
    end

    return private_obj
end

-------------------------------------
-- function startTutorial
-- @brief 튜토리얼 실행
-------------------------------------
function TutorialManager:startTutorial(script, tar_ui)
    self:doTutorial()
    local ui = UI_TutorialPlayer(script, tar_ui)
    UIManager.m_scene:addChild(ui.root, SCENE_ZORDER.TUTORIAL_DLG)
    ui:next()

    self.m_tutorialPlayer = ui
end

-------------------------------------
-- function doTutorial
-- @brief 튜토리얼 실행
-------------------------------------
function TutorialManager:doTutorial()
    -- 초기화
    self:releaseTutorial()

    local visible_size = cc.Director:getInstance():getVisibleSize()

    -- 하위 UI가 클릭되지 않도록 레이어 생성
	local block_layer = cc.Layer:create()
	local function onTouch(touch, event)
		if block_layer:isVisible() then
			event:stopPropagation()
			return true
		else
			return false
		end
	end
	UIManager:setLayerToEventListener(block_layer, onTouch)

    -- 배경을 어둡게
	local color_layer = UIManager:makeMaskingLayer()
    color_layer:setDockPoint(ZERO_POINT)
    color_layer:setAnchorPoint(ZERO_POINT)
	
    -- clipping 생성
    local clipping_node = cc.ClippingNode:create()
	clipping_node:setContentSize(visible_size['width'], visible_size['height'])
    clipping_node:setInverted(true)
    clipping_node:addChild(color_layer)
    self.m_tutorialClippingNode = clipping_node

    -- 기본 스텐실 생성
	self:releaseTutorialStencil()

    -- tutorial node 생성
	local tutorial_node = cc.Menu:create()
	tutorial_node:setNormalSize(visible_size['width'], visible_size['height'])
    tutorial_node:addChild(block_layer, -1)
	tutorial_node:addChild(clipping_node, -1)

	UIManager.m_scene:addChild(tutorial_node, SCENE_ZORDER.TUTORIAL)

    -- 멤버 변수 할당
    self.m_tutorialNode = tutorial_node
    self.m_tTutorialBtnInfoTable = {}

    -- 튜토리얼하는 동안 전역 블럭 처리
    self:setGlobalLock(true)
end

-------------------------------------
-- function setGlobalLock
-- @brief 
-------------------------------------
function TutorialManager:setGlobalLock(b)
    g_broadcastManager:setEnable(not b)
    g_broadcastManager:setEnableNotice(not b)
    g_topUserInfo:clearBroadcast()
    g_currScene:blockBackkey(b)
end

-------------------------------------
-- function setVisibleTutorial
-- @brief 
-------------------------------------
function TutorialManager:setVisibleTutorial(b)
    self.m_tutorialNode:setVisible(b)
end

-------------------------------------
-- function releaseTutorial
-- @brief 튜토리얼 해제
-------------------------------------
function TutorialManager:releaseTutorial()
    -- m_tutorialNode가 없다면 정상적으로 동작하지 않은것
	if (self.m_tutorialNode) then 
        self:revertNodeAll()
        self:releaseTutorialStencil()

		self.m_tutorialNode:removeFromParent(true)
		self.m_tutorialNode = nil

        self:setGlobalLock(false)

        if (self.m_tutorialPlayer) then
            self.m_tutorialPlayer.root:removeFromParent()
            self.m_tutorialPlayer = nil
        end
	end
end

-------------------------------------
-- function setTutorialStencil
-- @brief 튜토리얼 스텐실 설정
-------------------------------------
function TutorialManager:setTutorialStencil(node)
	local stencil = cc.DrawNode:create()
    stencil:clear()
    local rectangle = TutorialHelper:getStencilRectangle(node)
    local white = cc.c4b(1,1,1,1) 
    stencil:drawPolygon(rectangle, 4, white, 1, white)
    self.m_tutorialClippingNode:setStencil(stencil)
    
    -- 스텐실을 돋보이는 효과 추가
    self:setStencilEffect(node)
end

-------------------------------------
-- function setStencilEffect
-- @brief 스텐실에 반짝이는 프레임 씌움
-------------------------------------
function TutorialManager:setStencilEffect(node)
    if (self.m_tutorialStencilEffect) then
        self.m_tutorialStencilEffect:removeFromParent()
        self.m_tutorialStencilEffect = nil
    end

    local res = 'res/ui/frames/tutorial_highlight_0101.png'
    local effect = cc.Scale9Sprite:create(res)
    effect:setAnchorPoint(node:getAnchorPoint())
    effect:setDockPoint(node:getDockPoint())
    
    -- 10px 정도 더 크게 만듬
    local size = node:getContentSize()
    size = {['width'] = size['width'] + 10, ['height'] = size['height'] + 10}
    effect:setContentSize(size)

    self.m_tutorialNode:addChild(effect, 2)

    -- tutorialNode에 맞는 좌표 계산
    local world_pos = TutorialHelper:convertToWorldSpace(self.m_tutorialNode, node)
    effect:setPosition(world_pos['x'], world_pos['y'])

    -- 반짝반짝
    effect:runAction(cca.flash())
    
    -- 삭제를 위해 등록
    self.m_tutorialStencilEffect = effect
end

-------------------------------------
-- function setTutorialStencil
-- @brief 튜토리얼 스텐실 해제
-------------------------------------
function TutorialManager:releaseTutorialStencil()
    local node = cc.Node:create()
    node:retain()
    self.m_tutorialClippingNode:setStencil(node)
    
    if (self.m_tutorialStencilEffect) then
        self.m_tutorialStencilEffect:removeFromParent()
        self.m_tutorialStencilEffect = nil
    end
end

-------------------------------------
-- function attachToTutorialNode
-- @brief m_tutorialNode에 받아온 uic_node를 붙인다.
-------------------------------------
function TutorialManager:attachToTutorialNode(uic_node)
	local node = uic_node.m_node

    -- tutorialNode에 맞는 좌표 계산
    local world_pos = TutorialHelper:convertToWorldSpace(self.m_tutorialNode, node)

    -- 돌아갈 정보 저장
    local parent = node:getParent()
    local pos = {node:getPosition()}
    local z_order = node:getLocalZOrder()
    self.m_tTutorialBtnInfoTable[uic_node] = {parent = parent, pos = pos, z_order = z_order}

    -- tutorialNode에 붙여버린다.
    UIHelper:reattachNode(self.m_tutorialNode, node, 2)

    uic_node:setPosition(world_pos['x'], world_pos['y'])
end

-------------------------------------
-- function revertTutorialBtn
-- @brief m_tutorialNode에 붙여놓은 uic_node를 되돌린다.
-------------------------------------
function TutorialManager:revertNode(uic_node)
    local t_info = self.m_tTutorialBtnInfoTable[uic_node]
    local parent = t_info['parent']
    local pos = t_info['pos']
    local z_order = t_info['z_order']

    -- 원래의 부모에게 붙여줌
    UIHelper:reattachNode(parent, uic_node.m_node, z_order)
    
    uic_node:setPosition(pos[1], pos[2])
end

-------------------------------------
-- function revertNodeAll
-- @brief 튜토리얼 노드에 붙인 버튼을 전부 되돌린다.
-------------------------------------
function TutorialManager:revertNodeAll()
    if (self.m_tTutorialBtnInfoTable) then
        for uic_node, _ in pairs(self.m_tTutorialBtnInfoTable) do
            self:revertNode(uic_node)
        end
    end
    self.m_tTutorialBtnInfoTable = {}
end

-------------------------------------
-- function makePointingHand
-- @brief 가리키는 손가락을 만든다.
-------------------------------------
function TutorialManager:makePointingHand()
    local res = 'res/ui/a2d/tutorial/tutorial.vrp'
    local hand = MakeAnimator(res)
    hand:changeAni('hand_02', true)
    hand:setScale(0.8)
    hand:setAnchorPoint(cc.p(0, 1))
    hand:setDockPoint(cc.p(1, 0))
    hand:setPosition(0, 0)

    -- retain이 포인트
    hand.m_node:retain()

    return hand
end