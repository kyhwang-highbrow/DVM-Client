-------------------------------------
-- class ServerData_TamerCostume
-------------------------------------
ServerData_TamerCostume = class({
        m_serverData = 'ServerData',
        m_shopInfo = 'map',
        m_openList = 'list',
        m_saleInfo = 'map'
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_TamerCostume:init(server_data)
    self.m_serverData = server_data
    self.m_shopInfo = {}
    self.m_openList = {}
    self.m_saleInfo = {}
end

-------------------------------------
-- function getCostumeID 
-- @brief 코스튬 ID 반환
-------------------------------------
function ServerData_TamerCostume:getCostumeID(tamer_id)
	local tamer_id = tamer_id or g_tamerData:getCurrTamerID()
    local costume_id
    if (g_tamerData.m_mTamerMap[tamer_id]) then
        costume_id = g_tamerData.m_mTamerMap[tamer_id]['costume']
    end

    if (not costume_id) then
        costume_id = TableTamerCostume:getDefaultCostumeID(tamer_id)
    end
    
    return costume_id
end

-------------------------------------
-- function getCostumeDataWithTamerID 
-- @brief 코스튬 정보 반환
-------------------------------------
function ServerData_TamerCostume:getCostumeDataWithTamerID(tamer_id)
    local costume_id = self:getCostumeID(tamer_id)
    
    local table_tamer = TableTamerCostume()
    local t_costume = table_tamer:get(costume_id)

    return StructTamerCostume(t_costume)
end

-------------------------------------
-- function getCostumeDataWithCostumeID 
-- @brief 코스튬 정보 반환
-------------------------------------
function ServerData_TamerCostume:getCostumeDataWithCostumeID(costume_id)
    local table_tamer = TableTamerCostume()
    local t_costume = table_tamer:get(costume_id)

    return StructTamerCostume(t_costume)
end

-------------------------------------
-- function getUsedStructCostumeData
-- @breif 해당 테이머 코스튬중 사용중인 코스튬 정보 반환
-------------------------------------
function ServerData_TamerCostume:getUsedStructCostumeData(tamer_id)
    local sel_type = TableTamer:getTamerType(tamer_id)
    local costume_list = TableTamerCostume():filterList('type', sel_type) 

    for k, v in ipairs(costume_list) do
        local cid = v['cid']
        local tamer_idx = getDigit(cid, 100, 2)
        local tamer_id = tonumber(string.format('1100%02d', tamer_idx))
        local tamer_map = g_tamerData.m_mTamerMap
        local used_costume_id 

        if (tamer_map[tamer_id]) then
            used_costume_id =  tamer_map[tamer_id]['costume'] 
        end

        -- 테이머 정보가 없다면 기본복장 사용중인걸로 처리
        if (not used_costume_id) then
            used_costume_id = TableTamerCostume:getDefaultCostumeID(tamer_id)
        end
            
        if (used_costume_id == cid) then
            return StructTamerCostume(v)
        end
    end

    return nil
end

-------------------------------------
-- function makeStructCostumeList
-- @breif 해당 테이머의 모든 코스튬 정보 리스트로 반환
-------------------------------------
function ServerData_TamerCostume:makeStructCostumeList(tamer_id)
    local sel_type = TableTamer:getTamerType(tamer_id)
    local costume_list = TableTamerCostume():filterList('type', sel_type) 
    table.sort(costume_list, function(a,b)
        local a_priority = a['ui_priority'] or 0
        local b_priority = b['ui_priority'] or 0
        return a_priority > b_priority
    end)

    local l_struct_costume = {}
    for k, v in ipairs(costume_list) do
        table.insert(l_struct_costume, StructTamerCostume(v)) 
    end

    return l_struct_costume
end

-------------------------------------
-- function getShopInfo
-- @breif 해당 코스튬 샵정보 반환
-------------------------------------
function ServerData_TamerCostume:getShopInfo(costume_id)
    if (self.m_shopInfo[costume_id]) then
        return self.m_shopInfo[costume_id]
    end

    return nil
end

-------------------------------------
-- function request_costumeInfo
-------------------------------------
function ServerData_TamerCostume:request_costumeInfo(cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self.m_shopInfo = {}
        local shop_list = ret['tamer_costume_info']
        for _, data in ipairs(shop_list) do
            local cid = data['cid']
            self.m_shopInfo[cid] = data
        end

        self.m_openList = ret['tamers_costume'] or nil
        self.m_saleInfo = ret['tamer_costume_sale'] or nil
        
		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/tamer/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_costumeBuy
-------------------------------------
function ServerData_TamerCostume:request_costumeBuy(cid, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '테이머 코스튬 구매')

        self.m_serverData:networkCommonRespone(ret)
        self.m_openList = ret['tamers_costume']

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/buy/costume')
    ui_network:setParam('uid', uid)
    ui_network:setParam('costume', cid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_costumeSelect
-------------------------------------
function ServerData_TamerCostume:request_costumeSelect(cid, tid, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
    local cid = (cid % 100 == 0) and 0 or cid
    -- 0 으로 처리해도 안됨..

    -- 콜백 함수
    local function success_cb(ret)
        
        -- 테이머 정보 갱신
		g_tamerData:applyTamerInfo(ret['tamer'])
		g_tamerData:reMappingTamerInfo()

        -- 채팅 서버에 변경사항 적용
        if g_chatClientSocket then
            local tamer_id = tonumber(tid)
            if (tamer_id == g_tamerData:getCurrTamerID()) then
                g_chatClientSocket:globalUpdatePlayerUserInfo()
            end
        end

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/set/costume')
    ui_network:setParam('uid', uid)
    ui_network:setParam('tid', tid)
    ui_network:setParam('costume', cid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end