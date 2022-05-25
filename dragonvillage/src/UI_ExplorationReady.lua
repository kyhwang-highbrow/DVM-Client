local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ExplorationReady
-------------------------------------
UI_ExplorationReady = class(PARENT,{
        m_eprID = '',
        m_tableViewTD = '',
        m_selectedHours = 'number',-- 선택된 탐험 시간
        m_selectedDragonList = 'list',
        m_selectedDragonMap = 'map',
        m_currSlotIdx = 'number',
        m_currDragonCnt = 'number',
        m_focusDeckSlotEffect = 'cc.Sprite',
        m_sortManagerDragon = 'SortManager_Dragon',
        m_uicSortList = 'UIC_SortList',
        m_bActive = 'boolean',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ExplorationReady:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ExplorationReady'
    self.m_bVisible = true or false
    self.m_titleStr = Str('탐험 준비') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_ExplorationReady:init(epr_id)
    self.m_eprID = epr_id
    self.m_selectedDragonList = {}
    self.m_selectedDragonMap = {}
    self.m_currSlotIdx = 1
    self.m_currDragonCnt = 0
    self.m_bActive = false

    local vars = self:load('exploration_ready.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ExplorationReady')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ExplorationReady:initUI()
    local vars = self.vars
    self:init_tableView()

    -- 정렬 매니저
    self:init_dragonSortMgr()

    do
        self.m_focusDeckSlotEffect = cc.Sprite:create('res/ui/frames/temp/dragon_select_frame.png')
        self.m_focusDeckSlotEffect:setDockPoint(cc.p(0.5, 0.5))
        self.m_focusDeckSlotEffect:setAnchorPoint(cc.p(0.5, 0.5))
        self.vars['subRoot']:addChild(self.m_focusDeckSlotEffect, 2)

        self.m_focusDeckSlotEffect:setScale(0.6)
        self.m_focusDeckSlotEffect:setVisible(true)
        self.m_focusDeckSlotEffect:setPosition(self.vars['slotNode1']:getPosition())

        self.m_focusDeckSlotEffect:stopAllActions()
        self.m_focusDeckSlotEffect:setOpacity(255)
        self.m_focusDeckSlotEffect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.FadeTo:create(0.5, 255))))
    end

    -- 모험의 order가 모험모드의 chapter로 간주한다
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)
    local chapter = location_info['order']

    local res = string.format('res/ui/icons/adventure_map/chapter_01%.2d.png', chapter)
    local icon = cc.Sprite:create(res)
    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))
    vars['stageNode']:addChild(icon)


    do -- 테스트
        local l_doid = g_settingData:getExplorationDec(self.m_eprID)
        if l_doid then
            for i,v in ipairs(l_doid) do
                self:click_dragonBtn(v)
            end
        end
    end
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_ExplorationReady:init_tableView()
    local node = self.vars['selectListNode']
    --node:removeAllChildren()

    local l_item_list = g_explorationData:getDragonList()

    -- 생성 콜백
    local item_scale = 0.66
    local function create_func(ui, data)
        ui.root:setScale(item_scale)

        ui:setCheckSpriteVisible(false)
        ui:setReadySpriteVisible(false)
        ui:setTeamReadySpriteVisible(false)
        
        -- 다른 지역을 탐험 중인 드래곤인지 여부 체크
        local doid = data['id']
        if g_explorationData:isExplorationUsedDragon(doid) then
            ui:setShadowSpriteVisible(true)
            ui:setReadySpriteVisible(true)
            
        end

        if self.m_selectedDragonMap[doid] then
            ui:setCheckSpriteVisible(true)
        end

        local doid = data['id']
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonBtn(doid) end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(150 * item_scale, 150 * item_scale)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    table_view_td:setItemList(l_item_list)

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel(Str('보유한 드래곤이 없습니다.'))

    -- 정렬
    --g_friendData:sortForFriendList(table_view.m_itemList)
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExplorationReady:initButton()
    local vars = self.vars
    vars['explorationBtn']:registerScriptTapHandler(function() self:click_explorationBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExplorationReady:refresh()
    local vars = self.vars
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    -- 지역 이름
    vars['locationLabel']:setString(Str(location_info['t_name']))

    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)    

    local sec = location_info['clear_time']
    local time_str = ServerTime:getInstance():makeTimeDescToSec(sec, true)
    vars['timeLabel']:setString(Str('탐험 소요 : {1}', time_str))

    -- 획득하는 아이템 리스트
    local reward_items_str = location_info['reward_items']
    local reward_items_list = g_itemData:parsePackageItemStr(reward_items_str)

    -- UI 자수정 표시 추가
    -- @kwkang 20-11-11 하드코딩 자수정을 지우고, 서버 테이블을 이용하도록 변경
    -- table.insert(reward_items_list, {item_id = ITEM_ID_AMET, count = 0})
    vars['rewardNode']:removeAllChildren()

    local scale = 0.53
    local l_pos = getSortPosList(150 * scale + 3, #reward_items_list)

    for i,v in ipairs(reward_items_list) do
        local ui = UI_ItemCard(v['item_id'], v['count'])
        vars['rewardNode']:addChild(ui.root)
        ui.root:setScale(0)
        ui.root:setPosition(l_pos[i], 0)
        ui.root:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.025), cc.ScaleTo:create(0.25, scale)))
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ExplorationReady:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_dragonBtn
-------------------------------------
function UI_ExplorationReady:click_dragonBtn(doid, skip_msg)

    if (not g_dragonsData:getDragonDataFromUid(doid)) then
        return
    end

    -- 다른 지역을 탐험 중인 드래곤은 사용할 수 없음
    if (not skip_msg) and g_explorationData:isExplorationUsedDragon(doid) then
        UIManager:toastNotificationRed(Str('다른 지역을 탐험 중인 드래곤입니다.'))
        return
    end

    local slot_idx = self.m_selectedDragonMap[doid]
    local table_view_td = self.m_tableViewTD

    -- 장착
    if (not slot_idx) then
        
        -- 인원 제한
        if (self.m_currDragonCnt >= 5) then
            UIManager:toastNotificationRed(Str('더 이상 선택할 수 없습니다.'))
            return
        end

        -- 드래곤이 선택되면 new뱃지를 삭제
        g_highlightData:removeNewDoid(doid)


        local item = table_view_td:getItem(doid)
        local ui = nil
        if item then
            ui = item['ui']
        end
        if ui then
            ui:setCheckSpriteVisible(true)
        end

        self.m_selectedDragonList[self.m_currSlotIdx] = doid
        self.m_selectedDragonMap[doid] = self.m_currSlotIdx
        self.m_currDragonCnt = (self.m_currDragonCnt + 1)

        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        local ui = UI_DragonCard(t_dragon_data)
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonBtn(doid) end)
        ui:setCheckSpriteVisible(false)
        self.vars['slotNode' .. self.m_currSlotIdx]:addChild(ui.root)

        -- UI 연출
        cca.uiReactionSlow(ui.root)

    -- 해제
    else
        local item = table_view_td:getItem(doid)
        local ui = nil
        if item then
            ui = item['ui']
        end
        if ui then
            ui:setCheckSpriteVisible(false)

            -- UI 연출
            local scale = 0.66
            cca.uiReactionSlow(ui.root, scale, scale, scale*0.9, scale*0.9)
        end

        self.m_selectedDragonMap[doid] = nil
        self.m_selectedDragonList[slot_idx] = nil
        self.m_currDragonCnt = (self.m_currDragonCnt - 1)

        self.vars['slotNode' .. slot_idx]:removeAllChildren()
    end

    -- 다음 slot_idx 지정
    if (5 <= self.m_currDragonCnt) then
        self.m_currSlotIdx = -1

        self.m_focusDeckSlotEffect:setVisible(false)
    else
        for i=1, 5 do
            if (not self.m_selectedDragonList[i]) then
                self.m_currSlotIdx = i
                break
            end
        end

        self.m_focusDeckSlotEffect:setVisible(true)
        self.m_focusDeckSlotEffect:setPosition(self.vars['slotNode' .. self.m_currSlotIdx]:getPosition())

        self.m_focusDeckSlotEffect:stopAllActions()
        self.m_focusDeckSlotEffect:setOpacity(255)
        self.m_focusDeckSlotEffect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.FadeTo:create(0.5, 255))))
    end
    
