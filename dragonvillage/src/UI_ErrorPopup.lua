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
		-- rich_label 생성
		local rich_label = UIC_RichLabel()
		rich_label:setDimension(1000, 600)
		rich_label:setFontSize(20)
		rich_label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		rich_label:enableOutline(cc.c4b(0, 0, 0, 127), 1)

		-- scroll label  생성
		self.m_errorLabel = UIC_ScrollLabel:create(rich_label)
		self.m_errorLabel:setDockPoint(CENTER_POINT)
		self.m_errorLabel:setAnchorPoint(CENTER_POINT)
		self.m_backLayer:addChild(self.m_errorLabel.m_node)
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
	if (not str) then
		cclog('UI_ErrorPopup:setErrorStr(str) : nil parameter')
	end

	local error_str = string.gsub(str, '\t', '    ') or '???'
	if (__G__NOT_EXIST_RES) then
		error_str = '### 리소스가 없어 발생한 문제입니다. :D ###\n  -- 없는 리소스 : ' .. __G__NOT_EXIST_RES .. ' --\n\n' .. error_str
		__G__NOT_EXIST_RES = nil
	end

	self.m_errorLabel:setString(error_str)

	if (not DEVELOPMENT_SRC_VER) or (not isWin32()) then
		slack_api(error_str)
	end
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