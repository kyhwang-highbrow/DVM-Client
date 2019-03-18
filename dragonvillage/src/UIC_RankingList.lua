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

    if (self.m_offset == -1) then
        if (l_item_list[1] or l_item_list[1]) then
            self.m_offset = l_item_list[1]['rank']
        end
    end

    -- 이전 보기 추가
    if (1 < self.m_offset) then
        l_item['prev'] = 'prev'
    end
    
    -- 다음 보기 추가
    if (#l_item > 0) then
        l_item['next'] = 'next'
    end

    self.m_prevCb = prev_cb
    self.m_nextCb = next_cb
end

-------------------------------------
-- function setRankList
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

        if (data == 'prev') then
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

        if (data == 'next') then
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
    table_view.m_defaultCellSize = cc.size(510, 50 + 5)
    table_view:setCellUIClass(self.m_cellUIClass, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item)
    table_view:makeDefaultEmptyDescLabel(self.m_emptyMsg)

    self.m_rankTableView = table_view

    if (self.m_makeMyRankCb) then
        self.m_makeMyRankCb()
    end
end

-------------------------------------
-- function setFocus
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
            if (ui.vars['mySprite']) then
                ui.vars['mySprite']:setVisible(true)
            end

            if (ui.vars['meSprite']) then
                ui.vars['meSprite']:setVisible(true)
            end
        end
    end
    self.m_rankTableView.m_cellUIAppearCB = func_highlight

    self.m_rankTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    self.m_rankTableView:relocateContainerFromIndex(idx)
end

-------------------------------------
-- function makeMyRank
-------------------------------------
function UIC_RankingList:setMyRank(make_my_rank_cb)
    self.m_makeMyRankCb = make_my_rank_cb
end

-----------------------------
-- function click_prev
-------------------------------------
function UIC_RankingList:click_prev()
    self.m_offset = math_max(self.m_offset - self.m_offsetGap, 0)
    if (self.m_prevCb) then
        self.m_prevCb()
    end
end

-------------------------------------
-- function click_next
-------------------------------------
function UIC_RankingList:click_next()
    local l_item = self.m_itemList
    if (table.count(l_item) < self.m_offsetGap) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
        return
    end

    self.m_offset = self.m_offset + #l_item - 2

    if (self.m_nextCb) then
        self.m_nextCb()
    end
end
