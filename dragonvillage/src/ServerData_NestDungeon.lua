-------------------------------------
-- class ServerData_NestDungeon
-------------------------------------
ServerData_NestDungeon = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_NestDungeon:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function applyNestDungeonInfo
-------------------------------------
function ServerData_NestDungeon:applyNestDungeonInfo(data)
    self.m_serverData:applyServerData(data, 'nest_info')
end

-------------------------------------
-- function getNestDungeonInfo
-- @brief 네스트 던전 리스트 항목 얻어옴
--        거대용, 악몽, 거목
-------------------------------------
function ServerData_NestDungeon:getNestDungeonInfo()
    local l_nest_info = self.m_serverData:getRef('nest_info')

    local l_ret = {}
    
    for i,v in ipairs(l_nest_info) do
        if (v['mode'] == 2) and (v['sub_mode'] ~= 1) then
            -- 악몽(2)에서는 서브모드가 1인 리스트만 포함 skip
        else
            table.insert(l_ret, clone(v))
        end
    end

    -- 오픈되고 mode_id가 빠른 순으로 정렬
    local function sort_func(a, b) 
        if a['is_open'] > b['is_open'] then
            return true
        elseif a['is_open'] < b['is_open'] then
            return false
        end

        return a['mode_id'] < b['mode_id']
    end

    table.sort(l_ret, sort_func)

    return l_ret
end

-------------------------------------
-- function requestNestDungeonInfo
-------------------------------------
function ServerData_NestDungeon:requestNestDungeonInfo(cb_func)
    local uid = g_userData:get('uid')

    local function success_cb(ret)

        if ret['nest_info'] then
            self:applyNestDungeonInfo(ret['nest_info'])
        end

        if cb_func then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/nest/info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function getNestDungeonInfo_stageList
-- @brief 네스트 
--        거대용, 악몽, 거목
-------------------------------------
function ServerData_NestDungeon:getNestDungeonInfo_stageList(nest_dungeon_id)
    local table_drop = TableDrop()

    local function condition_func(t_table)
        local stage_id = t_table['stage']

        local nest_dungeon_id = nest_dungeon_id

        -- 악몽던전은 별도 처리
        if (nest_dungeon_id == 22100) then
            stage_id = stage_id - (stage_id % 1000)
            nest_dungeon_id = 22000
        else
            stage_id = stage_id - (stage_id % 100)
        end
        

        if (stage_id == nest_dungeon_id) then
            return true
        else
            return false
        end
    end

    local l_stage_list = table_drop:filterList_condition(condition_func)

    local function sort_func(a, b)
        return a['stage'] < b['stage']
    end

    table.sort(l_stage_list, sort_func)

    return l_stage_list
end

-------------------------------------
-- function parseNestDungeonID
-- @brief 네스트 
--        거대용, 악몽, 거목
-------------------------------------
function ServerData_NestDungeon:parseNestDungeonID(stage_id)
    -- 21101
    -- 2xxxx 모드 구분 (네스트 던전 모드)
    --  1xxx 네스트 던전 구분 (거대용, 고목, 악몽)
    --   1xx 세부 모드 (속성 or role)
    --    01 티어 (통상적으로 1~10)

    local t_dungeon_id_info = {}
    t_dungeon_id_info['stage_mode'] = getDigit(stage_id, 10000, 1)
    t_dungeon_id_info['dungeon_mode'] = getDigit(stage_id, 1000, 1)
    t_dungeon_id_info['detail_mode'] = getDigit(stage_id, 100, 1)
    t_dungeon_id_info['tier'] = getDigit(stage_id, 1, 2)

    return t_dungeon_id_info
end

-- 네스트 던전 리스트
-- 네스트 던전 스테이지 리스트