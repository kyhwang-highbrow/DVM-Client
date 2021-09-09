local PARENT = UI
local WAITING_TIME = 3

-------------------------------------
-- class UI_LoadingArenaNew
-------------------------------------
UI_LoadingArenaNew = class(PARENT,{
        m_lLoadingStrList = 'List<string>',
        m_bFriendMatch = 'boolean',

        m_myDeckList = 'table',

        m_remainTimer = 'number',
        m_bSelected = 'boolean',

        m_targetRivalInfo = 'StructUserInfoArenaNew',
        m_isReChallenge = 'boolean', --재도전 통해서 들어왔나?

        m_curScene = 'SceneGameArenaNew',

        m_devMode = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoadingArenaNew:init(cur_scene, isReChallenge, isDevMode)
	self.m_uiName = 'UI_LoadingArenaNew'
    local vars = self:load('arena_new_loading.ui')
    self.m_remainTimer = WAITING_TIME
    self.m_myDeckList = {}
    self.m_isReChallenge = isReChallenge
    self.m_curScene = cur_scene
    self.m_devMode = isDevMode

    if (self.m_curScene) then
        self.m_bFriendMatch = self.m_curScene.m_bFriendMatch

        local guide_type = self.m_curScene.m_loadingGuideType
	    if (guide_type) then
		    self.m_lLoadingStrList = table.sortRandom(GetLoadingStrList())
	    end

        self.vars['setDeckBtn']:setVisible(false)
        self.vars['startBtn']:setVisible(false)
        self.vars['closeBtn']:setVisible(false)
        self.vars['autoStartOnBtn']:setVisible(false)
    else
        -- backkey 지정
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_LoadingArenaNew')
        UIManager:open(self, UIManager.POPUP)

        -- @UI_ACTION
        self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.5)
        self:doActionReset()
        self:doAction(nil, false)

        -- 연속 모드 해제
        g_autoPlaySetting:setAutoPlay(false)
    end
    
	self:initUI()
    self:initButton()

    if (self.m_curScene) then
        self:selectAuto(true)
        -- 자체적으로 업데이트를 돌린다.
	    --self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    end

    if (self.m_bFriendMatch) then
        if (vars['scoreSprite']) then vars['scoreSprite']:setVisible(false) end
        if (vars['scoreWinLabel']) then vars['scoreWinLabel']:setVisible(false) end
    else
        self:setScoreLabelCenter()
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_LoadingArenaNew:update(dt)
    if (self.m_bSelected) then return end

    local prev = math_floor(self.m_remainTimer)
    self.m_remainTimer = self.m_remainTimer - dt

    local next = math_floor(self.m_remainTimer)

    if (self.m_remainTimer <= 0) then
        -- 타임아웃시 자동모드 강제 설정
        --self:selectAuto(true)

    elseif (prev ~= next) then
        local msg = Str('{1}초 후 전투가 시작됩니다.', next)
        local label = self.vars['countdownLabel']
        label:setString(msg)
        cca.uiReactionSlow(label)
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoadingArenaNew:initUI()
    local vars = self.vars
    local is_friend_match = self.m_bFriendMatch

	vars['arenaVisual']:setVisible(true)
    --self.vars['countdownLabel']:setString('')
	-- 플레이어
    do
		self:initMyDeckUI()
    end

	 -- 상대방
    do
		local struct_user_info = is_friend_match and g_friendMatchData.m_matchInfo or g_arenaNewData:getMatchUserInfo()
		if (struct_user_info) then
			-- 덱
			local l_dragon_obj = struct_user_info:getDeck_dragonList()

			local leader = struct_user_info.m_pvpDeck['leader']
			local formation = struct_user_info.m_pvpDeck['formation']

			self:initDeckUI('right', l_dragon_obj, leader, formation)

			-- 유저 정보
			self:initUserInfo('right', struct_user_info)
		end
    end

    -- 연속 전투 상태 여부에 따라 버튼이나 로딩 게이지 표시
    do
        local is_autoplay = g_autoPlaySetting:isAutoPlay()
    
        vars['btnNode']:setVisible(not is_autoplay)
        vars['loadingNode']:setVisible(is_autoplay)
    end

    g_arenaNewData:refeshNextWinCount()
    local nextScore = g_arenaNewData.m_nextScore and tonumber(g_arenaNewData.m_nextScore) or 0

    if (vars['scoreLabel']) then vars['scoreLabel']:setString(comma_value(nextScore)) end
end

-------------------------------------
-- function initMyDeckUI
-------------------------------------
function UI_LoadingArenaNew:initMyDeckUI()
    local struct_user_info

    if (self.m_curScene) then
        struct_user_info = self.m_curScene:getStructUserInfo_Player()
    else
        struct_user_info = g_arenaNewData:getPlayerArenaUserInfo()
    end

    if (not struct_user_info or not struct_user_info.m_pvpDeck) then return end

	if (struct_user_info) then
		-- 덱
		local tData = g_deckData:getDeck_lowData('arena_new_a')
        if (tData) then
		    struct_user_info:applyPvpDeckData(tData)
        end

        local l_dragon_obj = struct_user_info:getDeck_dragonList()
		local leader = nil

        if (struct_user_info.m_pvpDeck['leader']) then
            leader = struct_user_info.m_pvpDeck['leader']
        end

		local formation = nil
        
        if (struct_user_info.m_pvpDeck['formation']) then
            formation = struct_user_info.m_pvpDeck['formation']
        end

		self:initDeckUI('left', l_dragon_obj, leader, formation)

		-- 유저 정보
		self:initUserInfo('left', struct_user_info)

        self.m_myDeckList = l_dragon_obj
	end
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_LoadingArenaNew:initButton()
    local vars = self.vars
    
    vars['autoStartOnBtn'] = UIC_CheckBox(vars['autoStartOnBtn'].m_node, vars['autoStartOnSprite'], false)
    vars['autoStartOnBtn']:setManualMode(true)
    vars['autoStartOnBtn']:registerScriptTapHandler(function() self:click_autoStartOnBtn() end)

    vars['setDeckBtn']:registerScriptTapHandler( function() self:click_setAttackDeck() end)
    vars['startBtn']:registerScriptTapHandler( function() self:click_startButton() end)
    vars['closeBtn']:registerScriptTapHandler( function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoadingArenaNew:refresh()
end

-------------------------------------
-- function initDeckUI
-- @param direction 'left' or 'light'
-------------------------------------
function UI_LoadingArenaNew:initDeckUI(direction, l_dragon_obj, leader, formation)

    local vars = self.vars
    local parent_node
    if (direction == 'left') then
        parent_node = vars['formationNode1']
    elseif (direction == 'right') then
        parent_node = vars['formationNode2']
    end

    if (parent_node) then parent_node:removeAllChildren(true) end

    local player_2d_deck = UI_2DDeck(true, true)
    player_2d_deck:setDirection(direction)
    parent_node:addChild(player_2d_deck.root)
    player_2d_deck:initUI()

    -- 드래곤 생성 (리더도 함께)
    player_2d_deck:setDragonObjectList(l_dragon_obj, leader)
        
    -- 진형 설정
    player_2d_deck:setFormation(formation)
end

-------------------------------------
-- function initUserInfo
-------------------------------------
function UI_LoadingArenaNew:initUserInfo(direction, struct_user_info)
	local vars = self.vars
    local struct_clan = struct_user_info:getStructClan()
    local icon

	local idx
    if (direction == 'left') then
        idx = 1
    elseif (direction == 'right') then
        idx = 2
    end

    -- 티어
	if (struct_user_info.m_tier ~= nil) then
		icon = struct_user_info:makeTierIcon(nil, 'small')
		if (icon) then
			vars['tierNode' .. idx]:addChild(icon)
		end
	end

    -- 랭킹
    vars['rankLabel' .. idx]:setString(struct_user_info:getRankText(true))

    -- 레벨, 닉네임
    vars['userLabel' .. idx]:setString(struct_user_info:getUserText())

    -- 클랜
    local clan_name = struct_clan and struct_clan:getClanName() or ''
    vars['clanLabel' .. idx]:setString(clan_name)

    icon = struct_clan and struct_clan:makeClanMarkIcon()
    if (icon) then
        vars['markNode' .. idx]:addChild(icon)
    end

    -- 전투력
    local str = comma_value(struct_user_info:getDeckCombatPower(true))
    vars['powerLabel' .. idx]:setString(Str('전투력 : {1}', str))

    vars['tamerNode' .. idx]:removeAllChildren()
    -- 아이콘
    icon = struct_user_info:getDeckTamerIcon()
    if (icon) then
        vars['tamerNode' .. idx]:addChild(icon)
    end
end

-------------------------------------
-- function prepare
-------------------------------------
function UI_LoadingArenaNew:prepare()
    return self.m_bSelected
end

-------------------------------------
-- function setNextLoadingStr
-------------------------------------
function UI_LoadingArenaNew:setNextLoadingStr()
	if (not self.m_lLoadingStrList) then
		return
	end

	local random_str = self.m_lLoadingStrList[1]
	if (random_str) then
		self.vars['loadingLabel']:setString(random_str)
		table.remove(self.m_lLoadingStrList, 1)
	end
end

-------------------------------------
-- function setLoadingGauge
-------------------------------------
function UI_LoadingArenaNew:setLoadingGauge(percent, is_not_use_label)
    local vars = self.vars

	vars['loadingGauge']:setPercentage(percent)
	if (not is_not_use_label) then
		self:setNextLoadingStr()
	end
end

-------------------------------------
-- function getLoadingGauge
-------------------------------------
function UI_LoadingArenaNew:getLoadingGauge()
	return self.vars['loadingGauge']:getPercentage()
end

-------------------------------------
-- function selectAuto
-------------------------------------
function UI_LoadingArenaNew:selectAuto(auto_mode)
    if (self.m_bSelected) then return end

    local vars = self.vars

    self.m_bSelected = true

    --g_autoPlaySetting:set('auto_mode', auto_mode)

    vars['btnNode']:setVisible(false)
    vars['loadingNode']:setVisible(true)

    -- 서버 Log를 위해 임시저장
    g_arenaData.m_tempLogData['is_auto'] = auto_mode
end

-------------------------------------
-- function click_setAttackDeck
-------------------------------------
function UI_LoadingArenaNew:click_setAttackDeck()
    local ui = UI_ArenaNewDeckSettings(ARENA_NEW_STAGE_ID, 'arena_new_a', true)

    ui:setCloseCB(function() self:initMyDeckUI() end)
end



-------------------------------------
-- function click_startButtonDev
-------------------------------------
function UI_LoadingArenaNew:click_startButtonDev()
    -- 시작이 두번 되지 않도록 하기 위함
    UI_BlockPopup()
    -- 스케쥴러 해제 (씬 이동하는 동안 입장권 모두 소모시 다이아로 바뀌는게 보기 안좋음)
    self.root:unscheduleUpdate()

    local scene = SceneGameArenaNew(nil, nil, nil, true) -- PVP 개편 테스트용 임시 커밋
    scene:runScene()
end


-------------------------------------
-- function click_startButton
-------------------------------------
function UI_LoadingArenaNew:click_startButton()
    if (self.m_devMode) then
        self:click_startButtonDev()
        return
    end

    -- 콜로세움 공격 덱이 설정되었는지 여부 체크
    local l_dragon_list = self.m_myDeckList
    if (not l_dragon_list or table.count(l_dragon_list) <= 0) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 덱이 설정되지 않았습니다.'))
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
        -- 아레나 시작 요청
        local is_cash = false
        local function request()
            local function cb(ret)
                -- 시작이 두번 되지 않도록 하기 위함
                UI_BlockPopup()
                -- 스케쥴러 해제 (씬 이동하는 동안 입장권 모두 소모시 다이아로 바뀌는게 보기 안좋음)
                self.root:unscheduleUpdate()
                self:startGame()
            end

            g_arenaNewData:request_arenaStart(is_cash, nil, cb, nil)
        end

        -- 기본 입장권 부족시
        -- ARENA_NEW_STAGE_ID
        if (not g_staminasData:checkStageStamina(ARENA_NEW_STAGE_ID)) then
            -- 유료 입장권 체크
            local is_enough, insufficient_num = g_staminasData:hasStaminaCount('arena_new', 1)
            if (is_enough) then
                is_cash = true
                local msg = Str('입장권을 모두 소모하였습니다.\n{1}다이아몬드를 사용하여 진행하시겠습니까?', NEED_CASH)
                MakeSimplePopup_Confirm('cash', NEED_CASH, msg, request)

            -- 유료 입장권 부족시 입장 불가 
            elseif (self.m_isReChallenge) then
                is_cash = false
                request()
            end

        else
            is_cash = false
            request()
        end
    end

    check_dragon_inven()

end

-------------------------------------
-- function startGame
-------------------------------------
function UI_LoadingArenaNew:startGame()
    --self:close()
    local scene = SceneGameArenaNew() -- PVP 개편 테스트용 임시 커밋
    scene:runScene()
end

-------------------------------------
-- function click_manageBtn
-- @brief 시작 버튼
-------------------------------------
function UI_LoadingArenaNew:click_manageBtn()
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
-- function click_autoStartOnBtn
-- @brief 자동전투
-------------------------------------
function UI_LoadingArenaNew:click_autoStartOnBtn()
    local function refresh_btn()
        self.vars['autoStartOnBtn']:setChecked(g_autoPlaySetting:isAutoPlay())
    end

    local is_auto = g_autoPlaySetting:isAutoPlay()

    if (is_auto) then
        g_autoPlaySetting:setAutoPlay(false)
        refresh_btn()

    else
        local ui = UI_ArenaNewAutoPlayPopup(self)
        ui:setCloseCB(refresh_btn)

    end
end

-------------------------------------
-- function setScoreLabelCenter
-- @brief 승리 시 획득 승점라벨 길이에 따라 중앙정렬하기
-------------------------------------
function UI_LoadingArenaNew:setScoreLabelCenter()
    local vars = self.vars

    -- 타이틀
    local winLabelWidth = vars['scoreWinLabel']:getContentSize().width * 0.9

    -- 아이콘
    local iconWidth = vars['scoreSprite']:getContentSize().width * 0.7

    -- 스코어
    -- 이상하게 컨텐츠 사이즈가 크게 나온다
    local strWidth = vars['scoreLabel']:getContentSize().width * 1.4

    -- 가운데까지 필요한 너비
    local centerWidth = (winLabelWidth + iconWidth + strWidth) / 2

    local winLabelX
    local iconX
    local scoreX

    -- 타티틀이 반 이상을 차지하면?
    if (winLabelWidth >= centerWidth) then
        winLabelX = winLabelWidth - centerWidth -- 그려진 딱 맞는 너비값이기 때문에 미묘하게 갭이 좀 있음

        -- 아이콘은 좌표축이 왼쪽에 있음
        iconX = (winLabelWidth - centerWidth) + (iconWidth / 2)    -- 얘도 미묘하게 차이남

        -- 얜 아이콘 X
        scoreX = iconX + (iconWidth / 2)
        
        vars['scoreWinLabel']:setPositionX(winLabelX)
        vars['scoreSprite']:setPositionX(iconX)

    else
        -- 아이콘 왕방울만하고
        -- 점수 5천만점 주고
        -- 그러면 여기 들어와야함
    end

end


--@CHECK
UI:checkCompileError(UI_LoadingArenaNew)
