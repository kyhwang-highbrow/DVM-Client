local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Clan
-------------------------------------
UI_Clan = class(PARENT, {
        m_offset = 'number',
		m_tableView = 'UIC_TableView',
     })

local NOTICE_MAX_LENGTH = 200 
local OFFSET_GAP = 20
-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Clan:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Clan'
    self.m_titleStr = Str('클랜')
	--self.m_staminaType = 'pvp'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function init
-------------------------------------
function UI_Clan:init()
    local ui_res = 'clan_02.ui'
    if (g_arenaData:isStartClanWarContents()) then
        ui_res = 'clan_03.ui'
    end

    local vars = self:load_keepZOrder(ui_res)
    UIManager:open(self, UIManager.SCENE)

    self.m_uiName = 'UI_Clan'
    self.m_offset = 0

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Clan')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    -- 보상 안내 팝업
    local function finich_cb()
        self:checkEnterEvent()
    end

    self:sceneFadeInAction(nil, finich_cb)
end

-------------------------------------
-- function checkEnterEvent
-------------------------------------
function UI_Clan:checkEnterEvent()

    -- 클랜 설정을 강제로 해야하는지 확인
    if g_clanData:isNeedClanSetting() then
        self:click_settingBtn()
        return
    end

    -- 출석 보상 정보가 있는지 확인
    if g_clanData:getAttdRewardInfo() then
        local t_reward_info = g_clanData:getAttdRewardInfo(true)
        local attd_cnt = g_clanData.m_structClan:getLastAttd()
        self:openAttendanceRewardPopup(t_reward_info, attd_cnt)
        return
    end

    -- 튜토리얼 확인
    -- @ TUTORIAL : clan
	-- mskim : UI 변경 후 튜토리얼 수정하기 힘들어 제외함
    -- TutorialManager.getInstance():startTutorial(TUTORIAL.CLAN, self)
end

-------------------------------------
-- function openAttendanceRewardPopup
-- @brief 출석 보상 UI
-------------------------------------
function UI_Clan:openAttendanceRewardPopup(t_reward_info, attd_cnt)
    local ui = UI_ClanAttendanceReward(t_reward_info, attd_cnt)

    local function close_cb()
        self:checkEnterEvent()
        g_highlightData:setDirty(true)
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Clan:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_noticeBtn
-- @brief 공지사항 변경
-------------------------------------
function UI_Clan:click_noticeBtn()
    self.vars['noticeEditBox']:openKeyboard()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Clan:initUI()
    local vars = self.vars

    -- 스크롤 가능하게 공지 라벨 생성
    do
        -- rich_label 생성
        local node = vars['scrollNode']
        local node_size = node:getContentSize()

	    local rich_label = UIC_RichLabel()
	    rich_label:setDimension(node_size['width'], node_size['height'])
	    rich_label:setFontSize(22)
	    rich_label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
	    rich_label:enableOutline(cc.c4b(0, 0, 0, 127), 1.5)
        rich_label:setDefualtColor(COLOR['white'])

	    -- scroll label  생성
	    local scroll_label = UIC_ScrollLabel:create(rich_label)
	    scroll_label:setDockPoint(cc.p(0, 1))
	    scroll_label:setAnchorPoint(cc.p(0, 1))
        node:addChild(scroll_label.m_node)
        self.vars['clanNoticeLabel'] = scroll_label
    end

    self:initTab()
    self:initEditBox()
    self:initRaidInfo()
    self:initBoardTableView()

    vars['searchMenu']:setVisible(true)
    vars['searchBtn']:registerScriptTapHandler(function() self:click_searchBtn() end)

    -- IOS maxlength 설정 안하면 입력 안됨
    vars['searchEditBox']:setMaxLength(10)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Clan:initButton()
    local vars = self.vars

    vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end)
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    vars['requestBtn']:registerScriptTapHandler(function() self:click_requestBtn() end)
    vars['raidBtn']:registerScriptTapHandler(function() self:click_raidBtn() end)
    vars['noticeBtn']:registerScriptTapHandler(function() self:click_noticeBtn() end)
    vars['boardBtn']:registerScriptTapHandler(function() self:click_boardBtn() end)
	vars['clanInfoBtn']:registerScriptTapHandler(function() self:click_clanInfoBtn() end)

    if vars['buffIconBtn1'] then
        vars['buffIconBtn1']:registerScriptTapHandler(function() self:makeHotTimeToolTip('gold', vars['buffIconBtn1']) end)
    end

    if vars['buffIconBtn2'] then
        vars['buffIconBtn2']:registerScriptTapHandler(function() self:makeHotTimeToolTip('exp', vars['buffIconBtn2']) end)
    end
    


    self:runeGuardianNoti()
    -- 룬 수호자 던전 미오픈
    if (not g_nestDungeonData:isClearNightmare()) then
        vars['runeGuardianLockSprite']:setVisible(true)

        self:runeGuardianNoti()
    end
    vars['runeDungeonBtn']:registerScriptTapHandler(function() self:click_runeDungeonBtn() end)

	-- 클랜전
	vars['clanWarBtn']:registerScriptTapHandler(function() self:click_clanWarBtn() end)
