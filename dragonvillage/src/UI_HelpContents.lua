-------------------------------------
-- function make_child_menu
-------------------------------------
local make_child_menu = function(self, ui_name, ui_depth)
    return UI_HelpContentsListItem(ui_name)
end

-------------------------------------
-- function UI_HelpClan
-------------------------------------
function UI_HelpContents(...)
    local struct_tab_ui = StructTabUI()
    struct_tab_ui:setPrefix('')
    struct_tab_ui:setDefaultTab(...)
    struct_tab_ui:setMakeChildMenuFunc(make_child_menu)

    local ui = UI_TabUI_AutoGeneration('help_contents_open.ui', true, 1, struct_tab_ui) -- param ui_name, is_root, ui_depth, struct_tab_ui
    ui.vars['ScrollMenu']:setSwallowTouch(false)
    ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)
end
