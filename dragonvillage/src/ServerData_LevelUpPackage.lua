-- 관련 테이블
-- table_package_levelup
-- table_shop_lsit
-- table_shop_cash

-------------------------------------
-- class ServerData_LevelUpPackage
-- @breif 레벨업 패키지 관리
-------------------------------------
ServerData_LevelUpPackage = class({
        m_serverData = 'ServerData',
        m_bActive = 'boolean',
        m_receivedList = 'list',
        m_bDirty = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_LevelUpPackage:init(server_data)
    self.m_serverData = server_data
    self.m_bActive = false
    self.m_receivedList = {}
end

-------------------------------------
-- function ckechDirty
-------------------------------------
function ServerData_LevelUpPackage:ckechDirty()
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
function ServerData_LevelUpPackage:setDirty()
    self.m_bDirty = true
end

-------------------------------------
-- function isDirty
-------------------------------------
function ServerData_LevelUpPackage:isDirty()
    return self.m_bDirty
end

-------------------------------------
-- function request_lvuppackInfo
-------------------------------------
function ServerData_LevelUpPackage:request_lvuppackInfo(cb_func, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_lvuppackInfo(ret)

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/lvuppack_info')
    ui_network:setParam('uid', uid)
    -- 기존 레벨업 패키지 product_id : 90037, 
    -- 20191210 업데이트 이후 추가된 레벨업 패키지2 product_id : 110271
    ui_network:setParam('product_id', 90037) 
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_lvuppackInfo
-- @brief 타이틀에서도 정보 받고 있음
-------------------------------------
function ServerData_LevelUpPackage:response_lvuppackInfo(ret)
    self.m_bActive = ret['active'] or false
    self.m_receivedList = ret['received_list'] or {}
end

-------------------------------------
-- function isActive
-------------------------------------
function ServerData_LevelUpPackage:isActive()
    return self.m_bActive
end

-------------------------------------
-- function isVisible_lvUpPack
-------------------------------------
function ServerData_LevelUpPackage:isVisible_lvUpPack()
    if (not self:isActive()) then
        return false
    end

    local l_item_list = TABLE:get('table_package_levelup')
    for i,v in pairs(l_item_list) do
        local lv = v['level']
        if (self:isReceived(lv) == false) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function request_lvuppackReward
-------------------------------------
function ServerData_LevelUpPackage:request_lvuppackReward(lv, cb_func, fail_cb)
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
    ui_network:setUrl('/shop/lvuppack_reward')
    ui_network:setParam('uid', uid)
    -- 기존 레벨업 패키지 product_id : 90037, 
    -- 20191210 업데이트 이후 추가된 레벨업 패키지2 product_id : 110271
    ui_network:setParam('product_id', 90037) 
    ui_network:setParam('lv', lv)
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
function ServerData_LevelUpPackage:isReceived(lv)
    for i,v in pairs(self.m_receivedList) do
        if (v == lv) then
            return true
        end
    end

    return false
end


-------------------------------------
-- function getFocusRewardLevel
-- @brief 보상 수령이 가능한 레벨 리턴
-------------------------------------
function ServerData_LevelUpPackage:getFocusRewardLevel()
    local map = TABLE:get('table_package_levelup')
    local list = table.MapToList(map)

    local function sort_func(a, b)
        return a['level'] < b['level']
    end
    table.sort(list, sort_func)
    
    local user_level = g_userData:get('lv')

    for i,v in ipairs(list) do
        local lv = v['level']
        if (lv <= user_level) and (not self:isReceived(lv)) then
            return lv, i
        end
    end

    return nil
end