end

-------------------------------------
-- function runeGuardianNoti
-- @brief 룬 수호자 던전 핫타임 스프라이트 표시
-------------------------------------
function UI_Clan:runeGuardianNoti()
    local vars = self.vars
    -- 룬 수호자 던전 핫타임
    local rune_guardian_visible = g_fevertimeData:isActiveFevertime_dungeonRuneLegendUp()
        or g_fevertimeData:isActiveFevertime_dungeonRuneUp()
        or g_fevertimeData:isActiveFevertime_dungeonRgStDc()

    vars['runeDungeonHotSprite']:setVisible(rune_guardian_visible)
    
end

-------------------------------------
-- function initEditBox
-------------------------------------
function UI_Clan:initEditBox()
    local vars = self.vars

    -- notice editBox handler 등록
	local function notice_event_handler(event_name, p_sender)
        if (event_name == "began") then
            if (CppFunctions:isIos()) then
                vars['clanNoticeLabel']:setString('')
            end

        elseif (event_name == "return") then
            local editbox = p_sender
            local str = editbox:getText()

            -- 서버에서 ''을 nil과 같이 처리하기 때문에 임의로 공백을 부여
            if (str == '') then
                str = ' '
            end

			-- 비속어 필터링
			local function proceed_func()
                local finish_cb = function()
                    vars['clanNoticeLabel']:setString(str)
                end
                
                -- 이때 통신해서 저장
                g_clanData:request_clanSetting(finish_cb, fail_cb, nil, str)
			end
			local function cancel_func()
			end
			CheckBlockStr(str, proceed_func, cancel_func)
        end
    end
    vars['noticeEditBox']:registerScriptEditBoxHandler(notice_event_handler)
    vars['noticeEditBox']:setMaxLength(NOTICE_MAX_LENGTH)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_Clan:initTab()
    local vars = self.vars

    -- 클랜 정보
    local tab_ui = UI_ClanTabInfo(self)
    self:addTabWithTabUIAndLabel('clan', vars['clanTabBtn'], vars['clanTabLabel'], tab_ui)

    -- 클랜원 정보
    local tab_ui = UI_ClanTabMember(self)
    self:addTabWithTabUIAndLabel('member', vars['memberTabBtn'], vars['memberTabLabel'], tab_ui)

    -- 클랜 랭킹
    local tab_ui = UI_ClanTabRank(self)
    self:addTabWithTabUIAndLabel('rank', vars['rankTabBtn'], vars['rankTabLabel'], tab_ui)

    self:setTab('clan')
end

