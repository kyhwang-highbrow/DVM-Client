-------------------------------------
-- class ServerData_Birthday
-------------------------------------
ServerData_Birthday = class({
        m_serverData = 'ServerData',

        m_birthdayInfoMap = '',
        m_todayBirthdayList = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Birthday:init(server_data)
    self.m_serverData = server_data
    self:organize_birthdayTable()
end

-------------------------------------
-- function organize_birthdayTable
-------------------------------------
function ServerData_Birthday:organize_birthdayTable()
    local birthday_table = TableDragonType():cloneOrgTable()

    self.m_birthdayInfoMap = {}
    for i=1, 12 do
        self.m_birthdayInfoMap[i] = {}
    end

    for i,v in pairs(birthday_table) do
        local month = v['month']
        local day = v['day']

        local t_month = self.m_birthdayInfoMap[month]
        if (not t_month[day]) then
            t_month[day] = {}
        end

        table.insert(t_month[day], v)
    end
end

-------------------------------------
-- function getBirthdayInfo
-------------------------------------
function ServerData_Birthday:getBirthdayInfo(month, day)
    local t_month = self.m_birthdayInfoMap[month]

    if (not t_month[day]) then
        return {}
    else
        return t_month[day]
    end
end

-------------------------------------
-- function organize_todayBirthdayList
-------------------------------------
function ServerData_Birthday:organize_todayBirthdayList(birthday)
    self.m_todayBirthdayList = birthday or {}
end

-------------------------------------
-- function getTodayBirthIDList
-------------------------------------
function ServerData_Birthday:getTodayBirthIDList()
    return self.m_todayBirthdayList
end

-------------------------------------
-- function hasBirthdayReward
-------------------------------------
function ServerData_Birthday:hasBirthdayReward()
    local birthday_list = self:getTodayBirthIDList()

    local t_ret = {}

    for dragon_type,v in pairs(birthday_list) do

        -- 보상을 받지 않은 드래곤이고 도감에 드래곤 타입이 등록된 경우에만 추가
        if (v == false) and g_bookData:isExistDragonType(dragon_type) then
            table.insert(t_ret, dragon_type)
        end
    end

    return (#t_ret > 0), t_ret
end

-------------------------------------
-- function request_birthdayReward
-------------------------------------
function ServerData_Birthday:request_birthdayReward(dragon_type, itemid, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        -- 아이템 수령
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 받은 보상은 false 처리
        self.m_todayBirthdayList[dragon_type] = true

        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/birthday/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', dragon_type)
    ui_network:setParam('itemid', itemid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end