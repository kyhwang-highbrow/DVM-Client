local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonManageTrain
-------------------------------------
UI_DragonManageTrain = class(PARENT,{
        m_bChangeDragonList = 'boolean',
        m_trainSlotTableView = 'UIC_TableView',
        m_bExpanded = 'boolean',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManageTrain:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManageTrain'
    self.m_bVisible = true or false
    self.m_titleStr = Str('수련') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_bExpanded = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageTrain:init(doid, b_ascending_sort, sort_type)
    self.m_bChangeDragonList = false

    local vars = self:load('dragon_train.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManageTrain')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr(b_ascending_sort, sort_type)

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    do -- 1초 후에 리스트를 접음
        local function func()
            self:setExpand(false, 0.5)
        end
        cca.reserveFunc(self.root, 0.5, func)
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManageTrain:initUI()
    local vars = self.vars

    self:init_dragonTableView()
    --self:setDefaultSelectDragon()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManageTrain:initButton()
    local vars = self.vars

    vars['lacteaButton']:registerScriptTapHandler(function() self:click_lacteaButton() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageTrain:refresh()

    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    -- 드래곤 테이블
    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(t_dragon_data['did'])

    -- 드래곤 정보 갱신
    self:refresh_currDragonInfo(t_dragon_data, t_dragon)

    -- 수련에 의한 능력치 갱신
    self:refresh_currDragonTrainStatus(t_dragon_data, t_dragon)

    -- 보유 라테아 갯수 라벨
    local lactea = g_userData:get('lactea')
    vars['lacteaLabel']:setString(comma_value(lactea))

    self:int_trainSlotTableView(t_dragon_data)
end

-------------------------------------
-- function refresh_currDragonInfo
-------------------------------------
function UI_DragonManageTrain:refresh_currDragonInfo(t_dragon_data, t_dragon)
    local vars = self.vars

    -- 드래곤 이름
    vars['nameLabel']:setString(Str(t_dragon['t_name']))

    do -- 드래곤 리소스
        vars['dragonNode']:removeAllChildren()
        local card = UI_DragonCard(t_dragon_data)
        vars['dragonNode']:addChild(card.root)
    end
end

-------------------------------------
-- function refresh_currDragonTrainStatus
-------------------------------------
function UI_DragonManageTrain:refresh_currDragonTrainStatus(t_dragon_data, t_dragon)
    local vars = self.vars

    local table_dragon_train_status = TableDragonTrainStatus()
    local l_status = table_dragon_train_status:getTrainStatus(t_dragon_data['did'], t_dragon_data['train_slot'])

    -- 수련으로 상승한 능력치 출력
    vars['hpLabel']:setString(Str('체력 증가+{1}', comma_value(l_status['hp'])))
    vars['defLabel']:setString(Str('방어력 증가+{1}', comma_value(l_status['def'])))
    vars['atklabel']:setString(Str('공격력 증가+{1}', comma_value(l_status['atk'])))
end

-------------------------------------
-- function makeDragonSlotDataList
-------------------------------------
function UI_DragonManageTrain:makeDragonSlotDataList(t_dragon_data)
    
    local doid = t_dragon_data['id']

    local l_dragon_slot_data = {}

    for i=1,6 do
        l_dragon_slot_data[i] = {doid=doid, grade=i}
    end

    return l_dragon_slot_data
end


-------------------------------------
-- function int_trainSlotTableView
-------------------------------------
function UI_DragonManageTrain:int_trainSlotTableView(t_dragon_data)

    local l_item_list = self:makeDragonSlotDataList(t_dragon_data)

    if (not self.m_trainSlotTableView) then
        -- 테이블뷰의 부모 노드
        local list_table_node = self.vars['tableViewNode']
        list_table_node:removeAllChildren()

        -- 셀 아이템 생성 콜백
        local function create_func(ui, data)
            ui.root:setSwallowTouch(false)
            ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_expandBtn() end)
            ui.vars['trainButtonA']:registerScriptTapHandler(function() self:click_trainButton(ui, data, 'a') end)
            ui.vars['rewardBtnA']:registerScriptTapHandler(function() self:click_trainButton(ui, data, 'a') end)
            ui.vars['trainButtonB']:registerScriptTapHandler(function() self:click_trainButton(ui, data, 'b') end)
            ui.vars['rewardBtnB']:registerScriptTapHandler(function() self:click_trainButton(ui, data, 'b') end)
        end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(list_table_node)
        table_view.m_defaultCellSize = cc.size(518, 518)
        table_view.m_bUseEachSize = true
        table_view:setCellUIClass(UI_DragonTrainSlot_ListItem, create_func)
        table_view:setItemList(l_item_list, false, true)

        self.m_trainSlotTableView = table_view
    else
        for i,v in ipairs(self.m_trainSlotTableView.m_itemList) do
            v['data'] = l_item_list[i]
            v['ui'].m_doid = v['data']['doid']
            v['ui'].m_grade = v['data']['grade']
            v['ui']:refresh()
        end
    end
end

-------------------------------------
-- function click_lacteaButton
-------------------------------------
function UI_DragonManageTrain:click_lacteaButton()
    local ui = UI_DragonGoodbye()

    -- UI종료 후 콜백
    local function close_cb()
        if ui.m_bChangeDragonList then
            self.m_bChangeDragonList = true
            self:init_dragonTableView()

            -- 기존에 선택되어 있던 드래곤이 없어졌을 경우
            if (not g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)) then
                self:setDefaultSelectDragon(nil)
            end

            -- 보유 라테아 갯수 라벨
            local vars = self.vars
            local lactea = g_userData:get('lactea')
            vars['lacteaLabel']:setString(comma_value(lactea))
        end

        self:sceneFadeInAction()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_expandBtn
-------------------------------------
function UI_DragonManageTrain:click_expandBtn()
    if self.m_trainSlotTableView then
        local b_expanded = (not self.m_bExpanded)
        self:setExpand(b_expanded)
    end
end

-------------------------------------
-- function click_trainButton
-------------------------------------
function UI_DragonManageTrain:click_trainButton(ui, data, slot_type)
    local grade = ui.m_grade

    local slot_name = string.format('%.2d_%s', grade, slot_type)

    local level, is_max_level, reward_receive = ui:parseTrainSlotData(slot_name)

    -- 최대 레벨, 보상까지 받은 경우
    if (is_max_level == true) and (reward_receive == true) then
        UIManager:toastNotificationRed(Str('더이상 수련할 수 없습니다.'))

    --보상
    elseif (is_max_level == true) and (reward_receive == false) then    
        self:networkTrainRewardRequest(slot_name, ui)

    --수련
    else
        self:networkTrainRequest(slot_name, ui)
    end
end

-------------------------------------
-- function networkTrainRequest
-------------------------------------
function UI_DragonManageTrain:networkTrainRequest(slot_name, ui)
    local grade = ui.m_grade
    local dragon_grade = self.m_selectDragonData['grade']

    -- 수련 슬롯 등급 체크
    if (dragon_grade < grade) then
        UIManager:toastNotificationRed(Str('{1}등급이 되어야 수련할 수 있습니다.', grade))
        return
    end

    do -- 라테아 갯수 체크
        local table_dragon = TableDragon()
        local t_dragon = table_dragon:get(self.m_selectDragonData['did'])

        local table_dragon_train_info = TableDragonTrainInfo()
        local req_lactea = table_dragon_train_info:getReqLactea(grade, t_dragon['rarity'])

        local lactea = g_userData:get('lactea')
        if (lactea < req_lactea) then
            local function openLacteaPopup()
                self:click_lacteaButton()
            end

            MakeSimplePopup(POPUP_TYPE.YES_NO, Str('라테아가 부족합니다.\n"라테아 변화"으로 이동하시겠습니까?'), openLacteaPopup)
            return
        end
    end

    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID

    local function success_cb(ret)
        self:networkTrainResponse(ret, ui)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/train')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('slotid', slot_name)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function networkTrainResponse
-------------------------------------
function UI_DragonManageTrain:networkTrainResponse(ret, ui)
    local vars = self.vars

    -- 라테아 갱신
    if ret['lactea'] then
        g_serverData:applyServerData(ret['lactea'], 'user', 'lactea')
        g_topUserInfo:refreshData()

        vars['lacteaLabel']:setString(comma_value(ret['lactea']))
    end

    -- 드래곤 정보 갱신
    if ret['dragon'] then
        g_dragonsData:applyDragonData(ret['dragon'])

        -- 드래곤 테이블
        local t_dragon_data = ret['dragon']
        local table_dragon = TableDragon()
        local t_dragon = table_dragon:get(t_dragon_data['did'])

        -- 수련에 의한 능력치 갱신
        self:refresh_currDragonTrainStatus(t_dragon_data, t_dragon)
    end

    ui:refresh()

    self.m_bChangeDragonList = true
end

-------------------------------------
-- function networkTrainRewardRequest
-------------------------------------
function UI_DragonManageTrain:networkTrainRewardRequest(slot_name, ui)
    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID

    local function success_cb(ret)
        self:networkTrainRewardResponse(ret, ui)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/train/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('slotid', slot_name)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function networkTrainRewardResponse
-------------------------------------
function UI_DragonManageTrain:networkTrainRewardResponse(ret, ui)
    local vars = self.vars

    -- 라테아 갱신
    if ret['lactea'] then
        local prev_lactea = g_userData:get('lactea')

        g_serverData:applyServerData(ret['lactea'], 'user', 'lactea')
        g_topUserInfo:refreshData()

        vars['lacteaLabel']:setString(comma_value(ret['lactea']))

        local next_lactea = ret['lactea']

        local add_lactea = (next_lactea - prev_lactea)
        UIManager:toastNotificationGreen(Str('보상으로 {1}개의 라테아를 수령하였습니다.', add_lactea))
    end

    -- 드래곤 정보 갱신
    if ret['dragon'] then
        g_dragonsData:applyDragonData(ret['dragon'])

        -- 드래곤 테이블
        local t_dragon_data = ret['dragon']
        local table_dragon = TableDragon()
        local t_dragon = table_dragon:get(t_dragon_data['did'])
    end

    ui:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManageTrain:click_exitBtn()
    self:close()
end

-------------------------------------
-- function setExpand
-- @param
-------------------------------------
function UI_DragonManageTrain:setExpand(expand, duration)
    if (self.m_bExpanded == expand) then
        return
    end

    self.m_bExpanded = expand

    local table_view = self.m_trainSlotTableView

    for i,v in ipairs(table_view.m_itemList) do
        local ui = v['ui']
        ui:setExpand(expand, duration)
    end

    table_view:expandTemp(duration)

    if (not expand) then
        table_view:relocateContainer(true)
    end
end

--@CHECK
UI:checkCompileError(UI_DragonManageTrain)
