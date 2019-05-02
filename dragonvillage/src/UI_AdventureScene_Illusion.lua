local PARENT = UI


-------------------------------------
-- class UI_AdventureScene_Illusion
-------------------------------------
UI_AdventureScene_Illusion = class(PARENT, {
       
     })

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_AdventureScene_Illusion:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AdventureScene_Illusion'
    self.m_bUseExitBtn = true
    self.m_uiBgm = 'bgm_dungeon_ready'
end

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureScene_Illusion:init()
	local vars = self:load('event_illusion_dungeon_scene.ui')
	UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AdventureScene_Illusion')

	self:initUI()
	self:initButton()
	self:refresh()
end

