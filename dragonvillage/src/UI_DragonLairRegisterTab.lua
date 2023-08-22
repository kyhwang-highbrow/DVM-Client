local PARENT = UI_IndivisualTab
-------------------------------------
-- class UI_DragonLairRegisterTab
-------------------------------------
UI_DragonLairRegisterTab = class(PARENT,{
    m_dragonTableView = 'TableVIew',
    m_sortManagerDragon = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairRegisterTab:init(owner_ui)
    local vars = self:load('dragon_lair_register.ui')
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLairRegisterTab:initUI()
    local vars = self.vars

    local sort_lair_register_available = function (a, b, ascending)
        local a_data = a['data'] and a['data'] or a
        local b_data = b['data'] and b['data'] or b
    
        local a_value = (g_lairData:isRegisterLairDid(a_data['did']) == false) and 1 or 0
        local b_value = (g_lairData:isRegisterLairDid(b_data['did']) == false) and 1 or 0
    
        -- 같을 경우 리턴
        if (a_value == b_value) then
            return nil
        end
    
        -- 오름차순 or 내림차순
        if ascending then return a_value < b_value
        else              return a_value > b_value
        end
    end

    self.m_sortManagerDragon = SortManager_Dragon()
    self.m_sortManagerDragon:addPreSortType('sort_lair_register_available', false, sort_lair_register_available)
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonLairRegisterTab:getDragonList()
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
-- function initTableView
-- @breif 드래곤 리스트 테이블 뷰
-------------------------------------
function UI_DragonLairRegisterTab:initTableView()

    local list_table_node = self.vars['materialList']
    list_table_node:removeAllChildren()

    local function make_func(object)
        return UI_DragonCard(object)
    end

    local function create_func(ui, data)
        ui.root:setScale(0.66)
        -- 이미 한번 등록된 드래곤이냐?
        local is_register_doid = g_lairData:isRegisterLairByDoid(data['did'], data['id'])
        ui:setTeamBonusCheckSpriteVisible(is_register_doid)
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:registerToLair(data['id']) end)
        return ui
    end

    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 5
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
function UI_DragonLairRegisterTab:apply_dragonSort()
    if self.m_dragonTableView == nil then
        return
    end

    local list = self.m_dragonTableView.m_itemList
    self.m_sortManagerDragon:sortExecution(list)
    self.m_dragonTableView:setDirtyItemList()
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_DragonLairRegisterTab:onEnterTab(first)
    self:initTableView()
    
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_DragonLairRegisterTab:onExitTab()
end

-------------------------------------
-- function registerToLair
-- @brief 드래곤 둥지 추가
-------------------------------------
function UI_DragonLairRegisterTab:registerToLair(doid, b_force)
    local ok_btn_cb = function ()
        local sucess_cb = function (ret)
            self.m_dragonTableView:delItem(doid)
            self.m_ownerUI:refresh()
        end

        g_lairData:request_lairAdd(doid, sucess_cb)
    end    

    if g_settingData:isSkipAddToLairConfimPopup() == true then
        ok_btn_cb()
        return
    end

    local msg = Str('드래곤을 동굴에 등록하시겠습니까?')
    local submsg = Str('동굴에 등록해도 자유롭게 해제가 가능합니다.')
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)

    -- 잠금 설정된 드래곤인지 체크
    local check_cb = function()
        g_settingData:setSkipAddToLairConfimPopup()
    end
    
    ui:setCheckBoxCallback(check_cb)
end