-------------------------------------
-- function make_child_menu
-- @brief UI_TabUI_AutoGeneration���� ���� �� �� ���� ������ �ʿ��� UI ó��
-------------------------------------
local make_child_menu = function(self, ui_name, ui_depth)

end

-------------------------------------
-- function set_after
-- @brief UI_TabUI_AutoGeneration���� UI ���� �� UI���� �ʿ��� �κ� ó��
-------------------------------------
local set_after = function(ui_name, ui)
 
end

-------------------------------------
-- function UI_HelpStatus
-- @brief UI �ڵ� ����
-------------------------------------
function UI_HelpStatus(...)
    local struct_tab_ui = StructTabUI()
    struct_tab_ui:setPrefix('help_status_')        -- ����� ���ξ� ����
    struct_tab_ui:setDefaultTab(...)        -- Depth�� ����Ʈ �� ����
    struct_tab_ui:setAfterFunc(set_after)   -- UI ���� �� ��ó�� �Լ� ����
    struct_tab_ui:setMakeChildMenuFunc(nil) -- UI ���� �Լ� ����
    return UI_TabUI_AutoGeneration('help_status.ui', true, 1, struct_tab_ui) -- param ui_name, is_root, ui_depth, struct_tab_ui
end