-- T1 = (기본 능력치 + 레벨 능력치 + 승급 능력치 + 진화 능력치 + 초월 능력치 + 친밀도 능력치)
-- T2 =  (T1 * 룬 multi) + 룬 add
-- T3 = (T2 * 버프 multi ) + 버프 add

USE_NEW_COMBAT_POWER_CALC = false

-------------------------------------
-- class StructIndividualStatus
-- @instance indivisual_status
-------------------------------------
StructIndividualStatus = class({
        m_statusName = 'string',

        m_minBuffMulti = 'number',
        m_maxBuffMulti = 'number',

        ----------------------------------------------------
        -- T1
        -- 캐릭터의 기초 능력치
        m_baseStat = '',

        -- level을 기준으로 상승하는 능력치
        m_lvStat = '',
        m_gradeStat = '',
        m_evolutionStat = '',
        m_eclvStat = '',

        m_roleStat = '',        -- 롤(방어형, 공격형, ...) 능력치
		
		m_reinforceMulti = '',	-- 드래곤 강화 능력치
        m_reinforceStat = '',

        m_friendshipStat = '',  -- 친밀도 능력치
        ----------------------------------------------------


        ----------------------------------------------------
        -- T2
        m_runeMulti = '',       -- 룬 곱연산
        m_runeAdd = '',         -- 룬 합연산

        m_passiveMulti = '',    -- 패시브 곱연산
        m_passiveAdd = '',      -- 패시브 합연산

        m_masteryMulti = '',    -- 특성 곱연산
        m_masteryAdd = '',      -- 특성 합연산

        ----------------------------------------------------

        ----------------------------------------------------
        -- T3
        m_formationMulti = '',  -- 진형 버프
        m_formationAdd = '',

        m_stageMulti = '', -- 스테이지 버프
        m_stageAdd = '',

        m_buffMulti = '',
        m_buffAdd = '',
        ----------------------------------------------------

        m_t1 = '',
        m_bDirtyT1 = '',

        m_t2 = '',
        m_bDirtyT2 = '',

        m_finalStat = '',
        m_bDirtyFinalStat = '',
    })

-------------------------------------
-- function init
-------------------------------------
function StructIndividualStatus:init(status_name)
    self.m_statusName = status_name

    self.m_minBuffMulti = nil
    self.m_maxBuffMulti = nil

    self.m_baseStat = 0

    self.m_lvStat = 0
    self.m_gradeStat = 0
    self.m_evolutionStat = 0
    self.m_eclvStat = 0

    self.m_roleStat = 0

	self.m_reinforceMulti = 0
    self.m_reinforceStat = 0

    self.m_friendshipStat = 0

    self.m_runeMulti = 0
    self.m_runeAdd = 0

    self.m_passiveMulti = 0
    self.m_passiveAdd = 0

    self.m_masteryMulti = 0
    self.m_masteryAdd = 0

    self.m_t1 = 0
    self.m_bDirtyT1 = true

    self.m_t2 = 0
    self.m_bDirtyT2 = true

    self.m_formationMulti = 0
    self.m_formationAdd = 0

    self.m_stageMulti = 0
    self.m_stageAdd = 0

    self.m_buffMulti = 0
    self.m_buffAdd = 0

    self.m_finalStat = 0
    self.m_bDirtyFinalStat = true
end

-------------------------------------
-- function setMinMaxForBuffMulti
-------------------------------------
function StructIndividualStatus:setMinMaxForBuffMulti(min, max)
    self.m_minBuffMulti = min
    self.m_maxBuffMulti = max

    self.m_bDirtyFinalStat = true
end

-------------------------------------
-- function setDirtyT2
-------------------------------------
function StructIndividualStatus:setDirtyT2()
    self.m_bDirtyT2 = true
    self.m_bDirtyFinalStat = true
end

-------------------------------------
-- function setDirtyFinalStat
-------------------------------------
function StructIndividualStatus:setDirtyFinalStat()
    self.m_bDirtyFinalStat = true
end

-------------------------------------
-- function getT1
-------------------------------------
function StructIndividualStatus:getT1()
   if self.m_bDirtyT1 then
    self:calcT1()
   end

   return self.m_t1
end

-------------------------------------
-- function getT2
-------------------------------------
function StructIndividualStatus:getT2(exclude_mastery)
   if self.m_bDirtyT2 then
    self:calcT2(exclude_mastery)
   end

   return self.m_t2
end

-------------------------------------
-- function calcT1
-------------------------------------
function StructIndividualStatus:calcT1()
    -- 기본 능력치 연산 (드래곤 성장)
    local t0 = (self.m_baseStat +
                self.m_lvStat + self.m_gradeStat + self.m_evolutionStat + self.m_eclvStat)

	-- 강화 능력치
	local reinforce_multi = (self.m_reinforceMulti / 100)
    self.m_reinforceStat = (t0 * reinforce_multi)
    
	-- 강화 + 직군 + 친밀도 
	local t1 = t0 + self.m_reinforceStat + self.m_roleStat + self.m_friendshipStat

    self.m_t1 = t1

    self.m_bDirtyT1 = false
end

-------------------------------------
-- function calcT2
-------------------------------------
function StructIndividualStatus:calcT2(exclude_mastery)
    local t1 = self:getT1()

    -- 룬 능력치
    local rune_multi = (self.m_runeMulti / 100)
    
    -- 패시브 능력치
    local passive_multi = (self.m_passiveMulti / 100)

    -- 특성 능력치
    local mastery_multi = exclude_mastery == true and 0 or (self.m_masteryMulti / 100)
    
    local masteryAdd = exclude_mastery == true and 0 or self.m_masteryAdd

    -- 능력치 연산
    local t2 = t1 + (t1 * (rune_multi + passive_multi + mastery_multi)) + self.m_runeAdd + self.m_passiveAdd + masteryAdd

    self.m_t2 = t2

    self.m_bDirtyT2 = false
