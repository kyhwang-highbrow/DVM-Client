local PARENT = UI_MatchReady

-------------------------------------
-- class UI_MatchReadyClanWar
-------------------------------------
UI_MatchReadyClanWar = class(PARENT,{
		m_myStructMatchItem = 'StructClanWarMatchItem',
		m_curEnemyStructMatchItem = 'StructClanWarMatchItem',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MatchReadyClanWar:init(struct_match_item, my_struct_match_item)
	self.m_myStructMatchItem = my_struct_match_item
	self.m_curEnemyStructMatchItem = struct_match_item

	self:getStructUserInfo_Opponent() -- 적 정보 초기화
	self:getStructUserInfo_Player()

    self:initResult()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initResult
-------------------------------------
function UI_MatchReadyClanWar:initResult()
    local vars = self.vars
    vars['clanWarMenu']:setVisible(true)
    vars['startBtn']:setVisible(false)
    vars['clanWarStartBtn']:setVisible(true)
    vars['clanWarStartBtn']:registerScriptTapHandler(function() self:click_startBtn() end)

    -- 승/패/승 세팅
    local l_game_result = self.m_myStructMatchItem:getGameResult()
    
    for i, result in ipairs(l_game_result) do
        local color
        if (result == '0') then
            color = StructClanWarMatch.STATE_COLOR['LOSE']
        else
            color = StructClanWarMatch.STATE_COLOR['WIN']
        end
        if (vars['setResult'..i]) then
            vars['setResult'..i]:setColor(color)
            vars['setResult'..i]:setVisible(true)
        end
    end

	local no_time = (#l_game_result == 0)
	vars['lastTimeLabel']:setVisible(not no_time)
	vars['noTimeSprite']:setVisible(no_time)
end

-------------------------------------
-- function update
-------------------------------------
function UI_MatchReadyClanWar:update()
    local vars = self.vars
    local end_time = self.m_myStructMatchItem:getEndDate()

    if (not end_time) then
        vars['lastTimeLabel']:setString('')
        return
    end

    -- 공격 끝날 때 까지 남은 시간 = 공격 시작 시간 + 1시간
    local cur_time = Timer:getServerTime_Milliseconds()
    local remain_time = (end_time - cur_time)/1000
    if (remain_time > 0) then
        local hour = math.floor(remain_time / 3600)
        local min = math.floor(remain_time / 60) % 60
        vars['lastTimeLabel']:setString(Str('남은 공격 시간 {1}:{2} 남음', hour, min))
    else
        vars['lastTimeLabel']:setString('')
    end
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_MatchReadyClanWar:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_MatchReadyClanWar'
    self.m_bVisible = true
    self.m_titleStr = Str('클랜전')
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
    local ui = UI_ReadySceneNew(CLAN_WAR_STAGE_ID, true)
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
    local check_dragon_inven
    local check_item_inven
    local start_game

    local struct_user_info = g_clanWarData:getStructUserInfo_Player()
	local struct_clan_war_match_item = struct_user_info:getClanWarStructMatchItem()
    if (not struct_clan_war_match_item) then
       UIManager:toastNotificationRed(Str('공격 기회를 모두 사용하였습니다.'))
       return
    end

    if (struct_clan_war_match_item:isDoAllGame()) then
       UIManager:toastNotificationRed(Str('공격 기회를 모두 사용하였습니다.'))
       return
    end

    -- 콜로세움 공격 덱이 설정되었는지 여부 체크
    local l_dragon_list = self:getStructUserInfo_Player():getDeck_dragonList()
    if (table.count(l_dragon_list) <= 0) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('최소 1명 이상은 출전시켜야 합니다.'))
        return
    end


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
        g_inventoryData:checkMaximumItems(start_game, manage_func)
    end

    start_game = function()
        -- 콜로세움 시작 요청
        local is_cash = false
        local function request()
            local function cb(ret)
                -- 시작이 두번 되지 않도록 하기 위함
                UI_BlockPopup()
                -- 스케쥴러 해제 (씬 이동하는 동안 입장권 모두 소모시 다이아로 바뀌는게 보기 안좋음)
                self.root:unscheduleUpdate()
                local scene = SceneGameClanWar(ret['gamekey'])
                scene:runScene()
            end

			local enemy_uid = self.m_curEnemyStructMatchItem['uid']
            -- self.m_historyID이 nil이 아닌 경우 재도전, 복수전
            g_clanWarData:request_clanWarStart(enemy_uid, cb)
        end
        request()
    end

    check_dragon_inven()
end

-------------------------------------
-- function getStructUserInfo_Player
-------------------------------------
function UI_MatchReadyClanWar:getStructUserInfo_Player()
    local struct_user_info = g_clanWarData:getStructUserInfo_Player()	-- g_arenaData:getPlayerArenaUserInfo()	-
	struct_user_info:setClanWarStructMatchItem(self.m_myStructMatchItem)
    return struct_user_info
end

-------------------------------------
-- function getStructUserInfo_Opponent
-------------------------------------
function UI_MatchReadyClanWar:getStructUserInfo_Opponent()
    local struct_user_info = g_clanWarData:getEnemyUserInfo()
    return struct_user_info
end

-------------------------------------
-- function initStaminaInfo
-------------------------------------
function UI_MatchReadyClanWar:initStaminaInfo()
    local vars = self.vars
    --[[
    -- 스태미나 아이콘
    local stamina_type = TableDrop:getStageStaminaType(CHALLENGE_MODE_STAGE_ID)
    local icon = IconHelper:getStaminaInboxIcon(stamina_type)

    vars['staminaNode']:removeAllChildren()
    vars['staminaNode']:addChild(icon)

    -- 스태미나 갯수
    local stage = g_challengeMode:getSelectedStage()
    local cost = g_challengeMode:getChallengeMode_staminaCost(stage)
    --]]
    vars['actingPowerLabel']:setString(tostring(10))
end