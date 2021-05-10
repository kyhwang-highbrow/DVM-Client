
local DmgateStringTable = {
        ['chapter'] = {'하층', '상층'},
        ['difficulty'] = {[0] = '', '보통', '어려움', '지옥'},
        ['diff_color'] = {[0] = 'white', 'diff_normal', 'diff_hard', 'diff_hell'},
}

----------------------------------------------------------------------------
-- class ServerData_Dmgate
----------------------------------------------------------------------------
ServerData_Dmgate = class({
    m_serverData = 'ServerData',                -- ServerData.lua

    m_bIsNewSeason = 'boolean', -- 시즌 초기화 팝업 boolean
    m_bNewChapterPopup = 'boolean', -- 상층 개방시 팝업 boolean

    -- TEMP
    m_bRevealBanner = 'boolean',    -- 차원문 출시용 배너 to set visible()

    m_stageTableName = 'string',    -- 테스트를 위해 로컬로 csv 파일을 읽을 때 사용하는 변수. 

    -- stage
    m_dmgateInfo = 'table',                     -- request_dmgateInfo() from server
    m_bDirtyDimensionGateInfo = 'boolean',      -- lobby 진입 후 최초 request_dmgateInfo() 이 후에 로비 진입시 마다 반복되는 것을 방지

    m_stageTable = 'table',                     -- request_stageTable() from table_dmgate_stage.csv
    m_stageTableKeys = 'List[stage_id]',        -- [stage_id] = index of m_stageTable[mode_id][chapter_id][stage_id]

    m_seasonEndTime = 'timestamp',              -- dmgateInfo를 통해 서버에서 받아오는 end_time

    -- shop
    m_shopInfo = 'table',                       -- request_shopInfo() from server
    m_bDirtyDimensionGateShopInfo = 'boolean',  -- 반복 방지용이나 현재 사용 x
    m_shopProductCounts = 'List[product_id]',   -- 상품별 구매 제한 횟수

    
    m_unlockStageList = 'List[stage_id]',       -- 스테이지 클리어후 스테이지 언락 VRP를 보여주기 위함

    m_testSeasonBuffList = 'List[sid]';         -- 평소엔 비워두고 시즌효과 테스트 할 때만 세팅한다.
})

----------------------------------------------------------------------------
-- function init
----------------------------------------------------------------------------
function ServerData_Dmgate:init(server_data)
    self.m_bRevealBanner = true
    self.m_bNewChapterPopup = false
    self.m_bIsNewSeason = false
    self.m_stageTableName = 'table_dmgate_stage' -- csv from server

    self.m_serverData = server_data
    self.m_bDirtyDimensionGateInfo = true
    self.m_bDirtyDimensionGateShopInfo = true

    -- SHOP
    self.m_shopInfo = {}
    self.m_shopProductCounts = {}

    self.m_unlockStageList = {}
end


----------------------------------------------------------------------------
-- function isShowLobbyBanner
----------------------------------------------------------------------------
function ServerData_Dmgate:isShowLobbyBanner()
    return self.m_bRevealBanner
end

-- ******************************************************************************************************
-- ** request and response functions from server and csv file
-- ******************************************************************************************************

