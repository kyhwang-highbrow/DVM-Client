local PARENT = UI

-------------------------------------
-- class UI_BlockPopup
-------------------------------------
UI_BlockPopup = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BlockPopup:init()
	self.m_uiName = 'UI_BlockPopup'

    self:load('empty.ui')
    UIManager:open(self, UIManager.POPUP, true)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_BlockPopup')
end



-------------------------------------
-- class UI_BlockObject
-------------------------------------
UI_BlockObject = class({
    root = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_BlockObject:init()
    self.root = cc.Menu:create()
    self.root:setDockPoint(CENTER_POINT)
    self.root:setAnchorPoint(CENTER_POINT)
    self.root:setPosition(ZERO_POINT)

    local scr_size = cc.Director:getInstance():getWinSize()

    -- cc.Scale9Sprite:create('res/common/empty.png')
    local button = ccui.Button:create()
    button:loadTextures('res/common/empty.png', 'res/common/empty.png')
    button:setTouchEnabled(true)
    button:setContentSize(scr_size.width, scr_size.height)
    button:setPosition(ZERO_POINT)
    button:setScale(65535, 65535)
    --button:setOpacity(0.01)
    button:setDockPoint(CENTER_POINT)

    self.root:addChild(button, 1)
    g_currScene.m_scene:addChild(self.root, UI_ZORDER.LOADING)

    --UIManager:open(self, UIManager.POPUP, true, false)

    -- backkey 지정
    --g_currScene:pushBackKeyListener(self, function() end, 'UI_BlockPopup')
end

-------------------------------------
function UI_BlockObject:close()
end