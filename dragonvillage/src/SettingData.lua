---------------------------------------------------------------------------------------------------------------
-- @brief LocalData에서 설정(옵션)에 관련된 정보들을 따로 분리
--        Release빌드 환경에서 LocalData의 파일을 암호화해서 처리하다보니 속도가 느림
--        설정(옵션) 항목들은 노출이 되어도 큰 문제가 없어서 속도 향상을 위해 암호화 하지 않음
-- @date 2018.1.9 sgkim
---------------------------------------------------------------------------------------------------------------

-------------------------------------
-- class SettingData
-------------------------------------
SettingData = class({
        m_rootTable = 'table',
        m_rootTableDefault = 'table',

        m_nLockCnt = 'number',
        m_bDirtyDataTable = 'boolean',

        m_cloudRootTable = 'table', -- 게임 서버에서 관리하는 설정값
    })

-------------------------------------
-- function init
-------------------------------------
function SettingData:init()
    self.m_rootTable = nil
    self.m_rootTableDefault = nil
    self.m_nLockCnt = 0
    self.m_bDirtyDataTable = false
    self.m_cloudRootTable = {}
end

-------------------------------------
-- function getInstance
-------------------------------------
function SettingData:getInstance()
    if g_settingData then
        return g_settingData
    end
    
    g_settingData = SettingData()
    g_settingData:loadSettingDataFile()

    return g_settingData
end

-------------------------------------
-- function getSettingDataSaveFileName
-------------------------------------
function SettingData:getSettingDataSaveFileName()
    local file = 'setting_data.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function loadSettingDataFile
-------------------------------------
function SettingData:loadSettingDataFile()
    local ret_json, success_load = LoadLocalSaveJson(self:getSettingDataSaveFileName())

    if (success_load == true) then
        self.m_rootTable = ret_json
    else
        self.m_rootTable = self:makeDefaultSettingData()
        self:saveSettingDataFile()
    end

    self.m_rootTableDefault = self:makeDefaultSettingData()
end

