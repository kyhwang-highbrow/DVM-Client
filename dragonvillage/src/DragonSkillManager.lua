-------------------------------------
-- interface IDragonSkillManager
-------------------------------------
IDragonSkillManager = {
        -- [external variable]
        m_charType = 'string',
        m_charID = 'number',
        m_charGrade = 'number',

        -- [internal variable]
        m_charTable = 'table',

        m_lSkillIndivisualInfo = 'list',
        m_lReserveTurnSkillID = 'number',
    }

-------------------------------------
-- function init
-------------------------------------
function IDragonSkillManager:init()
    self.m_lReserveTurnSkillID = {}
end

-------------------------------------
-- function initDragonSkillManager
-------------------------------------
function IDragonSkillManager:initDragonSkillManager(char_type, char_id, char_grade)
    char_grade = char_grade or 6

    self.m_charType = char_type
    self.m_charID = char_id
    self.m_charGrade = char_grade

    -- 캐릭터 테이블 저장
    local table_dragon = TABLE:get(self.m_charType)
    local t_character = table_dragon[char_id]
    self.m_charTable = t_character

    self:initSkillIDList()

    -- 캐릭터 등급에 따라 루프를 돌며 스킬을 초기화 한다.
    -- 스킬 타입 별로 나중에 추가한것으로 덮어 씌운다.
    local max_idx = char_grade
    for i = 1, max_idx do
        local skill_type_key = 'skill_type_' .. i
        local skill_key = 'skill_' .. i

        local skill_type = t_character[skill_type_key]
        local skill_id = t_character[skill_key]

        self:setSkillID(skill_type, skill_id)
    end

	-- @TEST 활성화 스킬 확인 로그
    self:printSkillManager()
end

-------------------------------------
-- function initSkillIDList
-------------------------------------
function IDragonSkillManager:initSkillIDList()
    local t_character = self.m_charTable

    -- 타입별 기본 스킬 ID
    self.m_lSkillIndivisualInfo = {}
    self.m_lSkillIndivisualInfo['basic'] = false
    self.m_lSkillIndivisualInfo['basic_rate'] = {}
    self.m_lSkillIndivisualInfo['basic_turn'] = {}
    self.m_lSkillIndivisualInfo['passive'] = {}
    self.m_lSkillIndivisualInfo['manual'] = {}
    self.m_lSkillIndivisualInfo['active'] = false

    -- 기본 공격 지정
    self:setSkillID('basic', t_character['skill_basic'])
end

-------------------------------------
-- function setSkillID
-------------------------------------
function IDragonSkillManager:setSkillID(skill_type, skill_id)
    if (skill_type == 'x') then
        return
    end

    -- 미리 정의 되지 않은 것은 에러 처리
    if (self.m_lSkillIndivisualInfo[skill_type] == nil) then
        error('skill_type : ' .. skill_type)
    end

    local skill_indivisual_info = DragonSkillIndivisualInfo(self.m_charType, skill_id)

    if isExistValue(skill_type, 'active', 'basic') then
        self.m_lSkillIndivisualInfo[skill_type] = skill_indivisual_info
    else
        table.insert(self.m_lSkillIndivisualInfo[skill_type], skill_indivisual_info)
    end
end

-------------------------------------
-- function getSkillID
-- @brief 타입별 스킬 ID를 얻어옴(테이블을 리턴할 수도 있음)
-------------------------------------
function IDragonSkillManager:getSkillID(skill_type)
    local skill_indivisual_info = self.m_lSkillIndivisualInfo[skill_type]

    if (not skill_indivisual_info) then
        return 0
    end

    -- 하나의 스킬만을 가지는 스킬 타입
	if isExistValue(skill_type, 'active', 'basic') then
        return skill_indivisual_info.m_skillID

    -- 다중의 스킬을 가질 수 있는 스킬 타입
    else
        local l_skill_id = {}

        for i,v in ipairs(skill_indivisual_info) do
            table.insert(l_skill_id, v.m_skillID)
        end

        return l_skill_id
    end
end

