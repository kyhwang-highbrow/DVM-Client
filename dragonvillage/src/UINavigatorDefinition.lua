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
-- function goTo_tamer
-- @brief 테이머 관리로 이동
-- @usage UINavigatorDefinition:goTo('tamer')
-------------------------------------
function UINavigatorDefinition:goTo_tamer(...)
    local args = {...}
    local sel_tamer_id = args[1] or g_tamerData:getCurrTamerID()
    local refresh_cb = args[2]

    -- 해당 UI가 열려있을 경우
    -- UI_SkillDetailPopup_Tamer로 닫아줘야 중복해서 팝업 뜰 때 오류가 안남.
    local is_opend, idx, ui = self:findOpendUI('UI_SkillDetailPopup_Tamer')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local function finish_cb()
        local ui = UI_TamerManagePopup(sel_tamer_id)
        if (refresh_cb) then
            ui:setCloseCB(refresh_cb)
        end
    end

    -- 정보 요청 (테이머 관리에 코스튬 합쳐지면서 통신 필요함)
    -- 코스튬 정보가 있다면 굳이 갱신이 필요하지 않아 통신하지 않음
    local check_shop_info = true

    -- 코스튬을 구매한 후에 테이머 관리에 진입할때는 통신 필요
    if (g_tamerCostumeData.m_bDirtyCostumeInfo) then
        check_shop_info = false
        g_tamerCostumeData.m_bDirtyCostumeInfo = false
    end
    g_tamerCostumeData:request_costumeInfo(finish_cb, check_shop_info)
end

-------------------------------------
-- function goTo_quest
-- @brief 퀘스트 팝업으로 이동
-- @usage UINavigatorDefinition:goTo('quest')
-------------------------------------
function UINavigatorDefinition:goTo_quest(...)
    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_QuestPopup')

    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    g_questData:requestQuestInfo(function() UI_QuestPopup() end)
end

-------------------------------------
-- function goTo_book
-- @brief 도감으로 이동
-- @usage UINavigatorDefinition:goTo('book')
-------------------------------------
function UINavigatorDefinition:goTo_book(...)
    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Book')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    UI_Book()
end

-------------------------------------
-- function goTo_inventory
-- @brief 가방으로 이동
-- @usage UINavigatorDefinition:goTo('inventory')
-------------------------------------
function UINavigatorDefinition:goTo_inventory(...)
    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Inventory')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end

        local scene = SceneCommon(UI_Inventory, close_cb)
        scene:runScene()
    end
end

-------------------------------------
-- function goTo_shop
-- @brief 상점으로 이동
-- @usage UINavigatorDefinition:goTo('shop')
-------------------------------------
function UINavigatorDefinition:goTo_shop(...)
    local args = {...}
    local tab_name = args[1]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Shop')
    if (is_opend == true) then
        self:closeUIList(idx)
		if tab_name then
            ui:setTab(tab_name)
        end
        return
    end

    g_shopDataNew:openShopPopup(tab_name)
end

-------------------------------------
-- function goTo_event_illusion_dungeon
-- @brief 환상던전 이벤트로 이동
-- @usage UINavigatorDefinition:goTo('event_illusion_dungeon')
-------------------------------------
function UINavigatorDefinition:goTo_event_illusion_dungeon(...)
    local args = {...}
    local stage_id = args[1]

    -- 환상 이벤트가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_EventDungeon')
    if (is_opend == true) then
        self:closeUIList(idx)
        if stage_id then
            ui:focusByStageID(stage_id)
        end
        return
    end

    local function finish_cb()
        do-- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_EventDungeon, close_cb)
            scene:runScene()
        end
    end

    local function fail_cb()

    end

    -- 정보 요청
    g_illusionDungeonData:request_illusionInfo(finish_cb, fail_cb) -- param : finish_cb, fail_cb, include_reward
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
    
    -- 캐편 후 콜로세움
    if IS_ARENA_NEW_OPEN() and HAS_ARENA_NEW_SEASON() then
        self:goTo('arena_new')

    -- 콜로세움 (신규)
    elseif IS_ARENA_OPEN() then
        self:goTo('arena')

    -- 콜로세움 (예전)
    else
        self:goTo('colosseum_old')
    end
end

-------------------------------------
-- function goTo_colosseum_old
-- @brief 콜로세움으로 이동
-- @usage UINavigatorDefinition:goTo('colosseum_old')
-------------------------------------
function UINavigatorDefinition:goTo_colosseum_old(...)
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
-- function goTo_arena
-- @brief 콜로세움으로 이동
-- @usage UINavigatorDefinition:goTo('arena')
-------------------------------------
function UINavigatorDefinition:goTo_arena(...)
    local args = {...}
    local sub_data = args[1]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Arena')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local function finish_cb()

         -- 오픈 상태 여부 체크
        if (not g_arenaData:isOpenArena()) then
            local msg = Str('콜로세움 오픈 전입니다.\n오픈까지 {1}', g_arenaData:getArenaStatusText())
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return
		end

        -- 긴급하게 닫아야 할 경우 
        if (not g_arenaData:isOpen()) then
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
            UI_Arena(sub_data)
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local battle_menu_ui = UI_BattleMenu()
            battle_menu_ui:setTab('competition') -- 전투 메뉴에서 tab의 이름이 'competition'이다.
            battle_menu_ui:resetButtonsPosition()
            UI_Arena(sub_data)
            return
        end

        do-- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_Arena, close_cb, sub_data)
            scene:runScene()
        end
    end

    local function fail_cb()

    end

    -- 정보 요청
    g_arenaData:request_arenaInfo(finish_cb, fail_cb)
