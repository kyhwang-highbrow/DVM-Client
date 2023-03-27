-------------------------------------
-- class ServerData_StoryDungeonEvent
-------------------------------------
ServerData_StoryDungeonEvent = class({
    m_serverData = 'ServerData',
    m_cachedStageIdListMap = 'table',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_StoryDungeonEvent:init(server_data)
    self.m_serverData = server_data
    self.m_cachedStageIdListMap = {}    
end


-------------------------------------
-- function getStoryDungeonSeason
-------------------------------------
function ServerData_StoryDungeonEvent:getStoryDungeonSeason()
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
-- function isOpenStage
-------------------------------------
function ServerData_StoryDungeonEvent:isOpenStage(stage_id, _season_id)
    local season_id = _season_id or self:getStoryDungeonSeason()
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
    self.m_serverData:applyServerData(t_data or {}, 'story_dungeon_stage_info')
end

-------------------------------------
-- function requestStoryDungeonInfo
-- @return ui_network
-------------------------------------
function ServerData_StoryDungeonEvent:requestStoryDungeonInfo(cb_func, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if ret['story_dungeon_stage_info'] ~= nil then
            self:applyStoryDungeonSeasonInfo(ret['story_dungeon_stage_info'])
        end

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