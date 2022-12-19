local PARENT = UI

-------------------------------------
-- class UI_AdRewardPopup
-------------------------------------
UI_AdRewardPopup = class(PARENT,{
        m_itemInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AdRewardPopup:init(item_info)
    local vars = self:load('popup_ad_confirm.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_itemInfo = item_info

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AdRewardPopup')

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
function UI_AdRewardPopup:initUI()
    local vars = self.vars

    vars['mailCommentText']:setVisible(false)
    
    local item_info = self.m_itemInfo

    -- 아이템이 리스트 형태로 내려왔을 수도 있다.
    if (item_info and not item_info['item_id']) then
        for _, v in ipairs(item_info) do
            if (v) then item_info = v end
        end
    end

    if (item_info) then
        local id = item_info['item_id']
        local cnt = item_info['count']
        local item_card = UI_ItemCard(id, cnt)
        if (item_card) then
            vars['itemNode']:addChild(item_card.root)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AdRewardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_AdRewardPopup)
