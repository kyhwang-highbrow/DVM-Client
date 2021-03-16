

-------------------------------------
-- class ServerData_Trial
-------------------------------------
ServerData_Trial = class({
    m_serverData = 'ServerData',
    m_trialInfo = '',
    --m_dimensionGateInfo = '',
    m_trialTable = '',

    m_bDirtyTrialInfo = 'boolean'
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_Trial:init(server_data)
    self.m_serverData = server_data
    self.m_bDirtyTrialInfo = true

    
    self.m_trialInfo = {}
    self.m_trialTable = {}
end

-------------------------------------
-- function 
-------------------------------------
function ServerData_Trial:parseTrialID(stage_id)
    -- 1310101
    -- 13xxxxx 모드 구분 (시련 던전 모드)
    --   1xxxx 시련 던전 구분 (차원문, ...)
    --    01xx 세부 모드 (난이도)
    --      01 티어 - 스테이지 번호 (통상적으로 1~10)

    local id = {}
    id['stage_mode'] = getDigit(stage_id, 100000, 2)
    id['dungeon_mode'] = getDigit(stage_id, 10000, 1)
    id['detail_mode'] = getDigit(stage_id, 100, 2)
    id['tier'] = getDigit(stage_id, 1, 2)

    return id
end

function ServerData_Trial:request_trialInfo(cb_func, fail_cb)

    
    if(not self.m_bDirtyTrialInfo) then
        if cb_func then
            cb_func()
        end

        return nil
    end

    local uid = g_userData:get('uid')

    -- callback for success
    local function success_cb(ret)
        self:response_trialInfo(ret)

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

function ServerData_Trial:response_trialInfo(ret)
    self.m_trialInfo[TRIAL_DUNGEON_DIMENSION_GATE] = ret
    self.m_trialTable[TRIAL_DUNGEON_DIMENSION_GATE] = TABLE:get("table_dmgate_stage")
    
    self.m_bDirtyTrialInfo = false
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

function ServerData_Trial:getTrialInfoListByType(type)
    return self.m_trialInfo[type] 
end


-- function ServerData_Trial:getTrialTable()
--     return self.m_trialTable[TRIAL_DUNGEON_DIMENSION_GATE]
-- end


--function ServerData_Trial:getTrialList