end


-------------------------------------
-- function goTo_arena
-- @brief 콜로세움으로 이동
-- @usage UINavigatorDefinition:goTo('goTo_arena_new')
-------------------------------------
function UINavigatorDefinition:goTo_arena_new(...)
    local args = {...}
    local sub_data = args[1]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_ArenaNew')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local function finish_cb()
        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_ClanWarSelectScene')
        if (is_opend == true) then
            ui:close()
        end

        -- 오픈 상태 여부 체크
        if (not g_arenaNewData:isOpenArena()) then
            local str, exception = g_arenaNewData:getArenaStatusText()
            local msg = ''
            if exception then
                msg = Str(str)
            else
                msg = Str('콜로세움 오픈 전입니다.\n오픈까지 {1}', str)
            end
            
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return
		end

        -- 긴급하게 닫아야 할 경우 
        if (not g_arenaNewData:isOpen()) then
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
            UI_ArenaNew(sub_data)
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local battle_menu_ui = UI_BattleMenu()
            battle_menu_ui:setTab('competition') -- 전투 메뉴에서 tab의 이름이 'competition'이다.
            battle_menu_ui:resetButtonsPosition()
            UI_ArenaNew(sub_data)
            return
        end
          

        do-- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_ArenaNew, close_cb, sub_data)
            scene:runScene()
        end

    end

    
    local function response_status_cb(ret)
        --local ui = MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 덱이 설정되지 않았습니다.'))
        -- 요일에 맞지 않는 속성
        if (ret and tonumber(ret['status']) == -1360) then
            UI_ArenaNewDefenceDeckSettings(ARENA_NEW_STAGE_ID, 'arena_new', true)
        elseif (ret and tonumber(ret['status']) ~= 0) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('일시적인 오류입니다.\n잠시 후에 다시 시도 해주세요.'))
        end
    end

    -- 정보 요청
    g_arenaNewData:request_arenaInfo(finish_cb, fail_cb, response_status_cb)
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

    local req_table_cb = function()
        -- 정보 요청
        g_ancientTowerData:request_ancientTowerInfo(stage_id, finish_cb, fail_cb)
    end

    -- 보상 테이블 요청
    g_ancientTowerData:request_ancientTowerSeasonRankInfo(req_table_cb)
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
-- function goTo_challenge_mode
-- @brief 챌린지 모드로 이동
-- @usage UINavigatorDefinition:goTo('challenge_mode')
-------------------------------------
function UINavigatorDefinition:goTo_challenge_mode(...)
    local args = {...}
    local stage = args[1]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_ChallengeMode')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local function finish_cb()

        if (not g_challengeMode:isOpen_challengeMode()) then
            local msg = Str('오픈시간이 아닙니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return
		end

        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
        if (is_opend == true) then
            self:closeUIList(idx)
            ui:setTab('competition') -- 전투 메뉴에서 tab의 이름이 'competition'이다.
            ui:resetButtonsPosition()
            UI_ChallengeMode()
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local battle_menu_ui = UI_BattleMenu()
            battle_menu_ui:setTab('competition') -- 전투 메뉴에서 tab의 이름이 'competition'이다.
            battle_menu_ui:resetButtonsPosition()
            UI_ChallengeMode()
            return
        end

        do-- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_ChallengeMode, close_cb)
            scene:runScene()
        end
    end

    local function fail_cb()

    end

    -- 정보 요청
    g_challengeMode:request_challengeModeInfo(stage, finish_cb, fail_cb, true) -- param : stage, finish_cb, fail_cb, include_reward
end

