local PARENT = TableClass



-------------------------------------
-- class TableBattlePass
-------------------------------------
TableBattlePass = class(PARENT, {
    m_battlePassTable = 'table',
    m_battlePassRewardTable = 'table',

    m_battlePassInfoMap = 'map',

    -- member variables
    })

local THIS = TableBattlePass


-------------------------------------
-- function init
-------------------------------------
function TableBattlePass:init()
    self.m_tableName = 'table_battle_pass'
    self:initTables()
end

-------------------------------------
-- function init
-------------------------------------
function TableBattlePass:initTables()
    self.m_battlePassTable = TABLE:get(self.m_tableName)
    self.m_battlePassRewardTable = TABLE:get('table_battle_pass_reward')
end

-- ['121701']={
--     ['subscription']='';
--     ['sku']='dvm_shopitem_30k';
--     ['banner_res']='';
--     ['t_name']='육성 패스';
--     ['token']='';
--     ['product_content']='';
--     ['t_desc']='blank';
--     ['xsolla_price_dollar']=29.99;
--     ['price_dollar']=32.99;
--     ['purchase_point']=30000;
--     ['price_type']='money';
--     ['price']=33000;
--     ['icon']='';
--     ['mail_content']='';
--     ['m_startDate']='2021-03-05 00:00:00';
--     ['package_frame_type']='';
--     ['badge']='';
--     ['max_buy_display']='';
--     ['m_tabCategory']='etc';
--     ['m_uiPriority']=120;
--     ['package_res']='battle_pass_nurture.ui';
--     ['max_buy_count']='';
--     ['product_id']=121701;
--     ['max_buy_term']='';
-- };
-------------------------------------
-- function updateTableMap
-- @brief 전반적인 배틀패스 정보를 업데이트 한다.
-------------------------------------
function TableBattlePass:updateTableMap()
    self:initTables()

    -- 테이블 정보 그릇 초기화
    self.m_battlePassInfoMap = {}

    -- 패스 상품정보를 받아온다.
    local item_list = g_shopDataNew:getProductList('pass')

    if (not self.m_battlePassTable) then return end

    -- 배틀패스 테이블에 있는 상품별 조회를 해서
    -- 각각 보상 테이블에 카테고리별로 넣어주자
    for i, v in ipairs(self.m_battlePassTable) do
        -- pid = 프로덕트 id
        local pid = v['pid']
        
        -- 상품정보를 받아온다.
        local struct_product = item_list[tonumber(pid)]

        -- local start_date = struct_product['m_startDate'] or ''
        -- local end_date = struct_product['m_endDate'] or ''
        -- local isEventTime = g_eventData:checkEventTime(start_date, end_date)
        
        
        -- 먼저 상품정보를 맵에 넣고
        if (not self.m_battlePassInfoMap[tostring(pid)]) then
            self.m_battlePassInfoMap[tostring(pid)] = {}
        end

        self.m_battlePassInfoMap[tostring(pid)]["product"] = struct_product

        self.m_battlePassInfoMap[tostring(pid)]['active_level'] = tonumber(v['active_lv'])

        -- 일반, 프리미업 보상 리스트를 초기화 한 다음
        local normalList = {}
        local premiumList = {}

        for j, rewardInfo in pairs(self.m_battlePassRewardTable) do
            -- 정보가 유효하고 pid가 같으면?
            if (rewardInfo and tonumber(rewardInfo['pid']) == tonumber(pid)) then
                -- 일반 보상리스트를 넣고
                if (rewardInfo['type'] == 'normal') then
                    table.insert(normalList, rewardInfo)
                elseif (rewardInfo['type'] == 'premium') then
                    -- 프리미엄 보상을 넣자
                    table.insert(premiumList, rewardInfo)
                end
            end
        end

        table.sort(normalList, function(a, b) return (tonumber(a['level']) < tonumber(b['level'])) end)
        table.sort(premiumList, function(a, b) return (tonumber(a['level']) < tonumber(b['level'])) end)

        self.m_battlePassInfoMap[tostring(pid)]['normal'] = normalList
        self.m_battlePassInfoMap[tostring(pid)]['premium'] = premiumList

        self.m_battlePassInfoMap[tostring(pid)]['min_level'] = tonumber(normalList[1]['level'])
        self.m_battlePassInfoMap[tostring(pid)]['max_level'] = tonumber(normalList[#normalList]['level'])
        self.m_battlePassInfoMap[tostring(pid)]['max_exp'] = tonumber(normalList[#normalList]['exp'])
        self.m_battlePassInfoMap[tostring(pid)]['exp_per_level'] = tonumber(normalList[2]['exp']) - tonumber(normalList[1]['exp'])
    end
end



--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Table
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

function TableBattlePass:getInfoMap()
    return self.m_battlePassInfoMap
end
-- function TableBattlePass:getItemInfo(pass_id, level)
--     self.m_battlePassInfoMap[tostring(pass_id)]
-- end

-------------------------------------
-- function getNormalRewardList
-- pid 받으면 그에 해당하는 리스트를 반환
-------------------------------------
function TableBattlePass:getNormalRewardList(pass_id)
    local resultMap = {}

    if (not self.m_battlePassInfoMap) then
        return resultMap 
    end
    if not self.m_battlePassInfoMap[tostring(pass_id)] then   
        return resultMap 
    end
    if not self.m_battlePassInfoMap[tostring(pass_id)]['normal'] then 
            return resultMap 
    end


    return self.m_battlePassInfoMap[tostring(pass_id)]['normal']
end

-------------------------------------
-- function getPremiumRewardList
-- pid 받으면 그에 해당하는 리스트를 반환
-------------------------------------
function TableBattlePass:getPremiumRewardList(pass_id)
    local resultMap = {}

    if (not self.m_battlePassInfoMap or 
        not self.m_battlePassInfoMap[tostring(pass_id)] or
        not self.m_battlePassInfoMap[tostring(pass_id)]['premium']) then 
            return resultMap 
    end

    return self.m_battlePassInfoMap[tostring(pass_id)]['premium']
end

-------------------------------------
-- function getMinLevel
-- pid 받으면 현재 유저 경험치 반환
-------------------------------------

function TableBattlePass:getMinLevel(pass_id)
    return self.m_battlePassInfoMap[tostring(pass_id)]['min_level']
end


function TableBattlePass:getMaxLevel(pass_id)
    return self.m_battlePassInfoMap[tostring(pass_id)]['max_level']
end

function TableBattlePass:getMaxExp(pass_id)
    return self.m_battlePassInfoMap[tostring(pass_id)]['max_exp']
end


function TableBattlePass:getExpPerLevel(pass_id)
    return self.m_battlePassInfoMap[tostring(pass_id)]['exp_per_level']
end


function TableBattlePass:getNormalItemInfo(pass_id, index)
    local ITEM_ID = 1
    local ITEM_NUM = 2

    local itemInfo = self.m_battlePassInfoMap[tostring(pass_id)]['normal'][index]['item']
    local strList = seperate(itemInfo, ';')
    
    return tonumber(strList[ITEM_ID]), tonumber(strList[ITEM_NUM])
end


function TableBattlePass:getPremiumItemInfo(pass_id, index)
    local ITEM_ID = 1
    local ITEM_NUM = 2

    local itemInfo = self.m_battlePassInfoMap[tostring(pass_id)]['premium'][index]['item']
    -- TODO (YOUNGJIN) : table_pass_reward 파일 premium item 중에 빈 칸이 있음. 
    -- if itemInfo == '' then itemInfo = '760005;55' end
    local strList = seperate(itemInfo, ';')
    
    return tonumber(strList[ITEM_ID]), tonumber(strList[ITEM_NUM])
end

function TableBattlePass:getLevelFromIndex(pass_id, index)
    return tonumber(self.m_battlePassInfoMap[tostring(pass_id)]['normal'][index]['level'])
end

function TableBattlePass:IsActiveLevel(pass_id)

    local active_level = self.m_battlePassInfoMap[tostring(pass_id)]['active_level']
    local user_level = tonumber(g_userData:get('lv'))

    if(active_level <= user_level) then return true end

    return false
end

function TableBattlePass:IsBattlePassProduct(product_id)
    local result
    for k, v in pairs(self.m_battlePassInfoMap) do
        if tonumber(product_id) == tonumber(k) then 
            return true 
        end
    end
    return false
end

