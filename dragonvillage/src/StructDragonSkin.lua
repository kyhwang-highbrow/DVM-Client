-------------------------------------
-- class StructDragonSkin
-- @instance
-------------------------------------
StructDragonSkin = class({
        m_bStruct = 'boolean',
        m_skin_id = 'number',
        m_did = 'number',
        m_priority = 'number',
        m_name = 'string',
        m_desc = 'string',
        m_attribute = 'string',

        m_res = 'string',
        m_res_icon = 'string',

        m_price = 'number',
        m_price_type = 'number',

        m_scale = 'number',
        m_stat_bonus = 'table',

        m_bUsed = 'boolean',
        m_saleType = 'string', -- package : 패키지 상점에서 구매
    })

-------------------------------------
-- function init
-------------------------------------
function StructDragonSkin:init(data)
    self.m_bStruct = true

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructDragonSkin:applyTableData(data)
    
    local replacement = {}
    replacement['skin_id'] = 'm_skin_id'
    replacement['did'] = 'm_did'
    replacement['ui_priority'] = 'm_priority'
    replacement['t_name'] = 'm_name'
    replacement['sale_type'] = 'm_saleType'
    replacement['t_desc'] = 'm_desc'
    replacement['attribute'] = 'm_attribute'

    replacement['res'] = 'm_res'
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
-- @brief 열려있는 스킨인지
-------------------------------------
function StructDragonSkin:isOpen()
    -- 기본 스킨은 오픈 상태
    if (self.m_skin_id%10 == 0) then
        return true

    -- 유료 스킨은 구매리스트와 비교하여 오픈 상태인지 판단
    else
        -- local open_list = g_userData.m_openList
        -- for _, skin_id in ipairs(open_list) do
        --     if (self.m_skin_id == skin_id) then
        --         return true
        --     end
        -- end
    end

    return false
end

-------------------------------------
-- function isUsed
-- @brief 사용중인 코스튬인지
-------------------------------------
function StructDragonSkin:isUsed()
    local dragon_skin_map = nil
    local used_skin_id = 0

    -- if dragon_skin_map ~= nil or (dragon_skin_map[did]) then
    --     used_skin_id =  dragon_skin_map[tamer_id]['costume'] 

    -- -- 테이머 정보가 없다면 기본복장 사용중인걸로 처리
    -- else
    --     used_skin_id = TableDragonSkin:getDefaultSkinID(self.m_did)
    -- end 
    used_skin_id = TableDragonSkin:getDefaultSkinID(self.m_did)

    return (self.m_skin_id == used_skin_id)
end

