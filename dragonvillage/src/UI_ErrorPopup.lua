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
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ErrorPopup')

	self:initUI()
	self:initButton()
	self:setErrorStr(str)
end

-------------------------------------
-- function initDebugLayer
-------------------------------------
function UI_ErrorPopup:initUI(str)
	local scr_size = cc.Director:getInstance():getWinSize()
	
	-- 검은색 배경
	do
		local rect = cc.rect(0, 0, 0, 0)
		self.m_backLayer = cc.Scale9Sprite:create(rect, 'res/ui/toast_notification.png')
		self.m_backLayer:setDockPoint(cc.p(0.5, 0.5))
		self.m_backLayer:setAnchorPoint(cc.p(0.5, 0.5))
		self.m_backLayer:setNormalSize(scr_size)
		self.m_backLayer:setOpacity(200)
		self.root:addChild(self.m_backLayer, 0)
	end

	-- error label
	do
		self.m_errorLabel = cc.Label:createWithTTF(
			'',
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

	-- 복사 버튼
	do
	    local node = cc.MenuItemImage:create('res/ui/btn/base_0206.png', 'res/ui/btn/base_0207.png', 1)
        node:setDockPoint(cc.p(0.5, 0))
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setPosition(-100, 50)
        UIC_Button(node)
        self.root:addChild(node, 1)
        self.vars['copyBtn'] = node

		local label = cc.Label:createWithTTF('복사',	'res/font/common_font_01.ttf', 20, 1, cc.size(100, 50),	cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		label:setDockPoint(CENTER_POINT)
        label:setAnchorPoint(CENTER_POINT)
		self.vars['copyBtn']:addChild(label)
	end

	-- 닫기 버튼
	do
	    local node = cc.MenuItemImage:create('res/ui/btn/base_0206.png', 'res/ui/btn/base_0207.png', 1)
        node:setDockPoint(cc.p(0.5, 0))
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setPosition(100, 50)
        UIC_Button(node)
        self.root:addChild(node, 1)
        self.vars['exitBtn'] = node

		local label = cc.Label:createWithTTF('닫기',	'res/font/common_font_01.ttf', 20, 1, cc.size(100, 50),	cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER) 
		label:setDockPoint(CENTER_POINT)
        label:setAnchorPoint(CENTER_POINT)
		self.vars['exitBtn']:addChild(label)
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ErrorPopup:initButton()
	self.vars['copyBtn']:registerScriptTapHandler(function() self:click_copyBtn() end)
	self.vars['exitBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function setErrorStr
-------------------------------------
function UI_ErrorPopup:setErrorStr(str)
	local error_str = string.gsub(str, '\t', '    ') or '???'
	self.m_errorLabel:setString(error_str)

    slack_api(error_str)
end

-------------------------------------
-- function click_copyBtn
-------------------------------------
function UI_ErrorPopup:click_copyBtn()
	UIManager:toastNotificationGreen('클립보드 복사 기능 준비중')
end


-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ErrorPopup:click_exitBtn()
    self:close()
	IS_OPEN_ERROR_POPUP = false
end


__G__ERROR_POPUP = UI_ErrorPopup