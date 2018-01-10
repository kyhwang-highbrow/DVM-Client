-------------------------------------
-- interface IDragonSkillManager
-------------------------------------
IDragonSkillManager = {
        -- [external variable]
        m_charType = 'string',
        m_charID = 'number',
        m_openSkillCount = 'number',
        m_dragonSkillLevel = 'table', --드래곤일 경우에만 사용, 스킬 레벨 지정
		m_evolutionLv = 'number',

        -- [internal variable]
        m_charTable = 'table',

        m_lSkillIndivisualInfo = 'list',
		m_mSkillInfoMap = 'map',			-- 외부 접근용 맵테이블 key : skill_id

        m_lReserveTurnSkillID = 'table',
        m_mReserveTurnSkillID = 'table',

        m_lReserveHpRatePerSkillID = 'table',   -- 특정 체력 비율마다 발동되는 스킬
        m_mReserveHpRatePerSkillID = 'table',
    }

-------------------------------------
-- function init
-------------------------------------
function IDragonSkillManager:init()
    self.m_lReserveTurnSkillID = {}
    self.m_mReserveTurnSkillID = {}

    self.m_lReserveHpRatePerSkillID = {}
    self.m_mReserveHpRatePerSkillID = {}
end

-------------------------------------
-- function initDragonSkillManager
-------------------------------------
function IDragonSkillManager:initDragonSkillManager(char_type, char_id, evolution_lv)
    self.m_charType = char_type
    self.m_charID = char_id
    self.m_openSkillCount = open_skill_count
	self.m_mSkillInfoMap = {}


    -- 캐릭터 테이블 저장
    local table_dragon = TABLE:get(self.m_charType)
    local t_character = table_dragon[char_id]
    self.m_charTable = t_character
	self.m_evolutionLv = evolution_lv

    self:initSkillIDList()

    -- 기본 공격 지정
	if (t_character['skill_basic']) and (t_character['skill_basic'] ~= '') then
		self:setSkillID('basic', t_character['skill_basic'], 1)
	end

    -- 기본 드래그 스킬 지정
    if (t_character['skill_active']) and (t_character['skill_active'] ~= '') then
        self:setSkillID('active', t_character['skill_active'], self:getSkillLevel(0))
    end

	-- 리더 버프 지정
    if (t_character['skill_leader']) and (t_character['skill_leader'] ~= '') then
		local skill_lv = self:getLeaderSkillLevel()
        self:setSkillID('leader', t_character['skill_leader'], skill_lv)
		self.m_dragonSkillLevel['Leader'] = skill_lv
    end

    -- 캐릭터 등급에 따라 루프를 돌며 스킬을 초기화 한다.
    -- 스킬 타입 별로 나중에 추가한것으로 덮어 씌운다.
	local table_skill = GetSkillTable(self.m_charType)
    for i = 1, 9 do
        local skill_id = t_character['skill_' .. i]
		local skill_type = table_skill:getSkillType(skill_id)
		local add_type = t_character['skill_' .. i .. '_type']
        if skill_type and skill_id then
            self:setSkillID(skill_type, skill_id, self:getSkillLevel(i), add_type)
        end
    end

	-- @TEST 활성화 스킬 확인 로그
	if g_constant and g_constant:get('DEBUG', 'PRINT_DRAGON_SKILL') then 
		self:printSkillManager()
	end
end

-------------------------------------
-- function setDragonSkillLevelList
-- @breif 드래곤의 스킬 레벨 적용
-------------------------------------
function IDragonSkillManager:setDragonSkillLevelList(skill_00_lv, skill_01_lv, skill_02_lv, skill_03_lv, skill_04_lv)
    self.m_dragonSkillLevel = {}
    self.m_dragonSkillLevel[0] = skill_00_lv or 0 -- 액티브 스킬
    self.m_dragonSkillLevel[1] = skill_01_lv or 0
    self.m_dragonSkillLevel[2] = skill_02_lv or 0
    self.m_dragonSkillLevel[3] = skill_03_lv or 0 -- 성룡 스킬
    self.m_dragonSkillLevel[4] = skill_04_lv or 0 -- 테이머 콜로세움 스킬
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
-- function getLeaderSkillLevel
-- @brief 리더 버프의 레벨은 1이 최대치이고 획득 시기에 따라 나뉨
-------------------------------------
function IDragonSkillManager:getLeaderSkillLevel()
	local leader_buff_type = self.m_charTable['skill_leader_type']
	local evolution_lv = self.m_evolutionLv

	local skill_lv
	if (leader_buff_type == 'hatch') then
		skill_lv = 1
	elseif (leader_buff_type == 'adult') then
		if (evolution_lv == MAX_DRAGON_EVOLUTION) then
			skill_lv = 1
		else
			skill_lv = 0
		end
	end

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
    self.m_lSkillIndivisualInfo['active'] = false
	self.m_lSkillIndivisualInfo['leader'] = false
