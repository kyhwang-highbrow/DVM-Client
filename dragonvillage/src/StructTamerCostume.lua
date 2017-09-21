-------------------------------------
-- class StructTamerCostume
-- @instance
-------------------------------------
StructTamerCostume = class({
        m_bStruct = 'boolean',
        m_cid = 'number',
        m_name = 'string',
        m_type = 'string',
        m_desc = 'string',

        m_res_sd = 'string',
        m_res_icon = 'string',

        m_price = 'number',
        m_price_type = 'number',

        m_scale = 'number',
        m_stat_bonus = 'table',

        m_bUsed = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function StructTamerCostume:init(data)
    self.m_bStruct = true

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructTamerCostume:applyTableData(data)
    
    local replacement = {}
    replacement['cid'] = 'm_cid'
    replacement['t_name'] = 'm_name'
    replacement['type'] = 'm_type'
    replacement['t_desc'] = 'm_desc'

    replacement['res_sd'] = 'm_res_sd'
    replacement['res_icon'] = 'm_res_icon'

    replacement['price'] = 'm_price'
    replacement['price_type'] = 'm_price_type'

    replacement['scale'] = 'm_scale'
    replacement['stat_bonus'] = 'm_stat_bonus'

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function isOpen
-- @brief 열려있는 코스튬인지
-------------------------------------
function StructTamerCostume:isOpen()
    -- 기본 코스튬은 오픈 상태
    if (self.m_cid%100 == 0) then
        return true

    -- 유료 코스튬은 구매리스트와 비교하여 오픈 상태인지 판단
    else
        local open_list = g_tamerCostumeData.m_openList
        for _, cid in ipairs(open_list) do
            if (self.m_cid == cid) then
                return true
            end
        end
    end

    return false
end

-------------------------------------
-- function isUsed
-- @brief 사용중인 코스튬인지
-------------------------------------
function StructTamerCostume:isUsed()
    local tamer_id = self:getTamerID()
    local tamer_map = g_tamerData.m_mTamerMap
    local used_costume_id = 0

    if (tamer_map[tamer_id]) then
        used_costume_id =  tamer_map[tamer_id]['costume'] 

    -- 테이머 정보가 없다면 기본복장 사용중인걸로 처리
    else
        used_costume_id = TableTamerCostume:getDefaultCostumeID(tamer_id)
    end 

    return (self.m_cid == used_costume_id)
end

-------------------------------------
-- function isSale
-- @brief 할인중인지
-------------------------------------
function StructTamerCostume:isSale()
    local shop_info = g_tamerCostumeData:getShopInfo(self.m_cid)
    if (shop_info) then
        local origin_price = shop_info['origin_price']
        local price = shop_info['price']
        local is_sale = (origin_price ~= price)
        return is_sale
    end

    return false
end

-------------------------------------
-- function isTamerLock
-- @brief 해당 코스튬 테이머가 열려있는지
-------------------------------------
function StructTamerCostume:isTamerLock()
    local tamer_id = self:getTamerID()
    -- 기본 코스튬은 테이머 열려있지 않아도 잠금처리 안함
    if (self.m_cid == TableTamerCostume:getDefaultCostumeID(tamer_id)) then
        return false
    end

    return not g_tamerData:hasTamer(tamer_id)
end

-------------------------------------
-- function getTamerID
-------------------------------------
function StructTamerCostume:getTamerID()
    local tamer_idx = getDigit(self.m_cid, 100, 2)
    local tamer_id = tonumber(string.format('1100%02d', tamer_idx))
	if (not tamer_id) then
		tamer_id = self.m_serverData:getRef('user', 'tamer')
	end

    return tamer_id
end

-------------------------------------
-- function getTamerSDIcon
-------------------------------------
function StructTamerCostume:getTamerSDIcon()
    local image = cc.Sprite:create(self.m_res_icon)
    if (image) then
        image:setDockPoint(CENTER_POINT)
        image:setAnchorPoint(CENTER_POINT)
    end

    return image
end

-------------------------------------
-- function getResSD
-------------------------------------
function StructTamerCostume:getResSD()
    return self.m_res_sd
end

-------------------------------------
-- function getCid
-------------------------------------
function StructTamerCostume:getCid()
    return self.m_cid
end

-------------------------------------
-- function getLv
-------------------------------------
function StructTamerCostume:getName()
    return self.m_name
end

-------------------------------------
-- function getPrice
-------------------------------------
function StructTamerCostume:getPrice()
    return self.m_price, self.m_price_type
end

