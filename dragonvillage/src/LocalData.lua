-------------------------------------
-- class LocalData
-------------------------------------
LocalData = class({
        m_rootTable = 'table',
        m_rootTableDefault = 'table',

        m_nLockCnt = 'number',
        m_bDirtyDataTable = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function LocalData:init()
    self.m_rootTable = nil
    self.m_rootTableDefault = nil
    self.m_nLockCnt = 0
    self.m_bDirtyDataTable = false
end

-------------------------------------
-- function getInstance
-------------------------------------
function LocalData:getInstance()
    if g_localData then
        return g_localData
    end
    
    g_localData = LocalData()
    g_localData:loadLocalDataFile()

    return g_localData
end

-------------------------------------
-- function getLocalDataSaveFileName
-------------------------------------
function LocalData:getLocalDataSaveFileName()
    local file = 'local_data.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function loadLocalDataFile
-------------------------------------
function LocalData:loadLocalDataFile()
    local ret_json, success_load = LoadLocalSaveJson(self:getLocalDataSaveFileName())

    if (success_load == true) then
        self.m_rootTable = ret_json
    else
        self.m_rootTable = self:makeDefaultLocalData()
        self:saveLocalDataFile()
    end

    self.m_rootTableDefault = self:makeDefaultLocalData()
end

-------------------------------------
-- function makeDefaultLocalData
-------------------------------------
function LocalData:makeDefaultLocalData()
    local root_table = {}

    do -- 룬 일괄 판매 옵션
        local t_data = {}
        t_data['grade_1'] = true
        t_data['grade_2'] = true
        t_data['grade_3'] = false
        t_data['grade_4'] = false
        t_data['grade_5'] = false
        t_data['grade_6'] = false
        t_data['rarity_4'] = false
        t_data['rarity_3'] = false
        t_data['rarity_2'] = true
        t_data['rarity_1'] = true
        root_table['option_rune_bulk_sell'] = t_data
    end

    do -- 드래곤 정렬 (관리)
        local t_data = {}
        do
            local t_list = {}
            table.insert(t_list, 'lv')
            table.insert(t_list, 'grade')
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

    do -- 드래곤 정렬 (전투)
        local t_data = {}
        do
            local t_list = {}
            table.insert(t_list, 'lv')
            table.insert(t_list, 'grade')
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
    end

    -- 스테이지
    root_table['adventure_focus_stage'] = makeAdventureID(1, 1, 1)

    -- 시나리오 재생 룰
    root_table['scenario_playback_rules'] = 'first' -- 'always', 'off'

    -- 테스트 모드 on/off (빌드 자체에서 테스트 모드가 막혀있으면 무시하는 값)
    root_table['test_mode'] = nil

    -- 기본 설정 데이터
    root_table['lowResMode'] = false
    root_table['bgm'] = true
    root_table['sfx'] = true
    root_table['fps'] = false

    return root_table
end

-------------------------------------
-- function saveLocalDataFile
-------------------------------------
function LocalData:saveLocalDataFile()
    if (self.m_nLockCnt > 0) then
        self.m_bDirtyDataTable = true
        return
    end

    return SaveLocalSaveJson(self:getLocalDataSaveFileName(), self.m_rootTable)
end

-------------------------------------
-- function clearLocalDataFile
-------------------------------------
function LocalData:clearLocalDataFile()
    os.remove(self:getLocalDataSaveFileName())
end


-------------------------------------
-- function applyLocalData
-- @brief 서버로부터 받은 정보로 세이브 데이터를 갱신
-------------------------------------
function LocalData:applyLocalData(data, ...)
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
        self:saveLocalDataFile()
    end
end

-------------------------------------
-- function getFunc
-- @brief
-------------------------------------
function LocalData:getFunc(target_table, ...)
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
function LocalData:get(...)
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
function LocalData:getRef(...)
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
function LocalData:lockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt + 1)
end

-------------------------------------
-- function unlockSaveData
-- @breif
-------------------------------------
function LocalData:unlockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt -1)

    if (self.m_nLockCnt <= 0) then
        if self.m_bDirtyDataTable then
            self:saveLocalDataFile()
        end
        self.m_bDirtyDataTable = false
    end
end

-------------------------------------
-- function getExplorationDec
-- @breif
-------------------------------------
function LocalData:getExplorationDec(epr_id)
    return self:get('exploration_deck', tostring(epr_id))
end

-------------------------------------
-- function setExplorationDeck
-- @breif
-------------------------------------
function LocalData:setExplorationDec(epr_id, l_doid)
    self:applyLocalData(l_doid, 'exploration_deck', tostring(epr_id))
end

-------------------------------------
-- function applySetting
-------------------------------------
function LocalData:applySetting()
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
end

-------------------------------------
-- function isGooglePlayConnected
-- @breif
-------------------------------------
function LocalData:isGooglePlayConnected()
    if isAndroid() then
        return (self:get('local', 'googleplay_connected') == 'on')
    else
        return false
    end
end