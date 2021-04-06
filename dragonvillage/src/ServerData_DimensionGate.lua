-------------------------------------
-- class ServerData_DimensionGate
-------------------------------------
ServerData_DimensionGate = class({
    --
    m_serverData = 'ServerData', -- ServerData.lua
    m_bDirtyDimensionGateInfo = 'boolean', -- lobby 진입 후 최초 request_dmgateInfo() 이 후에 로비 진입시 마다 반복되는 것을 방지

    m_stageTableName = 'string',



    m_unlockStageList = '',  -- 스테이지 클리어후 스테이지 언락 VRP를 보여주기 위함
    --m_blessTable = '',      -- table_bless


    -- Refactoring
    m_stageTable = '', -- request_stageTable() from table_dmgate_stage.csv
    m_stageTableKeys = '', -- [mode_id][stage_id] = index of m_stageTable[mode_id]
    m_dmgateInfo = '', -- 

    
    m_shopInfo = '',            -- request_shopInfo() from server
    m_shopProductCounts = '', 
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_DimensionGate:init(server_data)
    self.m_serverData = server_data
    self.m_bDirtyDimensionGateInfo = true

    -- SHOP
    self.m_shopInfo = {}
    self.m_shopProductCounts = {}

    self.m_unlockStageList = {}

    -- TEST
    self.m_stageTableName = 'table_dmgate_stage' -- csv from server
end

-- ******************************************************************************************************
-- ** request and response functions from server and csv file
-- ******************************************************************************************************

----------------------------------------------------------------------------
-- function request_dmgateInfo
----------------------------------------------------------------------------
function ServerData_DimensionGate:request_dmgateInfo(success_cb, fail_cb)
    local user_id = g_userData:get('uid')

    -- 처음 불린 이후에 false
    if (not self.m_bDirtyDimensionGateInfo) then
        if success_cb then
            success_cb()
        end

        return
    end

    -- callback for success
    local function callback_for_success(ret)
        self:response_dmgateInfo(ret)

        if(success_cb) then success_cb(ret) end
    end
    
    local ui_network = UI_Network()
    ui_network:setUrl('/dmgate/info')
    ui_network:setParam('uid', user_id)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(callback_for_success)
    ui_network:setFailCB(fail_cb)
    ui_network:request()

    return ui_network
end

----------------------------------------------------------------------------
-- function response_dmgateInfo
----------------------------------------------------------------------------
function ServerData_DimensionGate:response_dmgateInfo(ret)
    local dmgate_info = ret['dmgate_info']
   

    if dmgate_info == nil then
        error('key for accessing the table is changed from \'dmgate_info\' to other from server')
    end

    -- request_dmgateInfo()를 처음 부르는 경우
    if (self.m_dmgateInfo == nil) then
        self.m_dmgateInfo = {}
        self:request_stageTable()
    end

    -- 차원문 스테이지 종료 후 GameStage_DimensionGate에서 '/dmgate/finish'을 통해 불린 경우
    if (#self.m_dmgateInfo > 0) and (ret['added_item'] == nil) and (ret['stage'] ~= nil) then
        local stage_id = ret['stage'] -- 클리어한 스테이지 (type : number)
        if (stage_id == nil) then error('cannot find cleared stage id with the key \'stage\' from the table which is result from \'/dmgate/finish\'') end
        -- TODO : need error check stage id is included in table_dmgate_stage.csv
        local mode_id = self:getModeID(stage_id)
        -- CHECK : need to check length of ret['stage']
   
        -- 클리어한 스테이지의 보상 정보가 바뀐 경우 0->1, 1->2 을 체크하기 위함
        local prev_reward_status = self.m_dmgateInfo[mode_id]['stage'][tostring(stage_id)]
        local curr_reward_status = dmgate_info[mode_id]['stage'][tostring(stage_id)]
        
        -- 0->1만 체크해야 하지만 1->2 인'/dmgate/reward' 의 경우 이 조건문을 들어올 수 없기에 별도 조건문 생략.
        if (prev_reward_status ~= curr_reward_status) then
            local stage_key = self.m_stageTableKeys[mode_id][stage_id]
            local next_stage_data = self.m_stageTable[mode_id][stage_key + 1]
            -- 다음 스테이지가 같은 모드 안에 존재하는지 체크
            if next_stage_data ~= nil then 
                local next_stage_id = next_stage_data['stage_id']
                if (next_stage_id ~= nil) then 
                    self.m_unlockStageList[next_stage_id] = true
                end
            end
        end
    end

    self.m_dmgateInfo = dmgate_info

    self.m_bDirtyDimensionGateInfo = false
end

----------------------------------------------------------------------------
-- function request_reward
-- @brief 차원문 보상 수령 서버에 요청
-- UI_DimensionGateItem:click_rewardBtn()
----------------------------------------------------------------------------
function ServerData_DimensionGate:request_reward(stage_id, success_cb, fail_cb)
    local uid = g_userData:get('uid')

    local function callback_for_success(ret)
        self:response_dmgateInfo(ret)

        if success_cb then success_cb(ret) end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dmgate/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(callback_for_success)
    ui_network:setFailCB(fail_cb)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function request_stageTable
-- @brief table_dmgate_stage.csv 를 서버에서 가져와 stage_id 기준으로 sort된 리스트와 
-- stage_id를 키값으로 가지는 리스트를 생성한다.
-------------------------------------
function ServerData_DimensionGate:request_stageTable()
    -- key 값을 별도로 가지고 있을 경우 sort가 작동하지 않기 때문에 변환
    local dimensionGate_list = table.MapToList(TABLE:get(self.m_stageTableName))
    
    -- sort by elss-than operation
    local function sort_func(a, b) return a['stage_id'] < b['stage_id'] end
    table.sort(dimensionGate_list, sort_func)

    local mode_id
    local stage_id
    self.m_stageTable = {}
    self.m_stageTableKeys = {}
    for key, data in pairs(dimensionGate_list) do
        -- 모드 id (앙그라, 마누스, ..)에 따라 stage 정보 분류
        stage_id = data['stage_id'] -- number
        mode_id = self:getModeID(stage_id) -- number

        if(self.m_stageTable[mode_id] == nil) then 
            self.m_stageTable[mode_id] = {}
            self.m_stageTableKeys[mode_id] = {}
        end

        table.insert(self.m_stageTable[mode_id], data)
        -- stage_id 로 검색하기 위해 index 키값을 따로 저장
        self.m_stageTableKeys[mode_id][stage_id] = #self.m_stageTable[mode_id]
    end    
end

-------------------------------------
-- function request_shopInfo
-------------------------------------
function ServerData_DimensionGate:request_shopInfo(success_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- callback for success
    local function callback_for_success(ret)
        self:response_shopInfo(ret)
        
        if success_cb then success_cb(ret) end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dmgate/shop_info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)  -- 게임 종료 통신이 아니면 취소
    ui_network:setSuccessCB(callback_for_success)
    ui_network:setFailCB(fail_cb)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function response_shopInfo
-------------------------------------
function ServerData_DimensionGate:response_shopInfo(ret)
    self.m_shopInfo = ret['table_shop_dmgate']
    self.m_shopProductCounts = ret['buycnt']
end

-------------------------------------
-- function request_buy
-------------------------------------
function ServerData_DimensionGate:request_buy(product_id, count, cb_func, fail_cb)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        -- 재화 갱신
        g_serverData:networkCommonRespone(ret)

        -- 아이템 수령
        g_serverData:networkCommonRespone_addedItems(ret)

        if(cb_func) then
            cb_func(ret)
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dmgate/shop_buying')
    ui_network:setParam('uid', uid)
    ui_network:setParam('product_id', tonumber(product_id)) 
    ui_network:setParam('count', tonumber(count))
    ui_network:setRevocable(true)  -- 게임 종료 통신이 아니면 취소
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()

    return ui_network
end

-- ******************************************************************************************************
-- ** Help functions related with 
-- ******************************************************************************************************

----------------------------------------------------------------------------
-- function isStageDimensionGate
-- @brief 
----------------------------------------------------------------------------
function ServerData_DimensionGate:isStageDimensionGate(stage_id)
    if (not self:isStageInTable(stage_id)) then return false end 

    local dungeon_id = self:getDungeonID(stage_id) -- GAME_MODE_DIMENSION_GATE = 30
    return dungeon_id == GAME_MODE_DIMENSION_GATE
end

----------------------------------------------------------------------------
-- function isStageInMode
-- @brief 
----------------------------------------------------------------------------
function ServerData_DimensionGate:isStageInMode(mode_id, stage_id)
    if mode_id == nil or stage_id == nil then 
        error('Missed out more than one parameter')
    end
    
    return mode_id == self:getModeID(stage_id)
end

----------------------------------------------------------------------------
-- function isStageInTable
-- @brief 
----------------------------------------------------------------------------
function ServerData_DimensionGate:isStageInTable(stage_id)
    local mode_id = self:getModeID(stage_id)
    if mode_id == nil then return false end
    if self.m_stageTableKeys[mode_id] == nil then return false end

    local key = self.m_stageTableKeys[mode_id][stage_id]
    if key == nil then return false end
    return self.m_stageTable[mode_id][key] ~= nil
end

----------------------------------------------------------------------------
-- function getPrevStageID
-- @brief 
----------------------------------------------------------------------------
function ServerData_DimensionGate:getPrevStageID(stage_id)
    local mode_id = self:getModeID(stage_id)
    local curr_stage_key = self.m_stageTableKeys[mode_id][stage_id]

    if (not key) then 
        error('This stage_id is not included in table_dmgate_stage.')
    end

    local prev_stage_data = self.m_stageTable[mode_id][curr_stage_key - 1]

    if prev_stage_data == nil then return nil end

    return prev_stage_data['stage_id']
end

----------------------------------------------------------------------------
-- function getPrevStageID
-- @brief 
----------------------------------------------------------------------------
function ServerData_DimensionGate:CheckBothStagesInSameChapater(lhs, rhs)
    return self:getChapterID(lhs) == self:getChapterID(rhs)
end

----------------------------------------------------------------------------
-- function getNextStageID
-- @brief 
----------------------------------------------------------------------------
function ServerData_DimensionGate:getNextStageID(stage_id)
    local mode_id = self:getModeID(stage_id)
    local curr_stage_key = self.m_stageTableKeys[mode_id][stage_id]

    if (not key) then 
        error('This stage_id is not included in table_dmgate_stage.')
    end

    local prev_stage_data = self.m_stageTable[mode_id][curr_stage_key + 1]

    if prev_stage_data == nil then return nil end

    return prev_stage_data['stage_id']
end

----------------------------------------------------------------------------
-- function getStageListByChapter
----------------------------------------------------------------------------
function ServerData_DimensionGate:getStageListByChapter(mode_id, chapter_id)
   local mode_table = self.m_stageTable[mode_id]
   if (mode_table == nil) then error('there is not any mode with this mode_id ' .. tostring(mode_id)) end
   local result = {}

   local stage_id
   local result_index
   local diff_id
   
   for _, data in pairs(mode_table) do
        stage_id = data['stage_id']

        if (self:getChapterID(stage_id) ==  chapter_id) then 
            diff_id = self:getDifficultyID(stage_id)
            result_index = self:getStageID(stage_id)
            if (result[result_index] == nil) then result[result_index] = {} end

            table.insert(result[result_index], data)
        end
   end

   return result
end

----------------------------------------------------------------------------
-- function getStageInfoList
----------------------------------------------------------------------------
function ServerData_DimensionGate:getStageInfoList(mode_id)
    if not mode_id then error('Forgot to pass mode_id as param') end

    return self.m_dmgateInfo[mode_id]['stage']
end

----------------------------------------------------------------------------
-- function getStageInfoList
----------------------------------------------------------------------------
function ServerData_DimensionGate:getClearedMaxStageInList(mode_id)
    if not mode_id then error('Forgot to pass mode_id as param') end

    local maxStage_id = 0
    local stage_id
    for key, stage_status in pairs(self:getStageInfoList(mode_id)) do
        stage_id = tonumber(key)
        if (stage_id > maxStage_id) then
            if self:checkStageTime(stage_id) then
                maxStage_id = stage_id
            end
        end
    end

    return maxStage_id
end

----------------------------------------------------------------------------
-- function checkStageTime
----------------------------------------------------------------------------
function ServerData_DimensionGate:checkStageTime(stage_id)
    if not stage_id then error('Forgot to pass mode_id as param') end

    local mode_id = self:getModeID(stage_id)
    local stage_key = self.m_stageTableKeys[mode_id][stage_id]

    if (not stage_key) then 
        error('This stage_id is not included in table_dmgate_stage.')
    end

    local stage_table = self.m_stageTable[mode_id][stage_key]
    local start_date = tostring(stage_table['start_date'])
    local end_date = tostring(stage_table['end_date'])

    local date_format = 'yyyymmdd'
    local parser = pl.Date.Format(date_format)

    -- 단말기(local)의 타임존 (단위 : 초)
    local timezone_local = datetime.getTimeZoneOffset()

    -- 서버(server)의 타임존 (단위 : 초)
    local timezone_server = Timer:getServerTimeZoneOffset()
    local offset = (timezone_local - timezone_server)

    local start_time
    local end_time
    local curr_time = Timer:getServerTime()

    if (start_date ~= '' or start_date) then
        local parse_start_date = parser:parse(start_date)
        if(parse_start_date) then
            if (parse_start_date['time'] == nil) then
                --start_time = nil
                error('parse_start_date[\'time\'] is nil')
            else
                start_time = parse_start_date['time'] + offset -- <- 문자열로 된 날짜를 timestamp로 변환할 때 서버 타임존의 숫자로 보정
            end
        end
    end

    if (end_date ~= '' or end_date) then
        local parse_end_date = parser:parse(end_date)
        if(parse_end_date) then
            if (parse_end_date['time'] == nil) then
                error('parse_start_date[\'time\'] is nil')
            else
                end_time = parse_end_date['time'] + offset  -- <- 문자열로 된 날짜를 timestamp로 변환할 때 서버 타임존의 숫자로 보정
            end
        end
    end
 
    -- 시작 종료 시간 모두 걸려있는 경우
    if (start_time) and (end_time) then
        return (start_time < curr_time and curr_time < end_time)
        
    -- 시작 시간만 걸려있는 경우
    elseif (start_time) then
        return (start_time < curr_time)

    -- 종료 시간만 걸려있는 경우
    elseif (end_time) then
        return (curr_time < end_time)
    end

    return true
end

----------------------------------------------------------------------------
-- function getStageStatus
-- nil -> -1 : not opened
-- 0 : opened but not cleared
-- 1 : cleared but not received reward yet
-- 2 : received reward
----------------------------------------------------------------------------
function ServerData_DimensionGate:getStageStatus(stage_id)
    local mode_id = self:getModeID(stage_id)
    return self.m_dmgateInfo[mode_id]['stage'][tostring(stage_id)] or -1
end


----------------------------------------------------------------------------
-- function isStageOpened
-- nil : not opened
-- 0 : opened but not cleared
-- 1 : cleared but not received reward yet
-- 2 : received reward
----------------------------------------------------------------------------
function ServerData_DimensionGate:isStageOpened(stage_id)
    return self:getStageStatus(stage_id) >= 0
end

----------------------------------------------------------------------------
-- function isStageCleared
-- nil : not opened
-- 0 : opened but not cleared
-- 1 : cleared but not received reward yet
-- 2 : received reward
----------------------------------------------------------------------------
function ServerData_DimensionGate:isStageCleared(stage_id)
    return self:getStageStatus(stage_id) > 0
end


----------------------------------------------------------------------------
-- function isStageRewarded
-- nil : not opened
-- 0 : opened but not cleared
-- 1 : cleared but not received reward yet
-- 2 : received reward
----------------------------------------------------------------------------
function ServerData_DimensionGate:isStageRewarded(stage_id)
    return self:getStageStatus(stage_id) >= 2
end

----------------------------------------------------------------------------
-- function getCurrDiffInList
----------------------------------------------------------------------------
function ServerData_DimensionGate:getCurrDiffInList(list)
    if #list == 0 then error('there isn\'n any stage in list') end

    local currDiffLevel
    local stage_id
    for _, data in pairs(list) do
        stage_id = data['stage_id']

        if(stage_id == nil) then error('received wrong list as param or stage_id is different with csv table.') end

        -- 스테이지가 열려있으면 현재 난이도를 해당 스테이지로 업데이트
        if self:isStageOpened(stage_id) and self:checkStageTime(stage_id) then
            currDiffLevel = self:getDifficultyID(stage_id)
            
        else
            -- 첫번째 스테이지가 열려있지 않으면 어느 스테이지도 열려있지 않으므로 첫스테이지 난이도 리턴.
            if (currDiffLevel == nil) then currDiffLevel = self:getDifficultyID(stage_id) end
            break;
        end
    end

    -- TODO : 모든 스테이지의 checkStageTime()이 FALSE 인 경우 가장 낮은 난이도가 리턴됨.
    -- UI 자체에서 막을 것임.

    return currDiffLevel
end

-- ******************************************************************************************************
-- ** Help functions related with request_shopInfo
-- ******************************************************************************************************


-- ******************************************************************************************************
-- ** Help functions related with request_shopInfo
-- ******************************************************************************************************



----------------------------------------------------------------------------
-- function getShopInfoProductList
-- @brief 
----------------------------------------------------------------------------
function ServerData_DimensionGate:getShopInfoProductList()
    return self.m_shopInfo
end


----------------------------------------------------------------------------
-- function getProductCount
-- @brief 
----------------------------------------------------------------------------
function ServerData_DimensionGate:getProductCount( product_id)
    return self.m_shopProductCounts[tostring(product_id)]
end



----------------------------------------------------------------------------
-- function checkInUnlockList
-- @brief 
----------------------------------------------------------------------------
function ServerData_DimensionGate:checkInUnlockList(stage_id)
    if self.m_unlockStageList[tonumber(stage_id)] ~= nil then
        self.m_unlockStageList[tonumber(stage_id)] = nil
        return true
    end

    return false
end


-- ******************************************************************************************************
-- ** 
-- ******************************************************************************************************

-------------------------------------
-- function makeDimensionGateID
-- 3011001
-- 30xxxxx 던전(dungeon)        : 차원문, ...
--   1xxxx 모드(mode)           : 마누스의 차원문, ...
--    1xxx 챕터(chapter)        : 상위층, 하위층, ...
--     1xx 난이도(difficulty)   : 쉬움, 보통, 어려움, ...
--      01 스테이지(stage)      : 스테이지 번호
-------------------------------------
function ServerData_DimensionGate:makeDimensionGateID(mode, chapter, difficulty, stage)
    return (GAME_MODE_DIMENSION_GATE * 100000) + (mode * 10000) + (chapter * 1000) + (difficulty * 100) + stage
end

-------------------------------------
-- function parseDimensionGateID
-- 3011001
-- 30xxxxx 던전(dungeon)        : 차원문, ...
--   1xxxx 모드(mode)           : 마누스의 차원문, ...
--    1xxx 챕터(chapter)        : 상위층, 하위층, ...
--     1xx 난이도(difficulty)   : 쉬움, 보통, 어려움, ...
--      01 스테이지(stage)      : 스테이지 번호
-------------------------------------
function ServerData_DimensionGate:parseDimensionGateID(stage_id)
    local mode_id = self:getModeID(stage_id)
    local chapter_id = self:getChapterID(stage_id)
    local difficulty_id = self:getDifficultyID(stage_id)
    local stage_id = self:getStageID(stage_id)

    return mode_id, chapter_id, difficulty_id, stage_id
end

-------------------------------------
-- function getDungeonID
-- 3011001
-- 30xxxxx 던전(dungeon)        : 차원문, ...
-------------------------------------
function ServerData_DimensionGate:getDungeonID(stage_id)
    return getDigit(stage_id, 100000, 2)
end

-------------------------------------
-- function getDungeonID
-- 3011001
--   1xxxx 모드(mode)           : 마누스의 차원문, ...
-------------------------------------
function ServerData_DimensionGate:getModeID(stage_id)
    return getDigit(stage_id, 10000, 1)
end


-------------------------------------
-- function getChapterID
-- 3011001
--    1xxx 챕터(chapter)        : 상위층, 하위층, ...
-------------------------------------
function ServerData_DimensionGate:getChapterID(stage_id)
    return getDigit(stage_id, 1000, 1)
end


-------------------------------------
-- function getDifficultyID
-- 3011001
--     1xx 난이도(difficulty)   : 쉬움, 보통, 어려움, ...
-------------------------------------
function ServerData_DimensionGate:getDifficultyID(stage_id)
    return getDigit(stage_id, 100, 1)
end


-------------------------------------
-- function getStageID
-- 3011001
--      01 스테이지(stage)      : 스테이지 번호
-------------------------------------
function ServerData_DimensionGate:getStageID(stage_id)
    return getDigit(stage_id, 1, 2)
end


function ServerData_DimensionGate:getPrevDifficultyID(stage_id)
    local diff_id = self:getDifficultyID(stage_id)

    if diff_id <= 1 then return nil end

    return self:makeDimensionGateID(self:getModeID(stage_id), self:getChapterID(stage_id),
                    diff_id - 1, self:getStageID(stage_id))
end



-------------------------------------
-- function MakeDimensionGateID
-- 30xxxxx 던전(dungeon)        : 차원문, ...
--   1xxxx 모드(mode)           : 마누스의 차원문, ...
--    1xxx 챕터(chapter)        : 상위층, 하위층, ...
--     1xx 난이도(difficulty)   : 쉬움, 보통, 어려움, ...
--      01 스테이지(stage)      : 스테이지 번호
-------------------------------------
function ServerData_DimensionGate:MakeDimensionGateID(mode_id, chapter_id, difficulty_id, stage_id)
    return GAME_MODE_DIMENSION_GATE * 100000
                + mode_id * 10000
                + chapter_id * 1000
                + difficulty_id * 100
                + stage_id
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// 
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////


-------------------------------------
-- function getBuffList
-------------------------------------
function ServerData_DimensionGate:getBuffList(mode_id)
    if not mode_id then return nil end

    local str = tostring(self.m_dmgateInfo[mode_id]['buff'])
    local buffList = plSplit(str, ';')   

    local blessTable = TABLE:get('dmgate_bless')
    local result = {}

    for _, value in pairs(buffList) do
        table.insert(result, blessTable[tonumber(value)])
    end

    return result
end



-------------------------------------
-- function getRewardStatus
-------------------------------------
function ServerData_DimensionGate:getRewardStatus(stage_id)
    local status = self:getStageStatus(stage_id)
    if status == -1 then status = 0 end

    return status
end

function ServerData_DimensionGate:getStageDesc(stage_id)
    return g_stageData:getStageDesc(stage_id)
end


function ServerData_DimensionGate:getStageName(stage_id)
    if not stage_id then error('Forgot to pass mode_id as param') end

    local mode_id = self:getModeID(stage_id)
    local stage_key = self.m_stageTableKeys[mode_id][stage_id]

    if (not stage_key) then 
        error('This stage_id is not included in table_dmgate_stage.')
    end

    local stage_table = self.m_stageTable[mode_id][stage_key]
    return stage_table['t_name']
end

function ServerData_DimensionGate:getStageDiffTextColor(stage_id)
    local diff_level = self:getDifficultyID(stage_id)

    if (diff_level == 1) then
        return COLOR['diff_normal']
    elseif (diff_level == 2) then
        return COLOR['diff_hard']
    elseif (diff_level == 3) then
        return COLOR['diff_hell']
    else
        return COLOR['white']
    end
end

function ServerData_DimensionGate:getStageDiffText(stage_id)
    local diff_level = self:getDifficultyID(stage_id)

    if (diff_level == 1) then
        return '보통'
    elseif (diff_level == 2) then
        return '어려움'
    elseif (diff_level == 3) then
        return '지옥'
    else
        return ''
    end
end