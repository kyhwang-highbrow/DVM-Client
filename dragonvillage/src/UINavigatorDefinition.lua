UINavigatorDefinition = {}

-------------------------------------
-- function goTo
-- @brief UI 이동
-- @param location_name string
-------------------------------------
function UINavigatorDefinition:goTo(location_name, ...)
    -- 콘텐츠 잠금 상태를 확인하기 위함
    if (not self:checkContentLock(location_name)) then
        return
    end

    -- 모드별 실행 함수 호출
    local function_name = 'goTo_' .. location_name
    if self[function_name] then
        self[function_name](self, ...)
    end
end

-------------------------------------
-- function checkContentLock
-- @brief
-- @return bool false일경우 잠겨있는 상태
-------------------------------------
function UINavigatorDefinition:checkContentLock(location_name)
    local table_ui_location = TableUILocation()

    -- 콘텐츠 잠금 상태를 확인하기 위함 (string or nil이 리턴됨)
    local content_name = table_ui_location:getContentName(location_name)

    -- 콘텐츠 이름이 있을 경우 잠금 상태 확인
    if content_name then
        -- 콘텐츠가 잠금 상태일 경우 checkContentLock함수 안에서 안내 팝업이 나오게 되어 있음
        local is_open = g_contentLockData:checkContentLock(content_name)
        if (is_open == false) then
            return false
        end
    end

    return true
end















-------------------------------------
-- function goTo_lobby
-- @brief 로비로 이동
-- @usage UINavigatorDefinition:goTo('lobby')
-------------------------------------
function UINavigatorDefinition:goTo_lobby(...)
    -- 로비가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local scene = SceneLobby()
    scene:runScene()
end

-------------------------------------
-- function goTo_adventure
-- @brief 모험 모드로 이동
-- @usage UINavigatorDefinition:goTo('adventure', stage_id)
-------------------------------------
function UINavigatorDefinition:goTo_adventure(...)
    local args = {...}
    local stage_id = args[1]

    -- 모험 모드가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_AdventureSceneNew')
    if (is_opend == true) then
        self:closeUIList(idx)
        if stage_id then
            ui:focusByStageID(stage_id)
        end
        return
    end

    local function finish_cb()
        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
        if (is_opend == true) then
            self:closeUIList(idx)
            ui:setTab('adventure')
            ui:resetButtonsPosition()
            UI_AdventureSceneNew(stage_id)
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local battle_menu_ui = UI_BattleMenu()
            battle_menu_ui:setTab('adventure')
            battle_menu_ui:resetButtonsPosition()
            UI_AdventureSceneNew(stage_id)
            return
        end

        
        do-- Scene으로 모험 모드 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_AdventureSceneNew, close_cb, stage_id)
            scene:runScene()
        end
    end

    local function fail_cb()

    end

    -- 모험 정보 요청
    g_adventureData:request_adventureInfo(finish_cb, fail_cb)
end

-------------------------------------
-- function goTo_exploration
-- @brief 탐험 모드로 이동
-- @usage UINavigatorDefinition:goTo('exploration')
-------------------------------------
function UINavigatorDefinition:goTo_exploration(...)
    -- 탐험 모드가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Exploration')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local function finish_cb()
        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
        if (is_opend == true) then
            self:closeUIList(idx)
            ui:setTab('adventure') -- 전투 메뉴에서 tab의 이름이 'adventure'이다.
            ui:resetButtonsPosition()
            UI_Exploration()
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local battle_menu_ui = UI_BattleMenu()
            battle_menu_ui:setTab('adventure') -- 전투 메뉴에서 tab의 이름이 'adventure'이다.
            battle_menu_ui:resetButtonsPosition()
            UI_Exploration()
            return
        end

        do-- Scene으로 탐험 모드 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_Exploration, close_cb)
            scene:runScene()
        end
    end

    local function fail_cb()

    end

    -- 탐험 정보 요청
    g_explorationData:request_explorationInfo(finish_cb, fail_cb)
end

