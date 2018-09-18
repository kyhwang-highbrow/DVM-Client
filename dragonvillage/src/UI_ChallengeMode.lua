local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ChallengeMode
-------------------------------------
UI_ChallengeMode = class(PARENT, {
        m_tableView = 'table',
        m_selectedStageID = 'number', -- 현재 선택된 스테이지 아이디
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeMode:init()
    local vars = self:load_keepZOrder('challenge_mode_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ChallengeMode')

    self.m_selectedStageID = g_challengeMode:getSelectedStage()

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ChallengeMode:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ChallengeMode'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('그림자의 신전')
    self.m_staminaType = 'st'
    self.m_subCurrency = 'valor'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChallengeMode:initUI()
    local vars = self.vars

    -- 테이블 뷰 생성
    self:initUI_tableView()

    if vars['bgSprite'] then
        -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
        local scr_size = cc.Director:getInstance():getWinSize()
        vars['bgSprite']:setScale(scr_size.width / 1280)
    end
end

-------------------------------------
-- function initUI_tableView
-- @brief 테이블 뷰 생성
-------------------------------------
function UI_ChallengeMode:initUI_tableView()
    local vars = self.vars

    local node = vars['floorNode']
    node:removeAllChildren()
        
	-- 층 생성
	local t_floor = g_challengeMode:getChallengeModeStagesInfo()

	-- 셀 아이템 생성 콜백
	local create_func = function(ui, data)
        ui.vars['stageBtn']:registerScriptTapHandler(function()
            self:selectFloor(data)
        end)

        local stage_id = data['stage']
        if (stage_id == self.m_selectedStageID) then
            self:changeFloorVisual(stage_id, ui)
        end

		return true
    end
		
    -- 테이블 뷰 인스턴스 생성
    self.m_tableView = UIC_TableView(node)
    self.m_tableView:setUseVariableSize(true)
    self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)
    self.m_tableView:setCellUIClass(UI_ChallengeModeListItem, create_func)
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_tableView:setItemList(t_floor)

    self.m_tableView.m_scrollView:setLimitedOffset(true)

    --[[
    local function sort_func(a, b)
        return a['data']['stage'] < b['data']['stage']
    end
    table.sort(self.m_tableView.m_itemList, sort_func)
    --]]
        
    --self.m_tableView:makeAllItemUINoAction()
                
    -- 현재 도전중인 층이 바로 보이도록 처리
    local floor = self.m_selectedStageID
    self.m_tableView:relocateContainerFromIndex(floor + 1)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeMode:initButton()
    local vars = self.vars

    if vars['startBtn'] then
        vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChallengeMode:refresh(floor_info)
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ChallengeMode:click_exitBtn()
	self:close()
end

-------------------------------------
-- function click_startBtn
-- @brief 출전 덱 설정 버튼
-------------------------------------
function UI_ChallengeMode:click_startBtn()
    UI_ChallengeModeDeckSettings(CHALLENGE_MODE_STAGE_ID)
end


-------------------------------------
-- function selectFloor
-------------------------------------
function UI_ChallengeMode:selectFloor(floor_info)
    local stage = floor_info['stage']
    local prev = self.m_selectedStageID
    self.m_selectedStageID = stage

    self:changeFloorVisual(prev)
    self:changeFloorVisual(self.m_selectedStageID)

    -- 실제로 진행될 스테이지 정보 저장
    g_challengeMode:setSelectedStage(self.m_selectedStageID)
end

-------------------------------------
-- function changeFloorVisual
-------------------------------------
function UI_ChallengeMode:changeFloorVisual(stage_id, ui)
    local t_item = self.m_tableView.m_itemMap[stage_id]
    if (not t_item) and (not ui) then
        return
    end
    local ui = ui or t_item['ui']
    
    local is_selected = (stage_id == self.m_selectedStageID)

    if (is_selected) then
        ui.vars['selectedVisual']:setVisible(true)
    else
        ui.vars['selectedVisual']:setVisible(false)
    end
end

--@CHECK
UI:checkCompileError(UI_ChallengeMode)