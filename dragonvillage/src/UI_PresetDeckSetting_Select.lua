-- @inherit UI_ReadySceneNew_Select
local PARENT = UI_ReadySceneNew_Select
-------------------------------------
-- class UI_PresetDeckSetting_Select
-------------------------------------
UI_PresetDeckSetting_Select = class(PARENT, {
    })

local DC_SCALE = 0.61
-------------------------------------
-- function initUI
-------------------------------------
function UI_PresetDeckSetting_Select:initUI()
    self:onEnterDragonTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PresetDeckSetting_Select:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PresetDeckSetting_Select:refresh()
end

-------------------------------------
-- function init_dragonTableView
-------------------------------------
function UI_PresetDeckSetting_Select:init_dragonTableView()
    local vars = self.m_uiReadyScene.vars
    local list_table_node = (not self.m_bFriend) and vars['listView'] or vars['listView2']
    list_table_node:removeAllChildren()

    local function create_func(ui, data)
        ui.root:setScale(DC_SCALE)	-- UI 테이블뷰 사이즈가 변경될 시 조정
        local unique_id = data['id']
        self.m_uiReadyScene:refresh_dragonCard(unique_id, self.m_bFriend)

        -- 드래곤 클릭 콜백 함수
        local function click_dragon_item()
            local t_dragon_data = data
            self:click_dragonCard(t_dragon_data)
        end

        -- 드래곤 정보 팝업 콜백 함수
        local function popup_close_cb()
            self.m_uiReadyScene:refresh()
            self:init_dragonTableView()
            self.m_uiReadyScene.m_readySceneDeck:init_deck()
            self.m_uiReadyScene:apply_dragonSort()
        end

        local function open_simple_popup()
            local doid = data['id']
            if doid and (doid ~= '') then
                local popup = UI_SimpleDragonInfoPopup(data)
                local manage_avail = not self.m_bFriend
                popup:setManagePossible(manage_avail)
                popup:setRefreshFunc(function() popup_close_cb() end)
            end
        end

          -- 드래곤 프레스 콜백 함수
        local function press_card_cb()
            self.m_uiReadyScene:checkChangeDeck(open_simple_popup)
        end 

        ui.vars['clickBtn']:registerScriptTapHandler(function() click_dragon_item() end)
        ui.vars['clickBtn']:registerScriptPressHandler(function() press_card_cb() end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize =  cc.size(92, 94)
    table_view_td.m_nItemPerCell = 5 -- UI 테이블뷰 사이즈가 변경될 시 조정
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    local empty_text = Str('드래곤이 없습니다.')
    table_view_td:makeDefaultEmptyDescLabel(empty_text)

    -- 리스트 설정
    local l_dragon_list = g_dragonsData:getDragonsList() 
    table_view_td:setItemList(l_dragon_list)
    self.m_tableViewExtMine = table_view_td
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_PresetDeckSetting_Select:click_dragonCard(t_dragon_data, skip_sort, idx)
    self.m_uiReadyScene.m_readySceneDeck:click_dragonCard(t_dragon_data, skip_sort, idx)
end
