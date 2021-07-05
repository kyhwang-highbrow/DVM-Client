local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_FriendMatchReadyArena
-------------------------------------
UI_FriendMatchReadyArena = class(PARENT,{
        m_mode = 'FRIEND_MATCH_MODE',
        m_vsuid = '',
        m_player2DDeck = 'UI_2DDeck',
        m_bClosedTag = 'boolean', -- 시즌이 종료되어 처리를 했는지 여부

        m_radioButton = 'UIC_RadioBtn',
    })

-- 친구 대전 제외한 친선전은 우정포인트 10 소모
local NEED_TYPE = 'fp'
local NEED_PRICE = 10

-------------------------------------
-- function init
-------------------------------------
function UI_FriendMatchReadyArena:init(mode, vsuid)
    self.m_mode = mode or FRIEND_MATCH_MODE.FRIEND
    self.m_vsuid = vsuid
    self.m_bClosedTag = nil

    -- 친선대전 공격덱 선택
    g_deckData:setSelectedDeck('fpvp_atk')

    local vars = self:load('arena_ready.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_FriendMatchReadyArena')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_FriendMatchReadyArena:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_FriendMatchReadyArena'
    self.m_bVisible = true
    self.m_titleStr = Str('친선전')
    self.m_bUseExitBtn = true

    -- 입장권 타입 설정
    local mode = self.m_mode
    local map_staimina = {}
    map_staimina[FRIEND_MATCH_MODE.FRIEND] = 'fpvp'
    map_staimina[FRIEND_MATCH_MODE.CLAN] = 'st'
    map_staimina[FRIEND_MATCH_MODE.RETRY] = 'arena'
    map_staimina[FRIEND_MATCH_MODE.REVENGE] = 'arena'
    local tar_stamina = map_staimina[mode]
    self.m_staminaType = tar_stamina

    -- 서브 재화 설정
    self.m_subCurrency = NEED_TYPE
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendMatchReadyArena:initUI()
    local vars = self.vars
    local mode = self.m_mode

	-- 클랜전 메뉴 초기화
    vars['clanWarMenu']:setVisible(false)
    vars['clanWarBgSprite']:setVisible(false)

    -- 스태미나 아이콘 설정
    local map_staimina_icon = {}
    map_staimina_icon[FRIEND_MATCH_MODE.FRIEND] = 'res/ui/icons/inbox/inbox_staminas_fpvp.png'
    map_staimina_icon[FRIEND_MATCH_MODE.CLAN] = 'res/ui/icons/inbox/inbox_fp.png'
    map_staimina_icon[FRIEND_MATCH_MODE.RETRY] = 'res/ui/icons/inbox/inbox_fp.png'
    map_staimina_icon[FRIEND_MATCH_MODE.REVENGE] = 'res/ui/icons/inbox/inbox_fp.png'

    local icon_path = map_staimina_icon[mode]
    local icon = IconHelper:getIcon(icon_path)
    vars['staminaNode']:removeAllChildren()
    vars['staminaNode']:addChild(icon)

    -- 스태미나 갯수 설정
    local map_staimina_cnt = {}
    map_staimina_cnt[FRIEND_MATCH_MODE.FRIEND] = '1'
    map_staimina_cnt[FRIEND_MATCH_MODE.CLAN] = tostring(NEED_PRICE)
    map_staimina_cnt[FRIEND_MATCH_MODE.RETRY] = tostring(NEED_PRICE)
    map_staimina_cnt[FRIEND_MATCH_MODE.REVENGE] = tostring(NEED_PRICE)

    local tar_stamina_cnt = map_staimina_cnt[mode]
    vars['actingPowerLabel']:setString(tar_stamina_cnt)

    local b_arena = true
    do -- 플레이어 유저 덱
        local t_pvp_deck = g_friendMatchData.m_playerUserInfo.m_pvpDeck

        local player_2d_deck = UI_2DDeck(nil, b_arena)
        player_2d_deck:setDirection('left')
        vars['formationNode1']:addChild(player_2d_deck.root)
        player_2d_deck:initUI()

        local l_dragon_obj = g_friendMatchData.m_playerUserInfo:getDeck_dragonList()
        local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
        player_2d_deck:setDragonObjectList(l_dragon_obj, leader)
        self.m_player2DDeck = player_2d_deck

        -- 진형 설정
        local formation = 'attack'
        if t_pvp_deck then
            formation = t_pvp_deck['formation'] or 'attack'
        end
        self.m_player2DDeck:setFormation(formation)
    end

    do -- 상대방 유저 덱
        local t_pvp_deck = g_friendMatchData.m_matchInfo.m_pvpDeck

        local player_2d_deck = UI_2DDeck(nil, b_arena)
        player_2d_deck:setDirection('right')
        vars['formationNode2']:addChild(player_2d_deck.root)
        player_2d_deck:initUI()

        local l_dragon_obj = g_friendMatchData.m_matchInfo:getDeck_dragonList()
        local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
        player_2d_deck:setDragonObjectList(l_dragon_obj, leader)

        -- 진형 설정
        local formation = 'attack'
        if t_pvp_deck then
            formation = t_pvp_deck['formation'] or 'attack'
        end
        player_2d_deck:setFormation(formation)
    end

    -- 친선대전만 보상 있음
    if (mode == FRIEND_MATCH_MODE.FRIEND) then
        vars['friendshipNode']:setVisible(true)
    end

    self:initUI_userInfo()
end

