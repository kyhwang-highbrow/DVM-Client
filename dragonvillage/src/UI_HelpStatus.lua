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
 
end

-------------------------------------
-- function UI_HelpStatus
-- @brief UI 자동 생성
-------------------------------------
function UI_HelpStatus(...)
    local struct_tab_ui = StructTabUI()
    struct_tab_ui:setPrefix('help_status_')        -- 사용할 접두어 설정
    struct_tab_ui:setDefaultTab(...)        -- Depth별 디폴트 탭 설정
    struct_tab_ui:setAfterFunc(set_after)   -- UI 생성 후 후처리 함수 설정
    struct_tab_ui:setMakeChildMenuFunc(nil) -- UI 생성 함수 설정
    return UI_TabUI_AutoGeneration('help_status.ui', true, 1, struct_tab_ui) -- param ui_name, is_root, ui_depth, struct_tab_ui
end