----------------------------------------------------------------------------
-- function request_dmgateInfo
----------------------------------------------------------------------------
function ServerData_Dmgate:request_dmgateInfo(success_cb, fail_cb)
    local user_id = g_userData:get('uid')

    -- 처음 불린 이후에 false
    if (not self.m_bDirtyDimensionGateInfo) then
        if success_cb then success_cb() end
        return
    end

    -- callback for success
    local function callback_for_success(ret)
        if ret ~= nil then 
            self:response_dmgateInfo(ret)

            if(success_cb) then success_cb(ret) end
        end
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
function ServerData_Dmgate:response_dmgateInfo(ret)
    local dmgate_info = ret['dmgate_info']

    -- dmgate 입장 조건이 안되는 경우
    if dmgate_info == nil then return end


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
        local next_stage_id = self:getNextStageID(stage_id)
        
        if next_stage_id ~= nil then
            local prev_reward_status = self.m_dmgateInfo[mode_id]['stage'][tostring(next_stage_id)]
            local curr_reward_status = dmgate_info[mode_id]['stage'][tostring(next_stage_id)]
            if prev_reward_status == nil  and prev_reward_status ~= curr_reward_status then
                self.m_unlockStageList[next_stage_id] = true

                local curr_chapter_id = self:getChapterID(stage_id)
                local next_chapter_id = self:getChapterID(next_stage_id)
                
                -- 앙그라 하층에서 처음 상층 클리어 했을 때
                if (curr_chapter_id == 1) and (curr_chapter_id ~= next_chapter_id) then
                    -- TODO : 앙그라 이후 차원문이 나올 시 여러 차원문에 동시에 진입 가능하게 바뀌면 문제가 됨.
                    self.m_bNewChapterPopup = true
                end
            end
        end
    end

    self.m_dmgateInfo = dmgate_info

    if ret['end_time'] then self.m_seasonEndTime = ret['end_time'] end

    self.m_bDirtyDimensionGateInfo = false


    local local_data = self:getLocalData('season')
    
    if (local_data ~= self.m_dmgateInfo[1]['season']) then
        self:setLocalData(self.m_dmgateInfo[1]['season'], 'season')
        self.m_bIsNewSeason = true
    end
end

----------------------------------------------------------------------------
-- function request_reward
-- @brief 차원문 보상 수령 서버에 요청
-- UI_DmgateStageItem:click_rewardBtn()
----------------------------------------------------------------------------
function ServerData_Dmgate:request_reward(stage_id, success_cb, fail_cb)
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


----------------------------------------------------------------------------
-- function request_stageTable
-- @brief table_dmgate_stage.csv 를 서버에서 가져와 stage_id 기준으로 sort된 리스트와 
-- stage_id를 키값으로 가지는 리스트를 생성한다.
----------------------------------------------------------------------------
function ServerData_Dmgate:request_stageTable()
    -- key 값을 별도로 가지고 있을 경우 sort가 작동하지 않기 때문에 변환
    local dimensionGate_list = table.MapToList(TABLE:get(self.m_stageTableName))
    
    -- sort by elss-than operation
    local function sort_func(a, b) return a['stage_id'] < b['stage_id'] end
    table.sort(dimensionGate_list, sort_func)

    local mode_id
    local chapter_id
    local stage_id
    self.m_stageTable = {}
    self.m_stageTableKeys = {}
    for key, data in pairs(dimensionGate_list) do
        -- 모드 id (앙그라, 마누스, ..)에 따라 stage 정보 분류
        stage_id = data['stage_id'] -- number
        mode_id = self:getModeID(stage_id) -- number

        if(self.m_stageTable[mode_id] == nil) then 
            self.m_stageTable[mode_id] = {}
        end

        chapter_id = self:getChapterID(stage_id)

        if(self.m_stageTable[mode_id][chapter_id] == nil) then
            self.m_stageTable[mode_id][chapter_id] = {}
        end

        table.insert(self.m_stageTable[mode_id][chapter_id], data)
        self.m_stageTableKeys[stage_id] = #self.m_stageTable[mode_id][chapter_id]

        -- table.insert(self.m_stageTable[mode_id], data)
        -- -- stage_id 로 검색하기 위해 index 키값을 따로 저장
        -- self.m_stageTableKeys[mode_id][stage_id] = #self.m_stageTable[mode_id]
    end    
end


----------------------------------------------------------------------------
-- function request_shopInfo
----------------------------------------------------------------------------
function ServerData_Dmgate:request_shopInfo(success_cb, fail_cb)
    local uid = g_userData:get('uid')

     -- 처음 불린 이후에 false
    if (not self.m_bDirtyDimensionGateShopInfo) then
        if success_cb then
            success_cb()
        end

        return
    end

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


----------------------------------------------------------------------------
-- function response_shopInfo
----------------------------------------------------------------------------
function ServerData_Dmgate:response_shopInfo(ret)

    if ret['table_shop_dmgate'] then
        self.m_shopInfo = ret['table_shop_dmgate']
    end

    if ret['buycnt'] then 
        self.m_shopProductCounts = ret['buycnt']
    end

    --self.m_bDirtyDimensionGateShopInfo = false
