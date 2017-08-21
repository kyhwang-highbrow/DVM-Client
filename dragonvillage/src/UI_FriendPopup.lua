local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-- 'friends'    친구 목록
-- 'recommend'  추천 친구
-- 'request'    친구 요청
-- 'invite'     초대하기

-------------------------------------
-- class UI_FriendPopup
-------------------------------------
UI_FriendPopup = class(PARENT, {
        m_tTabClass = 'table',
        m_hilightTimeStamp = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPopup:init()
	local vars = self:load('friend.ui')
	UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_FriendPopup')

	-- @UI_ACTION
	--self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
	self:doActionReset()
	self:doAction(nil, false)

	self:initUI()
	self:initButton()
	self:refresh()

    -- 로비 진입후 친구 팝업 뜨기 전까지의 받은 요청이 있을 수 있음, 진입시 하일라이트 정보 갱신!
    g_highlightData:request_highlightInfo(function() self:initHighlight() end)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_FriendPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_FriendPopup'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('친구')
    self.m_subCurrency = 'fp'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendPopup:initUI()
    self:initFrinedPopupTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendPopup:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendPopup:refresh()
    g_topUserInfo:refreshData()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_FriendPopup:click_exitBtn()
    self:close()

    -- 노티 정보를 갱신하기 위해서 호출
    g_highlightData:setLastUpdateTime()
end

-------------------------------------
-- function initHighlight
-- @brief 최초 진입시에만 서버 하일라이트 정보 적용 
-------------------------------------
function UI_FriendPopup:initHighlight()
    local vars = self.vars

    -- 우정 포인트 보내기 가능한 상태
    vars['listNotiSprite']:setVisible(g_highlightData:isHighlightFpointSend())

    -- 받은 요청 있는 상태 
    vars['responseNotiSprite']:setVisible(g_highlightData:isHighlightFrinedInvite()) 
end

-------------------------------------
-- function refreshHighlightFriend
-- @brief 진입후에는 친구 api 통신후 클라에서 갱신
-------------------------------------
function UI_FriendPopup:refreshHighlightFriend(visible)
    local vars = self.vars
    vars['listNotiSprite']:setVisible(visible)
end

-------------------------------------
-- function refreshHighlightResponse
-- @brief 진입후에는 친구 api 통신후 클라에서 갱신
-------------------------------------
function UI_FriendPopup:refreshHighlightResponse(visible)
    local vars = self.vars
    vars['responseNotiSprite']:setVisible(visible)
end

--------------------------------------------------------------------
--------------------------------------------------------------------
-- TAB 관련

-------------------------------------
-- function initFrinedPopupTab
-------------------------------------
function UI_FriendPopup:initFrinedPopupTab()
    self.m_tTabClass = {}
    self.m_tTabClass['friends'] = UI_FriendPopupTabFriends(self)
    self.m_tTabClass['recommend'] = UI_FriendPopupTabRecommend(self)
    self.m_tTabClass['response'] = UI_FriendPopupTabResponse(self)
    self.m_tTabClass['request'] = UI_FriendPopupTabRequest(self)

    local vars = self.vars
    self:addTabWithLabel('friends', vars['listTabBtn'], vars['listTabLabel'], vars['listMenu'])
    self:addTabAuto('recommend', vars, vars['recommendMenu2'])
    self:addTabAuto('response', vars, vars['responseNode']) -- 받은 요청
    self:addTabAuto('request', vars, vars['requestNode']) -- 보낸 요청
    
    self:setTab('friends')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_FriendPopup:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)

    if (not self.m_tTabClass[tab]) then
        return
    end

    self.m_tTabClass[tab]:onEnterFriendPopupTab(first)
end

--------------------------------------------------------------------
--------------------------------------------------------------------

--@CHECK
UI:checkCompileError(UI_FriendPopup)