local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Banner
-------------------------------------
UI_EventPopupTab_Banner = class(PARENT,{
        m_structBannerData = 'StructBannerData',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Banner:init(owner, struct_event_popup_tab)
    local vars = self:load('event_banner.ui')
    self.m_structBannerData = struct_event_popup_tab.m_eventData

    -- 배너 이미지 (클릭시 웹뷰로 연결)
    do
        local res = self.m_structBannerData['banner']
        local img = cc.Sprite:create(res)
        if img then
            img:setDockPoint(cc.p(0.5, 0.5))
            img:setAnchorPoint(cc.p(0.5, 0.5))
            vars['bannerNode']:addChild(img)
        end

        vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventPopupTab_Banner:click_bannerBtn()
    local url = self.m_structBannerData['url']
    -- 브라우저로 변경
    SDKManager:goToWeb(url)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Banner:onEnterTab()
    local vars = self.vars
end