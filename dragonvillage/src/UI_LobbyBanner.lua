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
    m_eventData = 'StructEvent',
})

----------------------------------------------------------------------
-- class init
----------------------------------------------------------------------
function UI_BannerAppCollaboration:init(event_data)
    self.m_uiName = 'UI_BannerAppCollaboration'
    -- 설치 페이지
    -- https://app.adjust.com/1ctll5t
    local ui_name = event_data.m_eventData['lobby_banner']


    local vars = self:load(ui_name)

    self.m_eventData = event_data

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
	g_fullPopupManager:showFullPopup('event_crosspromotion')
end





----------------------------------------------------------------------
-- class UI_LobbyBanner
----------------------------------------------------------------------
UI_LobbyBanner = class(PARENT,{
    m_eventData = 'StructEvent',
    m_parentUI = 'UI_Lobby'
})

----------------------------------------------------------------------
-- class init
----------------------------------------------------------------------
function UI_LobbyBanner:init(event_data, parent)
    self.m_uiName = 'UI_LobbyBanner'
    self.m_parentUI = parent

    local ui_name = event_data.m_eventData['lobby_banner']
    local vars = self:load(ui_name)

    self.m_eventData = event_data

    self:initUI()
    self:initButton()
    self:refresh()
end

--local text_color = TableFriendship:getTextColorWithFlv(flv)

----------------------------------------------------------------------
-- class initUI
----------------------------------------------------------------------
function UI_LobbyBanner:initUI()
    local vars = self.vars

    local url = self.m_eventData.m_eventData['url']
    local event_type = self.m_eventData.m_eventData['event_type']
    local parent_ui = self.m_parentUI
    local noti = parent_ui.m_bannerNoti

    if (event_type == 'event_newserver') and noti then
        vars['notiSprite']:setVisible(true)
    end
end


----------------------------------------------------------------------
-- class initButton
----------------------------------------------------------------------
function UI_LobbyBanner:initButton()
    self.vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end


----------------------------------------------------------------------
-- class refresh
----------------------------------------------------------------------
function UI_LobbyBanner:refresh()
end

----------------------------------------------------------------------
-- class click_bannerBtn
----------------------------------------------------------------------
function UI_LobbyBanner:click_bannerBtn()
    local url = self.m_eventData.m_eventData['url']
    local event_type = self.m_eventData.m_eventData['event_type']

    if (url ~= nil) and (url ~= '') then
        SDKManager:goToWeb(url)
    elseif (event_type == 'event_crosspromotion') then
	    g_fullPopupManager:showFullPopup(event_type)
    --죄악의 화신 현물 이벤트 및 현물 보상 풀팝업
    elseif (event_type == 'event_newserver') then
        self.m_parentUI.m_bannerNoti = false
        -- 이벤트 활성화중 아님
        if (not g_eventIncarnationOfSinsData:isActive()) then
            return
        
        -- 본 이벤트 기간
        elseif (g_eventIncarnationOfSinsData:canPlay()) then
            g_eventData:openEventPopup('event_incarnation_of_sins')
        -- 보상 수령 및 랭킹확인 기간
        else 
            g_eventIncarnationOfSinsData:openRankingPopupForLobby()
        end 
    end
end









-- @CHECK
UI:checkCompileError(UI_BannerDmgate)
UI:checkCompileError(UI_BannerAppCollaboration)