-------------------------------------
-- function goTo_colosseum
-- @brief 콜로세움으로 이동
-- @usage UINavigatorDefinition:goTo('colosseum')
-------------------------------------
function UINavigatorDefinition:goTo_colosseum(...)
    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Colosseum')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local function finish_cb()

        -- 오픈 상태 여부 체크
        if (not g_colosseumData:isOpenColosseum()) then
            local msg = Str('콜로세움 오픈 전입니다.\n오픈까지 {1}', g_colosseumData:getColosseumStatusText())
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return
		end

        -- 긴급하게 닫아야 할 경우 
        if (not g_colosseumData:isOpen()) then
            local msg = Str('오픈시간이 아닙니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return
		end

        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
        if (is_opend == true) then
            self:closeUIList(idx)
            ui:setTab('competition') -- 전투 메뉴에서 tab의 이름이 'adventure'이다.
            ui:resetButtonsPosition()
            UI_Colosseum()
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local battle_menu_ui = UI_BattleMenu()
            battle_menu_ui:setTab('competition') -- 전투 메뉴에서 tab의 이름이 'competition'이다.
            battle_menu_ui:resetButtonsPosition()
            UI_Colosseum()
            return
        end

        do-- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_Colosseum, close_cb)
            scene:runScene()
        end
    end

    local function fail_cb()

    end

    -- 정보 요청
    g_colosseumData:request_colosseumInfo(finish_cb, fail_cb)
end

-------------------------------------
-- function goTo_ancient
-- @brief 고대의탑으로 이동
-- @usage UINavigatorDefinition:goTo('ancient', stage_id)
-------------------------------------
function UINavigatorDefinition:goTo_ancient(...)
    local args = {...}
    local stage_id = args[1]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_AncientTower')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local function finish_cb()

        -- 오픈 상태 여부 체크
        if (not g_ancientTowerData:isOpenAncientTower()) then
            local msg = Str('고대의 탑 오픈 전입니다.\n오픈까지 {1}', g_ancientTowerData:getAncientTowerStatusText())
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return
		end
        
        -- 긴급하게 닫아야 할 경우 
        if (not g_ancientTowerData:isOpen()) then
            local msg = Str('오픈시간이 아닙니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return
		end

        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
        if (is_opend == true) then
            self:closeUIList(idx)
            ui:setTab('competition') -- 전투 메뉴에서 tab의 이름이 'adventure'이다.
            ui:resetButtonsPosition()
            UI_AncientTower()
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local battle_menu_ui = UI_BattleMenu()
            battle_menu_ui:setTab('competition') -- 전투 메뉴에서 tab의 이름이 'competition'이다.
            battle_menu_ui:resetButtonsPosition()
            UI_AncientTower()
            return
        end

        do-- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_AncientTower, close_cb)
            scene:runScene()
        end
    end

    local function fail_cb()

    end

    -- 정보 요청
    g_ancientTowerData:request_ancientTowerInfo(stage_id, finish_cb, fail_cb)
end

-------------------------------------
-- function goTo_attr_tower
-- @brief 시험의탑으로 이동
-- @usage UINavigatorDefinition:goTo('attr_tower', attr, stage_id)
-------------------------------------
function UINavigatorDefinition:goTo_attr_tower(...)
    local args = {...}
    local attr = args[1]
    local stage_id = args[2]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_AttrTower')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local function finish_cb()

        -- 메인 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_AttrTowerMenuScene')
        if (is_opend == true) then
            if (attr ~= nil) then
                UI_AttrTower()
            end
            return
        end

        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
        if (is_opend == true) then
            self:closeUIList(idx)
            UI_AttrTowerMenuScene(attr, stage_id)

            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local battle_menu_ui = UI_BattleMenu()
            battle_menu_ui:setTab('competition') 
            battle_menu_ui:resetButtonsPosition()
            UI_AttrTowerMenuScene(attr, stage_id)

            return
        end

        do-- Scene으로 동작
            local function close_cb()
                -- 메뉴 선택 로비로
                UINavigator:goTo('lobby')
            end

            local scene = SceneCommon(UI_AttrTowerMenuScene, close_cb, attr, stage_id)
            scene:runScene()
        end
    end

    local function fail_cb()

    end

    -- 전투 메뉴가 열려있지 않다면 무조건 시험의 탑 전체 메뉴 scene으로 먼저 보냄
    local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
    local _attr = is_opend and attr or nil
    local _stage_id = is_opend and stage_id or nil

    -- 정보 요청
    g_attrTowerData:request_attrTowerInfo(attr, stage_id, finish_cb, fail_cb)