-------------------------------------
-- function goTo_grand_arena
-- @brief 그랜드 콜로세움으로 이동
-- @usage UINavigatorDefinition:goTo('grand_arena')
-------------------------------------
function UINavigatorDefinition:goTo_grand_arena(...)
    local args = {...}
    local stage = args[1]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_GrandArena')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local function finish_cb()

        if (not g_grandArena:isActive_grandArena()) then
            local msg = Str('오픈시간이 아닙니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return
		end

        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
        if (is_opend == true) then
            self:closeUIList(idx)
            ui:setTab('competition') -- 전투 메뉴에서 tab의 이름이 'competition'이다.
            ui:resetButtonsPosition()
            UI_GrandArena()
            return
        end

        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            local battle_menu_ui = UI_BattleMenu()
            battle_menu_ui:setTab('competition') -- 전투 메뉴에서 tab의 이름이 'competition'이다.
            battle_menu_ui:resetButtonsPosition()
            UI_GrandArena()
            return
        end

        do-- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_GrandArena, close_cb)
            scene:runScene()
        end
    end

    local function fail_cb()

    end

    -- 연습전 기간
    if g_grandArena:isPreseason() then
        finish_cb()
        return
    end

    -- 정보 요청
    g_grandArena:request_grandArenaInfo(finish_cb, fail_cb, true) -- param : finish_cb, fail_cb, include_reward)
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
-- function goTo_ancient_ruin
-- @brief 고대 유적 던전으로 이동
-- @usage UINavigatorDefinition:goTo('ancient_ruin', stage_id)
-------------------------------------
function UINavigatorDefinition:goTo_ancient_ruin(...)
    local args = {...}
    local stage_id = args[1]
    self:goTo_nestdungeon_core(stage_id, NEST_DUNGEON_ANCIENT_RUIN)
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
        -- 기존 UI에 등록된 콜백 저장
        local close_cb = ui.m_closeCB
        ui:setCloseCB(nil)

        -- 해당 UI까지 포함해서 삭제
        self:closeUIList(idx, true) -- param : idx, include_idx

        -- 새로 생성 (갱신을 위해)
        local new_ui = UI_NestDungeonScene(stage_id, dungeon_type)
        new_ui:setCloseCB(close_cb)
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
        -- 기존 UI에 등록된 콜백 저장
        local close_cb = ui.m_closeCB
        ui:setCloseCB(nil)

        -- 해당 UI까지 포함해서 삭제
        self:closeUIList(idx, true) -- param : idx, include_idx

        -- 새로 생성 (갱신을 위해)
        local new_ui = UI_SecretDungeonScene(stage_id)
        new_ui:setCloseCB(close_cb)
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
    local focus_id = args[2]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Hatchery')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    local function finish_cb()
        -- 퀵메뉴 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_QuickPopupNew')
        if (is_opend == true) then
            self:closeUIList(idx)
            UI_Hatchery(tab, focus_id)
            return
        end
        
        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            UI_Hatchery(tab, focus_id)
            return
        end

        do-- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end
            local scene = SceneCommon(UI_Hatchery, close_cb, tab, focus_id)
            scene:runScene()
        end
    end

    g_hatcheryData:update_hatcheryInfo(finish_cb)
end

-------------------------------------
-- function goTo_rune_forge
-- @brief 룬 세공소로 이동
-- @usage UINavigatorDefinition:goTo('rune_forge', tab)
-------------------------------------
function UINavigatorDefinition:goTo_rune_forge(...)
    local args = {...}
    local tab = args[1]
    local focus_id = args[2]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_RuneForge')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx

        -- 기존 팝업에서 탭 이동만 시켜주자
        if tab then
            ui:setTab(tab)
        end
        
        return
    end

    local function finish_cb()
        -- 퀵메뉴 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_QuickPopupNew')
        if (is_opend == true) then
            self:closeUIList(idx)
            UI_RuneForge(tab, focus_id)
            return
        end
        
        -- 로비가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            UI_RuneForge(tab, focus_id)
            return
        end

        do-- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end
            local scene = SceneCommon(UI_RuneForge, close_cb, tab, focus_id)
            scene:runScene()
        end
    end

    finish_cb()
--
    --g_hatcheryData:update_hatcheryInfo(finish_cb)
end

