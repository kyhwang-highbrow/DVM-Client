-------------------------------------
-- class UIC_RankingList
-------------------------------------
UIC_RankingList = class({
        m_cellUIClass = 'class',
        m_cellUICreateCB = 'function',
        m_itemList = 'list',
        m_rankTableView = 'UIC_TableView',
        m_offset = 'number',
        m_offsetGap = 'number',
        m_emptyMsg = 'string',
        m_prevCb = 'function',
        m_nextCb = 'function',
        m_makeMyRankCb = 'function',

    })

-------------------------------------------------------

-- UIC_RankingList 사용 예시(순서 지켜야함)

-- local rank_list = UIC_RankingList()                                 -- step0. (필수)랭킹 UI 컴포넌트 생성
-- rank_list:setRankUIClass(UI_ArenaRankingListItem, create_cb)        -- step1. (필수)셸 UI 설정
-- rank_list:setRankList(l_rank_list)                                  -- step2. (필수)리스트 설정
-- rank_list:setEmptyStr('랭킹 정보가 없습니다')                       -- step3. (선택)랭킹이 없을 때, 메세지 설정
-- rank_list:setMyRank(make_my_rank_cb)                                -- step4. (선택)내 랭킹 만드는 콜백 함수
-- rank_list:setOffset(self.m_rankOffset)                              -- step5. (선택)몇 랭킹부터 보여줄 것인가 (1 이면 최상위 랭킹 부터, -1이면 내 랭킹 부터(내 랭킹 모를 때, 통신용))
-- rank_list:makeRankMoveBtn(func_prev_cb, func_next_cb, RANK_OFFSET_GAP)-- step6. (선택)이전, 다음 버튼 추가할 것인가 (param : (이전)눌렀을 때 콜백 함수, (다음)눌렀을 때 콜백 함수, 이동할 갯수)
-- rank_list:makeRankList(rank_node)                                   -- step7. (필수)실제로 랭킹 생성

-------------------------------------------------------

-------------------------------------
-- function init
-------------------------------------
function UIC_RankingList:init()
    self.m_offset = 1
    self.m_emptyMsg = ''
    self.m_offsetGap = 20
end

-------------------------------------
-- function setRankUIClass
-------------------------------------
function UIC_RankingList:setRankUIClass(ui_class, ui_create_cb)
    self.m_cellUIClass = ui_class
    self.m_cellUICreateCB = ui_create_cb
end

-------------------------------------
-- function setRankList
-------------------------------------
function UIC_RankingList:setRankList(list)
    self.m_itemList = list
end

-------------------------------------
-- function setOffset
-------------------------------------
function UIC_RankingList:setOffset(offset)
    self.m_offset = offset
end

-------------------------------------
-- function setEmptyStr
-------------------------------------
function UIC_RankingList:setEmptyStr(message)
    if (not message) then
       self.m_emptyMsg = '' 
    end
    self.m_emptyMsg = message
end

