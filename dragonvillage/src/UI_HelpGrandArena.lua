-------------------------------------
-- function make_child_menu
-- @brief UI_TabUI_AutoGeneration에서 생성 할 때 따로 생성이 필요한 UI 처리
-------------------------------------
local make_child_menu = function(self, ui_name, ui_depth)
    
end

-------------------------------------
-- function set_after
-- @brief UI_TabUI_AutoGeneration에서 UI 생성 후 UI설정 필요한 부분 처리
-------------------------------------
local set_after = function(ui_name, ui)
    if (ui_name == 'help_grand_arena.ui') then
        local l_item_list = g_grandArena.m_grandArenaRewardTable or {}
        -- 서버에서 테이블 보상 정보를 주지 않으면 해당 탭 버튼을 비활성화
        if (#l_item_list == 0) then
            ui.vars['grand_arena_rankingTabBtn']:setVisible(false)
            ui.vars['grand_arena_rankingTabBtn']:setEnabled(false)
        end
    end

    if (ui_name == 'help_grand_arena_ranking.ui') then
        -- 시즌 보상 테이블 뷰 생성
        local node = ui.vars['ranking_reward_TabMenu']
        local l_item_list = g_grandArena.m_grandArenaRewardTable or {}

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(550, 55 + 5)
        table_view:setCellUIClass(UI_GrandArenaRankingRewardListItem)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_item_list, true)
        table_view:makeDefaultEmptyDescLabel(Str('보상 정보가 없습니다.'))
    end
end

-------------------------------------
-- function UI_HelpGrandArena
-- @brief UI 자동 생성
-------------------------------------
function UI_HelpGrandArena(...)
    local struct_tab_ui = StructTabUI()
    struct_tab_ui:setPrefix('help_')                    -- 사용할 접두어 설정
    struct_tab_ui:setDefaultTab(...)                    -- Depth별 디폴트 탭 설정
    struct_tab_ui:setAfterFunc(set_after)               -- UI 생성 후 후처리 함수 설정
    struct_tab_ui:setMakeChildMenuFunc(make_child_menu) -- UI 생성 함수 설정
    return UI_TabUI_AutoGeneration('help_grand_arena.ui', true, 1, struct_tab_ui) -- param ui_name, is_root, ui_depth, struct_tab_ui
end


-- # 접두어로 'help_'가 붙음
-- help_grand_arena                         (help_grand_arena.ui)
--      help_grand_reward                   (help_grand_reward.ui)
--      help_grand_rules                    (help_grand_rules.ui)
--      help_grand_summary                  (help_grand_summary.ui)
--      help_grand_ranking