end

-------------------------------------
-- function getLevelStat
-------------------------------------
function StructIndividualStatus:getLevelStat()
    local t1 = (self.m_baseStat +
                self.m_lvStat + self.m_gradeStat + self.m_evolutionStat + self.m_eclvStat)
    return t1
end

-------------------------------------
-- function getBasicStat
-------------------------------------
function StructIndividualStatus:getBasicStat()
    local t1 = self:getT1()
    return t1
end

-------------------------------------
-- function getFinalStat
-------------------------------------
function StructIndividualStatus:getFinalStat(exclude_mastery)
    if self.m_bDirtyFinalStat then
        self:calcFinalStat(exclude_mastery)
    end

    return self.m_finalStat
end

-------------------------------------
-- function calcFinalStat
-------------------------------------
function StructIndividualStatus:calcFinalStat(exclude_mastery)
    local t2 = self:getT2(exclude_mastery)

    -- 진형 버프
    local formation_multi = self.m_formationMulti / 100

    -- 스테이지 버프
    local stage_multi = self.m_stageMulti / 100

    -- 버프
    local buff_multi = self.m_buffMulti

    do -- 버프 최소 및 최대값 적용
        if (self.m_minBuffMulti) then
            buff_multi = math_max(buff_multi, self.m_minBuffMulti)
        end
        if (self.m_maxBuffMulti) then
            buff_multi = math_min(buff_multi, self.m_maxBuffMulti)
        end
    end

    buff_multi = (buff_multi / 100)

    -- 능력치 연산
    local t3 = t2 + (t2 * (formation_multi + stage_multi + buff_multi)) + self.m_formationAdd + self.m_stageAdd + self.m_buffAdd

    self.m_finalStat = t3

    self.m_bDirtyFinalStat = false
end


-------------------------------------
-- function setBasicStat
-------------------------------------
function StructIndividualStatus:setBasicStat(base, lv, grade, evolution, eclv)
    self.m_baseStat = base

    self.m_lvStat = lv
    self.m_gradeStat = grade
    self.m_evolutionStat = evolution
    self.m_eclvStat = eclv

    self:setDirtyT2()
end

-------------------------------------
-- function setRoleStat
-------------------------------------
function StructIndividualStatus:setRoleStat(role_stat)
    self.m_roleStat = role_stat
    self:setDirtyT2()
end

-------------------------------------
-- function setFriendshipStat
-------------------------------------
function StructIndividualStatus:setFriendshipStat(friendship_stat)
    self.m_friendshipStat = friendship_stat
    self:setDirtyT2()
end

-------------------------------------
-- function setReinforceMulti
-------------------------------------
function StructIndividualStatus:setReinforceMulti(r_rate)
    self.m_reinforceMulti = r_rate
    self:setDirtyT2()
end

-------------------------------------
-- function setRuneMulti
-------------------------------------
function StructIndividualStatus:setRuneMulti(rune_multi)
    self.m_runeMulti = rune_multi
    self:setDirtyT2()
end

-------------------------------------
-- function setRuneAdd
-------------------------------------
function StructIndividualStatus:setRuneAdd(rune_add)
    self.m_runeAdd = rune_add
    self:setDirtyT2()
end

-------------------------------------
-- function addPassiveMulti
-------------------------------------
function StructIndividualStatus:addPassiveMulti(value)
    self.m_passiveMulti = (self.m_passiveMulti + value)
    self:setDirtyT2()
end

-------------------------------------
-- function addPassiveAdd
-------------------------------------
function StructIndividualStatus:addPassiveAdd(value)
    self.m_passiveAdd = (self.m_passiveAdd + value)
    self:setDirtyT2()
end

-------------------------------------
-- function addMasteryMulti
-------------------------------------
function StructIndividualStatus:addMasteryMulti(value)
    self.m_masteryMulti = (self.m_masteryMulti + value)
    self:setDirtyT2()
end

-------------------------------------
-- function addMasteryAdd
-------------------------------------
function StructIndividualStatus:addMasteryAdd(value)
    self.m_masteryAdd = (self.m_masteryAdd + value)
    self:setDirtyT2()
end

-------------------------------------
-- function addFormationMulti
-------------------------------------
function StructIndividualStatus:addFormationMulti(value)
    self.m_formationMulti = (self.m_formationMulti + value)
    self:setDirtyFinalStat()
end

-------------------------------------
-- function addFormationAdd
-------------------------------------
function StructIndividualStatus:addFormationAdd(value)
    self.m_formationAdd = (self.m_formationAdd + value)
    self:setDirtyFinalStat()
end

-------------------------------------
-- function addStageMulti
-------------------------------------
function StructIndividualStatus:addStageMulti(value)
    self.m_stageMulti = (self.m_stageMulti + value)
    self:setDirtyFinalStat()
end

-------------------------------------
-- function addStageAdd
-------------------------------------
function StructIndividualStatus:addStageAdd(value)
    self.m_stageAdd = (self.m_stageAdd + value)
    self:setDirtyFinalStat()
end

-------------------------------------
-- function addBuffMulti
-------------------------------------
function StructIndividualStatus:addBuffMulti(value)
    self.m_buffMulti = (self.m_buffMulti + value)
    self:setDirtyFinalStat()
end

-------------------------------------
-- function addBuffAdd
-------------------------------------
function StructIndividualStatus:addBuffAdd(value)
    self.m_buffAdd = (self.m_buffAdd + value)
    self:setDirtyFinalStat()
end