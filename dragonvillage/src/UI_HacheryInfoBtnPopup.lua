UI_HacheryInfoBtnPopup = class(UI, {})
 
----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_HacheryInfoBtnPopup:init(ui_name)
    -- 픽업
    -- 'hatchery_summon_info_popup.ui'
    -- 고오급
    -- 'hatchery_summon_info_premium_popup.ui'

	self.m_uiName = 'UI_HacheryInfoBtnPopup'

    local vars = self:load(ui_name)
    UIManager:open(self, UIManager.POPUP)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HacheryInfoBtnPopup')
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)


    if vars['specificationMenu'] then
        vars['specificationMenu']:setVisible(g_hatcheryData:checkCeilingInfoExist())
    end
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
