
-------------------------------------
-- class ServerData_DimensionGate
-------------------------------------
ServerData_DimensionGate = class({
    m_serverData = 'ServerData',

    m_dimensionGateInfo = '',   -- request_dmgateInfo() from server

    m_dimensionGateTable = '',  -- request_dmgateTable() from table
    m_dimensionGateKey = '',

    m_shopInfo = '', -- request_shopInfo() from server
    m_shopProductCounts = '', 

    m_unlockStageList = '',

    m_bDirtyDimensionGateInfo = 'boolean'
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_DimensionGate:init(server_data)
    self.m_serverData = server_data
    self.m_bDirtyDimensionGateInfo = true

    
    self.m_dimensionGateInfo = {}
    self.m_dimensionGateTable = {}
    self.m_dimensionGateKey = {}

    -- SHOP
    self.m_shopInfo = {}
    self.m_shopProductCounts = {}

    self.m_unlockStageList = {}    
end

-------------------------------------
-- function request_dimensionGateInfo
-------------------------------------
function ServerData_DimensionGate:request_gameStart(stage_id, deck_name, combat_power, finish_cb, is_cash)
    local uid = g_userData:get('uid')
    local api_url = '/dmgate/start'


    -- callback funciton
    local function success_cb(ret)
    end

    local response_status_cb

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setParam('deck_name', deck_name)
    ui_network:setParam('token', token)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

function ServerData_DimensionGate:request_reward(stage_id, cb_func, fail_cb)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        self:response_dimensionGateInfo(ret)

        if cb_func then cb_func(ret) end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dmgate/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function request_dimensionGateInfo
-------------------------------------
function ServerData_DimensionGate:request_dimensionGateInfo(cb_func, fail_cb)

    if(not self.m_bDirtyDimensionGateInfo) then
        if cb_func then
            cb_func()
        end

        return nil
    end

    local uid = g_userData:get('uid')

    -- callback for success
    local function success_cb(ret)
        self:response_dimensionGateInfo(ret)

        if cb_func then cb_func(ret) end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dmgate/info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_dimensionGateInfo
-------------------------------------
function ServerData_DimensionGate:response_dimensionGateInfo(ret)
    local dmgate_info = ret['dmgate_info']
    
    if #self.m_dimensionGateInfo ~= 0  and ret['added_items'] == nil then
        local stage_id = ret['stage']
        local mode_id = self:getModeID(stage_id)
        if self.m_dimensionGateInfo[mode_id]['stage'][tostring(stage_id)]
        ~= dmgate_info[mode_id]['stage'][tostring(stage_id)] then

            local key = self.m_dimensionGateKey[mode_id][stage_id]
            local next_stage_id = self.m_dimensionGateTable[mode_id][key+1]['stage_id']
            
            if next_stage_id ~= nil then
                self.m_unlockStageList[next_stage_id] = {}
            end
            self.m_dimensionGateInfo = dmgate_info
            return
        end

    end

    self.m_dimensionGateInfo = dmgate_info
    
    -- TODO (YOUNGJIN) : 지금은 request 할 때마다 table을 가져오고 sorting 하지만
    -- 테이블에 한해서는 게임 시작시 한번만 하면 됨. 하지만 init에 넣으면 
    -- TABLE의 load 순서에 따라 비어 있을 수도 있기 때문에 일단 여기 넣음. 
    self:request_dmgateTable()

    self.m_bDirtyDimensionGateInfo = false
end

-------------------------------------
-- function request_dmgateTable
-------------------------------------
function ServerData_DimensionGate:request_dmgateTable()
    local temp = TABLE:get("table_dmgate_stage")
    local dimensionGate_list = table.MapToList(temp)
    
    local function sort_func(a, b) return a['stage_id'] < b['stage_id'] end
    table.sort(dimensionGate_list, sort_func)
    
    local key = {}
    for k, v in pairs(dimensionGate_list) do
        key[v['stage_id']] = k
    end
    
    self.m_dimensionGateTable[DIMENSION_GATE_MANUS] = dimensionGate_list
    self.m_dimensionGateKey[DIMENSION_GATE_MANUS] = key
    
end

-------------------------------------
-- function request_dmgateTable
-------------------------------------
function ServerData_DimensionGate:request_shopInfo(cb_func, fail_cb)

    -- if(not self.m_bDirtyDimensionGateInfo) then
    -- if cb_func then
    --     cb_func()
    -- end

    --     return nil
    -- end

    local uid = g_userData:get('uid')

    -- callback for success
    local function success_cb(ret)
        self:response_shopInfo(ret)
        
        if cb_func then cb_func(ret) end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dmgate/shop_info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)  -- 게임 종료 통신이 아니면 취소
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function request_dmgateTable
-------------------------------------
function ServerData_DimensionGate:response_shopInfo(ret)
    self.m_shopInfo[DIMENSION_GATE_MANUS] = ret['table_shop_dmgate']
    self.m_shopProductCounts[DIMENSION_GATE_MANUS] = ret['buycnt']
end

-------------------------------------
-- function getShopInfoProductList
-------------------------------------
function ServerData_DimensionGate:getShopInfoProductList(mode_id)
    return self.m_shopInfo[mode_id]

    -- local result = {}

    -- if(self.m_shopInfo[mode_id]) then
    --     for i, v in pairs(self.m_shopInfo[mode_id]) do
    --         local struct_item = StructProduct(v)
    --         struct_item['product_idx'] = tonumber(i)
    --         table.insert(result, struct_item)
    --     end
    -- end

    -- table.sort(result, function(a, b)
    --     local a_priority = a['product_idx'] or 99
    --     local b_priority = b['product_idx'] or 99
    --     return a_priority < b_priority
    -- end)
    -- ccdump(result)
    -- return result
end

function ServerData_DimensionGate:getProductCount(mode_id, product_id)
    return self.m_shopProductCounts[mode_id][tostring(product_id)]
end

-------------------------------------
-- function request_dmgateTable
-------------------------------------
function ServerData_DimensionGate:request_buy(product_id, count, cb_func, fail_cb)
    local uid = g_userData:get('uid')

    local function success_cb(ret)

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

-------------------------------------
-- function checkInUnlockList
-------------------------------------
function ServerData_DimensionGate:checkInUnlockList(stage_id)
    if self.m_unlockStageList[tonumber(stage_id)] ~= nil then
        self.m_unlockStageList[tonumber(stage_id)] = nil
        return true
    end

    return false
end


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


-------------------------------------
-- function getPrevStageID
-- 3011001
--      01 스테이지(stage)      : 스테이지 번호
-------------------------------------
function ServerData_DimensionGate:getPrevStageID(stage_id)
    if (getStageID(stage_id) <= 1) then
        return nil
    else
        return stage_id - 1
    end
end


function ServerData_DimensionGate:getPrevDifficultyID(stage_id)
    local diff_id = self:getDifficultyID(stage_id)

    if diff_id <= 1 then return nil end

    return self:makeDimensionGateID(self:getModeID(stage_id), self:getChapterID(stage_id),
                    diff_id - 1, self:getStageID(stage_id))
end

-- function ServerData_DimensionGate:getPrevStageID(stage_id)

-- end

function ServerData_DimensionGate:getNextStageID(stage_id)

    -- 모드
    local mode_id = self:getModeID(stage_id)
    -- 챕터
    local chapter_id = self:getChapterID(stage_id)
    -- 난이도
    local difficulty_id = self:getDifficultyID(stage_id)
    -- 스테이지
    local stage_id = self:getStageID(stage_id)

    -- id 조합
    local temp_id = self:MakeDimensionGateID(mode_id, chapter_id, difficulty_id, stage_id)



    -- while (self.m_dimensionGateInfo[mode_id][tostring(temp_id)] == nil) do -- chapter
    --     while() do -- difficulty
    --         while() do -- stage
    --             stage_id = stage_i + 1

    --         end

    --         difficulty_id = difficulty_id + 1
    --         stage_id = 1
    --     end

    --     chapter_id = chapter_id + 1
    --     difficulty_id = 1

    -- end
    -- 스테이지 + 1 

    -- 없으면 난이도 +1 스테이지 1부터.
    -- 난이도 없으면 챕터 +1 스테이지 1부터. 난이도는? 0부터? 1부터? 어라? 챕터애매.
    -- 챕터 없으면 Max 상태. 모드 바뀌는건 다른 모드 나왔을 때 생각.
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

function ServerData_DimensionGate:isStageDimensionGate(stage_id)
    local dungeon_id = self:getDungeonID(stage_id)
    if dungeon_id == GAME_MODE_DIMENSION_GATE then
        return true
    end

    return false
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// 
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

-------------------------------------
-- function getStageInfoList
-------------------------------------
function ServerData_DimensionGate:getStageInfoList(mode_type)
    if not mode_type then return nil end

    return self.m_dimensionGateInfo[mode_type]['stage']
end

-------------------------------------
-- function getStageStatus
-------------------------------------
function ServerData_DimensionGate:getStageStatus(mode_type, stage_id)
   
    return self.m_dimensionGateInfo[mode_type]['stage'][tostring(stage_id)] or -1
end

-------------------------------------
-- function isStageOpened
-------------------------------------
function ServerData_DimensionGate:isStageOpened(mode_type, stage_id)
    return self:getStageStatus(mode_type, stage_id) >= 0
end

-------------------------------------
-- function isStageCleared
-------------------------------------
function ServerData_DimensionGate:isStageCleared(mode_type, stage_id)
    return self:getStageStatus(mode_type, stage_id) > 0
end

-------------------------------------
-- function getRewardStatus
-------------------------------------
function ServerData_DimensionGate:getRewardStatus(stage_id)
    local mode_id = self:getModeID(stage_id)
    local status = self:getStageStatus(mode_id, stage_id)
    if status == -1 then status = 0 end

    return status
end

-- function ServerData_DimensionGate:isRewarded(stage_id)
--     local mode_id = self:getModeID(stage_id)
--     -- 0 : 클리어 x // 1 : 클리어 o, 보상 x // 2: 클리어 o, 보상 o
--     return self:getStageStatus(mode_id, stage_id) == 2
-- end

-------------------------------------
-- function getDifficultyStatus
-------------------------------------
function ServerData_DimensionGate:getDifficultyStatus(mode_type, stage_id)
    return self.m_dimensionGateInfo[mode_type]['stage'][tostring(stage_id)] or -1
end

-------------------------------------
-- function isDifficultyOpen
-------------------------------------
function ServerData_DimensionGate:isDifficultyOpen(mode_type, stage_id)

end

-------------------------------------
-- function getMaxDifficultyInList
-- @TODO : NEED TO CHANGE NAME
-------------------------------------
function ServerData_DimensionGate:getMaxDifficultyInList(mode_type, list)
    
    if #list == 0 or #list == nil then return 0 end

    local diffLevel

    for _, data in pairs(list) do
        local id = data['stage_id']
        if(id == nil) then error('received wrong list as param or stage_id is different with csv table') end

        diffLevel = self:getDifficultyID(id)

        if (not self:isStageCleared(mode_type, id)) then
            if diffLevel == 1 then 
                return diffLevel
            else 
                return diffLevel - 1
            end
        end
    end

    return diffLevel
end






--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// 
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////





function ServerData_DimensionGate:GetTempLowChapterList()
    local LOW_CHAPTER = 1
    local dmgate_table = self.m_dimensionGateTable[DIMENSION_GATE_MANUS]
    
    local list = {}

    for _, data in pairs(dmgate_table) do
        
        if self:getChapterID(data['stage_id']) == LOW_CHAPTER then
            table.insert(list, data)
        end
    end

    return list
end

function ServerData_DimensionGate:GetTempHighChapterList()
    local HIGH_CHAPTER = 2
    local dmgate_table = self.m_dimensionGateTable[DIMENSION_GATE_MANUS]
    local list = {}

    local diff_id
    local stage_id

    for _, data in pairs(dmgate_table) do
        
        if self:getChapterID(data['stage_id']) == HIGH_CHAPTER then

            diff_id = self:getDifficultyID(data['stage_id'])
            stage_id = self:getStageID(data['stage_id'])

            if(list[stage_id] == nil) then list[stage_id] = {} end
            --if(list[stage_id][diff_id] == nil) then list[stage_id][diff_id] = {} end
            table.insert(list[stage_id], data)
        end
    end

    return list
end





























--[[
    TODO (YOUNGJIN) : 
    THERE IS TWO CHOICES YOU NEED TO CHOOSE.
    YOU HAVE TO SEND THE LIST WHICH EXACTLY SHOWS THE NUMBER OF ITEM FOR UI.
    BUT IN CASE OF PORTAL, LOW TYPE ONLY HAVE 5 STAGES and HIGH TYPE HAVE 15 STAGES.
    MAKE CONCLUSION HOW TO DEAL WITH HIGH TYPES.
    
    -- 3011001
    -- 30xxxxx 던전(dungeon)        : 차원문, ...
    --   1xxxx 모드(mode)           : 마누스의 차원문, ...
    --    1xxx 챕터(chapter)        : 상위층, 하위층, ...
    --     1xx 난이도(difficulty)   : 쉬움, 보통, 어려움, ...
    --      01 스테이지(stage)      : 스테이지 번호
]]

-------------------------------------
-- function getDimensionGateInfoListByType
-------------------------------------
function ServerData_DimensionGate:getDimensionGateInfoListByType(type)
    local list = {}
    --self.m_dimensionGateInfo['dmgate_info']

    for key, data in pairs(self.m_dimensionGateTable[type]) do
        
    end
    -- self.m_dimensionGateInfo[type]
    -- self.m_dimensionGateTable[type]
end


-------------------------------------
-- function getDimensionGateInfoListByType
-------------------------------------
function ServerData_DimensionGate:getDimensionGateInfoList()
    
end




-- function ServerData_DimensionGate:getDimensionGateTable()
--     return self.m_dimensionGateTable[DIMENSION_GATE_MANUS]
-- end


function ServerData_DimensionGate:getDimensionGateList(mode_id, chapter_id)
    local table = self.m_dimensionGateTable[mode_id]
    local list = {}

    for _, v in pairs(table) do

    end
end











-------------------------------------
-- function getChapterNum
-- @param for example, DIMENSION_GATE_MANUS in ConstantGameMode.lua
-------------------------------------
function ServerData_DimensionGate:getMaxChapterNum(mode_id)
    -- local table = self.m_dimensionGateTable[mode_id]
    -- --self.m_dimensionGateKey[mode_id]
    -- local chapter_id
    -- local max = 0
    -- for key, data in pairs(table) do 
    --     chapter_id = getChapterID(data['stage_id'])
    --     if chapter_id > max then max = chapter_id end
    -- end

    -- return max
end

-------------------------------------
-- function getDifficultyNum
-- @param 
-------------------------------------
function ServerData_DimensionGate:getMaxDifficultyNum(mode_id, target_chapter_id)
    -- local table = self.m_dimensionGateTable[mode_id]
    -- local temp_chapter_id
    -- local diff_id
    -- local max = 0

    -- for key, data in pairs(table) do 
    --     temp_chapter_id = getChapterID(data['stage_id'])
    --     diff_id = getDifficultyID(data['stage_id'])

    --     if (temp_chapter_id == target_chapter_id) and (diff_id > max) then
    --         max = diff_id
    --     end
    -- end
end

-------------------------------------
-- function getStageNum
-- @param 
-------------------------------------
function ServerData_DimensionGate:getMaxStageNum(mode_id, chapter_id, diff_id)

end



-- function getDigit(id, base_digit, range)
--     local range = range or 1
--     local digit = math_floor((id % (base_digit * math_pow(10, range)))/base_digit)
--     return digit
-- end