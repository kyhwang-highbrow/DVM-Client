local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventDealkingRankingAttributeTab
-------------------------------------
UI_EventDealkingRankingAttributeTab = class(PARENT,{
        m_ownerUI = 'UI_EventIncarnationOfSinsRankingPopup', -- 현재 검색 타입에 대해 받아올 때 필요
        m_searchType = 'string', -- 검색 타입 (world, clan, friend)
        m_bossType = 'number', -- 보스 타입 (0 전체, 1 단일, 2 다중)

        ------------------------------------------------
        m_tRankData = 'table', -- 각 속성별 랭크 정보
        m_tRankOffset = 'table', -- 각 속성별 오프셋
        ------------------------------------------------
    })

local SCORE_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_EventDealkingRankingAttributeTab:init(owner_ui)
    local vars = self:load('event_dealking_rank_popup_attr.ui')
    
    self.m_ownerUI = owner_ui
    self.m_searchType = owner_ui.m_rankType
    self.m_bossType = owner_ui.m_bossType
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
function UI_EventDealkingRankingAttributeTab:onEnterTab(first)
    if (first == true) then
        self:initUI()
        self:initButton()
        self.m_searchType = self.m_ownerUI.m_rankType
        self:refreshRank(self.m_searchType)
        self:refresh()
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventDealkingRankingAttributeTab:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventDealkingRankingAttributeTab:initButton()
    local vars = self.vars
end

