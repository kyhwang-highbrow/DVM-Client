local PARENT = UI

----------------------------------------------------------------------
-- class UI_BannerDmgate
----------------------------------------------------------------------
UI_BannerDmgate = class(PARENT,{
})

----------------------------------------------------------------------
-- class init
----------------------------------------------------------------------
function UI_BannerDmgate:init()
    self.m_uiName = 'UI_BannerDmgate'
    local vars = self:load('lobby_banner_dmgate.ui')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

--local text_color = TableFriendship:getTextColorWithFlv(flv)

----------------------------------------------------------------------
-- class initUI
----------------------------------------------------------------------
function UI_BannerDmgate:initUI()
end


----------------------------------------------------------------------
-- class initButton
----------------------------------------------------------------------
function UI_BannerDmgate:initButton()
    self.vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end


----------------------------------------------------------------------
-- class refresh
----------------------------------------------------------------------
function UI_BannerDmgate:refresh()
end

----------------------------------------------------------------------
-- class click_bannerBtn
----------------------------------------------------------------------
function UI_BannerDmgate:click_bannerBtn()
    if (not g_contentLockData:isContentLock('dmgate')) then
        UINavigator:goTo('dmgate')
    else
        local str = '입장 조건: {1}'

        local table_content_lock = TABLE:get('table_content_lock')
        local dmgate_data = table_content_lock['dmgate']
        
        local condition_str = UI_QuestListItem_Contents.makeConditionDesc(dmgate_data['req_stage_id'], dmgate_data['t_desc'])

        local text_color = self.vars['conditionLabel'].m_node:getTextColor()
        UIManager:toastNotification(Str(str, condition_str), text_color)
    end
end








----------------------------------------------------------------------
-- class UI_BannerAppCollaboration
----------------------------------------------------------------------
UI_BannerAppCollaboration = class(PARENT,{
})

----------------------------------------------------------------------
-- class init
----------------------------------------------------------------------
function UI_BannerAppCollaboration:init()
    self.m_uiName = 'UI_BannerAppCollaboration'
    local vars = self:load('lobby_banner_promotion.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

--local text_color = TableFriendship:getTextColorWithFlv(flv)

----------------------------------------------------------------------
-- class initUI
----------------------------------------------------------------------
function UI_BannerAppCollaboration:initUI()
end


----------------------------------------------------------------------
-- class initButton
----------------------------------------------------------------------
function UI_BannerAppCollaboration:initButton()
    self.vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end


----------------------------------------------------------------------
-- class refresh
----------------------------------------------------------------------
function UI_BannerAppCollaboration:refresh()
end

----------------------------------------------------------------------
-- class click_bannerBtn
----------------------------------------------------------------------
function UI_BannerAppCollaboration:click_bannerBtn()
    -- 주의 :: 따라하지 마시오
    --g_fullPopupManager:showFullPopup('event_dvnew_collaboration;event_cross_promotion.ui')
    SDKManager:goToWeb('https://01highbrow-inc.wixsite.com/website')
end









-- @CHECK
UI:checkCompileError(UI_BannerDmgate)
UI:checkCompileError(UI_BannerAppCollaboration)