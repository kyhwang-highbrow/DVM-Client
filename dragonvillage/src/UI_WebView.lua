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
function UI_WebView:init(url, node)
    if isWin32() then return end 
    self.m_url = url

    local vars = self:load('popup_webview.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_WebView')
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
    local webview = CreateWebview(self.m_url, node)
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

-------------------------------------
-- function CreateWebview
-------------------------------------
function CreateWebview(url, node)
    if (not node) then return end
    local url = url
    local content_size = node:getContentSize()
    local webview = ccexp.WebView:create()
    webview:setContentSize(content_size.width, content_size.height)

    if (getAppVerNum() > AppVer_strToNum('1.0.1')) then
        webview:setOnShouldStartLoading(function(index, url)
            cclog('webview url '..url)
            if (url ~= nil) and (string.sub(url, 1, string.len('http://')) == 'http://') then
                SDKManager:goToWeb(url)
                return false
            end

            return true
        end)
    end

    webview:loadURL(url)
    webview:setBounces(false)
    webview:setAnchorPoint(cc.p(0,0))
    webview:setDockPoint(cc.p(0,0))

    return webview
end


--@CHECK
UI:checkCompileError(UI_WebView)
