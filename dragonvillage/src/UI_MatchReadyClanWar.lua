local PARENT = UI_MatchReady

-------------------------------------
-- class UI_MatchReadyClanWar
-------------------------------------
UI_MatchReadyClanWar = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MatchReadyClanWar:init()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_MatchReadyClanWar:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_MatchReadyClanWar'
    self.m_bVisible = true
    self.m_titleStr = Str('쿨랜전')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'honor'
    self.m_addSubCurrency = 'valor'

    -- 입장권 타입 설정
    self.m_staminaType = TableDrop:getStageStaminaType(CHALLENGE_MODE_STAGE_ID)
    self.m_uiBgm = 'bgm_dungeon_ready'
end

-------------------------------------
-- function click_deckBtn
-- @brief 출전 덱 변경
-------------------------------------
function UI_MatchReadyClanWar:click_deckBtn()
    local vars = self.vars 
    local deck_change_mode = true
    local ui = UI_ReadySceneNew(CHALLENGE_MODE_STAGE_ID, true)
    local function close_cb()
        self:initUI()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_startBtn
-- @brief 시작 버튼
-------------------------------------
function UI_MatchReadyClanWar:click_startBtn()
    --[[
    -- 콜로세움 공격 덱이 설정되었는지 여부 체크
    local l_dragon_list = self:getStructUserInfo_Player():getDeck_dragonList()
    if (table.count(l_dragon_list) <= 0) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('그림자의 신전 덱이 설정되지 않았습니다.'))
        return
    end

    local check_dragon_inven
    local check_item_inven
    local check_stamina
    local start_game

    -- 드래곤 가방 확인(최대 갯수 초과 시 획득 못함)
    check_dragon_inven = function()
        local function manage_func()
            self:click_manageBtn()
        end
        g_dragonsData:checkMaximumDragons(check_item_inven, manage_func)
    end

    -- 아이템 가방 확인(최대 갯수 초과 시 획득 못함)
    check_item_inven = function()
        local function manage_func()
            UI_Inventory()
        end
        g_inventoryData:checkMaximumItems(check_stamina, manage_func)
    end

    check_stamina = function()
        -- 스태미너 소모 체크
        local stage = g_challengeMode:getSelectedStage()
        local req_count = g_challengeMode:getChallengeMode_staminaCost(stage)

        if g_staminasData:hasStaminaCount('st', req_count) then
            start_game()
        else
            local function finish_cb()
            end
            MakeSimplePopup(POPUP_TYPE.YES_NO, Str('날개가 부족합니다.\n상점으로 이동하시겠습니까?'), function() g_shopDataNew:openShopPopup('st', finish_cb) end)
        end
    end

    start_game = function()
        -- 콜로세움 시작 요청
        local function cb(ret)
            -- 시작이 두번 되지 않도록 하기 위함
            UI_BlockPopup()
            local scene = SceneGameChallengeMode(g_challengeMode.m_gameKey)
            scene:runScene()
        end

        -- api 요청
        g_challengeMode:request_challengeModeStart(cb)
    end

    check_dragon_inven()
    --]]
end

-------------------------------------
-- function getStructUserInfo_Player
-------------------------------------
function UI_MatchReadyClanWar:getStructUserInfo_Player()
    local struct_user_info = g_arenaData:getPlayerArenaUserInfo()
    return struct_user_info
end

-------------------------------------
-- function getStructUserInfo_Opponent
-------------------------------------
function UI_MatchReadyClanWar:getStructUserInfo_Opponent()
    local struct_user_info = g_arenaData:getPlayerArenaUserInfo()
    return struct_user_info
end

-------------------------------------
-- function initStaminaInfo
-------------------------------------
function UI_MatchReadyClanWar:initStaminaInfo()
    local vars = self.vars
end