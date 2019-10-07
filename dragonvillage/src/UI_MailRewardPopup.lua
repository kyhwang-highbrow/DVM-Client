local PARENT = UI

-------------------------------------
-- class UI_MailRewardPopup
-------------------------------------
UI_MailRewardPopup = class(PARENT,{
        m_itemInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MailRewardPopup:init(item_info)
    local vars = self:load('popup_ad_confirm.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_itemInfo = item_info

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_MailRewardPopup')

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
function UI_MailRewardPopup:initUI()
    local vars = self.vars
    local item_info = self.m_itemInfo

    if (item_info) then
        local id = item_info['item_id']
        local cnt = item_info['count']
        local item_card = UI_ItemCard(id, cnt)
        if (item_card) then
            vars['itemNode']:addChild(item_card.root)
        end

        -- 우편함 노티
        g_highlightData:setHighlightMail()
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_MailRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function removeMailLabel
-------------------------------------
function UI_MailRewardPopup:removeMailMsg()
    local vars = self.vars
    vars['mailMenu']:setVisible(false)
    vars['dragonForestMenu']:setVisible(true)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MailRewardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_MailRewardPopup)