end

-------------------------------------
-- function request_buy
-------------------------------------
function ServerData_Dmgate:request_buy(struct_product, count, cb_func, fail_cb)
    local uid = g_userData:get('uid')
    local product_id = struct_product['product_id']

    local function success_cb(ret)
        -- 재화 갱신
        g_serverData:networkCommonRespone(ret)

        -- 아이템 수령
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 상품 정보 갱신
        self:response_shopInfo(ret)

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
function ServerData_Dmgate:isStageDimensionGate(stage_id)
    if stage_id == nil then return false end
    
    local dungeon_id = self:getDungeonID(stage_id) -- GAME_MODE_DIMENSION_GATE = 30

    if dungeon_id ~= GAME_MODE_DIMENSION_GATE then return false end

    if (not self:isStageInTable(stage_id)) then return false end 

    return true
end


----------------------------------------------------------------------------
-- function isStageInTable
-- @brief 
----------------------------------------------------------------------------
function ServerData_Dmgate:isStageInTable(stage_id)
    local mode_id = self:getModeID(stage_id)
    if mode_id == nil then return false end

    local chapter_id = self:getChapterID(stage_id)
    if chapter_id == nil then return false end
    
    local key = self.m_stageTableKeys[stage_id]
    if key == nil then return false end
    
    return self.m_stageTable[mode_id][chapter_id][key] ~= nil
end

----------------------------------------------------------------------------
-- function getPrevStageID
-- @brief 
----------------------------------------------------------------------------
function ServerData_Dmgate:getPrevStageID(stage_id)
    local mode_id = self:getModeID(stage_id)
    local chapter_id = self:getChapterID(stage_id)
    local curr_stage_key = self.m_stageTableKeys[stage_id]
    
    if (not curr_stage_key) then 
        error('This stage_id is not included in table_dmgate_stage.')
    end
    
    local prev_stage_data = self.m_stageTable[mode_id][chapter_id][curr_stage_key - 1]

    if prev_stage_data == nil then 
        if self.m_stageTable[mode_id][chapter_id - 1] then
            local index = #self.m_stageTable[mode_id][chapter_id - 1]
            prev_stage_data = self.m_stageTable[mode_id][chapter_id - 1][index]
        end
    end

    if prev_stage_data == nil then return nil end

    return prev_stage_data['stage_id']
end
----------------------------------------------------------------------------
-- function getNextStageID
-- @brief 
----------------------------------------------------------------------------
function ServerData_Dmgate:getNextStageID(stage_id)
    local mode_id = self:getModeID(stage_id)
    local chapter_id = self:getChapterID(stage_id)
    local curr_stage_key = self.m_stageTableKeys[stage_id]

    if (not curr_stage_key) then 
        error('This stage_id is not included in table_dmgate_stage.')
    end
    
    local next_stage_data = self.m_stageTable[mode_id][chapter_id][curr_stage_key + 1]

    if next_stage_data == nil then 
        if self.m_stageTable[mode_id][chapter_id + 1] then
            next_stage_data = self.m_stageTable[mode_id][chapter_id + 1][1]
        end
    end

    if next_stage_data == nil then return nil end

    return next_stage_data['stage_id']
end

----------------------------------------------------------------------------
-- function getStageListByChapter
-- param mode_id     = number
-- param chapter_id  = number
-- return List[table]
----------------------------------------------------------------------------
function ServerData_Dmgate:getStageListByChapterId(mode_id, chapter_id)
   local mode_table = self.m_stageTable[mode_id]
   if (mode_table == nil) then error('there is not any mode with this mode_id ' .. tostring(mode_id)) end
   local chapter_table = mode_table[chapter_id]
   if (chapter_table == nil) then error('there is not any chapter with this chapter_id ' .. tostring(chapter_id)) end
   local result = {}

   for _, data in pairs(chapter_table) do
        local stage_id = data['stage_id']
        local result_index = self:getStageID(stage_id)

        if (result[result_index] == nil) then result[result_index] = {} end

        table.insert(result[result_index], data)
   end

   return result
