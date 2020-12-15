local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventIncarnationOfSinsRankingPopup
-------------------------------------
UI_EventIncarnationOfSinsRankingPopup = class(PARENT,{
    m_rankOffset = 'number',
    m_rankType = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:init()
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

    local all_rank_tab = UI_EventIncarnationOfSinsRankingTotalTab(self)
    local attr_rank_tab = UI_EventIncarnationOfSinsRankingAttributeTab(self)
    vars['indivisualTabMenu']:addChild(all_rank_tab.root)
    vars['indivisualTabMenu']:addChild(attr_rank_tab.root)
    
    self:addTabWithTabUIAndLabel('allRank', vars['allRankTabBtn'], vars['allRankTabLabel'], all_rank_tab) -- 종합 랭킹
    self:addTabWithTabUIAndLabel('attrRank', vars['attrRankTabBtn'], vars['attrRankTabLabel'], attr_rank_tab) -- 속성별 랭킹

    self:setTab('allRank')
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
    if (tab == 'allRank') and (first) then
	    -- 전체랭킹

	elseif (tab == 'attrRank') and (first) then
        -- 속성별 랭킹

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
end

-------------------------------------
-- function onChangeRankingType
-- @brief
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:onChangeRankingType(type)
    if (g_clanData) then
        if (type == 'clan' and g_clanData:isClanGuest()) then
            local msg = Str('소속된 클랜이 없습니다.')
            UIManager:toastNotificationRed(msg)
            return
        end
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

    -- self:requestRank(self.m_rankOffset)
end