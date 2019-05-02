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

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdventureScene_Illusion:initButton()
    local vars = self.vars

    for difficulty = 1, 4 do
        vars['stageBtn0'..difficulty]:registerScriptTapHandler(function() self:click_stage(difficulty) end)
    end
end

-------------------------------------
-- function click_stage
-------------------------------------
function UI_AdventureScene_Illusion:click_stage(difficulty)
    -- 임의로 죄악의 던전
    local stage_id = g_illusionDungeonData:makeAdventureID(difficulty, 1) -- param : difficulty, stage
    UI_ReadySceneNew_IllusionDungeon(stage_id)
end



