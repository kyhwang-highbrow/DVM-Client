local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Banner
-------------------------------------
UI_EventPopupTab_Banner = class(PARENT,{
        m_structBannerData = 'StructEventPopupTab',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Banner:init(owner, struct_event_popup_tab)
    self.m_structBannerData = struct_event_popup_tab.m_eventData
    local res = self.m_structBannerData['banner']
    local is_ui_res = string.match(res, '%.ui') and true or false
    local target_ui = (is_ui_res == true) and res or 'event_banner.ui'
    local vars = self:load(target_ui) 
    
    -- 리소스가 png인 경우 이미지 추가
    if (is_ui_res == false) then
        local img = cc.Sprite:create(res)
        if img then
            img:setDockPoint(CENTER_POINT)
            img:setAnchorPoint(CENTER_POINT)
            vars['bannerNode']:addChild(img)
        end
    end

    local banner_btn = vars['bannerBtn']
    if (banner_btn) then
        banner_btn:registerScriptTapHandler(function() self:click_bannerBtn() end)
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventPopupTab_Banner:click_bannerBtn()
    local url = self.m_structBannerData['url']
    if (url == '') then 
        return 
    end

    g_eventData:goToEventUrl(url)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Banner:onEnterTab()
    local vars = self.vars
end