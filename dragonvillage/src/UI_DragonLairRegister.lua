local PARENT = UI
-------------------------------------
-- class UI_DragonLairRegister
-------------------------------------
UI_DragonLairRegister = class(PARENT,{
    m_dragonTableView = 'TableVIew',
    m_sortManagerDragon = '',
    m_availableDragonList = 'Lit<>',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairRegister:init(owner_ui)
    self.m_uiName = 'UI_DragonLairRegister'
    self.m_availableDragonList = {}
    
    local vars = self:load('dragon_lair_register.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_SimplePopup2')

    self:initUI()
    self:initButton()
    self:initTableView()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLairRegister:initUI()
    local vars = self.vars

    local func_condition_value = function(struct_dragon_data)
        local val = 0

        if TableLairCondition:getInstance():isMeetCondition(struct_dragon_data) == true then
            val = 10
            if g_lairData:isRegisterLairDid(struct_dragon_data['did']) == true then
                val = val + 1
            end
        end

        return val
    end


    local sort_lair_register = function (a, b, ascending)
        local a_data = a['data'] and a['data'] or a
        local b_data = b['data'] and b['data'] or b

        local a_value = func_condition_value(a_data)
        local b_value = func_condition_value(b_data)
    
        -- 같을 경우 리턴
        if (a_value == b_value) then
            return nil
        end
    
        -- 오름차순 or 내림차순
        if ascending then return a_value < b_value
        else              return a_value > b_value
        end
    end

    local sort_mgr = SortManager_Dragon()
    sort_mgr:addPreSortType('sort_lair_register', false, sort_lair_register)
    sort_mgr:pushSortOrder('grade')
    self.m_sortManagerDragon = sort_mgr
    --self.m_sortManagerDragon:addPreSortType('sort_lair_register_available', false, sort_lair_register_available)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonLairRegister:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_registerBtn() end)
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonLairRegister:getDragonList()
--[[     local result_dragon_map = {}
    local m_dragons = g_dragonsData:getDragonsListRef()
    for doid, struct_dragon_data in pairs(m_dragons) do
        if TableLairCondition:getInstance():isMeetCondition(struct_dragon_data) == true then
            result_dragon_map[doid] = struct_dragon_data
        end
    end ]]

    return g_dragonsData:getDragonsListRef()
end

-------------------------------------
-- function makeAvailableDragonList
-------------------------------------
function UI_DragonLairRegister:makeAvailableDragonList()
    local m_dragons = g_dragonsData:getDragonsListRef()
    local list = {}

    self.m_availableDragonList = {}
    for _, struct_dragon_data in pairs(m_dragons) do
        if TableLairCondition:getInstance():isMeetCondition(struct_dragon_data) == true then
            table.insert(self.m_availableDragonList, struct_dragon_data)
        end
    end
end

-------------------------------------
-- function getAvailableDragonDoids
-------------------------------------
function UI_DragonLairRegister:getAvailableDragonDoids()
    local doid_list = {}
    for i,v in ipairs(self.m_availableDragonList) do
        table.insert(doid_list, v['id'])
    end
    return table.concat(doid_list, ',')
end

-------------------------------------
-- function initTableView
-- @breif 드래곤 리스트 테이블 뷰
-------------------------------------
function UI_DragonLairRegister:initTableView()

    local list_table_node = self.vars['materialList']
    list_table_node:removeAllChildren()

    local function make_func(object)
        return UI_DragonCard(object)
    end

    local function create_func(ui, data)
        ui.root:setScale(0.66)
        -- 이미 한번 등록된 드래곤이냐?
        --local is_register_doid = g_lairData:isRegisterLairByDoid(data['did'], data['id'])
        --ui:setTeamBonusCheckSpriteVisible(is_register_doid)

        local is_meet_condition = TableLairCondition:getInstance():isMeetCondition(data)
        local is_registered = g_lairData:isRegisterLairDid(data['did'])
        local is_register_available = is_meet_condition == true and is_registered == false

        ui.root:setColor(is_registered == true and COLOR['white'] or COLOR['deep_gray'])
        ui:setHighlightSpriteVisible(is_register_available)

        --ui.vars['clickBtn']:registerScriptTapHandler(function() self:registerToLair(data['id']) end)
        return ui
    end

    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 9
    table_view_td:setCellUIClass(make_func, create_func)
    self.m_dragonTableView = table_view_td
    

    local l_item_list = self:getDragonList()
    self.m_dragonTableView:setItemList(l_item_list)


    self:apply_dragonSort()
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_DragonLairRegister:apply_dragonSort()
    if self.m_dragonTableView == nil then
        return
    end

    local list = self.m_dragonTableView.m_itemList
    self.m_sortManagerDragon:sortExecution(list)
    self.m_dragonTableView:setDirtyItemList()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLairRegister:refresh()
    local vars = self.vars
    local count = #self.m_availableDragonList
    vars['dragonCountLabel']:setString(Str('등록 가능한 드래곤 수 : {1}마리', count))
end

-------------------------------------
-- function registerToLair
-- @brief 드래곤 둥지 추가
-------------------------------------
function UI_DragonLairRegister:registerToLair(doids)
    local ok_btn_cb = function ()
        local sucess_cb = function (ret)
        end

        g_lairData:request_lairAdd(doid, sucess_cb)
    end    

--[[     if g_settingData:isSkipAddToLairConfimPopup() == true then
        ok_btn_cb()
        return
    end ]]

    local msg = Str('드래곤을 동굴에 등록하시겠습니까?')
    local submsg = Str('동굴에 등록해도 자유롭게 해제가 가능합니다.')
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)

--[[     -- 잠금 설정된 드래곤인지 체크
    local check_cb = function()
        g_settingData:setSkipAddToLairConfimPopup()
    end
    
    ui:setCheckBoxCallback(check_cb) ]]
end

-------------------------------------
-- function click_registerBtn
-------------------------------------
function UI_DragonLairRegister:click_registerBtn()


    local sucess_cb = function (ret)
    end

    --g_lairData:request_lairAdd(doid, sucess_cb)


    
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_DragonLairRegister:click_closeBtn()
    self:close()
end

-------------------------------------
-- function open
-------------------------------------
function UI_DragonLairRegister.open()
    return UI_DragonLairRegister()
end

