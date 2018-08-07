-------------------------------------
-- class StructDragonObject
-- @instance dragon_obj
-------------------------------------
StructDragonObject = class({
        m_objectType = '',
        m_sortData = '',

        id = 'dragon_object_id',
        doid = 'dragon_object_id',

        did = 'number', -- 드래곤 ID
        lv = 'number',
        exp = 'number',
        grade = 'number', -- 승급 단계
        evolution = 'number', -- 진화 단계
        eclv = 'number', -- 초월 단계
        friendship = '',
        reinforce = 'number', -- 강화 단계
        transform = 'number',-- 외형 변환
        
		rlv = '',	-- 타인의 리더 드래곤 아이콘용 강화 레벨

		lock = 'boolean', -- 잠금

        runes = 'table', -- 장착 룬 roid

        skill_0 = 'number',
        skill_1 = 'number',
        skill_2 = 'number',
        skill_3 = 'number',

        mastery_lv = 'number',-- 특성 레벨
        mastery_point = 'number', -- 특성 포인트(남은 것)
        mastery_skills = 'table', -- 특성 스킬별 레벨

        -- 리더 설정 정보
        leader = '',

        updated_at = 'timestamp',
        created_at = 'timestamp',
		played_at = 'timestamp',

        ----------------------------------------------
        -- 룬정보
        m_mRuneObjects = 'map', -- key roid, value rune object

        ----------------------------------------------
        -- 드래곤의 숲에서 사용
        happy_at = 'timestapm',

        ----------------------------------------------
        -- 지울 것들
        uid = '',
        train_slot = '',
        train_max_reward = '',
    })

-------------------------------------
-- function init
-------------------------------------
function StructDragonObject:init(data)
    self.m_objectType = 'dragon'
    self.lv = 0
    self.grade = 0
    self.evolution = 1
    self.eclv = 0
    self.rlv = 0
    self.m_mRuneObjects = nil
  
    if data then
        self:applyTableData(data)
    end

	-- 드래곤 강화
	if (self['reinforce']) then
		self['reinforce'] = StructReinforcement(self['reinforce'])
	end

    -- 친밀도 오브젝트 생성
    self['friendship'] = StructFriendshipObject(self['friendship'])
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructDragonObject:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    --replacement['id'] = 'doid'

	-- 구조를 살짝 바꿔준다
    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end


-------------------------------------
-- function getRuneObject
-- @breif
-------------------------------------
function StructDragonObject:setRuneObjects(list)
    if (not list) then return end

    self.m_mRuneObjects = {}

    for _, v in ipairs(list) do
        local roid = v['id']

        self.m_mRuneObjects[roid] = StructRuneObject(v)
    end
end

-------------------------------------
-- function getRuneObjectList
-- @breif
-------------------------------------
function StructDragonObject:getRuneObjectList()
    if (not self['runes']) then
        return {}
    end

    local l_rune_obj = {}

    for _,roid in pairs(self['runes']) do
        local rune_obj = self:getRuneObject(roid)
        if rune_obj then
            table.insert(l_rune_obj, rune_obj)
        end
    end

    return l_rune_obj
end

-------------------------------------
-- function getRuneObject
-- @breif
-------------------------------------
function StructDragonObject:getRuneObject(roid)
    if (not roid) then
        return nil
    end

    if (roid == '') then
        return nil
    end

    -- 드래곤 오브젝트 객체에 룬 객체를 가지고 있을 경우 (친구나 다른 유저의 정보)
    if self.m_mRuneObjects then
        if self.m_mRuneObjects[roid] then
            return self.m_mRuneObjects[roid]
        end
    end

    -- 유저의 룬을 찾음
    return g_runesData:getRuneObject(roid)
end

-------------------------------------
-- function getRuneObjectBySlot
-- @breif
-------------------------------------
function StructDragonObject:getRuneObjectBySlot(slot)
    if (not self['runes']) then
        return nil
    end
    
    local roid = self['runes'][tostring(slot)]
    return self:getRuneObject(roid)
end


-------------------------------------
-- function getStructRuneSetObject
-- @breif
-------------------------------------
function StructDragonObject:getStructRuneSetObject()
    local rune_set_obj = StructRuneSetObject()
    local rune_obj_list = self:getRuneObjectList()
    rune_set_obj:setRuneObjectList(rune_obj_list)
    return rune_set_obj
