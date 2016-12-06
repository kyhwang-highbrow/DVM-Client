local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonManageTrain
-------------------------------------
UI_DragonManageTrain = class(PARENT,{
        m_bChangeDragonList = 'boolean',
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


    local list_table_node = self.vars['tableViewNode']
    list_table_node:removeAllChildren()

    -- 생성
    local function create_func(item)
        --[[
        self:reateDragonCardCB(item)
        local ui = item['ui']
        ui.root:setScale(0.7)

        local data = item['data']
        if (self.m_selectDragonOID == data['id']) then
            self:changeDragonSelectFrame()
        end
        --]]
    end

    -- 드래곤 클릭 콜백 함수
    local function click_dragon_item(item)
        --[[
        local data = item['data']
        local dragon_object_id = data['id']
        self:setSelectDragonData(dragon_object_id)
        --]]
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node)
    table_view_ext:setCellInfo(400, 460)
    table_view_ext:setItemUIClass(UI_DragonTrainSlot_ListItem, click_dragon_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    table_view_ext:setItemInfo(self:makeDragonSlotDataList(t_dragon_data))
    table_view_ext:update()

    --self.m_tableViewExt = table_view_ext
end

-------------------------------------
-- function click_lacteaButton
-------------------------------------
function UI_DragonManageTrain:click_lacteaButton()
    cclog('## UI_DragonManageTrain:click_lacteaButton()')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManageTrain:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonManageTrain)
