-------------------------------------
-- interface IDragonSkillManager
-------------------------------------
IDragonSkillManager = {
        -- [external variable]
        m_charType = 'string',
        m_charID = 'number',
        m_openSkillCount = 'number',
        m_dragonSkillLevel = 'table', --드래곤일 경우에만 사용, 스킬 레벨 지정

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
function IDragonSkillManager:initDragonSkillManager(char_type, char_id, open_skill_count)
    --open_skill_count = open_skill_count or 3
    open_skill_count = 10

    self.m_charType = char_type
    self.m_charID = char_id
    self.m_openSkillCount = open_skill_count

    -- 캐릭터 테이블 저장
    local table_dragon = TABLE:get(self.m_charType)
    local t_character = table_dragon[char_id]
    self.m_charTable = t_character

    self:initSkillIDList()

    -- 기본 공격 지정
    self:setSkillID('basic', t_character['skill_basic'], 1)

    -- 기본 드래그 스킬 지정
    if t_character['skill_active'] then
        self:setSkillID('active', t_character['skill_active'], self:getSkillLevel(0))
    end

    -- 캐릭터 등급에 따라 루프를 돌며 스킬을 초기화 한다.
    -- 스킬 타입 별로 나중에 추가한것으로 덮어 씌운다.
    local max_idx = open_skill_count
	local table_skill = GetSkillTable(self.m_charType)
    for i = 1, max_idx do
        local skill_id = t_character['skill_' .. i]
        local skill_type = table_skill:getSkillType(skill_id)

        if skill_type and skill_id then
            self:setSkillID(skill_type, skill_id, self:getSkillLevel(i))
        end
    end

	-- @TEST 활성화 스킬 확인 로그
	if g_constant:get('DEBUG', 'PRINT_DRAGON_SKILL') then 
		self:printSkillManager()
	end
end

-------------------------------------
-- function setDragonSkillLevelList
-- @breif 드래곤의 스킬 레벨 적용
-------------------------------------
function IDragonSkillManager:setDragonSkillLevelList(skill_00_lv, skill_01_lv, skill_02_lv, skill_03_lv)
    self.m_dragonSkillLevel = {}
    self.m_dragonSkillLevel[0] = skill_00_lv or 0 -- 액티브 스킬
    self.m_dragonSkillLevel[1] = skill_01_lv or 0 -- 터치 스킬
    self.m_dragonSkillLevel[2] = skill_02_lv or 0 -- 패시브 스킬
    self.m_dragonSkillLevel[3] = skill_03_lv or 0 -- 액티브 강화
end

-------------------------------------
-- function getSkillLevel
-------------------------------------
function IDragonSkillManager:getSkillLevel(idx)
    -- 몬스터는 무조건 1로 처리
    if (self.m_charType == 'monster') then
        return 1
    end

    if (not self.m_dragonSkillLevel) then
        return 0
    end

    local skill_lv = self.m_dragonSkillLevel[idx] or 0
    return skill_lv
end

-------------------------------------
-- function initSkillIDList
-------------------------------------
function IDragonSkillManager:initSkillIDList()
    local t_character = self.m_charTable

    -- 타입별 기본 스킬 ID
    self.m_lSkillIndivisualInfo = {}
    self.m_lSkillIndivisualInfo['basic'] = false
	self.m_lSkillIndivisualInfo['touch'] = false
    self.m_lSkillIndivisualInfo['active'] = false

    self.m_lSkillIndivisualInfo['basic_rate'] = {}
    self.m_lSkillIndivisualInfo['basic_turn'] = {}

	self.m_lSkillIndivisualInfo['indie_rate'] = {}
	self.m_lSkillIndivisualInfo['indie_turn'] = {}
	self.m_lSkillIndivisualInfo['indie_time'] = {}

	self.m_lSkillIndivisualInfo['under_atk_rate'] = {}
	self.m_lSkillIndivisualInfo['under_atk_turn'] = {}

	-- @TODO 삭제 예정
    self.m_lSkillIndivisualInfo['passive'] = {}
    self.m_lSkillIndivisualInfo['manual'] = {}
end

-------------------------------------
-- function setSkillID
-------------------------------------
function IDragonSkillManager:setSkillID(skill_type, skill_id, skill_lv)
    if (skill_lv <= 0) then
        return
    end

    if (skill_type == '') then
        return
    end

    -- 미리 정의 되지 않은 것은 에러 처리
    if (self.m_lSkillIndivisualInfo[skill_type] == nil) then
        error('skill_type : ' .. skill_type)
    end

    local skill_indivisual_info = DragonSkillIndivisualInfo(self.m_charType, skill_type, skill_id, skill_lv)

	local t_add_value = nil
	if isExistValue(skill_type, 'active', 'basic', 'touch') then
		if (self.m_lSkillIndivisualInfo[skill_type]) then
			t_add_value = self.m_lSkillIndivisualInfo[skill_type].m_tAddedValue
		end
		self.m_lSkillIndivisualInfo[skill_type] = skill_indivisual_info
    else
        table.insert(self.m_lSkillIndivisualInfo[skill_type], skill_indivisual_info)
    end

    -- 스킬 레벨 적용
    skill_indivisual_info:applySkillLevel(t_add_value)

	-- 스킬 desc 세팅
	skill_indivisual_info:applySkillDesc()
end

-------------------------------------
-- function getSkillIndivisualInfo
-- @brief 타입별 스킬의 DragonSkillIndivisualInfo를 얻어옴
-------------------------------------
function IDragonSkillManager:getSkillIndivisualInfo(skill_type)
    return self.m_lSkillIndivisualInfo[skill_type]
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
	if isExistValue(skill_type, 'active', 'basic', 'touch') then
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
-- function getDragonSkillIconList
-------------------------------------
function IDragonSkillManager:getDragonSkillIconList()
    local l_skill_icon = {}

    for i=0, 4 do
        l_skill_icon[i] = self:makeSkillIcon_usingIndex(i)
    end

    return l_skill_icon
end

-------------------------------------
-- function makeSkillIcon_usingIndex
-------------------------------------
function IDragonSkillManager:makeSkillIcon_usingIndex(idx)
    local skill_indivisual_info = self:getSkillIndivisualInfo_usingIdx(idx)
    if skill_indivisual_info then
        return UI_DragonSkillCard(skill_indivisual_info)
    else
        return nil
    end
end

-------------------------------------
-- function getSkillIndivisualInfo_usingIdx
-------------------------------------
function IDragonSkillManager:getSkillIndivisualInfo_usingIdx(idx)
    local t_character = self.m_charTable

    local skill_id
    local skill_type

    if (idx == 0) then
        skill_id = t_character['skill_active']
        skill_type = 'active'
    else
        skill_id = t_character['skill_' .. idx]
		skill_type = GetSkillTable(self.m_charType):getSkillType(skill_id)
    end
	-- @TODO
	-- active 강화에게 기본 active의 added_value 를 주기 위해서
	local t_add_value
	if (idx == 3) then
		if (self.m_lSkillIndivisualInfo[skill_type]) then
			t_add_value = self.m_lSkillIndivisualInfo[skill_type].m_tAddedValue
		end
	end

    if (skill_type) and skill_id ~= 0 then
        local skill_lv = self:getSkillLevel(idx)
        local skill_indivisual_info = DragonSkillIndivisualInfo('dragon', skill_type, skill_id, skill_lv)
		-- active 강화가 활성화 되지 않으면 기본 값이 나오도록...
		if (skill_lv == 0) then
			t_add_value = nil
		end
        skill_indivisual_info:applySkillLevel(t_add_value)
		skill_indivisual_info:applySkillDesc()
        return skill_indivisual_info
    end
end

-------------------------------------
-- function checkSkillRate
-------------------------------------
function IDragonSkillManager:checkSkillRate(skill_type)
	local t_skill_info = self.m_lSkillIndivisualInfo[skill_type]

	if (table.count(t_skill_info) > 0) then
        local sum_random = SumRandom()

        for i,v in pairs(self.m_lSkillIndivisualInfo[skill_type]) do
            local rate = (v.m_tSkill['chance_value'] * 100)
            local skill_id = v.m_skillID
            sum_random:addItem(rate, skill_id)
        end

        local remain_rate = math_max(0, (100 - sum_random.m_rateSum))
        sum_random:addItem(remain_rate, 0)

        local skill_id = sum_random:getRandomValue()
        if (skill_id ~= 0) then
            return skill_id
        end
    end

	return nil
end

-------------------------------------
-- function checkSkillTurn
-------------------------------------
function IDragonSkillManager:checkSkillTurn(skill_type)
	local t_skill_info = self.m_lSkillIndivisualInfo[skill_type]

	if (table.count(t_skill_info) > 0) then
        for i,v in pairs(t_skill_info) do
            v.m_turnCount = (v.m_turnCount + 1)
            if (v.m_tSkill['chance_value'] <= v.m_turnCount) then
                v.m_turnCount = 0
                table.insert(self.m_lReserveTurnSkillID, v.m_skillID)
            end
        end

        if (self.m_lReserveTurnSkillID[1]) then
            local skill_id = self.m_lReserveTurnSkillID[1]
            table.remove(self.m_lReserveTurnSkillID, 1)
            return skill_id
        end
    end

	return nil
end

-------------------------------------
-- function getBasicAttackSkillID
-- @return	skill_id, is_add_basic
-------------------------------------
function IDragonSkillManager:getBasicAttackSkillID()
	local skill_id = nil

	-- 1. 기본 공격과 동시에 나가는 스킬 체크
	do
		skill_id = self:checkSkillTurn('basic_turn')
		if (skill_id) then
			return skill_id, true
		end

		skill_id = self:checkSkillRate('basic_rate')
		if (skill_id) then
			return skill_id, true
		end
	end

	-- 2. 독립적으로 나가는 스킬 체크
	do
		skill_id = self:checkSkillTurn('indie_turn')
		if (skill_id) then
			return skill_id, false
		end

		skill_id = self:checkSkillRate('indie_rate')
		if (skill_id) then
			return skill_id, false
		end
	end

    -- 3. 기본 스킬
    do
        return self:getSkillID('basic'), false
    end
end

-------------------------------------
-- function getBasicAttackSkillID
-- @return	skill_id
-------------------------------------
function IDragonSkillManager:getBasicTimeAttackSkillID()
    if (not self.m_lSkillIndivisualInfo) then return end

    if (table.count(self.m_lSkillIndivisualInfo['indie_time']) > 0) then
        for i,v in pairs(self.m_lSkillIndivisualInfo['indie_time']) do
            if (v.m_tSkill['chance_value'] <= v.m_timer) then
                v.m_timer = 0
                return v.m_skillID
            end
        end
    end
end

-------------------------------------
-- function updateBasicTimeSkillID
-------------------------------------
function IDragonSkillManager:updateBasicTimeSkillTimer(dt)
    if (not self.m_lSkillIndivisualInfo) then return end
	
    if (table.count(self.m_lSkillIndivisualInfo['indie_time']) > 0) then
        for i,v in pairs(self.m_lSkillIndivisualInfo['indie_time']) do
            v.m_timer = (v.m_timer + dt)
            if (v.m_tSkill['chance_value'] <= v.m_timer) then
                return true
            end
        end
    end

    return false
end

-------------------------------------
-- function getCastTimeFromSkillID
-- @brief 해당 아이디 스킬의 캐스팅 시간을 얻는다
-------------------------------------
function IDragonSkillManager:getCastTimeFromSkillID(skill_id)
    local table_skill = TABLE:get(self.m_charType .. '_skill')
    local t_skill = table_skill[skill_id]
    if not t_skill then
        error('스킬 테이블이 존재하지 않는다.' .. tostring(skill_id))
    end

    local cast_time = tonumber(t_skill['casting_time'] or 0)

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
	cclog('dragon id : ' .. self.m_charID)
	for type, skill in pairs(self.m_lSkillIndivisualInfo) do
		if isExistValue(type, 'active', 'basic', 'touch') then
			if self.m_lSkillIndivisualInfo[type] then
				cclog('type : ' .. type, 'skill : ' .. skill.m_tSkill['sid'] .. skill.m_tSkill['t_name'] .. ' lv.' .. skill.m_skillLevel)
			end
		else
			if (skill[1]) then 
				cclog('type : ' .. type, '')
				for i, skill2 in pairs(skill) do
					cclog('--> no.' .. i .. ' : ' .. skill2.m_tSkill['sid'] .. skill2.m_tSkill['t_name'] .. ' lv.' .. skill2.m_skillLevel)
				end
			end
		end
	end
	cclog('----------------------------------------')
end

-------------------------------------
-- function getSkillDescPure
-- @brief 스킬 설명 리턴
-------------------------------------
function IDragonSkillManager:getSkillDescPure(t_skill)
    local desc = Str(t_skill['t_desc'], t_skill['desc_1'], t_skill['desc_2'], t_skill['desc_3'], t_skill['desc_4'], t_skill['desc_5'])
    return desc
end

-------------------------------------
-- function getLevelingSkill
-- @param Skill type
-- @brief 타입으로 찾아 레벨링된 스킬 테이블 반환
-------------------------------------
function IDragonSkillManager:getLevelingSkillByType(skill_type)
	return self.m_lSkillIndivisualInfo[skill_type]
end

-------------------------------------
-- function getLevelingSkill
-- @param Skill id 
-- @brief id로 찾아 레벨링된 스킬 테이블 반환
-------------------------------------
function IDragonSkillManager:getLevelingSkillById(skill_id)
	local t_skill = nil
	for skill_type, skill_info in pairs(self.m_lSkillIndivisualInfo) do
		if isExistValue(skill_type, 'active', 'basic', 'touch') then
			if (skill_info and skill_info.m_skillID == skill_id) then
				t_skill = skill_info.m_tSkill
				break
			end
		else
			for i, skill_info2 in pairs(skill_info) do
				if (skill_info2.m_skillID == skill_id) then
					t_skill = skill_info2.m_tSkill
					break
				end
			end
		end
	end
	return t_skill
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
function DragonSkillManager:init()
end

-------------------------------------
-- function MakeDragonSkillManager
-------------------------------------
function MakeDragonSkillManager(did, evolution_lv, skill_00_lv, skill_01_lv, skill_02_lv, skill_03_lv)
    
    -- 드래곤 스킬 매니저 생성
    local dragon_skill_mgr = DragonSkillManager()

    -- 스킬 레벨 설정
    dragon_skill_mgr:setDragonSkillLevelList(skill_00_lv, skill_01_lv, skill_02_lv, skill_03_lv)

    -- 스킬들 설정
    local char_type = 'dragon'
    local char_id = did
    local open_skill_count = evolution_lv
    dragon_skill_mgr:initDragonSkillManager(char_type, char_id, open_skill_count)

    return dragon_skill_mgr
end

-------------------------------------
-- function MakeDragonSkillFromDoid
-- @brief 드래곤 오브젝트 ID로 스킬 매니저 생성
-------------------------------------
function MakeDragonSkillFromDoid(doid)
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

    local dragon_skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
    return dragon_skill_mgr
end

-------------------------------------
-- function MakeDragonSkillFromDragonData
-- @brief 드래곤 데이터 테이블로 스킬 매니저 생성
-------------------------------------
function MakeDragonSkillFromDragonData(t_dragon_data)
    if (not t_dragon_data) then
        return nil
    end

    local did = t_dragon_data['did']
    local evolution_lv = t_dragon_data['evolution']
    local skill_00_lv = t_dragon_data['skill_0']
    local skill_01_lv = t_dragon_data['skill_1']
    local skill_02_lv = t_dragon_data['skill_2']
    local skill_03_lv = t_dragon_data['skill_3']

    local dragon_skill_mgr = MakeDragonSkillManager(did, evolution_lv, skill_00_lv, skill_01_lv, skill_02_lv, skill_03_lv)

    return dragon_skill_mgr
end

-------------------------------------
-- function GetSkillTable
-------------------------------------
function GetSkillTable(char_type)
	if (char_type == 'dragon') then
		return TableDragonSkill()
	else
		return TableMonsterSkill()
	end
end