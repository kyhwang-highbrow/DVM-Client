
-------------------------------------
-- class ServerData_DimensionGate
-------------------------------------
ServerData_DimensionGate = class({
    m_serverData = 'ServerData',
    m_dimensionGateInfo = '',
    --m_dimensionGateInfo = '',
    m_dimensionGateTable = '',
    m_dimensionGateKey = '',

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
end

-------------------------------------
-- function parseDimensionGateID
-- 3011001
-- 30xxxxx 던전 구분 (차원문, ...)
--   1xxxx 차원문 던전 세부 구분 (마누스의 차원문, ...)
--    1xxx 던전 세부 모드 (상위층/하위층)
--     1xx 난이도 (1, 2, 3)
--      01 스테이지 번호 (통상적으로 1~10)
-------------------------------------
function ServerData_DimensionGate:parseDimensionGateID(stage_id)
    local id = {}
    id['stage_mode'] = getDigit(stage_id, 100000, 2)
    id['dungeon_mode'] = getDigit(stage_id, 10000, 1)
    id['detail_mode'] = getDigit(stage_id, 1000, 1)
    id['difficulty'] = getDigit(stage_id, 100, 1)
    id['tier'] = getDigit(stage_id, 1, 2)

    return id
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
    self.m_dimensionGateInfo[DIMENSION_GATE_MANUS] = ret
    
    -- TODO (YOUNGJIN) : 지금은 request 할 때마다 table을 가져오고 sorting 하지만
    -- 테이블에 한해서는 게임 시작시 한번만 하면 됨. 하지만 init에 넣으면 
    -- TABLE의 load 순서에 따라 비어 있을 수도 있기 때문에 일단 여기 넣음. 
    self:request_dmgateTable()

    self.m_bDirtyDimensionGateInfo = false
end

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



--[[
    TODO (YOUNGJIN) : 
    THERE IS TWO CHOICES YOU NEED TO CHOOSE.
    YOU HAVE TO SEND THE LIST WHICH EXACTLY SHOWS THE NUMBER OF ITEM FOR UI.
    BUT IN CASE OF PORTAL, LOW TYPE ONLY HAVE 5 STAGES and HIGH TYPE HAVE 15 STAGES.
    MAKE CONCLUSION HOW TO DEAL WITH HIGH TYPES.
    
    -- 1310101
    -- 13xxxxx 모드 구분 (시련 던전 모드) 
    --   1xxxx 시련 던전 구분 (차원문, ...)
    --    01xx 세부 모드 (난이도)
    --      01 티어 - 스테이지 번호 (통상적으로 1~10)
]]

-------------------------------------
-- function getDimensionGateInfoListByType
-------------------------------------
function ServerData_DimensionGate:getDimensionGateInfoListByType(type)
    --return self.m_dimensionGateInfo[type] 
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


--function ServerData_DimensionGate:getDimensionGateList