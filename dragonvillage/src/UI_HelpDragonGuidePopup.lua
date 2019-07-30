local PARENT = UI

-------------------------------------
-- class UI_HelpDragonGuidePopup
-------------------------------------
UI_HelpDragonGuidePopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HelpDragonGuidePopup:init()
    local vars = self:load('help_dragon_guide_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HelpDragonGuidePopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HelpDragonGuidePopup:initUI()
    local vars = self.vars

    local list_expansion = UIC_ListExpansion()
    local item_name_list = {'role', 'rarity', 'attr'}
    list_expansion:configListExpansion(vars, item_name_list)

    -- 처음부터 특정 아이템을 펼쳐진 상태로 하고싶을 경우
    --list_expansion:setDefaultSelectedListItem('rarity')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HelpDragonGuidePopup:initButton()
    self.vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HelpDragonGuidePopup:refresh()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HelpDragonGuidePopup:click_closeBtn()
    self:close()
end