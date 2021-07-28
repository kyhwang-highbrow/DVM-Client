local PARENT = SceneGame

-------------------------------------
-- class SceneGameIntro
-------------------------------------
SceneGameIntro = class(PARENT, {
        m_nIdx = 'number',
        m_bDoAction = 'boolean',

        m_tutorialPlayer = 'UI_TutorialPlayer',

        m_focusingDragon = 'Dragon',

		m_nextCB = 'function',

        m_isReplayMode = 'boolean', -- true 라면 firstTimeExperience 기록 안함
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
-- function setNextCB
-------------------------------------
function SceneGameIntro:setNextCB(cb)
	self.m_nextCB = cb
end

-------------------------------------
-- function init_gameMode
-- @brief 스테이지 ID와 게임 모드 저장
-------------------------------------
function SceneGameIntro:init_gameMode()
    self.m_stageID = INTRO_STAGE_ID
    self.m_gameMode = GAME_MODE_INTRO
    self.m_bgmName = 'bgm_dungeon'
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneGameIntro:onEnter()
    g_gameScene = self
    PerpleScene.onEnter(self)

    g_autoPlaySetting:setMode(AUTO_NORMAL)
    g_autoPlaySetting:setAutoPlay(false)

    self.m_inGameUI = UI_Game(self)
    self.m_resPreloadMgr = ResPreloadMgr()

    -- 절전모드 설정
    SetSleepMode(false)
end

-------------------------------------
-- function onExit
-------------------------------------
function SceneGameIntro:onExit()
    PARENT.onExit(self)

    -- 절전모드 설정
    SetSleepMode(true)
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneGameIntro:prepare()
    -- 테이블 리로드(메모리 보안을 위함)
    self:addLoading(function()
        TABLE:reloadForGame()
    end)

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
        self.m_resPreloadMgr:resCaching('res/ui/a2d/tutorial/tutorial.vrp')

        Translate:a2dTranslate('ui/a2d/ingame_enemy/ingame_enemy.vrp')

        local ret = self.m_resPreloadMgr:loadFromStageId(self.m_stageID)
        return ret
    end)

    self:addLoading(function()
		-- 테스트 모드에서만 디버그패널 on
		if (IS_TEST_MODE()) then
			self.m_inGameUI:init_debugUI()
		end

		self.m_inGameUI:init_dpsUI()
		self.m_inGameUI:init_panelUI()
    end)
end

-------------------------------------
-- function prepareAfter
-------------------------------------
function SceneGameIntro:prepareAfter()
    return true
end

-------------------------------------
-- function prepareDone
-------------------------------------
function SceneGameIntro:prepareDone()
    local function start()
        SoundMgr:playBGM(self.m_bgmName)
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
    local mana = world:getMana()
    local boss = world.m_boss
    local idx = self.m_nIdx

    -- 첫번째 웨이브 - 시전자가 최초 평타 어택시
    if (idx == 1) and (recorder:getLog('basic_attack_cnt') > 1) then
        self:play_tutorialTalk()

        -- @analytics
        self:firstTimeExperience('Tutorial_Intro_Wave')
    end 
    
    -- 두번째 웨이브 - 아이템 드랍시
    -- if (idx == 2) and (recorder:getLog('drop_item_cnt') > 0) then
    --     self:play_tutorialTalk(true)

    --     -- @analytics
    --     self:firstTimeExperience('Tutorial_Intro_AutoPick')

    --     world.m_dropItemMgr:startIntro()
    -- end
    if (idx == 2) and (recorder:getLog('drop_item_cnt') > 0) then
        -- @analytics
        self:firstTimeExperience('Tutorial_Intro_AutoPick')
        
        self.m_nIdx = self.m_nIdx + 1
    end

    -- 세번째 웨이브 - 보스 대사
	if (idx == 3) and (world.m_waveMgr:isFinalWave() and world:isPossibleControl()) then
        self:play_tutorialTalk()

        -- 마나 게이지 활성화 시키면서 회복속도를 조절
        mana:setEnable(true)
        mana.m_incValuePerSec = 1 / 8
    end

    -- 세번째 웨이브 - 빙하고룡 스킬
    if (idx == 4) and (world:getMana():getCurrMana() > 1) then
        -- 해당 드래곤의 액티브 스킬에 필요한 마나를 추가
        self.m_focusingDragon = world:getDragonList()[2]
        mana:setCurrMana(self.m_focusingDragon:getSkillManaCost())

        -- 빙하고룡의 얼음조각 최대로 스택시켜줌
        for i = 1, 5 do
            StatusEffectHelper:doStatusEffect(self.m_focusingDragon, {self.m_focusingDragon}, 'ice_element', 'self', 1, -1, 100, 2)
        end
        
        self:play_tutorialTalk(false, true)
    end

    -- 세번째 웨이브 - 파워드래곤 스킬
    if (idx == 5) and (recorder:getLog('use_skill') > 0 and self.m_focusingDragon.m_state == 'attackDelay') then
        
        -- 해당 드래곤의 액티브 스킬에 필요한 마나를 추가
        self.m_focusingDragon = world:getDragonList()[1]
        mana:setCurrMana(self.m_focusingDragon:getSkillManaCost())
        
        self:play_tutorialTalk(false, true)
    end

	-- 세번째 웨이브 - 스마트 드래곤 대사
	if (idx == 6) and (recorder:getLog('use_skill') > 1 and self.m_focusingDragon.m_state == 'attackDelay') then
        
		self:play_tutorialTalk()
	end

    -- 세번째 웨이브 - 보스 스킬 사용 직전
	-- @jjo 다크닉스 공격으로 애들 피가 많이 깎임. 죽으면 안됨.
    if (idx == 7) and (boss.m_patternAtkIdx == '1' and boss.m_state == 'attack') then
        
        self:play_tutorialTalk()
    end

	-- 세번째 웨이브 - 스마트 드래곤 힐
	if (idx == 8) and (recorder:getLog('boss_special_attack') > 0 and boss.m_state == 'pattern_wait') then
        
        -- 해당 드래곤의 액티브 스킬에 필요한 마나를 추가
        self.m_focusingDragon = world:getDragonList()[3]
        mana:setCurrMana(self.m_focusingDragon:getSkillManaCost())
                
        self:play_tutorialTalk(false, true)
    end

    if (idx == 9) and (recorder:getLog('use_skill') > 2 and self.m_focusingDragon.m_state == 'attackDelay') then
        
        self:play_tutorialTalk()
    end

    -- 세번째 웨이브 - 번개고룡 패시브 및 드래그
	if (idx == 10) and (mana:getCurrMana() > 0.5) then
        
        -- 해당 드래곤의 액티브 스킬에 필요한 마나를 추가
        self.m_focusingDragon = world:getDragonList()[4]
        mana:setCurrMana(self.m_focusingDragon:getSkillManaCost())

        -- 번개고룡 스킬 사용 후 다크닉스 사망
        local activity_carrier = self.m_focusingDragon:makeAttackDamageInstance()
        activity_carrier:setDefiniteDeath(true)
        self.m_focusingDragon:reserveAttackDamage(activity_carrier)

        -- 번개고룡이 공격속도 증가 버프를 2중첩으로 스스로에게 건다.
        for i = 1, 2 do
            StatusEffectHelper:doStatusEffect(self.m_focusingDragon, {self.m_focusingDragon}, 'aspd_up', 'self', 1, 10, 100, 100)
        end

        -- @analytics
        self:firstTimeExperience('Tutorial_Intro_DragSkill')

        self:play_tutorialTalk(false, true)
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
    self.m_tutorialPlayer.root:removeFromParent()
    self.m_tutorialPlayer = nil

	if self.m_nextCB then
		self.m_nextCB()
	end
end

-------------------------------------
-- function init_loadingGuideType
-- @brief 로딩가이드 타입 - 인트로 전투일때 어떤 로딩?
-------------------------------------
function SceneGameIntro:init_loadingGuideType()
	self.m_loadingGuideType = 'in_tutorial_battle'
end	

-------------------------------------
-- function SceneGameIntro
------------------------------------
function SceneGameIntro:play_tutorialTalk(no_use_next_btn, no_color_layer)
    -- skip기능으로 m_tutorialPlayer 값 지워버린 상태에서 이 함수 들어왔을 때 예외처리 
    if (not self.m_tutorialPlayer) then
        return
    end
    
    local no_use_next_btn = no_use_next_btn or false
    local no_color_layer = no_color_layer or no_use_next_btn

    local world = self.m_gameWorld
    world:setTemporaryPause(true, nil, INGAME_PAUSE__TUTORIAL_TALK)
    world.m_gameHighlight:setToForced(no_use_next_btn)
	
    self.m_nIdx = self.m_nIdx + 1
    self.m_tutorialPlayer:next()

    -- 스킵은 항상 불가능
    self.m_tutorialPlayer.vars['skipBtn']:setVisible(true) -- 인트로 전투 스킵 가능하게 바뀜
    self.m_tutorialPlayer.vars['nextBtn']:setVisible(not no_use_next_btn)
    self.m_tutorialPlayer.vars['layerColor2']:setVisible(not no_color_layer)

    -- 튜토리얼 대사 후 콜백 함수
    local function next_cb()
        self.m_gameWorld:setTemporaryPause(false, nil, INGAME_PAUSE__TUTORIAL_TALK)

        if (self.m_nIdx == 5) then
            -- 드래그 스킬 입력 가이드 시작(빙하고룡)
            world.m_skillIndicatorMgr:startIntro(self.m_focusingDragon)
        elseif (self.m_nIdx == 6) then
            -- 드래그 스킬 입력 가이드 시작(파워드래곤)
            world.m_skillIndicatorMgr:startIntro(self.m_focusingDragon)
        elseif (self.m_nIdx == 9) then
            -- 드래그 스킬 입력 가이드 시작(스마트드래곤)
            world.m_skillIndicatorMgr:startIntro(self.m_focusingDragon)
        elseif (self.m_nIdx == 11) then
            -- 드래그 스킬 입력 가이드 시작(번개고룡드래곤)
            world.m_skillIndicatorMgr:startIntro(self.m_focusingDragon)    
        end
    end

    self.m_tutorialPlayer:set_nextFunc(next_cb, 'hide_all')

	cclog('play_tutorialTalk : ' .. self.m_nIdx)
end

-------------------------------------
-- function next_intro
------------------------------------
function SceneGameIntro:next_intro()
    local world = self.m_gameWorld
    world.m_gameHighlight:setToForced(false)

    -- 스킵 하면 self.m_tutorialPlayer = nil 처리함
    -- 스킵 동작 중간에 터치 등의 이벤트로 이 함수가 호출되었을 경우 에러 방지
    if (not self.m_tutorialPlayer) then
       return 
    end
    self.m_tutorialPlayer:next()
end

-------------------------------------
-- function showSkipPopup
-------------------------------------
function SceneGameIntro:showSkipPopup()
    local game_world = self.m_gameWorld
    local ok_cb = function()
        -- @analytics
        self:firstTimeExperience('Tutorial_Intro_Skip')
        g_gameScene:networkGameFinish()
    end
    local cancel_cb = function() 
        game_world:setTemporaryPause(false, nil, INGAME_PAUSE__TUTORIAL_TALK) -- pause, excluded_dragon, tag
    end
    
    -- 일시 정지 하고 튜토리얼 스킵 여부 물어봄
    game_world:setTemporaryPause(true, nil, INGAME_PAUSE__TUTORIAL_TALK) -- pause, excluded_dragon, tag
    self:makeSkipPopup(ok_cb, cancel_cb)
end

-------------------------------------
-- function makeSkipPopup
-- @brief 
-- UI_TutorialPlaayer의 z_order는 TUTORIAL_DLG = 128
-- UI_Popup에서 만드는 팝업은 z_order(UI = 16)가 더 낮아서 가려짐 (MakeSimplePopup.lua 사용 못함)
-- 씬에 붙일 수 있는 팝업 사용
-------------------------------------
function SceneGameIntro:makeSkipPopup(ok_cb, cancel_cb)
    local sub_msg = '시나리오 전투를 건너뛰시겠습니까?' -- 위 쪽 메세지
    local msg = '설정→게임→시나리오 다시 보기에서 시나리오 전투를 다시 할 수 있습니다.' -- 아래 쪽 메세지
	
    local no_popup = true
    local close_cb

    local popup_ui = UI_SimplePopup3(POPUP_TYPE.YES_NO, msg, sub_msg, ok_cb, cancel_cb, g_gameScene.m_scene)
    g_gameScene.m_scene:addChild(popup_ui.root, SCENE_ZORDER.TUTORIAL_DLG + 1)

    -- 눌림 방지
    UIManager:makeTouchBlock(popup_ui, false)
end

-------------------------------------
-- function setReplayMode
-------------------------------------
function SceneGameIntro:setReplayMode(is_replay)
    self.m_isReplayMode = is_replay
end

-------------------------------------
-- function firstTimeExperience
-------------------------------------
function SceneGameIntro:firstTimeExperience(first_experience_key)
    if (not self.m_isReplayMode) then
        -- @analytics
        Analytics:firstTimeExperience(first_experience_key)
    end
end
