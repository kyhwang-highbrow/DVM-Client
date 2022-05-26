local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventIncarnationOfSinsRankingPopup
-------------------------------------
UI_EventIncarnationOfSinsRankingPopup = class(PARENT,{
    m_rankOffset = 'number',
    m_rankType = 'string',

    m_sortList = 'UIC_SortList',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:init()
    self.uiName = 'UI_EventIncarnationOfSinsRankingPopup'
    local vars = self:load('event_incarnation_of_sins_rank_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventIncarnationOfSinsRankingPopup')

    self:make_UIC_SortList()
    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:initTab()
    local vars = self.vars

    require('UI_EventIncarnationOfSinsRankingServerTotalTab')
    require('UI_EventIncarnationOfSinsRankingTotalTab')
    require('UI_EventIncarnationOfSinsRankingAttributeTab')

    local server_rank_tab = UI_EventIncarnationOfSinsRankingServerTotalTab(self)
    local all_rank_tab = UI_EventIncarnationOfSinsRankingTotalTab(self)
    local attr_rank_tab = UI_EventIncarnationOfSinsRankingAttributeTab(self)
    
    vars['indivisualTabMenu']:addChild(server_rank_tab.root)
    vars['indivisualTabMenu']:addChild(all_rank_tab.root)
    vars['indivisualTabMenu']:addChild(attr_rank_tab.root)
    
    self:addTabWithTabUIAndLabel('serverRank', vars['serverRankTabBtn'], vars['serverRankTabLabel'], server_rank_tab) -- 통합 랭킹
    self:addTabWithTabUIAndLabel('allRank', vars['allRankTabBtn'], vars['allRankTabLabel'], all_rank_tab) -- 종합 랭킹
    self:addTabWithTabUIAndLabel('attrRank', vars['attrRankTabBtn'], vars['attrRankTabLabel'], attr_rank_tab) -- 속성별 랭킹

    self:setTab('serverRank')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:onChangeTab(tab, first)
    self.m_currTab = tab

    -- '통합 랭킹'의 경우 정렬 기준을 '내 랭킹'으로 설정
    if tab == 'serverRank' then
        self.m_sortList:setSelectSortType('my', true)
    else
        self.m_sortList:setSelectSortType('top', true)
    end

    -- 초기화 다 된 탭들이면
    if not first then
        -- 현재 세팅 된 탭 기준으로 refreshRank를 호출해준다.
        -- 각 탭들은 자신을 세팅하기 위해 모두 refreshRank 함수를 가진다.
        if (self.m_currTab and self.m_mTabData) then
            if (self.m_mTabData[self.m_currTab]) then
                -- 현재 팝업에서의 탭상태 vs 탭 UI의 상태
                -- 다르면 리프레시 해주자.
                local tabViewSearchType = self.m_mTabData[self.m_currTab]['ui'].m_searchType

                if (self.m_rankType ~= tabViewSearchType) then
                    self.m_mTabData[self.m_currTab]['ui']:refreshRank(self.m_rankType)
                end
            end
        end

    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function make_UIC_SortList
-- @brief
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:make_UIC_SortList()
    local vars = self.vars
    -- 내 순위 필터
    local button = vars['userRankBtn']
    local label = vars['rankLabel1']
    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()
    local uic = UIC_SortList()
    uic.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()
    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)
    parent:addChild(uic.m_node)
    uic:addSortType('my', Str('내 랭킹'))
    uic:addSortType('top', Str('최상위 랭킹'))
    uic:addSortType('friend', Str('친구 랭킹'))
    uic:addSortType('clan', Str('클랜원 랭킹'))
    uic:setSortChangeCB(function(sort_type) self:onChangeRankingType(sort_type) end)
    uic:setSelectSortType('my')

    self.m_sortList = uic;
end

-------------------------------------
-- function onChangeRankingType
-- @brief
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:onChangeRankingType(type)
    
    -- 랭킹 타입 바뀔 때마다 호출
    -- 소팅도 포함
    if (g_clanData) then
        if (type == 'clan' and g_clanData:isClanGuest()) then
            local msg = Str('소속된 클랜이 없습니다.')
            UIManager:toastNotificationRed(msg)

            -- 이전 탭으로 돌려보낸다
            if self.m_sortList then
                self.m_sortList:setSelectSortType(self.m_rankType)
            end

            return
        end
    end

    -- 그냥 타입을 써도 되지만 혹시 모르니 세팅은 해주자.
    self.m_rankType = type

    -- 현재 세팅 된 탭 기준으로 refreshRank를 호출해준다.
    -- 각 탭들은 자신을 세팅하기 위해 모두 refreshRank 함수를 가진다.
    if (self.m_currTab and self.m_mTabData) then
        if (self.m_mTabData[self.m_currTab]) then
            self.m_mTabData[self.m_currTab]['ui']:refreshRank(self.m_rankType)
        end
    end
end