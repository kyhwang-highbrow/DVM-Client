local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

local L_STAGE_ID = {1700011, 1700012, 1700013, 1700014, 1700015, 1700016}

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
    for i, stage_id in ipairs(L_STAGE_ID) do
        if (vars['stageNode'..i]) then
            local ui_item = UI_RuneGuardianDungeonListItem(stage_id)
            vars['stageNode'..i]:addChild(ui_item.root)
        end
    end
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneGuardianDungeonScene:initButton() 
    local vars = self.vars
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

--@CHECK
UI:checkCompileError(UI_RuneGuardianDungeonScene)








local PARENT = UI

-------------------------------------
-- class UI_RuneGuardianDungeonListItem
-------------------------------------
UI_RuneGuardianDungeonListItem = class(PARENT, {
        m_stageId = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneGuardianDungeonListItem:init(stage_id)
    local vars = self:load('rune_guardian_dungeon_scene_item.ui')
    self.m_stageId = stage_id

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function init
-------------------------------------
function UI_RuneGuardianDungeonListItem:initUI()
    local vars = self.vars
    local stage_id = self.m_stageId
    local direction_number = 1   -- 1은 ui 파일의 왼쪽 모양(메뉴) 사용, 2는 오른쪽
                                 -- 세 번째 던전까지는 왼쪽(디폴트)을 사용
    if (stage_id > 1700013) then
        direction_number = 2
    end

    -- 세팅 전에 모두 비활성화 된 상태로 초기화
    for i = 1, 2 do
        vars['mainMenu' .. i]:setVisible(false)        
    end

    local t_data = TableDrop():get(stage_id)
    vars['mainMenu' .. direction_number]:setVisible(true)

    local reward_item_id = t_data['item_1_id']
    local reward_sprite = IconHelper:getItemIcon(reward_item_id)
    vars['rewardNode' .. direction_number]:addChild(reward_sprite)

    local title = t_data['t_name']
    vars['titleLabel' .. direction_number]:setString(Str(title))

    vars['startBtn' .. direction_number]:registerScriptTapHandler(function() self:click_stageBtn(stage_id) end)
end

-------------------------------------
-- function init
-------------------------------------
function UI_RuneGuardianDungeonListItem:initButton()
end

-------------------------------------
-- function init
-------------------------------------
function UI_RuneGuardianDungeonListItem:refresh()

end

-------------------------------------
-- function click_stageBtn
-------------------------------------
function UI_RuneGuardianDungeonListItem:click_stageBtn(stage_id)
    UI_AdventureStageInfo(stage_id)
end
