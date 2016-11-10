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
    open_skill_count = open_skill_count or 3

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

    -- 기본 액티브 스킬 지정
    if t_character['skill_active'] then
        self:setSkillID('active', t_character['skill_active'], self:getSkillLevel(0))
    end

    -- 캐릭터 등급에 따라 루프를 돌며 스킬을 초기화 한다.
    -- 스킬 타입 별로 나중에 추가한것으로 덮어 씌운다.
    local max_idx = open_skill_count
    for i = 1, max_idx do
        local skill_type_key = 'skill_type_' .. i
        local skill_key = 'skill_' .. i

        local skill_type = t_character[skill_type_key]
        local skill_id = t_character[skill_key]

        self:setSkillID(skill_type, skill_id, self:getSkillLevel(i))
    end

	-- @TEST 활성화 스킬 확인 로그
	if PRINT_DRAGON_SKILL then 
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
    self.m_dragonSkillLevel[1] = skill_01_lv or 0 -- 패시브 1
    self.m_dragonSkillLevel[2] = skill_02_lv or 0 -- 패시브 2
    self.m_dragonSkillLevel[3] = skill_03_lv or 0 -- 액티브 강화
end

-------------------------------------
-- function getSkillLevel
-------------------------------------
function IDragonSkillManager:getSkillLevel(idx)
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
    self.m_lSkillIndivisualInfo['basic_rate'] = {}
    self.m_lSkillIndivisualInfo['basic_turn'] = {}
    self.m_lSkillIndivisualInfo['passive'] = {}
    self.m_lSkillIndivisualInfo['manual'] = {}
    self.m_lSkillIndivisualInfo['active'] = false
end

-------------------------------------
-- function setSkillID
-------------------------------------
function IDragonSkillManager:setSkillID(skill_type, skill_id, skill_lv)
    if (skill_type == 'x') then
        return
    end

    -- 미리 정의 되지 않은 것은 에러 처리
    if (self.m_lSkillIndivisualInfo[skill_type] == nil) then
        error('skill_type : ' .. skill_type)
    end

    local skill_indivisual_info = DragonSkillIndivisualInfo(self.m_charType, skill_type, skill_id, skill_lv)

    if isExistValue(skill_type, 'active', 'basic') then

        local l_existing_list = nil
        if self.m_lSkillIndivisualInfo[skill_type] then
            l_existing_list = self.m_lSkillIndivisualInfo[skill_type].m_lSkillLevelupIDList
        end
        self.m_lSkillIndivisualInfo[skill_type] = skill_indivisual_info
        skill_indivisual_info:init_skillLevelupIDList(l_existing_list)
    else
        table.insert(self.m_lSkillIndivisualInfo[skill_type], skill_indivisual_info)
        skill_indivisual_info:init_skillLevelupIDList(nil)
    end

    -- 스킬 레벨 적용
    skill_indivisual_info:applySkillLevel()
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

    do -- 액티브 스킬
        local skill_id = t_character['skill_active']
        local skill_type = 'active'

        if (skill_type ~= 'x') and skill_id ~= 0 then
            local skill_lv = self:getSkillLevel(0)
            l_skill_icon[0] = UI_SkillCard(self.m_charType, skill_id, skill_type, skill_lv)
        end
    end

    -- 진화에 의한 스킬 아이콘
    for i=1, MAX_DRAGON_EVOLUTION do
        local skill_id = t_character['skill_' .. i]
        local skill_type = t_character['skill_type_' .. i]

        if (skill_type ~= 'x') and skill_id ~= 0 then
            local skill_lv = self:getSkillLevel(i)
            l_skill_icon[i] = UI_SkillCard(self.m_charType, skill_id, skill_type, skill_lv)
        end
    end

    return l_skill_icon
end

-------------------------------------
-- function getDragonSkillIconList
-------------------------------------
function IDragonSkillManager:getDragonSkillIconList()
    local l_skill_icon = {}

    local t_character = self.m_charTable

    do -- 액티브 스킬
        local skill_id = t_character['skill_active']
        local skill_type = 'active'

        if (skill_type ~= 'x') and skill_id ~= 0 then
            local skill_lv = self:getSkillLevel(0)
            local skill_indivisual_info = DragonSkillIndivisualInfo('dragon', skill_type, skill_id, skill_lv)
            skill_indivisual_info:applySkillLevel()
            l_skill_icon[0] = UI_DragonSkillCard(skill_indivisual_info)
        end
    end

    -- 진화에 의한 스킬 아이콘
    for i=1, MAX_DRAGON_EVOLUTION do
        local skill_id = t_character['skill_' .. i]
        local skill_type = t_character['skill_type_' .. i]

        if (skill_type ~= 'x') and skill_id ~= 0 then
            local skill_lv = self:getSkillLevel(i)
            local skill_indivisual_info = DragonSkillIndivisualInfo('dragon', skill_type, skill_id, skill_lv)
            skill_indivisual_info:applySkillLevel()
            l_skill_icon[i] = UI_DragonSkillCard(skill_indivisual_info)
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
-- function getSkillDescPure
-- @brief 스킬 설명 리턴
-------------------------------------
function IDragonSkillManager:getSkillDescPure(t_skill)
    local desc = Str(t_skill['t_desc'], t_skill['desc_1'], t_skill['desc_2'], t_skill['desc_3'], t_skill['desc_4'], t_skill['desc_5'])
    return desc
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