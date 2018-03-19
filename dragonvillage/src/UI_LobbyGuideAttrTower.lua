local PARENT = UI

-------------------------------------
-- class UI_LobbyGuideAttrTower
-------------------------------------
UI_LobbyGuideAttrTower = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LobbyGuideAttrTower:init()
	local vars = self:load('lobby_guide_attr_tower.ui')
	UIManager:open(self, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_LobbyGuideAttrTower')

	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

	self:initUI()
	self:initButton()
	self:refresh()

    self:sceneFadeInAction()

	SoundMgr:playBGM('bgm_lobby')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LobbyGuideAttrTower:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LobbyGuideAttrTower:initButton()
    local vars = self.vars
    vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LobbyGuideAttrTower:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_bannerBtn
-- @brief 바로가기
-------------------------------------
function UI_LobbyGuideAttrTower:click_bannerBtn()
    -- 고대의 탑으로 이동
    UINavigator:goTo('ancient')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_LobbyGuideAttrTower:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_LobbyGuideAttrTower)