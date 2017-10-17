
------------------------------------------------------------------------------------
-- wave maker 전용 함수
------------------------------------------------------------------------------------

--------------------------------------
-- function getScript
-- cpp로부터 이벤트 받아서 처리하는 함수
--------------------------------------
function getEventFromCpp(event_type, content)
	ccdump({event_type, content})
	
	if event_type == "load" then
		g_stage_name = content 
		local scene = SceneWaveMaker()
		scene:runScene()

	end
end

-------------------------------------
-- function init
-------------------------------------
function GameWorld:init(stage_id, stage_name, world_node, game_node1, game_node2, game_node3, ui, develop_mode)
    self.m_stageName = stage_name
    self.m_stageID = stage_id
    self.m_inGameUI = ui

    self.m_worldLayer = world_node
    self.m_worldLayer:setPosition(-640, 0)
    self:makeDebugLayer()

    self.m_gameNode1 = game_node1
    self.m_gameNode2 = game_node2
    self.m_gameNode3 = game_node3
    self.m_bDevelopMode = develop_mode or false

    self.m_bgNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_bgNode)

    self.m_groundNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_groundNode)

    self.m_gridNode = cc.Node:create()
    self.m_gridNode:setVisible(false)
    self.m_gameNode1:addChild(self.m_gridNode)

    self.m_worldNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_worldNode)

    self.m_missiledNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_missiledNode)

    self.m_lUnitList = {}
    self.m_lUnitList2 = {}
    self.m_tEnemyList = {}

    self.m_physWorld = PhysWorld(self.m_gameNode1, false)
    self.m_physWorld:initGroup()

    self.m_heroList = {}
    self.m_participants = {}

    self.m_missileFactory = MissileFactory(self)

    self.m_worldSize = nil
    self.m_worldScale = nil
    self.m_worldScaleRealtime = 1

    self.m_gameState = GameState(self)

    self.m_missileRange = {min_x=0-50, max_x = CRITERIA_RESOLUTION_X+50, min_y=-GAME_RESOLUTION_X/2, max_y=GAME_RESOLUTION_X/2}

    -- callback
    self.m_lWorldScaleChangeCB = {}

    g_currScene:addKeyKeyListener(self)

    self.m_touchPrevPos = nil
    self.m_tCollisionTime = {}

end

-------------------------------------
-- function init_wavemaker
-------------------------------------
function GameWorld:init_wavemaker(deck_type)
    if (deck_type == 'deck_5') then
        self:changeWorldSize(1)
    end

    self:init_formation()
    self:initBG()

    local t_deck = g_dragonListData.m_lDragonDeck

    local table_dragon = TABLE:get('dragon')

    for i=1, 6 do
        local idx = tostring(i)
        if t_deck[idx] and (tonumber(t_deck[idx]) ~= 0) then

            local dragon_id = tonumber(t_deck[idx])
            local t_dragon = table_dragon[dragon_id]
			
			if (dragon_id == 120010) then  
			else
				local t_dragon_data = g_dragonListData:getDragon(dragon_id)

				local lv = t_dragon_data['lv']
				local grade = t_dragon_data['grade']
				local evolution = t_dragon_data['evolution']

				local dragon = Dragon(nil, {0, 0, 20})
				dragon:initDragonSkillManager(dragon_id, t_dragon_data['grade'])
				dragon.m_tDragonInfo = t_dragon_data
				dragon:initAnimatorDragon(t_dragon['res'], t_dragon_data['evolution'])
				dragon.m_animator:setScale(0.5 * t_dragon['scale'])
				dragon.m_skillButtonIndicator = SkillButtonIndicator(dragon)
				dragon:initState()
				dragon:initStatus(t_dragon, lv, grade, evolution)

				self.m_leftFormationMgr:setChangePosCallback(dragon)

				dragon.m_dragonID = dragon_id
				dragon.m_charTable = t_dragon

				self.m_worldNode:addChild(dragon.m_rootNode, 2)
				self:addToUnitList(dragon)
				self.m_physWorld:addObject('hero', dragon)
				self:addHero(dragon, tonumber(i))

				dragon:makeHPGauge({0, -80}, true)

				self:participationHero(dragon)
			end
        end
    end

    self:makeTamer()

    do 
        self.m_chargeSystem = ChargeSystem(self, self.m_inGameUI)
        self.m_inGameUI:doActionReset()
    end

    do 
        self.m_formationSystem = FormationSystem(self)
        self:setBattleZone('basic', true)
    end

    do 
        self.m_skillIndicatorMgr = SkillIndicatorMgr(self, g_gameScene.m_colorLayerForSkill)
    end
