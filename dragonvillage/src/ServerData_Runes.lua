-------------------------------------
-- class ServerData_Runes
-------------------------------------
ServerData_Runes = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Runes:init(server_data)
    self.m_serverData = server_data
end


-------------------------------------
-- function getRuneData
-------------------------------------
function ServerData_Runes:getRuneData(roid)
    local l_runes = self.m_serverData:get('runes')

    for _,v in pairs(l_runes) do
        cclog('check ' .. roid .. ' ' .. v['id'])
        if (roid == v['id']) then
            return clone(v)
        end
    end

    return nil
end

-------------------------------------
-- function getRuneInfomation
-- @brief rune object id로 룬의 정보 분석
-------------------------------------
function ServerData_Runes:getRuneInfomation(roid)
    local t_rune_data = self:getRuneData(roid)

    local table_rune = TableRune()

    local rid = t_rune_data['rid']
    local mopt_1_type = t_rune_data['mopt']['1']
    local mopt_2_type = t_rune_data['mopt']['2']
    local rarity = t_rune_data['rarity']

    local full_name = table_rune:getRuneFullName(rid, mopt_1_type, mopt_2_type, rarity)

    local t_rune_infomation = {}
    t_rune_infomation['full_name'] = full_name

    return t_rune_infomation
end