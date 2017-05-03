local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_AncientTowerScene
-------------------------------------
UI_AncientTowerScene = class(PARENT, {
        m_tableView = 'UIC_TableView', -- 탑 층 리스트
        
		m_challengingFloor  = 'number',-- 현재 진행중인 층
        m_selectedFloor     = 'number',-- 현재 선택된 층
        m_selectedStageID   = 'number',-- 현재 선택된 스테이지 아이디
    })

UI_AncientTowerScene.TAB_FIRST_REWARD = 1
UI_AncientTowerScene.TAB_SWEEP_REWARD = 2

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerScene:init()
    local vars = self:load('tower_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_AncientTowerScene')

    -- 현재 진행중인 층

    local challengingFloor = g_ancientTowerData:getChallengingFloor()
    local challengingStageID = g_ancientTowerData:getChallengingStageID()

    self.m_challengingFloor = challengingFloor
    self.m_selectedFloor = challengingFloor
    self.m_selectedStageID = challengingStageID
	
    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_AncientTowerScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AncientTowerScene'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('고대의 탑')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerScene:initUI()
    local vars = self.vars
	
	do -- 테이블 뷰 생성
        local node = vars['floorNode']
        node:removeAllChildren()

		-- 층 생성
		local t_floor = g_ancientTowerData:getAcientTower_stageList()
                
		-- 셀 아이템 생성 콜백
		local create_func = function(ui, data)
            ui.vars['floorBtn']:registerScriptTapHandler(function()
                ui.vars['selectSprite']:setVisible(true)

                self:selectFloor(data)
            end)

            ui.vars['selectSprite']:setVisible(data['stage'] == self.m_selectedStageID)

			return true
        end

        local make_func = function(data)
            if (data['stage'] == 1401001) then
                local ui = UI_AncientTowerListItem(data)
                return ui
            else
			    return UI_AncientTowerListItem(data)
            end
        end
		
        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_bUseEachSize = true
        table_view._vordering = VerticalFillOrder['BOTTOM_UP']
        table_view:setCellUIClass(make_func, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(t_floor)

        local function sort_func(a, b)
            return a['data']['stage'] < b['data']['stage']
        end
        table.sort(table_view.m_itemList, sort_func)
        table_view:makeAllItemUI()
        
        -- 현재 진행중인 층이 보이도록 임시 처리...
        local offset = table_view:_offsetFromIndex(self.m_selectedFloor)
        table_view.m_scrollView:setContentOffset(cc.p(0, -offset.y), false)

        self.m_tableView = table_view
    end
    
    do -- 도전 횟수
        local value = g_ancientTowerData:getChallengingCount()
        vars['weakenLabel']:setString(Str('도전 횟수 {1}회', value))
    end

    do -- 약화 등급
        local value = g_ancientTowerData:getChallengingCount()
        value = math_min(value, ANCIENT_TOWER_MAX_DEBUFF_LEVEL)
        vars['challengeLabel']:setString(Str('약화 등급 {1}/{2}', value, ANCIENT_TOWER_MAX_DEBUFF_LEVEL))
    end
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_AncientTowerScene:initTab()
    local vars = self.vars
    self:addTab(UI_AncientTowerScene.TAB_FIRST_REWARD, vars['rewardBtn1'], vars['rewardNode1'])
    self:addTab(UI_AncientTowerScene.TAB_SWEEP_REWARD, vars['rewardBtn2'], vars['rewardNode2'])
    self:setTab(UI_AncientTowerScene.TAB_FIRST_REWARD)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerScene:initButton()
    local vars = self.vars

    vars['readyBtn']:registerScriptTapHandler(function() self:click_readyBtn() end)
    vars['sweepBtn']:registerScriptTapHandler(function() self:click_sweepBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerScene:refresh()
    local vars = self.vars

    local stage_id = self.m_selectedStageID
    local t_drop = TableDrop():get(stage_id)
    local is_open = g_ancientTowerData:isOpenStage(stage_id)
    local is_challenging_floor = (self.m_selectedFloor == g_ancientTowerData:getChallengingFloor())
    local sweep_count = g_ancientTowerData:getSweepCount()

    vars['weakenNode']:setVisible(is_challenging_floor)

    do -- 현재 포커싱된 층 수
        vars['floorLabel']:setString(Str('고대의 탑 {1}층', self.m_selectedFloor))
    end
    
    do -- 보상
        local t_reward = TABLE:get('ancient_reward')[stage_id]
        if (t_reward) then
            do -- 첫 클리어 보상
                local l_str = seperate(t_reward['reward_first'], ';')
                self:setFirstRewardUI(l_str[1], l_str[2])
            end

            do -- 소탕시 보상
                l_str = seperate(t_reward['reward_sweep_floor'], ';')
                self:setSweepRewardUI(l_str[1], l_str[2])
            end
        end
    end
        
    do -- 소탕 정보
        local value = g_ancientTowerData:getSweepCount()
        vars['sweepEnergyLabel']:setString(string.format('%d/1', value))
    end

    do -- 스태미나 갯수 표시
        local cost_value = t_drop['cost_value']
        vars['actingPowerLabel']:setString(comma_value(cost_value))
    end

    do -- 버튼
        vars['readyBtn']:setEnabled(is_open)
        vars['sweepBtn']:setEnabled(sweep_count == 0)
                        
        if (is_challenging_floor and (self.m_challengingFloor > 0)) then
            vars['readyBtn']:setPositionX(145)
            vars['sweepBtn']:setVisible(true)
        else
            vars['readyBtn']:setPositionX(0)
            vars['sweepBtn']:setVisible(false)
        end
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_AncientTowerScene:onChangeTab(tab, first)
    local vars = self.vars

    for i = 1, 2 do
        vars['rewardNode' .. i]:setVisible(i == tab)
        vars['rewardLabel' .. i]:setVisible(i == tab)
    end
end

-------------------------------------
-- function click_readyBtn
-------------------------------------
function UI_AncientTowerScene:click_readyBtn()
	UI_AdventureStageInfo(self.m_selectedStageID)
end

-------------------------------------
-- function click_sweepBtn
-------------------------------------
function UI_AncientTowerScene:click_sweepBtn()
    local function finish_cb(items_list)
        UI_AncientTowerSweepReward(self.m_challengingFloor, items_list)
    end

    g_ancientTowerData:request_ancientTowerSweep(finish_cb)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AncientTowerScene:click_exitBtn()
	local is_use_loading = false
    local scene = SceneLobby(is_use_loading)
	scene:runScene()
end

-------------------------------------
-- function setFirstRewardUI
-------------------------------------
function UI_AncientTowerScene:setFirstRewardUI(id, count)
    local vars = self.vars

    local item_type = id
    local item_id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
    local item_count = tonumber(count)
    local item_name = TableItem:getItemName(item_id)

    local item_card = UI_ItemCard(item_id, item_count)
    item_card.vars['clickBtn']:setEnabled(false)
    vars['rewardNode1']:removeAllChildren()
    vars['rewardNode1']:addChild(item_card.root)
    vars['rewardLabel1']:setString(item_name .. ' X ' .. item_count)
end

-------------------------------------
-- function setSweepRewardUI
-------------------------------------
function UI_AncientTowerScene:setSweepRewardUI(id, count)
    local vars = self.vars

    local item_type = id
    local item_id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
    local item_count = tonumber(count)
    local item_name = TableItem:getItemName(item_id)

    local item_card = UI_ItemCard(item_id, item_count)
    item_card.vars['clickBtn']:setEnabled(false)
    vars['rewardNode2']:removeAllChildren()
    vars['rewardNode2']:addChild(item_card.root)
    vars['rewardLabel2']:setString(item_name .. ' X ' .. item_count)
end

-------------------------------------
-- function selectFloor
-------------------------------------
function UI_AncientTowerScene:selectFloor(floor_info)
    local stage_id = floor_info['stage']

    if (self.m_selectedStageID ~= stage_id) then
        local t_item = self.m_tableView.m_itemMap[self.m_selectedStageID]
        local ui = ui or t_item['ui']
        ui.vars['selectSprite']:setVisible(false)

        self.m_selectedStageID = stage_id
        self.m_selectedFloor = g_ancientTowerData:getFloorFromStageID(stage_id)

        self:refresh()
    end
end

--@CHECK
UI:checkCompileError(UI_AncientTowerScene)
