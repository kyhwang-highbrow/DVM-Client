require 'perpleLib/PerpleScene'
require 'socket'
require 'TableViewTD'

local FONT_PATH = 'res/font/common_font_01.ttf'
local ENTRY_FILE = 'res/spine/godae_shinryong_01/godae_shinryong_01.spine'


-------------------------------------
-- class UI_UIViewer
-------------------------------------
UI_UIViewer = class(UI,{})

-------------------------------------
-- function init
-------------------------------------
function UI_UIViewer:init(res)
	ccdump(res)
	local vars = self:load(res)
	UIManager:open(self, UIManager.POPUP)
	self:doActionReset()
	self:doAction()
end

-------------------------------------
-- class Scene_UIViewer
-------------------------------------
Scene_UIViewer = class(PerpleScene,{
		m_munu = '',
		m_ui = '',
        m_list = '',
        m_tabMenu = '',
        m_uiFileNameList = {},
        m_textLabel = '',
        m_layer = '',
        m_viewSize = '',
        m_countPage = 'int',
        m_tempNode = '',

		m_uiName = 'string',
	})

-------------------------------------
-- function init
-------------------------------------
function Scene_UIViewer:init()
	self.m_uiName = 'adventure_chapter_window.ui'
	self.m_ui = nil

    self:createContent()

	-- 키보드 입력 처리
	local listener = cc.EventListenerKeyboard:create()
	listener:registerScriptHandler(function(keyCode, event) self:onKeyReleased(keyCode, event) end, cc.Handler.EVENT_KEYBOARD_RELEASED)
	local eventDispatcher = self.m_scene:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_scene)
end

-------------------------------------
-- function createContent
-------------------------------------
function Scene_UIViewer:createContent()
    local scrSize = cc.Director:getInstance():getWinSize()
    self.m_viewSize = cc.size(scrSize.width, scrSize.height)
    self.m_layer = cc.Node:create()
    self.m_layer:setAnchorPoint(0.5,0.5)
    self.m_layer:setContentSize(self.m_viewSize)
    self.m_scene:addChild(self.m_layer,5000)

    self.m_uiFileNameList = {}
    for dir in io.popen([[dir "C:\project\dragonvillage\frameworks\dragonvillage\res" /b ]]):lines() do
		if (string.find(dir,'.ui')) then 
			table.insert(self.m_uiFileNameList, dir)
			cclog("file : " .. dir)
		end
    end

    self:createUiSearchBar()
    self:createUitabViewer()
    self:createInfo()
end

-------------------------------------
-- function createUiSearchBar
-------------------------------------
function Scene_UIViewer:createUiSearchBar()
    self.m_munu = cc.Node:create()
	self.m_munu:setPosition(320, 500)
	self.m_munu:setVisible(false)
	self.m_layer:addChild(self.m_munu, 100)


	local function editBoxTextEventHandle(strEventName, pSender)
		local edit = pSender
		self.m_uiName = edit:getText()
		self:refresh()
	end

	local editBoxSize = cc.size(500, 40)
	local edit_box = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create('res/common/tool/a_button_0103.png'))
	edit_box:setFontSize(20)
	edit_box:setFontName(FONT_PATH)
	edit_box:setFontColor(cc.c3b(255,255,255))
	edit_box:setPlaceHolder('UI 파일명')
	edit_box:setPlaceholderFontColor(cc.c3b(255,0,0))
	edit_box:setMaxLength(20)
	edit_box:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
	edit_box:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	edit_box:registerScriptEditBoxHandler(editBoxTextEventHandle)
	edit_box:setText(self.m_uiName)
	self.m_munu:addChild(edit_box)

	edit_box:setPosition(0, 50)
	edit_box:setDockPoint(cc.p(0.5, 0))

end

-------------------------------------
-- function createUitabViewer
-------------------------------------
function Scene_UIViewer:createUitabViewer()
     -- UI tab 보기 // ScrollView -> Menu -> Button & TextLabel 구조
     cclog("create UI Tab Viewer")
    -- size 일괄 변경

    local buttonHeight = 54
    local buttonWidth = 330
    local textFontSize = 18
    local adjustmentForFacebookMark = 60

    local listWidth = self.m_viewSize.width/2 - adjustmentForFacebookMark
    local listHeight = self.m_viewSize.height

    ----------------------------------------------------------------------

    self.m_tabMenu = cc.Menu:create()
	self.m_tabMenu:setAnchorPoint(1, 0)
    self.m_tabMenu:setDockPoint(cc.p(1,0))
	self.m_tabMenu:setContentSize(self.m_viewSize)
    self.m_tabMenu:setSwallowTouch(false)
    self.m_tabMenu:setVisible(false)
    self.m_layer:addChild(self.m_tabMenu, 5000)

    for i,uiFileName in ipairs(self.m_uiFileNameList) do

	    local button = cc.MenuItemImage:create("", "", "")
	    button:setAnchorPoint(1,0)
        button:setDockPoint(cc.p(1,(i-1)*buttonHeight/listHeight))
        button:setContentSize( buttonWidth, buttonHeight )
        button:setOpacity(150)
        button:setTag(i)
        self.m_tabMenu:addChild(button)

        if uiFileName == self.m_uiName then
            button:setOpacity(255)
            self.m_tempNode=button
        end

        local textLabel = cc.Label:createWithTTF(
		  uiFileName
		, FONT_PATH
		, textFontSize
		, 1
		, cc.size(listWidth, buttonHeight)
		, cc.TEXT_ALIGNMENT_LEFT
		, cc.VERTICAL_TEXT_ALIGNMENT_CENTER
		)
        textLabel:setAnchorPoint(0, 0.5)
        textLabel:setOpacity(255)
        textLabel:setColor(cc.c3b(255,255,255))
        textLabel:setPosition( adjustmentForFacebookMark , buttonHeight/2 )
        button:addChild(textLabel,9999)

        button:registerScriptTapHandler(function()
			self:refreshButton(i)
		end)
	end

