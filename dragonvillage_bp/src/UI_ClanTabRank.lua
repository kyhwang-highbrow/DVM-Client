local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanTabRank
-- @brief 클랜 랭킹 탭
-------------------------------------
UI_ClanTabRank = class(PARENT,{
        vars = '',
        m_mTableViewMap = 'Map<string, UIC_TableView>',
        m_mOffsetMap = 'number',
    })

UI_ClanTabRank.TAB_ANCT = CLAN_RANK['ANCT']
UI_ClanTabRank.TAB_CLSM = CLAN_RANK['CLSM']

local CLAN_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_ClanTabRank:init(owner_ui)
    self.root = owner_ui.vars['rankMenu']
    self.vars = owner_ui.vars
    self.m_mTableViewMap = {}
    self.m_mOffsetMap = {}
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_ClanTabRank:onEnterTab(first)
    if first then
        self:initUI()
        self:initTab()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_ClanTabRank:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanTabRank:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanTabRank:initTab()
    local vars = self.vars
    local tab_list = {CLAN_RANK['ANCT'], CLAN_RANK['CLSM']}

    for i, tab in ipairs(tab_list) do
        self:addTabAuto(tab, vars, vars[tab .. 'Node'])
    end

    self:setTab(CLAN_RANK['ANCT'])
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ClanTabRank:onChangeTab(tab, first)
    if (first) then
        self.m_mOffsetMap[tab] = 1
        self:request_clanRank(first)

    else
        self:makeMyRank(tab)

    end
end

-------------------------------------
-- function request_clanRank
-------------------------------------
function UI_ClanTabRank:request_clanRank(first)
    local rank_type = self.m_currTab
    local offset = self.m_mOffsetMap[rank_type]
    local cb_func = function()
        if (first) then
            self:makeMyRank(rank_type)
        end
        self:makeRankTableview(rank_type)
    end
    g_clanRankData:request_getRank(rank_type, offset, cb_func)
end

-------------------------------------
-- function makeTableViewRanking
-------------------------------------
function UI_ClanTabRank:makeRankTableview(tab)
	local t_tab_data = self.m_mTabData[tab]
	local node = t_tab_data['tab_node_list'][1]
	local l_rank_list = g_clanRankData:getRankData(tab)

    -- 이전 보기 추가
    if (1 < self.m_mOffsetMap[tab]) then
        l_rank_list['prev'] = 'prev'
    end

    -- 다음 보기 추가.. 
    if (#l_rank_list > 0) then
        l_rank_list['next'] = 'next'
    end
        
    -- 이전 랭킹 보기
    local function click_prevBtn()
        self.m_mOffsetMap[tab] = math_max(self.m_mOffsetMap[tab] - CLAN_OFFSET_GAP, 1)
        self:request_clanRank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        if (table.count(l_rank_list) < CLAN_OFFSET_GAP) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end
        self.m_mOffsetMap[tab] = self.m_mOffsetMap[tab] + CLAN_OFFSET_GAP
        self:request_clanRank()
    end

    -- 생성 콜백
    local function create_func(ui, data)
        if (data == 'prev') then
            ui.vars['prevBtn']:setVisible(true)
            ui.vars['itemMenu']:setVisible(false)
            ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
        elseif (data == 'next') then
            ui.vars['nextBtn']:setVisible(true)
            ui.vars['itemMenu']:setVisible(false)
            ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
        end
    end

	do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(1000, 100 + 5)
        table_view:setCellUIClass(UI_ClanTabRank.makeRankCell, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_rank_list)

        do-- 테이블 뷰 정렬
            local function sort_func(a, b)
                local a_data = a['data']
                local b_data = b['data']

                -- 이전, 다음 버튼 정렬
                if (a_data == 'prev') then
                    return true
                elseif (b_data == 'prev') then
                    return false
                elseif (a_data == 'next') then
                    return false
                elseif (b_data == 'next') then
                    return true
                end

                -- 랭킹으로 선별
                local a_rank = a_data:getRank()
                local b_rank = b_data:getRank()
                return a_rank < b_rank
            end

            table.sort(table_view.m_itemList, sort_func)
        end

        -- 정산 문구 분기
        local empty_str
        if (g_clanRankData:isSettlingDown()) then
            empty_str = Str('현재 클랜 순위를 정산 중입니다. 잠시만 기다려주세요.')
        else
            empty_str = Str('최초 순위는 자정 이후 집계됩니다.')
        end
        table_view:makeDefaultEmptyDescLabel(empty_str)
        self.m_mTableViewMap[tab] = table_view
    end
end

-------------------------------------
-- function makeMyRank
-------------------------------------
function UI_ClanTabRank:makeMyRank(tab)
    local node = self.vars['myNode']
    node:removeAllChildren()
    local my_rank = g_clanRankData:getMyRankData(tab)
    local ui = self.makeRankCell(my_rank)
    node:addChild(ui.root)
end

-------------------------------------
-- function makeRankCell
-------------------------------------
function UI_ClanTabRank.makeRankCell(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('clan_rank_item.ui')
    if (not t_data) then
        return ui
    end
    if (t_data == 'next') then
        return ui
    end
    if (t_data == 'prev') then
        return ui
    end

    local struct_clan_rank = t_data

    -- 클랜 마크
    local icon = struct_clan_rank:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan_rank:getClanName()
    vars['clanLabel']:setString(clan_name)

    -- 클랜 마스터
    local clan_master = struct_clan_rank:getMasterNick()
    vars['masterLabel']:setString(clan_master)

    -- 점수
    local clan_score = struct_clan_rank:getClanScore()
    vars['scoreLabel']:setString(clan_score)
    
    -- 등수 
    local clan_rank = struct_clan_rank:getClanRank()
    vars['rankLabel']:setString(clan_rank)
    
    -- 내클랜
    if (struct_clan_rank:isMyClan()) then
        vars['mySprite']:setVisible(true)
        vars['infoBtn']:setVisible(false)
    end

    -- 정보 보기 버튼
    vars['infoBtn']:registerScriptTapHandler(function()
        local clan_object_id = struct_clan_rank:getClanObjectID()
        g_clanData:requestClanInfoDetailPopup(clan_object_id)
    end)

	return ui
end