-------------------------------------
-- function makeDefaultSettingData
-------------------------------------
function SettingData:makeDefaultSettingData()
    local root_table = {}

    do -- 룬 일괄 판매 옵션
        local t_data = {}
        -- 등급
        t_data['grade_1'] = true
        t_data['grade_2'] = true
        t_data['grade_3'] = false
        t_data['grade_4'] = false
        t_data['grade_5'] = false
        t_data['grade_6'] = false
        t_data['grade_7'] = false

        -- 희귀도
        t_data['rarity_4'] = false
        t_data['rarity_3'] = false
        t_data['rarity_2'] = true
        t_data['rarity_1'] = true

        -- 강화 여부
        t_data['enhance'] = false

        -- 룬 번호 : 홀수
        t_data['odd'] = true
        -- 룬 번호 : 짝수
        t_data['even'] = true

        -- 주옵션
        t_data['mopt1'] = true
        t_data['mopt2'] = true
        t_data['mopt3'] = true
        t_data['mopt4'] = true
        t_data['mopt5'] = true
        t_data['mopt6'] = true
        t_data['mopt7'] = true
        t_data['mopt8'] = true

        root_table['option_rune_bulk_sell'] = t_data
    end

    do -- 룬 옵션 필터 옵션
        local t_data = {}
        t_data['include_equipped'] = false
        root_table['option_rune_filter'] = t_data
    end

    do -- 드래곤 선택 (바로가기)
        local t_data = {}
        t_data['grade_1'] = false
        t_data['grade_2'] = false
        t_data['grade_3'] = true
        t_data['grade_4'] = true
        t_data['grade_5'] = true
        t_data['grade_6'] = true
        t_data['attr_1'] = true
        t_data['attr_2'] = true
        t_data['attr_3'] = true
        t_data['attr_4'] = true
        t_data['attr_5'] = true
        t_data['type_1'] = true
        t_data['type_2'] = true
        t_data['type_3'] = true
        t_data['type_4'] = true
        t_data['rarity_1'] = true
        t_data['rarity_2'] = true
        t_data['rarity_3'] = true
        t_data['rarity_4'] = true
        t_data['rarity_5'] = true
        root_table['option_dragon_select'] = t_data
    end

    do -- 드래곤 정렬 (관리)
        local t_data = {}
        do
            local t_list = {}
            table.insert(t_list, 'grade')
            table.insert(t_list, 'lv')
            table.insert(t_list, 'rarity')
            table.insert(t_list, 'friendship')
            table.insert(t_list, 'attr')
            table.insert(t_list, 'hp')
            table.insert(t_list, 'def')
            table.insert(t_list, 'atk')
            table.insert(t_list, 'role')
            table.insert(t_list, 'did')
            t_data['order'] = t_list
        end

        do
            t_data['ascending'] = false
        end
        root_table['dragon_sort_order'] = t_list
        root_table['dragon_sort'] = t_data
    end

    do -- 드래곤 정렬 (바로가기)
        local t_data = {}
        do
            local t_list = {}
            table.insert(t_list, 'grade')
            table.insert(t_list, 'lv')
            table.insert(t_list, 'rarity')
            table.insert(t_list, 'friendship')
            table.insert(t_list, 'attr')
            table.insert(t_list, 'hp')
            table.insert(t_list, 'def')
            table.insert(t_list, 'atk')
            table.insert(t_list, 'role')
            table.insert(t_list, 'did')
            t_data['order'] = t_list
        end

        do
            t_data['ascending'] = false
        end
        root_table['dragon_sort_order_select'] = t_list
        root_table['dragon_sort_select'] = t_data
    end

    do -- 드래곤 정렬 (전투)
        local t_data = {}
        do
            local t_list = {}
            table.insert(t_list, 'grade')
            table.insert(t_list, 'lv')
            table.insert(t_list, 'rarity')
            table.insert(t_list, 'friendship')
            table.insert(t_list, 'attr')
            table.insert(t_list, 'hp')
            table.insert(t_list, 'def')
            table.insert(t_list, 'atk')
            table.insert(t_list, 'role')
            table.insert(t_list, 'did')
            t_data['order'] = t_list
        end

        do
            t_data['ascending'] = false
        end
        root_table['dragon_sort_order_fight'] = t_list
        root_table['dragon_sort_fight'] = t_data

        -- 드래곤 정렬 탐험
        root_table['dragon_sort_epr'] = t_data
    end

    -- 스테이지
    root_table['adventure_focus_stage'] = makeAdventureID(1, 1, 1)

    -- 시나리오 재생 룰
    root_table['scenario_playback_rules'] = 'first' -- 'always', 'off'

    -- 테스트 모드 on/off (빌드 자체에서 테스트 모드가 막혀있으면 무시하는 값)
    root_table['test_mode'] = nil
    root_table['colosseum_test_mode'] = nil

    -- 기본 설정 데이터
    root_table['lowResMode'] = false
    root_table['bgm'] = true
    root_table['sfx'] = true
    root_table['fps'] = false
    root_table['sleep_mode'] = true
    root_table['shake_mode'] = true

    -- 언어 확인 (기기 언어와, 게임 언어가 다를 경우)
    root_table['language_verification_complete'] = false

    do -- 상품별 판매 촉진하는 팝업 쿨타임 만료시간
        local t_data = {}
        t_data['auto_pick'] = 0         -- 황금 던전에서 자동줍기 상품 
        t_data['quest_double'] = 0      -- 일일퀘스트 2배 상품
        t_data['capsule_box'] = 0       -- 캡슐 뽑기 입장 팝업
        t_data['challenge_mode'] = 0    -- 그림자 신전 입장 권유 팝업
        root_table['promote_expired'] = t_data
    end

    return root_table
end

-------------------------------------
-- function saveSettingDataFile
-------------------------------------
function SettingData:saveSettingDataFile()
    if (self.m_nLockCnt > 0) then
        self.m_bDirtyDataTable = true
        return
    end

    return SaveLocalSaveJson(self:getSettingDataSaveFileName(), self.m_rootTable, true) -- param : filename, t_data, skip_xor)
end

-------------------------------------
-- function clearSettingDataFile
-------------------------------------
function SettingData:clearSettingDataFile()
    os.remove(self:getSettingDataSaveFileName())
