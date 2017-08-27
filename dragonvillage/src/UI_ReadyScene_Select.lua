-------------------------------------
-- class UI_ReadyScene_Select
-------------------------------------
UI_ReadyScene_Select = class({
        m_uiReadyScene = 'UI_ReadyScene',
        m_bFriend = 'boolean',

        m_tableViewExtMine = 'UIC_TableViewTD',
        m_tableViewExtFriend = 'UIC_TableViewTD',
    })

local DC_SCALE = 0.61

-------------------------------------
-- function init
-------------------------------------
function UI_ReadyScene_Select:init(ui_ready_scene)
    self.m_uiReadyScene = ui_ready_scene
    self.m_bFriend = false

	self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ReadyScene_Select:initUI()
    local vars = self.m_uiReadyScene.vars
    vars['friendToggleSprite']:setVisible(self.m_bFriend)
    self:onEnterDragonTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ReadyScene_Select:initButton()
    local vars = self.m_uiReadyScene.vars
    vars['friendToggleBtn']:registerScriptTapHandler(function() self:click_friendToggleBtn() end)
end

-------------------------------------
-- function onEnterDragonTab
-------------------------------------
function UI_ReadyScene_Select:onEnterDragonTableView()
    if (not self.m_bFriend) and (not self.m_tableViewExtMine) then
        self:init_dragonTableView()

    elseif (self.m_bFriend) and (not self.m_tableViewExtFriend) then
        local function finish_cb(ret)
            -- 최초 생성시 친구 리스트 받아온뒤 테이블 뷰 생성, 정렬 
            self:init_dragonTableView()
            self.m_uiReadyScene:apply_dragonSort()
        end
        local force = true
        g_friendData:request_friendList(finish_cb, force)
    end
end

-------------------------------------
-- function init_dragonTableView
-------------------------------------
function UI_ReadyScene_Select:init_dragonTableView()
    local vars = self.m_uiReadyScene.vars
    local list_table_node = (not self.m_bFriend) and vars['listView'] or vars['listView2']
    list_table_node:removeAllChildren()

    local is_mine = not self.m_bFriend

    local function create_func(ui, data)
        ui.root:setScale(DC_SCALE)	-- UI 테이블뷰 사이즈가 변경될 시 조정
        local unique_id = data['id']
        self.m_uiReadyScene:refresh_dragonCard(unique_id)

        -- 드래곤 클릭 콜백 함수
        local function click_dragon_item()
            local t_dragon_data = data
            self:click_dragonCard(t_dragon_data)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(function() click_dragon_item() end)

        -- 상성
        local dragon_attr = TableDragon():getValue(data['did'], 'attr')
        local stage_attr = self.m_uiReadyScene.m_stageAttr
        ui:setAttrSynastry(getCounterAttribute(dragon_attr, stage_attr))
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = is_mine and cc.size(97, 94) or cc.size(97, 115) -- UI 테이블뷰 사이즈가 변경될 시 조정
    table_view_td.m_nItemPerCell = 4 -- UI 테이블뷰 사이즈가 변경될 시 조정
    table_view_td:setCellUIClass(is_mine and UI_DragonCard or UI_FriendDragonCard, create_func)
    local empty_text = is_mine and Str('드래곤이 없습니다.') or Str('친구가 없습니다.\n친구를 추가해보세요!')
    table_view_td:makeDefaultEmptyDescLabel(empty_text)

    -- 리스트 설정
    local l_dragon_list = is_mine and g_dragonsData:getDragonsList() or g_friendData:getDragonsList()
    table_view_td:setItemList(l_dragon_list)

    if is_mine then
        self.m_tableViewExtMine = table_view_td
    else
        self.m_tableViewExtFriend = table_view_td
    end
end

-------------------------------------
-- function click_friendToggleBtn
-------------------------------------
function UI_ReadyScene_Select:click_friendToggleBtn()
    self.m_bFriend = not self.m_bFriend

    local vars = self.m_uiReadyScene.vars
    vars['listView']:setVisible(not self.m_bFriend)
    vars['listView2']:setVisible(self.m_bFriend)
    vars['friendToggleSprite']:setVisible(self.m_bFriend)
    
    self:onEnterDragonTableView()
end 

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_ReadyScene_Select:click_dragonCard(t_dragon_data, skip_sort, idx)
    self.m_uiReadyScene.m_readySceneDeck:click_dragonCard(t_dragon_data, skip_sort, idx)
end

-------------------------------------
-- function setFriend
-------------------------------------
function UI_ReadyScene_Select:setFriend(enable)
    local vars = self.m_uiReadyScene.vars
    vars['friendToggleBtn']:setEnabled(enable)
end

-------------------------------------
-- function getTableView
-------------------------------------
function UI_ReadyScene_Select:getTableView()
    return (not self.m_bFriend) and self.m_tableViewExtMine or self.m_tableViewExtFriend
end


