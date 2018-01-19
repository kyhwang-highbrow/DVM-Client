local PARENT = SceneGame

local LIMIT_TIME = 300

-------------------------------------
-- class SceneGameClanRaid
-------------------------------------
SceneGameClanRaid = class(PARENT, {
        m_realStartTime = 'number', -- 클랜 던전 시작 시간
        m_realLiveTimer = 'number', -- 클랜 던전 진행 시간 타이머

        m_uiPopupTimeOut = 'UI',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGameClanRaid:init(game_key, stage_id, stage_name, develop_mode, stage_param)
    self.m_sceneName = 'SceneGameClanRaid'
    self.m_realStartTime = Timer:getServerTime()
    self.m_realLiveTimer = 0
    self.m_uiPopupTimeOut = nil

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
-- function gameResume
-------------------------------------
function SceneGameClanRaid:gameResume()
    if (self.m_realLiveTimer > LIMIT_TIME) then
        self:showTimeOutPopup()
        return
    end

    PARENT.gameResume(self)
end

-------------------------------------
-- function updateRealTimer
-------------------------------------
function SceneGameClanRaid:updateRealTimer(dt)
    -- 실제 진행 시간을 계산(배속에 영향을 받지 않도록 함)
    self.m_realLiveTimer = self.m_realLiveTimer + (dt / self.m_timeScale)

    -- 시간 제한 체크 및 처리
    if (self.m_realLiveTimer > LIMIT_TIME) then
        if (self.m_bPause) then
            self:showTimeOutPopup()
        else
            local game_state = self.m_gameWorld.m_gameState
            game_state:processTimeOut()
        end
    end

    -- UI 시간 표기 갱신
    local remain_time = math_max(LIMIT_TIME - self.m_realLiveTimer, 0)
    self.m_inGameUI:setTime(remain_time, true)
end

-------------------------------------
-- function networkGameComeback
-- @breif 백그라운드로 나갔다가 복귀햇을 경우 요청
-------------------------------------
function SceneGameClanRaid:networkGameComeback(next_func)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        self:networkGameComeback_response(ret)

        -- 이미 클랜 던전 종료되었거나 제한 시간이 오버된 경우
        if (ret['is_gaming'] == false or self.m_realLiveTimer > LIMIT_TIME) then
            self:showTimeOutPopup()
        end

        if next_func then
            next_func()
        end
    end

    local api_url = '/clans/dungeon_check'
    
    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', self.m_stageID)
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

    -- 클랜 던전 진행 시간 재계산
    self.m_realLiveTimer = Timer:getServerTime() - self.m_realStartTime
end

-------------------------------------
-- function networkGameFinish
-- @breif
-------------------------------------
function SceneGameClanRaid:networkGameFinish(t_param, t_result_ref, next_func)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        self:networkGameFinish_response(ret, t_result_ref)

        -- 메일 갱신
		if (ret['new_mail'] == true) then
			g_highlightData:setHighlightMail()
		end

        -- 보상 등급 지정
        t_result_ref['dmg_rank'] = ret['dmg_rank'] or 1

        -- 클랜 던전 정보 갱신
        if (ret['dungeon']) then
            g_clanRaidData.m_structClanRaid = StructClanRaid(ret['dungeon'])
        end

        if next_func then
            next_func()
        end
    end

    -- 응답 상태 처리 함수
    local t_error = {
        [-1671] = Str('제한시간을 초과하였습니다.'),
        [-1371] = Str('유효하지 않은 던전입니다.'), 
    }
    local confirm_cb = function()
        UINavigator:goTo('clan_raid')
    end
    local response_status_cb = MakeResponseCB(t_error, confirm_cb)

    local api_url = '/clans/dungeon_finish'
    
    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', self.m_stageID)

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
            if g_chatClientSocket then
                g_chatClientSocket:globalUpdatePlayerUserInfo()
            end
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