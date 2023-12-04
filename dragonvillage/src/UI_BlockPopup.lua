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
--- @class UI_BlockObject
--- @brief  사이즈 조절이 가능한 블록 오브젝트
--          기존 블록 기능들은 z-order에 대한 조절만 가능했지 width, height 사이즈 조절이 불가능함
-------------------------------------
UI_BlockObject = class({
    root = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_BlockObject:init(size_x, size_y)
    self.root = cc.Menu:create()
    self.root:setDockPoint(CENTER_POINT)
    self.root:setAnchorPoint(CENTER_POINT)
    self.root:setPosition(ZERO_POINT)

    -- cc.Scale9Sprite:create('res/common/empty.png')
    local button = ccui.Button:create()
    button:loadTextures('res/common/empty.png', 'res/common/empty.png')
    button:setTouchEnabled(true)    
    button:setPosition(ZERO_POINT)
    button:setScale(size_x or 65535, size_y or 65535)
    button:setDockPoint(CENTER_POINT)

    self.root:addChild(button, 1)
end
