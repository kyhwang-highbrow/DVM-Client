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
    UIManager:open(self, UIManager.ERROR_POPUP, true)

    self.m_uiName = 'UI_ErrorPopup'

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
		self.m_backLayer = cc.Scale9Sprite:create(rect, 'res/ui/temp/toast_notification.png')
		self.m_backLayer:setDockPoint(CENTER_POINT)
		self.m_backLayer:setAnchorPoint(CENTER_POINT)
		self.m_backLayer:setNormalSize(scr_size)
		self.m_backLayer:setOpacity(170)
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
        rich_label:setDefualtColor(COLOR['white'])

		-- scroll label  생성
		self.m_errorLabel = UIC_ScrollLabel:create(rich_label)
		self.m_errorLabel:setDockPoint(CENTER_POINT)
		self.m_errorLabel:setAnchorPoint(CENTER_POINT)
		self.m_backLayer:addChild(self.m_errorLabel.m_node)
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

    self:initEditbox()
end

-------------------------------------
-- function initEditbox
-------------------------------------
function UI_ErrorPopup:initEditbox()
    -- 에러 레포트 시 에러 메세지 담기위한 edit box
    local normalBG = cc.Scale9Sprite:create(EMPTY_PNG)
    local editbox = cc.EditBox:create(cc.size(100, 100), normalBG)
    editbox:setPlaceHolder('제보자, 상세 내용을 입력해주세요!\nex)[문성] 모험 맵 진입 시 발생')
    editbox:setVisible(false)
    self.root:addChild(editbox)
    self.vars['report_editbox'] = editbox
    
    -- editBox handler 등록
	local function editBoxTextEventHandle(strEventName, pSender)
        -- 참고로 확인 / 취소 모두 return event가 발생한다.
        if (strEventName == "return") then
            if (pSender:getText() == '') then
                UIManager:toastNotificationRed('메세지를 입력하지 않으면 전송되지 않습니다.')
            else
                local error_str = string.format('%s\nmsg : %s', self.m_errorStr, pSender:getText())
                slack_api(error_str)
                UIManager:toastNotificationGreen('에러 로그 전송 완료!')
            end
        end
    end
    editbox:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ErrorPopup:initButton()
    local vars = self.vars

	vars['copyBtn']:registerScriptTapHandler(function() self:click_copyBtn() end)
    vars['slackBtn']:registerScriptTapHandler(function() self:click_slackBtn() end)
	vars['exitBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function setErrorStr
-- @brief setstring 및 저장
-------------------------------------
function UI_ErrorPopup:setErrorStr(str)
	if (not str) then
		cclog('UI_ErrorPopup:setErrorStr(str) : nil parameter')
        str = 'null parameter'
	end

	self.m_errorLabel:setString(str)
    self.m_errorStr = str
end

-------------------------------------
-- function click_copyBtn
-------------------------------------
function UI_ErrorPopup:click_copyBtn()
    SDKManager:copyOntoClipBoard(self.m_errorStr)
	UIManager:toastNotificationGreen('클립보드 복사 완료!')
end

-------------------------------------
-- function click_slackBtn
-------------------------------------
function UI_ErrorPopup:click_slackBtn()
    self.vars['report_editbox']:openKeyboard()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ErrorPopup:click_exitBtn()
    self:close()
end