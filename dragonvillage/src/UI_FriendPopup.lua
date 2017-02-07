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
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPopup:init()
	local vars = self:load('friend.ui')
	UIManager:open(self, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_FriendPopup')

	-- @UI_ACTION
	--self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
	self:doActionReset()
	self:doAction(nil, false)

	self:initUI()
	self:initButton()
	self:refresh()
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
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendPopup:initUI()
    self:initFrinedPopupTab()

    -- 임시 비활성
    local vars = self.vars
    vars['drawBtn']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendPopup:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_FriendPopup:click_exitBtn()
    self:close()
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
    self.m_tTabClass['request'] = UI_FriendPopupTabRequest(self)
    self.m_tTabClass['invite'] = UI_FriendPopupTabInvite(self)

    local vars = self.vars
    self:addTab('friends', vars['listBtn'], vars['listMenu'])
    self:addTab('recommend', vars['recommendBtn'], vars['recommendNode1'], vars['recommendMenu2'])
    self:addTab('request', vars['requestBtn'], vars['requestNode'])
    self:addTab('invite', vars['inviteBtn'], vars['inviteMenu'])
    self:addTab('support', vars['supportBtn'], vars['supportNode'])
    

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