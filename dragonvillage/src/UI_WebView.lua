local PARENT = UI

-------------------------------------
-- class UI_WebView
-------------------------------------
UI_WebView = class(PARENT,{
        m_url = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_WebView:init(url)
    if isWin32() then return end 
    local vars = self:load('popup_webview.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_url = url

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_WebView')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WebView:initUI()
    local vars = self.vars
    local loading_node = vars['emptySprite']
    loading_node:setVisible(true)
    cca.pickMePickMe(loading_node)

    local node = vars['viewNode']
    local url = self.m_url
    local content_size = node:getContentSize()
    local webview = ccexp.WebView:create()
    webview:setContentSize(content_size.width, content_size.height)
    webview:loadURL(url)
    webview:setBounces(false)
    webview:setAnchorPoint(cc.p(0,0))
    webview:setDockPoint(cc.p(0,0))
    node:addChild(webview)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_WebView:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WebView:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_WebView:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_WebView)