end

-------------------------------------
-- function goTo_nestdungeon
-- @brief 네스트던전으로 이동
-- @usage UINavigatorDefinition:goTo('nestdungeon', stage_id, dungeon_type)
-------------------------------------
function UINavigatorDefinition:goTo_nestdungeon(...)
    local args = {...}
    local stage_id = args[1]
    local dungeon_type = args[2]

    -- 던전 타입이 지정되지 않았을 경우 체크
    if (not dungeon_type) and stage_id then
        local t_dungeon_id_info = g_nestDungeonData:parseNestDungeonID(stage_id)
        dungeon_type = t_dungeon_id_info['dungeon_mode']
    end

    do -- 네스트던전 세부 모드 잠금 확인
        if dungeon_type then
            local location_name
            if (dungeon_type == NEST_DUNGEON_EVO_STONE) then
                location_name = 'nest_evo_stone'

            elseif (dungeon_type == NEST_DUNGEON_NIGHTMARE) then
                location_name = 'nest_nightmare'

            elseif (dungeon_type == NEST_DUNGEON_TREE) then
                location_name = 'nest_tree'

            else
                error('location_name : ' .. location_name)
            end

            -- 콘텐츠 잠금 상태를 확인하기 위함
            if (not self:checkContentLock(location_name)) then
                return
            end
        end

        -- 요일 던전의 경우 열려있는지 확인
        if stage_id and (not g_nestDungeonData:checkNestDungeonOpen(stage_id)) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('입장 가능한 시간이 아닙니다.'))
            return
        end
    end

    self:goTo_nestdungeon_core(stage_id, dungeon_type)
end

-------------------------------------
-- function goTo_nest_evo_stone
-- @brief 거대용 던전으로 이동
-- @usage UINavigatorDefinition:goTo('nest_evo_stone', stage_id)
-------------------------------------
function UINavigatorDefinition:goTo_nest_evo_stone(...)
    local args = {...}
    local stage_id = args[1]
    self:goTo_nestdungeon_core(stage_id, NEST_DUNGEON_EVO_STONE)
end

-------------------------------------
-- function goTo_nest_tree
-- @brief 거목 던전으로 이동
-- @usage UINavigatorDefinition:goTo('nest_tree', stage_id)
-------------------------------------
function UINavigatorDefinition:goTo_nest_tree(...)
    local args = {...}
    local stage_id = args[1]
    self:goTo_nestdungeon_core(stage_id, NEST_DUNGEON_TREE)
end

-------------------------------------
-- function goTo_nest_nightmare
-- @brief 악몽 던전으로 이동
-- @usage UINavigatorDefinition:goTo('nest_nightmare', stage_id)
-------------------------------------
function UINavigatorDefinition:goTo_nest_nightmare(...)
    local args = {...}
    local stage_id = args[1]
    self:goTo_nestdungeon_core(stage_id, NEST_DUNGEON_NIGHTMARE)
end

