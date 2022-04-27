
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  UI_EventRouletteRankingPopup
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_EventRouletteRankingPopup = class(UI, ITabUI:getCloneTable(),
{
    m_dailyBtn = 'UIC_Button',
    m_dailyMenu = 'cc.Menu', 
    m_totalBtn = 'UIC_Button',
    m_totalMenu = 'cc.Menu', 
    m_sortBtn = 'UIC_Button',

    m_rankType = 'string',

    m_rankOffset = 'number',
})

local OFFSET_GAP = 30

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRouletteRankingPopup:init()
    local vars = self:load('event_roulette_ranking_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRouletteRankingPopup')

    self.m_uiName = 'UI_EventRouletteRankingPopup'

    self.m_dailyBtn = vars['dailyTabBtn']
    self.m_dailyMenu = vars['dailyMenu']
    self.m_totalBtn = vars['totalTabBtn']
    self.m_totalMenu = vars['totalMenu']
    self.m_sortBtn = vars['sortBtn']


    self:init_sortList()
    self:initTab()


    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

----------------------------------------------------------------------
-- function init_sortList
----------------------------------------------------------------------
function UI_EventRouletteRankingPopup:init_sortList()
    local width, height = self.m_sortBtn:getNormalSize()
    local parent = self.m_sortBtn:getParent()
    local x, y = self.m_sortBtn:getPosition()

    local sort_list = UIC_SortList()

    sort_list.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    sort_list:setNormalSize(width, height)
    sort_list:setPosition(x, y)
    sort_list:setDockPoint(self.m_sortBtn:getDockPoint())
    sort_list:setAnchorPoint(self.m_sortBtn:getAnchorPoint())
    sort_list:init_container()

    sort_list:setExtendButton(self.m_sortBtn)
    sort_list:setSortTypeLabel(self.vars['sortLabel'])

    parent:addChild(sort_list.m_node)


    sort_list:addSortType('my', Str('내 랭킹'))
    sort_list:addSortType('top', Str('최상위 랭킹'))
    sort_list:addSortType('friend', Str('친구 랭킹'))
    sort_list:addSortType('clan', Str('클랜원 랭킹'))

    sort_list:setSortChangeCB(function(sort_type) self:onChangeSortType(sort_type) end)
end


-------------------------------------
-- function initTab
-------------------------------------
function UI_EventRouletteRankingPopup:initTab()
    local vars = self.vars

    local daily_rank_tab = UI_EventRouletteRankingTab(self, vars, 'daily')
    local total_rank_tab = UI_EventRouletteRankingTab(self, vars, 'total')

    self:addTabWithTabUIAndLabel('dailyRank', self.m_dailyBtn, vars['dailyTabLabel'], daily_rank_tab, self.m_dailyMenu, vars['dailyNode']) -- 종합 랭킹
    self:addTabWithTabUIAndLabel('totalRank', self.m_totalBtn, vars['totalTabLabel'], total_rank_tab, self.m_totalMenu, vars['totalNode']) -- 속성별 랭킹

    self:setTab('dailyRank')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_EventRouletteRankingPopup:onChangeTab(tab, first)
    self.m_currTab = tab

    -- 초기화 다 된 탭들이면
    if not first then
        -- 현재 세팅 된 탭 기준으로 refreshRank를 호출해준다.
        -- 각 탭들은 자신을 세팅하기 위해 모두 refreshRank 함수를 가진다.
        if (self.m_currTab and self.m_mTabData) then
            if (self.m_mTabData[self.m_currTab]) then
                -- 현재 팝업에서의 탭상태 vs 탭 UI의 상태
                -- 다르면 리프레시 해주자.
                local tabViewSearchType = self.m_mTabData[self.m_currTab]['ui'].m_rankType

                if (self.m_rankType ~= tabViewSearchType) then
                    self.m_mTabData[self.m_currTab]['ui']:refreshRank(self.m_rankType)
                end
            end
        end

    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_EventRouletteRankingPopup:onExitTab()

end

----------------------------------------------------------------------
-- function onChangeSortType
----------------------------------------------------------------------
function UI_EventRouletteRankingPopup:onChangeSortType(sort_type)
    
    if (sort_type == 'clan' and g_clanData:isClanGuest()) then
        local msg = Str('소속된 클랜이 없습니다.')
        UIManager:toastNotificationRed(msg)
        return
    end

    if (sort_type == 'my') then
        self.m_rankType = 'world'
        self.m_rankOffset = -1

    elseif (sort_type == 'top') then
        self.m_rankType = 'world'
        self.m_rankOffset = 1

    elseif (sort_type == 'friend') then
        self.m_rankType = 'friend'
        self.m_rankOffset = 1

    elseif (sort_type == 'clan') then
        self.m_rankType = 'clan'
        self.m_rankOffset = 1

    end
    
    -- 그냥 타입을 써도 되지만 혹시 모르니 세팅은 해주자.
    self.m_rankType = sort_type

    -- 현재 세팅 된 탭 기준으로 refreshRank를 호출해준다.
    -- 각 탭들은 자신을 세팅하기 위해 모두 refreshRank 함수를 가진다.
    if (self.m_currTab and self.m_mTabData) then
        if (self.m_mTabData[self.m_currTab]) then
            self.m_mTabData[self.m_currTab]['ui']:refreshRank(self.m_rankType)
        end
    end
end
