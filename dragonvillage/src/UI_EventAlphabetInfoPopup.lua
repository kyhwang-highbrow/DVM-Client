local PARENT = UI

-------------------------------------
-- class UI_EventAlphabetInfoPopup
-- @brief 알파벳 이벤트에서 알파벳 아이템 획득처 안내 팝업
-------------------------------------
UI_EventAlphabetInfoPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventAlphabetInfoPopup:init()
    local vars = self:load('alphabet_event_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventAlphabetInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventAlphabetInfoPopup:initUI()
    local vars = self.vars

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventAlphabetInfoPopup:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    local l_content_list = {}
    table.insert(l_content_list, 'gold_dungeon')
    table.insert(l_content_list, 'adventure')
    table.insert(l_content_list, 'nest_tree')
    table.insert(l_content_list, 'nest_evo_stone')
    table.insert(l_content_list, 'ancient_ruin')
    table.insert(l_content_list, 'nest_nightmare')
    table.insert(l_content_list, 'secret_relation')

    for i,v in pairs(l_content_list) do
        if vars[v .. 'Btn'] then
            vars[v .. 'Btn']:registerScriptTapHandler(function() UINavigator:goTo(v) end)
        end
    end
    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventAlphabetInfoPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_EventAlphabetInfoPopup)