-------------------------------------
-- function goTo_nestdungeon_core
-- @brief 네스트던전으로 이동
-- @usage UINavigatorDefinition:goTo('nestdungeon', stage_id, dungeon_type)
-------------------------------------
function UINavigatorDefinition:goTo_nestdungeon_core(...)
    local args = {...}
    local stage_id = args[1]
    local dungeon_type = args[2]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_NestDungeonScene')
    if (is_opend == true) then
        self:closeUIList(idx, true) -- param : idx, include_idx
        UI_NestDungeonScene(stage_id, dungeon_type)
        return
    end

    local request_nest_dungeon_info
    local request_nest_dungeon_stage_list
    local open_ui

    -- 네스트 던전 리스트 정보 얻어옴
    request_nest_dungeon_info = function()
        g_nestDungeonData:requestNestDungeonInfo(request_nest_dungeon_stage_list)
    end

    -- 네스트 던전 스테이지 리스트 얻어옴
    request_nest_dungeon_stage_list = function()
        g_nestDungeonData:requestNestDungeonStageList(open_ui)
    end

    -- 네스트 던전 UI 오픈
    open_ui = function()
        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
        if (is_opend == true) then
            self:closeUIList(idx)
            ui:setTab('dungeon') -- 전투 메뉴에서 tab의 이름이 'dungeon'이다.
            ui:resetButtonsPosition()
            UI_NestDungeonScene(stage_id, dungeon_type)
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local battle_menu_ui = UI_BattleMenu()
            battle_menu_ui:setTab('dungeon') -- 전투 메뉴에서 tab의 이름이 'dungeon'이다.
            battle_menu_ui:resetButtonsPosition()
            UI_NestDungeonScene(stage_id, dungeon_type)
            return
        end

        do-- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_NestDungeonScene, close_cb, stage_id, dungeon_type)
            scene:runScene()
        end
    end

    -- 정보 요청
    request_nest_dungeon_info()
end

-------------------------------------
-- function goTo_secret_relation
-- @brief 시크릿 던전 인연 던전
-- @usage UINavigatorDefinition:goTo('secret_relation', stage_id)
-------------------------------------
function UINavigatorDefinition:goTo_secret_relation(...)
    local args = {...}
    local stage_id = args[1]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_SecretDungeonScene')
    if (is_opend == true) then
        self:closeUIList(idx, true) -- param : idx, include_idx
        UI_SecretDungeonScene(stage_id)
        return
    end

    local request_secret_dungeon_info
    local request_secret_dungeon_stage_list
    local open_ui

    -- 씬 바뀔때는 정보 갱신 해주기 
    g_secretDungeonData.m_bDirtySecretDungeonInfo = true

    -- 비밀 던전 리스트 정보 얻어옴
    request_secret_dungeon_info = function()
        g_secretDungeonData:requestSecretDungeonInfo(request_secret_dungeon_stage_list)
    end

    -- 비밀 던전 스테이지 리스트 얻어옴
    request_secret_dungeon_stage_list = function()
        g_secretDungeonData:requestSecretDungeonStageList(open_ui)
    end

    -- 비밀 던전 씬으로 전환
    open_ui = function()
        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
        if (is_opend == true) then
            self:closeUIList(idx)
            ui:setTab('dungeon') -- 전투 메뉴에서 tab의 이름이 'dungeon'이다.
            ui:resetButtonsPosition()
            UI_SecretDungeonScene(stage_id)
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local battle_menu_ui = UI_BattleMenu()
            battle_menu_ui:setTab('dungeon') -- 전투 메뉴에서 tab의 이름이 'dungeon'이다.
            battle_menu_ui:resetButtonsPosition()
            UI_SecretDungeonScene(stage_id)
            return
        end

        do-- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_SecretDungeonScene, close_cb, stage_id)
            scene:runScene()
        end
    end

    request_secret_dungeon_info()
end

-------------------------------------
-- function goTo_battle_menu
-- @brief 전투 메뉴로 이동
-- @usage UINavigatorDefinition:goTo('battle_menu')
-------------------------------------
function UINavigatorDefinition:goTo_battle_menu(...)
    local args = {...}
    local tab_name = args[1]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
    if (is_opend == true) then
        self:closeUIList(idx)
        if tab_name then
            ui:setTab(tab_name)
            ui:resetButtonsPosition()
        end
        return
    end

    -- 로비가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
    if (is_opend == true) then
        self:closeUIList(idx)
        local battle_menu_ui = UI_BattleMenu()
        if tab_name then
            battle_menu_ui:setTab(tab_name)
            battle_menu_ui:resetButtonsPosition()
        end
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end

        local scene = SceneCommon(UI_BattleMenu, close_cb)
        scene:runScene()
    end
end

