local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventIncarnationOfSinsRankingAttributeTab
-------------------------------------
UI_EventIncarnationOfSinsRankingAttributeTab = class(PARENT,{
        m_ownerUI = 'UI_EventIncarnationOfSinsRankingPopup', -- 현재 검색 타입에 대해 받아올 때 필요
        m_searchType = 'string', -- 검색 타입 (world, clan, friend)
        ------------------------------------------------
        m_tRankData = 'table', -- 각 속성별 랭크 정보
        m_tRankOffset = 'table', -- 각 속성별 오프셋
        ------------------------------------------------
    })

local SCORE_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingAttributeTab:init(owner_ui)
    local vars = self:load('event_incarnation_of_sins_rank_popup_attr.ui')
    
    self.m_ownerUI = owner_ui
    self.m_searchType = owner_ui.m_rankType
    self.m_tRankData = {}
    self.m_tRankOffset = {}

    local l_attr = getAttrTextList()
    for _, attr in ipairs(l_attr) do
        self.m_tRankData[attr] = {}
        self.m_tRankOffset[attr] = -1
    end
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventIncarnationOfSinsRankingAttributeTab:onEnterTab(first)
    if (first == true) then
        self:initUI()
        self:initButton()
        self.m_searchType = self.m_ownerUI.m_rankType
        self:request_EventIncarnationOfSinsAttrRanking('all')
        self:refresh()
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsRankingAttributeTab:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSinsRankingAttributeTab:initButton()
    local vars = self.vars
end

-------------------------------------
-- function request_EventIncarnationOfSinsAttrRanking
-------------------------------------
function UI_EventIncarnationOfSinsRankingAttributeTab:request_EventIncarnationOfSinsAttrRanking(attr_type)
    local attr_type = attr_type or 'all'
    
    local function success_cb(ret)
        self:applyAttrRankData(ret)

        if (attr_type == 'all') then
            local l_attr = getAttrTextList()
            for i, attr in ipairs(l_attr) do
                self:makeAttrTableView(attr)
            end
            -- 전체 세팅할 때, 각 테이블이 비었는지 확인
            self:checkEmptyRank()
        else
            self:makeAttrTableView(attr_type)
        end
    end  
    
    local function fail_cb(ret)
    end

    local offset
    if (attr_type == 'all') then
        offset = self.m_tRankOffset['earth']
    else
        offset = self.m_tRankOffset[attr_type]
    end

    local search_type = self.m_searchType
    local limit = SCORE_OFFSET_GAP

    g_eventIncarnationOfSinsData:request_EventIncarnationOfSinsAttrRanking(attr_type, search_type, offset, limit, success_cb, fail_cb)
end

-------------------------------------
-- function applyAttrRankData
-- @brief 서버에서 받은 속성별 랭킹정보를 key = 속성인 맵으로 변환
-------------------------------------
function UI_EventIncarnationOfSinsRankingAttributeTab:applyAttrRankData(ret)
    local l_attr = getAttrTextList()

    for i, attr in ipairs(l_attr) do
        if (ret[attr ..'_list']) then
            self.m_tRankData[attr] = ret[attr..'_list']
        end
         if (ret[attr ..'_offset']) then
            self.m_tRankOffset[attr] = tonumber(ret[attr..'_offset'])
        end
    end
end

-------------------------------------
-- function checkEmptyRank
-- @brief 서버에서 랭킹값을 주지 않았을 경우 ui 세팅
-------------------------------------
function UI_EventIncarnationOfSinsRankingAttributeTab:checkEmptyRank()
    local vars = self.vars
    local t_rank_data = self.m_tRankData
    local m_attr = getAttrOrderMap()
    
    for attr, t_data in pairs(t_rank_data) do
        local empty_node = vars[string.format('attr%dNotRankNode', m_attr[attr])]
        local size = table.count(t_data)
        if (size == 0) then
            empty_node:setVisible(true)
        else
            empty_node:setVisible(false)
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSinsRankingAttributeTab:refresh()
    local vars = self.vars

    local l_attr = getAttrTextList()
    for idx, attr in ipairs(l_attr) do
        self:makeAttrTableView(attr)
    end
end

