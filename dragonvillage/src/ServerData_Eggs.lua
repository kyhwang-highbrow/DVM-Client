-------------------------------------
-- class ServerData_Eggs
-------------------------------------
ServerData_Eggs = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Eggs:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function request_incubate
-- @breif
-------------------------------------
function ServerData_Eggs:request_incubate(egg_id, cnt, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    local cnt = cnt or 1

    -- 성공 콜백
    local function success_cb(ret)

        -- 드래곤들 추가
        g_dragonsData:applyDragonData_list(ret['added_dragons'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/incubate')
    ui_network:setParam('uid', uid)
    ui_network:setParam('eggid', egg_id)
    ui_network:setParam('cnt', cnt)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getEggCount
-- @brief 보유중인 알 갯수 리턴
-------------------------------------
function ServerData_Eggs:getEggCount(egg_id)
    local egg_id = tostring(egg_id)
    local count = self.m_serverData:get('user', 'eggs', egg_id) or 0
    return count
end

-------------------------------------
-- function getEggListForUI
-- @brief UI에서 사용될 보유중인 알 리스트 리턴
-------------------------------------
function ServerData_Eggs:getEggListForUI()
    local egg_list = self.m_serverData:getRef('user', 'eggs')
    
    local t_ret = {}

    -- 리스트 생성
    for i,v in pairs(egg_list) do
        local egg_id = i
        local count = v

        -- 일단 모두 개별로 처리 (중급, 일반 알은 10개 묶음 가능)
        for _i=1, count do
            table.insert(t_ret, {['egg_id']=egg_id, count=1})
        end
    end


    -- 정렬
    local function sort_func(a, b)
        -- egg_id가 낮은게 우선순위가 높음
        if (a['egg_id'] ~= b['egg_id']) then
            return a['egg_id'] < b['egg_id']
        else
            -- count가 높은게 우선순위가 높음
            return a['count'] > b['count']
        end
    end
    table.sort(t_ret, sort_func)


    return t_ret
end