end


-------------------------------------
-- function applySettingData
-- @brief 서버로부터 받은 정보로 세이브 데이터를 갱신
-------------------------------------
function SettingData:applySettingData(data, ...)
    local args = {...}
    local cnt = #args

    local dirty = false

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                container[key] = {}
                dirty = true
            end
            container = container[key]
        else
            if (container[key] ~= data) then
                if (data ~= nil) then
                    container[key] = clone(data)
                else
                    container[key] = nil
                end
                dirty = true
            end
        end
    end

    -- 변경사항이 있을 때에만 저장
    if dirty then
        self:saveSettingDataFile()
    end
end

-------------------------------------
-- function getFunc
-- @brief
-------------------------------------
function SettingData:getFunc(target_table, ...)
    local args = {...}
    local cnt = #args

    if (not target_table) then
        return nil
    end

    local container = target_table
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                return nil
            end
            container = container[key]
        else
            if (container[key] ~= nil) then
                return clone(container[key])
            end
        end
    end

    return nil
end

-------------------------------------
-- function get
-- @brief
-------------------------------------
function SettingData:get(...)
    local ret = self:getFunc(self.m_rootTable, ...)

    if (ret == nil) then
        return self:getFunc(self.m_rootTableDefault, ...)
    end

    return ret
end

-------------------------------------
-- function getRef
-- @brief
-------------------------------------
function SettingData:getRef(...)
    local args = {...}
    local cnt = #args

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                return nil
            end
            container = container[key]
        else
            if (container[key] ~= nil) then
                return container[key]
            end
        end
    end

    return nil
end

-------------------------------------
-- function lockSaveData
-- @breif
-------------------------------------
function SettingData:lockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt + 1)
end

-------------------------------------
-- function unlockSaveData
-- @breif
-------------------------------------
function SettingData:unlockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt -1)

    if (self.m_nLockCnt <= 0) then
        if self.m_bDirtyDataTable then
            self:saveSettingDataFile()
        end
        self.m_bDirtyDataTable = false
    end
end

-------------------------------------
-- function getExplorationDec
-- @breif
-------------------------------------
function SettingData:getExplorationDec(epr_id)
    return self:get('exploration_deck', tostring(epr_id))
end

-------------------------------------
-- function setExplorationDec
-- @breif
-------------------------------------
function SettingData:setExplorationDec(epr_id, l_doid)
    self:applySettingData(l_doid, 'exploration_deck', tostring(epr_id))
end

-------------------------------------
-- function clearDataList
-- @breif
-------------------------------------
function SettingData:clearDataList(key)
	local list = g_settingData:get(key)
	if (not list) then 
		return
	end

    for k, v in pairs(list) do
        g_settingData:applySettingData(false, key, k)
    end
end

-------------------------------------
-- function clearDataListDaily
-- @breif
-------------------------------------
function SettingData:clearDataListDaily()
	self:lockSaveData()
    self:clearDataList('event_full_popup')
	self:clearDataList('lobby_guide_seen')
    self:clearDataList('arena_guide')
    self:clearDataList('farewell')
	self:unlockSaveData()
end

-------------------------------------
-- function applySetting
-------------------------------------
function SettingData:applySetting()
    -- fps 출력
    local fps = self:get('fps')
    cc.Director:getInstance():setDisplayStats(fps)

    -- 저사양모드
    local lowResMode = self:get('lowResMode')
    setLowEndMode(lowResMode)

    -- 배경음
    local bgm = self:get('bgm')
    SoundMgr:setBgmOnOff(bgm)

    -- 효과음
    local sfx = self:get('sfx')
    SoundMgr:setSfxOnOff(sfx)

    -- 사운드 엔진
    local engine_mode = self:get('sound_module') or cc.SimpleAudioEngine:getInstance():getEngineMode()
    cc.SimpleAudioEngine:getInstance():setEngineMode(engine_mode)

    -- 절전 모드
    if self:isSleepMode() then
        
        -- 현재 Scene이 GameScene일 경우 skip
        if g_gameScene and (g_currScene == g_gameScene) then -- skip
        -- 현재 Scene이 TitleScene일 경우 skip
        elseif g_currScene and (g_currScene.m_sceneName == 'SceneTitle') then -- skip
        -- 현재 Scene이 ScenePatch일 경우 skip
        elseif g_currScene and (g_currScene.m_sceneName == 'ScenePatch') then -- skip
        else
            cc.Director:getInstance():setIdleTimerDisabled(false)
        end
    else
        cc.Director:getInstance():setIdleTimerDisabled(true)
    end
