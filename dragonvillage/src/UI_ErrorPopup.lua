local PARENT = UI

-------------------------------------
-- class UI_ErrorPopup
-- @brief 에러를 화면에 찍어준다.
-------------------------------------
UI_ErrorPopup = class(PARENT, {
		m_scene = 'cc.Scene',

		m_backLayer = 'cc.Scale9Sprite',
		m_errorLabel = 'cc.LabelTTF',

		m_errorStr = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ErrorPopup:init(str)
    self:load('empty.ui')
    UIManager:open(self, UIManager.POPUP, true)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ErrorPopup')

	self:initDebugLayer(str)
end

-------------------------------------
-- function initDebugLayer
-------------------------------------
function UI_ErrorPopup:initDebugLayer(str)
	local scr_size = cc.Director:getInstance():getWinSize()
	
	local rect = cc.rect(0, 0, 0, 0)
	self.m_backLayer = cc.Scale9Sprite:create(rect, 'res/ui/toast_notification.png')
	self.m_backLayer:setDockPoint(cc.p(0.5, 0.5))
    self.m_backLayer:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_backLayer:setNormalSize(scr_size)
	self.m_backLayer:setOpacity(200)
	self.root:addChild(self.m_backLayer, 1)
	
	-- error label
	local error_str = str or '???'
	
	self.m_errorLabel = cc.Label:createWithTTF(
		error_str,
		'res/font/common_font_01.ttf', 
		20, 
		1, -- stroke
		cc.size(scr_size['width'] - 200, scr_size['height']), 
		cc.TEXT_ALIGNMENT_LEFT, 
		cc.VERTICAL_TEXT_ALIGNMENT_CENTER)

	self.m_errorLabel:setDockPoint(cc.p(0.5, 0.5))
    self.m_errorLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_backLayer:addChild(self.m_errorLabel)
end