end

-------------------------------------
-- function getRuneStatus
-- @breif
-------------------------------------
function StructDragonObject:getRuneStatus()
    local l_rune_obj = self:getRuneObjectList()

    local l_add_status = {}
    local l_multi_status = {}

    -- 개별 룬들의 능력치 합산
    for _,rune_obj in pairs(l_rune_obj) do
        local _l_add_status, _l_multi_status = rune_obj:getRuneStatus()

        for key,value in pairs(_l_add_status) do
            if (not l_add_status[key]) then
                l_add_status[key] = 0
            end
            l_add_status[key] = l_add_status[key] + value
        end

        for key,value in pairs(_l_multi_status) do
            if (not l_multi_status[key]) then
                l_multi_status[key] = 0
            end
            l_multi_status[key] = l_multi_status[key] + value
        end
    end

    do -- 룬 세트 능력치 합산
        local _l_add_status, _l_multi_status = self:getRuneSetStatus()

        for key,value in pairs(_l_add_status) do
            if (not l_add_status[key]) then
                l_add_status[key] = 0
            end
            l_add_status[key] = l_add_status[key] + value
        end

        for key,value in pairs(_l_multi_status) do
            if (not l_multi_status[key]) then
                l_multi_status[key] = 0
            end
            l_multi_status[key] = l_multi_status[key] + value
        end
    end

    return l_add_status, l_multi_status
end

-------------------------------------
-- function getRuneSetStatus
-- @breif
-------------------------------------
function StructDragonObject:getRuneSetStatus()
    local rune_set_obj = self:getStructRuneSetObject()
    local l_add_status, l_multi_status = rune_set_obj:getRuneSetStatus()
    return l_add_status, l_multi_status
end

-------------------------------------
-- function getRuneSetSkill
-- @breif
-------------------------------------
function StructDragonObject:getRuneSetSkill()
    local rune_set_obj = self:getStructRuneSetObject()
    local m_skill_id = rune_set_obj:getRuneSetSkill()
    return m_skill_id
end

-------------------------------------
-- function getMasterySkillStatus
-- @breif
-------------------------------------
function StructDragonObject:getMasterySkillStatus(game_mode)
    local mastery_skills = self['mastery_skills'] or {}
    
    local table_option = TableOption()
    local table_mastery_skill = TableMasterySkill()
    
    local l_add_status = {}
    local l_multi_status = {}
    
    -- 특성 스킬 능력치 합산
    for mastery_id, lv in pairs(mastery_skills) do
        local option, value, _game_mode = table_mastery_skill:getMasterySkillStatus(tonumber(mastery_id), lv)

        if (not _game_mode or _game_mode == game_mode) then
            local stat_type = table_option:getValue(option, 'status')
            local action = table_option:getValue(option, 'action')

            if (stat_type) then
                if (action == 'add') then
                    if (not l_add_status[stat_type]) then
                        l_add_status[stat_type] = 0
                    end
                    l_add_status[stat_type] = l_add_status[stat_type] + value

                elseif (action == 'multi') then
                    if (not l_multi_status[stat_type]) then
                        l_multi_status[stat_type] = 0
                    end
                    l_multi_status[stat_type] = l_multi_status[stat_type] + value

                else
                    error('# action : ' .. action)

                end
            end
        end
    end

    --cclog('l_add_status : ' .. luadump(l_add_status))
    --cclog('l_multi_status : ' .. luadump(l_multi_status))
    
    return l_add_status, l_multi_status
end

-------------------------------------
-- function getFriendshipObject
-- @breif
-------------------------------------
function StructDragonObject:getFriendshipObject()
    return self['friendship']
end

-------------------------------------
-- function getFlv
-- @breif
-------------------------------------
function StructDragonObject:getFlv()
    return self['friendship']['flv']
end

-------------------------------------
-- function getReinforceObject
-- @breif
-------------------------------------
function StructDragonObject:getReinforceObject()
	return self['reinforce']
end

-------------------------------------
-- function getRlv
-- @breif
-------------------------------------
function StructDragonObject:getRlv()
	if (self['reinforce']) then
		return self['reinforce']:getRlv()
	else
		return self['rlv']
	end
end