-------------------------------------
-- function getSkillIconList
-------------------------------------
function IDragonSkillManager:getSkillIconList()
    local l_skill_icon = {}

    local t_character = self.m_charTable

    do -- 기본 공격 스킬 아이콘
        local basic_skill_id = self:getSkillID('basic')
        if basic_skill_id then
            local icon = UI_SkillCard(self.m_charType, basic_skill_id, 'basic')
            l_skill_icon[0] = icon
        end
    end

    -- 승급에 의한 스킬 아이콘
    for i=1, 6 do
        local skill_id = t_character['skill_' .. i]
        local skill_type = t_character['skill_type_' .. i]

        if (skill_type ~= 'x') and skill_id ~= 0 then
            local grade_icon_idx = nil
            local grade_idx = i
            if (self.m_charGrade < grade_idx) then
                grade_icon_idx = grade_idx
            end

            l_skill_icon[i] = UI_SkillCard(self.m_charType, skill_id, skill_type, grade_icon_idx)
        end
    end

    return l_skill_icon
end


-------------------------------------
-- function getBasicAttackSkillID
-------------------------------------
function IDragonSkillManager:getBasicAttackSkillID()
    -- 1. turn류 스킬 확인
    if (table.count(self.m_lSkillIndivisualInfo['basic_turn']) > 0) then
        for i,v in pairs(self.m_lSkillIndivisualInfo['basic_turn']) do
            v.m_turnCount = (v.m_turnCount + 1)
            if (v.m_tSkill['chance_value'] <= v.m_turnCount) then
                v.m_turnCount = 0
                table.insert(self.m_lReserveTurnSkillID, v.m_skillID)
            end
        end

        if (self.m_lReserveTurnSkillID[1]) then
            local skill_id = self.m_lReserveTurnSkillID[1]
            table.remove(self.m_lReserveTurnSkillID, 1)
            return skill_id, true
        end
    end

    -- 2. basic_rate류 스킬 확인
    if (table.count(self.m_lSkillIndivisualInfo['basic_rate']) > 0) then
        local sum_random = SumRandom()

        for i,v in pairs(self.m_lSkillIndivisualInfo['basic_rate']) do
            local rate = (v.m_tSkill['chance_value'] * 100)
            local skill_id = v.m_skillID
            sum_random:addItem(rate, skill_id)
        end

        local remain_rate = math_max(0, (100 - sum_random.m_rateSum))
        sum_random:addItem(remain_rate, 0)

        local item = sum_random:getRandomValue()
        if (item ~= 0) then
            return item, true
        end
    end

    -- 3. 기본 스킬
    do
        return self:getSkillID('basic'), false
    end
end

-------------------------------------
-- function getCastTimeFromSkillID
-- @brief 해당 아이디 스킬의 캐스팅 시간을 얻는다
-------------------------------------
function IDragonSkillManager:getCastTimeFromSkillID(skill_id)
    local table_skill = TABLE:get(self.m_charType .. '_skill')
    local t_skill = table_skill[skill_id]
    local cast_time = tonumber(t_skill['casting_time']) or 0

    return cast_time
end

-------------------------------------
-- function printSkillManager
-- @brief 디버깅 용도로 스킬 리스트 출력
-------------------------------------
function IDragonSkillManager:printSkillManager()

    -- 드래곤만 출력되도록 예외처리
    if (not isExistValue(self.m_charType, 'dragon')) then
        return
    end

    cclog('########DragonSkillManager##############')
	cclog('id : ' .. self.m_charID)
	for type, skill in pairs(self.m_lSkillIndivisualInfo) do
		if isExistValue(type, 'active', 'basic') then
			if self.m_lSkillIndivisualInfo[type] then
				cclog('type : ' .. type, 'skill : ' .. skill.m_tSkill['id'] .. skill.m_tSkill['t_name'])
			end
		else
			cclog('type : ' .. type, '')
			for i, skill2 in pairs(skill) do
				cclog('    no.' .. i .. ' : ' .. skill2.m_tSkill['id'] .. skill2.m_tSkill['t_name'])
			end
		end
	end
	cclog('----------------------------------------')
end

-------------------------------------
-- function getCloneTable
-------------------------------------
function IDragonSkillManager:getCloneTable()
    return clone(IDragonSkillManager)
end


-------------------------------------
-- class DragonSkillManager
-------------------------------------
DragonSkillManager = class(clone(IDragonSkillManager))

-------------------------------------
-- function init
-------------------------------------
function DragonSkillManager:init(char_type, char_id, char_grade)
    self:initDragonSkillManager(char_type, char_id, char_grade)
end