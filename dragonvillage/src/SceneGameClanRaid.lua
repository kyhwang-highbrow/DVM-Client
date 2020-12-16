local PARENT = SceneGame

local LIMIT_TIME = 180

local t_error = {
        [-1671] = Str('제한시간을 초과하였습니다.'),
        [-1371] = Str('유효하지 않은 던전입니다.'), 
    }

-------------------------------------
-- class SceneGameClanRaid
-------------------------------------
SceneGameClanRaid = class(PARENT, {
        m_realStartTime = 'number', -- 클랜 던전 시작 시간
        m_realLiveTimer = 'number', -- 클랜 던전 진행 시간 타이머
        m_enterBackTime = 'number', -- 백그라운드로 나갔을때 실제시간

        m_uiPopupTimeOut = 'UI',

        -- 서버 통신 관련
        m_bWaitingNet = 'boolean', -- 서버와 통신 중 여부
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGameClanRaid:init(game_key, stage_id, stage_name, develop_mode, stage_param)
    self.m_sceneName = 'SceneGameClanRaid'
    self.m_realStartTime = Timer:getServerTime()
    self.m_realLiveTimer = 0
    self.m_enterBackTime = nil
    self.m_uiPopupTimeOut = nil
    self.m_bWaitingNet = false

    -- 스테이지 속성에 따른 이름을 사용
    local attr = TableStageData():getStageAttr(stage_id)
    self.m_stageName = string.format('stage_clanraid_%s', attr)
end

-------------------------------------
-- function init_gameMode
-- @brief 스테이지 ID와 게임 모드 저장
-------------------------------------
function SceneGameClanRaid:init_gameMode(stage_id)
    self.m_stageID = stage_id
    self.m_gameMode = GAME_MODE_CLAN_RAID
    self.m_bgmName = 'bgm_colosseum'

    -- @E.T.
	g_errorTracker:set_lastStage(self.m_stageID)
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneGameClanRaid:onEnter()
    g_gameScene = self
    PerpleScene.onEnter(self)

    SoundMgr:playBGM(self.m_bgmName)
    
    g_autoPlaySetting:setMode(AUTO_NORMAL)
    g_autoPlaySetting:setAutoPlay(false)
    
    self.m_inGameUI = UI_GameClanRaid(self)
    self.m_resPreloadMgr = ResPreloadMgr()

    -- 절전모드 설정
    SetSleepMode(false)
end

-------------------------------------
-- function onExit
-------------------------------------
function SceneGameClanRaid:onExit()
    PARENT.onExit(self)

    -- 절전모드 설정
    SetSleepMode(true)
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneGameClanRaid:prepare()
    -- 테이블 리로드(메모리 보안을 위함)
    self:addLoading(function()
        TABLE:reloadForGame()
    end)

    self:addLoading(function()

        -- 레이어 생성
        self:init_layer()
        self.m_gameWorld = GameWorldClanRaid(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode)
        self.m_gameWorld:initGame(self.m_stageName)
        
        -- 스크린 사이즈 초기화
        self:sceneDidChangeViewSize()
    end)

    self:addLoading(function()
        -- 리소스 프리로드
        Translate:a2dTranslate('ui/a2d/ingame_enemy/ingame_enemy.vrp')

        local ret = self.m_resPreloadMgr:loadFromStageId(self.m_stageID)
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
-- function prepareDone
-------------------------------------
function SceneGameClanRaid:prepareDone()
    self.m_scheduleNode = cc.Node:create()
    self.m_scene:addChild(self.m_scheduleNode)
    self.m_scheduleNode:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
    
    self.m_gameWorld.m_gameState:changeState(GAME_STATE_START)
end

-------------------------------------
-- function update
-------------------------------------
function SceneGameClanRaid:update(dt)
    PARENT.update(self, dt)

    self:updateRealTimer(dt)
end

-------------------------------------
-- function updateRealTimer
-- @brief 클랜 던전 타이머 업데이트
-------------------------------------
function SceneGameClanRaid:updateRealTimer(dt)
    local world = self.m_gameWorld
    local game_state = self.m_gameWorld.m_gameState
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    
    -- 실제 진행 시간을 계산(배속에 영향을 받지 않도록 함)
    local bUpdateRealLiveTimer = false

    -- 클랜던전에서는 일시정지에도 시간이 흘러야 하나, 스킬 연출 시에는 시간이 흐르지 않게 한다.
    -- world:isPause()이 true를 리턴하는 경우는 게임이 진행중이나 싸움이 멈춰 있는 경우이다. 
    -- 예를 들면 스킬 사용 시 연출, 튜토리얼 진행 중 대사, 일반 모드에서의 인디케이터 사용 등...
    -- self.m_bPause는 일시정지일 때 true이다.
    if (((not world:isPause()) and game_state:isFight()) or self.m_bPause) then
        bUpdateRealLiveTimer = true
    end

    -- 죄악의 화신 토벌작전 이벤트에서는 일시정지를 할 때 시간이 흐르지 않도록 한다.
    if ((self.m_bPause) and (struct_raid:isEventIncarnationOfSinsMode())) then
        bUpdateRealLiveTimer = false
    end

    -- 진행 시간을 업데이트
    if (bUpdateRealLiveTimer) then
        self.m_realLiveTimer = self.m_realLiveTimer + (dt / self.m_timeScale)
    end

    -- 시간 제한 체크 및 처리
    if (self.m_realLiveTimer > LIMIT_TIME and not world:isFinished()) then
        if (self.m_bPause) then
            -- 일시 정지 상태인 경우 즉시 점수 저장 후 종료
            world:setGameFinish()

            local t_param = game_state:makeGameFinishParam(false)

            -- 총 데미지
            t_param['damage'] = game_state:getTotalDamage()

            self:networkGameFinish(t_param, {}, function()
                self:showTimeOutPopup()
            end)
        else
            if (game_state and game_state:isTimeOut() == false) then
                game_state:processTimeOut()
            end
        end
    end

    -- UI 시간 표기 갱신
    local remain_time = self:getRemainTimer()
    self.m_inGameUI:setTime(remain_time, true)
end

-------------------------------------
-- function getRemainTimer
-------------------------------------
function SceneGameClanRaid:getRemainTimer()
    local remain_time = math_max(LIMIT_TIME - self.m_realLiveTimer, 0)
    return remain_time
end

-------------------------------------
-- function networkGamePlayStart
-- @breif 게임 플레이 시작 시 요청
-------------------------------------
function SceneGameClanRaid:networkGamePlayStart(next_func)
    -- 죄악의 화신 출몰작전 이벤트의 경우 시작 콜을 보내지 않는다.
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    if (struct_raid:isEventIncarnationOfSinsMode()) then
        if (next_func) then
            next_func()
        end
        return
    end

    -- 백그라운드로 한번만 요청하면서 다음 스텝으로 진행시킴
    local function success_cb(ret)
        if (ret['status'] ~= 0) then return end

        self:networkGamePlayStart_response(ret)
    end

    local t_request = {}
    t_request['url'] = '/clans/dungeon_play'
    t_request['method'] = 'POST'
    t_request['data'] = { uid = g_userData:get('uid'), stage = self.m_stageID }
    t_request['success'] = success_cb
    
    Network:HMacRequest(t_request)

    -- @E.T.
	g_errorTracker:appendAPI(t_request['url'])

    if (next_func) then
        next_func()
    end
end

-------------------------------------
-- function networkGameComeback
-- @breif 게임에 복귀 시 요청
-------------------------------------
function SceneGameClanRaid:networkGameComeback(next_func)
    if (self.m_bWaitingNet) then return end
    self.m_bWaitingNet = true

    local uid = g_userData:get('uid')

    local function success_cb(ret)
        self:networkGameComeback_response(ret)

        -- 이미 클랜 던전 종료되었거나 제한 시간이 오버된 경우
        if (ret['is_gaming'] == false) then
            self.m_gameWorld:setGameFinish()

            -- 서버에서 제한시간이 오버된 경우는 즉시 종료
            self:showTimeOutPopup()
            return
        end

        self.m_bWaitingNet = false

        if (next_func) then
            next_func()
        end
    end

    -- 응답 상태 처리 함수
    local confirm_cb = function()
        UINavigator:goTo('clan_raid')
    end
    local response_status_cb = MakeResponseCB(t_error, confirm_cb)

    local api_url = '/clans/dungeon_check'
    
    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', self.m_stageID)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end


-------------------------------------
-- function networkGameComeback_response
-- @breif
-------------------------------------
function SceneGameClanRaid:networkGameComeback_response(ret)
    -- server_info 정보를 갱신
    g_serverData:networkCommonRespone(ret)

    -- 클랜 던전 진행 시간 재계산(백그라운드 이후 포그라운드로 진입까지 걸린 시간만큼 계산)
    if (self.m_enterBackTime) then
        local add_time = Timer:getServerTime() - self.m_enterBackTime
        self.m_realLiveTimer = self.m_realLiveTimer + add_time

        self.m_enterBackTime = nil
    end
end

-------------------------------------
-- function networkGameFinish
-- @breif
-------------------------------------
function SceneGameClanRaid:networkGameFinish(t_param, t_result_ref, next_func)
    if (self.m_bWaitingNet) then return end
    self.m_bWaitingNet = true

    local uid = g_userData:get('uid')

    local function success_cb(ret)
        local struct_raid = g_clanRaidData:getClanRaidStruct()
        
        self:networkGameFinish_response(ret, t_result_ref)

        -- 메일 갱신
		if (ret['new_mail'] == true) then
			g_highlightData:setHighlightMail()
		end

        -- 내 클랜 정보
        if (ret['my_claninfo']) then
            g_clanRaidData.m_tExMyClanInfo = clone(g_clanRaidData.m_tMyClanInfo)
            g_clanRaidData.m_tMyClanInfo = ret['my_claninfo']
        end

        -- 앞/뒤 순위 정보
        if (ret['rank_list']) then
            -- 죄악의 화신 토벌작전의 경우 점수가 높아진 경우에만 근접한 랭킹 순위 저장하여 리더보드 표시
            if (struct_raid:isEventIncarnationOfSinsMode()) then
                if (ret['new_score'] == true) then
                    g_eventIncarnationOfSinsData:setCloseRankers(ret['rank_list'])
                else
                    g_eventIncarnationOfSinsData:setCloseRankers({})
                end
            
            -- 클랜던전의 경우 항상 근접 랭킹 순위 저장하여 리더보드 표시
            else
                g_clanRaidData:applyCloseRankerData(ret['rank_list'])
            end
        end

        -- 보상 등급 지정
        t_result_ref['dmg_rank'] = ret['dmg_rank'] or 1

        -- 연습 모드나 이벤트 모드가 아닌 경우, 클랜 던전 정보 갱신
        if (not (struct_raid:isTrainingMode() or struct_raid:isEventIncarnationOfSinsMode())) then
            if (ret['dungeon']) then
                g_clanRaidData.m_structClanRaid = StructClanRaid(ret['dungeon'])
            end
        -- 연습 모드나 이벤트 모드일 경우, @jhakim 190325  training 모드는 finish통신에서 hp/등급을 받지 않기 때문에 클라에서 계산
        else
            -- 하드코딩
            local ex_hp = g_clanRaidData.m_structClanRaid['hp']:get()
            local cur_hp = ex_hp - t_param['damage']
            local damage = t_param['damage']
            if (damage >= 8000000) then 
                t_result_ref['dmg_rank'] = 5
            elseif (damage >= 6000000) then 
                t_result_ref['dmg_rank'] = 4
            elseif (damage >= 4000000) then 
                t_result_ref['dmg_rank'] = 3
            elseif (damage >= 2000000) then 
                t_result_ref['dmg_rank'] = 2
            else 
                t_result_ref['dmg_rank'] = 1
            end
            g_clanRaidData.m_structClanRaid['hp']:set(cur_hp)
        end

        self.m_bWaitingNet = false
        if next_func then
            next_func()
        end
    end

    -- 응답 상태 처리 함수
    local confirm_cb = function()
        UINavigator:goTo('clan_raid')
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        -- invalid season
        if (ret['status'] == -1364) then
            -- 로비로 이동
            local function ok_cb()
                UINavigator:goTo('lobby')
            end 
            MakeSimplePopup(POPUP_TYPE.OK, Str('시즌이 종료되었습니다.'), ok_cb)
            return true
        end

        return false
    end

    if (g_clanRaidData:isClanRaidStageID(self.m_stageID)) then
        local struct_raid = g_clanRaidData:getClanRaidStruct()

        -- 클랜던전 연습모드일 경우
        if (struct_raid:isTrainingMode()) then
            local api_url = '/clans/dungeon_training_finish'
            
            local ui_network = UI_Network()
            ui_network:setUrl(api_url)
            ui_network:setParam('uid', uid)
            ui_network:setParam('stage', self.m_stageID)
            local attr = TableStageData():getStageAttr(self.m_stageID)
            local g_data = MultiDeckMgr(MULTI_DECK_MODE.CLAN_RAID, nil, attr)
            local l_deck_up = g_deckData:getDeck(g_data:getDeckName('up'))

            -- 현재 사용한 덱 정보(드래곤 아이디만) 를 120008;120882.. 형태로 서버에 보냄
            local up_dragon_id_str = ''
            for i, doid in pairs(l_deck_up) do
                local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
                local doid = t_dragon_data['did']
                up_dragon_id_str = string.format("%s;%s", up_dragon_id_str, doid)
            end
            local l_deck_down = g_deckData:getDeck(g_data:getDeckName('down'))
            local down_dragon_id_str = ''
            for i, doid in pairs(l_deck_down) do
                local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
                local doid = t_dragon_data['did']
                down_dragon_id_str = string.format("%s;%s", down_dragon_id_str, doid)
            end

            -- 데미지 임의 
            ui_network:setParam('attr', attr)
            ui_network:setParam('score', t_param['damage'])
            ui_network:setParam('deck1_dids', up_dragon_id_str)
            ui_network:setParam('deck2_dids', down_dragon_id_str)
            ui_network:setResponseStatusCB(response_status_cb)
            ui_network:setSuccessCB(success_cb)
            ui_network:request()
            return
        
        -- 죄악의 화신 토벌작전 이벤트 모드 
        elseif (struct_raid:isEventIncarnationOfSinsMode()) then
            local attr = TableStageData():getStageAttr(self.m_stageID)
            local g_data = MultiDeckMgr(MULTI_DECK_MODE.CLAN_RAID, nil, attr)
            local main_deck = g_data:getMainDeck()
            if (main_deck == 'up') then
                main_deck = 1
            else
                main_deck = 2
            end
            local stage = self.m_stageID
            local damage = t_param['damage']
            local clear_time = t_param['clear_time']
            local check_time = g_accessTimeData:getCheckTime()

            g_eventIncarnationOfSinsData:request_eventIncarnationOfSinsFinish(stage, attr, damage, main_deck, clear_time, check_time, success_cb, nil)
            return
        end
    end

    local api_url = '/clans/dungeon_finish'
    
    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', self.m_stageID)

    -- 사용한 메인덱(수동 조작) 정보를 서버로 올려줌 ('up' = 1, 'down' = 2)
    local g_data = MultiDeckMgr(MULTI_DECK_MODE.CLAN_RAID, nil, nil)
    if (g_data) then
        local main_deck = g_data:getMainDeck()
        if (main_deck == 'up') then
            main_deck = 1
        else
            main_deck = 2
        end
        ui_network:setParam('choice_deck', main_deck)
    end
    -- 데미지 임의 
    ui_network:setParam('damage', t_param['damage'])
    ui_network:setParam('gamekey', self.m_gameKey)
    ui_network:setResponseStatusCB(response_status_cb)
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
function SceneGameClanRaid:networkGameFinish_response(ret, t_result_ref)
    -- server_info, staminas 정보를 갱신
    g_serverData:networkCommonRespone(ret)
    g_serverData:networkCommonRespone_addedItems(ret)

    -- 유저 정보 변경사항 적용 (레벨, 경험치)
    -- self:networkGameFinish_response_user_info(ret, t_result_ref)

    -- 변경된 드래곤 적용
    -- self:networkGameFinish_response_modified_dragons(ret, t_result_ref)

    -- 추가된 드래곤 적용
    -- self:networkGameFinish_response_added_dragons(ret, t_result_ref)

    -- 드랍 정보 drop_reward
    self:networkGameFinish_response_drop_reward(ret, t_result_ref)

    -- 메일 보상 정보 mail_reward
    self:networkGameFinish_response_mail_reward(ret, t_result_ref)

    -- 스테이지 클리어 정보 stage_clear_info
    self:networkGameFinish_response_stage_clear_info(ret)
end

-------------------------------------
-- function networkGameFinish_response_user_info
-- @breif 유저 정보 변경사항 적용 (레벨, 경험치)
-------------------------------------
function SceneGameClanRaid:networkGameFinish_response_user_info(ret, t_result_ref)
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
function SceneGameClanRaid:networkGameFinish_response_modified_dragons(ret, t_result_ref)
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
function SceneGameClanRaid:networkGameFinish_response_added_dragons(ret, t_result_ref)
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
function SceneGameClanRaid:networkGameFinish_response_drop_reward(ret, t_result_ref)
    if (not ret['added_items']) then
        return
    end

    local items_list = ret['added_items']['items_list']
    if (not items_list) then
        return
    end

    local drop_reward_list = t_result_ref['drop_reward_list']
    if (not drop_reward_list) then
        return
    end

    -- 드랍 아이템
    for i,v in ipairs(items_list) do
        local item_id = v['item_id']
        local count = v['count']
        local from = v['from']
        local data = nil
        
        if v['oids'] then
            -- Object는 하나만 리턴한다고 가정 (dragon or rune)
            local oid = v['oids'][1]
            if oid then
                -- 드래곤에서 정보 검색
                for _,obj_data in ipairs(ret['added_items']['dragons']) do
                    if (obj_data['id'] == oid) then
                        data = StructDragonObject(obj_data)
                        break
                    end
                end

                -- 룬에서 정보 검색
                if (not data) then
                    for _,obj_data in ipairs(ret['added_items']['runes']) do
                        if (obj_data['id'] == oid) then
                            data = StructRuneObject(obj_data)
                            break
                        end
                    end
                end
            end
        end


        local t_data = {item_id, count, from, data}
        table.insert(drop_reward_list, t_data)
    end
end

-------------------------------------
-- function networkGameFinish_response_mail_reward
-- @breif 수신함 보상 데이터 처리
-------------------------------------
function SceneGameClanRaid:networkGameFinish_response_mail_reward(ret, t_result_ref)
    if (not ret['reward_info']) then
        return
    end

    t_result_ref['mail_reward_list'] = ret['reward_info']
end

-------------------------------------
-- function networkGameFinish_response_stage_clear_info
-- @breif
-------------------------------------
function SceneGameClanRaid:networkGameFinish_response_stage_clear_info(ret)
    if (not ret['stage_clear_info']) then
        return
    end

    -- TODO: 클리어 정보 저장
end

-------------------------------------
-- function applicationDidEnterBackground
-------------------------------------
function SceneGameClanRaid:applicationDidEnterBackground()
    PARENT.applicationDidEnterBackground(self)

    self.m_enterBackTime = Timer:getServerTime()
end

-------------------------------------
-- function applicationWillEnterForeground
-------------------------------------
function SceneGameClanRaid:applicationWillEnterForeground()
    PARENT.applicationWillEnterForeground(self)

    -- 백그라운드로 나갔다가 진입시 흘러간 시간을 계산하기 위한 서버 통신
    self:networkGameComeback()
end

-------------------------------------
-- function showTimeOutPopup
-- @brief 타임 아웃이 되었을 경우 팝업 후 강제 종료
-------------------------------------
function SceneGameClanRaid:showTimeOutPopup()
    if (self.m_uiPopupTimeOut) then return end

    self.m_uiPopupTimeOut = MakeSimplePopup(POPUP_TYPE.OK, Str('제한시간을 초과하였습니다.'), function()
        UINavigator:goTo('clan_raid')
    end)
end