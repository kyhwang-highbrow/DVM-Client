local PARENT = UI_AncientTowerRank

-------------------------------------
-- class UI_AttrTowerRank
-------------------------------------
UI_AttrTowerRank = class(PARENT, {})

local OFFSET_GAP = 20 -- 한번에 보여주는 랭커 수

-------------------------------------
-- function init
-------------------------------------
function UI_AttrTowerRank:init(ui_scene)
    self.m_uiScene = ui_scene
    self.m_rankOffset = 1
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttrTowerRank:initUI()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttrTowerRank:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttrTowerRank:initButton()
end

-------------------------------------
-- function request_Rank
-------------------------------------
function UI_AttrTowerRank:request_Rank()
    local function finish_cb()
        self.m_rankOffset = g_attrTowerData.m_nGlobalOffset
        self:init_rankTableView()
    end
    local offset = self.m_rankOffset
    g_attrTowerData:request_attrTowerRank(offset, finish_cb)
end

-------------------------------------
-- function init_rankTableView
-------------------------------------
function UI_AttrTowerRank:init_rankTableView()
    local node      = self.m_uiScene.vars['rankingListNode']
    local my_node   = self.m_uiScene.vars['rankingMeNode']

    node:removeAllChildren()
    my_node:removeAllChildren()

    -- 내 순위
	do
        local ui = UI_AncientTowerRankListItem(g_attrTowerData.m_playerUserInfo)
        my_node:addChild(ui.root)
	end

    local l_item_list = g_attrTowerData.m_lGlobalRank

    if (self.m_rankOffset > 1) then
        local prev_data = { m_tag = 'prev' }
        l_item_list['prev'] = prev_data
    end

    if (#l_item_list > 0) then
        local next_data = { m_tag = 'next' }
        l_item_list['next'] = next_data
    end

    -- 이전 랭킹 보기
    local function click_prevBtn()
        self.m_rankOffset = self.m_rankOffset - OFFSET_GAP
        self.m_rankOffset = math_max(self.m_rankOffset, 0)
        self:request_Rank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        local add_offset = #g_attrTowerData.m_lGlobalRank
        if (add_offset < OFFSET_GAP) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end
        self.m_rankOffset = self.m_rankOffset + add_offset
        self:request_Rank()
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
        ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 100 + 5)
    table_view:setCellUIClass(UI_AncientTowerRankListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_rankTableView = table_view

    do -- 테이블 뷰 정렬
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
            local a_rank = a_data.m_rank
            local b_rank = b_data.m_rank 
            return a_rank < b_rank
            
        end

        table.sort(table_view.m_itemList, sort_func)
    end

    table_view:makeDefaultEmptyDescLabel(Str('랭킹 정보가 없습니다.'))   
end