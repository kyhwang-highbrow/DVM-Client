-------------------------------------
-- class ServerData_DragonSummon
-------------------------------------
ServerData_DragonSummon = class({
        m_serverData = 'ServerData',

        m_dragonSummonTable = 'table', -- 서버로부터 소환 리스트를 받아옴
        m_mileage = 'number', -- 마일리지 보유량
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonSummon:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function request_dragonSummonInfo
-------------------------------------
function ServerData_DragonSummon:request_dragonSummonInfo(finish_cb)

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:organizeData(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function organizeData
-------------------------------------
function ServerData_DragonSummon:organizeData(ret)
    self.m_mileage = ret['mileage']
    self.m_dragonSummonTable = ret['dragon_summon_table']
end


-------------------------------------
-- function openDragonSummon
-------------------------------------
function ServerData_DragonSummon:openDragonSummon()
    local function finish_cb()
        UI_DragonSummon()
    end

    self:request_dragonSummonInfo(finish_cb)
end

-------------------------------------
-- function getDisplaySummonList
-------------------------------------
function ServerData_DragonSummon:getDisplaySummonList()
   local l_list = {}
   
   local server_time = Timer:getServerTime()

   for i,v in pairs(self.m_dragonSummonTable) do
        local start_date = Timer:strToTimeStamp(v['start_date'])
        local end_date = Timer:strToTimeStamp(v['end_date'])

        -- 판매가 시작되지 않은상품
        if (server_time < start_date) then
            break
        end

        -- 판매가 종료된 상품
        if (end_date < server_time) then
            break
        end

         -- 할인 이벤트 확인
        v['disc_event_active'] = false
        if (v['disc_start_date'] ~= '') and (v['disc_end_date'] ~= '') then
            local disc_start_date = Timer:strToTimeStamp(v['disc_start_date'])
            local disc_end_date = Timer:strToTimeStamp(v['disc_end_date'])

            -- 할인 이벤트 중
            if (disc_start_date <= server_time) and (server_time <= disc_end_date) then
                v['disc_event_active'] = true
            end
        end

        l_list[v['dsmid']] = clone(v)
   end

   return l_list
end