local PARENT = SceneGame

-------------------------------------
-- class SceneGameArenaNew
-------------------------------------
SceneGameArenaNew = class(PARENT, {
        m_bFriendMatch = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGameArenaNew:init(game_key, stage_id, stage_name, develop_mode, friend_match, match_rule)
    self.m_bDevelopMode = develop_mode
    self.m_bFriendMatch = friend_match or false
    self.m_matchRule = match_rule or 'colosseum'
    self.m_stageName = 'stage_' .. self.m_matchRule -- stage_colosseum / stage_clanwar
    self.m_sceneName = 'SceneGameArenaNew'

    -- 친구대전 
    if (self.m_bFriendMatch) then
        g_deckData:setSelectedDeck('fpvp_atk')
    else
        g_deckData:setSelectedDeck('arena_new_a')
    end

    -- 아레나 로딩은 상대방 덱을 확인하기 위해 5초간 유지
    self.m_minLoadingTime = 5

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() UINavigator:goTo('arena_new') end, 'SceneGameArenaNew')
end

-------------------------------------
-- function init_gameMode
-- @brief 스테이지 ID와 게임 모드 저장
-------------------------------------
function SceneGameArenaNew:init_gameMode()
    self.m_stageID = ARENA_NEW_STAGE_ID
    self.m_gameMode = self.m_matchRule == 'clanwar' and GAME_MODE_ARENA or GAME_MODE_ARENA_NEW
    self.m_bgmName = 'bgm_colosseum'

    -- @E.T.
	g_errorTracker:set_lastStage(self.m_stageID)
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneGameArenaNew:onEnter()
    g_gameScene = self
    PerpleScene.onEnter(self)

    SoundMgr:playBGM(self.m_bgmName)
    
    g_autoPlaySetting:setMode(AUTO_COLOSSEUM)

    if (IS_ARENA_AUTOPLAY()) then -- 테스트 모드에서 연속전투 활성화
    else
        g_autoPlaySetting:setAutoPlay(false)
    end
    
    -- 콜로세움이냐 클랜전이냐
    if (self.m_matchRule == 'colosseum') then
        self.m_inGameUI = UI_GameArenaNew(self)
    else
        self.m_inGameUI = UI_GameArena(self)
    end
   
    self.m_resPreloadMgr = ResPreloadMgr()

    -- 절전모드 설정
    SetSleepMode(false)
end

-------------------------------------
-- function onExit
-------------------------------------
function SceneGameArenaNew:onExit()
    PARENT.onExit(self)

    -- 절전모드 설정
    SetSleepMode(true)
end

-------------------------------------
-- function makeLoadingUI
-- @brief scene전환 중 로딩화면 생성
-------------------------------------
function SceneGameArenaNew:makeLoadingUI()
    return UI_LoadingArenaNew(self)
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneGameArenaNew:prepare()
    -- 테이블 리로드(메모리 보안을 위함)
    self:addLoading(function()
        TABLE:reloadForGame()
    end)

    self:addLoading(function()

        -- 레이어 생성
        self:init_layer()

        if (self.m_matchRule == 'colosseum') then
            self.m_gameWorld = GameWorldArenaNew(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode, self.m_bFriendMatch)
        else
            self.m_gameWorld = GameWorldArena(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode, self.m_bFriendMatch)
        end

        self.m_gameWorld:initGame(self.m_stageName)
        
        -- 스크린 사이즈 초기화
        self:sceneDidChangeViewSize()
    end)

    self:addLoading(function()
        -- 리소스 프리로드
        self.m_resPreloadMgr:resCaching('res/ui/a2d/colosseum_result/colosseum_result.vrp')

        Translate:a2dTranslate('ui/a2d/ingame_enemy/ingame_enemy.vrp')

        local ret = self.m_resPreloadMgr:loadForColosseum()
        return ret
    end)

    self:addLoading(function()
        UILoader.cache('ingame_result.ui')
        UILoader.cache('ingame_pause.ui')
        return true
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
function SceneGameArenaNew:prepareAfter()
    -- 콜로세움은 어뷰징 이슈로 playstart 요청을 하지 않음
    return true
end

-------------------------------------
-- function prepareDone
-------------------------------------
function SceneGameArenaNew:prepareDone()
    self.m_scheduleNode = cc.Node:create()
    self.m_scene:addChild(self.m_scheduleNode)
    self.m_scheduleNode:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
    
    self.m_gameWorld.m_gameState:changeState(GAME_STATE_START)
end

-------------------------------------
-- function networkGameFinish
-- @breif
-------------------------------------
function SceneGameArenaNew:networkGameFinish(t_param, t_result_ref, next_func)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        self:networkGameFinish_response(ret, t_result_ref)

        if next_func then
            next_func()
        end
    end

    local api_url = '/game/arena_new/finish'
    
    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', self.m_stageID)
    ui_network:setParam('clear_type', t_param['clear_type'])
    ui_network:setParam('exp_rate', t_param['exp_rate'])
    ui_network:setParam('clear_mission_1', t_param['clear_mission_1'])
    ui_network:setParam('clear_mission_2', t_param['clear_mission_2'])
    ui_network:setParam('clear_mission_3', t_param['clear_mission_3'])
    ui_network:setParam('gold', t_param['gold'])
    ui_network:setParam('gamekey', self.m_gameKey)

    -- 연속 전투의 경우 네트워크 에러 시 잠시 대기후 재요청보냄
    if (g_autoPlaySetting:isAutoPlay()) then
        ui_network:setRetryCount_forGameFinish()
    end

    ui_network:setRevocable(false) -- 게임 종료 통신은 취소를 하지 못함
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
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
function SceneGameArenaNew:networkGameFinish_response(ret, t_result_ref)
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
    self:networkGameFinish_response_stage_clear_info(ret)
end

-------------------------------------
-- function networkGameFinish_response_user_info
-- @breif 유저 정보 변경사항 적용 (레벨, 경험치)
-------------------------------------
function SceneGameArenaNew:networkGameFinish_response_user_info(ret, t_result_ref)
    local user_levelup_data = t_result_ref['user_levelup_data']

    -- 이전 레벨과 경험치
    user_levelup_data['prev_lv'] = g_userData:get('lv')
    user_levelup_data['prev_exp'] = g_userData:get('exp')

    do -- 서버에서 넘어온 레벨과 경험치 적용
        if ret['lv'] then
            g_userData:applyServerData(ret['lv'], 'lv')

            -- 채팅 서버에 변경사항 적용
            g_lobbyChangeMgr:globalUpdatePlayerUserInfo()
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
function SceneGameArenaNew:networkGameFinish_response_modified_dragons(ret, t_result_ref)
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
function SceneGameArenaNew:networkGameFinish_response_added_dragons(ret, t_result_ref)
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
function SceneGameArenaNew:networkGameFinish_response_drop_reward(ret, t_result_ref)
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
-- function makeGameState
-- @brief
-------------------------------------
function SceneGameArenaNew:makeGameState(game_world)
    return GameState_ArenaNew(game_world)
end

-------------------------------------
-- function getStructUserInfo_Player
-- @brief 플레이어 유저 정보
-- @return StructUserInfo
-------------------------------------
function SceneGameArenaNew:getStructUserInfo_Player()
    local is_friendMatch = self.m_bFriendMatch
    local user_info = is_friendMatch and g_friendMatchData.m_playerUserInfo or g_arenaNewData:getPlayerArenaUserInfo()
    return user_info
end

-------------------------------------
-- function getStructUserInfo_Opponent
-- @brief 상대방 유저 정보
-- @return StructUserInfo
-------------------------------------
function SceneGameArenaNew:getStructUserInfo_Opponent()

    -- 개발 모드일 경우
    if (self.m_bDevelopMode == true) then
        local user_info = g_arenaNewData:getMatchUserInfo()
        if user_info then
            return user_info
        end
    end

    local is_friendMatch = self.m_bFriendMatch
    local user_info = is_friendMatch and g_friendMatchData.m_matchInfo  or g_arenaNewData:getMatchUserInfo()
    return user_info
end

-------------------------------------
-- function getStartOption_Opponent
-- @brief 상대방 드래곤들의 시작 버프
-------------------------------------
function SceneGameArenaNew:getStartOption_Opponent()
    return {}
end