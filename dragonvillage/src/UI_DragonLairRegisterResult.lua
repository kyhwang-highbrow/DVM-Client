local PARENT = UI
-------------------------------------
-- class UI_DragonLairRegisterResult
-------------------------------------
UI_DragonLairRegisterResult = class(PARENT,{
    m_ticketCount = 'list<did>',
    m_dragonCount = 'list<did>',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairRegisterResult:init(ticket_count, dragon_count)
    self.m_ticketCount = ticket_count
    self.m_dragonCount = dragon_count
    self.m_uiName = 'UI_DragonLairRegisterResult'   
    
    local vars = self:load('dragon_lair_completion_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonLairRegisterResult')

    self:initUI()
    self:initButton()
    self:refresh()

        -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLairRegisterResult:initUI()
    local vars = self.vars

    local t_item = {}

    t_item['item_id'] = 700022
    t_item['count'] = 10 --self.m_ticketCount

    local ui = MakeItemCard(t_item)
    --local price_icon = IconHelper:getItemIcon('blessing_ticket')
    vars['iconNode']:removeAllChildren()
    vars['iconNode']:addChild(ui.root)

    vars['dscLabel']:setString(Str('{1}마리의 드래곤이 등록되었습니다.', self.m_dragonCount))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonLairRegisterResult:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLairRegisterResult:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_DragonLairRegisterResult:click_closeBtn()
    self:close()
end

-------------------------------------
-- function open
-------------------------------------
function UI_DragonLairRegisterResult.open(ticket_count, dragon_count)
    return UI_DragonLairRegisterResult(ticket_count, dragon_count)
end