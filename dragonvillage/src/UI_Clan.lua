local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Clan
-------------------------------------
UI_Clan = class(PARENT, {
     })

local NOTICE_MAX_LENGTH = 200 
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
    local vars = self:load_keepZOrder('clan_02_new.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_uiName = 'UI_Clan'
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
    TutorialManager.getInstance():startTutorial(TUTORIAL.CLAN, self)
end

-------------------------------------
-- function openAttendanceRewardPopup
-- @brief 출석 보상 UI
-------------------------------------
function UI_Clan:openAttendanceRewardPopup(t_reward_info, attd_cnt)
    local ui = UI_ClanAttendanceReward(t_reward_info, attd_cnt)

    local function close_cb()
        self:checkEnterEvent()
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
    self:initTab()
    self:initEditBox()
    self:initRaidInfo()
    self:initBoardTableView()
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

    vars['raidLockSprite']:setVisible(struct_raid == nil)
    vars['raidBtn']:setVisible(struct_raid ~= nil)

    -- 정보 없으면 락타임이라 간주
    if (not struct_raid) then
        function update(dt)
            if (g_clanRaidData.m_startTime == nil) then
                return
            end

            if (not g_clanRaidData:isOpenClanRaid()) then
                local msg = Str('클랜던전 오픈 전입니다.\n오픈까지 {1}', g_clanRaidData:getClanRaidStatusText())
                vars['raidTimelabel']:setString(msg)

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

        self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)

        return
    end

    local stage_id = struct_raid:getStageID()
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
end

-------------------------------------
-- function initBoardTableView
-------------------------------------
function UI_Clan:initBoardTableView()
    local OFFSET_GAP = 10
    local node = self.vars['boardNode']
	node:removeAllChildren(true)

	local l_item_list = g_clanData.m_clanBoardInfo

    local function make_func(data)
        local ui = UI_ClanBoardListItem(self, data)
        return ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
	table_view:setUseVariableSize(true)    -- 가변 사이즈를 쓰기 위해서 선언
	table_view.m_refreshDuration = 0
    table_view.m_defaultCellSize = cc.size(625, 155)
    table_view:setCellUIClass(make_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list, true)
    table_view:makeDefaultEmptyDescLabel(Str('첫번째 게시글을 남겨주세요!'))
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
    local str = Str('{1}', struct_clan:getCurrAttd())
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
        local label = vars['contentLabel'..idx]

        -- 선택된 필수 참여 컨텐츠
        label:setColor(COLOR['GOLD'])
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
    local str = Str('{1}/{2}', struct_clan:getCurrAttd(), 20)
    vars['attendanceLabel']:setString(str)
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

--@CHECK
UI:checkCompileError(UI_Clan)
