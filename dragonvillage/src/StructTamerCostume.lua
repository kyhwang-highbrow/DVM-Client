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

        m_priority = 'number',
        m_bUsed = 'boolean',
        m_saleType = 'string', -- valor : 용맹훈장 상점에서 구매
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
    replacement['ui_priority'] = 'm_priority'
    replacement['sale_type'] = 'm_saleType'
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
    local sale_info = g_tamerCostumeData.m_saleInfo
    local shop_info = g_tamerCostumeData:getShopInfo(self.m_cid)
    local msg 
    if (shop_info and sale_info and sale_info[tostring(self.m_cid)]) then
        local date_format = 'yyyy-mm-dd HH:MM:SS'
        local parser = pl.Date.Format(date_format)

        local end_date = parser:parse(shop_info['sale_end_date'])
        local cur_time =  ServerTime:getInstance():getCurrentTimestampSeconds()
        local end_time = end_date['time']
        
        if (end_time == nil) then
            return false, ''
        end
        local time = (end_time - cur_time)
        msg = Str('할인 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))

        return true, msg
    end
        
    return false, msg
end

-------------------------------------
-- function isLimit
-- @brief 기간한정인지 (기간한정이라면 남은 기간도 같이 반환)
-------------------------------------
function StructTamerCostume:isLimit()
    local shop_info = g_tamerCostumeData:getShopInfo(self.m_cid)
    local msg
    if (shop_info) then
        local date_format = 'yyyy-mm-dd HH:MM:SS'
        local parser = pl.Date.Format(date_format)

        local end_date = parser:parse(shop_info['end_date'])
        local cur_time =  ServerTime:getInstance():getCurrentTimestampSeconds()
        local end_time = end_date['time']
        if (cur_time and end_time) then
            local time = (end_time - cur_time)

            -- 판매기간이 1년 미만으로 남은 경우에만 기간한정으로 판단
            local remain = 86400 * 365
            if (time < remain) then
                msg = Str('판매 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))
                return true, msg
            else
                return false, msg
            end
        end
    end

    return false, msg
end

-------------------------------------
-- function isEnd
-- @brief 판매종료 (서버에서 코스튬 샵정보 안줌)
-------------------------------------
function StructTamerCostume:isEnd()
    local is_default = self:isDefaultCostume()
    local shop_info = g_tamerCostumeData:getShopInfo(self.m_cid)
    if (not shop_info) and (not is_default) then
         return true
    end

    return false
end

-------------------------------------
-- function isBuyable
-- @brief 구매가능한가
-------------------------------------
function StructTamerCostume:isBuyable()
    return (not self:isOpen()) and (not self:isEnd())
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
-- function getName
-------------------------------------
function StructTamerCostume:getName()
    return Str(self.m_name)
end

-------------------------------------
-- function getPrice
-------------------------------------
function StructTamerCostume:getPrice()
    return self.m_price, self.m_price_type
end

-------------------------------------
-- function isDefaultCostume
-- @brief 기본 복장인지 여부
-------------------------------------
function StructTamerCostume:isDefaultCostume()
    if (not self.m_cid) then
        return true
    end

    -- 1~10의자리 숫자가 개별 코스튬 아이디
    local individual_costume_id = getDigit(self.m_cid, 1, 2)
    
    if (individual_costume_id == 0) then
        return true
    end

    return false
end

-------------------------------------
-- function isValorCostume
-- @brief 용맹 코스튬인지 여부
-------------------------------------
function StructTamerCostume:isValorCostume()
    return (self.m_saleType == 'valor')
end

-------------------------------------
-- function isTopazCostume
-- @brief 상품 세일 타입이 topaz인지 여부 ex) 겨울 여왕 코스튬
-------------------------------------
function StructTamerCostume:isTopazCostume()
    return (self.m_saleType == 'topaz')
end

