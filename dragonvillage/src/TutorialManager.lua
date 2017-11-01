-------------------------------------
-- class TutorialManager
-- @brief tutorial의 시작과 끝을 관장하고 ServerData_Tutorial로 부터 튜토리얼 플레이 여부 받아옴
-------------------------------------
TutorialManager = class({
    m_isTutorialDoing = 'bool',

    m_tutorialNode = 'cc.Node',
    m_tutorialClippingNode = 'cc.ClippingNode',
    m_tTutorialBtnInfoTable = 'table',
    m_tutorialStencilEffect = 'cc.Sprite',
    m_tutorialPlayer = 'UI',
})

local _instance
-------------------------------------
-- function startTutorial
-- @brief 튜토리얼 실행
-------------------------------------
function TutorialManager.getInstance()
    if (not _instance) then
        _instance = TutorialManager(true)
    end

    return _instance
end

-------------------------------------
-- function init
-------------------------------------
function TutorialManager:init(is_singleton)
    if (not is_singleton) then
        error('Singleton class can not be initiated')
    end
    self.m_isTutorialDoing = false
end

-------------------------------------
-- private function __startTutorial
-------------------------------------
local function _startTutorial(tutorial_mgr, tutorial_key, tar_ui)
    -- 튜토리얼 키에 대한 예외처리
    if (not tutorial_key) then
        ccdisplay('#### tutorial key is not exist')
        return
    end
    if (not table.find(TUTORIAL, tutorial_key)) then
        ccdisplay(string.format('#### %s is not registrated', tutorial_key))
        return
    end
    if (not LuaBridge:isFileExist(string.format('data/scenario/%s.csv', tutorial_key))) then
        ccdisplay(string.format('#### %s.csv is not exist', tutorial_key))
        return
    end

    -- 튜토리얼 실행 : UI세팅
    tutorial_mgr:doTutorial()

    -- 튜토리얼 플레이어 -> 종료 하면서 튜토리얼 기록 저장
    local ui = UI_TutorialPlayer(tutorial_key, tar_ui)
    UIManager.m_scene:addChild(ui.root, SCENE_ZORDER.TUTORIAL_DLG)
    tutorial_mgr.m_tutorialPlayer = ui
    ui:setCloseCB(function() g_tutorialData:request_tutorialSave(tutorial_key) end)
    ui:next()
end

-------------------------------------
-- function startTutorial
-- @brief 튜토리얼 실행
-- @param tutorial_key : tutorial_key이자 tutorial_script이름
-------------------------------------
function TutorialManager:startTutorial(tutorial_key, tar_ui)
    -- 개발모드에서 튜토리얼 동작하지 않도록 함
    if (IS_TEST_MODE()) then
        
        -- 지정된 튜토리얼은 개발모드에서만 계속 동작 할 수 있도록 한다.
        if (g_constant:get('DEBUG', 'TEST_TUTORIAL') == tutorial_key) then
            _startTutorial(self, tutorial_key, tar_ui)
        end

        return
    end

    -- 완료되지 않은 튜토리얼이라면
    if (not g_tutorialData:isTutorialDone(tutorial_key)) then
        _startTutorial(self, tutorial_key, tar_ui)
    end
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

    -- 튜토리얼 실행중 명시
    self.m_isTutorialDoing = true
end

-------------------------------------
-- function setGlobalLock
-- @brief 전역 블럭
-------------------------------------
function TutorialManager:setGlobalLock(b)
    g_broadcastManager:setEnable(not b)
    g_broadcastManager:setEnableNotice(not b)
    g_topUserInfo:clearBroadcast()
    UIManager:blockBackKey(b)
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
	end

    -- tutorial 재생기 해제
    if (self.m_tutorialPlayer) then
        self.m_tutorialPlayer.root:removeFromParent()
        self.m_tutorialPlayer = nil
    end

    -- 전역 블럭 해제
    self:setGlobalLock(false)

    -- 튜토리얼 종료 명시
    self.m_isTutorialDoing = false
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

    self.m_tutorialNode:addChild(effect, 1)

    -- tutorialNode에 맞는 좌표 계산
    local world_pos = TutorialHelper:convertToWorldSpace(self.m_tutorialNode, node)
    effect:setPosition(world_pos['x'], world_pos['y'])

    -- 반짝반짝
    effect:runAction(cca.flash())
    
    -- 삭제를 위해 등록
    self.m_tutorialStencilEffect = effect
end

-------------------------------------
-- function releaseTutorialStencil
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
	local node = uic_node.m_node or uic_node

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
    for uic_node, _ in pairs(self.m_tTutorialBtnInfoTable) do
        self:revertNode(uic_node)
    end

    self.m_tTutorialBtnInfoTable = {}
end

-------------------------------------
-- function deleteNodeAll
-- @brief 튜토리얼 노드에 붙인 버튼을 전부 삭제해버림
-------------------------------------
function TutorialManager:deleteNodeAll()
    for uic_node, _ in pairs(self.m_tTutorialBtnInfoTable) do
        uic_node.m_node:removeFromParent(true)
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

-------------------------------------
-- function changeTargetUI
-- @brief target ui 변경
-------------------------------------
function TutorialManager:changeTargetUI(tar_ui)
    self.m_tutorialPlayer:setTargetUI(tar_ui)
end

-------------------------------------
-- function findTargetUI
-- @brief target ui 찾아서 변경
-------------------------------------
function TutorialManager:findTargetUI()
    local tar_ui
    for _, ui in pairs(table.reverse(UIManager.m_uiList)) do
        if (not isExistValue(ui.m_uiName, 'UI_Network', 'untitled')) then
            return ui
        end
    end

    return false
end

-------------------------------------
-- function refreshTargetUI
-- @brief 최상위 UI로 targetUI를 변경한다.
-------------------------------------
function TutorialManager:refreshTargetUI()
    local old_tar_ui = self.m_tutorialPlayer.m_targetUI
    local new_tar_ui = self:findTargetUI()
    
    -- 바뀐 ui가 없는 경우
    if (not new_tar_ui) then
        return
    end
      
    -- ui가 바뀐 경우
    if (old_tar_ui ~= new_tar_ui) then
        -- 기존 UI가 닫힌 경우라면 활성화 시킨 버튼을 날려버린다.
        if (old_tar_ui:isClosed()) then
            self:deleteNodeAll()
        end    
        self:changeTargetUI(new_tar_ui)
    end
end

-------------------------------------
-- function isDoing
-- @brief 튜토리얼 실행중 여부
-------------------------------------
function TutorialManager:isDoing()
    return self.m_isTutorialDoing
end
