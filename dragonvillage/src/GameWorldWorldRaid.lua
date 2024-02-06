local PARENT = GameWorld

-------------------------------------
-- class GameWorldWorldRaid
-------------------------------------
GameWorldWorldRaid = class(PARENT, {
    })

-------------------------------------
--- @function makeHeroDeck
--- @brief 덱 만들고 버프 부여하기
-------------------------------------
function GameWorldWorldRaid:makeHeroDeck()
    -- 부모 함수 호출
    PARENT.makeHeroDeck(self)

    -- 유저의 드래곤 덱 리스트
    local l_deck = self:getDragonList()
    for i, dragon in pairs(l_deck) do
        -- 스테이지 버프 적용
        self:applyWorldRaidBonus(dragon)
    end
end

-------------------------------------
--- @function applyWorldRaidBonus
--- @brief 스테이지 보너스 등록
-------------------------------------
function GameWorldWorldRaid:applyWorldRaidBonus(dragon)
    local world_raid_id = g_worldRaidData:getWorldRaidId()
    local l_buff = TableWorldRaidInfo:getInstance():getWorldRaidBuffAll(world_raid_id)

    for i, v in ipairs(l_buff) do
        local condition_type = v['condition_type']
        local condition_value = v['condition_value']

        if (condition_type == 'did' or condition_type == 'mid') then
            condition_value = tonumber(condition_value)
        end
        local t_char = dragon:getCharTable()
        if (v['condition_type'] == 'all' or condition_value == t_char[condition_type]) then
            local buff_type = v['buff_type']
            local buff_value = v['buff_value']
            local t_option = TableOption():get(buff_type)

            if (t_option) then
                local status_type = t_option['status']
                if (status_type) then
                    if (t_option['action'] == 'multi') then
                        dragon.m_statusCalc:addStageMulti(status_type, buff_value)                        
                    elseif (t_option['action'] == 'add') then
                        dragon.m_statusCalc:addStageAdd(status_type, buff_value)                        
                    end
                end
            end
        end
    end
end
