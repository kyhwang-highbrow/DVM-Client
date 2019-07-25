local PARENT = UI_ScenarioPlayer

-------------------------------------
-- class UI_TutorialPlayer
-- @brief 사실상 TutorialPlayer
-------------------------------------
UI_TutorialPlayer = class(PARENT,{ 
        m_nextCallBack = '',
        m_nextEffectName = '',
        m_targetUI = 'UI',
        m_pointingHand = 'Animator',

		m_tutorialKey = 'string',

		-- waiting 상태라면 외부에서 호출할 때까지 진행하지 않는다.
		m_isWaiting = 'boolean',

		m_advUI = 'UI',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TutorialPlayer:init(scenario_name, tar_ui)
    -- target ui 가 없는 경우 강제 종료
    if (not tar_ui) then
        return
    end

	self.m_isWaiting = false

    self:setTargetUI(tar_ui)
	self.m_tutorialKey = scenario_name

    local vars = self.vars
    vars['letterboxMenu']:setVisible(false)
end

-------------------------------------
-- function init_player
-------------------------------------
function UI_TutorialPlayer:init_player()
    local vars = self:load_keepZOrder('scenario_talk.ui', false)
end

-------------------------------------
-- function close
-------------------------------------
function UI_TutorialPlayer:close()
    -- pointingHand는 retain걸려있는 상태이므로 release해줌
    if (self.m_pointingHand) then
        self.m_pointingHand.m_node:removeFromParent()
        self.m_pointingHand.m_node:release()
        self.m_pointingHand = nil
    end
    -- 콜백 실행
    if (self.m_closeCB) then
        self.m_closeCB()
    end
    -- 튜토리얼 해제
    TutorialManager.getInstance():releaseTutorial()
end

-------------------------------------
-- function setTargetUI
-------------------------------------
function UI_TutorialPlayer:setTargetUI(tar_ui)
    self.m_targetUI = tar_ui
end

-------------------------------------
-- function set_nextFunc
-------------------------------------
function UI_TutorialPlayer:set_nextFunc(cb, effect_name)
    self.m_nextCallBack = cb
    self.m_nextEffectName = effect_name
end

-------------------------------------
-- function next
-------------------------------------
function UI_TutorialPlayer:next(next_effect)
	if (self.m_isWaiting) then
		return
	end
	if (not self.m_targetUI) then
		cclog('not exist target UI')
	end

    self.m_currPage = self.m_currPage + 1

    local function excute_next_func()
        if (self.m_nextCallBack) then
            self.m_nextCallBack()
            self.m_nextCallBack = nil
        end
    end

    if (self.m_currPage <= self.m_maxPage) then
        -- traget UI 갱신
        if (self.m_targetUI) then
            TutorialManager.getInstance():refreshTargetUI()
        end

        local effect = self.m_nextEffectName
        self:showPage()
  
        -- 페이지에 해당 이펙트 있을 경우에만 next_func 실행
        if (effect) then
            if (self:isExistEffect(self.m_currPage, effect)) then
                excute_next_func()
                self.m_nextEffectName = nil
            end
        else
            excute_next_func()
        end
    else
        self:close()
    end
end

-------------------------------------
-- function showPage
-------------------------------------
function UI_TutorialPlayer:showPage()
	cclog('page : ' .. self.m_currPage)

	local t_page = self.m_scenarioTable[self.m_currPage]
	if (t_page) and (t_page['save']) then
		local tutorial_key = self.m_tutorialKey
		local step = t_page['save']
		g_tutorialData:request_tutorialSave(tutorial_key, step)
	end

	PARENT.showPage(self)
end

-------------------------------------
-- function setPage
-------------------------------------
function UI_TutorialPlayer:setPage(page)
	self.m_currPage = page - 1
end

-------------------------------------
-- function setPageByStep
-------------------------------------
function UI_TutorialPlayer:setPageByStep(step)
	local table_scenario = self.m_scenarioTable
	for page, t_page in pairs(table_scenario) do
		if (t_page['goto'] == step) then
			self:setPage(page)
			break
		end
	end
end

-------------------------------------
-- function applyEffect
-- @comment https://docs.google.com/spreadsheets/d/1_obKDht0MJRJV2GtO3RCEwxY-8NE4Eb4LR2svlix8BU/edit#gid=0 기능일람과 동기화 해주세요!
-- @brief 튜토리얼 전용 기능들 포함
-------------------------------------
function UI_TutorialPlayer:applyEffect(effect)
    -- UI_ScenarioPlayer_util 에 있다면 굳이 또 통과하지 않는다.
    if (not PARENT.applyEffect(self, effect)) then
        return
    end

    local l_str = TableClass:seperate(effect, ';')
    local effect = l_str[1]
    local val_1 = l_str[2]
    local val_2 = l_str[3]

    local vars = self.vars

    if (effect == 'stencil') then
        self:setStencil(val_1)

    elseif (effect == 'pointing') then
        self:pointingNode(val_1)

    elseif (effect == 'activate') then
        self:activeNode(val_1)

    elseif (effect == 'black_layer') then
        self:blackLayerOnOff(val_1)

	elseif (effect == 'wait') then
		self:setWaiting(true)

	elseif (effect == 'touch_block') then
		self:touchBlockOnOff(val_1)

	elseif (effect == 'step_close') then
		self:closeWithoutCB()

	-- 튜토리얼 중에 1-7 보상 보여주기 위해서... 사용... 
	elseif (effect == 'adv_open') then
		local stage_id = 1110101
		self.m_advUI = UI_AdventureSceneNew(stage_id)

	elseif (effect == 'adv_close') then
		self.m_advUI:close()

    -- 튜토리얼 끝나고 튜토리얼 종료 팝업 보여주기 위해서 사용 
	elseif (effect == 'end_popup') then
		self:makeEndUI()
    else
        cclog('정말 없는 effect : ' .. effect)
    end
end

-------------------------------------
-- function setStencil
-- @brief 지정된 노드를 스텐실로 만든다.
-------------------------------------
function UI_TutorialPlayer:setStencil(node_name)
    local tutorial_mgr = TutorialManager.getInstance()

    if (node_name == 'release') then
        tutorial_mgr:releaseTutorialStencil()
        return
    end

    local tar_node = self.m_targetUI.vars[node_name]
    if (tar_node) then
        tutorial_mgr:setTutorialStencil(tar_node)
    end
end

-------------------------------------
-- function pointingNode
-- @brief 지정된 노드에 터치 손가락 a2d 붙인다.
-------------------------------------
function UI_TutorialPlayer:pointingNode(node_name)
    if (node_name == 'release') then
        if (self.m_pointingHand) then
            self.m_pointingHand:setVisible(false)
        end
        return
    end

    local tar_node = self.m_targetUI.vars[node_name]
    if (tar_node) then
        if (not self.m_pointingHand) then
            self.m_pointingHand = TutorialManager.getInstance():makePointingHand()
        end
        self.m_pointingHand.m_node:removeFromParent()
        self.m_pointingHand:setVisible(true)
        tar_node:addChild(self.m_pointingHand.m_node, 99)

		-- 손가락 위치 예외처리
		if (node_name == 'tutorialEggPicker') then
			self.m_pointingHand:setPosition(-200, 150)
		else
			self.m_pointingHand:setPosition(0, 0)
		end

    end
end

-------------------------------------
-- function activeNode
-- @brief 지정된 노드를 활성화 한다.
-------------------------------------
function UI_TutorialPlayer:activeNode(node_name)
    local tutorial_mgr = TutorialManager.getInstance()
    
    if (node_name == 'release') then
        tutorial_mgr:revertNodeAll()
        return

	-- 버튼을 되돌릴 필요가 없는 경우 날려버린다.
	elseif (node_name == 'remove') then
        tutorial_mgr:deleteNodeAll()
        return

    end

	-- 일반적으로는 targetUI의 lua_name을 체크하지만 특수하게 가져오는 케이스도 있다.
    local tar_node = self.m_targetUI.vars[node_name]
	if (not tar_node) then
		-- tar_node를 못 찾은 경우 1초에 한번씩 다시 시도한다, 통신 지연 등으로 화면 전환이 늦게 되는 경우도 있기 때문!
		cclog('## UI_TutorialPlayer:activeNode - find again until target_node is exist')
		local function retry_func()
			tutorial_mgr:refreshTargetUI()
			self:activeNode(node_name)
		end
		local action = cc.Sequence:create(
			cc.DelayTime:create(1),
			cc.CallFunc:create(retry_func)
		)
		self.root:runAction(action)
		return
	end

	-- node 최상단에 붙임
	tutorial_mgr:attachToTutorialNode(tar_node)
		
	-- 버튼이라면 스크립트를 추가한다.
	if (isInstanceOf(tar_node, UIC_Button)) then
		tar_node:addScriptTapHandler(function()
			if (tutorial_mgr:isDoing()) then
				self:next()
			end
		end)

	-- UIC_EggPicker도 가능하다
	elseif (node_name == 'tutorialEggPicker') then
		local egg_picker = self.m_targetUI.vars['UIC_EggPicker']

		-- activating 할때 스크롤도 막는다
		egg_picker:setTouchEnabled(false)
		
		-- egg_picker에 다음페이지 진행을 등록한다
		egg_picker:addItemClickCB(function(t_item, idx)
			if (tutorial_mgr:isDoing()) then
				local t_data = t_item['data']

				-- 상점 알 생성 시키지 않기가 힘들어서..
				if (t_data['is_shop']) then
					return false
				end

				-- 튜토리얼 전용 영웅의 알만 허용
				if (t_data['egg_id'] ~= '703027') then
					return false
				end

				self:next()
				return true
			end
		end)

	end
end

-------------------------------------
-- function blackLayerOnOff
-- @brief 튜토리얼 노드 전체를 on/off
-- @comment 함수명은 사용도에 따른 건데 혹시 필요하다면 정말 마스킹 레이어만 on/off하도록 수정
-------------------------------------
function UI_TutorialPlayer:blackLayerOnOff(cmd)
    local b = (cmd == 'on')
    TutorialManager.getInstance():setVisibleTutorial(b)
end

-------------------------------------
-- function isWaiting
-------------------------------------
function UI_TutorialPlayer:isWaiting()
	return self.m_isWaiting
end

-------------------------------------
-- function setWaiting
-------------------------------------
function UI_TutorialPlayer:setWaiting(b)
	self.m_isWaiting = b
end

-------------------------------------
-- function nextIfWaiting
-------------------------------------
function UI_TutorialPlayer:nextIfWaiting()
	if (self:isWaiting()) then
		self:setWaiting(false)
		self:next()
	end
end

-------------------------------------
-- function blackLayerOnOff
-- @brief 튜토리얼 하위 UI 터치 on/off
-------------------------------------
function UI_TutorialPlayer:touchBlockOnOff(cmd)
    local b = (cmd == 'on')
    TutorialManager.getInstance():setTouchBlock(b)
end

-------------------------------------
-- function click_skip
-------------------------------------
function UI_TutorialPlayer:click_skip()
    if (g_gameScene) then
        g_gameScene:showSkipPopup()
    end
end

-------------------------------------
-- function makeEndUI
-------------------------------------
function UI_TutorialPlayer:makeEndUI()
    local ui = UI()
    ui:load('popup_contents_open.ui')
    
    ui.vars['descLabel']:setString(Str('{@apricot}도움이 필요할 때는 {@default}마스터의 길{@apricot}을 따라가보세요!'))
    ui.vars['contentsLabel']:setString(Str('튜토리얼이 종료되었습니다.'))
    ui.vars['okBtn']:registerScriptTapHandler(function() ui:close() end)
    UIManager:open(ui, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'UI_TutorialEnd')
end
