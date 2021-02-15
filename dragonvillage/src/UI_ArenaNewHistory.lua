local PARENT = UI

-- g_colosseumData -> g_arenaData 변경 필요, 아직 서버 api 분리안됨

-------------------------------------
-- class UI_ArenaNewHistory
-- @brief 아레나 기록 탭 (공격전, 방어전)
-------------------------------------
UI_ArenaNewHistory = class(PARENT,{
        vars = '',
        
        m_arenaAtkTableView = 'UIC_TableView',        
        m_arenaDefTableView = 'UIC_TableView',
    })

UI_ArenaNewHistory['ATK'] = 'atk'
UI_ArenaNewHistory['DEF'] = 'def'

local OFFSET_GAP = 30 -- 한번에 보여주는 히스토리 수
local CLAN_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewHistory:init()
    local vars = self:load('arena_new_popup_defense.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ColosseumRankingRewardPopup')
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    --self.root = owner_ui.vars['historyMenu'] -- root가 있어야 보임
    --self.vars = owner_ui.vars

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewHistory:initUI()
    --self:initTab()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ArenaNewHistory:initTab()
    local vars = self.vars

    self:addTabAuto(UI_ArenaNewHistory['ATK'], vars, vars['atkListNode'])
    self:addTabAuto(UI_ArenaNewHistory['DEF'], vars, vars['defListNode'])
    
    self:setTab(UI_ArenaNewHistory['ATK'])
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ArenaNewHistory:onChangeTab(tab, first)
    local vars = self.vars
    if (not first) then
        return
    end

    if (tab == UI_ArenaNewHistory['ATK']) then
        self:request_atkHistory()
    elseif (tab == UI_ArenaNewHistory['DEF']) then
        self:request_defHistory()
    end
end

-------------------------------------
-- function request_atkHistory
-------------------------------------
function UI_ArenaNewHistory:request_atkHistory()
    local finish_cb = function()
        self:init_atkTableView()
    end

    g_arenaData:request_arenaHistory(UI_ArenaNewHistory['ATK'] , finish_cb)
end

-------------------------------------
-- function init_atkTableView
-------------------------------------
function UI_ArenaNewHistory:init_atkTableView()
    local node = self.vars['atkListNode']
    node:removeAllChildren()

    local function make_func(data)
        return UI_ArenaHistoryListItem(data, UI_ArenaNewHistory['ATK'])
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(720, 150 + 5)
    table_view:setCellUIClass(make_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local l_item_list = g_arenaData.m_matchAtkHistory
    table_view:setItemList(l_item_list)

    local msg = Str('공격전 기록이 없다고라')
    table_view:makeDefaultEmptyMandragora(msg)

    -- 상대방 방어덱의 전투력이 낮은 순으로 정렬
    local function sort_func(a, b)
        -- StructUserInfoArena
        local a_data = a['data']
        local b_data = b['data']

        -- 최근 매치한 순서로 가져옴
        local a_match = a_data.m_matchTime
        local b_match = b_data.m_matchTime

        return a_match > b_match
    end
    table.sort(table_view.m_itemList, sort_func)
end

-------------------------------------
-- function request_defHistory
-------------------------------------
function UI_ArenaNewHistory:request_defHistory()
    local finish_cb = function()
        self:init_defTableView()
    end

    g_arenaData:request_arenaHistory(UI_ArenaNewHistory['DEF'], finish_cb)
end

-------------------------------------
-- function init_defTableView
-------------------------------------
function UI_ArenaNewHistory:init_defTableView()
    local node = self.vars['defListNode']
    node:removeAllChildren()

    local function make_func(data)
        return UI_ArenaHistoryListItem(data, UI_ArenaNewHistory['DEF'])
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(720, 150 + 5)
    table_view:setCellUIClass(make_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local l_item_list = g_arenaData.m_matchDefHistory
    table_view:setItemList(l_item_list)

    local msg = Str('방어전 기록이 없다고라')
    table_view:makeDefaultEmptyMandragora(msg)

    -- 상대방 방어덱의 전투력이 낮은 순으로 정렬
    local function sort_func(a, b)
        -- StructUserInfoArena
        local a_data = a['data']
        local b_data = b['data']

        -- 최근 매치한 순서로 가져옴
        local a_match = a_data.m_matchTime
        local b_match = b_data.m_matchTime

        return a_match > b_match
    end
    table.sort(table_view.m_itemList, sort_func)
end