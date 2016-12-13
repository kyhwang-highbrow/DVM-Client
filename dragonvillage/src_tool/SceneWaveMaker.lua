local FONT_PATH = 'res/font/common_font_01.ttf'

require 'src_tool/redefine'

-- g_gameScene = nil

-------------------------------------
-- class SceneWaveMaker
-------------------------------------
SceneWaveMaker = class(PerpleScene, {
        m_stageName = '',
        m_stageID = '',
        m_scheduleNode = 'cc.Node',
        m_gameWorld = 'GameWorld',

        m_containerLayer = 'cc.Node',   
        m_viewLayer = 'cc.Node',
        m_shakeLayer = 'cc.Node',       
        m_cameraLayer = 'cc.Node',
        m_worldLayer = 'cc.Node',       
        m_gameNode1 = 'cc.Node',        
        m_gameNode2 = 'cc.Node',        
        m_gameNode3 = 'cc.Node',        
        m_gameIndicatorNode = 'cc.Node',
        m_gameHighlightNode = 'cc.Node',
        m_colorLayerForSkill = 'cc.LayerColor', 

        m_colorLayerTamerSkill = 'cc.LayerColor', 

        m_bStop = '',
        m_bPause = '',

        m_inGameUI = '',

        m_bDevelopMode = 'boolean',

		m_gridX = '',
		m_gridY = '',
		m_gridX_Outline = '',
		m_gridY_Outline = '',
		m_grid_factor = '',
		m_gridLayer = '',

		m_label = '',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneWaveMaker:init(stage_id, stage_name, develop_mode)
    self.m_bShowTopUserInfo = false
    self.m_stageID = DEV_STAGE_ID
    self.m_stageName = g_stage_name
    self.m_bUseLoadingUI = true
    self.m_bRemoveCache = true

    self.m_bStop = false
    self.m_bPause = false
    self.m_bDevelopMode = false
    self.m_bShowTopUserInfo = false

	-- 적 유닛이 등장하는 외부 위치도 보여주기 위해서 세팅
	self.m_scene:setScale(0.8)
	
	self.m_grid_factor = 1
end

-------------------------------------
-- function init_layer
-------------------------------------
function SceneWaveMaker:init_layer()

    self.m_containerLayer = cc.Node:create()
    self.m_scene:addChild(self.m_containerLayer)

    do 
        self.m_viewLayer = cc.Node:create()
        self.m_containerLayer:addChild(self.m_viewLayer)

        do 
            self.m_shakeLayer = cc.Node:create()
            self.m_viewLayer:addChild(self.m_shakeLayer)

            self.m_cameraLayer = cc.Node:create()
            self.m_shakeLayer:addChild(self.m_cameraLayer)

            do 
                self.m_worldLayer = cc.Node:create()
                self.m_cameraLayer:addChild(self.m_worldLayer, 2)
				
				self:makeTouchLayer(self.m_worldLayer)

                do
                    self.m_gameNode1 = cc.Node:create()
                    self.m_worldLayer:addChild(self.m_gameNode1)

                    self.m_gameNode2 = cc.Node:create()
                    self.m_worldLayer:addChild(self.m_gameNode2)
                    self.m_gameNode3 = cc.Node:create()
                    self.m_worldLayer:addChild(self.m_gameNode3)

                    self.m_colorLayerForSkill = cc.LayerColor:create()
                    self.m_colorLayerForSkill:setColor(cc.c3b(0, 0, 0))
                    self.m_colorLayerForSkill:setOpacity(100)
                    self.m_colorLayerForSkill:setAnchorPoint(cc.p(0.5, 0.5))
                    self.m_colorLayerForSkill:setDockPoint(cc.p(0, 0.5))
                    self.m_colorLayerForSkill:setNormalSize(4000, 2000)
                    self.m_colorLayerForSkill:setVisible(false)
                    self.m_worldLayer:addChild(self.m_colorLayerForSkill)

                    self.m_gameIndicatorNode = cc.Node:create()
                    self.m_worldLayer:addChild(self.m_gameIndicatorNode)

                    self.m_gameHighlightNode = cc.Node:create()
                    self.m_worldLayer:addChild(self.m_gameHighlightNode)
                end
            end
        end
    end

	-- grid
	self:initGrid()

	----------------------------------------------------------------------
	do 
		local function touchEvent(sender,eventType)
			if eventType == ccui.TouchEventType.ended then
				self.m_gameWorld:killAllEnemy()
				self.m_gameWorld.m_waveMgr:clearDynamicWave()

				self.m_gameWorld.m_gameState:waveChange(true)
				self.m_label:setString('Current Wave : '.. self.m_gameWorld.m_waveMgr.m_currWave)
			end
		end

		local button = ccui.Button:create()
		button:setTitleFontName(FONT_PATH)
		button:setTitleFontSize(20)
		button:setTitleText('PREV')

		button:setTouchEnabled(true)
		button:loadTextures("res/common/tool/a_button_0801.png", "res/common/tool/a_button_0802.png", "")
		button:setPosition(-150, 0)
		button:setDockPoint(cc.p(1, 0))
		button:setScale(1.5)
		button:addTouchEventListener(touchEvent)
		self.m_scene:addChild(button)
	end
	----------------------------------------------------------------------
	----------------------------------------------------------------------
	do
		local function touchEvent(sender,eventType)
			if eventType == ccui.TouchEventType.ended then
				self.m_gameWorld:killAllEnemy()
				self.m_gameWorld.m_waveMgr:clearDynamicWave()

				self.m_gameWorld.m_gameState:waveChange()
				self.m_label:setString('Current Wave : '.. self.m_gameWorld.m_waveMgr.m_currWave)
			end
		end

		local button = ccui.Button:create()
		button:setTitleFontName(FONT_PATH)
		button:setTitleFontSize(20)
		button:setTitleText('NEXT')

		button:setTouchEnabled(true)
		button:loadTextures("res/common/tool/a_button_0801.png", "res/common/tool/a_button_0802.png", "")
		button:setPosition(0, 0)
		button:setDockPoint(cc.p(1, 0))
		button:setScale(1.5)
		button:addTouchEventListener(touchEvent)
		self.m_scene:addChild(button)
	end
	----------------------------------------------------------------------

	----------------------------------------------------------------------
	-- Label
	local editBoxSize = cc.size(250, 40)
	local custom_label = cc.Label:createWithTTF('Current Wave : 1', FONT_PATH, 30.0, 0, editBoxSize, cc.TEXT_ALIGNMENT_LEFT)
	custom_label:setPosition(0, 0)
	custom_label:setDockPoint(cc.p(0.5, 0))
	self.m_scene:addChild(custom_label)
	self.m_label = custom_label
	----------------------------------------------------------------------
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneWaveMaker:onEnter()
    g_gameScene = self
    PerpleScene.onEnter(self)

    self.m_inGameUI = UI_Game(self)
end

-------------------------------------
-- function onExit
-------------------------------------
function SceneWaveMaker:onExit()
    g_gameScene = nil
    PerpleScene.onExit(self)
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneWaveMaker:prepare()
    self:addLoading(function()
        self:init_layer()

        self.m_gameWorld = GameWorld(self.m_stageID, self.m_stageName, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode)
        self.m_gameWorld:initStage(self.m_stageName, self.m_bDevelopMode)
		        
        local script = TABLE:loadJsonTable(self.m_stageName)
        local difficult = script['difficult'] or 1
        local deck_type = 'deck_5'
        if (difficult == 1) then
            deck_type = 'deck_5'
        end

        self.m_gameWorld:init_wavemaker(deck_type)
		self:sceneDidChangeViewSize()

    end)

	self:addLoading(function()
        MakeAnimator('res/effect/godae_shinryong_special/godae_shinryong_special.spine'):release()
    end)

    self:addLoading(function()
        self.m_inGameUI:init_debugUI()
		self.m_inGameUI.root:setPositionX(-155)
    end)
end

-------------------------------------
-- function prepareDone
-------------------------------------
function SceneWaveMaker:prepareDone()
    self.m_scheduleNode = cc.Node:create()
    self.m_scene:addChild(self.m_scheduleNode)
    self.m_scheduleNode:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
    
    self.m_gameWorld.m_gameState:changeState(GAME_STATE_FIGHT)
end

-------------------------------------
-- function appearDone
-------------------------------------
function SceneWaveMaker:appearDone()
end

-------------------------------------
-- function update
-------------------------------------
function SceneWaveMaker:update(dt)
    local function func()
        self.m_gameWorld:update(dt)
    end

    local status, msg = xpcall(func, __G__TRACKBACK__)
    if not status then
        self.m_bStop = true
    end
end

-------------------------------------
-- function sceneDidChangeViewSize
-------------------------------------
function SceneWaveMaker:sceneDidChangeViewSize()
    PerpleScene.sceneDidChangeViewSize(self)

    local scr_size = cc.Director:getInstance():getWinSize()

    do
        local pos_x = scr_size['width']/2
        local pos_y = scr_size['height']/2
        --self.m_containerLayer:setPosition(pos_x, pos_y)
        self.m_containerLayer:stopAllActions()
        local scale_action = cc.MoveTo:create(0.2, cc.p(pos_x, pos_y))
        local ease_action = cc.EaseIn:create(scale_action, 2)
        self.m_containerLayer:runAction(ease_action)
    end

    do
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
-- function initGrid
-------------------------------------
function SceneWaveMaker:initGrid()
    local function primitivesDraw(transform, transformUpdated)
        self:primitivesDraw(transform, transformUpdated)
    end

    local glNode = cc.GLNode:create()
    glNode:registerScriptDrawHandler(primitivesDraw)
	glNode:setAnchorPoint(cc.p(0, 0.5))
	glNode:setDockPoint(cc.p(0, 0.5))
	glNode:setPosition(0,0)
    self.m_scene:addChild(glNode)
	self.m_gridLayer = glNode

	local gap_x = ENEMY_POS['LF11']['x'] - ENEMY_POS['LF21']['x']

	-- grid x inline 
    self.m_gridX = {}
	table.insert(self.m_gridX, ENEMY_POS['LF11']['x'] - gap_x/2) -- 570
	table.insert(self.m_gridX, ENEMY_POS['LF21']['x'] - gap_x/2) -- 470
	table.insert(self.m_gridX, ENEMY_POS['LM11']['x'] - gap_x/2) -- 370
	table.insert(self.m_gridX, ENEMY_POS['LM21']['x'] - gap_x/2) -- 270
	table.insert(self.m_gridX, ENEMY_POS['LB11']['x'] - gap_x/2) -- 170
	
	table.insert(self.m_gridX, ENEMY_POS['RF21']['x'] - gap_x/2) -- 810
	table.insert(self.m_gridX, ENEMY_POS['RM11']['x'] - gap_x/2) -- 910
	table.insert(self.m_gridX, ENEMY_POS['RM21']['x'] - gap_x/2) -- 1010
	table.insert(self.m_gridX, ENEMY_POS['RB11']['x'] - gap_x/2) -- 1110
	table.insert(self.m_gridX, ENEMY_POS['RB21']['x'] - gap_x/2) -- 1210
	
	
	-- grid x outline 
	self.m_gridX_Outline = {}
	local highest_x = ENEMY_POS['RB21']['x'] + gap_x
	local middle_x = ENEMY_POS['LF11']['x'] + gap_x
	
	table.insert(self.m_gridX_Outline, middle_x				  - gap_x/2) -- 670
	table.insert(self.m_gridX_Outline, ENEMY_POS['LB21']['x'] - gap_x/2) -- 70
	table.insert(self.m_gridX_Outline, ENEMY_POS['RF11']['x'] - gap_x/2) -- 710
	table.insert(self.m_gridX_Outline, highest_x			  - gap_x/2) -- 1310

	--------------------------------------------------

	local gap_y = ENEMY_POS['LF11']['y'] - ENEMY_POS['LF12']['y']

	-- grid y inline 
    self.m_gridY = {}
	table.insert(self.m_gridY, ENEMY_POS['LF11']['y'] - gap_y/2) -- 240
	table.insert(self.m_gridY, ENEMY_POS['LF12']['y'] - gap_y/2) -- 160
	table.insert(self.m_gridY, ENEMY_POS['LF13']['y'] - gap_y/2) -- 80
	table.insert(self.m_gridY, ENEMY_POS['LM14']['y'] - gap_y/2) -- 0
	table.insert(self.m_gridY, ENEMY_POS['LM15']['y'] - gap_y/2) -- -80
	table.insert(self.m_gridY, ENEMY_POS['LM16']['y'] - gap_y/2) -- -160

	-- grid y outline
	self.m_gridY_Outline = {}
	local highest_y = ENEMY_POS['LF11']['y'] + gap_y
	table.insert(self.m_gridY_Outline, highest_y			  - gap_y/2) -- 320 
	table.insert(self.m_gridY_Outline, ENEMY_POS['LM17']['y'] - gap_y/2) -- -240
end

-------------------------------------
-- function primitivesDraw
-------------------------------------
function SceneWaveMaker:primitivesDraw(transform, transformUpdated)
    kmGLPushMatrix()
    kmGLLoadMatrix(transform)
    self:drawGrid()
    kmGLPopMatrix()
end

-------------------------------------
-- function drawGrid
-------------------------------------
function SceneWaveMaker:drawGrid()
	local line_length = 2048
	cclog(self.m_grid_factor)
	-- inline
	cc.DrawPrimitives.drawColor4B(255, 255, 100, 200)
	gl.lineWidth(1)
    for i, v in ipairs(self.m_gridX) do
        cc.DrawPrimitives.drawLine(cc.p(v, -line_length), cc.p(v, line_length))
    end

    for i, v in ipairs(self.m_gridY) do
		cc.DrawPrimitives.drawLine(cc.p(-line_length, v), cc.p(line_length, v))
    end

	-- outline 
	local outline_length
	cc.DrawPrimitives.drawColor4B(200, 50, 50, 200)
	gl.lineWidth(3)
	for i, v in ipairs(self.m_gridX_Outline) do
        cc.DrawPrimitives.drawLine(cc.p(v, -line_length), cc.p(v, line_length))
    end

    for i, v in ipairs(self.m_gridY_Outline) do
		cc.DrawPrimitives.drawLine(cc.p(-line_length, v), cc.p(line_length, v))
    end

	-- visible line
	cc.DrawPrimitives.drawColor4B(50, 50, 200, 200)
	gl.lineWidth(4)
	for i, v in ipairs({0, 1280}) do
        cc.DrawPrimitives.drawLine(cc.p(v, -370), cc.p(v, 370))
    end

    for i, v in ipairs({-360, 360}) do
		cc.DrawPrimitives.drawLine(cc.p(-10, v), cc.p(1290, v))
    end
end

-------------------------------------
-- function makeTouchLayer
-------------------------------------
function SceneWaveMaker:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    --listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)

	local eventDispatcher = target_node:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function SceneWaveMaker:onTouchBegan(touch, event)
    return true
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SceneWaveMaker:onTouchMoved(touch, event)
    local delta = touch:getDelta()
	local location = touch:getLocation()
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function SceneWaveMaker:onTouchEnded(touch, event)
    return true
end