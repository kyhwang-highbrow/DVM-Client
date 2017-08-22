-- T1 = (기본 능력치 + 레벨 능력치 + 승급 능력치 + 진화 능력치 + 초월 능력치 + 친밀도 능력치)
-- T2 =  (T1 * 룬 multi) + 룬 add
-- T3 = (T2 * 버프 multi ) + 버프 add

-------------------------------------
-- class StructIndividualStatus
-- @instance indivisual_status
-------------------------------------
StructIndividualStatus = class({
        m_statusName = 'string',

        ----------------------------------------------------
        -- T1
        -- 캐릭터의 기초 능력치
        m_baseStat = '',

        -- level을 기준으로 상승하는 능력치
        m_lvStat = '',
        m_gradeStat = '',
        m_evolutionStat = '',
        m_eclvStat = '',

        m_friendshipStat = '',  -- 친밀도 능력치
        ----------------------------------------------------


        ----------------------------------------------------
        -- T2
        m_runeMulti = '',       -- 룬 곱연산
        m_runeAdd = '',         -- 룬 합연산
        ----------------------------------------------------


        ----------------------------------------------------
        -- T3
        m_buffMulti = '',
        m_buffAdd = '',
        ----------------------------------------------------

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

    self.m_baseStat = 0

    self.m_lvStat = 0
    self.m_gradeStat = 0
    self.m_evolutionStat = 0
    self.m_eclvStat = 0

    self.m_friendshipStat = 0

    self.m_runeMulti = 0
    self.m_runeAdd = 0

    self.m_t2 = 0
    self.m_bDirtyT2 = true

    self.m_buffMulti = 0
    self.m_buffAdd = 0

    self.m_finalStat = 0
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
-- function getT2
-------------------------------------
function StructIndividualStatus:getT2()
   if self.m_bDirtyT2 then
    self:calcT2()
   end

   return self.m_t2
end

-------------------------------------
-- function calcT2
-------------------------------------
function StructIndividualStatus:calcT2()
    -- 기본 능력치 연산 (드래곤 성장)
    local t1 = (self.m_baseStat +
                self.m_lvStat + self.m_gradeStat + self.m_evolutionStat + self.m_eclvStat +
                self.m_friendshipStat)

    -- 룬 능력치 연산
    local rune_multi = (self.m_runeMulti / 100)
    local t2 = t1 + (t1 * rune_multi) + self.m_runeAdd

    self.m_t2 = t2

    self.m_bDirtyT2 = false
end

-------------------------------------
-- function getFinalStat
-------------------------------------
function StructIndividualStatus:getFinalStat()
    if self.m_bDirtyFinalStat then
        self:calcFinalStat()
    end

    return self.m_finalStat
end

-------------------------------------
-- function calcFinalStat
-------------------------------------
function StructIndividualStatus:calcFinalStat()
    local t2 = self:getT2()

    local buff_multi = (self.m_buffMulti / 100)
    local t3 = t2 + (t2 * buff_multi) + self.m_buffAdd

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
-- function setFriendshipStat
-------------------------------------
function StructIndividualStatus:setFriendshipStat(friendship_stat)
    self.m_friendshipStat = friendship_stat
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
-- function addBuffAdd
-------------------------------------
function StructIndividualStatus:addBuffAdd(value)
    self.m_buffAdd = (self.m_buffAdd + value)
    self:setDirtyFinalStat()
end

-------------------------------------
-- function addBuffMulti
-------------------------------------
function StructIndividualStatus:addBuffMulti(value)
    self.m_buffMulti = (self.m_buffMulti + value)
    self:setDirtyFinalStat()
end