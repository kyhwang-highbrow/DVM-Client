-------------------------------------
-- class GameUnitGroup
-------------------------------------
GameUnitGroup = class({
        m_world = 'GameWorld',
        m_mana = 'GameMana',
        m_auto = 'GameAuto',
        m_formationMgr = 'FormationMgr',

        m_bLeftFormation = 'boolean',
        m_groupKey = 'string',
        m_opponentGroupKey = 'string',
        m_lAttackableGroupKey = 'table',
        
        m_lSurvivor = 'table',  -- 전투에 참여중인 유닛
        m_lDead     = 'table',  -- 죽은 유닛(부활 가능한 대상만)

        m_leaderDragon = 'Dragon',  -- 그룹 내의 리더 드래곤
     })

-------------------------------------
-- function init
-------------------------------------
function GameUnitGroup:init(world, group_key)
    self.m_world = world

    local bLeftFormation = table.find(self.m_world:getHeroGroups(), group_key) ~= nil

    self.m_formationMgr = FormationMgr(bLeftFormation)

    self.m_bLeftFormation = bLeftFormation
    self.m_groupKey = group_key

    if (self.m_bLeftFormation) then
        self.m_opponentGroupKey = string.gsub(group_key, 'hero', 'enemy')
    else
        self.m_opponentGroupKey = string.gsub(group_key, 'enemy', 'hero')
    end
    
    self.m_lAttackableGroupKey = {}
    self.m_lSurvivor = {}
    self.m_lDead = {}
end

-------------------------------------
-- function update
-------------------------------------
function GameUnitGroup:update(dt)
    if (self.m_mana) then
        self.m_mana:update(dt)
    end

    if (self.m_auto) then
        self.m_auto:update(dt)
    end
end

-------------------------------------
-- function createMana
-------------------------------------
function GameUnitGroup:createMana(ui)
    self.m_mana = GameMana(self.m_world, self.m_groupKey)

    if (ui) then
        self.m_mana:bindUI(ui)
    end

    return self.m_mana
end

-------------------------------------
-- function createAuto
-------------------------------------
function GameUnitGroup:createAuto(ui)
    if (self.m_bLeftFormation) then
        self.m_auto = GameAuto_Hero(self.m_world, self.m_mana, ui)

        -- ui가 있을 경우 자동모드 온오프 이벤트시 리스너로 등록
        if (ui) then
            self.m_world:addListener('auto_start', self.m_auto)
            self.m_world:addListener('auto_end', self.m_auto)
			self.m_world:addListener('farming_changed', self.m_auto)
            self.m_world:addListener('auto_skill_unlock', self.m_auto)
        end
    else
        self.m_auto = GameAuto_Enemy(self.m_world, self.m_mana)
    end

    return self.m_auto
end

-------------------------------------
-- function joinUnit
-------------------------------------
function GameUnitGroup:joinUnit(unit)
    -- formationMgr에 등록
    self.m_formationMgr:setChangePosCallback(unit)

    -- 이벤트
    if (unit:isDragon()) then
        if (self.m_mana) then
            unit:addListener('dragon_active_skill', self.m_mana)
        end
        if (self.m_auto) then
            if (self.m_bLeftFormation) then
                unit:addListener('hero_active_skill', self.m_auto)
            else
                unit:addListener('enemy_active_skill', self.m_auto)
            end
        end
    end
end

-------------------------------------
-- function addSurvivor
-------------------------------------
function GameUnitGroup:addSurvivor(unit)
    local idx = table.find(self.m_lSurvivor, unit)
    if (not idx) then
        table.insert(self.m_lSurvivor, unit)
    end

    idx = table.find(self.m_lDead, unit)
    if (idx) then
        table.remove(self.m_lDead, idx)
    end
end

-------------------------------------
-- function removeSurvivor
-------------------------------------
function GameUnitGroup:removeSurvivor(unit)
    local idx = table.find(self.m_lSurvivor, unit)
    if (idx) then
        table.remove(self.m_lSurvivor, idx)
    end

    idx = table.find(self.m_lDead, unit)
    if (unit.m_bPossibleRevive) then
        if (not idx) then
            table.insert(self.m_lDead, unit)
        end
    else
        if (idx) then
            table.remove(self.m_lDead, idx)
        end
    end
end


-------------------------------------
-- function getGroupKey
-------------------------------------
function GameUnitGroup:getGroupKey()
    return self.m_groupKey
end

-------------------------------------
-- function getOpponentGroupKey
-- @brief 대응하는 상대측의 phys_group값을 리턴
-------------------------------------
function GameUnitGroup:getOpponentGroupKey()
    return self.m_opponentGroupKey
end

-------------------------------------
-- function getMana
-------------------------------------
function GameUnitGroup:getMana()
    return self.m_mana
end

-------------------------------------
-- function getAuto
-------------------------------------
function GameUnitGroup:getAuto()
    return self.m_auto
end

-------------------------------------
-- function getFormationMgr
-------------------------------------
function GameUnitGroup:getFormationMgr()
    return self.m_formationMgr
end

-------------------------------------
-- function getAttackbleGroupKeys
-------------------------------------
function GameUnitGroup:getAttackbleGroupKeys()
    return self.m_lAttackableGroupKey
end

-------------------------------------
-- function setAttackbleGroupKeys
-------------------------------------
function GameUnitGroup:setAttackbleGroupKeys(l_group_key)
    self.m_lAttackableGroupKey = l_group_key
end

-------------------------------------
-- function getSurvivorList
-------------------------------------
function GameUnitGroup:getSurvivorList()
    return self.m_lSurvivor
end

-------------------------------------
-- function getSurvivorCount
-------------------------------------
function GameUnitGroup:getSurvivorCount()
    return #self.m_lSurvivor
end

-------------------------------------
-- function getDeadList
-------------------------------------
function GameUnitGroup:getDeadList()
    return self.m_lDead
end

-------------------------------------
-- function getAllList
-------------------------------------
function GameUnitGroup:getAllList()
    local l_ret = table.merge(self.m_lSurvivor, self.m_lDead)

    return l_ret
end

-------------------------------------
-- function getLeader
-------------------------------------
function GameUnitGroup:getLeader()
    return self.m_leaderDragon
end

-------------------------------------
-- function setLeader
-------------------------------------
function GameUnitGroup:setLeader(leader)
    self.m_leaderDragon = leader
end

-------------------------------------
-- function prepareAuto
-------------------------------------
function GameUnitGroup:prepareAuto()
    if (self.m_auto) then
        self.m_auto:prepare(self.m_lSurvivor)
    end
end

-------------------------------------
-- function startAuto
-------------------------------------
function GameUnitGroup:startAuto()
    if (self.m_auto) then
        self.m_auto:onStart()
    end
end

-------------------------------------
-- function doSkill_leader
-------------------------------------
function GameUnitGroup:doSkill_leader()
    if (self.m_leaderDragon) then
        self.m_leaderDragon:doSkill_leader()
    end
end