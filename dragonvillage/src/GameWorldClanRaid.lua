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
