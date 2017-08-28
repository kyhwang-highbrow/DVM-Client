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

    -- node가 있는 경우 node content size로 생성한 웹뷰만 반환
    if (node) then
        return self:createWebview(node)

    -- 없는 경우 전면 웹뷰 UI
    else
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
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WebView:createWebview(node)
    if (not node) then return end

    local url = self.m_url
    local content_size = node:getContentSize()
    local webview = ccexp.WebView:create()
    webview:setContentSize(content_size.width, content_size.height)

    if (getAppVerNum() > AppVer_strToNum('1.0.1')) then
        local mainUrl = nil
        webview:setOnShouldStartLoading(function(index, url)
            if mainUrl == nil then
                mainUrl = url
            else
                if url ~= nil and string.sub(url, 1, string.len('http://')) == 'http://' then
                    if mainUrl ~= url then
                        SDKManager:goToWeb(url)
                        return false
                    end
                end
            end
            return true
        end)
        webview:setOnDidFinishLoading(function(index, url)
            ui_wloading_node:setVisible(false)
        end)
    end

    webview:loadURL(url)
    webview:setBounces(false)
    webview:setAnchorPoint(cc.p(0,0))
    webview:setDockPoint(cc.p(0,0))

    return webview
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
    local webview = self:createWebview(node)
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
