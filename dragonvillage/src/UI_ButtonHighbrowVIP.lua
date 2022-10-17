
-------------------------------------
-- Class UI_ButtonHighbrowVIP
-------------------------------------
UI_ButtonHighbrowVIP = class(UI_ManagedButton, {

})

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonHighbrowVIP:init()
    self:load('button_highbrow_vip.ui')

    self:initUI()
    self:initButton()
    self:refresh()

    
    -- 업데이트 스케줄러
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ButtonHighbrowVIP:initUI()
    local vars = self.vars

    local icon_res = g_highbrowVipData:getVipBtnRes()
    UIManager:replaceResource(vars['vipNode'], icon_res)


    vars['vipLabel']:setString(Str('등급혜택'))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ButtonHighbrowVIP:initButton()    
    self.vars['vipBtn']:registerScriptTapHandler(function() self:click_btn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ButtonHighbrowVIP:refresh()

end

-------------------------------------
-- function click_btn
-------------------------------------
function UI_ButtonHighbrowVIP:click_btn()
    g_highbrowVipData:openPopup()
end

-------------------------------------
-- function click_btn
-------------------------------------
function UI_ButtonHighbrowVIP:update(dt)
    if (g_highbrowVipData:checkVipStatus() == false) then
        self.m_bMarkDelete = true
        self:callDirtyStatusCB()
    end
end
