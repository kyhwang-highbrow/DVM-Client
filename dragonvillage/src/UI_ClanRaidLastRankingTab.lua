
-------------------------------------
-- class UI_ClanRaidLastRankingTab
-------------------------------------
UI_ClanRaidLastRankingTab = class({
        m_rank_data = 'table',  -- 속성별 랭킹 데이터
        m_rankOffset = 'table', -- 속성별 offset
        m_vars = 'vars'
    })

local CLAN_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidLastRankingTab:init(vars)
    self.m_vars = vars

    -- 속성별 랭킹 기록/offset 초기화
    self.m_rank_data = {}
    self.m_rankOffset = {}
    local l_attr = getAttrTextList()
    for _, attr in ipairs(l_attr) do
        self.m_rank_data[attr] = {}
        self.m_rankOffset[attr] = 1
    end

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
    local l_attr = getAttrTextList()

    if (type == 'my') then
        for i, attr in pairs(l_attr) do
            self.m_rankOffset[attr] = -1
        end
    elseif (type == 'top') then
        for i, attr in pairs(l_attr) do
            self.m_rankOffset[attr] = 1
        end
    end
    self:request_clanAttrRank()
end

-------------------------------------
-- function request_clanRank
-------------------------------------
function UI_ClanRaidLastRankingTab:request_clanAttrRank(selected_attr)
    local attr_type = selected_attr
    local cb_func = function(ret)
        self:applyAttrRankData(ret)

        if (attr_type == 'all') then
            local l_attr = getAttrTextList()
            for i, attr in ipairs(l_attr) do
                self:makeAttrTableView(attr)
            end
            -- 전체 세팅할 때, 각 테이블이 비었는지 확인
            self:checkEmptyRank()
        else
            self:makeAttrTableView(selected_attr)
        end
    end  
    if (not selected_attr) then
        attr_type = 'all'
        selected_attr = 'earth'
    end

    g_clanRaidData:requestAttrRankList(attr_type, self.m_rankOffset[selected_attr], cb_func)
end

-------------------------------------
-- function applyAttrRankData
-- @brief 서버에서 받은 속성별 랭킹정보를 key = 속성인 맵으로 변환
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
-- function checkEmptyRank
-- @brief 서버에서 랭킹값을 주지 않았을 경우 ui 세팅
-------------------------------------
function UI_ClanRaidLastRankingTab:checkEmptyRank()
    local vars = self.m_vars
    local l_rank_data = self.m_rank_data
    local m_attr = getAttrOrderMap()
    
    for attr, t_data in pairs(l_rank_data) do
        local empty_node = vars[string.format('attr%dNotRankNode', m_attr[attr])]
        local l_data = t_data['list']
        if (l_data == nil) then
            empty_node:setVisible(true)
        else
            empty_node:setVisible(false)
        end
    end
end

-------------------------------------
-- function makeAttrTableView
-- @brief 속성 랭킹 테이블 뷰 생성
-------------------------------------
function UI_ClanRaidLastRankingTab:makeAttrTableView(attr)
    local l_attr = getAttrTextList()
    local map_attr = getAttrOrderMap()
    local attr_node_str = string.format('attr%dListNode', map_attr[attr])
    local node = self.m_vars[attr_node_str]
    node:removeAllChildren()

    local l_item_list = self.m_rank_data[attr]['list']
    if (not l_item_list) then
        l_item_list = {}
    end

    -- 다음/이전 버튼 관련 세팅, 정리해야함
    do
        if (1 < self.m_rankOffset[attr]) then
            local prev_data = { m_tag = 'prev' }
            table.insert(l_item_list, 1, prev_data)
        end

        if (#l_item_list > 0) then
            local next_data = { m_tag = 'next' }
            table.insert(l_item_list, next_data)
        end

        -- 이전 랭킹 보기
        local click_prevBtn = function()
            self.m_rankOffset[attr] = self.m_rankOffset[attr] - CLAN_OFFSET_GAP
            self.m_rankOffset[attr] = math_max(self.m_rankOffset[attr], 0)
            self:request_clanAttrRank(attr)
        end

        -- 다음 랭킹 보기
        local click_nextBtn = function()
            local add_offset = #l_item_list
            if (add_offset < CLAN_OFFSET_GAP) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
                return
            end
            self.m_rankOffset[attr] = self.m_rankOffset[attr] + add_offset
            self:request_clanAttrRank(attr)
        end


        -- 생성 콜백
        local function create_func(ui, data)
            ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
            ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
            if (data['id'] == self.m_rank_data[attr]['my_claninfo']['id']) then
                ui.vars['meSprite']:setVisible(true)
            end
        end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(245, 80+5)
        table_view:setCellUIClass(self.makeAttrRankListItem, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_item_list, true)
        --self.m_rewardTableView = table_view
        table_view:makeDefaultEmptyDescLabel(Str(''))

        -- 포커싱
        local idx = nil
        for i,v in pairs(l_item_list) do
            if (v['id'] == self.m_rank_data[attr]['my_claninfo']['id']) then
                idx = i
                break
            end
        end

        if idx then
            table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
            table_view:relocateContainerFromIndex(idx)
        end
    end
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
    
    local tag = t_data['m_tag']
    -- 다음 랭킹 보기 
    if (tag == 'next') then
        vars['nextBtn']:setVisible(true)
        vars['itemMenu']:setVisible(false)
        return ui
    end

    -- 이전 랭킹 보기 
    if (tag == 'prev') then
        vars['prevBtn']:setVisible(true)
        vars['itemMenu']:setVisible(false)
        return ui
    end

    -- 클랜 이름
    vars['clanLabel']:setString(Str(t_data['name']))
    
    -- 점수 출력
    local score_str = comma_value(tonumber(t_data['score']))
    vars['scoreLabel']:setString(Str('{1}점', score_str))
    
    -- 클랜 랭크
    vars['rankLabel']:setString(t_data['rank'])
    
    -- 클리어한 보스 레벨
    vars['bossLabel']:setString('Lv.' ..t_data['cdlv'])

    -- 마크 정보
    local struct_mark = StructClanMark:create(t_data['mark'])
    local mark_icon = struct_mark:makeClanMarkIcon()
    vars['markNode']:addChild(mark_icon)
    return ui
end

--@CHECK
UI:checkCompileError(UI_ClanRaidLastRankingTab)

