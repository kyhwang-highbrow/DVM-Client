local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ArenaNew
-------------------------------------
UI_ArenaNew = class(PARENT, {
        m_tierProgressBar = 'ProgressTimer',
        m_rewardProgressBar = 'ProgressTimer',

        m_weekRankOffset = 'number', -- 서버에 랭킹 리스트 요청용
        m_topRankOffset = 'number', -- 서버에 랭킹 리스트 요청용

        m_bClosedTag = 'boolean', -- 시즌이 종료되어 처리를 했는지 여부

        m_winCnt =  'number',

        m_isRefreshOnCooltime = 'boolean', -- 무료갱신 쿨타임중 ...
     })


-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ArenaNew:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ArenaNew'
    self.m_titleStr = Str('콜로세움')
	self.m_staminaType = 'arena_new'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'honor'
    self.m_addSubCurrency = 'valor'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNew:init(sub_data)
    self.m_bClosedTag = false

    local ui_res = 'arena_new_scene.ui'
    local vars = self:load_keepZOrder(ui_res)

    UIManager:open(self, UIManager.SCENE)

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.4)
    self:doActionReset()
    self:doAction(nil, false)

    self.m_uiName = 'UI_ArenaNew'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ArenaNew')

    self.m_rewardProgressBar = vars['starBoxGg']
    self.m_tierProgressBar = vars['scoreGg']

    if (self.m_rewardProgressBar) then self.m_rewardProgressBar:setPercentage(0) end
    if (self.m_tierProgressBar) then self.m_tierProgressBar:setPercentage(0) end

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    -- 보상 안내 팝업
    local function finich_cb()
        -- 입문자 보상 안내 팝업
        self:showBegginerNoRewardPopup()

        local ui
        local get_target_ui = function(t_info, is_clan)
            local tar_ui  

            -- 기존 콜로세움 보상이라면 기존 UI 열자
            if (g_arenaNewData.m_bLastPvpReward) then
                tar_ui = UI_ColosseumRankingRewardPopup(t_info, is_clan)

            -- 신규 콜로세움 보상
            else
                tar_ui = UI_ArenaNewRankingRewardPopup(t_info, is_clan)
            end

            return tar_ui
        end

        -- 시즌 보상 팝업 (보상이 있다면)
		if (g_arenaNewData.m_tSeasonRewardInfo) then
            local t_info = g_arenaNewData.m_tSeasonRewardInfo
            local is_clan = false
            ui = get_target_ui(t_info, is_clan)
            
            g_arenaNewData.m_tSeasonRewardInfo = nil
		end

        -- 클랜 보상 팝업 (보상이 있다면)
        if (g_arenaNewData.m_tClanRewardInfo) then
            local t_info = g_arenaNewData.m_tClanRewardInfo
            local is_clan = true

            if (ui) then
                ui:setCloseCB(function()
                    ui = get_target_ui(t_info, is_clan)
                end)
            else
                ui = get_target_ui(t_info, is_clan)
            end

            g_arenaNewData.m_tClanRewardInfo = nil
        end

        -- 티어 달성 보상 팝업
        if(g_arenaNewData.m_tierRewardInfo and #g_arenaNewData.m_tierRewardInfo > 0) then
            UI_ArenaNewTierRewardPopup()
        end
    end

    self:sceneFadeInAction(nil, finich_cb)

    -- @ TUTORIAL : colosseum (튜토리얼 후에 처리)
--    TutorialManager.getInstance():startTutorial(TUTORIAL.COLOSSEUM, self)
end

function UI_ArenaNew:updateRivalList()
    local vars = self.vars
    local rivalNodeCount = 5

    for i = 1, rivalNodeCount do
        local node = vars['itemNode' .. tostring(i)]
        node:removeAllChildren()
    end

    local l_item_list = g_arenaNewData.m_matchUserList

    if (not l_item_list and #l_item_list <= 0) then return end

    self.m_winCnt = 0
    for i = 1, #l_item_list do
        local itemNode = vars['itemNode' .. tostring(i)]
        local item = l_item_list[i]

        if (item and itemNode) then
            local ui = UI_ArenaNewRivalListItem(item)
            itemNode:addChild(ui.root)

        -- @UI_ACTION
        ui:addAction(ui.root, UI_ACTION_TYPE_SCALE, 0, 0.3 + 0.1 * tonumber(i))
        ui:doActionReset()
        ui:doAction(nil, false)

        end

        if (item.m_state == 1) then
            self.m_winCnt = self.m_winCnt + 1
        end
    end

    --g_arenaNewData:request_arenaRank(offset, nil, finish_cb)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ArenaNew:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNew:initUI()
    local vars = self.vars

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:updateTimer(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function UI_ArenaNew:updateTimer(dt)
    local vars = self.vars
    local time_label = vars['refreshLabel']
    if time_label then
        local curr_time = Timer:getServerTime()
        local endtime = g_arenaNewData.m_costInfo['refresh_enable_time']
        if (not endtime) then 
            endtime = 0 
        else
            endtime = tonumber(endtime) / 1000
        end

        local shouldEnable = false
        if (0 < endtime) and (curr_time < endtime) then
            local remain_time = (endtime - curr_time)
            local str = datetime.makeTimeDesc_timer_filledByZero(remain_time * 1000)
            time_label:setString(str)
            self.m_isRefreshOnCooltime = true
        else
            time_label:setString(Str('갱신'))
            self.m_isRefreshOnCooltime = false
        end
    end
    
    -- UI내에서 시즌이 종료되는 경우 예외처리
    if self.m_bClosedTag then
        return
    
    elseif (not g_arenaNewData:isOpenArena()) then
        local function ok_cb()
            -- 로비로 이동
            UINavigator:goTo('lobby')
        end
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 시즌이 종료되었습니다.'), ok_cb)
        self.m_bClosedTag = true
        return
    end

    local str = g_arenaNewData:getArenaStatusText()
    vars['timeLabel']:setString(str)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNew:initButton()
    local vars = self.vars
    vars['testModeBtn']:setVisible(false)
    vars['rankDetailBtn']:registerScriptTapHandler(function() self:click_rankDetailBtn() end)
    vars['tierRewardBtn']:registerScriptTapHandler(function() self:click_rankDetailBtn() end)
	vars['defenseBtn']:registerScriptTapHandler(function() self:click_defendDeckBtn() end)
    vars['defenseRecordBtn']:registerScriptTapHandler(function() self:click_defendHistoryBtn() end)
    vars['honorBtn']:registerScriptTapHandler(function() self:click_honorMedalBtn() end)
    vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
    vars['InfoBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)

    vars['rewardBtn1']:registerScriptTapHandler(function() self:click_rewardInfoBtn(3) end)
    vars['rewardBtn2']:registerScriptTapHandler(function() self:click_rewardInfoBtn(5) end)
     
    vars['dailyRewardBtn']:registerScriptTapHandler(function() self:click_dailyReward() end)
    vars['dailyRewardSprite']:setVisible(true)

    -- 명예의 전당으로 이동
    --vars['fameBtn']:registerScriptTapHandler(function() self:click_fameBtn() end)
    --vars['fameBtn']:setVisible(false)
    
    -- 랭킹 팝업으로 이동
    vars['rankBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)
    vars['rankBtn']:setVisible(true)

    -- 콜로세움 안내 (네이버 sdk 링크)
    --NaverCafeManager:setPluginInfoBtn(vars['InfoBtn'], 'arena_help')
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNew:refresh()
    local vars = self.vars

    local struct_user_info = g_arenaNewData:getPlayerArenaUserInfo()
    do
        -- 티어 아이콘
        vars['tierIconNode']:removeAllChildren()
        local icon = struct_user_info:makeTierIcon(nil, 'big')
        vars['tierIconNode']:addChild(icon)

        local aniString = ''
        local hasAni = false

        if (string.match(struct_user_info.m_tier, "platinum")) then
            aniString = 'tier_04'
            hasAni = true
        elseif (string.match(struct_user_info.m_tier, "diamond")) then
            aniString = 'tier_05'
            hasAni = true
        elseif (string.match(struct_user_info.m_tier, "master")) then
            aniString = 'tier_07'
            hasAni = true
        elseif (string.match(struct_user_info.m_tier, "hero")) then
            aniString = 'tier_06'
            hasAni = true
        elseif (string.match(struct_user_info.m_tier, "legend")) then
            aniString = 'tier_08'
            hasAni = true
        end

        vars['tierVisual']:setVisible(hasAni)
        vars['tierVisual']:changeAni(aniString)
        vars['tierVisual']:setRepeat(true)

        -- 티어 이름
        local tier_name = struct_user_info:getTierName()
        vars['tierLabel']:setString(tier_name)

        -- 순위, 점수, 승률
        local str = struct_user_info:getRankText(true)

        vars['rankingLabel']:setString(str)
        vars['powerLabel']:setString(comma_value(struct_user_info:getDeckCombatPower(true)))
        vars['winLabel']:setString(tostring(struct_user_info:getWinCnt()))
        vars['scoreLabel']:setString(struct_user_info:getRPText(false))
    end

	-- 주간 승수 보상 -> 참여 보상으로 변경
	local curr_cnt = struct_user_info:getWinCnt() + struct_user_info:getLoseCnt()
	local temp
	if curr_cnt > 20 then
		temp = 4
	else
		temp = math_floor(curr_cnt/5)
	end

    --TODO
    -- 참여 횟수 보상
	--vars['rewardVisual']:changeAni('reward_' .. temp, true)

    self:updateRivalList()
    self:refreshTierGauge()
    self:refreshRewardInfo()
    --self:refreshHotTimeInfo()
end

-------------------------------------
-- function refreshHotTimeInfo
-- @breif 핫타임 정보 갱신
-------------------------------------
function UI_ArenaNew:refreshTierGauge()
    local struct_rank = StructArenaNewRankReward()
    local l_rank = struct_rank:getRankRewardList()

    -- 티어 게이지
    local curRp = math_floor(g_arenaNewData.m_playerUserInfo.m_rp, 0)
    local curRank = math_floor(g_arenaNewData.m_playerUserInfo.m_rank, 0)   -- 등수
    local rate = 0
    local nextMinRp = -1
    local myRankItem = nil

    -- 게이지에 필요한 수치 계산
    for i = 1, #l_rank do
        -- 조회중인 점수 조건
        local curMinRp = l_rank[i]['score_min']

        if (i == #l_rank) then
            nextMinRp = -1
        else
            -- 다음 티어달성 조건
            nextMinRp = l_rank[i + 1]['score_min']

            local totalRp = nextMinRp - curMinRp
            rate = (curRp - curMinRp) / totalRp * 100
            myRankItem = l_rank[i]
        end

        if (curRp < nextMinRp) then break end
    end

    local finalString = ''

    if (not myRankItem) then
        finalString = ''
    -- 백분위가 있을 때 
    elseif (myRankItem['ratio_max'] and myRankItem['ratio_max'] ~= '') then
        rate = 100
        finalString = Str('{1}점', comma_value(curRp))
    -- 순위제한 있을 때 
    elseif (myRankItem['rank_max'] and myRankItem['rank_max'] ~= '') then
        local isInTopTen = curRank <= 10 and curRank >= 1

        if (isInTopTen) then
            rate = 100 - (curRank - 1) * 10
            finalString = Str('{1}위', curRank)
        else
            rate = curRank * 100
            finalString = Str('{1}점', comma_value(curRp))
        end

    -- 일반
    elseif (curRp < 0) then
        finalString = '-'
    else
        finalString = comma_value(curRp) .. '/' .. comma_value(nextMinRp)
    end

    local action = cc.ProgressTo:create(0.3, rate)
    self.m_tierProgressBar:runAction(action)

    self.vars['scoreGgLabel']:setString(finalString)

    -- 다음 티어 아이콘
    self:setNextTierIcon()
end



-------------------------------------
-- function setNextTierIcon
-- @breif 
-------------------------------------
function UI_ArenaNew:setNextTierIcon()
    local vars = self.vars
    if (not vars['nextTierNode']) then return end

    local table_arena_rank = TABLE:get('table_arena_new_rank')
    local struct_rank = StructArenaNewRankReward()
    local l_rank = struct_rank:getRankRewardList()
    local struct_user_info = g_arenaNewData:getPlayerArenaUserInfo()
    local nextTier = struct_user_info.m_tier
    local nextTierId = 99
    local nextTierReward = 0

    -- 게이지에 필요한 수치 계산
    for i = 1, #l_rank do
        if (i == #l_rank and l_rank[i]['tier'] == struct_user_info.m_tier) then
            nextTier = l_rank[i]['tier']
            break
        end

        if (l_rank[i]['tier'] == struct_user_info.m_tier) then
            nextTier = l_rank[i + 1]['tier']
            nextTierId = l_rank[i + 1]['tier_id']

            local l_reward = plSplit(l_rank[i + 1]['achieve_reward'], ';')

            if (l_reward and #l_reward >= 2) then
                nextTierReward = tonumber(l_reward[2])
            end
            break
        end
    end

    if (vars['nextTierNode']) then 
        vars['nextTierNode']:removeAllChildren()

        local icon = struct_user_info:makeTierIcon(nextTier, 'small')
        vars['nextTierNode']:addChild(icon)
    end

    -- 보상 받았는지?
    local hasArchiveReward = g_arenaNewData:hasArchiveReward(nextTierId) and  nextTierReward > 0
    if (vars['tierRewardBtn']) then vars['tierRewardBtn']:setVisible(hasArchiveReward) end
    if (vars['tierRewardLabel']) then 
        if (nextTierReward > 0) then
            vars['tierRewardLabel']:setString(comma_value(nextTierReward)) 
        else
            vars['tierRewardLabel']:setString('') 
        end
    end
end

-------------------------------------
-- function refreshHotTimeInfo
-- @breif 핫타임 정보 갱신
-------------------------------------
function UI_ArenaNew:refreshHotTimeInfo()
    local vars = self.vars
    local l_active_hot = {}
    
    vars['hotTimeHonorBtn']:setVisible(false)
    
    -- 콜로세움 pvp 명예 핫타임
    local active, value = g_fevertimeData:isActiveFevertimeByType('pvp_honor_up')
    if active then
        value = value * 100 -- fevertime에서는 1이 100%이기 때문에 100을 곱해준다.
        table.insert(l_active_hot, 'hotTimeHonorBtn')
        local str = string.format('+%d%%', value)
        vars['hotTimeHonorLabel']:setString(str)
        vars['hotTimeHonorBtn']:registerScriptTapHandler(function() g_hotTimeData:makeHotTimeToolTip('pvp_honor_up', vars['hotTimeHonorBtn']) end)
    end
    
    for i,v in ipairs(l_active_hot) do
        vars[v]:setVisible(true)
    end
end

-------------------------------------
-- function refreshRewardInfo
-- @breif 핫타임 정보 갱신
-------------------------------------
function UI_ArenaNew:refreshRewardInfo()
    local vars = self.vars
    --local rewardInfo = g_arenaNewData.m_rewardInfo
    local l_item_list = g_arenaNewData.m_matchUserList

    local strRewardLabelPrefix = 'rewardLabel'
    for i = 1, 5 do
        local label = vars[strRewardLabelPrefix .. tostring(i)] 
        if (label) then
            label:setString('')
        end
    end

    if (not l_item_list or #l_item_list <= 0) then return end

    if (self.m_rewardProgressBar) then
        local rate = self.m_winCnt / #l_item_list * 100
        local action = cc.ProgressTo:create(0.3, rate)

        self.m_rewardProgressBar:runAction(action)
    end

    -- 3승 5승 이미지 설정
    local isThirdReached = self.m_winCnt >= 3
    local isFIfthReached = self.m_winCnt >= 5
    local winRewardAniName3 = isThirdReached and 'arena_box_03' or 'arena_box_01'
    local winRewardAniName5 = isFIfthReached and 'arena_box_03' or 'arena_box_01'

    if (vars['winRewardSprite3']) then vars['winRewardSprite3']:changeAni(winRewardAniName3, true) end
    if (vars['winRewardSprite5']) then vars['winRewardSprite5']:changeAni(winRewardAniName5, true) end

    if (vars['rewardBtn1']) then vars['rewardBtn1']:setEnabled(not isThirdReached) end
    if (vars['rewardBtn2']) then vars['rewardBtn2']:setEnabled(not isFIfthReached) end

    -- 보상테이블 받기
    local table_arena_new = TABLE:get('table_arena_new')

    -- 다음 승리시 점수 조회용
    -- 승리 수가 5일 때 다시 1로 바꾼다.
    local nextWinCnt = self.m_winCnt >= 5 and 1 or self.m_winCnt + 1

    for i = 1, #table_arena_new do
        if (table_arena_new[i]) then
            local score = 0
            local label = vars[strRewardLabelPrefix .. tostring(i)] 
            score = table_arena_new[i]['win_score']
            if (score and label) then
                label:setString(tostring(score))
            end

            -- 마지막 인덱스 조회면 처음으로
            if (nextWinCnt >= #table_arena_new) then
                g_arenaNewData.m_nextScore = table_arena_new[#table_arena_new]['win_score']
            elseif (i == nextWinCnt) then
                g_arenaNewData.m_nextScore = table_arena_new[i]['win_score']
            end
        end
    end
end

-------------------------------------
-- function showBegginerNoRewardPopup
-- @brief 입문자 보상 안내 팝업
-------------------------------------
function UI_ArenaNew:showBegginerNoRewardPopup()
    local save_key = 'no_reward'
    local is_view = g_settingData:get('arena_guide', save_key) or false
    if (is_view) then
        return
    end

    local struct_user_info = g_arenaNewData:getPlayerArenaUserInfo()
    local tier = struct_user_info.m_tier
    if (tier ~= 'beginner') then
        return
    end

    local msg = Str('현재 입문자 등급입니다.')
    local sub_msg = Str('콜로세움 시즌마다 1회 이상 전투를 진행해야 순위가 집계되고 시즌 보상을 받을 수 있습니다.')
    MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg)
    g_settingData:applySettingData(true, 'arena_guide', save_key)
end

-------------------------------------
-- function click_defendDeckBtn
-- @brief 콜로세움 랭킹 정보 팝업 (최고 순위 기록 시즌, 현재 시즌)
-------------------------------------
function UI_ArenaNew:click_defendDeckBtn()
    g_deckData:setSelectedDeck('arena_new_d')

	UI_ArenaNewDefenceDeckSettings(ARENA_NEW_STAGE_ID, 'arena_new_d', true)
end

-------------------------------------
-- function click_defendHistoryBtn
-- @brief 콜로세움 랭킹 정보 팝업 (최고 순위 기록 시즌, 현재 시즌)
-------------------------------------
function UI_ArenaNew:click_defendHistoryBtn()
    local function finish_cb(ret)
	    UI_ArenaNewHistory()
    end
    
    g_arenaNewData:request_arenaHistory(finish_cb, nil)

end

-------------------------------------
-- function click_rankDetailBtn
-- @brief 콜로세움 랭킹 정보 팝업 (최고 순위 기록 시즌, 현재 시즌)
-------------------------------------
function UI_ArenaNew:click_rankDetailBtn()
	UI_ArenaNewRankInfoPopup()
end

-------------------------------------
-- function click_rewardInfoBtn
-- @brief 콜로세움 보상 정보 팝업
-------------------------------------
function UI_ArenaNew:click_rewardInfoBtn()
    UI_ArenaRewardInfoPopup()
end

-------------------------------------
-- function click_startBtn
-- @brief 출전 덱 설정 버튼
-------------------------------------
function UI_ArenaNew:click_startBtn()
    g_deckData:setSelectedDeck('arena_new_a')

	UI_ArenaNewDeckSettings(ARENA_NEW_STAGE_ID, 'arena_new_a', false)
end

-------------------------------------
-- function click_honorMedalBtn
-- @brief 명예훈장 버튼
-------------------------------------
function UI_ArenaNew:click_honorMedalBtn()
	local ui_shop_popup = UI_Shop()
    ui_shop_popup:setTab('honor')
end
    

-------------------------------------
-- function click_fameBtn
-- @brief 명예의 전당으로 이동
-------------------------------------
function UI_ArenaNew:click_fameBtn()
    UINavigatorDefinition:goTo('hell_of_fame')
end

-------------------------------------
-- function click_rankBtn
-- @brief 랭킹으로 이동
-------------------------------------
function UI_ArenaNew:click_rankBtn()
    UI_ArenaNewRankPopup()
end

-------------------------------------
-- function click_testModeBtn
-- @brief 테스트 모드로 진입
-------------------------------------
function UI_ArenaNew:click_testModeBtn()
    local combat_power = g_arenaNewData.m_playerUserInfo:getDefDeckCombatPower(true)
    if (combat_power == 0) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 덱이 설정되지 않았습니다.'))
        return
    end

    UI_ColosseumReadyForDev()
end

-------------------------------------
-- function click_valorShopBtn
-------------------------------------
function UI_ArenaNew:click_valorShopBtn()
	 UINavigator:goTo('shop', 'valor')
end

-------------------------------------
-- function click_helpBtn
-------------------------------------
function UI_ArenaNew:click_helpBtn()
	 UI_ArenaNewHelp()
end



-------------------------------------
-- function click_valorShopBtn
-------------------------------------
function UI_ArenaNew:click_refreshBtn()
    local function ok_cb()
        self:updateRivalList()
        self:refreshRewardInfo()
    end
    -- cost_info 조회
    local maxRefreshCount = g_arenaNewData:getCostInfo('refresh_cash_max_count')
    local curRefreshCount = g_arenaNewData:getCostInfo('refresh_cash_cur_count')

    -- 무료가능?
    if (not self.m_isRefreshOnCooltime) then
        UI_ArenaNewRivalListResetPopup(ok_cb, self.m_isRefreshOnCooltime)
        return
    end

    -- 유료 다썼음?
    if (curRefreshCount >= maxRefreshCount) then
        UIManager:toastNotificationRed(Str('사용 가능한 횟수를 초과했습니다.'))
        return
    end

    -- 그것도 아님 ㅇㅋ
    UI_ArenaNewRivalListResetPopup(ok_cb, self.m_isRefreshOnCooltime)

end

-------------------------------------
-- function click_rewardInfoBtn3
-- step 3/5 승
-- 3단계 보상 미리보기
-------------------------------------
function UI_ArenaNew:click_rewardInfoBtn(step)
    UI_ArenaNewStepRewardPopup(step, self.m_winCnt)

end


function UI_ArenaNew:click_dailyReward()
    UI_ArenaNewDailyReward()
end


--@CHECK
UI:checkCompileError(UI_ArenaNew)