-------------------------------------
-- function initRaidInfo
-------------------------------------
function UI_Clan:initRaidInfo()
    local vars = self.vars
    local struct_raid = g_clanRaidData:getClanRaidStruct()

    vars['raidLockSprite']:setVisible(false)
    vars['raidBtn']:setVisible(true)

    -- 정보 없으면 락타임이라 간주
    if (not struct_raid) then
        function update(dt)
            if (g_clanRaidData.m_startTime == nil) then
                return
            end

            if (not g_clanRaidData:isOpenClanRaid()) then
                local msg = Str(g_clanRaidData:getClanRaidStatusText())
                vars['raidTimelabel']:setString(msg)
                vars['bossLevelLabel']:setVisible(false)
                vars['bossHpLabel']:setVisible(false)
                vars['raidTimelabel']:setVisible(true)
            -- UI 진입된 상태에서 오픈되는 경우 - 인포 다시 호출
            else
                vars['raidTimelabel']:setString('')

                -- 강제로 닫는 경우가 있어 일딴 갱신 안함 
                --[[
                self.root:unscheduleUpdate()

                -- 클랜 던전 정보 갱신
                local finish_cb = function()
                    self:initRaidInfo()
                end

                -- 클랜 정보 요청
                g_clanData:update_clanInfo(finish_cb, fail_cb)
                ]]--
            end
        end
        vars['raidTimelabel']:setVisible(false)
        self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
        
        local cur_boss_attr = g_clanData:getCurSeasonBossAttr()
        local stage_id = TableStageDesc:getStageIdByClanBossAttr(cur_boss_attr)
        self:setBossAni(stage_id)
        return
    end

    local stage_id = struct_raid:getStageID()
    self:setBossAni(stage_id)

    -- 레벨, 이름
    local is_rich_label = true
    local name = struct_raid:getBossNameWithLv(is_rich_label)
    vars['bossLevelLabel']:setString(name)

    -- 체력 퍼센트
    local tween_cb = function(number, label)
        label:setString(string.format('%0.2f%%', number))
    end

    local hp_label = vars['bossHpLabel']
    hp_label = NumberLabel(hp_label, 0, 0.3)
    hp_label:setTweenCallback(tween_cb)

    local rate = struct_raid:getHpRate()
    hp_label:setNumber(rate, false)

    if (struct_raid:isClearAllClanRaidStage() and stage_id == MAX_STAGE_ID) then
        vars['bossHpLabel']:setString(Str('마지막 스테이지를 클리어 했습니다.'))
    end
end

