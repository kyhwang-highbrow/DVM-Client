local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Notice
-------------------------------------
UI_EventPopupTab_Notice = class(PARENT,{
        m_structBannerData = 'StructBannerData',
        m_webView = 'ccexp.WebView',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Notice:init(owner, struct_event_popup_tab)
    local vars = self:load('event_notice.ui')
    self.m_structBannerData = struct_event_popup_tab.m_eventData
    self.m_webView = nil

    do
        if isWin32() then return end 
        local node = vars['webviewNode']

        -- 공지 홈페이지 나오면 연결
        local url = self.m_structBannerData['url']

        local content_size = node:getContentSize()
        local webview = ccexp.WebView:create()
        webview:setContentSize(content_size.width, content_size.height)
        webview:loadURL(url)
        webview:setBounces(false)
        webview:setAnchorPoint(cc.p(0,0))
        webview:setDockPoint(cc.p(0,0))

        --webview:setVisible(false)
        --[[
        local function callbackFromJS()
            webview:setVisible(true)
        end
        webview:setOnJSCallback(callbackFromJS)
        ]]--

        node:addChild(webview)

        self.m_webView = webview
    end
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Notice:onEnterTab()
    local vars = self.vars
    if (self.m_webView) then
        self.m_webView:setVisible(true)
    end
end