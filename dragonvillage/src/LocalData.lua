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
    local f = io.open(self:getLocalDataSaveFileName(), 'r')

    local success_load = false
    if f then
        local content = f:read('*all')
        f:close()

        if (#content > 0) then
            self.m_rootTable = json_decode(content)
            success_load = true
        end
    end
        
    if (success_load == false) then
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

    do -- 드래곤 정렬
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

    -- 스테이지
    root_table['adventure_focus_stage'] = makeAdventureID(1, 1, 1)

    -- 시나리오 재생 룰
    root_table['scenario_playback_rules'] = 'first' -- 'always', 'off'

    -- 테스트 모드 on/off (빌드 자체에서 테스트 모드가 막혀있으면 무시하는 값)
    root_table['test_mode'] = nil

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

    local f = io.open(self:getLocalDataSaveFileName(),'w')
    if (not f) then
        return false
    end

    -- cclog(luadump(self.m_rootTable))
    local content = dkjson.encode(self.m_rootTable, {indent=true})
    f:write(content)
    f:close()

    return true
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

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                container[key] = {}
            end
            container = container[key]
        else
            if (data ~= nil) then
                container[key] = clone(data)
            else
                container[key] = nil
            end
        end
    end

    self:saveLocalDataFile()
end

-------------------------------------
-- function getFunc
-- @brief
-------------------------------------
function LocalData:getFunc(target_table, ...)
    local args = {...}
    local cnt = #args

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