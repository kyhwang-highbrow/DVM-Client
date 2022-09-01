local PARENT = class(UI, ITabUI:getCloneTable())

local OFFSET_GAP = 30 -- 한번에 보여주는 랭커 수

------------------------------------- 
-- class UI_EventLFBagRankingPopup
-------------------------------------
UI_EventLFBagRankingPopup = class(PARENT,{
        m_rankTableView = 'UIC_TableView',
        m_rankType = 'string',
        m_rankFullType = 'string',
        m_rankOffset = 'number',

        m_rewardTableView = '',
        m_selectedUI = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventLFBagRankingPopup:init(use_for_inner_ui)
    self.m_rankOffset = 1
    self.m_uiName = 'UI_EventLFBagRankingPopup'
    local vars = self:load('event_lucky_bag_ranking_popup.ui')

    if (use_for_inner_ui) then
        -- nothing to do
    else
        UIManager:open(self, UIManager.SCENE)
	    -- backkey 지정
	    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventLFBagRankingPopup')
    end


    -- 랭킹 테이블뷰 생성됨
    self:make_UIC_SortList()
    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()

    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventLFBagRankingPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_EventLFBagRankingPopup:initTab()
    local vars = self.vars

    local daily_rank_tab = UI_EventLFBagRankingDailtyTab(self)
    local total_rank_tab = UI_EventLFBagRankingTotalTab(self)
    --vars['rankTabMenu']:addChild(daily_rank_tab.root)
    --vars['rankTabMenu']:addChild(total_rank_tab.root)
    
    daily_rank_tab:setParentAndInit(vars['rankTabMenu'])
    total_rank_tab:setParentAndInit(vars['rankTabMenu'])

    self:addTabWithTabUIAndLabel('dailyRank', vars['dailyTabBtn'], vars['dailyTabLabel'], daily_rank_tab) -- 종합 랭킹
    self:addTabWithTabUIAndLabel('totalRank', vars['totalTabBtn'], vars['totalTabLabel'], total_rank_tab) -- 속성별 랭킹

    self:setTab('dailyRank')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventLFBagRankingPopup:initButton()
    local vars = self.vars

    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventLFBagRankingPopup:refresh()
end


-------------------------------------
-- function onExitTab
-------------------------------------
function UI_EventLFBagRankingPopup:onExitTab()

end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_EventLFBagRankingPopup:onChangeTab(tab, first)
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
-- function make_UIC_SortList
-- @brief
-------------------------------------
function UI_EventLFBagRankingPopup:make_UIC_SortList()
    local vars = self.vars
    local button = vars['sortBtn']
    local label = vars['sortLabel']

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
    --uic:setSelectSortType('my')
end

-------------------------------------
-- function onChangeRankingType
-- @brief
-------------------------------------
function UI_EventLFBagRankingPopup:onChangeRankingType(type)

    if (type == 'clan' and g_clanData:isClanGuest()) then
        local msg = Str('소속된 클랜이 없습니다.')
        UIManager:toastNotificationRed(msg)
        return
    end

    if (type == 'my') then
        self.m_rankType = 'world'
        self.m_rankOffset = -1

    elseif (type == 'top') then
        self.m_rankType = 'world'
        self.m_rankOffset = 1

    elseif (type == 'friend') then
        self.m_rankType = 'friend'
        self.m_rankOffset = 1

    elseif (type == 'clan') then
        self.m_rankType = 'clan'
        self.m_rankOffset = 1

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

--@CHECK
UI:checkCompileError(UI_EventLFBagRankingPopup)