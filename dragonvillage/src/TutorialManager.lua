TUTORIAL = {
	-- 초기 튜토리얼
    INTRO_FIGHT = 'intro',
    FIRST_START = 'tutorial_first_adv_start',
    FIRST_END = 'tutorial_first_adv_end',
	ADV_01_02_END = 'tutorial_01_02_adv_end',
	ADV_01_07_END = 'tutorial_01_07_adv_end',

	-- 무료뽑기를 서버에 전달하기 위한 축약키
	GACHA11_START = 'gacha_11_start',
	GACHA11_END = 'gacha_11_end',

	-- 컨텐츠 튜토리얼
    COLOSSEUM = 'tutorial_colosseum',
    ANCIENT = 'tutorial_ancient_tower',
    CLAN = 'tutorial_clan',
    CLAN_GUEST = 'tutorial_clan_guest',
}

-------------------------------------
-- class TutorialManager
-- @brief tutorial의 시작과 끝을 관장하고 ServerData_Tutorial로 부터 튜토리얼 플레이 여부 받아옴
-------------------------------------
TutorialManager = class({
    m_isTutorialDoing = 'bool',
	m_isTouchBlock = 'bool',

    m_tutorialNode = 'cc.Node',
    m_tutorialClippingNode = 'cc.ClippingNode',
    m_tTutorialBtnInfoTable = 'table',
    m_tutorialStencilEffect = 'cc.Sprite',
    m_tutorialPlayer = 'UI',
})

local _instance
-------------------------------------
-- function getInstance
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
	self.m_isTouchBlock = true
	self.m_tTutorialBtnInfoTable = {}
end

-------------------------------------
-- function _startTutorial
-------------------------------------
local function _startTutorial(tutorial_mgr, tutorial_key, tar_ui)
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
function TutorialManager:startTutorial(tutorial_key, tar_ui, step, is_force)
	-- 튜토리얼 테스트
	if (IS_TEST_MODE()) then
		if (g_constant:get('DEBUG', 'TEST_TUTORIAL') == tutorial_key) then
			_startTutorial(self, tutorial_key, tar_ui)
			if (step) then
				self:setTutorialStep(step)
			end
			return
		end
	end

	-- 튜토리얼 가능 상태
	if (not self:isCanTutorial(tutorial_key)) then
		return
	end

    -- 완료 체크
    if (not is_force) and (g_tutorialData:isTutorialDone(tutorial_key)) then
		return
    end

	-- strat
	cclog('----------------------------------')
	cclog('## START tutorial', tutorial_key, step)

    _startTutorial(self, tutorial_key, tar_ui)
	if (step) then
		self:setTutorialStep(step)
	end
end

-------------------------------------
-- function isCanTutorial
-- @param : tutorial_key - Nilable : default = 'adv'
-------------------------------------
function TutorialManager:isCanTutorial(tutorial_key)
	-- 여기서 체크하게 되면 
	-- 1. 계정 새로 생성 / 2. 개발모드 off / 3. 튜토리얼 시작 이 가능하다
    --[[
	if (IS_TEST_MODE()) then
		return false
	end
    --]]
    
    --[[
    	-- @jhakim 성장일지 제거	
    	-- 신규 유저
		if (not g_dragonDiaryData:isEnable()) then
			return false
		end
    
    --]]

    -- 1. 성장일지 없을 때 생성한 계정
    -- 2. 성장일지 제거 전 생성한 계정일 경우
    -- 저장 안함
	if (not g_dragonDiaryData:isEnable()) then
		if (not g_dragonDiaryData:getIsAfterCloseDiaryUser()) then
            return false
        end
	end

	-- 임시방편 : 모험 튜토리얼은 렙 10이 넘어가는 경우 시작하지 않도록 함
	local tutorial_key = tutorial_key or 'adv'
	if (g_userData:get('lv') >= 10) and (string.find(tutorial_key, 'adv')) then
		return false
	end

	return true
end

-------------------------------------
-- function setTutorialStep
-- @brief tutorial player의 page를 step에 맞춰 세팅
-------------------------------------
function TutorialManager:setTutorialStep(step)
	self.m_tutorialPlayer:setPageByStep(step)
	self.m_tutorialPlayer:next()
end

-------------------------------------
-- function nextIfPlayerWaiting
-- @brief tutorial player next 호출
-------------------------------------
function TutorialManager:nextIfPlayerWaiting()
	self.m_tutorialPlayer:nextIfWaiting()
end

