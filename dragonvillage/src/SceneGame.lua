-- g_gameScene = nil

-------------------------------------
-- class SceneGame
-------------------------------------
SceneGame = class(PerpleScene, {
        m_stageName = '',
        m_stageID = '',
        m_scheduleNode = 'cc.Node',
        m_gameWorld = 'GameWorld',

        -- 레이어 관련 변수
        m_containerLayer = 'cc.Node',   -- (UI, 화면 연출에 관여)
        m_viewLayer = 'cc.Node',
        m_shakeLayer = 'cc.Node',       -- 화면 떨림 레이어
        m_cameraLayer = 'cc.Node',
        m_worldLayer = 'cc.Node',       -- 월드 레이어 (줌인, 줌아웃 관여)
        m_gameNode1 = 'cc.Node',        -- 게임 레이어
        m_gameNode2 = 'cc.Node',        -- 게임 레이어
        m_gameNode3 = 'cc.Node',        -- 게임 레이어
        m_feverNode = 'cc.Node',        -- 피버 레이어
        m_gameIndicatorNode = 'cc.Node',
        m_gameHighlightNode = 'cc.Node',
        m_colorLayerForSkill = 'cc.LayerColor', -- 암전 레이어

        m_colorLayerTamerSkill = 'cc.LayerColor', -- 암전 레이어

        m_bStop = '',
        m_bPause = '',

        m_inGameUI = '',

        m_bDevelopMode = 'boolean',

        m_timerTimeScale = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGame:init(stage_id, stage_name, develop_mode)
    self.m_stageID = stage_id
    self.m_stageName = stage_name
    self.m_bUseLoadingUI = true
    self.m_bRemoveCache = true

    self.m_bStop = false
    self.m_bPause = false
    self.m_bDevelopMode = develop_mode or false
    self.m_bShowTopUserInfo = false

    self.m_timerTimeScale = 0
end

-------------------------------------
-- function init_layer
-- @brief 레이어 초기화
-------------------------------------
function SceneGame:init_layer()

    -- Scene에 최초로 add되는 레이어 (UI, 화면 연출에 관여)
    self.m_containerLayer = cc.Node:create()
    self.m_scene:addChild(self.m_containerLayer)

    do -- 뷰 레이어
        self.m_viewLayer = cc.Node:create()
        self.m_containerLayer:addChild(self.m_viewLayer)

        do -- 화면 떨림 레이어
            self.m_shakeLayer = cc.Node:create()
            self.m_viewLayer:addChild(self.m_shakeLayer)

            self.m_cameraLayer = cc.Node:create()
            self.m_shakeLayer:addChild(self.m_cameraLayer)

            do -- 월드 레이어 (줌인, 줌아웃 관여)
                self.m_worldLayer = cc.Node:create()
                self.m_cameraLayer:addChild(self.m_worldLayer)

                do -- 게임 레이어
                    self.m_gameNode1 = cc.Node:create()
                    self.m_worldLayer:addChild(self.m_gameNode1)

                    -- 게임 레이어
                    self.m_gameNode2 = cc.Node:create()
                    self.m_worldLayer:addChild(self.m_gameNode2)
                    self.m_gameNode3 = cc.Node:create()
                    self.m_worldLayer:addChild(self.m_gameNode3)

                    -- 피버 레이어
                    self.m_feverNode = cc.Node:create()
                    self.m_worldLayer:addChild(self.m_feverNode)

                    -- 암전용 레이어
                    self.m_colorLayerForSkill = cc.LayerColor:create()
                    self.m_colorLayerForSkill:setColor(cc.c3b(0, 0, 0))
                    self.m_colorLayerForSkill:setOpacity(100)
                    self.m_colorLayerForSkill:setAnchorPoint(cc.p(0.5, 0.5))
                    self.m_colorLayerForSkill:setDockPoint(cc.p(0, 0.5))
                    self.m_colorLayerForSkill:setNormalSize(4000, 2000)
                    self.m_colorLayerForSkill:setVisible(false)
                    self.m_worldLayer:addChild(self.m_colorLayerForSkill)

                    -- 스킬 인디케이터 레이어
                    self.m_gameIndicatorNode = cc.Node:create()
                    self.m_worldLayer:addChild(self.m_gameIndicatorNode, 99)

                    -- 하일라이트 레이어
                    self.m_gameHighlightNode = cc.Node:create()
                    self.m_worldLayer:addChild(self.m_gameHighlightNode)
                end
            end
        end
    end

    self.m_colorLayerTamerSkill = cc.LayerColor:create()
    self.m_colorLayerTamerSkill:setColor(cc.c3b(255, 255, 255))
    self.m_colorLayerTamerSkill:setOpacity(0)
    self.m_colorLayerTamerSkill:setNormalSize(4000, 2000)
    self.m_colorLayerTamerSkill:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_colorLayerTamerSkill:setDockPoint(cc.p(0.5, 0.5))
    self.m_scene:addChild(self.m_colorLayerTamerSkill)
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneGame:onEnter()
    g_gameScene = self
    PerpleScene.onEnter(self)
    SoundMgr:playBGM('bgm_battle')

    self.m_inGameUI = UI_Game(self)
end

-------------------------------------
-- function onExit
-------------------------------------
function SceneGame:onExit()
    g_gameScene = nil
    PerpleScene.onExit(self)
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneGame:prepare()
    self:addLoading(function()

        -- 레이어 생성
        self:init_layer()

        self.m_gameWorld = GameWorld(self.m_stageID, self.m_stageName, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_feverNode, self.m_inGameUI, self.m_bDevelopMode)
        self.m_gameWorld:initWaveMgr(self.m_stageName, self.m_bDevelopMode)

        -- 스테이지의 스크립트 정보를 얻어옴
        local script = TABLE:loadJsonTable(self.m_stageName)
        local difficult = script['difficult'] or 1
        difficult = 1 -- 임시 처리
        local deck_type = 'deck_5'
        if (difficult == 1) then
            deck_type = 'deck_5'
        end

        -- 임시
        self.m_gameWorld:init_test(deck_type)

        -- 스크린 사이즈 초기화
        self:sceneDidChangeViewSize()
    end)


    -- self:addLoading(function()
    --     MakeAnimator('res/effect/godae_shinryong_special/godae_shinryong_special.spine'):release()
    -- end)

    self:addLoading(function()
        self.m_inGameUI:init_debugUI()
    end)
end

-------------------------------------
-- function prepareDone
-------------------------------------
function SceneGame:prepareDone()
    self.m_scheduleNode = cc.Node:create()
    self.m_scene:addChild(self.m_scheduleNode)
    self.m_scheduleNode:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
    
    self.m_gameWorld.m_gameState:changeState(GAME_STATE_START_1)
end

-------------------------------------
-- function appearDone
-------------------------------------
function SceneGame:appearDone()
    --self.m_gameWorld.m_gameState:changeState(GAME_STATE_START_2)
end

-------------------------------------
-- function update
-------------------------------------
function SceneGame:update(dt)
    if self.m_bStop then
        return
    end

    if self.m_bPause then
        return
    end

    if self.m_timerTimeScale > 0 then
        self.m_timerTimeScale = self.m_timerTimeScale - dt
        if self.m_timerTimeScale <= 0 then
            self:setTimeScale(1)
        end
    end
    
    local function func()
        self.m_gameWorld:update(dt)
    end

    local status, msg = xpcall(func, __G__TRACKBACK__)
    if not status then
        self.m_bStop = true
    end
end

-------------------------------------
-- function gamePause
-------------------------------------
function SceneGame:gamePause()
    self.m_bPause = true

    local function f_pause(node)
        node:pause()
    end

    doAllChildren(self.m_gameNode1, f_pause)
    doAllChildren(self.m_gameNode2, f_pause)
    doAllChildren(self.m_feverNode, f_pause)
end

-------------------------------------
-- function gameResume
-------------------------------------
function SceneGame:gameResume()
    self.m_bPause = false

    local function f_resume(node)
        node:resume()
    end

    doAllChildren(self.m_gameNode1, f_resume)
    doAllChildren(self.m_gameNode2, f_resume)
    doAllChildren(self.m_feverNode, f_resume)
end

-------------------------------------
-- function sceneDidChangeViewSize
-------------------------------------
function SceneGame:sceneDidChangeViewSize()
    PerpleScene.sceneDidChangeViewSize(self)

    -- 스크린 사이즈 초기화
    local scr_size = cc.Director:getInstance():getWinSize()

    do -- 컨테이너 레이어를 항상 센터 위치로 이동
        local pos_x = scr_size['width']/2
        local pos_y = scr_size['height']/2
        --self.m_containerLayer:setPosition(pos_x, pos_y)
        self.m_containerLayer:stopAllActions()
        local scale_action = cc.MoveTo:create(0.2, cc.p(pos_x, pos_y))
        local ease_action = cc.EaseIn:create(scale_action, 2)
        self.m_containerLayer:runAction(ease_action)
    end

    do
        -- 뷰를 현재 해상도로 조정
        local scale = scr_size['width'] / CRITERIA_RESOLUTION_X
        if is_ui_toggle then
            scale = scale * 0.95
        end
        self.m_viewLayer:stopAllActions()
        local scale_action = cc.ScaleTo:create(0.2, scale)
        local ease_action = cc.EaseIn:create(scale_action, 2)
        self.m_viewLayer:runAction(ease_action)
    end
end

-------------------------------------
-- function setTimeScaleAction
-- @brief duration 시간동안만 timeScale을 변경시킴
-------------------------------------
function SceneGame:setTimeScaleAction(timeScale, duration)
    if timeScale == 0 then return end

    self:setTimeScale(timeScale)

    self.m_timerTimeScale = duration * timeScale
end

-------------------------------------
-- function setShakeAction
-- @brief 화면 떨림 연출
-------------------------------------
function SceneGame:setShakeAction(x, y)
    local timeScale = cc.Director:getInstance():getScheduler():getTimeScale()
    local duration = 0.5 * timeScale

    self.m_shakeLayer:stopAllActions()
    local start_action = cc.MoveTo:create(0, cc.p(x, y))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(duration, cc.p(0, 0)), 0.2)
    self.m_shakeLayer:runAction(cc.Sequence:create(start_action, end_action))
end


-------------------------------------
-- function flashIn
-- @brief 테이머 스킬 칼라 레이어를 페이드인
-------------------------------------
function SceneGame:flashIn(tParam)
	local tParam = tParam or {}
	local cbEnd = tParam['cbEnd']
	local time = tParam['time'] or 0.5
	local color = tParam['color'] or cc.c3b(255, 255, 255)
    local opacity = tParam['opacity'] or 255

    local layer = self.m_colorLayerTamerSkill
	layer:setColor(color)
	layer:setOpacity(0)
	layer:runAction(cc.Sequence:create(
		--cc.FadeIn:create(time),
        cc.FadeTo:create(time, opacity),
		cc.CallFunc:create(function(node)
			if cbEnd then
				cbEnd()
			end
		end)
	))
end

-------------------------------------
-- function flashOut
-- @brief 테이머 스킬 칼라 레이어를 페이드아웃
-------------------------------------
function SceneGame:flashOut(tParam)
	local tParam = tParam or {}
	local cbEnd = tParam['cbEnd']
	local time = tParam['time'] or 0.5
	
	local layer = self.m_colorLayerTamerSkill
	layer:runAction(cc.Sequence:create(
		cc.FadeOut:create(time),
		cc.CallFunc:create(function(node)
			if cbEnd then
				cbEnd()
			end
		end)
	))
end

-------------------------------------
-- function Shake
-- @brief 화면 떨림 연출
-------------------------------------
function Shake(x, y)
    if g_gameScene then
        g_gameScene:setShakeAction(x, y)
    end
end

-------------------------------------
-- function ShakeDir
-- @brief 화면 떨림 연출
-------------------------------------
function ShakeDir(dir, distance)
    if g_gameScene then
        local pos = getPointFromAngleAndDistance(dir, distance)
        g_gameScene:setShakeAction(pos['x'], pos['y'])
    end
end

-------------------------------------
-- function ShakeDir2
-- @brief 화면 떨림 연출
-------------------------------------
function ShakeDir2(dir, speed)
    if g_gameScene then
        local distance = math_clamp(speed / 20, 5, 50)
        ShakeDir(dir, distance)
    end
end