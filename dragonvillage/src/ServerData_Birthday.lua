-------------------------------------
-- class ServerData_Birthday
-------------------------------------
ServerData_Birthday = class({
        m_serverData = 'ServerData',

        m_birthdayTable = 'serverDataTable',
        m_birthdayInfoMap = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Birthday:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function organize_birthdayTable
-------------------------------------
function ServerData_Birthday:organize_birthdayTable(birthday_table)
    self.m_birthdayTable = birthday_table

    self.m_birthdayInfoMap = {}
    for i=1, 12 do
        self.m_birthdayInfoMap[i] = {}
    end

    for i,v in ipairs(birthday_table) do
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