end

-------------------------------------
-- function setSkillID
-------------------------------------
function IDragonSkillManager:setSkillID(skill_type, skill_id, skill_lv, add_type)
    if (skill_lv <= 0) then
        return
    end

    if (skill_type == '' or skill_id == '') then
        return
    end

    -- 이미 보유한 스킬인지 체크
    if (self.m_mSkillInfoMap[skill_id]) then
        return
    end

    -- game_mode 체크
    if (g_gameScene) then
        local t_skill = GetSkillTable(self.m_charType):get(skill_id)
        local game_mode = t_skill['game_mode']
        if (game_mode and game_mode ~= '') then
            if (game_mode ~= PLAYER_VERSUS_MODE[g_gameScene.m_gameWorld.m_gameMode]) then
                return
            end
        end
    end

    if (self.m_lSkillIndivisualInfo[skill_type] == nil) then
        self.m_lSkillIndivisualInfo[skill_type] = {}
    end

	-- skill info 생성
    local skill_indivisual_info = DragonSkillIndivisualInfo(self.m_charType, skill_type, skill_id, skill_lv)

	-- skill 입력 및 덮어씌우기
	local old_skill_info

	-- 액티브 스킬
	if (skill_type == 'active') then
		-- 덮어씌우기전에 임시로 저장해둔다
		old_skill_info = self.m_lSkillIndivisualInfo[skill_type]
		self.m_lSkillIndivisualInfo[skill_type] = skill_indivisual_info

	-- 기본공격 및 리더버프는 강화 불가
	elseif isExistValue(skill_type, 'basic', 'leader') then
		self.m_lSkillIndivisualInfo[skill_type] = skill_indivisual_info

	-- 일반 스킬
    else	
		-- 성룡스킬이 아닌 경우 add_type == nil 이다.
		if (not add_type) then 
			table.insert(self.m_lSkillIndivisualInfo[skill_type], skill_indivisual_info)

		-- 성룡스킬이지만 새로 추가되는 일반 스킬인 경우
		elseif (add_type == 'new') then
			table.insert(self.m_lSkillIndivisualInfo[skill_type], skill_indivisual_info)

		-- 성룡 스킬이고 skill_1, skill_2를 가리킨다면 찾아서 바꿔줘야한다.
		elseif isExistValue(add_type, 'skill_1', 'skill_2') then
			local old_skill_id = self.m_charTable[add_type]
			local skill_info, idx = self:findSkillInfoByID(old_skill_id)
			old_skill_info = skill_info
			self.m_lSkillIndivisualInfo[skill_type][idx] = skill_indivisual_info
			
		end

    end

    -- 스킬 레벨 적용
    skill_indivisual_info:applySkillLevel()
	skill_indivisual_info:mergeSkillInfo(old_skill_info)

	-- 스킬 desc 세팅
	skill_indivisual_info:applySkillDesc()

	-- 맵으로 저장
	self.m_mSkillInfoMap[skill_id] = skill_indivisual_info
end

-------------------------------------
-- function unsetSkillID
-- @brief skill_id의 스킬을 삭제시킴
-------------------------------------
function IDragonSkillManager:unsetSkillID(skill_id)
    local skill_type = GetSkillTable(self.m_charType):getSkillType(skill_id)
    if (not self.m_lSkillIndivisualInfo[skill_type]) then return end

    -- 하나의 스킬만을 가지는 스킬 타입
	if isExistValue(skill_type, 'active', 'basic', 'leader') then
        self.m_lSkillIndivisualInfo[skill_type] = nil
    else
        for i, skill_info in ipairs(self.m_lSkillIndivisualInfo[skill_type]) do
		    if (skill_id == skill_info:getSkillID()) then
                table.remove(self.m_lSkillIndivisualInfo[skill_type], i)
                break
            end
        end
    end

    self.m_mSkillInfoMap[skill_id] = nil
