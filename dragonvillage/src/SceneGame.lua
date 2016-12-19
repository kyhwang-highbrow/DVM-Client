-- g_gameScene = nil

-------------------------------------
-- class SceneGame
-------------------------------------
SceneGame = class(PerpleScene, {
        m_stageName = '',
        m_stageID = '',
        m_gameMode = 'GAME_MODE_CONSTANT',
        m_scheduleNode = 'cc.Node',
        m_gameWorld = 'GameWorld',

        -- 레이어 관련 변수
        m_containerLayer = 'cc.Node',   -- (UI, 화면 연출에 관여)
        m_viewLayer = 'cc.Node',
        m_shakeLayer = 'cc.Node',       -- 화면 떨림 레이어
        m_cameraLayer = 'cc.Node',
        m_worldLayer = 'cc.Node',       -- 월드 레이어 (줌인, 줌아웃 관여)
        m_gameNode1 = 'cc.Node',        -- 게임 레이어 (배경, 유닛, 미사일 영역)
        m_gameNode2 = 'cc.Node',        -- 게임 레이어 (이펙트 및 폰트 영역)
        m_gameNode3 = 'cc.Node',        -- 게임 레이어 (pause, resume 제외하는 이펙트 및 폰트 영역)
        m_feverNode = 'cc.Node',        -- 피버 레이어
        m_gameIndicatorNode = 'cc.Node',
        m_gameHighlightNode = 'cc.Node',
        m_colorLayerForSkill = 'cc.LayerColor', -- 암전 레이어

        m_colorLayerTamerSkill = 'cc.LayerColor', -- 암전 레이어

        m_bStop = '',
        m_bPause = '',

        m_inGameUI = '',

        m_bDevelopMode = 'boolean',

        m_gameKey = 'number', -- 서버에서 넘어오는 고유 Key
        m_resPreloadMgr = 'ResPreloadMgr',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGame:init(game_key, stage_id, stage_name, develop_mode)
    self.m_gameKey = game_key    
    self.m_stageName = stage_name
    self.m_bUseLoadingUI = true
    self.m_bRemoveCache = true

    self.m_bStop = false
    self.m_bPause = false
    self.m_bDevelopMode = develop_mode or false
    self.m_bShowTopUserInfo = false

    self:init_gameMode(stage_id)
end

-------------------------------------
-- function init_gameMode
-- @brief 스테이지 ID와 게임 모드 저장
-------------------------------------
function SceneGame:init_gameMode(stage_id)
    self.m_stageID = stage_id

    if (self.m_stageID == DEV_STAGE_ID) then
        self.m_gameMode = GAME_MODE_ADVENTURE
    else
        self.m_gameMode = g_stageData:getGameMode(self.m_stageID)
    end
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

			do -- 카메라 레이어
				self.m_cameraLayer = cc.Node:create()
				self.m_shakeLayer:addChild(self.m_cameraLayer)

				do -- 월드 레이어 (줌인, 줌아웃 관여)
					self.m_worldLayer = cc.Node:create()
					self.m_cameraLayer:addChild(self.m_worldLayer)

					do -- 게임 레이어 (배경, 유닛, 미사일 용)
						self.m_gameNode1 = cc.Node:create()
						self.m_worldLayer:addChild(self.m_gameNode1)

						-- 게임 레이어 (이펙트 및 폰트 용)
						self.m_gameNode2 = cc.Node:create()
						self.m_worldLayer:addChild(self.m_gameNode2)

						-- 게임 레이어 (pause 제외 이펙트 및 폰트 용)
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
    end

	-- 암전용 레이어 (카메라 등의 영향 제외)
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
    self.m_resPreloadMgr = ResPreloadMgr()
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
        self.m_gameWorld = GameWorld(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_feverNode, self.m_inGameUI, self.m_bDevelopMode)
        self.m_gameWorld:initGame(self.m_stageName)
        
        -- 스크린 사이즈 초기화
        self:sceneDidChangeViewSize()
    end)

    self:addLoading(function()
        -- 리소스 프리로드
        local ret = self.m_resPreloadMgr:loadFromStageName(self.m_stageName)
        return ret
    end)
    
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
    
    self.m_gameWorld.m_gameState:changeState(GAME_STATE_START)
end

-------------------------------------
-- function appearDone
-------------------------------------
function SceneGame:appearDone()
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

-------------------------------------
-- function networkGameFinish
-- @breif
-------------------------------------
function SceneGame:networkGameFinish(t_param, t_result_ref, next_func)
    if (self.m_stageID == DEV_STAGE_ID) then
        if next_func then
            next_func()
        end
        return
    end

    local uid = g_userData:get('uid')

    local function success_cb(ret)
        self:networkGameFinish_response(ret, t_result_ref)

        if next_func then
            next_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/stage/finish')
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', self.m_stageID)
    ui_network:setParam('clear_type', t_param['clear_type'])
    ui_network:setParam('exp_rate', t_param['exp_rate'])
    ui_network:setParam('clear_mission_1', t_param['clear_mission_1'])
    ui_network:setParam('clear_mission_2', t_param['clear_mission_2'])
    ui_network:setParam('clear_mission_3', t_param['clear_mission_3'])
    ui_network:setParam('gold', t_param['gold'])
    ui_network:setParam('gamekey', self.m_gameKey)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()

    -- @TODO sgkim 남은 작업들
    -- 0. 모험모드 전체 관련 데이터 stage_clear_info
    -- 1. 드랍 아이템에 드래곤 드랍 처리하기
    -- 2. 도전과제 구현하기
    -- 3. 선택할 수 있는 덱이 여러개일 때 처리하기 (지금은 무조건 '1'번 덱으로 처리 중)
    -- 4. 스테이지 진입 시 덱 검증(드히에 드래곤들 데이터가 유효한지 체크하는게 있음)
end

-------------------------------------
-- function networkGameFinish_response
-- @breif
-- @param t_result_ref 결과화면에서 사용하기 위한 각종 정보들 저장
--        t_result_ref['user_levelup_data'] = {}
--        t_result_ref['dragon_levelu_data_list'] = {}
--        t_result_ref['drop_reward_grade'] = 'c'
--        t_result_ref['drop_reward_list'] = {}
-------------------------------------
function SceneGame:networkGameFinish_response(ret, t_result_ref)
    -- server_info, staminas 정보를 갱신
    g_serverData:networkCommonRespone(ret)

    -- 유저 정보 변경사항 적용 (레벨, 경험치)
    self:networkGameFinish_response_user_info(ret, t_result_ref)

    -- 변경된 드래곤 적용
    self:networkGameFinish_response_modified_dragons(ret, t_result_ref)

    -- 추가된 드래곤 적용
    self:networkGameFinish_response_added_dragons(ret, t_result_ref)

    -- 드랍 정보 drop_reward
    self:networkGameFinish_response_drop_reward(ret, t_result_ref)

    -- 스테이지 클리어 정보 stage_clear_info
end

-------------------------------------
-- function networkGameFinish_response_user_info
-- @breif 유저 정보 변경사항 적용 (레벨, 경험치)
-------------------------------------
function SceneGame:networkGameFinish_response_user_info(ret, t_result_ref)
    local user_levelup_data = t_result_ref['user_levelup_data']

    -- 이전 레벨과 경험치
    user_levelup_data['prev_lv'] = g_userData:get('lv')
    user_levelup_data['prev_exp'] = g_userData:get('exp')

    do -- 서버에서 넘어온 레벨과 경험치 적용
        if ret['lv'] then
            g_userData:applyServerData(ret['lv'], 'lv')
        end

        if ret['exp'] then
            g_userData:applyServerData(ret['exp'], 'exp')
        end
    end

    -- 현재 레벨과 경험치
    user_levelup_data['curr_lv'] = g_userData:get('lv')
    user_levelup_data['curr_exp'] = g_userData:get('exp')

    -- 현재 레벨의 최대 경험치
    local table_user_level = TableUserLevel()
    local lv = g_userData:get('lv')
    local curr_max_exp = table_user_level:getReqExp(lv)
    user_levelup_data['curr_max_exp'] = curr_max_exp

    -- 최대 레벨 여부
    user_levelup_data['is_max_level'] = (curr_max_exp == 0)

    do -- 추가 경험치 총량
        local low_lv = user_levelup_data['prev_lv']
        local low_lv_exp = user_levelup_data['prev_exp']
        local high_lv = user_levelup_data['curr_lv']
        local high_lv_exp = user_levelup_data['curr_exp']
        user_levelup_data['add_exp'] = table_user_level:getBetweenExp(low_lv, low_lv_exp, high_lv, high_lv_exp)
    end    
end

-------------------------------------
-- function networkGameFinish_response_modified_dragons
-- @breif 드래곤 변경사항 적용 (레벨, 경험치)
-------------------------------------
function SceneGame:networkGameFinish_response_modified_dragons(ret, t_result_ref)
    if (not ret['modified_dragons']) then
        return
    end

    local dragon_levelu_data_list = t_result_ref['dragon_levelu_data_list']
    local table_dragon = TableDragon()

    for _,t_dragon in ipairs(ret['modified_dragons']) do
        local udid = t_dragon['id']
        local did = t_dragon['did']
            
        -- 변경 전 드래곤 정보
        local t_prev_dragon_data = g_dragonsData:getDragonDataFromUid(udid)

        -- 서버에서 넘어온 드래곤 정보 저장
        g_dragonsData:applyDragonData(t_dragon)

        -- 변경 후 드래곤 정보
        local t_next_dragon_data = g_dragonsData:getDragonDataFromUid(udid)

        -- 드래곤 레벨업 연출을 위한 데이터
        local levelup_data = {}
        do
             levelup_data['prev_lv'] = t_prev_dragon_data['lv']
             levelup_data['prev_exp'] = t_prev_dragon_data['exp']
             levelup_data['curr_lv'] = t_next_dragon_data['lv']
             levelup_data['curr_exp'] = t_next_dragon_data['exp']

             local max_level = dragonMaxLevel(t_next_dragon_data['grade'])
             local is_max_level = (t_next_dragon_data['lv'] >= max_level)
             levelup_data['is_max_level'] = is_max_level
        end

        -- t_data에 정보를 담음
        local t_data = {}
        t_data['levelup_data'] = levelup_data
        t_data['user_data'] = t_next_dragon_data
        t_data['table_data'] = table_dragon:get(did)

        -- 레퍼런스 테이블에 insert
        table.insert(dragon_levelu_data_list, t_data)
    end
end

-------------------------------------
-- function networkGameFinish_response_added_dragons
-- @breif 드랍에 의해 유저에 추가된 드래곤들 추가
-------------------------------------
function SceneGame:networkGameFinish_response_added_dragons(ret, t_result_ref)
    if (not ret['added_dragons']) then
        return
    end

    for _,t_dragon in ipairs(ret['added_dragons']) do
        -- 서버에서 넘어온 드래곤 정보 저장
        g_dragonsData:applyDragonData(t_dragon)
    end
end


-------------------------------------
-- function networkGameFinish_response_drop_reward
-- @breif 드랍 보상 데이터 처리
-------------------------------------
function SceneGame:networkGameFinish_response_drop_reward(ret, t_result_ref)
    if (not ret['drop_reward']) then
        return
    end

    -- 보상 등급 지정
    t_result_ref['drop_reward_grade'] = ret['drop_reward_grade'] or 'c'

    local drop_reward_list = t_result_ref['drop_reward_list']

    for i,v in ipairs(ret['drop_reward']) do
        local item_id = tonumber(v['item_id'])
        local count = tonumber(v['num'])
        local t_data = {item_id, count}
        table.insert(drop_reward_list, t_data)
    end
end

-------------------------------------
-- function isAdventureMode
-- @brief 모험 모드 스테이지 여부
-------------------------------------
function SceneGame:isAdventureMode()
    return (self.m_gameMode == GAME_MODE_ADVENTURE)
end

-------------------------------------
-- function isNestMode
-- @brief 네스트 던전 스테이지 여부
-------------------------------------
function SceneGame:isNestMode()
    if (self.m_gameMode == GAME_MODE_NEST_DUNGEON) then
        return true
    else
        return false
    end
end