-------------------------------------
-- function goTo_dragon
-- @brief 드래곤 관리로 이동
-- @usage UINavigatorDefinition:goTo('dragon')
-------------------------------------
function UINavigatorDefinition:goTo_dragon(...)
    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_DragonManageInfo')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    -- 로비가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
    if (is_opend == true) then
        self:closeUIList(idx)
        UI_DragonManageInfo()
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end

        local scene = SceneCommon(UI_DragonManageInfo, close_cb)
        scene:runScene()
    end
end

-------------------------------------
-- function goTo_hatchery
-- @brief 부화소로 이동
-- @usage UINavigatorDefinition:goTo('hatchery', tab)
-------------------------------------
function UINavigatorDefinition:goTo_hatchery(...)
    local args = {...}
    local tab = args[1]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Hatchery')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    local function finish_cb()
        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            UI_Hatchery(tab)
            return
        end

        do-- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_Hatchery, close_cb, tab)
            scene:runScene()
        end
    end

    g_hatcheryData:update_hatcheryInfo(finish_cb)
end

-------------------------------------
-- function goTo_friend
-- @brief 친구UI로 이동
-- @usage UINavigatorDefinition:goTo('friend')
-------------------------------------
function UINavigatorDefinition:goTo_friend(...)
	local args = {...}

	-- 로비 진입후 친구 팝업 뜨기 전까지의 받은 요청이 있을 수 있음, 진입시 하일라이트 정보 갱신!
	g_highlightData:request_highlightInfo(function() 

		-- 해당 UI가 열려있을 경우
		local is_opend, idx, ui = self:findOpendUI('UI_FriendPopup')
		if (is_opend == true) then
			self:closeUIList(idx, false) -- param : idx, include_idx
			return
		end

		-- 로비가 열려있을 경우
		local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
		if (is_opend == true) then
			self:closeUIList(idx)
			UI_FriendPopup()
			return
		end

		do-- Scene으로 동작
			local function close_cb()
				UINavigatorDefinition:goTo('lobby')
			end

			local scene = SceneCommon(UI_FriendPopup, close_cb)
			scene:runScene()
		end
	end)
end

-------------------------------------
-- function goTo_dragon_manage
-- @brief 드래곤 관리로 이동
-- @usage UINavigatorDefinition:goTo('dragon_manage')
-------------------------------------
function UINavigatorDefinition:goTo_dragon_manage(...)
    local args = {...}
    local sub_menu = args[1]
    local tar_dragon = args[2]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_DragonManageInfo')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        ui:clickSubMenu(sub_menu)
        return
    end

    -- 로비가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
    if (is_opend == true) then
        self:closeUIList(idx)
        local ui = UI_DragonManageInfo(tar_dragon)
        ui:clickSubMenu(sub_menu)
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end

        local scene = SceneCommon(UI_DragonManageInfo, close_cb, nil, sub_menu)
        scene:runScene()
    end
end

-------------------------------------
-- function goTo_costume_shop
-- @brief 테이머 코스튬 상점으로 이동
-- @usage UINavigatorDefinition:goTo('costume_shop')
-------------------------------------
function UINavigatorDefinition:goTo_costume_shop(...)
    local args = {...}
    local sel_tamer_id = args[1] or 110001
    local refresh_cb = args[2] or function() end

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_TamerCostumeShop')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    local function finish_cb()
        -- 테이머 관리창이 열려있을 경우
        -- UI_TamerManagePopup 호출시 UI_SkillDetailPopup_Tamer도 ui에 등록해줘야 백키 누를때 오류 나지 않음.
        local is_opend, idx, ui = self:findOpendUI('UI_SkillDetailPopup_Tamer')
        if (is_opend == true) then
            self:closeUIList(idx)
            local ui = UI_TamerCostumeShop(sel_tamer_id)
            ui:setCloseCB(refresh_cb)
            return
        end

        -- 이벤트 팝업이 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_EventPopup')
        if (is_opend == true) then
            self:closeUIList(idx)
            local ui = UI_TamerCostumeShop(sel_tamer_id)
            ui:setCloseCB(refresh_cb)
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local ui = UI_TamerCostumeShop(sel_tamer_id)
            ui:setCloseCB(refresh_cb)
            return
        end

        do -- Scene으로 동작
            local function close_cb()
                refresh_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_TamerCostumeShop, close_cb, sel_tamer_id)
            scene:runScene()
        end
    end

    -- 정보 요청
    g_tamerCostumeData:request_costumeInfo(finish_cb)