-------------------------------------
-- function initBoardTableView
-------------------------------------
function UI_Clan:initBoardTableView()
    local node = self.vars['boardNode']
	node:removeAllChildren(true)

	local board_data = g_clanData.m_clanBoardInfo

    local function make_func(data)
        local ui = UI_ClanBoardListItem(self, data)
        ui.vars['container']:setSwallowTouch(false)
        return ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
	table_view:setUseVariableSize(true)    -- 가변 사이즈를 쓰기 위해서 선언
	table_view.m_refreshDuration = 0
    table_view.m_defaultCellSize = cc.size(620, 95)
    table_view:setCellUIClass(make_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(board_data, true)
    table_view:makeDefaultEmptyDescLabel(Str('첫번째 게시글을 남겨주세요!'))

    -- 테이블 뷰 scroll end callback
    local l_item_list = table.MapToList(board_data)
	if (table.count(l_item_list) == OFFSET_GAP) then
		table_view:setScrollEndCB(function() self:onScrollEnd() end)
	end        
	self.m_tableView = table_view
    self:sortBoardTalbeView()
end

-------------------------------------
-- function sortBoardTalbeView
-------------------------------------
function UI_Clan:sortBoardTalbeView()
    local function sort_func(a, b)
        return a['data']['no'] < b['data']['no']
    end
    table.sort(self.m_tableView.m_itemList, sort_func)
end

-------------------------------------
-- function setBossAni
-------------------------------------
function UI_Clan:setBossAni(stage_id)
    local vars = self.vars
    
    local _, boss_mid = g_stageData:isBossStage(stage_id)

    -- 보스 animator
    local boss_node = vars['bossNode']
    boss_node:removeAllChildren()

    local l_monster = g_stageData:getMonsterIDList(stage_id)
    for _, mid in ipairs(l_monster) do
        local res, attr, evolution = TableMonster:getMonsterRes(mid)
        animator = AnimatorHelper:makeMonsterAnimator(res, attr, evolution)
        
        if (animator) then
            local zOrder = WORLD_Z_ORDER.BOSS
            local idx = getDigit(mid, 10, 1)
            if (idx == 1) and (mid == boss_mid) then
                zOrder = WORLD_Z_ORDER.BOSS     
            elseif (idx == 1) then
                zOrder = WORLD_Z_ORDER.BOSS + 1
            elseif (idx == 7) then
                zOrder = WORLD_Z_ORDER.BOSS
            else
                zOrder = WORLD_Z_ORDER.BOSS + 1 + 7 - idx
            end
            boss_node:addChild(animator.m_node, zOrder)
            animator:changeAni('idle', true)
        end
    end
end
            
-------------------------------------
-- function onScrollEnd
-- @brief 다음 OFFSET_GAP개 게시물을 가져온다.
-------------------------------------
function UI_Clan:onScrollEnd()
	self.m_offset = self.m_offset + OFFSET_GAP

	local function cb_func(t_ret)

		-- 게시글이 있는 경우 추가
		if (table.count(t_ret) > 0) then
            local board_data = g_clanData.m_clanBoardInfo
			self.m_tableView:mergeItemList(board_data)
            self:sortBoardTalbeView()

		-- 게시글이 없는 경우 콜백 해제
		else
			self.m_tableView:setScrollEndCB(nil)
			self.m_tableView:setDirtyItemList()
			UIManager:toastNotificationGreen(Str('게시글을 모두 불러왔습니다.'))
		end
	end
    
	g_clanData:request_boardList(self.m_offset, cb_func)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Clan:refresh()
    local vars = self.vars

    local struct_clan = g_clanData:getClanStruct()

    -- 클랜 마크
    local icon = struct_clan:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)

	-- 클랜 레벨
	local clan_lv = struct_clan:getClanLv()
	vars['clanLvLabel']:setString(string.format('Lv. %d', clan_lv))

	-- 클랜 경험치
	local clan_exp_percent = struct_clan:getClanExpRatio() * 100
	vars['clanExpGg']:setPercentage(clan_exp_percent)
	vars['clanExpLabel']:setString(string.format('%.2f%%', clan_exp_percent))

	-- 클랜 버프
	self:refresh_clanBuff(struct_clan)

    -- 클랜 이름
    local clan_name = struct_clan:getClanName()
    vars['clanNameLabel']:setString(clan_name)

    -- 클랜 마스터 닉네임
    local clan_master = struct_clan:getMasterNick()
    vars['clanMasterLabel']:setString(clan_master)

    -- 맴버 수
    local member_str = struct_clan:getMemberCntText()
    vars['clanMemberLabel']:setString(member_str)

    
    -- 클랜 공지
    local clan_notice = struct_clan:getClanNoticeText()
    vars['clanNoticeLabel']:setString(clan_notice)

    local member_type = g_clanData:getMyMemberType()
    if (member_type == 'master') or (member_type == 'manager') then
        vars['noticeBtn']:setVisible(true)
    else
        vars['noticeBtn']:setVisible(false)
    end

    -- 출석
    -- local str = Str('{1}', struct_clan:getCurrAttd())
    -- vars['attendanceLabel']:setString(str)
    
    local str = Str('{1}/{2}', struct_clan:getCurrAttd(), struct_clan:getMemberCnt())
    vars['attendanceLabel']:setString(str)

    -- 가입 승인 대기 수
    local str = Str('{1}', g_clanData:getRequestedJoinUserCnt())
    vars['requestLabel']:setString(str)

    -- 가입 승인
    local member_type = g_clanData:getMyMemberType()
    if (member_type == 'master') or (member_type == 'manager') then
        vars['requestMenu']:setVisible(true)
    else
        vars['requestMenu']:setVisible(false)
    end

    -- 지원 레벨
    local join_lv = struct_clan:getJoinLv()
    vars['levelLabel']:setString(Str('{1}레벨 이상', join_lv))

    -- 필수 참여 컨텐츠
    for idx = 1, 4 do
        local label = vars['contentLabel'..idx]
        label:setColor(COLOR['wood'])
    end

    local l_category = struct_clan['category']
    for idx, v in ipairs(l_category) do
        local idx = g_clanData:getNeedCategryIdxWithName(v)
        if idx then
            local label = vars['contentLabel'..idx]

            -- 선택된 필수 참여 컨텐츠
            if label then
                label:setColor(COLOR['GOLD'])
            end
        end
    end
end

-------------------------------------
-- function refresh_memberCnt
-------------------------------------
function UI_Clan:refresh_memberCnt()
    local vars = self.vars

    local struct_clan = g_clanData:getClanStruct()

    -- 맴버 수
    local member_str = struct_clan:getMemberCntText()
    vars['clanMemberLabel']:setString(member_str)

    -- 출석
    local str = Str('{1}/{2}', struct_clan:getCurrAttd(), struct_clan:getMemberCnt())
    vars['attendanceLabel']:setString(str)
end

