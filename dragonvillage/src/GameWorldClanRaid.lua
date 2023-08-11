local PARENT = GameWorldForDoubleTeam

-------------------------------------
-- class GameWorldClanRaid
-------------------------------------
GameWorldClanRaid = class(PARENT, {})
    
-------------------------------------
-- function init
-------------------------------------
function GameWorldClanRaid:init()
end

-------------------------------------
-- function makePassiveStartEffect
-- @brief
-------------------------------------
function GameWorldClanRaid:makePassiveStartEffect(char, str_map)
    local root_node = PARENT.makePassiveStartEffect(self, char, str_map)

    -- 보스의 경우는 충돌영역 위치로 표시
    if (isInstanceOf(char, Monster_ClanRaidBoss)) then
        -- 실시간 위치 동기화
        root_node:scheduleUpdateWithPriorityLua(function(dt)
            local x, y = char:getCenterPos()
            root_node:setPosition(x, y)
        end, 0)
    end
end

-------------------------------------
-- function onExterminateGroup
-- @brief 아군이나 적군 그룹 중 하나가 전멸되었을때 호출되는 함수
-------------------------------------
function GameWorldClanRaid:onExterminateGroup(group_key)
    PARENT.onExterminateGroup(self, group_key)

    if (group_key == PHYS.HERO_TOP or group_key == PHYS.HERO_BOTTOM) then
        -- 한 팀이 전멸해서 공격 그룹이 변경된 경우 특정 패턴은 못하도록 막기 위한 하드코딩
        for i, enemy in ipairs(self:getEnemyList()) do
            enemy:onChangedAttackableGroup()
        end
    end
end

-------------------------------------
-- function bindEnemy
-------------------------------------
function GameWorldClanRaid:bindEnemy(enemy)
    PARENT.bindEnemy(self, enemy)
    
    -- 막타 데미지
    enemy:addListener('clan_boss_final_damage', self.m_gameState)
end

-------------------------------------
-- function removeAllEnemy
-- @brief
-------------------------------------
function GameWorldClanRaid:removeAllEnemy()
    for i, v in pairs(self.m_rightParticipants) do
		--cclog('REMOVE ALL ' .. v:getName())
        if (not v:isDead()) then
            v:doDie()
        end
    end

    for i, v in pairs(self.m_rightNonparticipants) do
        -- GameWorld:updateUnit에서 삭제하도록 하기 위함
        v.m_bPossibleRevive = false
    end
	
    self.m_waveMgr:clearDynamicWave()
end

-------------------------------------
-- function makeHeroDeck
-- @brief
-------------------------------------
function GameWorldClanRaid:makeHeroDeck()
    -- 부모 함수 호출
    -- GameWorldForDoubleTeam:makeHeroDeck에서는 스테이지 버프를(table_stage_data) 셋팅한 상태
    PARENT.makeHeroDeck(self)
    
    -- 유저의 드래곤 덱 리스트
    local l_deck = self:getDragonList()
    
    -- (table_clan_dungseon_buff)로 만든 스테이지 버프 사용
    for i, dragon in pairs(l_deck) do
        -- 스테이지 버프 적용
        self:applyClanRaidStageBonus(dragon)
    end
end

-------------------------------------
-- function applyClanRaidStageBonus
-- @brief
-------------------------------------
function GameWorldClanRaid:applyClanRaidStageBonus(dragon)
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local l_buff = struct_raid:getClanAttrBuffList()

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