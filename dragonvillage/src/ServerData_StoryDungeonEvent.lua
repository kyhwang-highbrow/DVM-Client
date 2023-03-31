-------------------------------------
-- class ServerData_StoryDungeonEvent
-------------------------------------
ServerData_StoryDungeonEvent = class({
    m_serverData = 'ServerData',
    m_cachedStageIdListMap = 'table',
    m_ceilingInfo = 'table',
    m_ceilingMax = 'number',
    m_isAutomaticFarewell = 'boolean',
    m_isItemReplaced = 'boolean',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_StoryDungeonEvent:init(server_data)
    self.m_serverData = server_data
    self.m_cachedStageIdListMap = {}    
    self.m_isAutomaticFarewell = false
    self.m_ceilingInfo = {}
    self.m_ceilingMax = 100
    self.m_isItemReplaced = false
end

-------------------------------------
-- function getStoryDungeonSeasonId
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonSeasonId()
    local t_stage_clear_info = self.m_serverData:getRef('story_dungeon_stage_info') or {}
    if t_stage_clear_info ~= nil then
        for key, v in pairs(t_stage_clear_info) do
            return key
        end
    end

    return nil
end

-------------------------------------
-- function getStoryDungeonStageIdList
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonStageIdList(season_id)
    if self.m_cachedStageIdListMap[season_id] ~= nil then
        return self.m_cachedStageIdListMap[season_id]
    end

    local t_season_info = self:getStoryDungeonSeasonInfo(season_id)
    local t_clear_info = t_season_info['stage_play_count']
    local list = {}

    if t_clear_info == nil then
        return {}
    end

    for stage_id, _ in pairs(t_clear_info) do
        table.insert(list, tonumber(stage_id))
    end

    table.sort(list, function (a, b) 
        return a < b
    end)

    self.m_cachedStageIdListMap[season_id] = list
    return list
end

-------------------------------------
-- function isStoryDungeonEventDoing
-------------------------------------
function ServerData_StoryDungeonEvent:isStoryDungeonEventDoing()
    return self:getStoryDungeonSeasonId() ~= nil    
end

-------------------------------------
-- function isOpenStage
-------------------------------------
function ServerData_StoryDungeonEvent:isOpenStage(stage_id, _season_id)
    local season_id = _season_id or self:getStoryDungeonSeasonId()
    local prev_stage_id = stage_id - 1

    if (prev_stage_id % 10 == 0) then
        return true
    else
        local clear_count = self:getStoryDungeonStageClearCount(season_id, prev_stage_id)
        local is_open = (0 < clear_count)
        return is_open
    end
end

-------------------------------------
-- function getStoryDungeonStagePlayCount
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonStagePlayCount(season_id, stage_id)
    local t_season_info = self:getStoryDungeonSeasonInfo(season_id)
    local t_clear_info = t_season_info['stage_play_count']

    if t_clear_info == nil then
        return 0
    end

    local clear_count = t_clear_info[tostring(stage_id)]
    return clear_count
end

-------------------------------------
-- function getStoryDungeonStageClearCount
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonStageClearCount(season_id, stage_id)
    local t_season_info = self:getStoryDungeonSeasonInfo(season_id)
    local t_clear_info = t_season_info['stage_play_count']

    if t_clear_info == nil then
        return 0
    end

    local clear_count = t_clear_info[tostring(stage_id)]
    return clear_count
end

-------------------------------------
-- function getStoryDungeonSeasonInfo
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonSeasonInfo(season_id)
    local t_stage_clear_info = self.m_serverData:getRef('story_dungeon_stage_info', season_id)
    return t_stage_clear_info
end

-------------------------------------
-- function applyStoryDungeonSeasonInfo
-- @brief 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_StoryDungeonEvent:applyStoryDungeonSeasonInfo(t_data)
    if t_data['story_dungeon_stage_info'] ~= nil then
        self.m_serverData:applyServerData(t_data['story_dungeon_stage_info'] or {}, 'story_dungeon_stage_info')
    end
end

-------------------------------------
-- function applyStoryDungeonSeasonGachaCeilCount
-- @brief 서버에서 전달받은 천장 값
-------------------------------------
function ServerData_StoryDungeonEvent:applyStoryDungeonSeasonGachaCeilCount(t_data)
    if t_data['story_dungeon_ceiling_count'] ~= nil then
        self.m_serverData:applyServerData(t_data['story_dungeon_ceiling_count'] or 0, 'story_dungeon_ceiling_count')
    end
end

-------------------------------------
-- function update_hatcheryInfo
-- @breif 천장 정보 갱신
-------------------------------------
function ServerData_StoryDungeonEvent:applyPickupCeilingInfo(ret)
    local summon_ceiling_info = ret['summon_ceiling_info']

    if summon_ceiling_info then
        self.m_ceilingInfo = summon_ceiling_info['ceiling_info']
        self.m_ceilingMax = summon_ceiling_info['ceiling_max']
    end
end

-------------------------------------
-- function getStoryDungeonSeasonGachaCeilCount
-- @brief 서버에서 전달받은 천장 값
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonSeasonGachaCeilCount()
    local ceil_count = self.m_serverData:get('story_dungeon_ceiling_count') or 0
    return ceil_count
end

-------------------------------------
-- function getStoryDungeonSeasonTokenItemType
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonSeasonTokenItemType()
    local season_id = self:getStoryDungeonSeasonId()

    if season_id == nil then
        return 'token_event_origingoddragon'
    end

    local season_code = TableStoryDungeonEvent:getStoryDungeonSeasonCode(season_id)
    return string.format('token_event_%s', season_code)
end

-------------------------------------
-- function getStoryDungeonSeasonTicketItemType
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonSeasonTicketItemType()
    local season_id = self:getStoryDungeonSeasonId()

    if season_id == nil then
        return 'ticket_event_origingoddragon'
    end

    local season_code = TableStoryDungeonEvent:getStoryDungeonSeasonCode(season_id)
    return string.format('ticket_event_%s', season_code)
end

-------------------------------------
-- function makeAddedDragonTable
-- @breif
-------------------------------------
function ServerData_StoryDungeonEvent:makeAddedDragonTable(org_list, is_bundle)
    local result = {}
    
    if (not self.m_isAutomaticFarewell) or (not is_bundle) then return org_list end

    for key, value in pairs(org_list) do
        if (value['grade'] > 3) then
            result[key] = value
        end
    end

    return result
end


-------------------------------------
-- function replaceStoryDungeonRelatedItems
-- @brief 스토리 던전 관련 아이템을 시즌별로 다르게 보이도록 처리
-- 앱 구동 후 info 받고 한번만 처리
-------------------------------------
function ServerData_StoryDungeonEvent:replaceStoryDungeonRelatedItems()
    if self.m_isItemReplaced == true then
        return
    end

    local season_id = self:getStoryDungeonSeasonId()
    local l_replace_id_list = {}
    table.insert(l_replace_id_list, TableStoryDungeonEvent:getStoryDungeonEventTicketReplaceId(season_id))
    table.insert(l_replace_id_list, TableStoryDungeonEvent:getStoryDungeonEventTokenReplaceId(season_id))
    TableItem:replaceDisplayInfo(l_replace_id_list)
end

-------------------------------------
-- function requestStoryDungeonInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_StoryDungeonEvent:requestStoryDungeonInfo(cb_func, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        -- 스테이지 정보
        self:applyStoryDungeonSeasonInfo(ret)
        
        -- 시즌 천장 정보
        self:applyStoryDungeonSeasonGachaCeilCount(ret)

        -- 스토리 던전 관련 아이템을 시즌별로 다르게 보이도록 처리
        self:replaceStoryDungeonRelatedItems()
        

        if cb_func ~= nil then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/story_dungeon/info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function requestStoryDungeonGacha
-- @brief 소환하기
-------------------------------------
function ServerData_StoryDungeonEvent:requestStoryDungeonGacha(season_id, draw_cnt, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        -- cash(캐시) / summon_dragon_ticket(드래곤 소환권) 갱신
        g_serverData:networkCommonRespone(ret)
--[[         -- 추가된 마일리지
        local after_mileage = g_userData:get('mileage')
        local added_mileage = (after_mileage - prev_mileage)
        ret['added_mileage'] = added_mileage ]]
        
        -- 드래곤들 추가
        local add_dragon_list = self:makeAddedDragonTable(ret['added_dragons'], false)
        g_dragonsData:applyDragonData_list(add_dragon_list)

        -- 슬라임들 추가
        --g_slimesData:applySlimeData_list(ret['added_slimes'])

        -- 신규 드래곤 new 뱃지 정보 저장
        g_highlightData:saveNewDoidMap()

        -- 시즌 천장 정보
        self:applyStoryDungeonSeasonGachaCeilCount(ret)

        --드래곤 획득 패키지 정보 갱신
        g_getDragonPackage:applyPackageList(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon/story_dungeon')
    ui_network:setParam('uid', uid)
    ui_network:setParam('sals', false)
    ui_network:setParam('season_id', season_id)
    ui_network:setParam('draw_cnt', draw_cnt)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end