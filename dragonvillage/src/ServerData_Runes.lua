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
        if (roid == v['id']) then
            return clone(v)
        end
    end

    return nil
end

-------------------------------------
-- function applyRuneData_list
-- @brief 서버에서 넘어오는 룬 정보 갱신
-------------------------------------
function ServerData_Runes:applyRuneData_list(l_rune_data)
    for i,v in pairs(l_rune_data) do
        self:applyRuneData(t_rune_data)
    end
end

-------------------------------------
-- function applyRuneData
-- @brief 서버에서 넘어오는 룬 정보 갱신
-------------------------------------
function ServerData_Runes:applyRuneData(t_rune_data)
    -- 보유중인 룬에서 t_rune_data정보가 있는지 확인
    local l_runes = self.m_serverData:get('runes')
    local roid = t_rune_data['id']
    local idx = nil
    for i,v in pairs(l_runes) do
        if (roid == v['id']) then
            idx = i
            break
        end
    end

    -- 기존에 있는 룬데이터이면 갱신
    if idx then
        self.m_serverData:applyServerData(t_rune_data, 'runes', idx)
    -- 기존에 없던 룬이면 추가
    else
        self.m_serverData:applyServerData(t_rune_data, 'runes', idx + 1)
    end
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

    local full_name, alphabet_idx = table_rune:getRuneFullName(rid, mopt_1_type, mopt_2_type, rarity)

    local t_rune_infomation = {}
    t_rune_infomation['rid'] = rid
    t_rune_infomation['full_name'] = full_name
    t_rune_infomation['alphabet_idx'] = alphabet_idx

    return t_rune_infomation
end