-------------------------------------
-- function checkTutorialInLobby
-- @comment 하드코딩할 부분을 최대한 몰아서..
-------------------------------------
function TutorialManager:checkTutorialInLobby(ui_lobby)
	-- 튜토리얼 가능 상태
	if (not self:isCanTutorial()) then
		return
	end

	-- 1-1 start 클리어 여부
	local stage_id = 1110101
	local tutorial_key = TUTORIAL.FIRST_START

	local clear_cnt = g_adventureData:getStageClearCnt(stage_id)
	local is_done = g_tutorialData:isTutorialDone(tutorial_key)
	local is_master_road_clear = g_masterRoadData:isClearedRoad(10001)

	if (not is_done) or (clear_cnt == 0) or (not is_master_road_clear) then
		local step = nil
		local is_force = true
		self:startTutorial(tutorial_key, ui_lobby, step, is_force)
		return
	end

	-- 1-1 end 클리어 여부
	tutorial_key = TUTORIAL.FIRST_END
	is_done = g_tutorialData:isTutorialDone(tutorial_key)

	if (not is_done) then
		local step = g_tutorialData:getStep(tutorial_key)

		-- 101 : 마스터의길 보상 수령
		if (step == 101) then
			-- 스텝 101에서 알 보상을 수령 후 스텝102 저장&진입 하기 전에 끝(?)나는 케이스가 있다 그거에 대한 보정
			local is_exist_egg = g_eggsData:isExistTutorialEgg()
			if (is_exist_egg) then
				g_tutorialData:setStep(tutorial_key, 102)
				UINavigator:goTo('hatchery', 'incubate')
				return
			end

            --[[
            local function close_cb()
                --UINavigatorDefinition:goTo('lobby')
            end

			local scene = SceneCommon(UI_MasterRoadPopup, close_cb)
            scene:runScene()
            --]]
            UI_MasterRoadRewardPopup()
			return

		-- 102 : 튜토리얼 알 부화
		elseif (step == 102) then
			-- 튜토리얼 전용 알 존재 여부 체크
			local is_exist_egg = g_eggsData:isExistTutorialEgg()
			if (is_exist_egg) then
				UINavigator:goTo('hatchery', 'incubate')
				return
			else
				-- 마스터의길 10002 보상 수령 여부
				local has_reward, rid = g_masterRoadData:hasRewardRoad()
				if has_reward and (rid == 10002) then
					g_tutorialData:setStep(tutorial_key, 103)
					--UI_MasterRoadPopup()
                    UI_MasterRoadRewardPopup()
					return

				-- 이도 저도 아니고 막 꼬인상태..?
				else
					g_tutorialData:setStep(tutorial_key, 104)
					stage_id = 1110102
					UINavigator:goTo('battle_ready', stage_id)
					return
				end
			end

		-- 103 : 마스터의길 보상 수령
		elseif (step == 103) then
			-- 마스터의길 10002 보상 수령 여부
			local has_reward, rid = g_masterRoadData:hasRewardRoad()
			if has_reward and (rid == 10002) then
				g_tutorialData:setStep(tutorial_key, 103)
				--UI_MasterRoadPopup()
                UI_MasterRoadRewardPopup()
				return
			else
				g_tutorialData:setStep(tutorial_key, 104)
				stage_id = 1110102
				UINavigator:goTo('battle_ready', stage_id)
				return
			end

		-- 104 : 1-2 전투 시작
		elseif (step == 104) then
			stage_id = 1110102
            UINavigatorDefinition:goTo('battle_ready', stage_id)
			return

		end
	end

	-- 1-2 end 는 체크하지 않는다.

	-- 1-7 end
	tutorial_key = TUTORIAL.ADV_01_07_END
	is_done = g_tutorialData:isTutorialDone(tutorial_key)
	if (not is_done) then
		local step = g_tutorialData:getStep(tutorial_key)
		if (step == 101) then
			UINavigator:goTo('hatchery')
			return

		-- 클리어 처리
		elseif (step == 102) then
			g_tutorialData:request_tutorialSave(tutorial_key)
			return
		end
	end

	-- 1-7 tutorial 못한 신규 유저 중 1-7 이미 클리어 한 경우
	if (not is_done) then
		local stage_id = 1110107
		local clear_cnt = g_adventureData:getStageClearCnt(stage_id)
		if (clear_cnt >= 1) then
			local function cb_func()
				local step = 101
				local function go_func()
					UINavigator:goTo('hatchery')
				end
				g_tutorialData:request_tutorialSave(tutorial_key, step, go_func)
			end

			local gacha_key = TUTORIAL.GACHA11_START
			g_tutorialData:request_tutorialSave(gacha_key, nil, cb_func)
			return
		end
	end

	-- 후속 처리는 없기를...
end