end

-------------------------------------
-- function goTo_forest
-- @brief 드래곤의 숲으로 이동
-- @usage UINavigatorDefinition:goTo('forest')
-------------------------------------
function UINavigatorDefinition:goTo_forest(...)
    -- 드래곤의 숲 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Forest')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local function cb_func()
        UI_BlockPopup()
        SceneForest():runScene()
    end
    ServerData_Forest:getInstance():request_myForestInfo(cb_func)
end

-------------------------------------
-- function goTo_clan
-- @brief 클랜으로 이동
-- @usage UINavigatorDefinition:goTo('clan')
-------------------------------------
function UINavigatorDefinition:goTo_clan(...)

    -- 클랜 게스트 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI(UI_ClanGuest)
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end
    
    -- 클랜 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI(UI_Clan)
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end
        
    local function finish_cb()
        -- 클랜 가입 여부에 따른 UI 선택
        local target_ui_class = nil
        if g_clanData:isClanGuest() then
            target_ui_class = UI_ClanGuest
        else
            target_ui_class = UI_Clan
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local ui = target_ui_class(sel_tamer_id)
            return
        end

        do-- Scene으로 클랜 UI 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(target_ui_class, close_cb)
            scene:runScene()
        end
    end

    local function fail_cb()

    end

    -- 클랜 정보 요청
    g_clanData:update_clanInfo(finish_cb, fail_cb)
end

-------------------------------------
-- function goTo_clan_raid
-- @brief 클랜 던전으로 이동
-- @usage UINavigatorDefinition:goTo('clan_raid')
-------------------------------------
function UINavigatorDefinition:goTo_clan_raid(...)
    -- 클랜 던전 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI(UI_ClanRaid)
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end
        
    local function finish_cb()
        -- 오픈 상태 여부 체크
        if (not g_clanRaidData:isOpenClanRaid()) then
            local msg = Str('클랜던전 오픈 전입니다.\n오픈까지 {1}', g_clanRaidData:getClanRaidStatusText())
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return
		end

        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
        if (is_opend == true) then
            self:closeUIList(idx)
            ui:setTab('dungeon') -- 전투 메뉴에서 tab의 이름이 'dungeon'이다.
            ui:resetButtonsPosition()
            UI_ClanRaid()
            return
        end

        -- 클랜 UI가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Clan')
        if (is_opend == true) then
            self:closeUIList(idx)
            UI_ClanRaid()
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            UI_ClanRaid()
            return
        end

        do-- Scene으로 클랜 던전 UI 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_ClanRaid, close_cb)
            scene:runScene()
        end
    end

    local function fail_cb()

    end

    -- 클랜 정보 요청
    local stage_id = nil
    g_clanRaidData:request_info(stage_id, finish_cb, fail_cb)
end




















-------------------------------------
-- function findOpendUI
-- @brief 오픈된 UI에서 특정 UI를 찾음
-------------------------------------
function UINavigatorDefinition:findOpendUI(ui_class_name)
    local idx = nil
    local opend_ui = nil

    for i=#UIManager.m_uiList, 1, -1 do
        local ui = UIManager.m_uiList[i]
        if (ui.m_uiName == ui_class_name) then
            idx = i
            opend_ui = ui
            break
        end
    end

    if (idx) then
        return true, idx, opend_ui
    else
        return false, idx, opend_ui
    end
end

-------------------------------------
-- function closeUIList
-- @brief 오픈된 UI에서 idx이후의 UI들을 닫음
-------------------------------------
function UINavigatorDefinition:closeUIList(idx, include_idx)
    local dest_idx = idx+1

    if (include_idx == true) then
        dest_idx = idx
    end

    for i=#UIManager.m_uiList, dest_idx, -1 do
        local ui = UIManager.m_uiList[i]
        ui:close()
    end
end