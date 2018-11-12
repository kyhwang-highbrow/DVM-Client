local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanInfoDetailPopup
-------------------------------------
UI_ClanInfoDetailPopup = class(PARENT, {
        m_structClan = 'StructClan',
        m_sortManager = '',
        m_tableView = '',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ClanInfoDetailPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ClanInfoDetailPopup'
    self.m_titleStr = Str('클랜 정보')
	--self.m_staminaType = 'pvp'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanInfoDetailPopup:init(struct_clan)
    self.m_structClan = struct_clan

    self.m_uiName = 'UI_ClanInfoDetailPopup'

    local vars = self:load('clan_02.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanInfoDetailPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanInfoDetailPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanInfoDetailPopup:initUI()
    local vars = self.vars

    self:initTab()

    -- 스크롤 가능하게 공지 라벨 생성
    do
        -- rich_label 생성
        local node = vars['scrollNode']
        local node_size = node:getContentSize()

	    local rich_label = UIC_RichLabel()
	    rich_label:setDimension(node_size['width'], node_size['height'])
	    rich_label:setFontSize(24)
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

	vars['runeDungeonBtn']:setVisible(false) -- 클랜 룬 던전 버튼 숨김
	vars['clanInfoBtn']:setVisible(false) -- 클랜 정보..?
    vars['raidBtn']:setVisible(false) -- 클랜던전 버튼 숨김
    vars['noticeBtn']:setVisible(false) -- 공지사항 작성 버튼 숨김
    vars['boardBtn']:setVisible(false) -- 게시판 작성 버튼 숨김
    vars['settingBtn']:setVisible(false) -- 클랜 관리 버튼 숨김
    vars['rankTabBtn']:setVisible(false) -- 랭킹 탭 숨김
    vars['requestMenu']:setVisible(false) -- 가입 승인 UI 숨김
    vars['requestNode']:setVisible(true) -- 가입 요청 노드

    vars['noticeLabel']:setString(Str('클랜 소개'))

    do -- 게시판 노출하지 않음
        vars['boardMenu']:setVisible(false)
        vars['boardMenu2']:setVisible(true)
        local msg = Str('같은 클랜원만 볼 수 있다고라!')
        local mandragora = UIC_Factory:MakeTableViewEmptyMandragora(msg)
        mandragora.root:setVisible(true)
        vars['boardMenu2']:addChild(mandragora.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanInfoDetailPopup:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    vars['requestBtn2']:registerScriptTapHandler(function() self:click_requestBtn2() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanInfoDetailPopup:refresh()
    local vars = self.vars

    local struct_clan = self.m_structClan
    local clan_object_id = struct_clan:getClanObjectID()

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
	self:refresh_clanBuff()

    -- 클랜 이름
    vars['clanNameLabel']:setString(struct_clan['name'])

    -- 클랜 마스터 닉네임
    vars['clanMasterLabel']:setString(struct_clan['master'])

    -- 맴버 수
    vars['clanMemberLabel']:setString(Str('{1}', struct_clan['member_cnt']))
    
    -- 클랜 소개
    local str = struct_clan:getClanIntroText()
    vars['clanNoticeLabel']:setString(str)

    -- 출석
    local str = Str('{1}', struct_clan:getLastAttd())
    vars['attendanceLabel']:setString(str)

    -- 지원 레벨
    local join_lv = struct_clan:getJoinLv()
    vars['levelLabel']:setString(Str('{1}레벨 이상', join_lv))

    -- 가입 신청이 가능한 상태일 경우
    if g_clanData:isCanJoinRequest(struct_clan) then
        vars['requestNode']:setVisible(true)
    else
        vars['requestNode']:setVisible(false)
    end

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
-- function refresh_clanBuff
-------------------------------------
function UI_ClanInfoDetailPopup:refresh_clanBuff()
	local struct_clan = self.m_structClan
	UI_Clan.refresh_clanBuff(self, struct_clan)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanInfoDetailPopup:initTab()
    local vars = self.vars

    -- 클랜 정보
    local tab_ui = UI_ClanTabInfo(self)
    self:addTabWithTabUIAndLabel('clan', vars['clanTabBtn'], vars['clanTabLabel'], tab_ui)

    -- 클랜원 정보
    local tab_ui = UI_ClanTabMember(self, 'guest')
    self:addTabWithTabUIAndLabel('member', vars['memberTabBtn'], vars['memberTabLabel'], tab_ui)

    self:setTab('clan')
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_ClanInfoDetailPopup:click_rewardBtn()
    UI_ClanAttendanceRewardInfo()
end

-------------------------------------
-- function click_requestBtn2
-------------------------------------
function UI_ClanInfoDetailPopup:click_requestBtn2()
    local struct_clan = self.m_structClan
    local clan_object_id = struct_clan:getClanObjectID()

    local function finish_cb(ret)

        -- 클랜에 가입 신청 시 즉시 가입이 되었을 경우
        if g_clanData:isNeedClanInfoRefresh() then

            local function ok_cb()
                UINavigator:closeClanUI()
                UINavigator:goTo('clan')
            end

            local msg = Str('축하합니다. 클랜에 가입되었습니다.')
            local sub_msg = Str('(클랜 정보 화면으로 이동합니다)')
            MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg, ok_cb)
        else
            UIManager:toastNotificationGreen(Str('가입 신청을 했습니다.'))
            self:refresh()
        end
    end

    local fail_cb = nil

    if struct_clan:isAutoJoin() then
        local msg = Str('자동 가입이 설정된 클랜입니다.\n가입하시겠습니까?')
        local function ok_cb()
            g_clanData:request_join(finish_cb, fail_cb, clan_object_id) 
        end
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb)
    else
        g_clanData:request_join(finish_cb, fail_cb, clan_object_id) 
    end
end

-------------------------------------
-- function init_memberSortMgr
-- @brief 정렬 도우미
-------------------------------------
function UI_ClanInfoDetailPopup:init_memberSortMgr()
    -- 정렬 매니저 생성
    self.m_sortManager = SortManager_ClanMember()

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_clanMember(vars['sortSelectBtn'], vars['sortSelectLabel'], UIC_SORT_LIST_BOT_TO_TOP)
    

    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortManager:pushSortOrder(sort_type)
        self:apply_memberSort()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortSelectOrderBtn']:registerScriptTapHandler(function()
            local ascending = (not self.m_sortManager.m_defaultSortAscending)
            self.m_sortManager:setAllAscending(ascending)
            self:apply_memberSort()

            vars['sortSelectOrderSprite']:stopAllActions()
            if ascending then
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
            else
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
            end
        end)

    -- 첫 정렬 타입 지정
    uic_sort_list:setSelectSortType('member_type')
end

-------------------------------------
-- function apply_memberSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_ClanInfoDetailPopup:apply_memberSort()
    local list = self.m_tableView.m_itemList
    self.m_sortManager:sortExecution(list)
    self.m_tableView:setDirtyItemList()
end

--@CHECK
UI:checkCompileError(UI_ClanInfoDetailPopup)
