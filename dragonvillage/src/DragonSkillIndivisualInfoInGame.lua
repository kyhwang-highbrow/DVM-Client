local PARENT = DragonSkillIndivisualInfo

-------------------------------------
-- class DragonSkillIndivisualInfoInGame
-- @TODO Individual로 수정 예정
-------------------------------------
DragonSkillIndivisualInfoInGame = class(PARENT, {
        m_tOrgSkill = 'table',  -- 스킬 레벨까지 적용된 테이블(인게임에선 실시간 변경사항은 적용되지 않음)

        m_bDirtyBuff = 'boolean',
        m_lBuff = 'table',

        m_turnCount = 'number', -- 턴 공격 횟수 저장용
        m_timer = 'number',     -- 타임 공격 저장용
        m_cooldownTimer = 'number', -- 쿨타임 시간 저장용
        m_hpRate = 'number',    -- 체력 조건 저장용
    })

-------------------------------------
-- function init
-------------------------------------
function DragonSkillIndivisualInfoInGame:init(char_type, skill_type, skill_id, skill_level)
    self.m_className = 'DragonSkillIndivisualInfoInGame'

    self.m_bDirtyBuff = false
    self.m_lBuff = {}

    self.m_turnCount = 0
    self.m_timer = 0
    self.m_cooldownTimer = 0
    self.m_hpRate = 100
end

-------------------------------------
-- function update
-------------------------------------
function DragonSkillIndivisualInfoInGame:update(dt)
    -- TODO: 차후 드래그 스킬 쿨타임도 여기서 처리될 수 있도록 수정해야할듯...
    if (self.m_skillType == 'active') then return end

    -- indie_time 타이머
    if (self.m_timer > 0) then
        self.m_timer = self.m_timer - dt

        if (self.m_timer <= 0) then
            self.m_timer = 0
        end
    end
    
    -- 스킬 쿨타임
    if (self.m_cooldownTimer > 0) then
        self.m_cooldownTimer = self.m_cooldownTimer - dt

        if (self.m_cooldownTimer <= 0) then
            self.m_cooldownTimer = 0
        end
    end

    -- 버프 적용
    if (self.m_bDirtyBuff) then
        self:applyBuff()
    end
end

-------------------------------------
-- function startCoolTime
-------------------------------------
function DragonSkillIndivisualInfoInGame:startCoolTime()
    if (not self.m_tSkill['cooldown'] or self.m_tSkill['cooldown'] == '') then
        self.m_cooldownTimer = 0
    else
        self.m_cooldownTimer = tonumber(self.m_tSkill['cooldown'])
    end

    if (self.m_skillType == 'indie_time' or self.m_skillType == 'indie_time_short') then
        self.m_timer = self.m_tSkill['chance_value']
    end

    self.m_turnCount = 0
end


-------------------------------------
-- function startCoolTimeByCasting
-- @brief 캐스팅을 시작하면 cooldown을 제외한 나머지만 시작시킴
-------------------------------------
function DragonSkillIndivisualInfoInGame:startCoolTimeByCasting()
    if (self.m_skillType == 'indie_time' or self.m_skillType == 'indie_time_short') then
        self.m_timer = self.m_tSkill['chance_value']
    end

    self.m_turnCount = 0
end

-------------------------------------
-- function isEndCoolTime
-------------------------------------
function DragonSkillIndivisualInfoInGame:isEndCoolTime()
    if (self.m_skillType == 'indie_time' or self.m_skillType == 'indie_time_short') then
        return (self.m_cooldownTimer == 0 and self.m_timer == 0)
    else
        return (self.m_cooldownTimer == 0)
    end
end

-------------------------------------
-- function resetCoolTime
-------------------------------------
function DragonSkillIndivisualInfoInGame:resetCoolTime()
    self.m_timer = 0
    self.m_cooldownTimer = 0
    self.m_turnCount = 0
end

-------------------------------------
-- function applySkillLevel
-------------------------------------
function DragonSkillIndivisualInfoInGame:applySkillLevel(old_skill_info)
    PARENT.applySkillLevel(self, old_skill_info)

	-- 원본 테이블 저장
    self.m_tOrgSkill = clone(self.m_tSkill)
end

-------------------------------------
-- function applyBuff
-------------------------------------
function DragonSkillIndivisualInfoInGame:applyBuff()
    if (not self.m_bDirtyBuff) then return end

    -- 원본 테이블 값으로 설정
    for k, v in pairs(self.m_tOrgSkill) do
        self.m_tSkill[k] = v
    end

    -- 원본 테이블로 부터 다시 계산
    for i, v in ipairs(self.m_lBuff) do
        local col = v['col']
        local val = v['val']
        
        if (v['action'] == 'multi') then
            self.m_tSkill[col] = self.m_tSkill[col] * val
        elseif (v['action'] == 'add') then
            self.m_tSkill[col] = self.m_tSkill[col] + val
        end
    end

    self.m_bDirtyBuff = false
end

-------------------------------------
-- function addBuff
-------------------------------------
function DragonSkillIndivisualInfoInGame:addBuff(column, value, action)
    local data = {
        col = column,
        val = value or 0,
        action = action or 'add'
    }

    table.insert(self.m_lBuff, data)

    self.m_bDirtyBuff = true

    self:applyBuff()
end

-------------------------------------
-- function removeBuff
-------------------------------------
function DragonSkillIndivisualInfoInGame:removeBuff(column, value, action)
    for i, v in ipairs(self.m_lBuff) do
        if (v['col'] == column and v['val'] == value and v['action'] == action) then
            table.remove(self.m_lBuff, i)
            return
        end
    end

    self.m_bDirtyBuff = true
end