end

-------------------------------------
-- function migration
-- @brief 업데이트 전 LocalData에 저장되어 있는 설정을 SettingData로 옮기는 작업
-------------------------------------
function SettingData:migration(local_data_instance)
    
    -- 옮겨질 항목들
    local l_key = {
        'option_rune_bulk_sell',
        'dragon_sort_order',
        'dragon_sort',
        'dragon_sort_order_fight',
        'dragon_sort_fight',
        'dragon_sort_epr',
        'dragon_sort_forest',
        'adventure_focus_stage',
        'scenario_playback_rules',
        'test_mode',
        'colosseum_test_mode',
        'lowResMode',
        'bgm',
        'sfx',
        'fps',

        'event_full_popup',
        'auto_play_setting',
        'exploration_deck',
        'clan_raid',
        'sound_module',
    }

    -- 저장 잠금
    local_data_instance:lockSaveData()

    -- key를 순회하며 설정 정보 이전
    for _,key in pairs(l_key) do
        local value = local_data_instance:get(key)
        if (value ~= nil) then
            -- 설정 이전
            self:applySettingData(value, key)

            -- LocalData에서 해당 값 삭제
            local_data_instance:applyLocalData(nil, key)
        end
    end

    -- 저장 잠금 해제 (한 번에 모두 저장)
    local_data_instance:unlockSaveData()
end

-------------------------------------
-- function isSleepMode
-- @brief
-------------------------------------
function SettingData:isSleepMode()
    local sleep_mode = self:get('sleep_mode')
    if (sleep_mode == nil) then
        return true
    end

    return sleep_mode
end

-------------------------------------
-- function setSleepMode
-- @brief
-------------------------------------
function SettingData:setSleepMode(sleep_mode)
    self:applySettingData(sleep_mode, 'sleep_mode')
end

-------------------------------------
-- function getPromoteExpired
-- @return 상품별(key) 판매 촉진하는 팝업 만료시간(second)
-------------------------------------
function SettingData:getPromoteExpired(key)
    -- 값이 없을 경우 0으로 리턴(현재보다 과거 시간으로 처리하기 위해)
    return self:get('promote_expired', key) or 0
end

-------------------------------------
-- function setPromoteCoolTime
-- @brief 상품별(key) 판매 촉진하는 팝업 만료시간(second) 갱신
-------------------------------------
function SettingData:setPromoteCoolTime(key, time)
    self:applySettingData(time, 'promote_expired', key) 
end

-------------------------------------
-- function setChellengeModeSettingdata
-------------------------------------
function SettingData:setChellengeModeSettingdata(type, value)
    self:applySettingData(time, 'promote_expired', type) 
end

------------------------------------
-- function getChellengeModeSettingdata
-------------------------------------
function SettingData:getChellengeModeSettingdata(type)
    return self:get('challenge_history', type)
end

-------------------------------------
-- function setChellengeModeSettingdata
-------------------------------------
function SettingData:setChellengeModeSettingdata(type, value)
    self:applySettingData(value, 'challenge_history', type) 
end


-------------------------------------
-- function resetChallengeSettingData
-- @brief 그림자 신전 관련 세팅 데이터 리셋
-------------------------------------
function SettingData:resetChallengeSettingData()
    --[[
     self:applySettingData(nil, 'challenge_history', 'last_entry_day')
     self:applySettingData(nil, 'challenge_history', 'last_day_rank')
     self:applySettingData(nil, 'challenge_history', 'last_day_rank_time')
     self:applySettingData(nil, 'challenge_history', 'history_rank')
     self:applySettingData(nil, 'challenge_history', 'history_rank_time')
     self:applySettingData(nil, 'challenge_history', 'last_entry_day')
     self:applySettingData(nil, 'promote_expired', 'challenge_mode')
     --]]