end

-------------------------------------
-- function click_explorationBtn
-------------------------------------
function UI_ExplorationReady:click_explorationBtn()
    -- 인원 체크
    if (self.m_currDragonCnt < 5) then
        UIManager:toastNotificationRed(Str('탐험에는 5마리의 드래곤이 필요합니다.'))
        return
    end

    local check_dragon_inven
    local check_item_inven
    local start_game

    -- 드래곤 가방 확인(최대 갯수 초과 시 획득 못함)
    check_dragon_inven = function()
        local function manage_func()
            UINavigator:goTo('dragon')
        end
        g_dragonsData:checkMaximumDragons(check_item_inven, manage_func)
    end

    -- 아이템 가방 확인(최대 갯수 초과 시 획득 못함)
    check_item_inven = function()
        local function manage_func()
            -- UI_Inventory() @kwkang 룬 업데이트로 룬 관리쪽으로 이동하게 변경 
            UI_RuneForge('manage')
        end
        g_inventoryData:checkMaximumItems(start_game, manage_func)
    end

    start_game = function()
        local function request()
            local function finish_cb(ret)
                UIManager:toastNotificationGreen(Str('드래곤 5마리가 탐험을 떠났습니다.'))
                self.m_bActive = true
                self:close()

                -- 덱 저장
                local l_doid = g_settingData:setExplorationDec(self.m_eprID, self.m_selectedDragonList)
            end

            -- params
            local epr_id = self.m_eprID
            local doids = listToCsv(self.m_selectedDragonList)

            g_explorationData:request_explorationStart(epr_id, doids, finish_cb)
        end

        
        --MakeSimplePopup(POPUP_TYPE.YES_NO, Str('드래곤 5마리를 탐험을 보내시겠습니까?'), request)
        request() -- 2018-01-11 sgkim 확인 팝업이 불필요한 뎁스라고 느껴져서 제거
    end

    check_dragon_inven()
