-------------------------------------
-- class ServerData_DragonSkin
-------------------------------------
ServerData_DragonSkin = class({
    m_serverData = 'ServerData',
    m_shopInfo = 'map',
    m_saleInfo = 'map',
    m_skinPackageMap = 'map',
    m_bDirtySkinInfo = 'bool', -- 스킨 구매로 인해 갱신이 필요한지 여부
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonSkin:init(server_data)
    self.m_serverData = server_data
    self.m_shopInfo = {}
    self.m_saleInfo = {}
    self.m_bDirtySkinInfo = false
end

-------------------------------------
-- function getDragonSkinDataWithSkinID
-- @brief 스킨 정보 반환
-------------------------------------
function ServerData_DragonSkin:getDragonSkinDataWithSkinID(skin_id)
    local table_skin = TableDragonSkin()
    local t_skin = table_skin:get(skin_id)

    return StructDragonSkin(t_skin)
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
    local struct_dragon_skin_sale_map = self:getDragonSkinSaleMap(true)
    local skin_id_list = TableDragonSkin:getDragonSkinIdList(did)
    table.sort(skin_id_list, function(a,b)
        local a_priority = TableDragonSkin:getDragonSkinValue('ui_priority', a) or 0
        local b_priority = TableDragonSkin:getDragonSkinValue('ui_priority', b) or 0
        return a_priority > b_priority
    end)

    local l_struct_skin = {}

    -- @dhkim 23.03.02 항상 스킨 리스트 첫번째엔 기본 스킨이 포함되야 한다
    local struct_basic_skin = StructDragonSkin:makeDefaultSkin(did)
    table.insert(l_struct_skin, struct_basic_skin)

    for _, skin_id in ipairs(skin_id_list) do
        local t_skin_info = clone(TableDragonSkin:getDragonSkinInfo(skin_id))
        local struct_dragon_skin = StructDragonSkin(t_skin_info)

        local struct_dragon_skin_sale = struct_dragon_skin_sale_map[skin_id]
        if struct_dragon_skin_sale ~= nil then
            struct_dragon_skin.money_product_list = struct_dragon_skin_sale.money_product_list
            struct_dragon_skin.cash_product_list = struct_dragon_skin_sale.cash_product_list
        end

        table.insert(l_struct_skin, struct_dragon_skin)
    end

    return l_struct_skin
end

-------------------------------------
-- function getShopInfo
-- @breif 해당 스킨 샵정보 반환
-------------------------------------
function ServerData_DragonSkin:getShopInfo(dragon_skin)
    if (self.m_skinPackageMap[dragon_skin]) then
        return self.m_skinPackageMap[dragon_skin]
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
        local t_data = {['skin_id'] = skin_id}
        local struct_dragon_skin_sale = StructDragonSkin(t_data)
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
-- function isDragonSkinSalePurchaseAvailable
-------------------------------------
function ServerData_DragonSkin:isDragonSkinSalePurchaseAvailable()
    local struct_product_list = g_shopDataNew:getProductList('dragon_skin')
    cclog('struct_product_list', #struct_product_list)

    for _, struct_product in pairs(struct_product_list) do
        return true, struct_product
--[[         if struct_product:getPriceType() == 'money' and struct_product:getProductBadge() == 'sale' then
            if struct_product:isBuyable() == true then
                return true, struct_product
            end
        end ]]
    end
    return false
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
function ServerData_DragonSkin:request_dragonSkinSelect(skin_id, doid, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        g_dragonsData:applyDragonData(ret['dragon'])

        -- -- 채팅 서버에 변경사항 적용
        -- if g_chatClientSocket then
        --     local doid = tonumber(doid)
        --     if (g_dragonsData:isLeaderDragon(doid)) then
        --         g_lobbyChangeMgr:globalUpdatePlayerUserInfo()
        --     end
        -- end

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/set/skin')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('skin_id', skin_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end