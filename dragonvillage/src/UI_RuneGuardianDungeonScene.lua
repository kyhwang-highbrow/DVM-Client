local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_RuneGuardianDungeonScene
-------------------------------------
UI_RuneGuardianDungeonScene = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneGuardianDungeonScene:init()
    local vars = self:load('rune_guardian_dungeon_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_RuneGuardianDungeonScene')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_RuneGuardianDungeonScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_RuneGuardianDungeonScene'
    self.m_titleStr = Str('룬 수호자 던전')
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneGuardianDungeonScene:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneGuardianDungeonScene:initButton() 
    local vars = self.vars

    vars['stageBtn01']:registerScriptTapHandler(function() self:click_stageBtn(1700011) end)
    vars['stageBtn02']:registerScriptTapHandler(function() self:click_stageBtn(1700012) end)
    vars['stageBtn03']:registerScriptTapHandler(function() self:click_stageBtn(1700013) end)
    vars['stageBtn04']:registerScriptTapHandler(function() self:click_stageBtn(1700014) end)

    vars['infoBtn']:registerScriptTapHandler(function() self:click_runeInfo() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneGuardianDungeonScene:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RuneGuardianDungeonScene:click_exitBtn()
	if (g_currScene.m_sceneName == 'SceneRuneGuardianDungeon') then
		local is_use_loading = false
		local scene = SceneLobby(is_use_loading)
		scene:runScene()
	else
		self:close()
	end
end

-------------------------------------
-- function click_runeInfo
-- @brief 룬 도움말(룬 획득확률 -> 룬 수호자 던전) 팝업 출력
-------------------------------------
function UI_RuneGuardianDungeonScene:click_runeInfo()
    UI_HelpRune('probability', 'runeGuardian')
end

-------------------------------------
-- function click_stageBtn
-------------------------------------
function UI_RuneGuardianDungeonScene:click_stageBtn(stage_id)
    UI_AdventureStageInfo(stage_id)
end


--@CHECK
UI:checkCompileError(UI_RuneGuardianDungeonScene)
