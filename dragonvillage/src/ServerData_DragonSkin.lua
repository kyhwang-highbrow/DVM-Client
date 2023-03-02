-------------------------------------
-- class ServerData_DragonSkin
-------------------------------------
ServerData_DragonSkin = class({
    m_serverData = 'ServerData',
    m_shopInfo = 'map',
    m_saleInfo = 'map',
    m_bDirtyCostumeInfo = 'bool', -- 코스튬 구매로 인해 갱신이 필요한지 여부
    m_skinPackageMap = 'Map',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonSkin:init(server_data)
    self.m_serverData = server_data
    self.m_shopInfo = {}
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

    -- @dhkim 23.03.02 항상 스킨 리스트 첫번째엔 기본 스킨이 포함되야 한다
    local basic_data = {}
    basic_data['skin_id'] = 0
    basic_data['did'] = did
    basic_data['ui_priority'] = 99
    basic_data['t_name'] = '기본 스킨'
    basic_data['sale_type'] = ''
    basic_data['t_desc'] = ''
    basic_data['attribute'] = TableDragon:getValue(did, 'attr')
    basic_data['res'] = TableDragon:getValue(did, 'res')
    basic_data['res_icon'] = TableDragon:getValue(did, 'icon')
    basic_data['price'] = 0
    basic_data['price_type'] = 0
    basic_data['scale'] = 0
    basic_data['stat_bonus'] = 0

    local struct_basic_skin = StructDragonSkin(basic_data)

    table.insert(l_struct_skin, struct_basic_skin)

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
-- function makeDragonSkinSaleMap
-------------------------------------
function ServerData_DragonSkin:makeDragonSkinSaleMap()
    local struct_dragon_skin_sale_map = {}
    local struct_product_list = g_shopDataNew:getProductList('dragon_skin')
    local skin_id_list = TableDragonSkin:getDragonSkinIdList()

    for _ ,skin_id in ipairs(skin_id_list) do
        local struct_dragon_skin_sale = StructDragonSkinSale(skin_id)
        if TableItem:getInstance():exists(skin_id) == true then
            struct_dragon_skin_sale_map[skin_id] = struct_dragon_skin_sale
        end
    end

    for _, struct_product in pairs(struct_product_list) do
        local is_skin_product, skin_id = struct_product:isDragonSkinProduct()
        if is_skin_product == true then
            local struct_dragon_skin_sale = struct_dragon_skin_sale_map[skin_id]

            if struct_dragon_skin_sale ~= nil then
                struct_dragon_skin_sale:insertDragonSkinProduct(struct_product)
            end
        end
    end

    self.m_skinPackageMap = struct_dragon_skin_sale_map
end

-------------------------------------
-- function getDragonSkinSaleMap
-------------------------------------
function ServerData_DragonSkin:getDragonSkinSaleMap(force_make)
    if self.m_skinPackageMap == nil or force_make == true then
        self:makeDragonSkinSaleMap()
    end

    return self.m_skinPackageMap
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