end

-------------------------------------
-- function resetSettingData
-------------------------------------
function SettingData:resetSettingData()
    --[[
    self.m_rootTable = nil
    SaveLocalSaveJson(self:getSettingDataSaveFileName(), self.m_rootTable, true) -- param : filename, t_data, skip_xor)
    --]]
end

-------------------------------------
-- function getIllusionBestScore
-- key : event_illusion
-------------------------------------
function SettingData:getIllusionBestScore()
    return self:get('event_illusion') or 0
end

-------------------------------------
-- function setIllusionBestScore

-- key : event_illusion
-------------------------------------
function SettingData:setIllusionBestScore(t_score_data)
    self:applySettingData(t_score_data, 'event_illusion') 
end

-------------------------------------
-- function getLinkAccountStep
-------------------------------------
function SettingData:getLinkAccountStep()
    return self:get('t_link_account_step') or {}
end

-------------------------------------
-- function setLinkAccountStep
-------------------------------------
function SettingData:setLinkAccountStep(t_link)
    self:applySettingData(t_link, 't_link_account_step') 
end

-------------------------------------
-- function setIsShowedRunGuardianDungeonInfoPopup
-------------------------------------
function SettingData:setIsShowedRunGuardianDungeonInfoPopup(is_showed)
    self:applySettingData(is_showed, 'is_showed_rune_guardian_info_popup') 
end

-------------------------------------
-- function getIsShowedRunGuardianDungeonInfoPopup
function SettingData:getIsShowedRunGuardianDungeonInfoPopup()
    return self:get('is_showed_rune_guardian_info_popup') or false
end

-------------------------------------
-- function setClanWarDay
-------------------------------------
function SettingData:setClanWarDay(day)
    self:applySettingData(day, 'clan_war', 'day') 
end

-------------------------------------
-- function getClanWarDay
-------------------------------------
function SettingData:getClanWarDay()
    return self:get('clan_war', 'day')
end

-------------------------------------
-- function setClanWarSeason
-------------------------------------
function SettingData:setClanWarSeason(season)
    self:applySettingData(season, 'clan_war', 'season') 
end

-------------------------------------
-- function getClanWarSeason
-------------------------------------
function SettingData:getClanWarSeason()
    return self:get('clan_war', 'season')
end

-------------------------------------
-- function setSkipInfoForFarewellWarningPopup
-------------------------------------
function SettingData:setSkipInfoForFarewellWarningPopup(date)
     self:applySettingData(date, 'farewell', 'skip_warning_popup')
end

-------------------------------------
-- function getSkipInfoForFarewellWarningPopup
-------------------------------------
function SettingData:getSkipInfoForFarewellWarningPopup()    
    return self:get('farewell', 'skip_warning_popup')
end

-------------------------------------
-- function setAutoFarewell
-------------------------------------
function SettingData:setAutoFarewell(is_active, dragon_rarity)
    self:applySettingData(is_active, 'farewell', 'auto_farewell', dragon_rarity)
end

-------------------------------------
-- function getAutoFarewell
-------------------------------------
function SettingData:getAutoFarewell(dragon_rarity)
    return self:get('farewell', 'auto_farewell', dragon_rarity)
end

-------------------------------------
-- function getCloudSetting
-- @brief
-- @param key string
-------------------------------------
function SettingData:getCloudSetting(key)
    if (not self.m_cloudRootTable) then
        return nil
    end

    local ret = self.m_cloudRootTable[key]
    return ret
end

-------------------------------------
-- function applyCloudSettings
-- @brief
-- @param t_data table
-------------------------------------
function SettingData:applyCloudSettings(t_data)
    self.m_cloudRootTable = t_data or {}
end

-------------------------------------
-- function request_setSetting
-- @breif
-- @param push_all boolean
-------------------------------------
function SettingData:request_setSetting(push_all, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        
        if ret['settings'] then
            self:applyCloudSettings(ret['settings'])
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/set_setting')
    ui_network:setParam('uid', uid)
    ui_network:setParam('push_all', push_all)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end