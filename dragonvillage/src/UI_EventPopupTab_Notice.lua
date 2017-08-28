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
        if isWin32() then 
            return 
        end 

        local loading_node = vars['emptySprite']
        loading_node:setVisible(true)
        cca.pickMePickMe(loading_node)

        local node = vars['webviewNode']
        local url = self.m_structBannerData['url']
        local webview = UI_WebView(url, node)
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