-------------------------------------
-- function goTo_friend
-- @brief 친구UI로 이동
-- @usage UINavigatorDefinition:goTo('friend')
-------------------------------------
function UINavigatorDefinition:goTo_friend(...)
	local args = {...}
    local tab_name = args[1]

	-- 로비 진입후 친구 팝업 뜨기 전까지의 받은 요청이 있을 수 있음, 진입시 하일라이트 정보 갱신!
	g_highlightData:request_highlightInfo(function() 

		-- 해당 UI가 열려있을 경우
		local is_opend, idx, friend_ui = self:findOpendUI('UI_FriendPopup')
		if (is_opend == true) then
            self:closeUIList(idx, false) -- param : idx, include_idx
            if tab_name then
                friend_ui:setTab(tab_name)
            end
			return
		end

		-- 로비가 열려있을 경우
		local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
		if (is_opend == true) then
			self:closeUIList(idx)
            local friend_ui = UI_FriendPopup()
            if tab_name then
                friend_ui:setTab(tab_name)
            end
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
    local is_opend, idx, ui = self:findOpendUI('UI_ClanGuest')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end
    
    -- 클랜 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Clan')
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

        -- 퀵메뉴 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_QuickPopupNew')
        if (is_opend == true) then
            self:closeUIList(idx)
            local ui = target_ui_class(sel_tamer_id)
            return
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
    -- 클랜 가입이 되지 않은 상태에서 진입시에
    if (g_clanData:isClanGuest()) then
        local msg = Str('소속된 클랜이 없습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end

    -- 클랜 던전 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_ClanRaid')
    if (is_opend == true) then
        self:closeUIList(idx)
        ui:refresh(true)
        return
    end
        
    local function finish_cb()
        -- 오픈 상태 여부 체크
        if (not g_clanRaidData:isOpenClanRaid()) then
            local msg = Str(g_clanRaidData:getClanRaidStatusText())
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return
		end

        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
        if (is_opend == true) then
            self:closeUIList(idx)
            ui:setTab('clan') -- 전투 메뉴에서 tab의 이름이 'clan'이다.
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
-- function goTo_rune_guardian
-- @brief 룬 수호자 던전으로 이동
-- @usage UINavigatorDefinition:goTo('rune_guardian')
-------------------------------------
function UINavigatorDefinition:goTo_rune_guardian(...)
    -- 클랜 가입이 되지 않은 상태에서 진입시에
    if (g_clanData:isClanGuest()) then
        local msg = Str('소속된 클랜이 없습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end

    -- 악몽 10단계 클리어하지 않았을 경우
    if (not g_nestDungeonData:isClearNightmare()) then
        local msg = Str('룬 수호자 던전은 클랜 전용 던전이며 악몽 던전 10단계 클리어 후 오픈 됩니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end

    -- 룬 수호자 던전 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_RuneGuardianDungeonScene')
    if (is_opend == true) then
        self:closeUIList(idx)
        ui:refresh(true)
        return
    end
        
    -- 전투 메뉴가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
    if (is_opend == true) then
        self:closeUIList(idx)
        ui:setTab('clan') -- 전투 메뉴에서 tab의 이름이 'clan'이다.
        ui:resetButtonsPosition()
        UI_RuneGuardianDungeonScene()
        return
    end

    -- 클랜 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Clan')
    if (is_opend == true) then
        self:closeUIList(idx)
        UI_RuneGuardianDungeonScene()
        return
    end

    -- 로비가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
    if (is_opend == true) then
        self:closeUIList(idx)
        UI_RuneGuardianDungeonScene()
        return
    end

    do-- Scene으로 클랜 던전 UI 동작
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end

        local scene = SceneCommon(UI_RuneGuardianDungeonScene, close_cb)
        scene:runScene()
    end
end

-------------------------------------
-- function goTo_package_shop
-- @brief 패키지 상점으로 이동
-- @usage UINavigatorDefinition:goTo('package_shop')
-------------------------------------
function UINavigatorDefinition:goTo_package_shop(...)
    local args = {...}
    local initial_tab = args[1]
    
    local close_cb = (type(args[2]) == 'function') and args[2]
    
    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_ShopPackageScene')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        
        if initial_tab then
            local uic_table = ui.m_tableView
            for _,item in ipairs(uic_table.m_itemList) do

                local item_ui = item['generated_ui'] or item['ui']

                if item_ui.m_data['t_name'] == initial_tab then
                    ui:changeTargetUI(item_ui)
                end
            end
            ui.m_targetButton:click_btn()
        end

        return
    end

    local function finish_cb()
        local ui = UI_ShopPackageScene(initial_tab)

        if close_cb then
            ui:setCloseCB(close_cb)
        end
    end

    g_shopDataNew:request_shopInfo(finish_cb)
end

-------------------------------------
-- function goTo_event_gold_dungeon
-- @brief 황금던전 이벤트 탭으로 이동
-- @usage UINavigatorDefinition:goTo('event_gold_dungeon')
-------------------------------------
function UINavigatorDefinition:goTo_event_gold_dungeon(...)
    local args = {...}
    local sub_menu = args[1]
    local tar_dragon = args[2]

    -- 이벤트 팝업이 열려있는 경우
    local is_opend, idx, ui = self:findOpendUI('UI_EventPopup')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end

        g_eventData:openEventPopup('event_gold_dungeon', close_cb)
    end
end

-------------------------------------
-- function goTo_event_match_card
-- @brief 카드 짝 맞추기 이벤트 탭으로 이동
-- @usage UINavigatorDefinition:goTo('event_match_card')
-------------------------------------
function UINavigatorDefinition:goTo_event_match_card(...)
    local args = {...}
    local sub_menu = args[1]
    local tar_dragon = args[2]

    -- 이벤트 팝업이 열려있는 경우
    local is_opend, idx, ui = self:findOpendUI('UI_EventPopup')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end

        g_eventData:openEventPopup('event_match_card', close_cb)
    end
end

-------------------------------------
-- function goTo_event_rune_festival
-- @brief 룬 축제 이벤트 탭으로 이동
-- @usage UINavigatorDefinition:goTo('event_rune_festival')
-------------------------------------
function UINavigatorDefinition:goTo_event_rune_festival(...)
    local args = {...}
    local sub_menu = args[1]
    local tar_dragon = args[2]

    -- 이벤트 팝업이 열려있는 경우
    local is_opend, idx, ui = self:findOpendUI('UI_EventPopup')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end

        g_eventData:openEventPopup('event_rune_festival', close_cb)
    end
end

-------------------------------------
-- function goTo_event_mandragora_quest
-- @brief 만드라고라 이벤트 탭으로 이동
-- @usage UINavigatorDefinition:goTo('event_mandragora_quest')
-------------------------------------
function UINavigatorDefinition:goTo_event_mandragora_quest(...)
    local args = {...}
    local sub_menu = args[1]
    local tar_dragon = args[2]

    -- 이벤트 팝업이 열려있는 경우
    local is_opend, idx, ui = self:findOpendUI('UI_EventPopup')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end

        g_eventData:openEventPopup('event_mandragora_quest', close_cb)
    end
end

-------------------------------------
-- function goTo_event_incarnation_of_sins
-- @brief 죄악의 화신 토벌작전 이벤트 탭으로 이동
-- @usage UINavigatorDefinition:goTo('event_incarnation_of_sins')
-------------------------------------
function UINavigatorDefinition:goTo_event_incarnation_of_sins(...)
    local args = {...}

    -- 이벤트 팝업이 열려있는 경우
    local is_opend, idx, ui = self:findOpendUI('UI_EventPopup')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end

        g_eventData:openEventPopup('event_incarnation_of_sins', close_cb)
    end
end


-------------------------------------
-- function goTo_event_dealking
-- @brief 딜킹 이벤트 탭으로 이동
-- @usage UINavigatorDefinition:goTo('event_dealking')
-------------------------------------
function UINavigatorDefinition:goTo_event_dealking(...)
    local args = {...}

    -- 이벤트 팝업이 열려있는 경우
    local is_opend, idx, ui = self:findOpendUI('UI_EventPopup')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end

        g_eventData:openEventPopup('event_dealking', close_cb)
    end
end

-------------------------------------
-- function goTo_battle_ready
-- @brief 전투 준비 화면으로 이동
-- @usage UINavigatorDefinition:goTo('battle_ready')
-------------------------------------
function UINavigatorDefinition:goTo_battle_ready(...)
    local args = {...}
    local stage_id = args[1]
    local finish_cb = args[2]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_ReadySceneNew')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            if (finish_cb) then
                finish_cb()
            else
                UINavigatorDefinition:goTo('lobby')
            end
        end

        local scene = SceneCommon(UI_ReadySceneNew, close_cb, stage_id)
        scene:runScene()
    end
end

-------------------------------------
-- function goTo_illusion_battle_ready
-- @brief 환상 던전 전투 준비 화면으로 이동
-- @usage UINavigatorDefinition:goTo('illusion_battle_ready')
-------------------------------------
function UINavigatorDefinition:goTo_illusion_battle_ready(...)
    local args = {...}
    local stage_id = args[1]
    local finish_cb = args[2]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_ReadySceneNew_IllusionDungeon')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            if (finish_cb) then
                finish_cb()
            else
                UINavigatorDefinition:goTo('lobby')
            end
        end

        local scene = SceneCommon(UI_ReadySceneNew_IllusionDungeon, close_cb, stage_id)
        scene:runScene()
    end
end


-------------------------------------
-- function goTo_shop_daily
-- @brief 일일 상점으로 이동
-- @usage UINavigatorDefinition:goTo('shop_daily')
-------------------------------------
function UINavigatorDefinition:goTo_shop_daily(...)
    local args = {...}
    local is_popup = args[1] or false
    local buy_cb = args[2]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_ShopDaily')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end
    
    local function finish_cb()
        local ui = UI_ShopDaily(is_popup)
        if (buy_cb) then
            ui:setBuyCB(buy_cb)
        end
    end
     -- 서버에 상품정보 요청
	g_shopDataNew:request_shopInfo(finish_cb)
end

-------------------------------------
-- function goTo_shop_random
-- @brief 랜덤 상점으로 이동
-- @usage UINavigatorDefinition:goTo('shop_random')
-------------------------------------
function UINavigatorDefinition:goTo_shop_random(...)
    local args = {...}

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_RandomShop')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end
    
    local function finish_cb()
        local ui = UI_RandomShop()
        if (buy_cb) then
            ui:setBuyCB(buy_cb)
        end
    end

     -- 서버에 상품정보 요청
	g_randomShopData:request_shopInfo(finish_cb)
end

-------------------------------------
-- function goTo_shop_booster
-- @brief 부스터 상점으로 이동
-- @usage UINavigatorDefinition:goTo('shop_booster')
-------------------------------------
function UINavigatorDefinition:goTo_shop_booster(...)
    local args = {...}
    local is_popup = args[1] or false
    local buy_cb = args[2]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_ShopBooster')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end
    
    local function finish_cb()
        local ui = UI_ShopBooster(is_popup)
        if (buy_cb) then
            ui:setBuyCB(buy_cb)
        end
    end
     -- 서버에 상품정보 요청
	g_shopDataNew:request_shopInfo(finish_cb)
end

-------------------------------------
-- function goTo_dragon_diary
-- @brief 드래곤 성장일지로 이동
-- @usage UINavigatorDefinition:goTo('dragon_diary')
-------------------------------------
function UINavigatorDefinition:goTo_dragon_diary(...)
    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_DragonDiaryPopup')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end
    
    local function finish_cb()
        UI_DragonDiaryPopup()
    end

	g_dragonDiaryData:checkAlreadyClear(finish_cb)
end

-------------------------------------
-- function goTo_mail_select
-- @brief 선택한 아이템만 노출되는 우편함으로 이동
-- @usage UINavigatorDefinition:goTo('mail_select')
-------------------------------------
function UINavigatorDefinition:goTo_mail_select(...)
    local args = {...}
    local select_type = args[1] or MAIL_SELECT_TYPE.NONE
    local close_cb = args[2]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_MailSelectPopup')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end
    
    local function finish_cb()
        local ui = UI_MailSelectPopup(select_type)
        if (close_cb) then
            ui:setCloseCB(close_cb)
        end
    end

    -- 수신함 
	g_mailData:request_mailList(finish_cb)
end

-------------------------------------
-- function goTo_gold_dungeon
-- @brief 황금 던전으로 이동
-- @usage UINavigatorDefinition:goTo('gold_dungeon')
-------------------------------------
function UINavigatorDefinition:goTo_gold_dungeon(...)
    local args = {...}
    local stage_id = args[1]
    local dungeon_type = args[2]

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_GoldDungeonScene')
    if (is_opend == true) then
        -- 기존 UI에 등록된 콜백 저장
        local close_cb = ui.m_closeCB
        ui:setCloseCB(nil)

        -- 해당 UI까지 포함해서 삭제
        self:closeUIList(idx, true) -- param : idx, include_idx

        -- 새로 생성 (갱신을 위해)
        local new_ui = UI_GoldDungeonScene()
        new_ui:setCloseCB(close_cb)
        return
    end

    -- 전투 메뉴가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
    if (is_opend == true) then
        self:closeUIList(idx)
        ui:setTab('dungeon') -- 전투 메뉴에서 tab의 이름이 'dungeon'이다.
        ui:resetButtonsPosition()
        UI_GoldDungeonScene()
        return
    end

    -- 로비가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
    if (is_opend == true) then
        self:closeUIList(idx)
        local battle_menu_ui = UI_BattleMenu()
        battle_menu_ui:setTab('dungeon') -- 전투 메뉴에서 tab의 이름이 'dungeon'이다.
        battle_menu_ui:resetButtonsPosition()
        UI_GoldDungeonScene()
        return
    end

    do-- Scene으로 동작
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end

        local scene = SceneCommon(UI_GoldDungeonScene, close_cb)
        scene:runScene()
    end
end

-------------------------------------
-- function goTo_capsule
-- @brief 캡슐 뽑기로 이동 
-- @warning lobby에서 드빌전용관 이동할 때 이름도 capsuleBtn으로 사용함 주의!
-- @usage UINavigatorDefinition:goTo('capsule')
-------------------------------------
function UINavigatorDefinition:goTo_capsule(...)
	g_capsuleBoxData:openCapsuleBoxUI()
end

-------------------------------------
-- function goTo_hell_of_fame
-- @brief 명예의 전당으로 이동
-- @usage UINavigatorDefinition:goTo('hell_of_fame')
-------------------------------------
function UINavigatorDefinition:goTo_hell_of_fame(...)
  -- 명예의 전당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_HallOfFame')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end

    local function cb_func(ret)
        UI_HallOfFame(ret['list'])
    end

    local type = 'world'
    local offset = 1 -- 상위 유저 기준
    local limit = 5 -- 5개까지 랭킹 정보를 가져옴
    g_rankData:request_HallOfFameRank(type, limit, offset, cb_func)
end

-------------------------------------
-- function goTo_clan_war
-- @brief 클랜전으로 이동
-- @usage UINavigatorDefinition:goTo('clan_war')
-------------------------------------
function UINavigatorDefinition:goTo_clan_war(...)
    local args = {...}
    local open_by_scene = args[1]

	-- 클랜 가입이 되지 않은 상태에서 진입시에
    if (g_clanData:isClanGuest()) then
        local msg = Str('소속된 클랜이 없습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end

    local function finish_cb(ret)
        -- 정비 상태 여부 체크
        if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['LOCK']) then
            local msg = Str('클랜전을 정비 중입니다.')
            --local sub_msg = Str('경기 준비 시간 00:00 ~ 10:00') .. '\n' .. Str('경기 진행 시간 10:00 ~ 24:00')
            local sub_msg = ''
            MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg)
            return       
        end

        -- 오픈 상태 여부 체크
        if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['DONE']) then
            local msg
            if g_localData:isGlobalServer() then
                msg = Str('클랜전을 정비 중입니다.')
            else
                msg = Str('다음 클랜전까지 {1} 남음', g_clanWarData:getRemainSeasonTime())
            end
            
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return       
        end

        -- 클랜전 UI 생성 함수
        local function create_clan_war_ui(ret)
        	-- 조별리그    
			if g_clanWarData:isGroupStage() then
                return UI_ClanWar_GroupStage()
	        
			-- 토너먼트    
			else
                local ui_tournament = UI_ClanWarTournamentTree()
                ui_tournament:setTournamentData(ret)
                return ui_tournament
            end
        end

		-- 클랜전 UI가 열려있을 경우
        -- 기존처럼 UI 갱신이 아니라 클랜전 로비를 다시 만들어 줄 것이기 때문에 idx-1까지 UI닫고 생성함
		local is_opend, idx, ui = self:findOpendUI('UI_ClanWar_GroupStage')
		if (is_opend == true) then
			self:closeUIList(idx-1)
			create_clan_war_ui(ret)
			return
		end

		-- 클랜전 UI가 열려있을 경우
        -- 기존처럼 UI 갱신이 아니라 클랜전 로비를 다시 만들어 줄 것이기 때문에 idx-1까지 UI닫고 생성함
		local is_opend, idx, ui = self:findOpendUI('UI_ClanWarTournamentTree')
		if (is_opend == true) then
			self:closeUIList(idx-1)
			create_clan_war_ui(ret)
			return
		end

        -- 전투 메뉴가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_BattleMenu')
        if (is_opend == true) then
            self:closeUIList(idx)
            ui:setTab('clan') -- 전투 메뉴에서 tab의 이름이 'clan'이다.
            ui:resetButtonsPosition()
            create_clan_war_ui(ret)
            return
        end

		-- 클랜 UI가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Clan')
        if (is_opend == true) then
            self:closeUIList(idx)
            create_clan_war_ui(ret)
            return
        end

        -- 로비 UI가 열려있을 경우
        local is_opend, idx, ui = self:findOpendUI('UI_Lobby')
        if (is_opend == true) then
            self:closeUIList(idx)
            create_clan_war_ui(ret)
            return
        end

        do-- Scene으로 클랜전 UI 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(create_clan_war_ui, close_cb, ret)
            scene:runScene()
        end
    end

    local function fail_cb()

    end

    -- 클랜전 정보 요청
    g_clanWarData:request_clanWarLeagueInfo(nil, finish_cb) -- param : team, success_cb
end

-------------------------------------
-- function goTo_dimension_gate
-- @brief 차원문으로 이동
-- @usage UINavigatorDefinition:goTo('dmgate')
-------------------------------------
function UINavigatorDefinition:goTo_dmgate(...)
    local args = {...}
    local stage = args[1]

    -- 해당 UI가 열려있을 경우
    local is_opened, index, ui = self:findOpendUI('UI_DmgateScene')
    if is_opened then 
        self:closeUIList(index)
        return
    end

    local function finish_cb()

        -- 전투 메뉴가 열려 있을 경우
        local is_opened, index, ui = self:findOpendUI('UI_BattleMenu')
        if is_opened then
            self:closeUIList(index) 
            ui:setTab('dungeon')
            ui:resetButtonsPosition()
            UI_DmgateScene(DIMENSION_GATE_ANGRA)
            return
        end

        -- 로비가 열려있을 경우
        local is_opened, index, ui = self:findOpendUI('UI_Lobby')
        if is_opened then
            self:closeUIList(index) 
            UI_DmgateScene(DIMENSION_GATE_ANGRA)
            return
        end
   
        do -- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_DmgateScene, close_cb, DIMENSION_GATE_ANGRA)
            scene:runScene()
        end
    end

    local function fail_cb() end

    -- TODO : 업데이트하는 조건 추가 필요.
    g_dmgateData.m_bDirtyDimensionGateInfo = true
    g_dmgateData:request_dmgateInfo(finish_cb, fail_cb)
end

-------------------------------------
-- function goTo_dimension_gate
-- @brief 차원문으로 이동
-- @usage UINavigatorDefinition:goTo('dmgate')
-------------------------------------
function UINavigatorDefinition:goTo_league_raid(...)
    local args = {...}
    local stage = args[1]

    -- 해당 UI가 열려있을 경우
    local is_opened, index, ui = self:findOpendUI('UI_LeagueRaidScene')
    if is_opened then 
        self:closeUIList(index)
        return
    end

    local function finish_cb()

        -- 전투 메뉴가 열려 있을 경우
        local is_opened, index, ui = self:findOpendUI('UI_BattleMenu')
        if is_opened then
            self:closeUIList(index) 
            ui:setTab('competition')
            ui:resetButtonsPosition()
            UI_LeagueRaidScene()
            return
        end

        -- 로비가 열려있을 경우
        local is_opened, index, ui = self:findOpendUI('UI_Lobby')
        if is_opened then
            self:closeUIList(index) 
            UI_LeagueRaidScene()
            return
        end
   
        do -- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end

            local scene = SceneCommon(UI_LeagueRaidScene, close_cb)
            scene:runScene()
        end
    end

    local function fail_cb() end

    -- TODO : 업데이트하는 조건 추가 필요.
    g_leagueRaidData:request_RaidInfo(finish_cb, fail_cb)
end


-------------------------------------
-- function goTo_story_dungeon
-- @brief 스토리 던전으로 이동
-- @usage UINavigatorDefinition:goTo('story_dungeon')
-------------------------------------
function UINavigatorDefinition:goTo_story_dungeon(...)
    local args = {...}
    local stage_id = args[1]    

    -- 해당 UI가 열려있을 경우
    local is_opened, index, ui = self:findOpendUI('UI_DragonStoryDungeonEventScene')
    if is_opened then 
        self:closeUIList(index)
        return
    end

    local function finish_cb()
        -- 콜로세움 진입 가능 레벨 체크
        if (g_contentLockData:isContentLock('story_dungeon')) then
            UINavigatorDefinition:goTo('lobby')
            UIManager:toastNotificationRed(Str('이벤트가 종료되었습니다.'))
            return
        end

        -- 전투 메뉴가 열려 있을 경우
        local is_opened, index, ui = self:findOpendUI('UI_BattleMenu')
        if is_opened then
            self:closeUIList(index) 
            ui:setTab('adventure')
            ui:resetButtonsPosition()
            if stage_id == 'shop' then
                UI_DragonStoryDungeonEventScene(stage_id)
                UI_StoryDungeonEventShop()
                
            else
                UI_DragonStoryDungeonEventScene(stage_id)
            end
            return
        end

        -- 로비가 열려있을 경우
        local is_opened, index, ui = self:findOpendUI('UI_Lobby')
        if is_opened then
            self:closeUIList(index) 
            if stage_id == 'shop' then
                UI_DragonStoryDungeonEventScene(stage_id)
                UI_StoryDungeonEventShop(stage_id)

            else
                UI_DragonStoryDungeonEventScene(stage_id)
            end
            return
        end
   
        do -- Scene으로 동작
            local function close_cb()
                UINavigatorDefinition:goTo('lobby')
            end
            local scene

            if stage_id == 'shop' then
                scene = SceneCommon(UI_StoryDungeonEventShop, close_cb, stage_id)
            else
                scene = SceneCommon(UI_DragonStoryDungeonEventScene, close_cb, stage_id)
            end
            
            scene:runScene()
        end
    end

    local function fail_cb() end

    -- TODO : 업데이트하는 조건 추가 필요.
    g_eventDragonStoryDungeon:requestStoryDungeonInfo(finish_cb, fail_cb)

end

-------------------------------------
-- function goTo_lair
-- @brief 동굴로 이동
-- @usage UINavigatorDefinition:goTo('dmgate')
-------------------------------------
function UINavigatorDefinition:goTo_lair(...)
    local args = {...}

    

    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_DragonLair')
    if (is_opend == true) then
        self:closeUIList(idx)
        return
    end
    
    local function finish_cb()
        local ui = UI_DragonLair()
    end

     -- 서버에 상품정보 요청
	g_lairData:request_lairInfo(finish_cb)
end


-------------------------------------
-- function goTo_slime_combine
-- @brief 슈퍼 슬라임 합성으로 이동
-- @usage UINavigatorDefinition:goTo('slime_combine')
-------------------------------------
function UINavigatorDefinition:goTo_slime_combine(...)
    -- 해당 UI가 열려있을 경우
    local is_opend, idx, ui = self:findOpendUI('UI_DragonUpgradeCombineMaterial')
    if (is_opend == true) then
        self:closeUIList(idx, false) -- param : idx, include_idx
        return
    end

    local is_opened, idx, owner_ui = self:findOpendUI('UI_DragonManageInfo')
    local ui = UI_DragonUpgradeCombineMaterial()
    if (is_opened == true) then
        -- 갱신될 필요가 있다면 갱신
        local function close_cb()
            -- 슬라임 합성을 한 경우 
            if (ui.m_bDirty) then
                -- 테이블 아이템 갱신
                owner_ui:init_dragonTableView()

                local dragon_object_id = owner_ui.m_selectDragonOID
                local b_force = true
                owner_ui:setSelectDragonData(dragon_object_id, b_force)

                -- 정렬
			    owner_ui:apply_dragonSort_saveData()
            end        
        end

        ui:setCloseCB(close_cb)
    end
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
        if (ui) then
            ui:close()
        end
    end
end

-------------------------------------
-- function CloseOpendUI
-- @brief 오픈된 UI에서 특정 UI를 찾아서 열려있으면 닫는다
-------------------------------------
function UINavigatorDefinition:CloseOpendUI(ui_class_name)
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
        opend_ui:close()
    end
end