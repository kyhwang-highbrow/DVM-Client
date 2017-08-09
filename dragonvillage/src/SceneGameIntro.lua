local PARENT = SceneGame

-------------------------------------
-- class SceneGameIntro
-------------------------------------
SceneGameIntro = class(PARENT, {
        m_nIdx = 'number',
        m_bDoAction = 'boolean',

        m_tutorialPlayer = 'UI_TutorialPlayer',

        m_focusingDragon = 'Dragon',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGameIntro:init(game_key, stage_id, stage_name, develop_mode)
    -- 핫타임 관련 빈값으로 셋팅해줘야함 (통신하고 시작하는게 아님)
    g_hotTimeData:setIngameHotTimeList(game_key, {})

    self.m_stageName = 'stage_' .. INTRO_STAGE_ID
    self.m_bDoAction = false
    
    self.m_nIdx = 1
end

-------------------------------------
-- function init_gameMode
-- @brief 스테이지 ID와 게임 모드 저장
-------------------------------------
function SceneGameIntro:init_gameMode()
    self.m_stageID = INTRO_STAGE_ID
    self.m_gameMode = GAME_MODE_INTRO
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneGameIntro:onEnter()
    g_gameScene = self
    PerpleScene.onEnter(self)

    SoundMgr:playBGM('bgm_colosseum')

    self.m_inGameUI = UI_Game(self)
    self.m_resPreloadMgr = ResPreloadMgr()
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneGameIntro:prepare()
    self:addLoading(function()

        -- 레이어 생성
        self:init_layer()
        self.m_gameWorld = GameWorldIntro(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode)
        self.m_gameWorld:initGame(self.m_stageName)
        
        -- 스크린 사이즈 초기화
        self:sceneDidChangeViewSize()
    end)

    self:addLoading(function()
        -- 리소스 프리로드
        resCaching('res/ui/a2d/tutorial/tutorial')

        local ret = self.m_resPreloadMgr:loadForColosseum()
        return ret
    end)

    self:addLoading(function()
        -- FGT 에서는 디버그 기능을 제한한다
		if (not (TARGET_SERVER == 'FGT')) then 
			self.m_inGameUI:init_debugUI()
		end

		self.m_inGameUI:init_dpsUI()
		self.m_inGameUI:init_panelUI()
    end)
end

-------------------------------------
-- function prepareDone
-------------------------------------
function SceneGameIntro:prepareDone()
    local function start()
        self.m_containerLayer:setVisible(true)
        self.m_scheduleNode = cc.Node:create()
        self.m_scene:addChild(self.m_scheduleNode)
        self.m_scheduleNode:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
    
        self.m_gameWorld.m_gameState:changeState(GAME_STATE_START)
    end
    
    -- 인트로 시나리오
    local scenario_name = 'scenario_intro_fight'
    local ui = UI_TutorialPlayer(scenario_name)
    self.m_scene:addChild(ui.root, SCENE_ZORDER.TUTORIAL_DLG)
    ui:next()

    self.m_tutorialPlayer = ui

    start()
end

-------------------------------------
-- function update
-------------------------------------
function SceneGameIntro:update(dt)
    if (self.m_bPause) then return end

    local world = self.m_gameWorld
    local recorder = world.m_logRecorder
    local boss = world.m_boss
    local idx = self.m_nIdx

    -- 첫번째 웨이브 - 시전자가 최초 평타 어택시
    if (idx == 1) and (recorder:getLog('basic_attack_cnt') > 1) then
        self:play_tutorialTalk()
    end 
    
    -- 두번째 웨이브 - 아이템 드랍시
    if (idx == 2) and (recorder:getLog('drop_item_cnt') > 0) then
        self:play_tutorialTalk(true)

        world.m_dropItemMgr:startIntro()
    end 

    -- 세번째 웨이브 - 보스 대사
    if (idx == 3) and (world.m_waveMgr:isFinalWave() and world:isPossibleControl()) then
        self:play_tutorialTalk()

        -- 마나 게이지 활성화 시키면서 회복속도를 조절
        world.m_heroMana:setEnable(true)
        world.m_heroMana.m_incValuePerSec = 1 / 17
    end

    -- 세번째 웨이브 - 빙하고룡 스킬
    if (idx == 4) and (world.m_heroMana.m_value > 1) then
        self:play_tutorialTalk(false, true)

        -- 미리 암전 처리후 리더 드래곤만 하이라이트 시킴
        self.m_focusingDragon = world:getDragonList()[2]
        world.m_heroMana:addMana(self.m_focusingDragon:getSkillManaCost() - 1)
        world.m_gameHighlight:setToForced(true)
        world.m_gameHighlight:addForcedHighLightList(self.m_focusingDragon)
    end

    -- 세번째 웨이브 - 파워드래곤 스킬
    if (idx == 5) and (recorder:getLog('use_skill') > 0 and self.m_focusingDragon.m_state == 'attackDelay') then
        self:play_tutorialTalk(false, true)

        -- 미리 암전 처리후 리더 드래곤만 하이라이트 시킴
        self.m_focusingDragon = world:getDragonList()[1]
        world.m_heroMana:addMana(self.m_focusingDragon:getSkillManaCost())
        world.m_gameHighlight:setToForced(true)
        world.m_gameHighlight:addForcedHighLightList(self.m_focusingDragon)
    end

    -- 세번째 웨이브 - 번개고룡 스킬
    if (idx == 6) and (recorder:getLog('use_skill') > 1 and self.m_focusingDragon.m_state == 'attackDelay' and not world.m_gameDragonSkill:isPlaying()) then
        self:play_tutorialTalk(false, true)

        -- 미리 암전 처리후 리더 드래곤만 하이라이트 시킴
        self.m_focusingDragon = world:getDragonList()[4]
        world.m_heroMana:addMana(self.m_focusingDragon:getSkillManaCost())
        world.m_gameHighlight:setToForced(true)
        world.m_gameHighlight:addForcedHighLightList(self.m_focusingDragon)
    end

    -- 세번째 웨이브 - 보스 스킬 사용 직전
    if (idx == 7) and (boss.m_patternAtkIdx == '1' and boss.m_state == 'attack') then
        self:play_tutorialTalk()

        -- 보스의 공격력을 증가 시킴
        boss.m_statusCalc:addBuffMulti('atk', 9999)

        -- 아군의 무적처리 해제
        for _, hero in ipairs(world:getDragonList()) do
            hero:setInvincibility(false)
        end
    end

    -- 세번째 웨이브 - 아군이 모두 죽었을 때
    if (idx == 8) and (world.m_gameState.m_state == GAME_STATE_FAILURE) then
        self:play_tutorialTalk()
    end


    -- 유저가 튜토리얼 액션을 취하면 다시 게임 진행
    if (self.m_bDoAction) and (self.m_bPause) then
        self.m_bDoAction = false
        SceneGame:gameResume()
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function networkGameFinish
-------------------------------------
function SceneGameIntro:networkGameFinish(t_param, t_result_ref, next_func)
    self:checkScenario()
end

-------------------------------------
-- function checkScenario()
-------------------------------------
function SceneGameIntro:checkScenario()
    self.m_tutorialPlayer.root:removeFromParent()
    self.m_tutorialPlayer = nil

    local tid = g_userData:get('start_tamer')
    local tamer_name = TableTamer():getTamerType(tid) or 'goni'
    local intro_finish_name = 'scenario_intro_finish_'..tamer_name

    local play_intro_finish
    local lobby_func

    play_intro_finish = function()
        local ui = g_scenarioViewingHistory:playScenario(intro_finish_name)
        ui:setReplaceSceneCB(lobby_func)
        ui:next()
    end

    lobby_func = function()
        local is_use_loading = true
        local scene = SceneLobby(is_use_loading)
        scene:runScene()
    end

    if (not g_scenarioViewingHistory:isViewed(intro_finish_name)) then
        -- 튜토리얼 상태 저장
        g_tutorialData:request_tutorialSave(TUTORIAL.INTRO_FIGHT, play_intro_finish, lobby_func)
    else
        lobby_func()
    end
end

-------------------------------------
-- function init_loadingGuideType
-- @brief 로딩가이드 타입 - 인트로 전투일때 어떤 로딩?
-------------------------------------
function SceneGameIntro:init_loadingGuideType()
	self.m_loadingGuideType = 'in_adventure'
end	

-------------------------------------
-- function SceneGameIntro
------------------------------------
function SceneGameIntro:play_tutorialTalk(no_use_next_btn, no_color_layer)
    local no_use_next_btn = no_use_next_btn or false
    local no_color_layer = no_color_layer or no_use_next_btn

    local world = self.m_gameWorld
    world:setTemporaryPause(true)
    world.m_gameHighlight:setToForced(no_use_next_btn)

    self.m_nIdx = self.m_nIdx + 1
    self.m_tutorialPlayer:next()

    -- 스킵은 항상 불가능
    self.m_tutorialPlayer.vars['skipBtn']:setVisible(false)

    -- PC에서 스킵 가능 
    if (isWin32()) then
        self.m_tutorialPlayer.vars['skipBtn']:registerScriptTapHandler(function()  
            self:checkScenario()
        end)

        self.m_tutorialPlayer.vars['skipBtn']:setVisible(true)
    end

    self.m_tutorialPlayer.vars['nextBtn']:setVisible(not no_use_next_btn)
    self.m_tutorialPlayer.vars['layerColor2']:setVisible(not no_color_layer)

       
    -- 튜토리얼 대사 후 콜백 함수
    local function next_cb()
        if (self.m_nIdx == 5) then
            -- 드래그 스킬 입력 가이드 시작
            world.m_skillIndicatorMgr:startIntro(self.m_focusingDragon)
        elseif (self.m_nIdx == 6) then
            -- 드래그 스킬 입력 가이드 시작
            world.m_skillIndicatorMgr:startIntro(self.m_focusingDragon)
        elseif (self.m_nIdx == 7) then
            -- 드래그 스킬 입력 가이드 시작
            world.m_skillIndicatorMgr:startIntro(self.m_focusingDragon)
        else
            self.m_gameWorld:setTemporaryPause(false)
        end
    end

    self.m_tutorialPlayer:set_nextFunc(next_cb, 'hide_all') 
end

-------------------------------------
-- function next_intro
------------------------------------
function SceneGameIntro:next_intro()
    local world = self.m_gameWorld
    world.m_gameHighlight:setToForced(false)

    self.m_tutorialPlayer:next()
end