end

-------------------------------------
-- function findSkillInfoByID
-- @brief 해당 skillID의 skill_individual_info를 찾는다.
-------------------------------------
function IDragonSkillManager:findSkillInfoByID(skill_id)
	if (not skill_id) then
		return
	end

    local skill_type = GetSkillTable(self.m_charType):getSkillType(skill_id)
    if (not self.m_lSkillIndivisualInfo[skill_type]) then return end
    
    -- 하나의 스킬만을 가지는 스킬 타입
	if isExistValue(skill_type, 'active', 'basic', 'leader') then
        local skill_info = self.m_lSkillIndivisualInfo[skill_type]
        return skill_info
    else
	    for i, skill_info in pairs(self.m_lSkillIndivisualInfo[skill_type]) do
		    if (skill_id == skill_info:getSkillID()) then
			    return skill_info, i
		    end		
	    end
    end
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
	if isExistValue(skill_type, 'active', 'basic', 'leader') then
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
-- function getSkillKeyList
-------------------------------------
function IDragonSkillManager:getSkillKeyList()
	local l_ret = {'Leader'}
    
	--[[
		인게임에서 리더 스킬을 참조할때는 leader를 사용하지만 
		UI에서는 node이름의 일관성을 위해 Leader를 사용한다.
		
		자세히 구분하자면 UI에서 스킬을 순서대로 찍기 위해 사용하는 
		getSkillIndivisualInfo_usingIdx에서 idx로 Leader를 받아오며
		skill_lv를 구할때도 key로 Leader를 사용하며
		
		인게임에서 리더 스킬을 참조하기 위해 사용하는 key는 leader이다.
	]]

    -- 여기서 0은 active를 의미한다.. 가능하면 바꾸고 싶지만 server와 이름이 일치하지 않는 문제가 생긴다.
	for i = 0, MAX_DRAGON_EVOLUTION do
		table.insert(l_ret, i)
	end

    return l_ret
end

-------------------------------------
-- function makeIndividualInfo
-------------------------------------
function IDragonSkillManager:makeIndividualInfo(skill_type, skill_id, skill_lv)
	local skill_indivisual_info = DragonSkillIndivisualInfo(self.m_charType, skill_type, skill_id, skill_lv)
	skill_indivisual_info:applySkillLevel()
	skill_indivisual_info:applySkillDesc()

	return skill_indivisual_info
end

-------------------------------------
-- function getSkillIndivisualInfo_usingIdx
-- @brief idx 보다는 key에 가까워 짐
-------------------------------------
function IDragonSkillManager:getSkillIndivisualInfo_usingIdx(idx)
    local t_character = self.m_charTable

	-- skill id 찾기
    local skill_id
	if (idx == 'Leader') then
		skill_id = t_character['skill_leader']

    elseif (idx == 'Basic') then
		skill_id = t_character['skill_basic']

    elseif (idx == 0) then
        skill_id = t_character['skill_active']

    else
        skill_id = t_character['skill_' .. idx]

    end

	-- skill type
	local skill_type = GetSkillTable(self.m_charType):getSkillType(skill_id)

    -- 성룡 진화 시 획득하는 스킬이 리더스킬인 경우 성룡 진화 전에는 뒤에 두고 진화 후에는 앞에 둔다.
    local evolution_lv = self.m_evolutionLv
    if (idx == 'Leader') and (skill_type == 'leader') then
        if (self:getSkillLevel('Leader') == 0) then
            return nil
        end
    elseif (idx == 3) and (skill_type == 'leader') then
        if (evolution_lv >= MAX_DRAGON_EVOLUTION) then 
            return nil
        end
    end

    -- 이미 skill_individual_info가 있는 경우
	local skill_indivisual_info = self:getSkillInfoByID(skill_id)
	if (skill_indivisual_info) then
		return skill_indivisual_info

	else
		-- UI용 skill_info 계산
		if (skill_type and skill_id ~= 0 and skill_id ~= '') then
			local skill_lv = self:getSkillLevel(idx)
			return self:makeIndividualInfo(skill_type, skill_id, skill_lv)
		end
	end
