local PARENT = TableClass

-------------------------------------
-- class TableBattlePass
-------------------------------------
TableBattlePass = class(PARENT, {
    m_battlePassTable = 'table',
    m_battlePassRewardTable = 'table',

    m_battlePassInfoMap = 'map',
    })

local THIS = TableBattlePass


-------------------------------------
-- function init
-------------------------------------
function TableBattlePass:init()
    self.m_tableName = 'table_battle_pass'
    self.m_battlePassTable = TABLE:get(self.m_tableName)
    self.m_battlePassRewardTable = TABLE:get('table_battle_pass_reward')
end


-------------------------------------
-- function getNormalRewardList
-- pid 받으면 그에 해당하는 리스트를 반환
-------------------------------------
function TableBattlePass:getNormalRewardList(pass_id)
    local resultMap = {}

    if (not self.m_battlePassInfoMap or 
        not self.m_battlePassInfoMap[tostring(pass_id)] or
        not self.m_battlePassInfoMap[tostring(pass_id)]['normal']) then 
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
-- function updateTableMap
-- @brief 전반적인 배틀패스 정보를 업데이트 한다.
-------------------------------------
function TableBattlePass:updateTableMap()
    -- 테이블 정보 그릇 초기화
    self.m_battlePassInfoMap = {}

    -- 패스 상품정보를 받아온다.
    local l_item_list = g_shopDataNew:getProductList('pass')

    if (not self.m_battlePassTable) then return end

    -- 배틀패스 테이블에 있는 상품별 조회를 해서
    -- 각각 보상 테이블에 카테고리별로 넣어주자
    for i, v in ipairs(self.m_battlePassTable) do
        -- pid = 프로덕트 id
        local pid = v['pid']

        -- 상품정보를 받아온다.
        local struct_product = l_item_list[tonumber(pid)]
        
        -- 먼저 상품정보를 맵에 넣고
        if (not self.m_battlePassInfoMap[tostring(pid)]) then
            self.m_battlePassInfoMap[tostring(pid)] = {}
        end

        self.m_battlePassInfoMap[tostring(pid)]["product"] = struct_product

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

        self.m_battlePassInfoMap[tostring(pid)]["normalList"] = normalList
        self.m_battlePassInfoMap[tostring(pid)]["premiumList"] = premiumList
    end
end