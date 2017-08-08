UINavigator = {}

-------------------------------------
-- function goTo
-- @brief UI 이동
-- @param location_name string
-------------------------------------
function UINavigator:goTo(location_name, ...)
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
function UINavigator:checkContentLock(location_name)
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
-- @usage UINavigator:goTo('lobby')
-------------------------------------
function UINavigator:goTo_lobby(...)
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
-- @usage UINavigator:goTo('adventure', stage_id)
-------------------------------------
function UINavigator:goTo_adventure(...)
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
                UINavigator:goTo('lobby')
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
-- @usage UINavigator:goTo('exploration')
-------------------------------------
function UINavigator:goTo_exploration(...)
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
                UINavigator:goTo('lobby')
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
-- @usage UINavigator:goTo('colosseum')
-------------------------------------
function UINavigator:goTo_colosseum(...)
    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Colosseum')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local function finish_cb()
        -- 오픈 상태 여부 체크
        if (not g_colosseumData:isOpenColosseum()) then
            UIManager:toastNotificationGreen('콜로세움 오픈 전입니다.\n오픈까지 ' .. g_colosseumData:getColosseumStatusText())
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
                UINavigator:goTo('lobby')
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
-- @usage UINavigator:goTo('ancient', stage_id)
-------------------------------------
function UINavigator:goTo_ancient(...)
    local args = {...}
    local stage_id = args[1]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_AncientTower')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end


    -- ???????????? sgkim
    -- 고대의 탑은 점검시간이 없나요??
    -- 보상 팝업은 UI_AncientTower 안에서 처리가 불가능한가요??
    -- Tutorial은 UI_AncientTower 안에서 처리가 불가능한가요??

    local function finish_cb()
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
                UINavigator:goTo('lobby')
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
-- function goTo_nestdungeon
-- @brief 네스트던전으로 이동
-- @usage UINavigator:goTo('nestdungeon', stage_id, dungeon_type)
-------------------------------------
function UINavigator:goTo_nestdungeon(...)
    local args = {...}
    local stage_id = args[1]
    local dungeon_type = args[2]

    -- 던전 타입이 지정되지 않았을 경우 체크
    if (not dungeon_type) then
        local t_dungeon_id_info = g_nestDungeonData:parseNestDungeonID(stage_id)
        dungeon_type = t_dungeon_id_info['dungeon_mode']
    end

    do -- 네스트던전 세부 모드 잠금 확인
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

    self:goTo_nestdungeon_core(stage_id, dungeon_type)
end

-------------------------------------
-- function goTo_nest_evo_stone
-- @brief 거대용 던전으로 이동
-- @usage UINavigator:goTo('nest_evo_stone', stage_id)
-------------------------------------
function UINavigator:goTo_nest_evo_stone(...)
    local args = {...}
    local stage_id = args[1]
    self:goTo_nestdungeon_core(stage_id, NEST_DUNGEON_EVO_STONE)
end

-------------------------------------
-- function goTo_nest_tree
-- @brief 거목 던전으로 이동
-- @usage UINavigator:goTo('nest_tree', stage_id)
-------------------------------------
function UINavigator:goTo_nest_tree(...)
    local args = {...}
    local stage_id = args[1]
    self:goTo_nestdungeon_core(stage_id, NEST_DUNGEON_TREE)
end

-------------------------------------
-- function goTo_nest_nightmare
-- @brief 악몽 던전으로 이동
-- @usage UINavigator:goTo('nest_nightmare', stage_id)
-------------------------------------
function UINavigator:goTo_nest_nightmare(...)
    local args = {...}
    local stage_id = args[1]
    self:goTo_nestdungeon_core(stage_id, NEST_DUNGEON_NIGHTMARE)
end

-------------------------------------
-- function goTo_nestdungeon_core
-- @brief 네스트던전으로 이동
-- @usage UINavigator:goTo('nestdungeon', stage_id, dungeon_type)
-------------------------------------
function UINavigator:goTo_nestdungeon_core(...)
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
            ui:setTab('competition') -- 전투 메뉴에서 tab의 이름이 'adventure'이다.
            ui:resetButtonsPosition()
            UI_NestDungeonScene(stage_id, dungeon_type)
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local battle_menu_ui = UI_BattleMenu()
            battle_menu_ui:setTab('competition') -- 전투 메뉴에서 tab의 이름이 'competition'이다.
            battle_menu_ui:resetButtonsPosition()
            UI_NestDungeonScene(stage_id, dungeon_type)
            return
        end

        do-- Scene으로 동작
            local function close_cb()
                UINavigator:goTo('lobby')
            end

            local scene = SceneCommon(UI_NestDungeonScene, close_cb, stage_id, dungeon_type)
            scene:runScene()
        end
    end

    -- 정보 요청
    request_nest_dungeon_info()
end

























-------------------------------------
-- function findOpendUI
-- @brief 오픈된 UI에서 특정 UI를 찾음
-------------------------------------
function UINavigator:findOpendUI(ui_class_name)
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
function UINavigator:closeUIList(idx, include_idx)
    local dest_idx = idx+1

    if (include_idx == true) then
        dest_idx = idx
    end

    for i=#UIManager.m_uiList, dest_idx, -1 do
        local ui = UIManager.m_uiList[i]
        ui:close()
    end
end