end

-------------------------------------
-- function getDragonSkillIconList
-------------------------------------
function IDragonSkillManager:getDragonSkillIconList()
    local l_skill_icon = {}

    for _, i in ipairs(self:getSkillKeyList()) do
        l_skill_icon[i] = self:makeSkillIcon_usingIndex(i)
    end

    return l_skill_icon
end

-------------------------------------
-- function makeSkillIcon_usingIndex
-- @brief 스킬 full ui 
-- @brief 인덱스를 키로 skill_individual_info를 가져와서 생성
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
-- function getDragonSkillImageList
-- @brief 이미지만 필요한 경우
-------------------------------------
function IDragonSkillManager:getDragonSkillImageList()
    local l_skill_image = {}

    for _, i in ipairs(self:getSkillKeyList()) do
        l_skill_image[i] = self:makeSkillImage_usingIndex(i)
    end

    return l_skill_image
end

-------------------------------------
-- function makeSkillImage_usingIndex
-- @brief 아이콘 이미지만 생성
-------------------------------------
function IDragonSkillManager:makeSkillImage_usingIndex(idx)
    local skill_indivisual_info = self:getSkillIndivisualInfo_usingIdx(idx)
    if skill_indivisual_info then
        local char_type = skill_indivisual_info.m_charType
        local skill_id = skill_indivisual_info.m_skillID
        local image = IconHelper:getSkillIcon(char_type, skill_id)
        return image
    else
        return nil
    end
end


-------------------------------------
-- function getDragonSkillIconList_NoLv
-------------------------------------
function IDragonSkillManager:getDragonSkillIconList_NoLv()
    local l_skill_icon = {}

    for _, i in ipairs(self:getSkillKeyList()) do
        l_skill_icon[i] = self:makeSkillIcon_usingIndex_NoLv(i)
    end

    return l_skill_icon
end

-------------------------------------
-- function makeSkillIcon_usingIndex_NoLv
-------------------------------------
function IDragonSkillManager:makeSkillIcon_usingIndex_NoLv(idx)
    local skill_indivisual_info = self:getSkillIndivisualInfo_usingIdx(idx)
    if skill_indivisual_info then
        local ui_dragon = UI_DragonSkillCard(skill_indivisual_info)
        ui_dragon:setNoLv()
        return ui_dragon
    else
        return nil
    end
end

-------------------------------------
-- function getSkillInfoByID
-------------------------------------
function IDragonSkillManager:getSkillInfoByID(skill_id)
    return self.m_mSkillInfoMap[skill_id]
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
	local skill_info = self.m_mSkillInfoMap[skill_id]
	if (skill_info) then
		return skill_info.m_tSkill
	end
end

















-------------------------------------
-- function checkSkillRate
-------------------------------------
function IDragonSkillManager:checkSkillRate(skill_type)
	local t_skill_info = self.m_lSkillIndivisualInfo[skill_type]
    if (not t_skill_info) then return end

    if (table.count(t_skill_info) > 0) then
        local sum_random = SumRandom()

        for i,v in pairs(self.m_lSkillIndivisualInfo[skill_type]) do
            if (v:isEndCoolTime()) then
                local rate = v.m_tSkill['chance_value']
                local skill_id = v.m_skillID
                sum_random:addItem(rate, skill_id)
            end
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
    if (not t_skill_info) then return end

	if (table.count(t_skill_info) > 0) then
        for i,v in pairs(t_skill_info) do
            if (v:isEndCoolTime() and not self.m_mReserveTurnSkillID[v.m_skillID]) then
                v.m_turnCount = (v.m_turnCount + 1)

                if (v.m_tSkill['chance_value'] <= v.m_turnCount) then
                    table.insert(self.m_lReserveTurnSkillID, v.m_skillID)

                    self.m_mReserveTurnSkillID[v.m_skillID] = true
                end
            end
        end

        if (self.m_lReserveTurnSkillID[1]) then
            local skill_id = table.remove(self.m_lReserveTurnSkillID, 1)
            self.m_mReserveTurnSkillID[skill_id] = nil

            return skill_id
        end
    end
    
	return nil