-------------------------------------
-- function request_EventDealkingAttrRanking
-------------------------------------
function UI_EventDealkingRankingAttributeTab:request_EventDealkingAttrRanking(attr_type)
    local attr_type = attr_type or 'all'
    
    local function success_cb(ret)

        -- 밑바닥 유저를 위한 예외처리
        -- 마침 현재 페이지에 20명이 차있어서 다음 페이지 버튼 클릭이 가능한 상태
        -- 전체리스트 요청한것이 아니라면
        -- 요청한 속성에 저장된 오프셋이 1보다 큰 값을 가질 때, 
        -- 내 랭킹 조회 혹은 페이징을 통한 행위가 있었다고 판단
        if (attr_type ~= 'all') then
            if (self.m_tRankOffset[attr_type] and self.m_tRankOffset[attr_type] > 1) then
                -- 랭킹 리스트가 비어있는지 확인한다
                local l_rank_list = ret[attr_type .. '_list'] or {}

                -- 비어있으면 리스트 업뎃을 안하고 팝업만 띄워주자
                if (l_rank_list and #l_rank_list <= 0) then
                    MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
                    return
                end   
            end
                 
        end

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
    
    local offset
    if (attr_type == 'all') then
        offset = self.m_tRankOffset['earth']
    else
        offset = self.m_tRankOffset[attr_type]
    end

    --local search_type = self.m_searchType
    -- my 와 top 은 모두 world 로 요청한다.
    local search_type = (self.m_searchType == 'top' or self.m_searchType == 'my') and 'world' or self.m_searchType
    local limit = SCORE_OFFSET_GAP

    g_eventDealkingData:request_EventDealkingRanking(self.m_bossType, attr_type, search_type, offset, limit, success_cb, nil)
end

-------------------------------------
-- function applyAttrRankData
-- @brief 서버에서 받은 속성별 랭킹정보를 key = 속성인 맵으로 변환
-------------------------------------
function UI_EventDealkingRankingAttributeTab:applyAttrRankData(ret)
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
function UI_EventDealkingRankingAttributeTab:checkEmptyRank()
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
function UI_EventDealkingRankingAttributeTab:refresh()
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
function UI_EventDealkingRankingAttributeTab:makeAttrTableView(attr)
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
            -- 내가 밑바닥 랭커에 해당 될 때 다음 페이지에 아무도 없을 수 있다.
            -- 리스트가 존재하고 리스트 요소가 1개 이상일 때에는 1인덱스 랭커기준으로 오프셋 세팅
            if (self.m_tRankData[attr] and #self.m_tRankData[attr] > 0) then
                -- 랭킹 리스트 중 가장 첫 번째 랭킹 - SCORE_OFFSET_GAP 부터 랭킹 데이터 가져옴
                self.m_tRankOffset[attr] = self.m_tRankData[attr][1]['rank'] - SCORE_OFFSET_GAP
            else
                -- 참조할 랭킹이 없기 때문에 offset 정보에서 덜어내서 계산한다.
                self.m_tRankOffset[attr] = self.m_tRankOffset[attr] - SCORE_OFFSET_GAP
            end

            -- offset이 마이너스값을 가지는것을 방지한다
            -- -1값을 가지게 되면 내 랭킹을 불러온다.
            self.m_tRankOffset[attr] = math_max(self.m_tRankOffset[attr], 0)
            self:request_EventDealkingAttrRanking(attr)
        end
        
        -- 다음 랭킹 보기
        local click_nextBtn = function()
            -- 랭킹 리스트 중 가장 마지막 랭킹 + 1 부터 랭킹 데이터 가져옴
            --local cnt = table.count(self.m_tRankData[attr])

            -- 테이블에 20개가 들어가 있는데 cnt가 이전, 다음 버튼을 포함한 22, 21이라는 값을 가진다.
            -- 정확히 테이블, 리스트에 값을 받을려면 #을 쓰는게 안전해 보임.
            --if (cnt < SCORE_OFFSET_GAP - 1) then

            -- 랭킹데이터가 20개와 다른 값을 가지면 끝자락에 닿았다고 판단.
            if (#self.m_tRankData[attr] ~= SCORE_OFFSET_GAP) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
                return
            end
           
            -- local next_idx = self.m_tRankData[attr][cnt - 1]['rank']
            -- 위에서 직접 아이템 조회로 계산 할 때 2페이지부터 인덱스가 꼬이는 현상이 발생.
            -- 서버 리스폰스의 offset도 믿을만 한 정보니 서버 offset정보에 offset gap을 더해서 인덱싱하자.
            -- 인덱싱이 이미 1부터 시작하기 때문에 +1을 할 필요가 없다.
            local next_idx = self.m_tRankOffset[attr] + SCORE_OFFSET_GAP

            -- 여긴 대입만
            self.m_tRankOffset[attr] = next_idx
            self:request_EventDealkingAttrRanking(attr)
        end

        local uid = g_userData:get('uid')
        -- 생성 콜백
        local function create_func(ui, data)
            ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
            ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
            if (data['uid'] == uid) then
                ui.vars['meSprite']:setVisible(true)
            end
            
            ui.vars['bossLabel']:setVisible(false)
        end
       
        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(245, 80+5)
        table_view:setCellUIClass(UI_EventDealkingRankingAttributeTabListItem, create_func)
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
function UI_EventDealkingRankingAttributeTab:refreshRank(type)
    local offset = (type == 'top') and 0 or -1
    -- self.m_searchType 은 메인 팝업과 비교하기 위해 똑같이 세팅해야 한다.
    --local type = (type == 'top' or type == 'my') and 'world' or type

    self.m_searchType = type

    for attr, attr_offset in pairs(self.m_tRankOffset) do
        self.m_tRankOffset[attr] =  offset
    end

    self:request_EventDealkingAttrRanking('all')
end


-- tableview cell class
local CELL_PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_EventDealkingRankingAttributeTabListItem
-------------------------------------
UI_EventDealkingRankingAttributeTabListItem = class(CELL_PARENT,{
        m_tData = 'table',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventDealkingRankingAttributeTabListItem:init(t_data)
    local vars = self:load('event_incarnation_of_sins_rank_popup_attr_item_01.ui')
    self.m_tData = t_data

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventDealkingRankingAttributeTabListItem:initUI()
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

    local t_rank_info = StructUserInfoArena:create_forRanking(t_data)

    -- 점수 표시
    vars['scoreLabel']:setString(tostring(comma_value(t_data['score'])))

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['userLabel']:setString(t_data['nick'])

    -- 순위 표시
    vars['rankLabel']:setString(tostring(comma_value(t_data['rank'])))

    do -- 리더 드래곤 아이콘
        local ui = t_rank_info:getLeaderDragonCard()
        if ui then
            ui.root:setSwallowTouch(false)
            vars['profileNode']:addChild(ui.root)
            
			ui.vars['clickBtn']:registerScriptTapHandler(function() 
				local is_visit = true
				UI_UserInfoDetailPopup:open(t_rank_info, is_visit, nil)
			end)
        end
    end

    local struct_clan = t_rank_info:getStructClan()
    if (struct_clan) then
        -- 클랜 이름
        local clan_name = struct_clan:getClanName()
        vars['clanLabel']:setString(clan_name)
        
        -- 클랜 마크
        local icon = struct_clan:makeClanMarkIcon()
        if (icon) then
            vars['markNode']:addChild(icon)
        end
    else
        vars['clanLabel']:setVisible(false)
    end

    vars['itemMenu']:setSwallowTouch(false)
end