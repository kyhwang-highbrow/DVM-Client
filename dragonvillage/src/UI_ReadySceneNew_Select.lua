-------------------------------------
-- class UI_ReadySceneNew_Select
-------------------------------------
UI_ReadySceneNew_Select = class({
        m_uiReadyScene = 'UI_ReadyScene',
        m_bFriend = 'boolean',

        m_tableViewExtMine = 'UIC_TableViewTD',
        m_tableViewExtFriend = 'UIC_TableViewTD',
    })

local DC_SCALE = 0.61

-------------------------------------
-- function init
-------------------------------------
function UI_ReadySceneNew_Select:init(ui_ready_scene)
    self.m_uiReadyScene = ui_ready_scene
    self.m_bFriend = false

	self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ReadySceneNew_Select:initUI()
    local vars = self.m_uiReadyScene.vars
    vars['friendToggleSprite']:setVisible(self.m_bFriend)
    self:onEnterDragonTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ReadySceneNew_Select:initButton()
    local vars = self.m_uiReadyScene.vars
    vars['friendToggleBtn']:registerScriptTapHandler(function() self:click_friendToggleBtn() end)
end

-------------------------------------
-- function onEnterDragonTableView
-------------------------------------
function UI_ReadySceneNew_Select:onEnterDragonTableView()
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
function UI_ReadySceneNew_Select:init_dragonTableView()
    local vars = self.m_uiReadyScene.vars
    local list_table_node = (not self.m_bFriend) and vars['listView'] or vars['listView2']
    list_table_node:removeAllChildren()

    local is_mine = not self.m_bFriend
    local game_mode = g_stageData:getGameMode(self.m_uiReadyScene.m_stageID)

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

        -- 상성
        local dragon_attr = TableDragon():getValue(data['did'], 'attr')
        local stage_attr = self.m_uiReadyScene.m_stageAttr

        if (game_mode == GAME_MODE_CLAN_RAID) then
            local raid_info = g_clanRaidData:getClanRaidStruct()
            local _, bonus_info = raid_info:getBonusSynastryInfo()
            local _, penalty_info = raid_info:getPenaltySynastryInfo()
            ui:setAttrSynastry(getCounterAttribute_ClanRaid(dragon_attr, bonus_info, penalty_info))
        elseif (game_mode == GAME_MODE_EVENT_DEALKING) then
            local _, bonus_info = TableDealkingBuff:getInstance():getDealkingBonusInfo(self.m_uiReadyScene.m_stageID, stage_attr, true)
            local _, penalty_info = TableDealkingBuff:getInstance():getDealkingBonusInfo(self.m_uiReadyScene.m_stageID, stage_attr, false)
            ui:setAttrSynastry(getCounterAttribute_ClanRaid(dragon_attr, bonus_info, penalty_info))
        elseif (game_mode == GAME_MODE_EVENT_ILLUSION_DUNSEON) then
			ui:setAttrSynastry(getCounterAttribute(dragon_attr, stage_attr))
			if (g_illusionDungeonData:isIllusionDragon(data)) then
				ui:setEventIllusionVisible(true) -- param : visible, is_bonus
                ui:setEventIllusionFrameVisible(true)
		    elseif (g_illusionDungeonData:isIllusionDragonID(data)) then
                ui:setEventIllusionVisible(true, true) -- param : visible, is_bonus
                ui:setEventIllusionFrameVisible(true)
            end

        elseif (game_mode == GAME_MODE_WORLD_RAID) then
            local _, bonus_info = g_worldRaidData:getWorldRaidBuff()
            local _, penalty_info = g_worldRaidData:getWorldRaidDebuff()
            ui:setAttrSynastry(getCounterAttribute_ClanRaid(dragon_attr, bonus_info, penalty_info))

		else
            ui:setAttrSynastry(getCounterAttribute(dragon_attr, stage_attr))
        end
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = is_mine and cc.size(92, 94) or cc.size(92, 115) -- UI 테이블뷰 사이즈가 변경될 시 조정
    table_view_td.m_nItemPerCell = 5 -- UI 테이블뷰 사이즈가 변경될 시 조정
    table_view_td:setCellUIClass(is_mine and UI_DragonCard or UI_FriendDragonCard, create_func)
    local empty_text = is_mine and Str('드래곤이 없습니다.') or Str('친구가 없습니다.\n친구를 추가해보세요!')
    table_view_td:makeDefaultEmptyDescLabel(empty_text)

    -- 리스트 설정
    local l_dragon_list
    if (game_mode == GAME_MODE_ANCIENT_TOWER) then
        local attr = g_attrTowerData:getSelAttr()
        -- 시험의 탑 (같은 속성 드래곤만 받아옴)
        if (attr) then
            l_dragon_list = g_dragonsData:getDragonsListWithAttr(attr)

        -- 고대의 탑
        else
            l_dragon_list = g_dragonsData:getDragonsList()
        end
    else
        l_dragon_list = is_mine and g_dragonsData:getDragonsList() or g_friendData:getDragonsList()
    end

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
function UI_ReadySceneNew_Select:click_friendToggleBtn()
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
function UI_ReadySceneNew_Select:click_dragonCard(t_dragon_data, skip_sort, idx)
    self.m_uiReadyScene.m_readySceneDeck:click_dragonCard(t_dragon_data, skip_sort, idx)
end

-------------------------------------
-- function setFriend
-------------------------------------
function UI_ReadySceneNew_Select:setFriend(visible)
    local vars = self.m_uiReadyScene.vars
    vars['friendToggleBtn']:setVisible(visible)
end

-------------------------------------
-- function getTableView
-------------------------------------
function UI_ReadySceneNew_Select:getTableView(is_friend)
    -- tableview 가 cell 을 생성중이라면 타입에 따라 테이블뷰를 지정해줘야 하기 때문에 아래와 같이 처리
    local table_view
    if (is_friend == nil) then
        table_view = (not self.m_bFriend) and self.m_tableViewExtMine or self.m_tableViewExtFriend
    elseif (is_friend == true) then
        table_view = self.m_tableViewExtFriend
    elseif (is_friend == false) then
        table_view = self.m_tableViewExtMine
    end

    return table_view
end