end

-------------------------------------
-- function waveChange
-------------------------------------
function GameState:waveChange(isPrev)

    local world = self.m_world
    local map_manager = world.m_mapManager
    local t_wave_data, is_final_wave 
	
	if (isPrev) then
		t_wave_data, is_final_wave = world.m_waveMgr:getPrevWaveScriptData()
	else
		t_wave_data, is_final_wave = world.m_waveMgr:getNextWaveScriptData()
	end

    if (not t_wave_data) then
        return true
    end
    
    local t_bg_data = t_wave_data['bg']
    self.m_nextWaveDirectionType = t_wave_data['direction']
    if (not self.m_nextWaveDirectionType) and is_final_wave then
        self.m_nextWaveDirectionType = 'final_wave'
    end
    
    world.m_waveMgr:newScenario(isPrev)
    
    if (self.m_nextWaveDirectionType == nil) and (t_bg_data == nil) then
        return false

    elseif (self.m_nextWaveDirectionType) and (not t_bg_data) then
        return self:applyWaveDirection()

    elseif (t_bg_data) then
        if map_manager:applyWaveScript(t_bg_data) then
            map_manager.m_finishCB = function()
                    if (not self:applyWaveDirection()) then
                        self:changeState(GAME_STATE_FIGHT)
                    end
                end
            self:changeState(GAME_STATE_FIGHT_WAIT)
            return true
        else
            map_manager.m_finishCB = nil
            if (not self:applyWaveDirection()) then
                self:changeState(GAME_STATE_FIGHT)
            end
        end

    else
        error()

    end
end

-------------------------------------
-- function getPrevWaveScriptData
-------------------------------------
function WaveMgr:getPrevWaveScriptData()
    local wave = (self.m_currWave - 1)

    local t_script_data = self:getScriptData()

    if (self.m_maxWave > wave) then
		wave = 1
    end

    local is_final_wave = (wave == self.m_maxWave)

    return t_script_data['wave'][wave], is_final_wave
end

-------------------------------------
-- function getNextWaveScriptData
-------------------------------------
function WaveMgr:getNextWaveScriptData()
    local wave = (self.m_currWave + 1)

    local t_script_data = self:getScriptData()

    if (self.m_maxWave < wave) then
		wave = self.m_maxWave 
    end

    local is_final_wave = (wave == self.m_maxWave)

    return t_script_data['wave'][wave], is_final_wave
end

-------------------------------------
-- function newScenario
-------------------------------------
function WaveMgr:newScenario(isPrev)
	if (isPrev) then
		self.m_currWave = self.m_currWave - 1
	else
		self.m_currWave = self.m_currWave + 1
	end

	self.m_currWave = math_clamp(self.m_currWave, 0, self.m_maxWave)
    self.m_waveTimer = -1
   
    local t_data = self.m_scriptData['wave'][self.m_currWave]

    WaveMgr.changeCameraOption(self, t_data['camera'])
    self:newScenario_dynamicWave(t_data)

    self:dispatch('change_wave', self.m_currWave)
end

-------------------------------------
-- function makeLoadingUI
-- @brief scene전환 중 로딩화면 생성
-------------------------------------
function PerpleScene:makeLoadingUI()
    -- 검은색 레이어 생성
    local layer = cc.LayerColor:create()
    layer:setAnchorPoint(cc.p(0.5, 0.5))
	layer:setDockPoint(cc.p(0.5, 0.5))
    layer:setColor(cc.c3b(0, 0, 0))
    layer:setOpacity(255)

    if (self.m_loadingUIDuration > 0) then
        -- 화면 사이즈 크기로 설정
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        layer:setContentSize(visibleSize.width*1.5, visibleSize.height*5)

        do
            -- 메세지 지정
            local msg = 'loading...'

            -- 폰트 지정
            local font = 'res/font/common_font_01.ttf'
            --font = Translate:getFontPath()

            -- label 생성
            local label = cc.Label:createWithTTF(msg, font, 30, 0)
            label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
            label:setAnchorPoint(cc.p(0.5, 0.5))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:enableOutline(cc.c4b(0, 0, 0, 255), 3)
            layer:addChild(label)
        end
    end

    return layer
end