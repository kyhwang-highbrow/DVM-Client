-------------------------------------
-- class ServerData_IndivPass
-------------------------------------
ServerData_IndivPass = class({
        m_serverData = 'ServerData',
        m_mPassData = 'Map<pass_id, Table>',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_IndivPass:init(server_data)
    self.m_serverData = server_data
    self.m_mPassData = {}
end


-------------------------------------
-- function isIndivPassEventOnGoing
-------------------------------------
function ServerData_IndivPass:isIndivPassEventOnGoing()
    local list = self:getEventRepresentProductList(true)
    return #list > 0
end

-------------------------------------
-- function getEventRepresentProductList
-- @brief 더미 대표 상품, 지금 패스 구조상 1개의 상품당 탭 1개로 처리해야 하는데
--        개인 패스는 한 탭에 상품 2개가 같이 노출되어야 함
-------------------------------------
function ServerData_IndivPass:getEventRepresentProductList(is_for_check)
    local list = {}
    local priority = 1

    for key, struct_indv_pass in pairs(self.m_mPassData) do
        if struct_indv_pass:isIndivPassValidTime() == true then
            struct_indv_pass.product_id = struct_indv_pass:getAdvancePassPid()
            struct_indv_pass.m_uiPriority = priority
            struct_indv_pass.package_res = 'battle_pass_3step.ui'
            struct_indv_pass.package_res_2 = 'battle_pass_3step.ui'
            struct_indv_pass.package_class = 'UI_BattlePass_Nurture'
            
            table.insert(list, struct_indv_pass)
            priority = priority - 1

            if is_for_check == true then
                return list
            end
        end
    end

    return list
end

-------------------------------------
-- function getIndivPass
-------------------------------------
function ServerData_IndivPass:getIndivPass(pass_id)
    return self.m_mPassData[pass_id]
end

-------------------------------------
-- function applyPassData
-------------------------------------
function ServerData_IndivPass:applyPassData(ret)
    if ret['modified_indiv_pass_map'] ~= nil then
        local t_info = ret['modified_indiv_pass_map'] 
        for k, v in pairs(t_info) do
            local struct_indiv_pass = self.m_mPassData[tonumber(k)]
            for var_name, var_value in pairs(v) do
                struct_indiv_pass[var_name] = var_value
            end
        end
    end

    if ret['indiv_pass_map'] ~= nil then
        local t_info = ret['indiv_pass_map']
        for k, v in pairs(t_info) do
            self.m_mPassData[tonumber(k)] = StructIndivPass(v)
        end
    end
end

-------------------------------------
-- function request_info
-------------------------------------
function ServerData_IndivPass:request_info(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:applyPassData(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/indiv_pass/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function request_reward
-------------------------------------
function ServerData_IndivPass:request_reward(pass_id, reward_ids ,finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:applyPassData(ret)
        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/indiv_pass/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('pass_id', pass_id)
    ui_network:setParam('reward_ids', reward_ids)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end