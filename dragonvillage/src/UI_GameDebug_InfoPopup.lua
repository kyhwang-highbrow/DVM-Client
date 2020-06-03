local PARENT = UI

-------------------------------------
-- class UI_GameDebug_InfoPopup
-- @brief 인게임 정보를 화면에 찍어준다.
-------------------------------------
UI_GameDebug_InfoPopup = class(PARENT, {
		m_endCB = 'function',

		m_backLayer = 'cc.Scale9Sprite',
		m_infoLabel = 'cc.LabelTTF',

		m_infoStr = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GameDebug_InfoPopup:init(str, end_cb)
    self.m_endCB = end_cb

    self:load('empty.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_GameDebug_InfoPopup'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_GameDebug_InfoPopup')

	self:initUI()
	self:initButton()
    self:setInfoStr(str)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameDebug_InfoPopup:initUI()
	local scr_size = cc.Director:getInstance():getWinSize()
	
	-- 검은색 배경
	do
		local rect = cc.rect(0, 0, 0, 0)
		self.m_backLayer = cc.Scale9Sprite:create(rect, 'res/ui/toast_notification.png')
		self.m_backLayer:setDockPoint(CENTER_POINT)
		self.m_backLayer:setAnchorPoint(CENTER_POINT)
		self.m_backLayer:setNormalSize(scr_size)
		self.m_backLayer:setOpacity(170)
		self.root:addChild(self.m_backLayer, 0)
	end

	-- info label
	do
		-- rich_label 생성
		local rich_label = UIC_RichLabel()
		rich_label:setDimension(1000, 600)
		rich_label:setFontSize(20)
		rich_label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		rich_label:enableOutline(cc.c4b(0, 0, 0, 127), 1)
        rich_label:setDefualtColor(COLOR['white'])

		-- scroll label  생성
		self.m_infoLabel = UIC_ScrollLabel:create(rich_label)
		self.m_infoLabel:setDockPoint(CENTER_POINT)
		self.m_infoLabel:setAnchorPoint(CENTER_POINT)
		self.m_backLayer:addChild(self.m_infoLabel.m_node)
	end

    local btn_res_1 = 'res/ui/buttons/64_base_btn_0101.png'
    local btn_res_2 = 'res/ui/buttons/64_base_btn_0102.png'
    local common_dock = cc.p(1, 0.5)
    local common_anchor = cc.p(1, 0.5)
    local common_size = cc.size(200, 80)

    -- 생성할 버튼 정보
    local l_btn = {
        {btn_str = 'Copy', lua_name = 'copyBtn', pos = {x = -20, y = 100}},
        {btn_str = 'Report', lua_name = 'slackBtn', pos = {x = -20, y = 0}},
        {btn_str = 'Close', lua_name = 'exitBtn', pos = {x = -20, y = -100}},
    }

    for _, t_btn_info in pairs(l_btn) do
        local pos = t_btn_info['pos']
        local lua_name = t_btn_info['lua_name']
        local btn_str = t_btn_info['btn_str']

        -- button
	    local node = cc.MenuItemImage:create(btn_res_1, btn_res_2, 1)
        node:setDockPoint(common_dock)
        node:setAnchorPoint(common_anchor)
        node:setPosition(pos.x, pos.y)
        node:setContentSize(common_size)
        UIC_Button(node)
        self.root:addChild(node, 1)
        self.vars[lua_name] = node

        -- label
		local label = cc.Label:createWithTTF(btn_str, Translate:getFontPath(), 20, 1, cc.size(100, 50),	cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        label:setColor(COLOR['DESC'])
		label:setDockPoint(CENTER_POINT)
        label:setAnchorPoint(CENTER_POINT)
		self.vars[lua_name]:addChild(label)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GameDebug_InfoPopup:initButton()
    local vars = self.vars

	vars['copyBtn']:registerScriptTapHandler(function() self:click_copyBtn() end)
    vars['slackBtn']:registerScriptTapHandler(function() self:click_slackBtn() end)
	vars['exitBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function setInfoStr
-------------------------------------
function UI_GameDebug_InfoPopup:setInfoStr(str)
    if (not str) then
		cclog('setInfoStr:setInfoStr(str) : nil parameter')
	end
    
	self.m_infoLabel:setString(str)
    self.m_infoStr = str
end

-------------------------------------
-- function click_copyBtn
-------------------------------------
function UI_GameDebug_InfoPopup:click_copyBtn()
	SDKManager:copyOntoClipBoard(self.m_infoStr)
	UIManager:toastNotificationGreen('클립보드 복사 완료!')
end

-------------------------------------
-- function click_slackBtn
-------------------------------------
function UI_GameDebug_InfoPopup:click_slackBtn()
    local info_str = self.m_infoStr
    slack_api(info_str)
    UIManager:toastNotificationGreen('전송 완료!')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_GameDebug_InfoPopup:click_exitBtn()
    if (self.m_endCB) then
        self.m_endCB()
    end

    self:close()
end