-------------------------------------
-- function blockIngamePause
-- @comment ingame 진행 중 pause 막아야 하는지 체크
-------------------------------------
function TutorialManager:blockIngamePause(stage_id)
	
	-- 1-1을 클리어 하지 않고 1-1 end tutorial도 클리어하지 않은 상태
	if (stage_id == 1110101) then
		local tutorial_key = TUTORIAL.FIRST_END
		local clear_cnt = g_adventureData:getStageClearCnt(stage_id)
		local is_done = g_tutorialData:isTutorialDone(tutorial_key)
		if (not is_done) and (clear_cnt == 0) then
			return true
		end

	-- 1-2를 클리어 하지 않고 1-2 end tutorial도 클리어 하지 않은 상태
	elseif (stage_id == 1110102) then
		local tutorial_key = TUTORIAL.ADV_1_2_END
		local clear_cnt = g_adventureData:getStageClearCnt(stage_id)
		local is_done = g_tutorialData:isTutorialDone(tutorial_key)
		if (not is_done) and (clear_cnt == 0) then
			return true
		end

	end

	return false
end

-------------------------------------
-- function showAmazingNewbiePresent
-- @comment 1-7 클리어시의 보상 보여준다
-------------------------------------
function TutorialManager:showAmazingNewbiePresent()

	-- 1-7 모험 클리어 하지 않은 상태여야 함 (기존 유저 거르기)
	local stage_id = 1110107
	local clear_cnt = g_adventureData:getStageClearCnt(stage_id)
	if (clear_cnt ~= 0) then
		return false
	end

	-- 1-7 end 튜토리얼 완료 하지 않아야 함
	if (g_tutorialData:isTutorialDone(TUTORIAL.ADV_01_07_END)) then
		return false
	end
	
	return true
end

-------------------------------------
-- function checkStartFreeSummon11
-- @comment 11연차 무료 튜토리얼 시작 여부
-------------------------------------
function TutorialManager:checkStartFreeSummon11(stage_id)
	-- 1-7에서 왔는지 체크
	if (stage_id ~= 1110107) then
		return false
	end
	--[[
		-- @jhakim 성장일지 제거
		-- 올드 유저는 못함
		if (not g_dragonDiaryData:isEnable()) then
			return false
		end
	--]]

    -- 1. 성장일지 없을 때 생성한 계정
    -- 2. 성장일지 제거 전 생성한 계정일 경우
    -- 저장 안함
	if (not g_dragonDiaryData:isEnable()) then
		if (not g_dragonDiaryData:getIsAfterCloseDiaryUser()) then
            return false
        end
	end

	-- 1-7 clear_cnt 가 1이어야 함 (최초 클리어)
	local clear_cnt = g_adventureData:getStageClearCnt(stage_id)
    -- if (clear_cnt > 1) then @kwkang 2020-11-21 패배 상태에서도 튜토리얼이 진행되는 것 막음
    if (clear_cnt ~= 1) then
		return false
	end

	return true
end

-------------------------------------
-- function checkFullPopupBlock
-- @comment 풀팝업 블럭 여부
-------------------------------------
function TutorialManager:checkFullPopupBlock()
	-- 1-1 start 완료 전에 block
	local tutorial_key = TUTORIAL.FIRST_START
    if (not g_tutorialData:isTutorialDone(tutorial_key)) then
        return true
    end
	local stage_id = 1110101
	local clear_cnt = g_adventureData:getStageClearCnt(stage_id)
	if (clear_cnt == 0) then
		return true
	end
	local is_master_road_clear = g_masterRoadData:isClearedRoad(10001)
	if (not is_master_road_clear) then
		return true
	end

	-- 1-1 end 완료 전에 ...
	local tutorial_key = TUTORIAL.FIRST_END
	if (not g_tutorialData:isTutorialDone(tutorial_key)) then
		-- 저장된 step이 있다면 block
		local step = g_tutorialData:getStep(tutorial_key)
		if (step) then
			return true
		end
    end

	-- 1-7 end 완료 전에 ... 
	local tutorial_key = TUTORIAL.ADV_01_07_END
	if (not g_tutorialData:isTutorialDone(tutorial_key)) then
		-- 저장된 step이 있다면 block
		local step = g_tutorialData:getStep(tutorial_key)
		if (step) then
			return true
		end
	end

	return false
end

