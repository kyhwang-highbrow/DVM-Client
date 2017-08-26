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
        local loading_node = vars['emptySprite']
        loading_node:setVisible(true)
        cca.pickMePickMe(loading_node)

        local node = vars['webviewNode']
        local url = self.m_structBannerData['url']
        local content_size = node:getContentSize()
        local webview = ccexp.WebView:create()
        webview:setContentSize(content_size.width, content_size.height)

        if (getAppVerNum() > AppVer_strToNum('1.0.1')) then
            webview:setOnDidFinishLoading(function(index, url)
                loading_node:setVisible(false)
            end)
        end

        webview:loadURL(url)
        webview:setBounces(false)
        webview:setAnchorPoint(cc.p(0,0))
        webview:setDockPoint(cc.p(0,0))
        node:addChild(webview)

        self.m_webView = webview
    end
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Notice:onEnterTab()
end