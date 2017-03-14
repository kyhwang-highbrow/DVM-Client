-------------------------------------
-- class LevelupDirector
-------------------------------------
LevelupDirector = class({
    -- [external variable]
        -- 기존 레벨, 경험치
        m_srcLv = 'number',
        m_srcExp = 'number',

        -- 목표 레벨, 경험치 (skip할 경우 사용하기 위함)
        m_destLv = 'number',
        m_destExp = 'number',

        -- 레벨별 최대 경험치 리스트
        m_lMaxExp = 'list', -- key=lv, value=maxExp

        m_cbUpdate = 'function(lv, exp, percentage)',
        m_cbLevelUp = 'function',
        m_cbMaxLevel = 'function',

    -- [interval variable]
        -- 총 추가된 경험치
        m_totalAddExp = 'number',

        m_iterLv = 'number',
        m_iterExp = 'number',

        m_dragonGrade = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function LevelupDirector:init(src_lv, src_exp, dest_lv, dest_exp, l_max_exp, dragon_grade)
    
    do -- [external variable]
        -- 기존 레벨, 경험치
        self.m_srcLv = src_lv
        self.m_srcExp = src_exp

        -- 목표 레벨, 경험치 (skip할 경우 사용하기 위함)
        self.m_destLv = dest_lv
        self.m_destExp = dest_exp

        -- 레벨별 최대 경험치 리스트
        self.m_lMaxExp = l_max_exp

        self.m_dragonGrade = dragon_grade
    end

    do -- [interval variable]
        self.m_iterLv = self.m_srcLv
        self.m_iterExp = self.m_srcExp

        self:calcTotalAddExp()
    end
end

-------------------------------------
-- function calcTotalAddExp
-- @brief 획득한 총 경험치 역산
--        self.m_totalAddExp 설정 
-------------------------------------
function LevelupDirector:calcTotalAddExp()
    local total_add_exp = 0

    local iter_lv = self.m_destLv
    local iter_exp = self.m_destExp

    while true do
        -- iter_lv이 더 낮으면 버그이지만 그렇게 처리하도록 함(무한 루프에 빠질 수 있으므로)
        if (iter_lv <= self.m_srcLv) then
            local gap = (iter_exp - self.m_srcExp)
            total_add_exp = (total_add_exp + gap)
            break
        end
        
        if (self.m_srcLv < iter_lv) then
            total_add_exp = (total_add_exp + iter_exp)
            iter_lv = (iter_lv - 1)
            iter_exp = self.m_lMaxExp[iter_lv]
        end
    end

    self.m_totalAddExp = total_add_exp
end

-------------------------------------
-- function calcLvAndExp
-- @brief 획득 경험치를 0부터 순회한 값을 value로 넣었을 때 lv과 exp를 계산
-------------------------------------
function LevelupDirector:calcLvAndExp(value)
    local iter_lv = self.m_srcLv
    local iter_exp = (self.m_srcExp + value)

    while true do
        -- 최대 경험치가 nil이거나 0일 경우 최대 레벨
        local max_exp = self.m_lMaxExp[iter_lv] or 0

        -- 최대 레벨
        if (max_exp == 0) then
            iter_exp = 0
            break
        end

        -- 종료
        if (iter_exp < max_exp) then
            break
        end

        -- 레벨업
        if (iter_exp >= max_exp) then
            iter_lv = (iter_lv + 1)
            iter_exp = (iter_exp - max_exp)
        end
    end

    local max_exp = self.m_lMaxExp[iter_lv] or 0
    local percentage = 100
    if (max_exp > 0) then
        percentage = math_floor((iter_exp / max_exp) * 100)
    end
    return iter_lv, iter_exp, max_exp, percentage
end

-------------------------------------
-- function update
-- @brief
-------------------------------------
function LevelupDirector:update(value, force)
    local iter_lv, iter_exp, max_exp, percentage = self:calcLvAndExp(value)

    -- 변경되지 않았을 경우
    if (not force) and (self.m_iterLv == iter_lv) and (self.m_iterExp == iter_exp) then
        return
    end

    local prev_lv = self.m_iterLv
    local prev_exp = self.m_iterExp

    self.m_iterLv = iter_lv
    self.m_iterExp = iter_exp

    local is_max_level = (max_exp == 0)
    local is_level_up = (prev_lv < self.m_iterLv)

    -- 업데이트 콜백
    if self.m_cbUpdate then
        self.m_cbUpdate(iter_lv, iter_exp, percentage)
    end

    -- 레벨업일 경우
    if is_level_up and self.m_cbLevelUp then
        self.m_cbLevelUp()
    end

    -- 최대 레벨일 경우
    if is_max_level and self.m_cbMaxLevel then
        self.m_cbMaxLevel()
    end
end

-------------------------------------
-- function getTamerExpList
-- @brief
-------------------------------------
function LevelupDirector:getTamerExpList()
    local table_exp_tamer = TABLE:get('exp_tamer')
    local l_max_exp = {}
    for i,v in pairs(table_exp_tamer) do
        local level = tonumber(i)
        local max_exp = v['exp_t']
        l_max_exp[level] = max_exp
    end
    return l_max_exp
end

-------------------------------------
-- function getDragonExpList
-- @brief
-------------------------------------
function LevelupDirector:getDragonExpList()
    local table_dragon_exp = TableDragonExp()
    local l_exp_data = table_dragon_exp:filterList('grade', self.m_dragonGrade)

    local l_max_exp = {}

    for i,v in ipairs(l_exp_data) do
        local level =  v['lv']
        local max_exp = v['max_exp']
        l_max_exp[level] = max_exp
    end

    return l_max_exp
end