-------------------------------------
-- function getLvText
-- @breif Lv.60 +6 텍스트 생성
-- @param use_rich : rich_text 사용 여부
-------------------------------------
function StructDragonObject:getLvText(use_rich)
	local lv = self:getLv()
	local rlv = self:getRlv()
    local lv_str

	-- 강화 렙 있는 경우
	if (rlv > 0) then
		if (use_rich) then
			lv_str = string.format('{@default}Lv. %d {@light_green}+%d', lv, rlv)
		else
			lv_str = string.format('Lv. %d +%d', lv, rlv)
		end
	
	-- 무강
	else
		lv_str = string.format('Lv. %d', lv)

	end

	return lv_str
end

-------------------------------------
-- function isMaxRlv
-- @breif
-------------------------------------
function StructDragonObject:isMaxRlv()
	local rlv = self:getRlv()
	return (MAX_DRAGON_REINFORCE <= rlv)
end

-------------------------------------
-- function getRexp
-- @breif
-------------------------------------
function StructDragonObject:getRexp()
	if (self['reinforce']) then
		return self['reinforce']:getExp()
	end
end

-------------------------------------
-- function getReinforceMulti
-- @breif
-------------------------------------
function StructDragonObject:getReinforceMulti()
	local reinforce_obj = self['reinforce']
	if (not reinforce_obj) then
		return {['atk'] = 0, ['def'] = 0, ['hp'] = 0}
	end
	local t_reinforce_rate = TableDragonReinforce:getReinforceRateTable(self['did'], reinforce_obj:getRlv())
	return t_reinforce_rate
end

-------------------------------------
-- function getCombatPower
-- @breif
-------------------------------------
function StructDragonObject:getCombatPower(status_calc)
    local status_calc = (status_calc or MakeDragonStatusCalculator_fromDragonDataTable(self))
    local combat_power = status_calc:getCombatPower()
    
    -- 스킬 레벨에 따른 전투력 추가
    do
        local t_dragon = TableDragon():get(self['did'])
        local table = g_constant:get('UI', 'DRAGON_SKILL_COMBAT_POWER')
        local str_rarity = self:getRarity()
        local modified_rarity = 5 - evolutionStoneRarityStrToNum(str_rarity)

        local dragon_skill_mgr = MakeDragonSkillFromDragonData(self)
        local skill_indivisual_info
    
        -- 리더
        skill_indivisual_info = dragon_skill_mgr:getSkillIndivisualInfo('leader')
        if (skill_indivisual_info) then
            combat_power = combat_power + table['LEADER'][modified_rarity]
        end

        -- 드래그
        skill_indivisual_info = dragon_skill_mgr:getSkillIndivisualInfo('active')
        if (skill_indivisual_info) then
            local lv = self['skill_0']
            combat_power = combat_power + table['DRAG'][modified_rarity] + table['DRAG_ADD'][modified_rarity] * (lv - 1)
        
            -- 드래그 강화된 경우
            if (self['skill_3'] > 0 and t_dragon['skill_3_type'] == 'skill_active') then
                combat_power = combat_power + table['DRAG_UPGRADE'][modified_rarity]
            end
        end

        -- 패시브 1
        if (self['skill_1'] and self['skill_1'] > 0) then
            local lv = self['skill_1']
            combat_power = combat_power + table['PASSIVE1'][modified_rarity] + table['PASSIVE1_ADD'][modified_rarity] * (lv - 1)
        end

        -- 패시브 2
        if (self['skill_2'] and self['skill_2'] > 0) then
            local lv = self['skill_2']
            combat_power = combat_power + table['PASSIVE2'][modified_rarity] + table['PASSIVE2_ADD'][modified_rarity] * (lv - 1)
        end

        -- 패시브 3
        if (t_dragon['skill_3_type'] == 'new' and t_dragon['skill_3'] ~= t_dragon['skill_leader']) then
            if (self['skill_3'] and self['skill_3'] > 0) then
                local lv = self['skill_3']
                combat_power = combat_power + table['PASSIVE2'][modified_rarity] + table['PASSIVE2_ADD'][modified_rarity] * (lv - 1)
            end
        end
    end

    return combat_power
end

-------------------------------------
-- function getDragonNameWithEclv
-- @breif
-------------------------------------
function StructDragonObject:getDragonNameWithEclv()
    local dragon_name = TableDragon:getDragonName(self['did'])

    if (self['eclv'] > 0) then
        dragon_name = dragon_name .. ' +' .. self['eclv']
    end

    return dragon_name
end

