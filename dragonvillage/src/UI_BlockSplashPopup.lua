local PARENT = UI

-------------------------------------
-- class UI_BlockSplashPopup
-- @brief block 기능이 있으면서 splash 이펙트(번쩍)
-------------------------------------
UI_BlockSplashPopup = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BlockSplashPopup:init(finish_cb)
	self.m_uiName = 'UI_BlockSplashPopup'

    local vars = self:load('splash.ui')
    UIManager:open(self, UIManager.POPUP, true)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_BlockSplashPopup')
    
    local function splash_finish_cb()
        if (finish_cb) then
            finish_cb()
        end
        self:close()
    end

    vars['splashLayer']:setLocalZOrder(1)
	vars['splashLayer']:setVisible(true)
	vars['splashLayer']:stopAllActions()
	vars['splashLayer']:setOpacity(255)
	vars['splashLayer']:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.Hide:create(), cc.CallFunc:create(function() splash_finish_cb() end)))
end