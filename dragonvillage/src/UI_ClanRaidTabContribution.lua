local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaidTabContribution
-------------------------------------
UI_ClanRaidTabContribution = class(PARENT,{
        m_owner_ui = '',
        m_contribution_table_view = 'TableView', -- 누적 기여도 테이블 뷰
        m_selected_tab = 'string',
    })

local TAB_TOTAL = 'total_contribution' -- 누적 기여도
local TAB_TOTAL_REWARD = 'total_reward' -- 누적 기여도에 대한 보상 (미리보기)
local TAB_CURRENT = 'current_contribution' -- 현재 기여도
-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidTabContribution:init(owner_ui)
    self.m_owner_ui = owner_ui
    self.m_selected_tab = TAB_TOTAL_REWARD

    self:initUI()
    self:initButton()
    self:initTab()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidTabContribution:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidTabContribution:initButton()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanRaidTabContribution:initTab()
    local vars = self.m_owner_ui.vars
    self:addTabWithLabel(TAB_TOTAL, vars['contributionTabBtn1'], vars['contributionTabLabel1'], vars['contributionTabNode1'])
    self:addTabWithLabel(TAB_TOTAL_REWARD, vars['contributionTabBtn2'], vars['contributionTabLabel2'], vars['contributionTabNode1'])
    self:addTabWithLabel(TAB_CURRENT, vars['contributionTabBtn3'], vars['contributionTabLabel3'], vars['contributionTabNode3'])

    self:setTab(TAB_TOTAL_REWARD)
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ClanRaidTabContribution:onChangeTab(tab, first)
    self.m_selected_tab = tab
    if (tab == TAB_TOTAL) then
        self:visibleContributeRank(false)

    elseif (tab == TAB_TOTAL_REWARD) then
        if (first) then
            self:initTableViewTotalRank()
        end
        self:visibleContributeRank(true)

    elseif (tab == TAB_CURRENT) then
        if (first) then
            self:initTableViewCurrentRank()
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidTabContribution:refresh()
end

-------------------------------------
-- function initTableViewTotalRank
-- @brief 누적 기여도
-------------------------------------
function UI_ClanRaidTabContribution:initTableViewTotalRank()
    local vars = self.m_owner_ui.vars
    local struct_raid = g_clanRaidData:getClanRaidStruct()

    local node = vars['contributionTabNode1']
    node:removeAllChildren()

    -- cell size 정의
	local width = node:getContentSize()['width']
	local height = 50 + 2

    local create_func = function(ui, data)
        local is_reward = (self.m_selected_tab == TAB_TOTAL_REWARD)
        ui.vars['damageLabel']:setVisible(not is_reward)
        ui.vars['rewardNode']:setVisible(is_reward)
    end

    -- 테이블 뷰 인스턴스 생성
    local l_rank_list = g_clanRaidData:getRankList()
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(width, height)
    table_view:setCellUIClass(self.makeTotalRankCell, create_func)
	table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_rank_list)
    self.m_contribution_table_view = table_view
    local msg = Str('참여한 유저가 없습니다.')
    table_view:makeDefaultEmptyDescLabel(msg)

    local user_rank = 1
    for i,data in ipairs(l_rank_list) do
        if (data['m_uid'] == g_userData:get('uid')) then
            user_rank = i
        end
    end
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view:relocateContainerFromIndex(user_rank)
end

-------------------------------------
-- function visibleContributeRank
-- @breif 누적 기여도 보상/점수 구분
-------------------------------------
function UI_ClanRaidTabContribution:visibleContributeRank(is_reward)

    local l_rank_list = g_clanRaidData:getRankList()
    for key, v in ipairs(l_rank_list) do
        local t_data = self.m_contribution_table_view:getItem(key)
        if (t_data) and (t_data['ui']) then
            t_data['ui'].vars['rewardNode']:setVisible(is_reward)
            t_data['ui'].vars['damageLabel']:setVisible(not is_reward)
        end
    end
end