-------------------------------------
-- function isNewDragon
-- @breif
-------------------------------------
function StructDragonObject:isNewDragon()
    local doid = self['id']

    if (not doid) then
        return
    end

    return g_highlightData:isNewDoid(doid)
end

-------------------------------------
-- function isNotiDragon
-- @breif
-------------------------------------
function StructDragonObject:isNotiDragon()
    local doid = self['id']

    return g_dragonsData:possibleUpgradeable(doid) or g_dragonsData:possibleDragonEvolution(doid) or g_dragonsData:possibleDragonSkillEnhance(doid)
end

-------------------------------------
-- function getRole
-- @breif
-------------------------------------
function StructDragonObject:getRole()
    return TableDragon:getValue(self['did'], 'role')
end

-------------------------------------
-- function getAttr
-- @breif
-------------------------------------
function StructDragonObject:getAttr()
    return TableDragon:getValue(self['did'], 'attr')
end

-------------------------------------
-- function getRarity
-- @breif
-------------------------------------
function StructDragonObject:getRarity()
    return TableDragon:getValue(self['did'], 'rarity')
end

-------------------------------------
-- function getBirthGrade
-- @breif
-------------------------------------
function StructDragonObject:getBirthGrade()
    return TableDragon:getValue(self['did'], 'birthgrade')
end

-------------------------------------
-- function getDid
-- @breif
-------------------------------------
function StructDragonObject:getDid()
    return self['did']
end

-------------------------------------
-- function getEclv
-- @breif
-------------------------------------
function StructDragonObject:getEclv()
    return self['eclv']
end

-------------------------------------
-- function getGrade
-- @breif
-------------------------------------
function StructDragonObject:getGrade()
    return self['grade']
end

-------------------------------------
-- function getEvolution
-- @breif
-------------------------------------
function StructDragonObject:getEvolution()
    return self['evolution']
end

-------------------------------------
-- function getTransform
-- @breif
-------------------------------------
function StructDragonObject:getTransform()
    return self['transform']
end

-------------------------------------
-- function getLv
-- @breif
-------------------------------------
function StructDragonObject:getLv()
    return self['lv']
end

-------------------------------------
-- function getLock
-- @breif
-------------------------------------
function StructDragonObject:getLock()
    return self['lock']
end

-------------------------------------
-- function setLock
-- @breif
-------------------------------------
function StructDragonObject:setLock(b)
    self['lock'] = b
end

-------------------------------------
-- function isFarmer
-- @breif 쫄작가능 드래곤 (dragon farming -> farmer)
-------------------------------------
function StructDragonObject:isFarmer()
    return (self['grade'] >= 6)
end

-------------------------------------
-- function isPossibleTransformChange
-- @breif
-------------------------------------
function StructDragonObject:isPossibleTransformChange()
    local is_undering = TableDragon():isUnderling(self['did'])
    local is_possible = (not is_undering) and (self['evolution'] >= POSSIBLE_TRANSFORM_CHANGE_EVO)
    return is_possible
end

-------------------------------------
-- function getIconRes
-- @breif
-------------------------------------
function StructDragonObject:getIconRes()
    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(self['did'])

    local res = t_dragon['icon']
    local evolution = self['evolution']
    local attr = t_dragon['attr']

    res = string.gsub(res, '#', '0' .. evolution)
    res = string.gsub(res, '@', attr)

    return res
end

-------------------------------------
-- function getGradeRes
-- @breif 등급 별 리소스 생성
-------------------------------------
function StructDragonObject:getGradeRes()
    -- 기본 정보
    local grade = tonumber(self['grade'] or 1)
	local evolution = tonumber(self['evolution'])

    -- grade의 0을 넣는 경우도 있다..!
    if (grade <= 0) then
        return
    end

    -- 색상을 구함
	local color
	if (evolution == 1) then
		if (TableDragon():isUnderling(self['did'])) then
			color = 'gray'
		elseif (self['m_objectType'] == 'slime') then
			color = 'gray'
		else
			color = 'yellow'
		end
	elseif (evolution == 2) then
		color = 'purple'
	elseif (evolution == 3) then
		color = 'red'
	end

    return string.format('card_star_%s_01%02d.png', color, grade)
end

