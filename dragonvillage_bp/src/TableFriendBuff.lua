local PARENT = TableClass

-------------------------------------
-- class TableFriendBuff
-------------------------------------
TableFriendBuff = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableFriendBuff:init()
    self.m_tableName = 'friendbuff'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function makeFriendBuffData
-------------------------------------
function TableFriendBuff:makeFriendBuffData(did, rarity, attr)
    if (self == TableFriendBuff) then
        self = TableFriendBuff()
    end

    local l_add_status = {}
    local l_multiplay_status = {}
    local apply_trim = true
    
    -- did에 해당하는 유니크 버프 정보를 가져옴
    if (self.m_orgTable['rarity'] == tostring(did)) then
        local l_status = self:getSemicolonSeparatedValues(did, 'unique_status', apply_trim)
        local l_action = self:getSemicolonSeparatedValues(did, 'unique_action', apply_trim)
        local l_value = self:getSemicolonSeparatedValues(did, 'unique_value', apply_trim)

        for i, v in ipairs(l_status) do
            local key = v
            local act = l_action[i]
            local value = l_value[i]

            local target_list
            if (act == 'add') then
                target_list = l_add_status
            elseif (act == 'multiply') then
                target_list = l_multiplay_status
            else
                error('act : ' .. act)
            end

            if (not target_list[key]) then
                target_list[key] = 0
            end

            target_list[key] = (target_list[key] + value)
        end
    end

    -- rarity와 attr에 해당하는 버프 정보를 가져옴
    do
        local l_status = self:getSemicolonSeparatedValues(rarity, attr .. '_status', apply_trim)
        local l_action = self:getSemicolonSeparatedValues(rarity, attr .. '_action', apply_trim)
        local l_value = self:getSemicolonSeparatedValues(rarity, attr .. '_value', apply_trim)

        for i, v in ipairs(l_status) do
            local key = v
            local act = l_action[i]
            local value = l_value[i]

            local target_list
            if (act == 'add') then
                target_list = l_add_status
            elseif (act == 'multiply') then
                target_list = l_multiplay_status
            else
                error('act : ' .. act)
            end

            if (not target_list[key]) then
                target_list[key] = 0
            end

            target_list[key] = (target_list[key] + value)
        end
    end

    local t_friend_buff = {}
    t_friend_buff['add_status'] = l_add_status
    t_friend_buff['multiply_status'] = l_multiplay_status
    
    --cclog('TableFriendBuff:makeFriendBuffData = ' .. luadump(t_friend_buff))

    return t_friend_buff
end