end

-------------------------------------
-- function createInfo
-------------------------------------
function Scene_UIViewer:createInfo()
    self.m_textLabel = cc.Label:createWithTTF(
		' L = List 탐색, M = 파일명 탐색, \n S = 액션 역실행, A = 액션 재실행 \n R = refresh, X = 안내문 삭제 \n 키보드 조작이 가능합니다.'
	, FONT_PATH
	, 25
	, 1
	)
    self.m_textLabel:setAnchorPoint(0.5, 0.5)
    self.m_textLabel:setColor(cc.c3b(255,255,255))
    self.m_textLabel:setPosition( 320, 1070 )
    self.m_scene:addChild(self.m_textLabel,3000)
end

-------------------------------------
-- function refreshButton
-------------------------------------
function Scene_UIViewer:refreshButton(num)
    self.m_uiName = self.m_uiFileNameList[num]
    local newSelectedNode = self.m_tabMenu:getChildByTag(num)

    self.m_tempNode:setOpacity(150)
    newSelectedNode:setOpacity(255)

    self.m_tempNode = newSelectedNode
	self:refresh()
end

-------------------------------------
-- function onEnter
-------------------------------------
function Scene_UIViewer:onEnter()
	PerpleScene.onEnter(self)

	--
	self:refresh()
end

-------------------------------------
-- function onExit
-------------------------------------
function Scene_UIViewer:onExit()
end

-------------------------------------
-- function onKeyReleased
-------------------------------------
function Scene_UIViewer:onKeyReleased(keyCode, event)

    local function createSimpleMoveBy(int)
        return cc.MoveBy:create(0.1, cc.p(0, self.m_viewSize.height*int))
    end

    local moveUP = createSimpleMoveBy(1)
    local moveDOWN = createSimpleMoveBy(-1)
    local tempIndex = table.find(self.m_uiFileNameList,self.m_uiName)

	-- A
    if keyCode == 121 then
		if self.m_ui then
			self.m_ui:doActionReset()
			self.m_ui:doAction()
		end

	-- S
    elseif keyCode == 139 then
		if self.m_ui then
			self.m_ui:doActionReverse()
		end

	-- R
    elseif keyCode == 138 then
		self:refresh()

    -- L
    elseif keyCode == 132 then
        cclog("L")
        if self.m_tabMenu then
			if self.m_tabMenu:isVisible() then
				self.m_tabMenu:setVisible(false)
			else
				self.m_tabMenu:setVisible(true)
			end
		end

    -- upArrow
    elseif keyCode == 25 then
        cclog('up')
        if tempIndex < #self.m_uiFileNameList then
            self:refreshButton(tempIndex+1)
        end
        if self.m_tempNode:getTag()%21 == 0 then
            if self.m_tabMenu:isVisible() then
                self.m_tabMenu:runAction(moveDOWN)
            end
        end

    -- downArrow
    elseif keyCode == 26 then
        cclog('down')
        if tempIndex > 1 then
            self:refreshButton(tempIndex-1)
        end
        if self.m_tempNode:getTag()%21 == 0 then
            if self.m_tabMenu:isVisible() then
                self.m_tabMenu:runAction(moveUP)
            end
        end

    -- leftArrow
    elseif keyCode == 23 then
        cclog('left')
        if self.m_tabMenu:isVisible() then
            self.m_tabMenu:runAction(moveUP)
        end

    -- rightArrow
    elseif keyCode == 24 then
        cclog('right')
        if self.m_tabMenu:isVisible() then
            self.m_tabMenu:runAction(moveDOWN)
        end


	-- M
    elseif keyCode == 133 then
		if self.m_munu then
			if self.m_munu:isVisible() then
				self.m_munu:setVisible(false)
			else
				self.m_munu:setVisible(true)
			end
		end

    -- X
    elseif keyCode == 144 then
        if self.m_textLabel then
			if self.m_textLabel:isVisible() then
				self.m_textLabel:setVisible(false)
			else
				self.m_textLabel:setVisible(true)
			end
		end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function Scene_UIViewer:refresh()
	if self.m_ui then
		self.m_ui:close()
		self.m_ui = nil
	end

	UILoader.clearCache()

	local start_time = socket.gettime()
	UILoader.cache(self.m_uiName)
	local cache_time = socket.gettime()
	self.m_ui = UI_UIViewer(self.m_uiName)
	local make_time = socket.gettime()

	cclog('----------------------------------------------------')
	cclog(self.m_uiName)
	cclog('----------------------------------------------------')
	cclog(string.format('총 소요시간 : %f', make_time - start_time))
	cclog(string.format('파일 로드 시간 : %f', cache_time - start_time))
	cclog(string.format('UI 생성 시간 : %f', make_time - cache_time))
	cclog('----------------------------------------------------')
end