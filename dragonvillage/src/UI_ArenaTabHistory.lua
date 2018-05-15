local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-- g_colosseumData -> g_arenaData 변경 필요, 아직 서버 api 분리안됨

-------------------------------------
-- class UI_ArenaTabHistory
-- @brief 아레나 기록 탭 (공격전, 방어전)
-------------------------------------
UI_ArenaTabHistory = class(PARENT,{
        vars = '',
        
        m_arenaAtkTableView = 'UIC_TableView',        
        m_arenaDefTableView = 'UIC_TableView',
    })

UI_ArenaTabHistory['ATK'] = 'atk'
UI_ArenaTabHistory['DEF'] = 'def'

local OFFSET_GAP = 30 -- 한번에 보여주는 히스토리 수
local CLAN_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaTabHistory:init(owner_ui)
    self.root = owner_ui.vars['historyMenu'] -- root가 있어야 보임
    self.vars = owner_ui.vars

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaTabHistory:initUI()
    self:initTab()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ArenaTabHistory:initTab()
    local vars = self.vars

    self:addTabAuto(UI_ArenaTabHistory['ATK'], vars, vars['rankNode'])
    self:addTabAuto(UI_ArenaTabHistory['DEF'], vars, vars['clanRankNode'])
    
    self:setTab(UI_ArenaTabHistory['ATK'])
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ArenaTabHistory:onChangeTab(tab, first)
    local vars = self.vars
    if (not first) then
        return
    end

    if (tab == UI_ArenaTabHistory['ATK']) then
        self:request_atkHistory()
    elseif (tab == UI_ArenaTabHistory['DEF']) then
        self:request_defHistory()
    end
end

-------------------------------------
-- function request_atkHistory
-------------------------------------
function UI_ArenaTabHistory:request_atkHistory()
    local finish_cb = function()
        self:init_atkTableView()
    end

    g_arenaData:request_colosseumHistory('atk', finish_cb)
end

-------------------------------------
-- function init_atkTableView
-------------------------------------
function UI_ArenaTabHistory:init_atkTableView()
    local node = self.vars['atkListNode']
    node:removeAllChildren()

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(720, 150 + 5)
    table_view:setCellUIClass(UI_ArenaHistoryListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local l_item_list = g_arenaData.m_matchAtkHistory
    table_view:setItemList(l_item_list)

    -- 상대방 방어덱의 전투력이 낮은 순으로 정렬
    local function sort_func(a, b)
        -- StructUserInfoColosseum
        local a_data = a['data']
        local b_data = b['data']

        -- 리그 포인트를 얻어옴
        local a_rp = a_data:getRP()
        local b_rp = b_data:getRP()

        return a_rp < b_rp
    end
    table.sort(table_view.m_itemList, sort_func)
end

-------------------------------------
-- function request_defHistory
-------------------------------------
function UI_ArenaTabHistory:request_defHistory()
end

-------------------------------------
-- function init_defTableView
-------------------------------------
function UI_ArenaTabHistory:init_defTableView()
end