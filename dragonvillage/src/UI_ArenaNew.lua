local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ArenaNew
-------------------------------------
UI_ArenaNew = class(PARENT, {
        m_weekRankTableView = 'UIC_TableView',
        m_topRankTableView = 'UIC_TableView',
        m_friendRankTableView = 'UIC_TableView',

        m_weekRankOffset = 'number', -- 서버에 랭킹 리스트 요청용
        m_topRankOffset = 'number', -- 서버에 랭킹 리스트 요청용

        m_rankOffset = 'number',
        m_bClosedTag = 'boolean', -- 시즌이 종료되어 처리를 했는지 여부
     })

-- 탭 자동 등록을 위해 UI 네이밍과 맞춰줌
UI_ArenaNew['RANK'] = 'ranking'
UI_ArenaNew['HISTORY'] = 'history'

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ArenaNew:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ArenaNew'
    self.m_titleStr = Str('콜로세움')
	self.m_staminaType = 'arena'
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
    self.m_rankOffset = 1 -- 최상위 랭크를 받겠다는 뜻
    self.m_bClosedTag = false
    
    local ui_res = 'arena_new_scene.ui'

    -- TODO
    --if (g_arenaData:isStartClanWarContents()) then
    --    ui_res = 'arena_scene_new.ui'
    --end

    local vars = self:load_keepZOrder(ui_res)
    UIManager:open(self, UIManager.SCENE)

    self.m_uiName = 'UI_ArenaNew'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ArenaNew')

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
            if (g_arenaData.m_bLastPvpReward) then
                tar_ui = UI_ColosseumRankingRewardPopup(t_info, is_clan)

            -- 신규 콜로세움 보상
            else
                tar_ui = UI_ArenaNewRankingRewardPopup(t_info, is_clan)
            end

            return tar_ui
        end

        -- 시즌 보상 팝업 (보상이 있다면)
		if (g_arenaData.m_tSeasonRewardInfo) then
            local t_info = g_arenaData.m_tSeasonRewardInfo
            local is_clan = false
            ui = get_target_ui(t_info, is_clan)
            
            g_arenaData.m_tSeasonRewardInfo = nil
		end

        -- 클랜 보상 팝업 (보상이 있다면)
        if (g_arenaData.m_tClanRewardInfo) then
            local t_info = g_arenaData.m_tClanRewardInfo
            local is_clan = true

            if (ui) then
                ui:setCloseCB(function()
                    ui = get_target_ui(t_info, is_clan)
                end)
            else
                ui = get_target_ui(t_info, is_clan)
            end

            g_arenaData.m_tClanRewardInfo = nil
        end
    end

    self:sceneFadeInAction(nil, finich_cb)

    -- @ TUTORIAL : colosseum (튜토리얼 후에 처리)
--    TutorialManager.getInstance():startTutorial(TUTORIAL.COLOSSEUM, self)

    self:updateRivalList()
end

function UI_ArenaNew:updateRivalList()
    local vars = self.vars
    local node = vars['itemNode']

    local l_item_list = {'', '', '', '', ''}

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(720, 100 + 5)
    table_view:setCellUIClass(UI_ArenaNewRivalListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
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

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.root:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
        end
    end)
    self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNew:initButton()
    local vars = self.vars
    vars['testModeBtn']:setVisible(false)
    --vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    --vars['rewardInfoBtn']:registerScriptTapHandler(function() self:click_rewardInfoBtn() end)
    vars['rankDetailBtn']:registerScriptTapHandler(function() self:click_rankDetailBtn() end)
	
    -- TODO 
    --[[
	do
		vars['valorShopBtn']:registerScriptTapHandler(function() self:click_valorShopBtn() end)
		vars['valorShopLabel']:setString(Str('용맹훈장') .. '\n' .. Str('상점'))
	end
    ]]

    -- 명예의 전당으로 이동
    --vars['fameBtn']:registerScriptTapHandler(function() self:click_fameBtn() end)
    --vars['fameBtn']:setVisible(false)
    
    -- 랭킹 팝업으로 이동
    vars['rankBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)
    vars['rankBtn']:setVisible(true)

    -- 콜로세움 안내 (네이버 sdk 링크)
    NaverCafeManager:setPluginInfoBtn(vars['InfoBtn'], 'arena_help')
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNew:refresh()
    local vars = self.vars

    local struct_user_info = g_arenaData:getPlayerArenaUserInfo()
    do
        -- 티어 아이콘
        vars['tierIconNode']:removeAllChildren()
        local icon = struct_user_info:makeTierIcon(nil, 'big')
        vars['tierIconNode']:addChild(icon)

        -- 티어 이름
        local tier_name = struct_user_info:getTierName()
        vars['tierLabel']:setString(tier_name)

        -- 순위, 점수, 승률
        local str = struct_user_info:getRankText(true) .. '\n'
            .. struct_user_info:getRPText()  .. '\n'
            .. struct_user_info:getWinRateText()  .. '\n'
        vars['rankingLabel']:setString(str)
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

    self:refreshHotTimeInfo()
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
-- function showBegginerNoRewardPopup
-- @brief 입문자 보상 안내 팝업
-------------------------------------
function UI_ArenaNew:showBegginerNoRewardPopup()
    local save_key = 'no_reward'
    local is_view = g_settingData:get('arena_guide', save_key) or false
    if (is_view) then
        return
    end

    local struct_user_info = g_arenaData:getPlayerArenaUserInfo()
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
-- function click_rankDetailBtn
-- @brief 콜로세움 랭킹 정보 팝업 (최고 순위 기록 시즌, 현재 시즌)
-------------------------------------
function UI_ArenaNew:click_rankDetailBtn()
	UI_ArenaRankInfoPopup()
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
    UI_ArenaDeckSettings(ARENA_STAGE_ID)
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
    UI_ArenaRankPopup()
end

-------------------------------------
-- function click_testModeBtn
-- @brief 테스트 모드로 진입
-------------------------------------
function UI_ArenaNew:click_testModeBtn()
    local combat_power = g_arenaData.m_playerUserInfo:getDefDeckCombatPower(true)
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
-- function initTab
-- @brief 랭킹, 기록 탭
-------------------------------------
function UI_ArenaNew:initTab()
    --local vars = self.vars
    --self:addTabAuto(UI_ArenaNew['RANK'], vars, vars['rankingMenu'])
    --self:addTabAuto(UI_ArenaNew['HISTORY'], vars, vars['historyMenu'])
    --self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)

    --self:setTab(UI_ArenaNew['RANK'])
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ArenaNew:onChangeTab(tab, first)
    if (not first) then
        return
    end

    if (tab == UI_ArenaNew['RANK']) then
        UI_ArenaTabRank(self)

    elseif (tab == UI_ArenaNew['HISTORY']) then
        UI_ArenaTabHistory(self)
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_ArenaNew:update(dt)
    local vars = self.vars

    -- UI내에서 시즌이 종료되는 경우 예외처리
    if self.m_bClosedTag then
        return

    elseif (not g_arenaData:isOpenArena()) then
        local function ok_cb()
            -- 로비로 이동
            UINavigator:goTo('lobby')
        end
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 시즌이 종료되었습니다.'), ok_cb)
        self.m_bClosedTag = true
        return
    end

    local str = g_arenaData:getArenaStatusText()
    vars['timeLabel']:setString(str)
end

--@CHECK
UI:checkCompileError(UI_ArenaNew)
