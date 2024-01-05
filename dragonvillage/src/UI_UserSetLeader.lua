local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_UserSetLeader
-------------------------------------
UI_UserSetLeader = class(PARENT, {
	m_tUserInfo = 'table',
})

-------------------------------------
-- function init
-------------------------------------
function UI_UserSetLeader:init(t_user_info)
    self.m_uiName = 'UI_UserSetLeader'
    self:load('user_info_dragon.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_UserSetLeader')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	self.m_tUserInfo = t_user_info
    self:initUI()
    self:initButton()
    self:initTab()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserSetLeader:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserSetLeader:initTab()
    local vars = self.vars

    local dragon_tab = UI_UserSetLeaderDragonTab(self.m_tUserInfo)
    local profile_frame_tab = UI_UserSetLeaderProfileFrameTab(self.m_tUserInfo)

    vars['indivisualTabMenu']:addChild(dragon_tab.root)
    vars['indivisualTabMenu']:addChild(profile_frame_tab.root)

    self:addTabWithTabUIAndLabel('dragon', vars['dragonTabBtn'], vars['dragonTabLabel'], dragon_tab)       -- 드래곤
    self:addTabWithTabUIAndLabel('profile_frame', vars['profileFrameTabBtn'], vars['profileFrameTabLabel'], profile_frame_tab) -- 프로필 테두리

    self:setTab('dragon')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserSetLeader:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserSetLeader:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_UserSetLeader:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_UserSetLeader)