-------------------------------------
-- function getIngameRes
-- @breif
-------------------------------------
function StructDragonObject:getIngameRes()
    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(self['did'])
    -- 외형 변환 적용
    local transform = self['transform']
    local evolution = transform and transform or self:getEvolution()
    local res = AnimatorHelper:getDragonResName(t_dragon['res'], evolution, t_dragon['attr'])
    return res
end

-------------------------------------
-- function isLeader
-- @breif
-------------------------------------
function StructDragonObject:isLeader()
    return (self['leader'] and (0 < table.count(self['leader'])))
end

-------------------------------------
-- function getObjectType
-- @breif
-------------------------------------
function StructDragonObject:getObjectType()
    return self['m_objectType']
end

-------------------------------------
-- function getDragonSortData
-- @breif
-------------------------------------
function StructDragonObject:getDragonSortData()
    if self.m_sortData then
        if (self.m_sortData['updated_at'] ~= self['updated_at']) then
            self.m_sortData = g_dragonsData:makeDragonsSortData(self)
        end
        return self.m_sortData
    end

    local doid = self['id']

    if (not doid) or (doid == '') then
        self.m_sortData = g_dragonsData:makeDragonsSortData(self)
        return self.m_sortData
    end

    -- 생성되지 않았으면 생성한 후 return
    self.m_sortData = g_dragonsData:getDragonsSortData(doid)
    return self.m_sortData
end

-------------------------------------
-- function getStringData
-------------------------------------
function StructDragonObject:getStringData()
	local rlv = self['reinforce']:getRlv()
	local rexp = self['reinforce']:getExp()

    -- [ 드래곤 정보 ]
    -- did;lv;exp;eclv;rlv;rexp;evolution;grade;skill_0;skill_1;skill_2;skill_3;transform
    local t1 = string.format('%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d', 
        self['did'],
        self['lv'],
        self['exp'],
        self['eclv'],
		rlv,
		rexp,
        self['evolution'],
        self['grade'],
        self['skill_0'],
        self['skill_1'],
        self['skill_2'],
        self['skill_3'],
        self['transform']
    )

    -- [ 친밀도 정보 ]
    -- flv;fexp;fatk;fhp;fdef
    local t2 = self['friendship']:getStringData()

    -- [ 특성 레벨 ]
    local t3 = self['mastery_lv']

    -- [ 룬 정보 ]
    -- rid:lv:rarity:mopt:uopt:sopt_1:sopt_2:sopt_3:sopt_4
    local t4 = ''
    do
        local is_first = true

        for i = 1, 6 do
            if (not is_first) then
                t4 = t4 .. ';'
            end

            local rune = self:getRuneObjectBySlot(i)
            if (rune) then
                t4 = t4 .. rune:getStringData()
            end

            is_first = false
	    end
    end

    -- [ 특성 스킬 정보 ]
    -- mastery_id:mastery_lv
    -- !!룬정보 뒤에 추가되는데 특성 스킬이 없을 경우 마지막에 ;이 안붙도록 해야함
    do
        local mastery_skills = self['mastery_skills'] or {}
        
        -- id 순으로 정렬
        local t_sorted = {}
        for mastery_id, mastery_lv in pairs(mastery_skills) do
            table.insert(t_sorted, tonumber(mastery_id))
        end
        table.sort(t_sorted, function(a, b) return a < b end)

        for _, mastery_id in ipairs(t_sorted) do
            local mastery_lv = mastery_skills[tostring(mastery_id)]
            t4 = t4 .. ';' .. mastery_id .. ':' .. mastery_lv
        end
    end

    --cclog('token : ' .. t1 .. ';' .. t2 .. ';' .. t3 .. ';' .. t4)

    -- t1 + t2 + t3 + t4
    return t1 .. ';' .. t2 .. ';' .. t3 .. ';' .. t4
end

-------------------------------------
-- function isMaxGradeAndLv()
-- @brief 최대 등급, 최대 레벨인지 확인 (6성 60레벨)
--        특성 시스템 활성 조건이기도 함
-- @return boolean
-------------------------------------
function StructDragonObject:isMaxGradeAndLv()
    local max_grade = MAX_DRAGON_GRADE

    -- 최대 등급보다 현재 등급이 낮을 경우 false
    if (self:getGrade() < max_grade) then
        return false
    end

    local max_lv = dragonMaxLevel(max_grade)
    -- 최대 레벨보다 현재 레벨이 낮을 경우 false
    if (self:getLv() < max_lv) then
        return false
    end

    return true
end