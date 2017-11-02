local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanInfoDetailPopup
-------------------------------------
UI_ClanInfoDetailPopup = class(PARENT, {
        m_structClan = 'StructClan',
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
    self.m_subCurrency = 'clan_coin'
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

    vars['settingBtn']:setVisible(false) -- 클랜 관리 버튼 숨김
    vars['rankTabBtn']:setVisible(false) -- 랭킹 탭 숨김
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanInfoDetailPopup:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanInfoDetailPopup:refresh()
    local vars = self.vars

    local struct_clan = self.m_structClan

    -- 클랜 마크
    local icon = struct_clan:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)

    -- 클랜 이름
    vars['clanNameLabel']:setString(struct_clan['name'])

    -- 클랜 마스터 닉네임
    vars['clanMasterLabel']:setString(struct_clan['master'])

    -- 맴버 수
    vars['clanMemberLabel']:setString(Str('클랜원 {1}/{2}', struct_clan['member_cnt'], 20))
    
    -- 클랜 소개
    local str = struct_clan:getClanIntroText()
    vars['clanNoticeLabel']:setString(str)

    -- 클랜원 리스트
    self:init_TableView()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanInfoDetailPopup:initTab()
    local vars = self.vars

    -- 클랜 정보
    local tab_ui = UI_ClanTabInfo(self, 'clan')
    self:addTabWithTabUIAndLabel('clan', vars['clanTabBtn'], vars['clanTabLabel'], tab_ui)

    self:setTab('clan')
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_ClanInfoDetailPopup:init_TableView()
    local node = self.vars['memberNode']
    node:removeAllChildren()

    local struct_clan = self.m_structClan
    local l_item_list = struct_clan.m_memberList

    --[[
    if (self.m_topRankOffset > 1) then
        local prev_data = {m_rank = 'prev'}
        l_item_list['prev'] = prev_data
    end

    if (#l_item_list > 0) then
        local next_data = {m_rank = 'next'}
        l_item_list['next'] = next_data
    end
    --]]

    -- 생성 콜백
    local function create_func(ui, data)
        -- 관리 버튼 visible off
        ui.vars['adminBtn']:setVisible(false)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1170, 120 + 5)
    table_view:setCellUIClass(UI_ClanMemberListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    --table_view_td:makeDefaultEmptyDescLabel('')

    -- 정렬
    --g_colosseumRankData:sortColosseumRank(table_view.m_itemList)
    --self.m_topRankTableView = table_view
end

--@CHECK
UI:checkCompileError(UI_ClanInfoDetailPopup)