end


-------------------------------------
-- function init_dragonSortMgr
-- @brief 정렬 도우미
-------------------------------------
function UI_ExplorationReady:init_dragonSortMgr()
    -- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon()

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortSelectBtn'], vars['sortSelectLabel'], UIC_SORT_LIST_TOP_TO_BOT)
    self.m_uicSortList = uic_sort_list
    

    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortManagerDragon:pushSortOrder(sort_type)
        self:apply_dragonSort()
        self:save_dragonSortInfo()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortSelectOrderBtn']:registerScriptTapHandler(function()
            local ascending = (not self.m_sortManagerDragon.m_defaultSortAscending)
            self.m_sortManagerDragon:setAllAscending(ascending)
            self:apply_dragonSort()
            self:save_dragonSortInfo()

            vars['sortSelectOrderSprite']:stopAllActions()
            if ascending then
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
            else
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
            end
        end)

    -- 세이브데이터에 있는 정렬 값을 적용
    self:apply_dragonSort_saveData()
end

-------------------------------------
-- function apply_dragonSort_saveData
-- @brief 세이브데이터에 있는 정렬 순서 적용
-------------------------------------
function UI_ExplorationReady:apply_dragonSort_saveData()
    local l_order = g_settingData:get('dragon_sort_epr', 'order') or g_settingData:get('dragon_sort_fight', 'order')
    local ascending = g_settingData:get('dragon_sort_epr', 'ascending')

    local sort_type
    for i=#l_order, 1, -1 do
        sort_type = l_order[i]
        self.m_sortManagerDragon:pushSortOrder(sort_type)
    end
    self.m_sortManagerDragon:setAllAscending(ascending)

    self.m_uicSortList:setSelectSortType(sort_type)


    do -- 오름차순, 내림차순 아이콘
        local vars = self.vars
        vars['sortSelectOrderSprite']:stopAllActions()
        if ascending then
            vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
        else
            vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
        end
    end
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_ExplorationReady:apply_dragonSort()
    local list = self.m_tableViewTD.m_itemList
    self.m_sortManagerDragon:sortExecution(list)
    self.m_tableViewTD:setDirtyItemList()
end

-------------------------------------
-- function save_dragonSortInfo
-- @brief 새로운 정렬 설정을 세이브 데이터에 적용
-------------------------------------
function UI_ExplorationReady:save_dragonSortInfo()
    g_settingData:lockSaveData()

    -- 정렬 순서 저장
    local sort_order = self.m_sortManagerDragon.m_lSortOrder
    g_settingData:applySettingData(sort_order, 'dragon_sort_epr', 'order')

    -- 오름차순, 내림차순 저장
    local ascending = self.m_sortManagerDragon.m_defaultSortAscending
    g_settingData:applySettingData(ascending, 'dragon_sort_epr', 'ascending')

    g_settingData:unlockSaveData()
end

--@CHECK
UI:checkCompileError(UI_ExplorationReady)
