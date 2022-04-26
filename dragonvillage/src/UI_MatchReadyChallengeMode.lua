local PARENT = UI_MatchReady

-------------------------------------
-- class UI_MatchReadyChallengeMode
-------------------------------------
UI_MatchReadyChallengeMode = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MatchReadyChallengeMode:init()
    self:initChallengeModeUI()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_MatchReadyChallengeMode:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_MatchReadyChallengeMode'
    self.m_bVisible = true
    self.m_titleStr = Str('그림자의 신전')
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
function UI_MatchReadyChallengeMode:click_deckBtn()
    local vars = self.vars 
    local deck_change_mode = true
    local ui = UI_ChallengeModeDeckSettings(CHALLENGE_MODE_STAGE_ID, true)
    local function close_cb()
        self:initUI()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_startBtn
-- @brief 시작 버튼
-------------------------------------
function UI_MatchReadyChallengeMode:click_startBtn()
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
            -- UI_Inventory() @kwkang 룬 업데이트로 룬 관리쪽으로 이동하게 변경 
            UI_RuneForge('manage')
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
            local b_use_cash_label = false
            local b_open_spot_sale = true
            local st_charge_popup = UI_StaminaChargePopup(b_use_cash_label, b_open_spot_sale, finish_cb)
            UIManager:toastNotificationRed(Str('날개가 부족합니다.'))
            --MakeSimplePopup(POPUP_TYPE.YES_NO, Str('날개가 부족합니다.\n상점으로 이동하시겠습니까?'), function() g_shopDataNew:openShopPopup('st', finish_cb) end)
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
end

-------------------------------------
-- function getStructUserInfo_Player
-------------------------------------
function UI_MatchReadyChallengeMode:getStructUserInfo_Player()
    local struct_user_info = g_challengeMode:getPlayerArenaUserInfo()
    return struct_user_info
end

-------------------------------------
-- function getStructUserInfo_Opponent
-------------------------------------
function UI_MatchReadyChallengeMode:getStructUserInfo_Opponent()
    local struct_user_info = g_challengeMode:getMatchUserInfo()
    return struct_user_info
end

-------------------------------------
-- function initStaminaInfo
-------------------------------------
function UI_MatchReadyChallengeMode:initStaminaInfo()
    local vars = self.vars

    -- 스태미나 아이콘
    local stamina_type = TableDrop:getStageStaminaType(CHALLENGE_MODE_STAGE_ID)
    local icon = IconHelper:getStaminaInboxIcon(stamina_type)

    vars['staminaNode']:removeAllChildren()
    vars['staminaNode']:addChild(icon)

    -- 스태미나 갯수
    local stage = g_challengeMode:getSelectedStage()
    local cost = g_challengeMode:getChallengeMode_staminaCost(stage)
    vars['actingPowerLabel']:setString(tostring(cost))
end

-------------------------------------
-- function initChallengeModeUI
-------------------------------------
function UI_MatchReadyChallengeMode:initChallengeModeUI()
    local vars = self.vars
    vars['challengeModeMenu']:setVisible(true)

    local stage = g_challengeMode:getSelectedStage()

    
    vars['currentPointSprite']:setVisible(true)
    vars['difficultyBtn']:setVisible(true)


    -- 점수
    local point = g_challengeMode:getChallengeModeStagePoint(stage)
    local difficulty_text = self:makePointRichText(point)
    vars['currentPointLabel']:setString(difficulty_text)

    local uid = g_userData:get('uid')
    local taget_uid = self:getStructUserInfo_Opponent():getUid()

    vars['serverLabel1']:setVisible(true)
    vars['serverLabel2']:setVisible(true)
    vars['serverLabel1']:setString(g_challengeMode:getUserServer(uid))
    vars['serverLabel2']:setString(g_challengeMode:getUserServer(taget_uid))

    -- 난이도 선택 드롭리스트
    self:make_UIC_SortList()
end

-------------------------------------
-- function make_UIC_SortList
-- @brief 난이도 선택
-------------------------------------
function UI_MatchReadyChallengeMode:make_UIC_SortList()
    local vars = self.vars
    local button = vars['difficultyBtn']
    local label = vars['difficultyLabel']

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()

    uic.m_direction = UIC_SORT_LIST_BOT_TO_TOP
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)

    -- 난이도 설정
    local l_difficulty_point = {}
    table.insert(l_difficulty_point, 20) -- 쉬움 수동
    table.insert(l_difficulty_point, 30) -- 쉬움 자동

    table.insert(l_difficulty_point, 40) -- 보통 수동
    table.insert(l_difficulty_point, 60) -- 보통 자동

    table.insert(l_difficulty_point, 80) -- 어려움 수동
    table.insert(l_difficulty_point, 100) -- 어려움 자동


    -- 마스터 시즌 중 and 마스터 구간일 경우에만 지옥 모드
    if (g_challengeMode:isChallengeModeMasterMode()) then
        local cur_stage = 100 - tonumber(g_challengeMode:getSelectedStage())
        if (cur_stage < tonumber(g_challengeMode:getMasterStage())) then
            table.insert(l_difficulty_point, 120) -- 지옥 수동
            table.insert(l_difficulty_point, 150) -- 지옥 자동
        end
    end

    for i,difficulty_point in ipairs(l_difficulty_point) do
        
        local difficulty, is_auto, text = g_challengeMode:parseChallengeModeStagePoint(difficulty_point)
        local difficulty_text = self:makePointRichText(difficulty_point)
        uic:addSortType(difficulty_point, difficulty_text, nil, true)
    end

    uic:setSortChangeCB(function(sort_type) self:click_selectDifficultyBtn(sort_type) end)

    -- 기본 선택 난이도 설정
    local stage = g_challengeMode:getSelectedStage()
    local difficulty, is_auto = g_challengeMode:getRecommandDifficulty(stage)
    local point = g_challengeMode:getChallengeModeClearPoint(difficulty, is_auto)
    uic:setSelectSortType(point)
end

-------------------------------------
-- function click_selectDifficultyBtn
-------------------------------------
function UI_MatchReadyChallengeMode:click_selectDifficultyBtn(point)
    local difficulty, is_auto, text = g_challengeMode:parseChallengeModeStagePoint(point)

    -- 실제로 진행될 난이도 저장
    g_challengeMode:setSelectedDifficulty(difficulty, is_auto)
end

-------------------------------------
-- function makePointRichText
-------------------------------------
function UI_MatchReadyChallengeMode:makePointRichText(point)
    local point_color
    local top_difficulty = 100
    
    -- 최상위 난이도에 회색 표시 : 마스터 150, 일반 100
    local cur_stage = 100 - g_challengeMode:getSelectedStage()
    if (g_challengeMode:isMasterStage(cur_stage)) then
        top_difficulty = 150
    else
        top_difficulty = 100    
    end

    if (point < top_difficulty) then
        point_color = '{@DESC}'
    else
        point_color = '{@gray}'
    end

    -- 난이도
    local difficulty, is_auto, text = g_challengeMode:parseChallengeModeStagePoint(point)
    local difficulty_color = DIFFICULTY:getColorKey(difficulty)

    local difficulty_text = difficulty_color .. text .. ' ' .. point_color .. '(' .. Str('{1}점', point) .. ')'

    return difficulty_text
end