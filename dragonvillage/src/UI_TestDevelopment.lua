require('UI_TestDevelopmentListItem')

local PARENT = UI


-------------------------------------
-- class UI_TestDevelopment
-------------------------------------
UI_TestDevelopment = class(PARENT, {
        m_buttonTableView = 'UIC_TableView',
        m_chatTableView = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TestDevelopment:init()
    local vars = self:load('empty.ui')

    self:initUI()
    self:initButton()
    self:refresh()

    UIManager:open(self, UIManager.SCENE)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TestDevelopment:initUI()

-- UI Layout
-- ---------------------------------
-- |          Title Label     close|
-- |-------------------------------|
-- |               |               |
-- |               |               |
-- |     button    | log(message)  |
-- |   table view  |  list view    |
-- |               |               |
-- |               |               |
-- |               |               |
-- ---------------------------------

    local vars = self.vars

    
    do -- 배경
        local animator = MakeAnimator('bg/ui/dragon_bg_earth/dragon_bg_earth.vrp')
        animator:changeAni('idle', true)
        self.root:addChild(animator.m_node)
        animator:setDockPoint(0.5, 0.5)
        animator:setAnchorPoint(0.5, 0.5)
        animator:setPosition(0, 0)
    end

    -- LayerColor (배경을 조금 어둡게 처리하기 위해)
    do
        local layer = cc.LayerColor:create()
        layer:setAnchorPoint(cc.p(0.5, 0.5))
        layer:setDockPoint(cc.p(0.5, 0.5))

        -- relativesize 타입
        RELATIVE_SIZE_NONE = 0
        RELATIVE_SIZE_VERTICAL = 1
        RELATIVE_SIZE_HORIZONTAL = 2
        RELATIVE_SIZE_BOTH = 3

        layer:setRelativeSizeAndType(cc.size(0, 0), RELATIVE_SIZE_BOTH, true) -- param : size(cc.size), type(int), update(bool)
        layer:setColor(cc.c3b(0, 0, 0))
        layer:setOpacity(180)
        self.root:addChild(layer)
    end

    -- 닫기 버튼
    if true then 
        local node = cc.MenuItemImage:create('ui/buttons/64_close_btn_0101.png', 'ui/buttons/64_close_btn_0102.png', 1)
        local width, height = node:getNormalSize()
        node:setPosition(-(width/2), -(height/2))
        node:setDockPoint(cc.p(1, 1))
        self.root:addChild(node)
        node:setAnchorPoint(cc.p(0.5, 0.5))

        local uic_button = UIC_Button(node)

        uic_button:registerScriptTapHandler(function()
            self:close()
        end)
    end

    -- 로그창 (메세지)
    if true then
        local visibleSize = cc.Director:getInstance():getVisibleSize()

        local uic_node = UIC_Node:create()
        uic_node:initGLNode()
        local width = (visibleSize.width/2) - 30
        local height = visibleSize.height - 75
        uic_node:setNormalSize(width, height)
        
        self.root:addChild(uic_node.m_node)

        uic_node:setDockPoint(cc.p(0.75, 1))
        uic_node:setAnchorPoint(cc.p(0.5, 1))
        uic_node:setPosition(-5, -65)

        self.m_chatTableView = UIC_ChatView(uic_node.m_node)

        do -- sample
            --[[
            local chat_content = ChatContent()
            chat_content['nickname'] = '닉넴'
            chat_content['uid'] = 102893
            chat_content['message'] = '안녕하세요 ' .. i
            self.m_chatTableView:addChatContent(chat_content)
            --]]
        end
    end


    -- 왼쪽 버튼
    if true then
        local visibleSize = cc.Director:getInstance():getVisibleSize()

        local uic_node = UIC_Node:create()
        uic_node:initGLNode()
        local width = (visibleSize.width/2) - 30
        local height = visibleSize.height - 75
        uic_node:setNormalSize(width, height)
        
        self.root:addChild(uic_node.m_node)

        uic_node:setDockPoint(cc.p(0.25, 1))
        uic_node:setAnchorPoint(cc.p(0.5, 1))
        uic_node:setPosition(5, -65)

        --------------------

        -- 생성 콜백
        local function create_func(ui, data)
            --[[
            local function click_func()
                self:click_inviteAcceptBtn(data)
            end

            ui.vars['acceptBtn']:registerScriptTapHandler(click_func)

            local function click_refuseBtn()
                self:click_inviteRefuseBtn(data)
            end
            ui.vars['refuseBtn']:registerScriptTapHandler(click_refuseBtn)
            --]]
        end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableViewTD(uic_node.m_node)
        table_view.m_cellSize = cc.size((width / 2), 100)
        table_view.m_nItemPerCell = 2
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setCellUIClass(UI_TestDevelopmentListItem, create_func)
        table_view:makeDefaultEmptyDescLabel(Str(''))
        table_view:setItemList({})
        self.m_buttonTableView = table_view
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TestDevelopment:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_TestDevelopment:refresh()
    local vars = self.vars
end

-------------------------------------
-- function addTestButton
-- @breif 버튼 추가
-------------------------------------
function UI_TestDevelopment:addTestButton(btn_key, btn_name, btn_click_cb)
    if (self.m_buttonTableView == nil) then
        return
    end

    local unique_id = btn_key
    local t_data = {}
    t_data['name'] = btn_name
    t_data['cb'] = btn_click_cb
    self.m_buttonTableView:addItem(unique_id, t_data)
end

-------------------------------------
-- function addLogMessage
-- @breif 로그 메세지 추가
-------------------------------------
function UI_TestDevelopment:addLogMessage(msg)
    if (self.m_chatTableView == nil) then
        return
    end

    local chat_content = ChatContent()
    chat_content['message'] = tostring(msg)
    self.m_chatTableView:addChatContent(chat_content)
end

-------------------------------------
-- function sampleCode
-- @brief
-------------------------------------
function UI_TestDevelopment:sampleCode()
    local test_development_ui = UI_TestDevelopment()

    -- 버튼 추가
    test_development_ui:addTestButton('btn_1', '버튼 이름 btn1', function() test_development_ui:addLogMessage('click btn1') end) -- btn_key, btn_name, btn_click_cb

    -- 로그 메세지 추가
    test_development_ui:addLogMessage('-----------------\n테스트를 시작합니다.\n-----------------')




    -- 버튼 100개 추가 테스트 코드
    for i=1, 100 do
        local btn_key = 'btn' .. i
        local btn_name = '테스트' .. i
        local btn_click_cb = function()
            cclog('클릭' .. i)
            test_development_ui:addLogMessage('클릭' .. i .. '\n개행확인')
        end

        test_development_ui:addTestButton(btn_key, btn_name, btn_click_cb)
    end
end