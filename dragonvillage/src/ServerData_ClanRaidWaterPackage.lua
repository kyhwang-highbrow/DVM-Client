

-- MissionPackage
-- Renewal / Non-Renewal(normal / limit - 신규, 복귀, 기타 등등)
-- 

--------------------------------------------------------------------------
-- class ServerData_ClanRaidWaterPackage
--------------------------------------------------------------------------
ServerData_ClanRaidWaterPackage = class({
    m_serverData = 'ServerData',

    m_packageInfo = 'table',
    m_tableName = 'string',

    m_bDirtyTable = 'boolean',
})

--------------------------------------------------------------------------
-- function init
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:init()
    --self.m_serverData = server_data
    self.m_tableName = 'table_battlepass_clan_water' 
    self.m_packageInfo = {}
    self.m_bDirtyTable = true
end



-- {
--     "active": true,
--     "dmgate_stage_pack_info": { # 보상을 수령한 스테이지
--         "120141": [3011002, 3011001]
--     },
--     "message": "success",
--     "status": 0
-- }
--------------------------------------------------------------------------
-- function request_info
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:request_info(product_id, cb_func, fail_cb)
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        --if ret['active'] then
            local product_info = ret['clan_dungeon_score_pack_info'][tostring(product_id)]
            self:response_info(product_info, product_id)
        --end

        if (cb_func) then
            cb_func(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/clan_dungeon_score_w/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('product_id', product_id)
    ui_network:setParam('dungeon_id', 1)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

--------------------------------------------------------------------------
-- function response_info
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:response_info(product_info, product_id)
    local _product_id = tostring(product_id)

    if self.m_bDirtyTable then
        self:convertPackageTableKey()
        self.m_bDirtyTable = false
    end

    --if next(product_info) ~= nil then
    self.m_packageInfo[_product_id] = product_info
    -- if product_info['active'] == true then
    --     self.m_packageInfo[_product_id] = product_info
    --     self.m_packageInfo[_product_id]['received_list'] = product_info['received_list']

        
    -- end
    --end
end

-- {
--     "dmgate_stage_pack_info": { # 보상을 수령한 스테이지 정보
--         "120141": [3011002, 3011001]
--     },
--     "mail_item_info": [{ # 현재 요청으로 메일로 발송된 아이템 리스트
--             "count": 15000,
--             "from": null,
--             "item_id": 700001,
--             "oids": []
--         }
--     ],
--     "message": "success",
--     "new_mail": true,
--     "status": 0
-- }

--------------------------------------------------------------------------
-- function request_reward
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:request_reward(product_id, dunegon_score, cb_func, fail_cb)
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_reward(ret, product_id)

        if (cb_func) then
            cb_func(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/clan_dungeon_score/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('product_id', product_id)
    ui_network:setParam('dungeon_id', 1)
    ui_network:setParam('score', dunegon_score)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


--------------------------------------------------------------------------
-- function response_reward
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:response_reward(ret, product_id)
    local _product_id = tostring(product_id)


    self.m_packageInfo[_product_id] = ret['clan_dungeon_score_pack_info'][_product_id]
end


--------------------------------------------------------------------------
-- function response_reward
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:getPackageTable(product_id)

    local package_table = TABLE:get(self.m_tableName)

    if (not product_id) then return package_table end

    return package_table[tostring(product_id)]
end

--------------------------------------------------------------------------
-- function convertPackageTableKey
-- @brief convert key from 'package_id' to 'product_id'
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:convertPackageTableKey()
    local package_table = TABLE:get(self.m_tableName)
    local result = {}

    local product_id
    for key, data in pairs(package_table) do
        product_id = tostring(data['product_id'])

        if (not result[product_id]) then result[product_id] = {} end

        table.insert(result[product_id], data)
    end

    local function coroutine_func()
        local co = CoroutineHelper()

        for key, data in pairs(result) do
            co:work()

            self:request_info(product_id, co.NEXT, co.ESCAPE)
            
            if co:waitWork() then return end
        end

        co:close()
    end

    Coroutine(coroutine_func, 'Clan Raid Water Package 코루틴')

    TABLE:replaceTable(self.m_tableName, result)
end

--------------------------------------------------------------------------
-- function checkProductInTable
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:checkProductInTable(product_id)
    if (not product_id) then return false end
    
    local package_table = self:getPackageTable(product_id)
    if package_table then return true end

    return false
end


--------------------------------------------------------------------------
-- function isPackageActive
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:isPackageActive(product_id)
    --if (not self.m_packageInfo[tostring(product_id)]) then return false end
    
    return self.m_packageInfo[tostring(product_id)]['active']
end


--------------------------------------------------------------------------
-- function isRewardReceived
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:isRewardReceived(product_id, stage_id)
    --if (not self.m_packageInfo[tostring(product_id)]) then return false end

    local product_table = self.m_packageInfo[tostring(product_id)]['received_list']

    for key, value in pairs(product_table) do
        if value == stage_id then
            return true
        end
    end

    return false
end


--------------------------------------------------------------------------
-- function getProductIdWithClanDungeonID
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:getProductIdWithClanDungeonID(clan_dungeon_id)
    local data = TABLE:get(self.m_tableName)

    for key, value in pairs(data) do
        for k, v in pairs(value) do
            if tonumber(v['achive_1']) == tonumber(clan_dungeon_id) then
                return v['product_id']
            end
            break
        end
    end

    return nil
end

--------------------------------------------------------------------------
-- function isVisibleAtBattlePassShop
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:isVisibleAtBattlePassShop()
    local package_table = self:getPackageTable()
    local product_id
    local stage_id
    
    if (not g_contentLockData:isContentLock('clan_raid')) then
        for i, v in pairs(package_table) do
            for key, data in pairs(v) do
                product_id = data['product_id']
                if self:isPackageActive(product_id) then
                    stage_id = data['achive_2']
        
                    if (not self:isRewardReceived(product_id, stage_id)) then
                        return true
                    end
                else
                    return true
                end
            end
        end
    else
        return false
    end

    return false
end

--------------------------------------------------------------------------
-- function isNotiVisible
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:isNotiVisible()
    local package_table = self:getPackageTable()
    local product_id
    local stage_id

    if (not g_contentLockData:isContentLock('clan_raid')) then
        for i, v in pairs(package_table) do
            for key, data in pairs(v) do
                product_id = data['product_id']
                if self:isPackageActive(product_id) then
                    stage_id = data['achive_2']
        
                    if (not self:isRewardReceived(product_id, stage_id)) then
                        return true
                    end
                else
                    return true
                end
            end
        end
    end

    return false
end

--------------------------------------------------------------------------
-- function isUnclearedAnyPackage
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:isUnclearedAnyPackage()
    if g_contentLockData:isContentLock('clan_raid') then
        return true
    end

    local package_table = self:getPackageTable()
    local product_id
    local stage_id

    if (not g_contentLockData:isContentLock('clan_raid')) then
        for i, v in pairs(package_table) do
            for key, data in pairs(v) do 
                product_id = data['product_id']
                if self:isPackageActive(product_id) then
                    stage_id = data['achive_2']
        
                    if (not self:isRewardReceived(product_id, stage_id)) then
                        return true
                    end
                else
                    return true
                end
            end
        end
    end
end

--------------------------------------------------------------------------
-- function isPackageVisible
--------------------------------------------------------------------------
function ServerData_ClanRaidWaterPackage:isPackageVisible(product_id)
    if (g_contentLockData:isContentLock('clan_raid')) then 
        return false
    end

    if (not self:isPackageActive(product_id)) then
        return true
    end
    
    local package_table = self:getPackageTable()
    local product_id
    local stage_id
    for i, v in pairs(package_table) do
        for key, data in pairs(v) do 
            product_id = data['product_id']
            if self:isPackageActive(product_id) then
                stage_id = data['achive_2']
    
                if (not self:isRewardReceived(product_id, stage_id)) then
                    return true
                end
            else
                return true
            end
        end
    end

    return false
end

--function ServerData_ClanRaidWaterPackage:getProductIdWithMatched