-------------------------------------
-- function saveTutorialStepInAdventureResult
-- @comment 모험 결과화면에서 튜토리얼 step 저장 하는 경우
-------------------------------------
function TutorialManager:saveTutorialStepInAdventureResult(stage_id, cb_func)

	-- 1-1 end tutorial
    if (stage_id == 1110101) then
		local clear_cnt = g_adventureData:getStageClearCnt(stage_id)
		if (clear_cnt == 1) then
			local tutorial_key = TUTORIAL.FIRST_END
			local step = 101
			g_tutorialData:request_tutorialSave(tutorial_key, step, cb_func)
		else
			if (cb_func) then
				cb_func()
			end
		end

	-- 1-2 end tutorial
	elseif (stage_id == 1110102) then
		local clear_cnt = g_adventureData:getStageClearCnt(stage_id)
		if (clear_cnt == 1) then
			local tutorial_key = TUTORIAL.ADV_01_02_END
			local step = nil
			g_tutorialData:request_tutorialSave(tutorial_key, step, cb_func)
		else
			if (cb_func) then
				cb_func()
			end
		end

	-- 1-7 end tutorial
	elseif (self:checkStartFreeSummon11(stage_id)) then
		local tutorial_key = TUTORIAL.ADV_01_07_END
		local step = 101
		local function finish_cb()
			local tutorial_key = TUTORIAL.GACHA11_START
			local step = nil
			g_tutorialData:request_tutorialSave(tutorial_key, step, cb_func)
		end
		g_tutorialData:request_tutorialSave(tutorial_key, step, finish_cb)

	-- 콜백은 항상 동작됨
	else
		if (cb_func) then
			cb_func()
		end
	end
end

-------------------------------------
-- function continueTutorial
-- @brief tutorial이 경우에 따라 Scene이 전환되면 날아가 강제로 진행시켜준다.. Scene위에 존재하는 tutorial은 다음에 만들자
-------------------------------------
function TutorialManager:continueTutorial(tutorial_key, check_step, tar_ui)
	local is_done = g_tutorialData:isTutorialDone(tutorial_key)
	if (not is_done) then
		local step = g_tutorialData:getStep(tutorial_key)        
		if (step == check_step) then
			-- continue되는 경우는 이전 튜토리얼 정보를 날려버린다
			self:deleteNodeAll()

			-- target_ui 찾아서 튜토리얼 시작
			local tar_ui = tar_ui or self:findTargetUI()
            cclog(tar_ui.m_uiName)
            cclog(tar_ui.m_resName)
			self:startTutorial(tutorial_key, tar_ui, step)
		end
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
		if (self.m_isTouchBlock) then
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
-- function setTouchBlock
-- @brief 튜토리얼 하위 UI 터치 제어
-------------------------------------
function TutorialManager:setTouchBlock(b)
	self.m_isTouchBlock = b
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
        self.m_tutorialPlayer.root = nil
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

    -- 생성된 순서대로 z_order를 다시 설정해줌
    -- removeFromChild하는 과정에서 orderOfArrival이 이상하게 세팅되어 아예 z-order를 설정해줌
    local l_child = node:getChildren()
    for i, _node in ipairs(l_child) do
        _node:setLocalZOrder(i)
    end

    uic_node:setPosition(world_pos['x'], world_pos['y'])
end

-------------------------------------
-- function revertNode
-- @brief m_tutorialNode에 붙여놓은 uic_node를 되돌린다.
-------------------------------------
function TutorialManager:revertNode(uic_node)
    local t_info = self.m_tTutorialBtnInfoTable[uic_node]
    local parent = t_info['parent']
	local node = uic_node.m_node or uic_node
    local pos = t_info['pos']
    local z_order = t_info['z_order']

    -- 원래의 부모에게 붙여줌
    UIHelper:reattachNode(parent, node, z_order)
    
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

-------------------------------------
-- function forcedClose
-- @brief 튜토리얼 실행중 여부
-------------------------------------
function TutorialManager:forcedClose()
	if (self:isDoing()) then
		if (self.m_tutorialPlayer) then
			self.m_tutorialPlayer:close()
		end
	end
end

-------------------------------------
-- function beforeFirstTutorialDone
-- @comment 첫 번째 튜토리얼 시작 전이라면 return true
-------------------------------------
function TutorialManager:beforeFirstTutorialDone()
	-- 튜토리얼 가능 상태
	if (not self:isCanTutorial()) then
		return false
	end

	-- 1-1 start 클리어 여부
	local stage_id = 1110101
	local tutorial_key = TUTORIAL.FIRST_START

	local clear_cnt = g_adventureData:getStageClearCnt(stage_id)
	local is_done = g_tutorialData:isTutorialDone(tutorial_key)
	local is_master_road_clear = g_masterRoadData:isClearedRoad(10001)

	if (not is_done) or (clear_cnt == 0) or (not is_master_road_clear) then
		return true
	end

    return false
end