-------------------------------------
-- function makeRankMoveBtn
-------------------------------------
function UIC_RankingList:makeRankMoveBtn(prev_cb, next_cb, offset_gap)
    local l_item = self.m_itemList
    self.m_offsetGap = offset_gap
    if (#l_item == 0) then
        l_item = {} 
        return
    end
    
    -- 첫 통신할 때 내 순위를 받아오기 위해 offset을 -1 로 들고 있음
    -- 첫 통신 이후에는 offset에 옳은 값에 넣어줌 (offset : offset (랭킹)부터 시작하는 랭킹 리스트를 받음)
    if (self.m_offset == -1) then
        if (l_item[1] or l_item[1]['rank']) then
            self.m_offset = l_item[1]['rank']
        end
    end

    -- 이전 보기 추가
    if (1 < self.m_offset) then
        local prev_data = { rank = 'prev' }
        table.insert(l_item, prev_data)
    end

    -- 다음 보기 추가
    if (#l_item > 0) then
        local next_data = { rank = 'next' }
        table.insert(l_item, next_data)
    end
    self.m_itemList = l_item

    do-- 테이블 뷰 정렬
        local function sort_func(a, b)
            local a_data = a
            local b_data = b

            -- 1.이전, 다음 버튼 정렬
            if (a_data.rank == 'prev') then
                return true
            elseif (b_data.rank == 'prev') then
                return false
            elseif (a_data.rank == 'next') then
                return false
            elseif (b_data.rank == 'next') then
                return true
            end

            -- 2.랭킹이 없다면 하위로 정렬
            if (a_data.rank <= 0) then
                return false
            end

            if (b_data.rank <= 0) then
                return true
            end

            -- 3.랭킹으로 선별
            local a_rank = a_data.rank
            local b_rank = b_data.rank
            return a_rank < b_rank
        end

        table.sort(self.m_itemList, sort_func)
    end


    self.m_prevCb = prev_cb
    self.m_nextCb = next_cb
end

-------------------------------------
-- function makeRankList
-------------------------------------
function UIC_RankingList:makeRankList(node)
    local l_item = self.m_itemList
    if (not l_item) then
        l_item = {}
    end

    local create_func = function(ui, data)    
        -- 이전 버튼 세팅
        local click_prev = function()
            self:click_prev()
        end       

        if (data['rank'] == 'prev') then
            if (ui.vars['prevBtn']) then
                ui.vars['prevBtn']:registerScriptTapHandler(click_prev)
                ui.vars['prevBtn']:setVisible(true)
            end
            ui.vars['itemMenu']:setVisible(false)
        end

        -- 다음 버튼 세팅
        local click_next = function()
            self:click_next()
        end

        if (data['rank'] == 'next') then
            if (ui.vars['nextBtn']) then
                ui.vars['nextBtn']:registerScriptTapHandler(click_next)
                ui.vars['nextBtn']:setVisible(true)
            end
            ui.vars['itemMenu']:setVisible(false)
        end

        if (self.m_cellUICreateCB) then
            self.m_cellUICreateCB(ui, data)
        end
    end

    node:removeAllChildren()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(550, UIHelper:getProfileScrollItemHeight(55 + 5, 23))
    table_view:setCellUIClass(self.m_cellUIClass, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:makeDefaultEmptyDescLabel(self.m_emptyMsg)
    table_view:setItemList(l_item)

    self.m_rankTableView = table_view

    if (self.m_makeMyRankCb) then
        self.m_makeMyRankCb()
    end
end

-------------------------------------
-- function setFocus
-- @warning 동작 안함! 사용 안함!
-------------------------------------
function UIC_RankingList:setFocus(value_type, value)
    local l_item = self.m_itemList
    local idx = 1

    for i,v in pairs(l_item) do
        if (v[value_type] == value) then
            idx = i
            break
        end
    end

    -- 최상위 랭킹 필터일 때는 1위에 포커스
    if (self.m_offset == 1) then
        idx = 1
    end

    -- 해당 셀에 하이라이트
    local func_highlight = function(ui, data)
        if (data[value_type] == value) then
            if (type(data[value_type]) == 'number' and data[value_type] > 0) then
                if (ui.vars['mySprite']) then
                    ui.vars['mySprite']:setVisible(true)
                end

                if (ui.vars['meSprite']) then
                    ui.vars['meSprite']:setVisible(true)
                end
            end
        end
    end
    self.m_rankTableView.m_cellUIAppearCB = func_highlight

    self.m_rankTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    self.m_rankTableView:relocateContainerFromIndex(idx)
end

-------------------------------------
-- function setMyRank
-------------------------------------
function UIC_RankingList:setMyRank(make_my_rank_cb)
    self.m_makeMyRankCb = make_my_rank_cb
end

-----------------------------
-- function click_prev
-------------------------------------
function UIC_RankingList:click_prev()
     local l_item = self.m_itemList or {}
     local list_cnt = #l_item

     local offset_gap = self.m_offsetGap
     local next_offset = self.m_offset
     if (list_cnt <= 0) then
         MakeSimplePopup(POPUP_TYPE.OK, Str('랭킹 정보가 없습니다'))
         return       
     end
     
     local rank_data = l_item[1]
     if (not rank_data) then
         MakeSimplePopup(POPUP_TYPE.OK, Str('랭킹 정보가 없습니다'))
         return    
     end
     
     local next_offset = rank_data['rank'] -- 첫 번째 랭킹 데이터의 rank 
     if (not next_offset) then
        return
     end

    -- 다음/이전 버튼은 rank의 값이 prev, next임
    -- 첫 번째 대신, 두 번째 랭킹 데이터를 사용
    if (type(next_offset) == 'string') then
        next_offset = l_item[2]['rank']
    end

    next_offset = next_offset - offset_gap -- 가져온 랭킹의 가장 첫 번째 - OFFSET_GAP
    next_offset = math_max(next_offset, 0) -- 계산된 offset을 저장
    self.m_offset = next_offset or 1
    
    if (self.m_prevCb) then
       self.m_prevCb(self.m_offset)
    end
end

-------------------------------------
-- function click_next
-------------------------------------
function UIC_RankingList:click_next()
    local l_item = self.m_itemList or {}
    local list_cnt = #l_item

    local offset_gap = self.m_offsetGap
    if (list_cnt < offset_gap) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
        return
    end

    local rank_data = l_item[list_cnt]
    if (not rank_data) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('랭킹 정보가 없습니다'))
        return       
    end
    
    local next_offset = rank_data['rank'] -- 가져온 랭킹의 가장 마지막
    if (not next_offset) then
        return
    end

    -- 다음/이전 버튼은 rank의 값이 prev, next임
    -- 마지막 대신, 마지막에서 두 번째 랭킹 데이터를 사용
    if (type(next_offset) == 'string') then
        next_offset = l_item[list_cnt-1]['rank']
    end

    self.m_offset = next_offset + 1
    
    if (self.m_nextCb) then
       self.m_nextCb(self.m_offset)
    end
end