-------------------------------------
-- function initUI_userInfo
-------------------------------------
function UI_FriendMatchReadyArena:initUI_userInfo()
    local vars = self.vars

    do
        -- 레벨, 닉네임
        local user_info = g_friendMatchData.m_playerUserInfo
        vars['userLabel1']:setString(user_info:getUserText())

        -- 전투력
        local str = user_info:getDeckCombatPower(true)
        vars['powerLabel1']:setString(Str('전투력 : {1}', comma_value(str)))

        -- 아이콘
        local icon = user_info:getDeckTamerReadyIcon()
        vars['tamerNode1']:removeAllChildren()
        vars['tamerNode1']:addChild(icon)
    end

    do
        local user_info = g_friendMatchData.m_matchInfo

        -- 레벨, 닉네임
        vars['userLabel2']:setString(user_info:getUserText())

        -- 전투력
        local str = user_info:getDeckCombatPower()
        vars['powerLabel2']:setString(Str('전투력 : {1}', comma_value(str)))

        -- 아이콘
        local icon = user_info:getDeckTamerReadyIcon()
        vars['tamerNode2']:removeAllChildren()
        vars['tamerNode2']:addChild(icon)
    end

    -- radio btn
	do
        vars['radioMenu']:setVisible(true)

		local radio_button = UIC_RadioButton()        
		
        radio_button:addButton('colosseum', vars['arenaRadioBtn'], vars['arenaRadioSprite'])
        radio_button:addButton('clanwar', vars['clanRadioBtn'], vars['clanRadioSprite'])

        radio_button:setSelectedButton('colosseum')
        		
		self.m_radioButton = radio_button
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendMatchReadyArena:initButton()
    local vars = self.vars
    vars['deckBtn']:registerScriptTapHandler(function() self:click_deckBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    vars['teamBonusBtn1']:registerScriptTapHandler(function() self:click_teamBonusBtn(true) end)
    vars['teamBonusBtn2']:registerScriptTapHandler(function() self:click_teamBonusBtn(false) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendMatchReadyArena:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_deckBtn
-- @brief 출전 덱 변경
-------------------------------------
function UI_FriendMatchReadyArena:click_deckBtn()
    local ui = UI_FriendMatchDeckSettingsArena(FRIEND_MATCH_STAGE_ID, 'fatk')
    local function close_cb()
        local player_2d_deck = self.m_player2DDeck
        local l_dragon_obj = g_friendMatchData.m_playerUserInfo:getDeck_dragonList()
        
        player_2d_deck:setDragonObjectList(l_dragon_obj)

        -- 진형 설정
        local formation = 'attack'
        local t_pvp_deck = g_friendMatchData.m_playerUserInfo.m_pvpDeck
        if t_pvp_deck then
            formation = t_pvp_deck['formation'] or 'attack'
        end
        self.m_player2DDeck:setFormation(formation)

        -- 유저 정보도 변경 (테이머가 갱신될 수 있음)
        self:initUI_userInfo()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_startBtn
-- @brief 시작 버튼
-------------------------------------
function UI_FriendMatchReadyArena:click_startBtn()

    -- 콜로세움 공격 덱이 설정되었는지 여부 체크
    local l_dragon_obj = g_friendMatchData.m_playerUserInfo:getDeck_dragonList()
    if (table.count(l_dragon_obj) <= 0) then
        local function yes()
            self:click_deckBtn()
        end
        MakeSimplePopup(POPUP_TYPE.YES_NO, Str('친구대전 출전 덱이 설정되지 않았습니다.\n출전 덱을 설정하시겠습니까?'), yes)
        return
    end

    local check_dragon_inven
    local check_item_inven
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
        g_inventoryData:checkMaximumItems(start_game, manage_func)
    end


    start_game = function()
        local function cb(ret)
            -- 시작이 두번 되지 않도록 하기 위함
            UI_BlockPopup()

            local friend_match = true
            local scene = SceneGameArenaNew(nil, nil, nil, nil, friend_match, self.m_radioButton.m_selectedButton)
            scene:runScene()
        end

        -- 친구대전일 경우 친구대전 스태미너 체크
        if (self.m_mode == FRIEND_MATCH_MODE.FRIEND) then
            if (not g_staminasData:checkStageStamina(FRIEND_MATCH_STAGE_ID)) then
                g_staminasData:staminaCharge(FRIEND_MATCH_STAGE_ID, function() end)
            else
                g_friendMatchData:request_arenaStart(self.m_mode, g_friendMatchData.m_matchUserID, cb)
            end

        -- 그외 우정포인트 체크
        else
            if (not ConfirmPrice(NEED_TYPE, NEED_PRICE)) then
            else
                g_friendMatchData:request_arenaStart(self.m_mode, self.m_vsuid, cb)
            end
        end
    end

    check_dragon_inven()
end

-------------------------------------
-- function click_teamBonusBtn
-------------------------------------
function UI_FriendMatchReadyArena:click_teamBonusBtn(mine)
    local l_deck
    -- 내 덱
    if (mine) then
        l_deck = g_friendMatchData.m_playerUserInfo:getDeck_dragonList()
    -- 상대 덱
    else
        l_deck = g_friendMatchData.m_matchInfo:getDeck_dragonList()
    end

	local ui = UI_TeamBonus(TEAM_BONUS_MODE.TOTAL, l_deck)
    if (not mine) then
        ui:setOnlyMyTeamBonus()
    end
end

-------------------------------------
-- function click_manageBtn
-- @brief 시작 버튼
-------------------------------------
function UI_FriendMatchReadyArena:click_manageBtn()
    local ui = UI_DragonManageInfo()
    local function close_cb()
        local function func()
            -- 콜로세움 덱(atk, def)에 출전 중인 드래곤은
            -- 삭제(작별or판매)가 불가하기 때문에 덱 정보가 변경되지 않는다는 가정 하에
            -- refresh 작업을 별도로 하지 않음
        end
        self:sceneFadeInAction(func)
    end
    ui:setCloseCB(close_cb)
end


-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_FriendMatchReadyArena:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_FriendMatchReadyArena)