-------------------------------------
-- function refresh_clanBuff
-------------------------------------
function UI_Clan:refresh_clanBuff(struct_clan)
	local vars = self.vars
	local struct_clan_buff = struct_clan:getClanBuffStruct()
	local idx = 1

	for clan_buff_type, value in pairs(struct_clan_buff) do
		-- 아이콘
		vars['buffIconNode' .. idx]:removeAllChildren(true)
		local icon = IconHelper:getClanBuffIcon(clan_buff_type)
		if (icon) then
			vars['buffIconNode' .. idx]:addChild(icon)
		end

		-- 버프 수치
		vars['buffLabel' .. idx]:setString(string.format('+%d%%', value))

		idx = idx + 1
	end
end

-------------------------------------
-- function requestBoard
-- @brief 클랜 게시물을 다시 요청하고 초기화한다.
-------------------------------------
function UI_Clan:requestBoard()
	self.m_offset = 0

	local offset = self.m_offset

	local function cb_func()
		self:refresh()
	end

	g_boardData:request_dragonBoard(did, offset, order, cb_func)
end

-------------------------------------
-- function click_settingBtn
-------------------------------------
function UI_Clan:click_settingBtn()
    local ui = UI_ClanSetting()

    local function close_cb()
        if ui.m_bRet then
            self:refresh()
        end

        self:checkEnterEvent()
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_Clan:click_rewardBtn()
    UI_ClanAttendanceRewardInfo()
end

-------------------------------------
-- function click_requestBtn
-- @breif 가입 승인 관리 버튼 (마스터, 부마스터 권한)
-------------------------------------
function UI_Clan:click_requestBtn()
    local work_open_popup
    local work_close_cb
    local ui

    -- 팝업 생성
    work_open_popup = function()
        ui = UI_ClanAcceptPopup()
        ui:setCloseCB(work_close_cb)
    end

    -- 팝업 닫힘 콜백
    work_close_cb = function()
        -- 클랜 정보 갱신이 필요할 경우 (신규 클랜원이 가입되었을 때)
        if g_clanData:isNeedClanInfoRefresh() then
            UINavigator:closeClanUI()
            UINavigator:goTo('clan')
        end
    end

    work_open_popup()
end

-------------------------------------
-- function click_raidBtn
-- @breif 클랜던전 버튼 
-------------------------------------
function UI_Clan:click_raidBtn()
    UINavigator:goTo('clan_raid')
end

-------------------------------------
-- function click_boardBtn
-- @brief 게시판 글쓰기
-------------------------------------
function UI_Clan:click_boardBtn()
	local ui = UI_ClanBoardPopup_Write()
	local function close_cb()
		self:initBoardTableView() 
	end
	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_clanInfoBtn
-- @brief 클랜 도움말
-------------------------------------
function UI_Clan:click_clanInfoBtn()
    UI_HelpClan()
end

-------------------------------------
-- function click_runeDungeonBtn
-- @breif 룬 수호자 던전 버튼
-------------------------------------
function UI_Clan:click_runeDungeonBtn()
    UINavigator:goTo('rune_guardian')
end

-------------------------------------
-- function click_searchBtn
-------------------------------------
function UI_Clan:click_searchBtn()
    local vars = self.vars
    local clan_name = vars['searchEditBox']:getText()

    if (clan_name == '') then
        MakeSimplePopup(POPUP_TYPE.OK, Str('검색할 클랜명을 입력하세요.'))
        return
    end

    g_clanData:requestClanInfoDetailPopup_byClanName(clan_name)
end

-------------------------------------
-- function makeHotTimeToolTip
-- @brief 클랜 버프 (경험치, 골드 부스터 툴팁)
-------------------------------------
function UI_Clan:makeHotTimeToolTip(hottime_type, btn)
    if (not btn) then
        return
    end

    -- 버프가 적용 전일 경우 클랜 레벨 도움말 띄움
    local value = g_clanData:getClanStruct():getClanBuffByType(CLAN_BUFF_TYPE[hottime_type:upper()])
    if (value <= 0) then
        UI_HelpClan('clan_level')
        return
    end

    g_hotTimeData:makeHotTimeToolTip_onlyClanBuff(hottime_type, btn)
end

-------------------------------------
-- function onFocus
-- @brief 탑바가 Lobby UI에 포커싱 되었을 때
-------------------------------------
function UI_Clan:onFocus(is_push)
    if (not is_push) then
        self:refresh()
    end
end

-------------------------------------
-- function click_clanWarBtn
-------------------------------------
function UI_Clan:click_clanWarBtn()
	UINavigatorDefinition:goTo('clan_war')
end

--@CHECK
UI:checkCompileError(UI_Clan)
