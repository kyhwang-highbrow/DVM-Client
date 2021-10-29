local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_AncientTower
-------------------------------------
UI_AncientTower = class(PARENT, {
        m_tableView = 'UIC_TableView', -- 탑 층 리스트
        
        m_floorInfo = 'UI_AncientTowerFloorInfo', -- 탑 정보 UI
        m_rankInfo = 'UI_AnceintTowerRank', -- 순위 정보 UI

		m_challengingFloor = 'number', -- 현재 진행중인 층
        m_selectedStageID = 'number', -- 현재 선택된 스테이지 아이디
    })

UI_AncientTower.TAB_INFO = 1
UI_AncientTower.TAB_RANK = 2

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTower:init()
    local vars = self:load_keepZOrder('tower_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_AncientTower')

    -- 층 정보, 랭킹 UI
    self.m_floorInfo = UI_AncientTowerFloorInfo(self)
    self.m_rankInfo = UI_AncientTowerRank(self)

    -- 현재 진행중인 층
    local challengingFloor = g_ancientTowerData:getChallengingFloor()
    local challengingStageID = g_ancientTowerData:getChallengingStageID()

    self.m_challengingFloor = challengingFloor
    self.m_selectedStageID = challengingStageID

    self:initUI()
    self:initButton()

    -- 최초 진입시 도전 층 정보 표시
    self:refresh(g_ancientTowerData.m_challengingInfo)

    self:sceneFadeInAction()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    -- @ TUTORIAL : ancient, @jhakim 190411 튜토리얼 진입 제외
    --TutorialManager.getInstance():startTutorial(TUTORIAL.ANCIENT, self)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_AncientTower:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AncientTower'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('고대의 탑')
    self.m_staminaType = 'tower'
    self.m_subCurrency = 'ancient'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTower:initUI()
    local vars = self.vars

    do -- 시즌 남은 시간 표시
        local str_time = g_ancientTowerData:getAncientTowerStatusText()
        vars['timeLabel']:setString(str_time)
    end

	do -- 테이블 뷰 생성
        local node = vars['floorNode']
        node:removeAllChildren()
        
		-- 층 생성
		local t_floor = clone(g_ancientTowerData:getAcientTower_stageList())
        table.insert(t_floor, { stage = ANCIENT_TOWER_STAGE_ID_START, is_bottom = true })
        table.insert(t_floor, { stage = g_ancientTowerData:getTopStageID() + 1, is_top = true })

		-- 셀 아이템 생성 콜백
		local create_func = function(ui, data)
            if (data['is_bottom'] or data['is_top']) then
                return
            end

            ui.vars['floorBtn']:registerScriptTapHandler(function()
                self:selectFloor(data)
            end)

            local stage_id = data['stage']
            if (stage_id == self.m_selectedStageID) then
                self:changeFloorVisual(stage_id, ui)
            end

			return true
        end

        local make_func = function(data)
            if (data['is_bottom']) then
                return UI_AncientTowerListBottomItem(data)
            elseif (data['is_top']) then
                return UI_AncientTowerListTopItem(data)
            else
			    return UI_AncientTowerListItem(data)
            end
        end
		
        -- 테이블 뷰 인스턴스 생성
        self.m_tableView = UIC_TableView(node)
        self.m_tableView:setUseVariableSize(true)
        self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)
        self.m_tableView:setCellUIClass(make_func, create_func)
        self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.m_tableView:setItemList(t_floor)

        self.m_tableView.m_scrollView:setLimitedOffset(true)

        local function sort_func(a, b)
            return a['data']['stage'] < b['data']['stage']
        end
        table.sort(self.m_tableView.m_itemList, sort_func)
        
        self.m_tableView:makeAllItemUINoAction()
                
        -- 현재 도전중인 층이 바로 보이도록 처리
        local floor = g_ancientTowerData:getFloorFromStageID(self.m_selectedStageID)
        self.m_tableView:relocateContainerFromIndex(floor + 1)
    end

	-- 스킬 슬라임 보상 강조
	local curr_floor = g_ancientTowerData:getClearFloor()
	if (curr_floor < 50) then
		local slime_id = 129215
		local t_slime = TableSlime():get(slime_id)
    
		local res_name = t_slime['res']
		local evolution = 1
		local attr = t_slime['attr']

		vars['itemNode']:removeAllChildren()
		local animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
		vars['itemNode']:addChild(animator.m_node)

		local goal_floor = (50 > curr_floor) and (curr_floor >= 30) and 50 or 30
		local left_cnt = goal_floor - curr_floor
		vars['rewardLabel2']:setString(Str('{1}층 남음', left_cnt))

		vars['rewardBtn']:setVisible(true)
	end

    -- 시즌 보상 팝업 (보상이 있다면)
    local ui
    if (g_ancientTowerData.m_tSeasonRewardInfo) then
        local t_info = g_ancientTowerData.m_tSeasonRewardInfo
        local is_clan = false

        ui = UI_AncientTowerRankingRewardPopup(t_info, is_clan)
        
        g_ancientTowerData.m_tSeasonRewardInfo = nil
	end
    -- 클랜 보상 팝업 (보상이 있다면)
    if (g_ancientTowerData.m_tClanRewardInfo) then
        local t_info = g_ancientTowerData.m_tClanRewardInfo
        local is_clan = true

        if (ui) then
            ui:setCloseCB(function()
                UI_AncientTowerRankingRewardPopup(t_info, is_clan)
            end)
        else
            UI_AncientTowerRankingRewardPopup(t_info, is_clan)
        end

        g_ancientTowerData.m_tClanRewardInfo = nil
    end

    -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
    local scr_size = cc.Director:getInstance():getWinSize()
    vars['bgSprite']:setScale(scr_size.width / 1280)

    -- 받기로 예정된 보상
    local t_possible_reward = g_ancientTowerData:getPossibleReward()
    if (t_possible_reward) then
        local l_reward = plSplit(t_possible_reward['reward'], ',')
        local ind = 1
        for _, item_str in ipairs(l_reward) do
            local t_item = plSplit(item_str, ';')
            if (vars['meRewardLabel' .. ind]) then
                vars['meRewardLabel' .. ind]:setString(descBlank(t_item[2]))
            end
            ind = ind + 1
        end
        local rank_name = UI_AncientTowerRewardListItem.getNameStr(t_possible_reward)
        vars['totalRankLabel']:setString(rank_name)
    -- 보상 정보가 없다면 - 로 세팅
    else
        vars['meRewardLabel1']:setString('-')
        vars['meRewardLabel2']:setString('-')
        vars['meRewardLabel3']:setString('-')
        vars['totalRankLabel']:setString('-')
    end

    -- 다음 보상 까지 ~ 남음
    local until_next_reward = g_ancientTowerData:getUntilNextRewardText()
    vars['rewardLabel']:setString(until_next_reward)
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTower:initButton()
    local vars = self.vars
    vars['readyBtn']:registerScriptTapHandler(function() self:click_readyBtn() end)
    vars['rankBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)
    vars['recordBtn']:registerScriptTapHandler(function() self:click_recordBtn() end)
end

-------------------------------------
-- function update
-------------------------------------
function UI_AncientTower:update(dt)
    local vars = self.vars

    -- 고대의탑 테이블뷰 offset에 맞춰서 배경도 같이 스크롤 시킴

    -- 테이블뷰의 현재 스크롤 비율을 계산
    local _, min_offset = self.m_tableView:minContainerOffset()
    local _, max_offset = self.m_tableView:maxContainerOffset()
    local tower_offset = self.m_tableView.m_scrollView:getContentOffset()
    local scroll_rate = (tower_offset['y'] - min_offset) / (max_offset - min_offset)

    -- 배경 스크롤 좌표를 계산(화면 크기 고려)
    local bg_size = vars['bgSprite']:getContentSize()
    local scr_size = cc.Director:getInstance():getWinSize()
    local bg_scope = bg_size['height'] - scr_size['height']
    local bg_scroll_y = bg_scope * scroll_rate - (bg_scope / 2)

    vars['bgSprite']:setPosition(0, bg_scroll_y)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTower:refresh(floor_info)
    local vars = self.vars

    -- 층 정보 UI 갱신
    self.m_floorInfo:refresh(floor_info)

    -- 준비 버튼 활성화/비활성화
    local select_floor = floor_info.m_floor + ANCIENT_TOWER_STAGE_ID_START
    local is_open = g_ancientTowerData:isOpenStage(select_floor)
    vars['readyBtn']:setEnabled(is_open)
    vars['lockSprite']:setVisible(not is_open)
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_AncientTower:click_rankBtn(floor_info)
    local vars = self.vars
    UI_AncientTowerRankNew()
end

-------------------------------------
-- function click_recordBtn
-------------------------------------
function UI_AncientTower:click_recordBtn(floor_info)
    local vars = self.vars
    local cb_finish = function(t_data)
        local ui_best = UI_AncientTowerBestDeckPopup(self.m_selectedStageID, t_data)
        local move_func = function(t_data)
            self:selectFloor(t_data, true) -- 해당 층에 포커싱, 이동 시켜줌
        end
        ui_best:setFuncMove(move_func)    
    end
    
    g_ancientTowerData:requestAllAncientScore(cb_finish)
end

-------------------------------------
-- function click_readyBtn
-------------------------------------
function UI_AncientTower:click_readyBtn()
	local func = function()
        local stage_id = self.m_selectedStageID

        local function close_cb()
            local ui = UIManager:getLastUI()
            ui:sceneFadeInAction()
        end

        local ui = UI_ReadySceneNew(stage_id)
        ui:setCloseCB(close_cb)
    end

    self:sceneFadeOutAndCallFunc(func)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AncientTower:click_exitBtn()
	self:close()
end

-------------------------------------
-- function selectFloor
-------------------------------------
function UI_AncientTower:selectFloor(floor_info, is_move)
    local stage_id = floor_info['stage']
    
    if (self.m_selectedStageID ~= stage_id) then
        local finish_cb 
        finish_cb = function(ret)
            local prev_stage_id = self.m_selectedStageID
            self.m_selectedStageID = stage_id
            local stage_info = ret['ancient_stage']
            local floor_info = StructAncientTowerFloorData(stage_info)
            self:refresh(floor_info)
            self:changeFloorVisual(prev_stage_id)
            self:changeFloorVisual(self.m_selectedStageID)

            if (is_move) then
                -- 현재 도전중인 층이 바로 보이도록 처리
                local floor = g_ancientTowerData:getFloorFromStageID(self.m_selectedStageID)
                self.m_tableView:relocateContainerFromIndex(floor + 1)
            end
        end

        g_ancientTowerData:request_ancientTowerInfo(stage_id, finish_cb)
    end
end

-------------------------------------
-- function changeFloorVisual
-------------------------------------
function UI_AncientTower:changeFloorVisual(stage_id, ui)
    local t_item = self.m_tableView.m_itemMap[stage_id]
    local ui = ui or t_item['ui']
    
    local is_selected = (stage_id == self.m_selectedStageID)
    local is_opened = g_ancientTowerData:isOpenStage(stage_id)
    local visual_id

    -- 스테이지 속성 보너스
    local t_info = TABLE:get('anc_floor_reward')[stage_id]
    local attr = t_info['bonus_attr']

    if (is_selected) then
        visual_id = 'select'

        if attr and (attr ~= '') then
            visual_id = (visual_id .. '_' .. attr)
        end
    else
        visual_id = 'normal'
    end

    ui.vars['towerVisual']:changeAni(visual_id, true)

    -- 속성 보너스가 있는 스테이지일 경우
    if attr and (attr ~= '') then
        self.vars['attrMenu']:setVisible(true)
        cca.uiReactionSlow(self.vars['attrMenu'])
        
        -- 속성 아이콘
        local icon = IconHelper:getAttributeIconButton(attr)
        self.vars['attrNode']:removeAllChildren()
        self.vars['attrNode']:addChild(icon)
        
        -- TIP
        local attr_str = dragonAttributeName(attr)
        local str = Str('TIP.\n전투에 참여한 {1}속성 드래곤의 수에 따라\n보너스 점수를 획득할 수 있어요.', attr_str)
        self.vars['attrInfoLabel']:setString(str)

        -- 속성 보너스
        self.vars['attrLabel']:setString(Str('{1}속성 보너스', attr_str))
        
        -- 색상 변경
        local color = COLOR[attr]
        self.vars['attrSprite1']:setColor(color)
        self.vars['attrSprite2']:setColor(color)
        self.vars['attrLabel']:setColor(color)
    else
        self.vars['attrMenu']:setVisible(false)
    end
end

--@CHECK
UI:checkCompileError(UI_AncientTower)