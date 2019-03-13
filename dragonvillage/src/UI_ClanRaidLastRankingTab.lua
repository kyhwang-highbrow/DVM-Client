
-------------------------------------
-- class UI_ClanRaidLastRankingTab
-------------------------------------
UI_ClanRaidLastRankingTab = class({
        m_rank_data = 'table',
        m_rankOffset = 'number',
        m_selected_attr = 'string',
        m_vars = 'vars'
    })

local CLAN_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidLastRankingTab:init(vars)
    self.m_vars = vars
    self.m_rankOffset = CLAN_OFFSET_GAP
    self.m_selected_attr = 'all'

    -- 속성별 랭킹 기록 초기화
    self.m_rank_data = {}
    local l_attr = getAttrTextList()
    for _, attr in ipairs(l_attr) do
        self.m_rank_data[attr] = {}   
    end

    self.m_rank_data['earth'] = {}
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidLastRankingTab:initUI()
    local vars = self.m_vars
    self:make_UIC_SortList()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidLastRankingTab:initButton()
    local vars = self.m_vars

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidLastRankingTab:refresh()
    local vars = self.m_vars
end

-------------------------------------
-- function make_UIC_SortList
-- @brief
-------------------------------------
function UI_ClanRaidLastRankingTab:make_UIC_SortList()
    local vars = self.m_vars
    local button = vars['rankBtn']
    local label = vars['rankLabel']

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


    uic:addSortType('my', Str('내 클랜 랭킹'))
    uic:addSortType('top', Str('최상위 클랜 랭킹'))

    uic:setSortChangeCB(function(sort_type) self:onChangeRankingType(sort_type) end)
    uic:setSelectSortType('my')
end

-------------------------------------
-- function onChangeRankingType
-- @brief
-------------------------------------
function UI_ClanRaidLastRankingTab:onChangeRankingType(type)

    if (type == 'my') then
        self.m_rankOffset = -1

    elseif (type == 'top') then
        self.m_rankOffset = 1
    end
    self:request_clanAttrRank()
end

-------------------------------------
-- function request_clanRank
-------------------------------------
function UI_ClanRaidLastRankingTab:request_clanAttrRank()
    local selected_attr = self.m_selected_attr
    local cb_func = function(ret)
        self:applyAttrRankData(ret)

        if (selected_attr == 'all') then
            local l_attr = getAttrTextList()
            for i, attr in ipairs(l_attr) do
                self:makeAttrTableView(attr)
            end
        else
            self:makeAttrTableView(selected_attr)
        end
    end 
    g_clanRaidData:requestAttrRankList(self.m_rankOffset, cb_func)
end

-------------------------------------
-- function applyAttrRankData
-------------------------------------
function UI_ClanRaidLastRankingTab:applyAttrRankData(ret)
    local l_attr = getAttrTextList()

    for i, attr in ipairs(l_attr) do
        if (ret[attr ..'_Rankinfo']) then
            self.m_rank_data[attr] = {}
            self.m_rank_data[attr] = ret[attr..'_Rankinfo']
        end
    end

end

-------------------------------------
-- function makeAttrTableView
-- @brief 보상 정보 테이블 뷰 생성
-------------------------------------
function UI_ClanRaidLastRankingTab:makeAttrTableView(attr)
    local l_attr = getAttrTextList()
    local map_attr = getAttrOrderMap()
    local attr_node_str = string.format('attr%dListNode', map_attr[attr])
    local node = self.m_vars[attr_node_str]

    local l_item_list = self.m_rank_data[attr]['list']
    if (not l_item_list) then
        l_item_list = {}
    end
    
    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(245, 80+5)
    table_view:setCellUIClass(self.makeAttrRankListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list, true)
    --self.m_rewardTableView = table_view
    
    table_view:makeDefaultEmptyDescLabel(Str('랭킹 정보가 없습니다.'))
end

-------------------------------------
-- function makeAttrRankListItem
-------------------------------------
function UI_ClanRaidLastRankingTab.makeAttrRankListItem(t_data)
    local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('clan_raid_rank_popup_item_02.ui')
    if (not t_data) then
        return ui
    end
    
    vars['clanLabel']:setString(Str(t_data['name']))
    vars['scoreLabel']:setString(t_data['score'])
    vars['rankLabel']:setString(t_data['rank'])
    vars['bossLabel']:setString('Lv.' ..t_data['cdlv'])

    -- 마크 정보
    local struct_mark = StructClanMark:create(t_data['mark'])
    local mark_icon = struct_mark:makeClanMarkIcon()
    vars['markNode']:addChild(mark_icon)
    return ui
end

--@CHECK
UI:checkCompileError(UI_ClanRaidLastRankingTab)