-------------------------------------
-- function makeAttrTableView
-- @brief 속성 랭킹 테이블 뷰 생성
-------------------------------------
function UI_EventIncarnationOfSinsRankingAttributeTab:makeAttrTableView(attr)
    local map_attr = getAttrOrderMap()
    local attr_node_str = string.format('attr%dListNode', map_attr[attr])
    local node = self.vars[attr_node_str]
    node:removeAllChildren()

    local l_item_list = self.m_tRankData[attr]
    if (not l_item_list) then
        l_item_list = {}
    end

    if (self.m_tRankOffset[attr] == -1) then
        if (l_item_list[1]) then
            self.m_tRankOffset[attr] = l_item_list[1]['rank']
        end
    end

    -- 다음/이전 버튼 관련 세팅, 정리해야함
    do
        if (1 < self.m_tRankOffset[attr]) then
            local prev_data = { m_tag = 'prev' }
            l_item_list['prev'] = prev_data
        end

        if (#l_item_list > 0) then
            local next_data = { m_tag = 'next' }
            l_item_list['next'] = next_data
        end

        -- 이전 랭킹 보기
        local click_prevBtn = function()
            -- 랭킹 리스트 중 가장 첫 번째 랭킹 - SCORE_OFFSET_GAP 부터 랭킹 데이터 가져옴
            self.m_tRankOffset[attr] = self.m_tRankData[attr][1]['rank'] - SCORE_OFFSET_GAP
            self.m_tRankOffset[attr] = math_max(self.m_tRankOffset[attr], 0)
            self:request_EventIncarnationOfSinsAttrRanking(attr)
        end

        -- 다음 랭킹 보기
        local click_nextBtn = function()
            -- 랭킹 리스트 중 가장 마지막 랭킹 + 1 부터 랭킹 데이터 가져옴
            local cnt = table.count(self.m_tRankData[attr])
            if (cnt < SCORE_OFFSET_GAP - 1) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
                return
            end
           
            local next_idx = self.m_tRankData[attr][cnt]['rank']
            self.m_tRankOffset[attr] = next_idx + 1
            self:request_EventIncarnationOfSinsAttrRanking(attr)
        end

        local uid = g_userData:get('uid')
        -- 생성 콜백
        local function create_func(ui, data)
            ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
            ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
            if (data['uid'] == uid) then
                ui.vars['meSprite']:setVisible(true)
            end
            
            local last_lv = '-'
            if (data['cldg_last_info']) then
                last_lv = (data['cldg_last_info'][attr]['cldg_last_lv']) % 1000
                ui.vars['bossLabel']:setString('Lv.' .. last_lv)
            else
                ui.vars['bossLabel']:setString('-')
            end
            
            -- @jhakim 190409 개발은 해놓았지만 데이터가 모이지 않아 표시하지 않음
            -- 클리어한 보스 레벨          
            ui.vars['bossLabel']:setVisible(false)
            ui.vars['rankDifferentLabel']:setVisible(true)
            ui.vars['rankDifferentLabel']:setString('')

            if (data['cldg_last_info']) then
                if (data['cldg_last_info'][attr]['change_rank']) then
                    local rank_dis = tonumber(data['cldg_last_info'][attr]['change_rank'])
                    local rank_dis_str = descChangedValue(rank_dis)

                    ui.vars['rankDifferentLabel']:setString(rank_dis_str)
                end   
            end
        end
       
        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(245, 80+5)
        table_view:setCellUIClass(UI_EventIncarnationOfSinsRankingAttributeTabListItem, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_item_list, false)
        table_view:makeDefaultEmptyDescLabel(Str(''))

        do-- 테이블 뷰 정렬
            local function sort_func(a, b)
                local a_data = a['data']
                local b_data = b['data']

                -- 이전, 다음 버튼 정렬
                if (a_data.m_tag == 'prev') then
                    return true
                elseif (b_data.m_tag == 'prev') then
                    return false
                elseif (a_data.m_tag == 'next') then
                    return false
                elseif (b_data.m_tag == 'next') then
                    return true
                end

                -- 랭킹으로 선별
                local a_rank = a_data.rank
                local b_rank = b_data.rank
                return a_rank < b_rank
            end

            table.sort(table_view.m_itemList, sort_func)
        end


        -- 포커싱
        local idx = nil
        for i,v in pairs(l_item_list) do
            if (v['uid'] == uid) then
                idx = i
                break
            end
        end
        
        -- 최상위 랭킹 필터일 때는 1위에 포커싱
        if (self.m_tRankOffset[attr] == 1) then
            idx = 1
        end

        if idx then
            table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
            table_view:relocateContainerFromIndex(idx)
        end
    end
end

-------------------------------------
-- function refreshRank
-- @brief 랭크 범위가 바뀐 경우 UI_EventIncarnationOfSinsRankingPopup에서 호출함
-------------------------------------
function UI_EventIncarnationOfSinsRankingAttributeTab:refreshRank(type)
    local type = (type == 'top' or type == 'my') and 'world' or type
    local offset = (type == 'top') and 1 or -1

    self.m_searchType = type

    for attr, attr_offset in pairs(self.m_tRankOffset) do
        attr_offset = offset
    end

    self:request_EventIncarnationOfSinsAttrRanking('all')
end


-- tableview cell class
local CELL_PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_EventIncarnationOfSinsRankingAttributeTabListItem
-------------------------------------
UI_EventIncarnationOfSinsRankingAttributeTabListItem = class(CELL_PARENT,{
        m_tData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingAttributeTabListItem:init(t_data)
    local vars = self:load('event_incarnation_of_sins_rank_popup_attr_item_01.ui')
    self.m_tData = t_data

    self:initUI()
end



-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsRankingAttributeTabListItem:initUI()
    local vars = self.vars
    local t_data = self.m_tData

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

    -- 유저 닉네임
    vars['clanLabel']:setString(Str(t_data['nick']))
    
    -- 점수 출력
    local score_str = comma_value(tonumber(t_data['score']))
    vars['scoreLabel']:setString(Str('{1}점', score_str))
    
    -- 유저 랭크
    vars['rankLabel']:setString(tostring(t_data['rank']))

    -- 마크 정보
    if ((t_data['clan_info']) and (t_data['clan_info']['mark'])) then
        local struct_mark = StructClanMark:create(t_data['clan_info']['mark'])
        local mark_icon = struct_mark:makeClanMarkIcon()
        vars['markNode']:addChild(mark_icon)
    end
end