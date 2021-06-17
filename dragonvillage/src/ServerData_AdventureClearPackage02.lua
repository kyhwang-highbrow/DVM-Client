-- 관련 테이블
-- table_package_stage
-- table_shop_lsit
-- table_shop_cash

-------------------------------------
-- class ServerData_AdventureClearPackage02
-- @breif 모험돌파 패키지 관리
-------------------------------------
ServerData_AdventureClearPackage02 = class({
        m_serverData = 'ServerData',
        m_bActive = 'boolean',
        m_receivedList = 'list',
        m_bDirty = 'bool',
        m_productID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AdventureClearPackage02:init(server_data)
    self.m_serverData = server_data
    self.m_bActive = false
    self.m_receivedList = {}
    self.m_productID = 110281
end

-------------------------------------
-- function isBattlePassProduct
-------------------------------------
function ServerData_AdventureClearPackage02:isBattlePassProduct(product_id)
    return self.m_productID == tonumber(product_id)
end

-------------------------------------
-- function checkDirty
-------------------------------------
function ServerData_AdventureClearPackage02:checkDirty()
    if self.m_bDirty then
        return
    end

    -- 만료 시간 체크 할 것!
    --self.m_expirationData
    self:setDirty()
end

-------------------------------------
-- function setDirty
-------------------------------------
function ServerData_AdventureClearPackage02:setDirty()
    self.m_bDirty = true
end

-------------------------------------
-- function isDirty
-------------------------------------
function ServerData_AdventureClearPackage02:isDirty()
    return self.m_bDirty
end

-------------------------------------
-- function request_adventureClearInfo
-------------------------------------
function ServerData_AdventureClearPackage02:request_adventureClearInfo(cb_func, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_adventureClearInfo(ret)

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/stagepack_info')
    ui_network:setParam('product_id', self.m_productID)
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_adventureClearInfo
-------------------------------------
function ServerData_AdventureClearPackage02:response_adventureClearInfo(ret)
    self.m_bActive = ret['active'] or false
    self.m_receivedList = ret['received_list'] or {}
end

-------------------------------------
-- function isActive
-------------------------------------
function ServerData_AdventureClearPackage02:isActive()
    return self.m_bActive
end

-------------------------------------
-- function isVisibleAtBattlePassShop
-- @breif 구매 전에는 출력하고 구매 후에는 보상이 남은 경우 출력
-------------------------------------
function ServerData_AdventureClearPackage02:isVisibleAtBattlePassShop()
    if (not self:isActive()) then
        return true
    end

    local l_item_list = TABLE:get('table_package_stage_02')
    for i,v in pairs(l_item_list) do
        local stage_id = v['stage']
        if (self:isReceived(stage_id) == false) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function isVisible_adventureClearPack
-------------------------------------
function ServerData_AdventureClearPackage02:isVisible_adventureClearPack()
    if (not self:isActive()) then
        return false
    end

    local l_item_list = TABLE:get('table_package_stage_02')
    for i,v in pairs(l_item_list) do
        local stage_id = v['stage']
        if (self:isReceived(stage_id) == false) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function isVisible_adventureClearPackNoti
-- @brief 보상받을 수 있는 항목 있을 때에만 노티
-------------------------------------
function ServerData_AdventureClearPackage02:isVisible_adventureClearPackNoti()
    if (not self:isActive()) then
        return false
    end

    local l_item_list = TABLE:get('table_package_stage_02')
    for i,v in pairs(l_item_list) do
        local stage_id = v['stage']
        -- 보상 안 받은 항목들 중에서
        if (self:isReceived(stage_id) == false) then
            local stage_info = g_adventureData:getStageInfo(stage_id)
            local star = stage_info:getNumberOfStars()
            -- 보상 받을 수 있는 항목이 있음
            if (star >= 3) then
                return true
            end
        end
    end

    return false
end

-------------------------------------
-- function request_adventureClearReward
-------------------------------------
function ServerData_AdventureClearPackage02:request_adventureClearReward(stage, cb_func, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        
        self.m_receivedList = ret['received_list']

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/stagepack_reward')
    ui_network:setParam('product_id', self.m_productID)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function isReceived
-------------------------------------
function ServerData_AdventureClearPackage02:isReceived(stage_id)
    for i,v in pairs(self.m_receivedList) do
        if (v == stage_id) then
            return true
        end
    end

    return false
end


-------------------------------------
-- function getFocusRewardStage
-- @brief 보상 받기 가능한 idx로 이동
-------------------------------------
function ServerData_AdventureClearPackage02:getFocusRewardStage()
    local map = TABLE:get('table_package_stage_02')
    local list = table.MapToList(map)

    local function sort_func(a, b)
        return a['stage'] < b['stage']
    end
    table.sort(list, sort_func)
   
    for i,v in ipairs(list) do
        local stage_id = v['stage']
        local stage_info = g_adventureData:getStageInfo(stage_id)
        local star = stage_info:getNumberOfStars()

        if (3 <= star) and (not self:isReceived(stage_id)) then
            return stage_id, i
        end
    end

    return nil
end