end

----------------------------------------------------------------------------
-- function getStageInfoList
----------------------------------------------------------------------------
function ServerData_Dmgate:getDmgateId(mode_id)
    if not mode_id then error('Forgot to pass mode_id as param') end

    return self.m_dmgateInfo[mode_id]['dm_id']
end

----------------------------------------------------------------------------
-- function getStageInfoList
----------------------------------------------------------------------------
function ServerData_Dmgate:getStageInfoList(mode_id)
    if not mode_id then error('Forgot to pass mode_id as param') end

    if self.m_dmgateInfo[mode_id] == nil then return {} end

    return self.m_dmgateInfo[mode_id]['stage']
end

----------------------------------------------------------------------------
-- function getClearedMaxStageInList
----------------------------------------------------------------------------
function ServerData_Dmgate:getClearedMaxStageInList(mode_id)
    if not mode_id then error('Forgot to pass mode_id as param') end

    local max_stage_id = 0
    local stage_id
    local list = self:getStageInfoList(mode_id)

    if (not #list) then 
        error('There isn\'t stageInfo with this mode_id : ' .. tostring(mode_id))
    end

    for key, stage_status in pairs(list) do
        stage_id = tonumber(key)
        if (stage_id > max_stage_id) then
            if self:checkStageTime(stage_id) then
                max_stage_id = stage_id
            end
        end
    end

    if (max_stage_id == 0) then 
        if IS_DEV_SERVER() then
            error('There isn\'t any opened stage with this mode_id : ' .. tostring(mode_id))
        end
        return nil
    end

    return max_stage_id
end

----------------------------------------------------------------------------
-- function checkStageTime
----------------------------------------------------------------------------
function ServerData_Dmgate:checkStageTime(stage_id)
    if not stage_id then error('Forgot to pass stage_id as param') end

    local mode_id = self:getModeID(stage_id)
    local chapter_id = self:getChapterID(stage_id)
    local stage_key = self.m_stageTableKeys[stage_id]

    if (not stage_key) then 
        error('This stage_id is not included in table_dmgate_stage.')
    end

    local stage_table = self.m_stageTable[mode_id][chapter_id][stage_key]
    local start_date = tostring(stage_table['start_date'])
    local end_date = tostring(stage_table['end_date'])

    if (#pl.stringx.split(start_date, ' ') == 1) then
        start_date = start_date .. ' 0000'
    end
    if (#pl.stringx.split(end_date, ' ') == 1) then
        end_date = end_date .. ' 0000'
    end

    local date_format = 'yyyymmdd HHMM'
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
                --error('parse_start_date[\'time\'] is nil')
            else
                start_time = parse_start_date['time'] + offset -- <- 문자열로 된 날짜를 timestamp로 변환할 때 서버 타임존의 숫자로 보정
            end
        end
    end

    if (end_date ~= '' or end_date) then
        local parse_end_date = parser:parse(end_date)
        if(parse_end_date) then
            if (parse_end_date['time'] == nil) then
                --error('parse_end_date[\'time\'] is nil')
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
function ServerData_Dmgate:getStageStatus(stage_id)
    if not stage_id then error('Forgot to pass stage_id as param') end

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
function ServerData_Dmgate:isStageOpened(stage_id)
    if not stage_id then error('Forgot to pass stage_id as param') end

    return self:getStageStatus(stage_id) >= 0
end

----------------------------------------------------------------------------
-- function isStageCleared
-- nil : not opened
-- 0 : opened but not cleared
-- 1 : cleared but not received reward yet
-- 2 : received reward
----------------------------------------------------------------------------
function ServerData_Dmgate:isStageCleared(stage_id)
    if not stage_id then error('Forgot to pass stage_id as param') end

    return self:getStageStatus(stage_id) > 0
end

----------------------------------------------------------------------------
-- function isStageEverCleared
-- 한번이라도 클리어 한 적이 있는지
----------------------------------------------------------------------------
function ServerData_Dmgate:isStageEverCleared(stage_id)
    if not stage_id then error('Forgot to pass stage_id as param') end

    local mode_id = self:getModeID(stage_id)

     return self.m_dmgateInfo[mode_id]['clear'][tostring(stage_id)] ~= nil
end

----------------------------------------------------------------------------
-- function isChapterCleared
----------------------------------------------------------------------------
function ServerData_Dmgate:isChapterCleared(mode_id, chapter_id)
    if not mode_id then error('Forgot to pass mode_id as param') end
    if not chapter_id then error('Forgot to pass chapter_id as param') end

    local stage_id
    local stage_status
    local result = true
    for key, stage_data in pairs(self.m_stageTable[mode_id][chapter_id]) do
        stage_id = stage_data['stage_id']
        stage_status = self:getStageStatus(stage_id)

        if stage_status <= 0 then 
            result = false
            break
        end
    end

    return result
end 

----------------------------------------------------------------------------
-- function isStageRewarded
-- @todo : need to change the name of function
-- nil : not opened
-- 0 : opened but not cleared
-- 1 : cleared but not received reward yet
-- 2 : received reward
----------------------------------------------------------------------------
function ServerData_Dmgate:hasStageReward(stage_id)
    if not stage_id then error('Forgot to pass stage_id as param') end

    return self:getStageStatus(stage_id) == 1
end

----------------------------------------------------------------------------
-- function isStageRewarded
-- nil : not opened
-- 0 : opened but not cleared
-- 1 : cleared but not received reward yet
-- 2 : received reward
----------------------------------------------------------------------------
function ServerData_Dmgate:isStageRewarded(stage_id)
    if not stage_id then error('Forgot to pass stage_id as param') end

    return self:getStageStatus(stage_id) >= 2
end

----------------------------------------------------------------------------
-- function getCurrDiffInList
----------------------------------------------------------------------------
function ServerData_Dmgate:getCurrDiffInList(list)
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

----------------------------------------------------------------------------
-- function getShopInfoProductList
-- @brief 
----------------------------------------------------------------------------
function ServerData_Dmgate:getShopInfoProductList()
    local result = {}
    for i, v in pairs(self.m_shopInfo) do
        struct_product = StructProduct(v)
        table.insert(result, struct_product)
    end

    return result
end


----------------------------------------------------------------------------
-- function getProductCount
-- @brief 
----------------------------------------------------------------------------
function ServerData_Dmgate:getProductCount(product_id)
    return self.m_shopProductCounts[tostring(product_id)] or 0
end



-- ******************************************************************************************************
-- ** 
-- ******************************************************************************************************

----------------------------------------------------------------------------
-- function makeDimensionGateID
-- 3011001
-- 30xxxxx 던전(dungeon)        : 차원문, ...
--   1xxxx 모드(mode)           : 마누스의 차원문, ...
--    1xxx 챕터(chapter)        : 상위층, 하위층, ...
--     1xx 난이도(difficulty)   : 쉬움, 보통, 어려움, ...
--      01 스테이지(stage)      : 스테이지 번호
----------------------------------------------------------------------------
function ServerData_Dmgate:makeDimensionGateID(mode, chapter, difficulty, stage)
    return (GAME_MODE_DIMENSION_GATE * 100000) + (mode * 10000) + (chapter * 1000) + (difficulty * 100) + stage
end

----------------------------------------------------------------------------
-- function parseDimensionGateID
-- 3011001
-- 30xxxxx 던전(dungeon)        : 차원문, ...
--   1xxxx 모드(mode)           : 마누스의 차원문, ...
--    1xxx 챕터(chapter)        : 상위층, 하위층, ...
--     1xx 난이도(difficulty)   : 쉬움, 보통, 어려움, ...
--      01 스테이지(stage)      : 스테이지 번호
----------------------------------------------------------------------------
function ServerData_Dmgate:parseDimensionGateID(stage_id)
    stage_id = tonumber(stage_id)
    local mode_id = self:getModeID(stage_id)
    local chapter_id = self:getChapterID(stage_id)
    local difficulty_id = self:getDifficultyID(stage_id)
    local stage_id = self:getStageID(stage_id)

    return mode_id, chapter_id, difficulty_id, stage_id
end

----------------------------------------------------------------------------
-- function getDungeonID
-- 3011001
-- 30xxxxx 던전(dungeon)        : 차원문, ...
----------------------------------------------------------------------------
function ServerData_Dmgate:getDungeonID(stage_id)
    stage_id = tonumber(stage_id)
    return getDigit(stage_id, 100000, 2)
end

----------------------------------------------------------------------------
-- function getDungeonID
-- 3011001
--   1xxxx 모드(mode)           : 마누스의 차원문, ...
----------------------------------------------------------------------------
function ServerData_Dmgate:getModeID(stage_id)
    stage_id = tonumber(stage_id)
    return getDigit(stage_id, 10000, 1)
end


----------------------------------------------------------------------------
-- function getChapterID
-- 3011001
--    1xxx 챕터(chapter)        : 상위층, 하위층, ...
----------------------------------------------------------------------------
function ServerData_Dmgate:getChapterID(stage_id)
    stage_id = tonumber(stage_id)
    return getDigit(stage_id, 1000, 1)
end


----------------------------------------------------------------------------
-- function getDifficultyID
-- 3011001
--     1xx 난이도(difficulty)   : 쉬움, 보통, 어려움, ...
----------------------------------------------------------------------------
function ServerData_Dmgate:getDifficultyID(stage_id)
    stage_id = tonumber(stage_id)
    return getDigit(stage_id, 100, 1)
end


----------------------------------------------------------------------------
-- function getStageID
-- 3011001
--      01 스테이지(stage)      : 스테이지 번호
----------------------------------------------------------------------------
function ServerData_Dmgate:getStageID(stage_id)
    stage_id = tonumber(stage_id)
    return getDigit(stage_id, 1, 2)
end




----------------------------------------------------------------------------
-- function MakeDimensionGateID
-- 30xxxxx 던전(dungeon)        : 차원문, ...
--   1xxxx 모드(mode)           : 마누스의 차원문, ...
--    1xxx 챕터(chapter)        : 상위층, 하위층, ...
--     1xx 난이도(difficulty)   : 쉬움, 보통, 어려움, ...
--      01 스테이지(stage)      : 스테이지 번호
----------------------------------------------------------------------------
function ServerData_Dmgate:MakeDimensionGateID(mode_id, chapter_id, difficulty_id, stage_id)
    return GAME_MODE_DIMENSION_GATE * 100000
                + mode_id * 10000
                + chapter_id * 1000
                + difficulty_id * 100
                + stage_id
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// 
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------------
-- function checkInUnlockList
-- @brief 오직 UI_DmgateStageItem의 Unlock VRP 를 위한 function으로 체크 후 
-- 해당 데이터를 삭제하므로 이 외의 목적으로 사용 X
----------------------------------------------------------------------------
function ServerData_Dmgate:checkInUnlockList(stage_id)
    if self.m_unlockStageList[tonumber(stage_id)] ~= nil then
        self.m_unlockStageList[tonumber(stage_id)] = nil
        return true
    end

    return false
end

----------------------------------------------------------------------------
-- function getBuffList
----------------------------------------------------------------------------
function ServerData_Dmgate:getBuffList(mode_id)
    if not mode_id then return nil end
    
    local result = {}
    local buff_str
    local debuff_str

    -- 테스트 기능을 위한 분기처리
    -- 설정된 테스트 데이터가 있으면 그것으로 설정
    if not isNullOrEmpty(self.m_testSeasonBuffList) and IS_TEST_MODE() then 
        buff_str = self.m_testSeasonBuffList
        debuff_str = ''
    else
        buff_str = tostring(self.m_dmgateInfo[mode_id]['buff'])
        debuff_str = tostring(self.m_dmgateInfo[mode_id]['debuff'])
    end

    local buff_list = plSplit(buff_str, ';')   
    local debuff_list = plSplit(debuff_str, ';')   
    
    local data
    for _, skill_id in pairs(buff_list) do
        if (not skill_id) or (skill_id == '') then
            --vars['skillInfoLabel']:setString(Str('스킬이 지정되지 않았습니다.'))
        else
            local t_skill = clone(GetSkillTable('dragon'):get(tonumber(skill_id)))

            if t_skill then
                DragonSkillCore.substituteSkillDesc(t_skill)
                DragonSkillCore.getSkillDescPure(t_skill)

                local val_1 = (t_skill['desc_1'])
                local val_2 = (t_skill['desc_2'])
                local val_3 = (t_skill['desc_3'])
                local val_4 = (t_skill['desc_4'])
                local val_5 = (t_skill['desc_5'])
                
                t_skill['t_desc'] = Str(t_skill['t_desc'], val_1, val_2, val_3, val_4, val_5)
                
                t_skill['color'] = cc.c4b(0, 248, 15, 255)
                table.insert(result, t_skill)
            end
        end
    end

    for _, skill_id in pairs(debuff_list) do
        if (not skill_id) or (skill_id == '') then
            --vars['skillInfoLabel']:setString(Str('스킬이 지정되지 않았습니다.'))
        else
            local t_skill = clone(GetSkillTable('dragon'):get(tonumber(skill_id)))

            if t_skill then
                DragonSkillCore.substituteSkillDesc(t_skill)
                DragonSkillCore.getSkillDescPure(t_skill)
                local val_1 = (t_skill['desc_1'])
                local val_2 = (t_skill['desc_2'])
                local val_3 = (t_skill['desc_3'])
                local val_4 = (t_skill['desc_4'])
                local val_5 = (t_skill['desc_5'])
                
                t_skill['t_desc'] = Str(t_skill['t_desc'], val_1, val_2, val_3, val_4, val_5)
                
                t_skill['color'] = cc.c4b(255, 0, 0, 255)
                table.insert(result, t_skill)
            end
        end
    end

    return result
end

----------------------------------------------------------------------------
-- function getStageName
----------------------------------------------------------------------------
function ServerData_Dmgate:getStageName(stage_id)
    if not stage_id then error('Forgot to pass mode_id as param') end

    local mode_id = self:getModeID(stage_id)
    local chapter_id = self:getChapterID(stage_id)
    local stage_key = self.m_stageTableKeys[stage_id]

    if (not stage_key) then 
        error('This stage_id is not included in table_dmgate_stage.')
    end

    local stage_table = self.m_stageTable[mode_id][chapter_id][stage_key]
    return Str(stage_table['t_name'])
end

----------------------------------------------------------------------------
-- function getStageDesc
----------------------------------------------------------------------------
function ServerData_Dmgate:getStageDesc(stage_id)
    return g_stageData:getStageDesc(stage_id)
end

----------------------------------------------------------------------------
-- function getStageChapterText
----------------------------------------------------------------------------
function ServerData_Dmgate:getStageChapterText(stage_id)
    local chapter_id = self:getChapterID(stage_id)
    
    return Str(DmgateStringTable['chapter'][chapter_id])
end

----------------------------------------------------------------------------
-- function getStageDiffText
----------------------------------------------------------------------------
function ServerData_Dmgate:getStageDiffText(stage_id)
    local diff_level = self:getDifficultyID(stage_id)

    return Str(DmgateStringTable['difficulty'][diff_level])
end

----------------------------------------------------------------------------
-- function getStageDiffTextColor
----------------------------------------------------------------------------
function ServerData_Dmgate:getStageDiffTextColor(stage_id)
    local diff_level = self:getDifficultyID(stage_id)
    
    return COLOR[DmgateStringTable['diff_color'][diff_level]]
end

----------------------------------------------------------------------------
-- function getStageDiffColorStr
----------------------------------------------------------------------------
function ServerData_Dmgate:getStageDiffColorStr(stage_id)
    local diff_level = self:getDifficultyID(stage_id)
    
    return DmgateStringTable['diff_color'][diff_level]
end

----------------------------------------------------------------------------
-- function getTimeStatus
----------------------------------------------------------------------------
function ServerData_Dmgate:getTimeStatus()
    local end_time = (self.m_seasonEndTime / 1000)
    
    local curr_time = Timer:getServerTime()
    local is_season_ended = false

    if (curr_time > end_time) then
        is_season_ended = true
    end

    return is_season_ended
end

----------------------------------------------------------------------------
-- function getTimeStatusText
----------------------------------------------------------------------------
function ServerData_Dmgate:getTimeStatusText(mode_id, chapter_id)
    if not mode_id then error('Forgot to pass mode_id as param') end
    if not chapter_id then error('Forgot to pass chapter_id as param') end

    local first_stage_data = self.m_stageTable[mode_id][chapter_id][1]

    local start_date = tostring(first_stage_data['start_date'])
    if (#pl.stringx.split(start_date, ' ') == 1) then
        start_date = start_date .. ' 0000'
    end
    
    local end_time = (self.m_seasonEndTime / 1000)
    
    local date_format = 'yyyymmdd HHMM'
    local parser = pl.Date.Format(date_format)
    -- 단말기(local)의 타임존 (단위 : 초)
    local timezone_local = datetime.getTimeZoneOffset()

    -- 서버(server)의 타임존 (단위 : 초)
    local timezone_server = Timer:getServerTimeZoneOffset()
    local offset = (timezone_local - timezone_server)

    local start_time
    local parse_start_date
    if (start_date ~= '' or start_date) then
        parse_start_date = parser:parse(start_date)
        
        if(parse_start_date) then
            if (parse_start_date['time'] == nil) then
                --start_time = nil
                error('parse_start_date[\'time\'] is nil')
            else
                start_time = parse_start_date['time'] + offset -- <- 문자열로 된 날짜를 timestamp로 변환할 때 서버 타임존의 숫자로 보정
            end
        end
    end

    local curr_time = Timer:getServerTime()
    local is_season_ended = false


    local str = ''
    if (curr_time < start_time) then
        local time = (start_time - curr_time)
        str = Str('{1} 후 열림', datetime.makeTimeDesc(time, true))
    elseif (start_time <= curr_time) and (curr_time <= end_time) then
        local time = (end_time - curr_time)
        str = Str('{1} 남음', datetime.makeTimeDesc(time, true))
    else
        is_season_ended = true
        str = Str('시즌이 종료되었습니다.')
    end

    return str, is_season_ended
end

----------------------------------------------------------------------------
-- function MakeSeasonEndedPopup
----------------------------------------------------------------------------
function ServerData_Dmgate:MakeSeasonEndedPopup()
    local msg = '시즌이 종료되었습니다.'

    local function ok_callback()
        UINavigator:goTo('lobby')
    end

    MakeSimplePopup(POPUP_TYPE.OK, msg, ok_callback)
end

----------------------------------------------------------------------------
-- function getLocalData
----------------------------------------------------------------------------
function ServerData_Dmgate:getLocalData(...)
    return g_settingData:get('dmgate', ...)
end

----------------------------------------------------------------------------
-- function setLocalData
----------------------------------------------------------------------------
function ServerData_Dmgate:setLocalData(data, ...)
    g_settingData:applySettingData(data, 'dmgate', ...)
end

----------------------------------------------------------------------------
-- function MakeSeasonResetPopup
----------------------------------------------------------------------------
function ServerData_Dmgate:MakeSeasonResetPopup(mode_id, is_season_reset)
    local id = mode_id or DIMENSION_GATE_ANGRA

    local isBuffExist = #self:getBuffList(id) ~= 0

    if is_season_reset and self.m_bIsNewSeason and isBuffExist then
    --if is_season_reset and isBuffExist then
        
        UI_DmgateSeasonResetPopup(id, is_season_reset)
        self.m_bIsNewSeason = false
    elseif (not is_season_reset) and self.m_bNewChapterPopup and isBuffExist then
        UI_DmgateSeasonResetPopup(id, is_season_reset)
        self.m_bNewChapterPopup = false
    --else
    end
end

