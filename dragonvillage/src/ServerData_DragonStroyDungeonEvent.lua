-------------------------------------
-- class ServerData_DragonStroyDungeonEvent
-------------------------------------
ServerData_DragonStroyDungeonEvent = class({
    m_serverData = 'ServerData',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonStroyDungeonEvent:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function getNewDragonEventDungeonStageIdList
-------------------------------------
function ServerData_DragonStroyDungeonEvent:getNewDragonEventDungeonStageIdList()
    -- 시나리오 작업할 수 있도록 일단 하드코딩
    return {
        4230101, 
        4230102, 
        4230103, 
        4230104, 
        4230105, 
        4230106, 
        4230107, 
        4230108, 
        4230109, 
        4230110,
    }
end

-------------------------------------
-- function isOpenStage
-- @brief
-------------------------------------
function ServerData_DragonStroyDungeonEvent:isOpenStage(stage_id)
    local prev_stage_id = self:getPrevStageID(stage_id)

    if (not prev_stage_id) then
        return true
    else
        local t_dungeon_id_info = self:getNestDungeonStageClearInfo(prev_stage_id)
        local is_open = (0 < t_dungeon_id_info['clear_cnt'])
        return is_open
    end
end

-------------------------------------
-- function getPrevStageID
-- @brief
-------------------------------------
function ServerData_DragonStroyDungeonEvent:getPrevStageID(stage_id)
    local t_dungeon_id_info = self:parseNestDungeonID(stage_id)
    
    if (t_dungeon_id_info['tier'] <= 1) then
        return nil
    else
        return (stage_id - 1)
    end
end

-------------------------------------
-- function getNestDungeonStageClearInfo
-- @brief
-------------------------------------
function ServerData_DragonStroyDungeonEvent:getNestDungeonStageClearInfo(stage_id)
    local t_stage_clear_info = self:getNestDungeonStageClearInfoRef(stage_id)
    return clone(t_stage_clear_info)
end

-------------------------------------
-- function getNestDungeonStageClearInfoRef
-- @brief
-------------------------------------
function ServerData_DragonStroyDungeonEvent:getNestDungeonStageClearInfoRef(stage_id)
    local t_stage_clear_info = self.m_serverData:getRef('nest_dungeon_stage_list', tostring(stage_id))

    if (not t_stage_clear_info) then
        t_stage_clear_info = {}
        t_stage_clear_info['clear_cnt'] = 0
        self.m_serverData:applyServerData(t_stage_clear_info, 'nest_dungeon_stage_list', tostring(stage_id))
    end

    return t_stage_clear_info
end

-------------------------------------
-- function applyNestDungeonStageList
-- @brief 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_DragonStroyDungeonEvent:applyNestDungeonStageList(data)

    -- 서버에서 줄여진 key명칭을 사용
    for i,v in pairs(data) do
        if v['cl_cnt'] then
            v['clear_cnt'] = v['cl_cnt']
        end
    end

    self.m_serverData:applyServerData(data, 'nest_dungeon_stage_list')
end

-------------------------------------
-- function requestNestDungeonInfo
-- @brief 서버로부터 네스트던전 open정보를 받아옴
-- @return ui_network
-------------------------------------
function ServerData_DragonStroyDungeonEvent:requestNestDungeonInfo(cb_func, fail_cb)
    if (not self.m_bDirtyNestDungeonInfo) then
        if cb_func then
            cb_func()
        end
        return nil
    end

    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if ret['nest_info'] then
            -- 황금던전은 나중에 다시 들어갈 것이 자명함으로 클라에서 처리
            do
                local remove_idx
                for i, v in pairs(ret['nest_info']) do
                    if (v['mode_id'] == 1240000) then
                        remove_idx = i
                    end
                end
                if (remove_idx) then
                    table.remove(ret['nest_info'], remove_idx)
                end
            end

            self:applyNestDungeonInfo(ret['nest_info'])
        end

        if cb_func then
            cb_func(ret)
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/nest/info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()

    return ui_network
end