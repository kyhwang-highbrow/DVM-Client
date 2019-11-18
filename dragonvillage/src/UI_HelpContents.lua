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
    local defualt_tab = ...
    local struct_tab_ui = StructTabUI()
    struct_tab_ui:setPrefix('')
    struct_tab_ui:setDefaultTab(defualt_tab)
    struct_tab_ui:setMakeChildMenuFunc(make_child_menu)

    local ui = UI_TabUI_AutoGeneration('help_contents_open.ui', true, 1, struct_tab_ui) -- param ui_name, is_root, ui_depth, struct_tab_ui

    -- help_contents_open.ui 의 function initUI()
    ui.vars['ScrollMenu']:setSwallowTouch(false)
    ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)

    -- 선택한 탭을 바로 보여주도록 포커싱
    local container_node = ui.vars['ScrollView']:getContainer()
    local ori_pos_y = container_node:getPositionY()
    local l_content = {'adventure', 'secret_relation', 'exploration', 'nest_tree', 'nest_evo_stone', 'daily_shop', 'ancient', 'shop_random', 'colosseum', 'capsule', 'nest_nightmare',  'forest', 'clan', 'challenge_mode', 'attr_tower', 'ancient_ruin', 'rune_guardian', 'clan_raid'}
    local focus_idx = 0
    for i, content_name in ipairs(l_content) do
        if (content_name == defualt_tab) then
            focus_idx = i
            break
        end
        -- 가장 11번째부터는 포커싱 더 내리지 않음
        if (i > 10) then
            focus_idx = i
            break
        end

    end

    -- 선택된 탭 만큼 포커싱 위치를 내려줌
    local pos_y = ori_pos_y + (focus_idx-1) * 65
    container_node:setPositionY(pos_y)
end
