local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonLair
-------------------------------------
UI_DragonLair = class(PARENT,{
    m_lairTableView = '',

    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonLair:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonLair'
    self.m_subCurrency = 'blessing_ticket'  -- 상단 유저 재화 정보 중 서브 재화
    self.m_bVisible = true or false
    self.m_titleStr = nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_bShowInvenBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLair:init(doid)
    local vars = self:load('dragon_lair.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, self.m_uiName)

    self:sceneFadeInAction()
    self:initUI()
    self:initButton()    
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_DragonLair:init_after()
    PARENT.init_after(self)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLair:initUI()
    local vars = self.vars

    self:init_lairSlot()
    self:init_dragonTableView()
    --self:init_lairTableView()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonLair:initButton()
    local vars = self.vars

    vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
    vars['blessBtn']:registerScriptTapHandler(function() self:click_blessBtn() end)
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonLair:getDragonList()
    local result_dragon_map = {}
    local m_dragons = g_dragonsData:getDragonsListRef()

    for doid, struct_dragon_data in pairs(m_dragons) do
        if TableLairCondition:getInstance():isMeetCondition(struct_dragon_data) == true then
            result_dragon_map[doid] = struct_dragon_data
        end
    end

    return result_dragon_map
end

-------------------------------------
-- function init_lairSlot
-------------------------------------
function UI_DragonLair:init_lairSlot()
    local vars = self.vars

    local l_dids = g_lairData:getLairSlotDidList()
    for i, did in ipairs(l_dids) do
        local node_str = string.format('dragonNode%d', i)
        local birth_grade = TableDragon:getBirthGrade(did)

        local t_dragon_data = {}
        t_dragon_data['did'] = did
        t_dragon_data['evolution'] = 3
        t_dragon_data['grade'] = TableLairCondition:getInstance():getLairConditionGrade(birth_grade)
        t_dragon_data['lv'] = TableLairCondition:getInstance():getLairConditionLevel(birth_grade)

        local card_ui = MakeSimpleDragonCard(did, t_dragon_data)
        vars[node_str]:removeAllChildren()
        vars[node_str]:addChild(card_ui.root)
    end
end

-------------------------------------
-- function init_dragonTableView
-- @breif 드래곤 리스트 테이블 뷰
-------------------------------------
function UI_DragonLair:init_dragonTableView()
    if (not self.m_tableViewExt) then
        local list_table_node = self.vars['materialTableViewNode']

        local function make_func(object)
            return UI_DragonCard(object)
        end

        local function create_func(ui, data)
            self:createDragonCardCB(ui, data)
            ui.root:setScale(0.66)
            ui.vars['clickBtn']:registerScriptTapHandler(function() self:setSelectDragonData(data['id']) end)
            ui.vars['clickBtn']:unregisterScriptPressHandler()
            -- 승급/진화/스킬강화 
            -- local is_noti_dragon = data:isNotiDragon()
            -- ui:setNotiSpriteVisible(is_noti_dragon)

            -- 새로 획득한 드래곤 뱃지
            local is_new_dragon = data:isNewDragon()
            ui:setNewSpriteVisible(is_new_dragon)
        end

        local table_view_td = UIC_TableViewTD(list_table_node)
        table_view_td.m_cellSize = cc.size(100, 100)
        table_view_td.m_nItemPerCell = 5
        table_view_td:setCellUIClass(make_func, create_func)
        self.m_tableViewExt = table_view_td
    end

    local l_item_list = self:getDragonList()
    self.m_tableViewExt:setItemList(l_item_list)

--[[     -- 드래곤 선택 버튼이 있다면
    local list_btn = self.vars['listBtn']
    if (list_btn) then
        list_btn:registerScriptTapHandler(function() self:click_listBtn() end)
    end ]]
end

-------------------------------------
-- function init_lairTableView
-------------------------------------
function UI_DragonLair:init_lairTableView()
--[[      local node = self.vars['materialTableViewNode']

    -- 리스트 아이템 생성 콜백
    local function make_func(object)
        return UI_DragonCard(object)
    end

    local function create_func(ui, data)
        
        ui.root:setScale(0.66)
        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function()
            --self:click_dragon(data)
            self:setSelectLairDragonData(data['id'])
        end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(102, 102)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['scale'])
    table_view_td:setCellCreatePerTick(3)
    self.m_lairTableView = table_view_td
    self.m_lairTableView:setItemList({}) ]]
end

-------------------------------------
-- function checkDragonSelect
-- @brief 선택이 가능한 드래곤인지 여부
-- @override
-------------------------------------
function UI_DragonLair:checkDragonSelect(doid)
	-- 재료용 검증 함수이지만 판매와 동일하기 때문에 사용
    local possible, msg = g_dragonsData:possibleMaterialDragon(doid)

    if possible then
        return true
    else
        UIManager:toastNotificationRed(msg)
        return false
    end
end

-------------------------------------
-- function setSelectDragonData
-- @brief 선택된 드래곤 설정
-------------------------------------
function UI_DragonLair:setSelectDragonData(doid, b_force)
    local ok_btn_cb = function ()
        local struct_dragon = g_dragonsData:getDragonObject(doid)
        if struct_dragon ~= nil then
            self.m_lairTableView:addItem(doid, struct_dragon)
            self.m_tableViewExt:delItem(doid)
        end
    end

    -- 등록 가능 여부 체크
    if self:checkDragonSelect(doid) == false then
        return
    end

    local msg = Str('드래곤을 라테아에 등록하시겠습니까?')
    local submsg = Str('라테아에 등록해도 자유롭게 해제가 가능합니다.')
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function setSelectLairDragonData
-- @brief 선택된 라테아 드래곤 설정
-------------------------------------
function UI_DragonLair:setSelectLairDragonData(object_id, b_force)
    local ok_btn_cb = function ()
        local struct_dragon = g_dragonsData:getDragonObject(object_id)
        if struct_dragon ~= nil then
            self.m_tableViewExt:addItem(object_id, struct_dragon)
            self.m_lairTableView:delItem(object_id)

            self:apply_dragonSort()
        end
    end

    local msg = Str('드래곤을 라테아에서 해제하시겠습니까?')
    local submsg = Str('해제해도 자유롭게 등록이 가능합니다.')
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLair:refresh()
    local vars = self.vars
    
    for type = 1, 5 do
        local stat_id_list = {10001, 10004, 10006, 10007}
        local attr_str = TableLairStatus:getInstance():getLairOverlapStatStrByIds(stat_id_list)
        local label_str = string.format('typeLabel%d', type)

        if #stat_id_list == 0 then
            vars[label_str]:setString(Str('축복 효과 없음'))
        else
            vars[label_str]:setString(attr_str)
        end
    end
end

-------------------------------------
-- function click_blessBtn
-------------------------------------
function UI_DragonLair:click_blessBtn()
    UI_DragonLairBlessingPopup.open()
end

-------------------------------------
-- function click_helpBtn
-------------------------------------
function UI_DragonLair:click_helpBtn()
    local ui = MakePopup('dragon_lair_info_popup.ui')
    -- @UI_ACTION
    ui:doActionReset()
    ui:doAction(nil, false)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonLair:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonLair)