end

-------------------------------------
-- function getHpRateSkillID
-------------------------------------
function IDragonSkillManager:getHpRateSkillID(hp_rate)
    local skill_type = 'hp_rate'
	local t_skill_info = self.m_lSkillIndivisualInfo[skill_type]
    if (not t_skill_info) then return end

    local hp_rate = hp_rate * 100

    if (table.count(t_skill_info) > 0) then
        for i,v in pairs(t_skill_info) do
            if (v:isEndCoolTime()) then
                if (hp_rate <= v.m_hpRate) then
                    return v.m_skillID
                end
            end
        end
    end

    return nil
end

-------------------------------------
-- function getTimeOutSkillID
-------------------------------------
function IDragonSkillManager:getTimeOutSkillID()
    local skill_type = 'time_out'
	local t_skill_info = self.m_lSkillIndivisualInfo[skill_type]
    if (not t_skill_info) then return end

    if (table.count(t_skill_info) > 0) then
        for i,v in pairs(t_skill_info) do
            if (v:isEndCoolTime()) then
                return v.m_skillID
            end
        end
    end
end

-------------------------------------
-- function getHpRatePerSkillID
-------------------------------------
function IDragonSkillManager:getHpRatePerSkillID(hp_rate)
    local skill_type = 'hp_rate_per'
	local t_skill_info = self.m_lSkillIndivisualInfo[skill_type]
    if (not t_skill_info) then return end

    local hp_rate = hp_rate * 100

    if (table.count(t_skill_info) > 0) then
        for i,v in pairs(t_skill_info) do
            if (hp_rate <= v.m_hpRate) then
                v.m_hpRate = math_max(v.m_hpRate - v.m_tSkill['chance_value'], 0)

                -- 이미 스킬이 예약된 상태라면 연속으로 사용하지 않도록 막음
                if (v:isEndCoolTime() and not self.m_mReserveHpRatePerSkillID[v.m_skillID]) then
                    table.insert(self.m_lReserveHpRatePerSkillID, v.m_skillID)
                        
                    self.m_mReserveHpRatePerSkillID[v.m_skillID] = true
                end
            end
        end

        if (self.m_lReserveHpRatePerSkillID[1]) then
            local skill_id = table.remove(self.m_lReserveHpRatePerSkillID, 1)
            self.m_mReserveHpRatePerSkillID[skill_id] = nil

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
-- function getInterceptableSkillID
-- @return	skill_id
-------------------------------------
function IDragonSkillManager:getInterceptableSkillID(tParam)
    local tParam = tParam or {}
    local skill_id = nil

    -- time_out류 스킬
    if (not skill_id and tParam['time_out']) then
        skill_id = self:getTimeOutSkillID()
    end

    -- hp_rate_per류 스킬
    if (not skill_id and tParam['hp_rate']) then
        skill_id = self:getHpRatePerSkillID(tParam['hp_rate'])
    end

    -- hp_rate류 스킬
    if (not skill_id and tParam['hp_rate']) then
        skill_id = self:getHpRateSkillID(tParam['hp_rate'])
    end

    -- indie_time류 스킬
    if (not skill_id) then
        skill_id = self:getBasicTimeAttackSkillID()
    end

    return skill_id
end

-------------------------------------
-- function getBasicTimeAttackSkillID
-- @return	skill_id
-------------------------------------
function IDragonSkillManager:getBasicTimeAttackSkillID()
    if (not self.m_lSkillIndivisualInfo['indie_time']) then return end

    if (table.count(self.m_lSkillIndivisualInfo['indie_time']) > 0) then
        for i,v in pairs(self.m_lSkillIndivisualInfo['indie_time']) do
            if (v:isEndCoolTime()) then
                return v.m_skillID
            end
        end
    end
end

-------------------------------------
-- function updateBasicSkillTimer
-------------------------------------
function IDragonSkillManager:updateBasicSkillTimer(dt)
    if (not self.m_lSkillIndivisualInfo) then return end

    for type, list in pairs(self.m_lSkillIndivisualInfo) do
        if not isExistValue(type, 'active', 'basic', 'leader') then
            for _, v in pairs(list) do
                v:update(dt)
            end
        end
    end
end

