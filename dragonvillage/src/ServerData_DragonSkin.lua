-------------------------------------
-- class ServerData_DragonSkin
-------------------------------------
ServerData_DragonSkin = class({
        m_serverData = 'ServerData',
        m_shopInfo = 'map',
        m_openList = 'list',
        m_saleInfo = 'map',
        m_bDirtyCostumeInfo = 'bool', -- 코스튬 구매로 인해 갱신이 필요한지 여부
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonSkin:init(server_data)
    self.m_serverData = server_data
    self.m_shopInfo = {}
    self.m_openList = {}
    self.m_saleInfo = {}
    self.m_bDirtyCostumeInfo = false
end

-------------------------------------
-- function getSkinID
-- @brief 코스튬 ID 반환
-------------------------------------
function ServerData_DragonSkin:getSkinID(did)
	local tamer_id = did or g_tamerData:getCurrTamerID()
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
function ServerData_DragonSkin:getCostumeDataWithTamerID(tamer_id)
    local costume_id = self:getCostumeID(tamer_id)
    
    local table_tamer = TableTamerCostume()
    local t_costume = table_tamer:get(costume_id)

    return StructTamerCostume(t_costume)
end

-------------------------------------
-- function getCostumeDataWithCostumeID
-- @brief 코스튬 정보 반환
-------------------------------------
function ServerData_DragonSkin:getCostumeDataWithCostumeID(costume_id)
    local table_tamer = TableTamerCostume()
    local t_costume = table_tamer:get(costume_id)

    return StructTamerCostume(t_costume)
end

-------------------------------------
-- function isDragonSkinExist
-- @brief 스킨이 존재하는 드래곤인지 확인
-------------------------------------
function ServerData_DragonSkin:isDragonSkinExist(doid)

    --@dhkim temp 23.02.17 - 스킨 있는 드래곤 우선 임시 확인용
    if doid == 121854 or doid == 121842 or doid == 121752 or doid == 121861 then
        return true
    end

    return false
end

-------------------------------------
-- function isDragonSkinOpened
-- @brief 해당 스킨을 보유 중인지 확인
-------------------------------------
function ServerData_DragonSkin:isDragonSkinOpened(skin_id)
    for _,v in pairs(self.m_openList) do
        if v == skin_id then
            return true
        end
    end
    
    return false
end

-------------------------------------
-- function getUsedStructCostumeData
-- @breif 해당 테이머 코스튬중 사용중인 코스튬 정보 반환
-------------------------------------
function ServerData_DragonSkin:getUsedStructCostumeData(tamer_id)
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
-- function makeStructSkinList
-- @breif 해당 드래곤의 모든 스킨 정보 리스트로 반환
-------------------------------------
function ServerData_DragonSkin:makeStructSkinList(did)
    local skin_list = TableDragonSkin():filterList('did', did) 
    table.sort(skin_list, function(a,b)
        local a_priority = a['ui_priority'] or 0
        local b_priority = b['ui_priority'] or 0
        return a_priority > b_priority
    end)

    local l_struct_skin = {}
    for k, v in ipairs(skin_list) do
        table.insert(l_struct_skin, StructDragonSkin(v))
    end

    return l_struct_skin
end

-------------------------------------
-- function getShopInfo
-- @breif 해당 코스튬 샵정보 반환
-------------------------------------
function ServerData_DragonSkin:getShopInfo(costume_id)
    if (self.m_shopInfo[costume_id]) then
        return self.m_shopInfo[costume_id]
    end

    return nil
end

-------------------------------------
-- function applyTamersCostume
-------------------------------------
function ServerData_DragonSkin:applyTamersCostume(l_tamers_costume_id_list)
    assert(l_tamers_costume_id_list, 'tamer costume id list is nil')
    self.m_openList = l_tamers_costume_id_list
end

-------------------------------------
-- function request_costumeInfo
-------------------------------------
function ServerData_DragonSkin:request_costumeInfo(cb_func, check_shop_info, fail_cb)
    -- check_shop_info = true 일 경우 코스튬 상품 정보가 있다면 통신 하지 않음 (불필요한 통신 줄이기위해)
    if (check_shop_info) then
        local l_shop = table.MapToList(self.m_shopInfo)
        if (#l_shop > 0) then
            if (cb_func) then
			    cb_func()
		    end
            return
        end
    end

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
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function request_costumeBuy
-------------------------------------
function ServerData_DragonSkin:request_costumeBuy(cid, cb_func)
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
function ServerData_DragonSkin:request_costumeSelect(cid, tid, cb_func)
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
                g_lobbyChangeMgr:globalUpdatePlayerUserInfo()
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