-------------------------------------
-- function initTableViewCurrentRank
-- @brief 현재 기여도
-------------------------------------
function UI_ClanRaidTabContribution:initTableViewCurrentRank()
    local vars = self.m_owner_ui.vars
    local struct_raid = g_clanRaidData:getClanRaidStruct()

    local node = vars['contributionTabNode3']
    node:removeAllChildren()

    -- cell size 정의
	local width = node:getContentSize()['width']
	local height = 50 + 2

    local create_func = function(ui, data)
        ui.vars['damageLabel']:setVisible(true)
        ui.vars['rewardNode']:setVisible(false)
    end
    
    -- 테이블 뷰 인스턴스 생성
    local l_rank_list = struct_raid:getRankList()
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(width, height)
    table_view:setCellUIClass(self.makeTotalRankCell, create_func)
	table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_rank_list)

    local msg = Str('참여한 유저가 없습니다.')
    table_view:makeDefaultEmptyDescLabel(msg)

    local user_rank = 1
    for i,data in ipairs(l_rank_list) do
        if (data['m_uid'] == g_userData:get('uid')) then
            user_rank = i
        end
    end
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view:relocateContainerFromIndex(idx)
end

-------------------------------------
-- function makeTotalRankCell
-------------------------------------
function UI_ClanRaidTabContribution.makeTotalRankCell(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('clan_raid_scene_item_01.ui')
    if (not t_data) then
        return ui
    end

    local t_rank_info = t_data

    -- 보상 기여도
    vars['rewardPercentLabel']:setString(t_rank_info:getRewardContributionText())

    -- 보상받을 클랜코인
    vars['rewardLabel']:setString(t_rank_info:getRewardText())

    -- 점수 표시
    vars['damageLabel']:setString(t_rank_info:getScoreText())

    -- 유저 정보 표시 
    vars['levelLabel']:setString(t_rank_info:getLvText())
    vars['nameLabel']:setString(t_rank_info:getUserText())

    -- 기여도 
    vars['percentLabel']:setString(t_rank_info:getContributionText())

    -- 순위  
    local rank = t_rank_info.m_rank
    vars['rankNode']:removeAllChildren()

    if (rank <= 3) then
        vars['rankLabel']:setString('')
        local path = string.format('res/ui/icons/rank/clan_raid_02%02d.png', rank)
        local icon = cc.Sprite:create(path)

        if (icon) then
            icon:setAnchorPoint(ZERO_POINT)
            icon:setDockPoint(ZERO_POINT)
            vars['rankNode']:addChild(icon)
        end
    else
        vars['rankLabel']:setString(t_rank_info:getRankText())
    end

    do -- 내 순위 UI일 경우
        local uid = g_userData:get('uid')
        local is_my_rank = t_rank_info['m_uid'] == g_userData:get('uid')
        vars['meSprite']:setVisible(is_my_rank)
    end
    return ui
end

-------------------------------------
-- function makeTotalRewardCell
-------------------------------------
function UI_ClanRaidTabContribution.makeTotalRewardCell(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('clan_raid_scene_item_02.ui')
    if (not t_data) then
        return ui
    end

    local t_rank_info = t_data

    -- 유저 정보 표시 
    vars['levelLabel']:setString(t_rank_info:getLvText())
    vars['nameLabel']:setString(t_rank_info:getUserText())

    -- 기여도 
    vars['percentLabel']:setString(t_rank_info:getContributionText())

    -- 보상 기여도
    vars['rewardPercentLabel']:setString(t_rank_info:getRewardContributionText())

    -- 보상받을 클랜코인
    vars['rewardLabel']:setString(t_rank_info:getRewardText())

    -- 순위  
    local rank = t_rank_info.m_rank
    vars['rankNode']:removeAllChildren()

    if (rank <= 3) then
        vars['rankLabel']:setString('')
        local path = string.format('res/ui/icons/rank/clan_raid_02%02d.png', rank)
        local icon = cc.Sprite:create(path)

        if (icon) then
            icon:setAnchorPoint(ZERO_POINT)
            icon:setDockPoint(ZERO_POINT)
            vars['rankNode']:addChild(icon)
        end
    else
        vars['rankLabel']:setString(t_rank_info:getRankText())
    end

    return ui
end

--@CHECK
UI:checkCompileError(UI_ClanRaidTabContribution)