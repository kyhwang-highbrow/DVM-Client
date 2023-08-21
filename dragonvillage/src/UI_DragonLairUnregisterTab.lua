local PARENT = UI_IndivisualTab
-------------------------------------
-- class UI_DragonLairUnregisterTab
-------------------------------------
UI_DragonLairUnregisterTab = class(PARENT,{
    m_dragonTableView = 'TableVIew',
    m_sortManagerDragon = '',
    m_lairTargetDragonMap = 'Map<number, StructDragonObject>',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairUnregisterTab:init(owner_ui)
    local vars = self:load('dragon_lair_unregister.ui')
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLairUnregisterTab:initUI()
    local vars = self.vars

    local sort_lair_register = function (a, b, ascending)
        local a_data = a['data'] and a['data'] or a
        local b_data = b['data'] and b['data'] or b
    
        local a_value = g_lairData:isRegisterLairDid(a_data['did']) and 1 or 0
        local b_value = g_lairData:isRegisterLairDid(b_data['did']) and 1 or 0
    
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
    self.m_sortManagerDragon:addPreSortType('sort_lair_register', false, sort_lair_register)
end

-------------------------------------
-- function initTableView
-- @breif 드래곤 리스트 테이블 뷰
-------------------------------------
function UI_DragonLairUnregisterTab:initTableView()
    local list_table_node = self.vars['materialList']
    list_table_node:removeAllChildren()

    local function create_func(ui, data)
        ui.root:setScale(0.66)
        -- 이미 한번 등록된 드래곤이냐?
        local is_registered = g_lairData:isRegisterLairDid(data['did'])
        local is_exist_doid = g_lairData:isRegisterLairDragonExist(data['did'])

        ui.root:setColor((is_registered and is_exist_doid) and COLOR['white'] or COLOR['deep_gray'])
        ui:setTeamBonusCheckSpriteVisible(is_registered)
        
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:unregisterFromLair(data, ui) end)
        return ui
    end

    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_dragonTableView = table_view_td
    

    local l_item_list = self:getDragonList()
    self.m_dragonTableView:setItemList(l_item_list)
    
    self:apply_dragonSort()
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonLairUnregisterTab:getDragonList()
    if self.m_lairTargetDragonMap == nil then
        self.m_lairTargetDragonMap = g_lairData:getLairTargetDragonMap()
    end

    return self.m_lairTargetDragonMap
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_DragonLairUnregisterTab:onEnterTab(first)
    self:initTableView()
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_DragonLairUnregisterTab:onExitTab()
end


-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_DragonLairUnregisterTab:apply_dragonSort()
    if self.m_dragonTableView == nil then
        return
    end

    local list = self.m_dragonTableView.m_itemList
    self.m_sortManagerDragon:sortExecution(list)
    self.m_dragonTableView:setDirtyItemList()
end

-------------------------------------
-- function unregisterFromLair
-- @brief 드래곤 둥지 제거
-------------------------------------
function UI_DragonLairUnregisterTab:unregisterFromLair(data, ui_cell)
    local info = g_lairData:getRegisterLairInfo(data['did'])
    local is_exist_doid = g_lairData:isRegisterLairDragonExist(data['did'])

    if info == nil or is_exist_doid == false then
        UI_BookDetailPopup.openWithFrame(data['did'], 6, 3, 1, true)
        return
    end

    local doid = info['doid']
    local ok_btn_cb = function ()
        local sucess_cb = function (ret)
            ui_cell.root:setColor(COLOR['deep_gray'])
        end

        g_lairData:request_lairRemove(doid, sucess_cb)
    end

    local msg = Str('드래곤을 동굴에서 해제하시겠습니까?')
    local submsg = Str('해제 시 새 시즌전까지 동굴에 다시 등록 불가합니다.')
    local ui = MakeSimplePricePopup(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
    ui:setPrice('cash', 3000)
end