-------------------------------------
-- function isSale
-- @brief 할인중인지
-------------------------------------
function StructDragonSkin:isSale()
    -- local sale_info = g_tamerCostumeData.m_saleInfo
    -- local shop_info = g_tamerCostumeData:getShopInfo(self.m_cid)
    -- local msg 
    -- if (shop_info and sale_info and sale_info[tostring(self.m_cid)]) then
    --     local date_format = 'yyyy-mm-dd HH:MM:SS'
    --     local parser = pl.Date.Format(date_format)

    --     local end_date = parser:parse(shop_info['sale_end_date'])
    --     local cur_time =  ServerTime:getInstance():getCurrentTimestampSeconds()
    --     local end_time = end_date['time']
        
    --     if (end_time == nil) then
    --         return false, ''
    --     end
    --     local time = (end_time - cur_time)
    --     msg = Str('할인 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))

    --     return true, msg
    -- end
        
    -- return false, msg

    return false, ''
end

-------------------------------------
-- function isLimit
-- @brief 기간한정인지 (기간한정이라면 남은 기간도 같이 반환)
-------------------------------------
function StructDragonSkin:isLimit()
    -- local shop_info = g_tamerCostumeData:getShopInfo(self.m_cid)
    -- local msg
    -- if (shop_info) then
    --     local date_format = 'yyyy-mm-dd HH:MM:SS'
    --     local parser = pl.Date.Format(date_format)

    --     local end_date = parser:parse(shop_info['end_date'])
    --     local cur_time =  ServerTime:getInstance():getCurrentTimestampSeconds()
    --     local end_time = end_date['time']
    --     if (cur_time and end_time) then
    --         local time = (end_time - cur_time)

    --         -- 판매기간이 1년 미만으로 남은 경우에만 기간한정으로 판단
    --         local remain = 86400 * 365
    --         if (time < remain) then
    --             msg = Str('판매 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))
    --             return true, msg
    --         else
    --             return false, msg
    --         end
    --     end
    -- end

    -- return false, msg

    return false, ''
end

-------------------------------------
-- function isEnd
-- @brief 판매종료 (서버에서 코스튬 샵정보 안줌)
-------------------------------------
function StructDragonSkin:isEnd()
    -- local is_default = self:isDefaultCostume()
    -- local shop_info = g_tamerCostumeData:getShopInfo(self.m_cid)
    -- if (not shop_info) and (not is_default) then
    --      return true
    -- end

    return false
end

-------------------------------------
-- function isBuyable
-- @brief 구매가능한가
-------------------------------------
function StructDragonSkin:isBuyable()
    return (not self:isOpen()) and (not self:isEnd())
end

-------------------------------------
-- function isDragonLock
-- @brief 해당 스킨의 드래곤을 보유중인지
-------------------------------------
function StructDragonSkin:isDragonLock()
    -- local tamer_id = self:getTamerID()
    -- 기본 코스튬은 테이머 열려있지 않아도 잠금처리 안함
    if (self.m_skin_id == TableDragonSkin:getDefaultSkinID(self.m_did)) then
        return false
    end

    return not g_dragonsData:has(self.m_did)
end

-------------------------------------
-- function getSkinID
-------------------------------------
function StructDragonSkin:getSkinID()
    -- local dragon_idx = getDigit(self.m_did, 10, 2)
    -- local dragon_id = tonumber(string.format('1100%02d', dragon_idx))
	-- if (not tamer_id) then
	-- 	tamer_id = self.m_serverData:getRef('user', 'tamer')
	-- end

    return self.m_skin_id
end

-------------------------------------
-- function getSkinAttribute
-------------------------------------
function StructDragonSkin:getSkinAttribute()
    return self.m_attribute
end

-------------------------------------
-- function getDragonSkinIcon
-------------------------------------
function StructDragonSkin:getDragonSkinIcon(i)
    local path = string.gsub(self.m_res_icon, '#', '0' .. i)

    if string.find(path, '@') then
        path = string.gsub(path, '@', self.m_attribute)
    end
    -- local image = cc.Sprite:create(path)
    -- if (image) then
    --     image:setDockPoint(CENTER_POINT)
    --     image:setAnchorPoint(CENTER_POINT)
    -- end

    return path
end

-------------------------------------
-- function getDragonSkinRes
-------------------------------------
function StructDragonSkin:getDragonSkinRes()
    local res = self.m_res

    if string.find(res, '@') then
        res = string.gsub(res, '@', self.m_attribute)
    end

    return res
end

-------------------------------------
-- function getCid
-------------------------------------
function StructDragonSkin:getDid()
    return self.m_did
end

-------------------------------------
-- function getName
-------------------------------------
function StructDragonSkin:getName()
    return Str(self.m_name)
end

-------------------------------------
-- function getPrice
-------------------------------------
function StructDragonSkin:getPrice()
    return self.m_price, self.m_price_type
end

-------------------------------------
-- function isDefaultSkin
-- @brief 기본 복장인지 여부
-------------------------------------
function StructDragonSkin:isDefaultSkin()
    if (not self.m_did) then
        return true
    end

    -- 1~10의자리 숫자가 개별 코스튬 아이디
    local individual_skin_id = getDigit(self.m_did, 1, 2)
    
    if (individual_skin_id == 0) then
        return true
    end

    return false
end

-------------------------------------
-- function isPackageSkin
-- @brief 패키지로 판매하는 코스튬인지 여부
-------------------------------------
function StructDragonSkin:isPackageSkin()
    return (self.m_saleType == 'package')
end