-------------------------------------
-- function getCastTimeFromSkillID
-- @brief 해당 아이디 스킬의 캐스팅 시간을 얻는다
-------------------------------------
function IDragonSkillManager:getCastTimeFromSkillID(skill_id)
    local t_skill = GetSkillTable(self.m_charType):get(skill_id)
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
    if (not isExistValue(self.m_charType, 'dragon', 'tamer')) then
        return
    end

    cclog('########DragonSkillManager##############')
	cclog('name : ' .. self.m_charTable['t_name'])
	for type, skill in pairs(self.m_lSkillIndivisualInfo) do
		if isExistValue(type, 'active', 'basic', 'leader') then
			if self.m_lSkillIndivisualInfo[type] then
				cclog('type : ' .. type, 'skill : ' .. skill.m_tSkill['sid'] .. ' ' .. skill.m_tSkill['t_name'] .. ' lv.' .. skill.m_skillLevel)
			end
		else
			if (skill[1]) then 
				cclog('type : ' .. type, '')
				for i, skill2 in pairs(skill) do
					cclog('--> no.' .. i .. ' : ' .. skill2.m_tSkill['sid'] .. ' ' .. skill2.m_tSkill['t_name'] .. ' lv.' .. skill2.m_skillLevel)
				end
			end
		end
	end
	cclog('----------------------------------------')
end

-------------------------------------
-- function printSkillInfo
-------------------------------------
function IDragonSkillManager:printSkillInfo()
    cclog('-------------------------------------------------------')
    for k, v in pairs(self.m_lSkillIndivisualInfo) do
        if (type(v) == 'table') then
            cclog('TYPE : ' .. k)

            if isExistValue(k, 'active', 'basic', 'leader') then
                local t_skill = GetSkillTable(self.m_charType):get(v.m_skillID)

                cclog('## SKILL ID LIST : 1 ##')
                cclog(t_skill['t_name'] .. ' - ' .. v.m_skillID)
            else
                cclog('## SKILL ID LIST : ' .. table.count(v) .. ' ##')
                for _, skill_indivisual_info in pairs(v) do
                    local t_skill = GetSkillTable(self.m_charType):get(skill_indivisual_info.m_skillID)
                    
                    cclog(t_skill['t_name'] .. ' - ' .. skill_indivisual_info.m_skillID)
                end
            end
        end
    end
    cclog('=======================================================')
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
    local evolution_lv = evolution_lv
    dragon_skill_mgr:initDragonSkillManager(char_type, char_id, evolution_lv)

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
-- function MakeTamerSkillManager
-- @brief 테이머 스킬도 skillManager를 사용
-------------------------------------
function MakeTamerSkillManager(t_tamer)
    local tamer_id = t_tamer['tid']
    local skill_00_lv = t_tamer['skill_lv1']
    local skill_01_lv = t_tamer['skill_lv2']
    local skill_02_lv = t_tamer['skill_lv3']
    local skill_03_lv = t_tamer['skill_lv4']

	-- 드래곤 스킬 매니저 생성
	local dragon_skill_mgr = DragonSkillManager()

    -- 스킬 레벨 설정
    dragon_skill_mgr:setDragonSkillLevelList(skill_00_lv, skill_01_lv, skill_02_lv, skill_03_lv)

    -- 스킬들 설정
    local char_type = 'tamer'
    local char_id = tamer_id
    dragon_skill_mgr:initDragonSkillManager(char_type, char_id)

    return dragon_skill_mgr
end

-------------------------------------
-- function GetSkillTable
-------------------------------------
function GetSkillTable(char_type)
	if (char_type == 'dragon') then
		return TableDragonSkill()
	elseif (char_type == 'monster') then
		return TableMonsterSkill()
	elseif (char_type == 'tamer') then
		return TableTamerSkill()
	end
end


-------------------------------------
-- function TestDragonSkillManager
-------------------------------------
function TestDragonSkillManager(did)
    
    -- 드래곤 스킬 매니저 생성
    local dragon_skill_mgr = DragonSkillManager()

    -- 스킬 레벨 설정
    dragon_skill_mgr:setDragonSkillLevelList(5, 5, 5, 1)

    -- 스킬들 설정
    dragon_skill_mgr:initDragonSkillManager('dragon', did, 3)
end