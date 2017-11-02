local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Clan
-------------------------------------
UI_Clan = class(PARENT, {
     })

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
    self.m_subCurrency = 'clan_coin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function init
-------------------------------------
function UI_Clan:init()
    local vars = self:load('clan_02.ui')
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
        if g_clanData:isNeedClanSetting() then
            self:click_settingBtn()
        end
    end

    self:sceneFadeInAction(nil, finich_cb)

    -- @ TUTORIAL
    --TutorialManager.getInstance():startTutorial(TUTORIAL.CLAN, self)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Clan:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Clan:initUI()
    local vars = self.vars

    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Clan:initButton()
    local vars = self.vars

    vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end)
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
    vars['clanNameLabel']:setString(struct_clan['name'])

    -- 클랜 마스터 닉네임
    vars['clanMasterLabel']:setString(struct_clan['master'])

    -- 맴버 수
    vars['clanMemberLabel']:setString(Str('클랜원 {1}/{2}', struct_clan['member_cnt'], 20))
    
    -- 클랜 공지
    vars['clanNoticeLabel']:setString(struct_clan['notice'] or Str('등록된 공지가 없습니다.'))

    -- 클랜원 리스트
    self:init_TableView()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_Clan:initTab()
    local vars = self.vars

    -- 클랜 정보
    local tab_ui = UI_ClanTabInfo(self, 'clan')
    self:addTabWithTabUIAndLabel('clan', vars['clanTabBtn'], vars['clanTabLabel'], tab_ui)

    -- 클랜 랭킹
    local tab_ui = UI_ClanTabRank(self, 'rank')
    self:addTabWithTabUIAndLabel('rank', vars['rankTabBtn'], vars['rankTabLabel'], tab_ui)

    self:setTab('clan')
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
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_Clan:init_TableView()
    local node = self.vars['memberNode']
    node:removeAllChildren()

    local struct_clan = g_clanData:getClanStruct()
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
        --[[
        local function click_previousButton()
            self:update_topRankTableView(self.m_topRankOffset - 30)
        end
        ui.vars['previousButton']:registerScriptTapHandler(click_previousButton)

        local function click_nextButton()
            self:update_topRankTableView(self.m_topRankOffset + 30)
        end
        ui.vars['nextButton']:registerScriptTapHandler(click_nextButton)
        --]]
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
UI:checkCompileError(UI_Clan)
