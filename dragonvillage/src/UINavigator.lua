UINavigator = {}

-------------------------------------
-- function goTo
-- @brief UI 이동
-- @param location_name string
-------------------------------------
function UINavigator:goTo(location_name, ...)
    local table_ui_location = TableUILocation()

    -- 콘텐츠 잠금 상태를 확인하기 위함 (string or nil이 리턴됨)
    local content_name = table_ui_location:getContentName(location_name)

    -- 콘텐츠 이름이 있을 경우 잠금 상태 확인
    if content_name then
        -- 콘텐츠가 잠금 상태일 경우 checkContentLock함수 안에서 안내 팝업이 나오게 되어 있음
        local is_open = g_contentLockData:checkContentLock(content_name)
        if (is_open == false) then
            return
        end
    end

    -- 모드별 실행 함수 호출
    local function_name = 'goTo_' .. location_name
    if self[function_name] then
        self[function_name](self, ...)
    end
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
function UINavigator:closeUIList(idx)
    for i=#UIManager.m_uiList, idx+1, -1 do
        local ui = UIManager.m_uiList[i]
        ui:close()
    end
end