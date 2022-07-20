local PARENT = UI

-------------------------------------
-- class UI_HbrwLoungePopup
-------------------------------------
UI_HbrwLoungePopup = class(PARENT,{

})


-------------------------------------
-- function init
-------------------------------------
function UI_HbrwLoungePopup:init()
    self.m_uiName = 'UI_HbrwLoungePopup'
    local vars = self:load('hbrw_lounge_popup.ui')

    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_cancelBtn() end, 'UI_HbrwLoungePopup')
    
    self:initUI()
    self:initButton()
    self:refresh()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_HbrwLoungePopup:initUI()
    local vars = self.vars


    local check = self:getCheckStatus()
    local is_coupon_used = self:getCheckCoupon()
    vars['checkSprite']:setVisible(check)

    self:setItemNode()

    if is_coupon_used then
        local root_size = vars['Menu']:getContentSize()
        local coupon_size = vars['couponNode']:getContentSize()
        local width = root_size['width']
        local height = root_size['height'] - coupon_size['height']

        vars['Menu']:setContentSize(width, height)
        vars['couponNode']:removeFromParent()
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HbrwLoungePopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['checkBtn']:registerScriptTapHandler(function() self:click_checkBtn() end)
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_HbrwLoungePopup:click_okBtn()
    g_settingData:setHbrwLoungeCheckSetting(true)

    self:setCloseCB(function() SDKManager:goToWeb('https://discord.gg/mtM3xnE4nh') end)
    
    self:close()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HbrwLoungePopup:click_cancelBtn()
    
    if g_settingData:getHbrwLoungeCheckSetting() ~= true then
        g_settingData:setHbrwLoungeCheckSetting(false)
    end

    self:close()
end

-------------------------------------
-- function click_checkBtn
-------------------------------------
function UI_HbrwLoungePopup:click_checkBtn()
    local vars = self.vars
    local check = not self:getCheckStatus()

    g_settingData:setHbrwLoungeCheckSetting(check)
    vars['checkSprite']:setVisible(check)
end

-------------------------------------
-- function getCheckStatus
-------------------------------------
function UI_HbrwLoungePopup:getCheckStatus()
    if g_settingData:getHbrwLoungeCheckSetting() == true then
        return true
    else
        return false
    end
end

-------------------------------------
-- function getCheckCoupon
-------------------------------------
function UI_HbrwLoungePopup:getCheckCoupon()
    if g_settingData:getHbrwLoungeCheckCoupon() == true then
        return true
    else
        return false
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HbrwLoungePopup:refresh()
   
end

-------------------------------------
-- function setItemNode
-------------------------------------
function UI_HbrwLoungePopup:setItemNode()
    local vars = self.vars

    local t_item = {
            {   ['item_id'] = 700404,
                ['count'] = 7},
            {   ['item_id'] = 700330,
                ['count'] = 70},
            {   ['item_id'] = 700001,
                ['count'] = 7000},
            {   ['item_id'] = 700002,
                ['count'] = 700000},
    }

    for idx, data in ipairs(t_item) do
        local item_card = MakeItemCard(data)

        vars['itemNode' .. idx]:addChild(item_card.root)
    end
   
end