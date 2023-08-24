-------------------------------------
---@class StructDragonObject
-- @instance dragon_obj
-------------------------------------
StructDragonObject = class({
        m_objectType = '',
        m_sortData = '',

        id = 'dragon_object_id',
        doid = 'dragon_object_id',

        data = '',

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
        -- 스킨 아이디
        dragon_skin = 'number',

        ----------------------------------------------
        -- 드래곤 둥지 등록 여부
        lair = 'boolean',

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

        -- cclog(key)
        -- cclog(v)

        self[key] = v
    end
end


-------------------------------------
-- function setRuneObjects
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
-- function getMasteryLevel
-- @breif 특성 레벨
-------------------------------------
function StructDragonObject:getMasteryLevel()
    return self['mastery_lv'] or 0
end

-------------------------------------
-- function getMasteryPoint
-- @breif 특성 스킬 포인트 (남은것)
-------------------------------------
function StructDragonObject:getMasteryPoint()
    return self['mastery_point'] or 0
end

-------------------------------------
-- function getMasterySkillsTable
-- @breif 특성 스킬 정보
-------------------------------------
function StructDragonObject:getMasterySkillsTable()
    return self['mastery_skills'] or {}
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
---@return StructFriendshipObject
-------------------------------------
function StructDragonObject:getFriendshipObject()
    if (isNullOrEmpty(self['friendship']['frarity'])) then
        self['friendship']['frarity'] = self:getRarity()
    end

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
-- function getDragonSkillLevelUpNum
---@return number
-------------------------------------
function StructDragonObject:getDragonSkillLevelUpNum()
    local result = 0
    for i = 0, 2 do
        if (self['skill_' .. i] > 0) then
            result = result + self['skill_' .. i] - 1
        end
    end

    return result
end


-------------------------------------
-- function getDragonSkillLeveSum
---@return number
-------------------------------------
function StructDragonObject:getDragonSkillLeveSum()
    local result = 0
    for i = 0, 2 do
        if (self['skill_' .. i] > 0) then
            result = result + self['skill_' .. i]
        end
    end

    return result
end


-------------------------------------
-- function getCombatPower
-- @breif
-------------------------------------
function StructDragonObject:getCombatPower(status_calc)
    local status_calc = (status_calc or MakeDragonStatusCalculator_fromDragonDataTable(self))
    local combat_power = status_calc:getCombatPower()

    local exclude_mastery = USE_NEW_COMBAT_POWER_CALC and USE_NEW_COMBAT_POWER_CALC or false

    if (exclude_mastery == true) then
        -- 스킬레벨 1당 전투력에 0.02의 배수를 적용한다.
        -- 스킬레벨은 도합 12(몬스터 제외)  스킬 레벨을 전부 올릴 경우 최종 전투력에 1.24배를 곱하게 된다.
        local coef_gap = 0.02
        local skill_coef = 1
        local total_skill_level = 0 --self['skill_0'] + self['skill_1'] + self['skill_2'] + self['skill_3']
        for i = 0, 3 do
            if self['skill_' .. tostring(i)] then
                total_skill_level = total_skill_level + self['skill_' .. tostring(i)]
            end
        end
        total_skill_level = math.max(total_skill_level - 4, 0)

        if (total_skill_level >= 14) then
            skill_coef = 1.28
        else
            skill_coef = (1 + coef_gap * total_skill_level)
        end

        --[[
        if IS_DEV_SERVER() then
            cclog(
            '도합스킬레벨 :: ' .. tostring(total_skill_level) .. 
            ' 스킬배율 :: ( ' .. tostring(skill_coef) .. ' )' .. 
            ' ... 총 전투력 :: ' .. tostring(combat_power * skill_coef))
        end]]

        return math_floor(combat_power * skill_coef)
    end

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
-- @breif 드래곤 속성
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
-- function getDoid
-- @breif
-------------------------------------
function StructDragonObject:getObjectId()
    return self['id']
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
-- function getSkinID
-------------------------------------
function StructDragonObject:getSkinID()
    return self['dragon_skin'] or 0
end

-------------------------------------
-- function isSkinOn
-------------------------------------
function StructDragonObject:isSkinOn(skin_id)
    return self:getSkinID() == skin_id
end

-------------------------------------
-- function setLock
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
-- function isMonster
-- @breif 
-------------------------------------
function StructDragonObject:isMonster()
    return TableDragon():isUnderling(self['did'])
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
    local attr = self:getAttr() --t_dragon['attr']

    -- 성체부터 외형변환 적용
    if (evolution == POSSIBLE_TRANSFORM_CHANGE_EVO) then
        evolution = self['transform'] or evolution
    end

    if self['dragon_skin'] ~= nil and self['dragon_skin'] > 0 then
        res = TableDragonSkin:getDragonSkinValue('res_icon', self['dragon_skin'])
    end

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

    grade = math.min(grade, 6)

    return string.format('card_star_%s_01%02d.png', color, grade)
end

-------------------------------------
-- function getIngameRes
-- @breif 로비의 리더 드래곤일시 따라다니는 드래곤 리소스 호출
-------------------------------------
function StructDragonObject:getIngameRes()
    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(self['did'])
    -- 외형 변환 적용
    local transform = self['transform']
    local evolution = transform and transform or self:getEvolution()

    local res = t_dragon['res']
    local attr = self:getAttr()

    if self['dragon_skin'] ~= nil and self['dragon_skin'] ~= 0 then 
        res = TableDragonSkin:getDragonSkinValue('res', self['dragon_skin'])
        attr = TableDragonSkin:getDragonSkinValue('attribute', self['dragon_skin'])
    end

    local res = AnimatorHelper:getDragonResName(res, evolution, attr)

    return res
end

-------------------------------------
-- function isAppearanceChanged
-- @breif 외형 변환 여부
---@return boolean
-------------------------------------
function StructDragonObject:isAppearanceChanged()
    local transform = self:getTransform()
    local evolution = self:getEvolution()

    return (transform ~= evolution)
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
-- function getDragonSortData_Illusion
-- @breif getDragonSortData에 환상던전 전용 드래곤이 추가된 버
-------------------------------------
function StructDragonObject:getDragonSortData_Illusion()
    if self.m_sortData then
        if (self.m_sortData['updated_at'] ~= self['updated_at']) then
            self.m_sortData = g_illusionDungeonData:makeDragonsSortData(self)
        end
        return self.m_sortData
    end

    local doid = self['id']

    if (not doid) or (doid == '') then
        self.m_sortData = g_illusionDungeonData:makeDragonsSortData(self)
        return self.m_sortData
    end

    -- 생성되지 않았으면 생성한 후 return
    self.m_sortData = g_illusionDungeonData:getDragonsSortData(doid)
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

    -- [ 드래곤 스킨 정보 ]
    local t5 = self:getSkinID()

    --cclog('token : ' .. t1 .. ';' .. t2 .. ';' .. t3 .. ';' .. t4 ..  t5)
    -- t1 + t2 + t3 + t4 + t5
    return t1 .. ';' .. t2 .. ';' .. t3 .. ';' .. t4 .. ';' .. t5
end

-------------------------------------
-- function parseDragonStringData
-- @brief 드래곤 토큰 문자열로 오브젝트 생성
-------------------------------------
function StructDragonObject:parseDragonStringData(str)
    local l_str = pl.stringx.split(str, ';')
    local l_key = {}

    local idx = 0
    local function getIdx()
        idx = (idx + 1)
        return idx
    end

    local function getValue(key, to_number)
        local value = l_str[l_key[key]]
        
        if to_number then
            return tonumber(value)
        else
            return value
        end
    end


    --121882; 
    --60;
    --0;
    --0;
    --0;
    --0;
    --3;
    --6;
    --1;
    --1;
    --1;
    --1;
    --3;
    --9;
    --0;
    --225;
    --13500;
    --225;
    --0;
    --710116:15:4:atk_add|492::cri_chance_add|8:hp_multi|5:accuracy_add|4:hp_add|1251;
    --711226:15:4:aspd_add|46::hp_multi|9:hp_add|650:avoid_add|6:accuracy_add|8;
    --710136:15:4:def_add|492::hp_multi|9:hp_add|1249:atk_add|9:aspd_add|6;
    --711246:15:4:hp_multi|46::hp_add|518:def_multi|10:resistance_add|1:atk_multi|6;
    --710156:15:4:hp_add|34440:def_add|13:atk_add|15:hit_rate_add|3:avoid_add|2:hp_multi|8;
    --710166:15:4:hp_multi|46::def_add|9:aspd_add|1:def_multi|10:cri_dmg_add|7


    l_key['did'] = getIdx()
    l_key['lv'] = getIdx()
    l_key['exp'] = getIdx()
    l_key['eclv'] = getIdx()
    l_key['rlv'] = getIdx()
    l_key['rexp'] = getIdx()
    l_key['evolution'] = getIdx()
    l_key['grade'] = getIdx()
    l_key['skill_0'] = getIdx()
    l_key['skill_1'] = getIdx()
    l_key['skill_2'] = getIdx()
    l_key['skill_3'] = getIdx()
    l_key['transform'] = getIdx()   
    l_key['flv'] = getIdx()
    l_key['fexp'] = getIdx()
    l_key['fatk'] = getIdx()
    l_key['fhp'] = getIdx()
    l_key['fdef'] = getIdx()
    l_key['mastery_lv'] = getIdx()
    l_key['rune_1'] = getIdx()
    l_key['rune_2'] = getIdx()
    l_key['rune_3'] = getIdx()
    l_key['rune_4'] = getIdx()
    l_key['rune_5'] = getIdx()
    l_key['rune_6'] = getIdx()
    l_key['dragon_skin'] = getIdx()

    local t_data = {}
    t_data['did'] = getValue('did', true)
    t_data['lv'] = getValue('lv', true)
    t_data['rlv'] = getValue('rlv', true)
    t_data['exp'] = getValue('exp', true)
    t_data['eclv'] = getValue('eclv', true)
    t_data['evolution'] = getValue('evolution', true)
    t_data['grade'] = getValue('grade', true)
    t_data['mastery_lv'] = getValue('mastery_lv', true)
    t_data['dragon_skin'] = getValue('dragon_skin', true)

    local struct_dragon_object = StructDragonObject(t_data)
    return struct_dragon_object
end

-------------------------------------
-- function isMaxGradeAndLv
-- @brief 최대 등급, 최대 레벨인지 확인 (6성 60레벨)
--        특성 시스템 활성 조건이기도 함
-- @return boolean
-------------------------------------
function StructDragonObject:isMaxGradeAndLv()
    -- 최대 등급보다 현재 등급이 낮을 경우 false
    if (self:getGrade() < MAX_DRAGON_GRADE) then
        return false
    end

    -- 최대 레벨보다 현재 레벨이 낮을 경우 false
    if (self:getLv() < dragonMaxLevel(MAX_DRAGON_GRADE)) then
        return false
    end

    return true
end

-------------------------------------
-- function isMaxAll
-- @brief 레벨, 등급, 스킬, 강화, 특성 모두 최대치
-- @return boolean
-------------------------------------
function StructDragonObject:isMaxAll()
    -- 달성하기 어려운 것 부터 확인

    -- 특성
    if (self:getMasteryLevel() < MAX_DRAGON_MASTERY) then
        return false
    end

    -- 강화
    if (self:getRlv() < MAX_DRAGON_REINFORCE) then
        return false
    end

    -- 모든 스킬 강화 완료
    if (self['skill_0'] < 5) then
        return false
    end
    if (self['skill_1'] < 5) then
        return false
    end
    if (self['skill_2'] < 5) then
        return false
    end

    -- 최대 등급보다 현재 등급이 낮을 경우 false
    if (self:getGrade() < MAX_DRAGON_GRADE) then
        return false
    end

    -- 최대 레벨보다 현재 레벨이 낮을 경우 false
    if (self:getLv() < dragonMaxLevel(MAX_DRAGON_GRADE)) then
        return false
    end

    return true
end

-------------------------------------
-- function isLimited
-- @brief 한정 드래곤 여부
-- @return boolean
-------------------------------------
function StructDragonObject:isLimited()
    return TableDragon:getValue(self['did'], 'category') == 'limited'
end

-------------------------------------
-- function getMasterySkilLevel
-- @brief 특성 스킬 아이디로 레벨
-- @return number
-------------------------------------
function StructDragonObject:getMasterySkilLevel(mastery_skill_id)
    if (not self['mastery_skills']) then
        return 0
    end

    -- mastery_skill_id가 number type일 경우
    local mastery_skill_lv = self['mastery_skills'][mastery_skill_id]
    if mastery_skill_lv then
        return mastery_skill_lv
    end

    -- mastery_skill_id가 string type일 경우
    mastery_skill_lv = self['mastery_skills'][tostring(mastery_skill_id)]
    if mastery_skill_lv then
        return mastery_skill_lv
    end

    return 0
end

-------------------------------------
-- function getReinforceGoldCost
-- @brief 드래곤 강화 비용 계산
-- @return number, bool
-------------------------------------
function StructDragonObject:getReinforceGoldCost()
    local did = self:getDid()
	local rlv = self:getRlv()

    local req_gold = TableDragonReinforce:getCurrCost(did, rlv)

    -- 할인 핫타임
	local active, dc_value, _ = g_fevertimeData:isActiveFevertimeByType(FEVERTIME_SALE_EVENT.REINFORCE_DC)
    if (active) then
		req_gold = req_gold * (1 - dc_value)
	end

    return req_gold, active
end

-------------------------------------
-- function getMasteryLvUpAmorAndGoldCost
-- @brief 드래곤 특성 레벨업 비용 계산
-- @return number, number, bool
-------------------------------------
function StructDragonObject:getMasteryLvUpAmorAndGoldCost()
    local rarity_str = self:getRarity()
    local mastery_level = self:getMasteryLevel()

    local req_amor, req_gold = TableMastery:getRequiredAmorQuantity(rarity_str, mastery_level + 1)

    -- 할인 핫타임
	local active, dc_value, _ = g_fevertimeData:isActiveFevertimeByType(FEVERTIME_SALE_EVENT.MASTERY_DC)
    if (active) then
		req_gold = req_gold * (1 - dc_value)
	end

    return req_amor, req_gold, active
end

-------------------------------------
-- function isRaisedByUser
-- @brief 드래곤이 성장되었는지 확인
-- @brief 룬 장착 여부, 레벨, 경험치, 진화, 친밀도, 강화, 스킬 레벨업 여부 체크
-------------------------------------
function StructDragonObject:isRaisedByUser()
    -- 레벨
    if (self:getLv() > 1) then
        return true
    end

    -- 경험치
    if (self['exp'] > 0) then
        return true
    end

    -- 진화
    if (self['evolution'] > 1) then
        return true
    end

    -- 등급
    if (self['grade'] ~= self:getBirthGrade()) then
        return true
    end

    -- 친밀도
    if (self['friendship']['flv'] > 0) or (self['friendship']['fexp'] > 0) then
        return true
    end

    -- 강화
    if (self['reinforce']['lv'] > 0) or (self['reinforce']['exp'] > 0) then
        return true
    end

    -- 스킬 레벨업
    for skill_idx = 0, 3 do
        if (self['skill_' .. skill_idx] > 1) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function isRuneEquipped
-- @brief 룬 장착 여부
-------------------------------------
function StructDragonObject:isRuneEquipped()
    if (self['runes'] == nil) then return false end

    for slot_idx = 1, 6 do
        local roid = self['runes'][tostring(slot_idx)] or ''
        if (roid ~= '') then
            return true
        end
    end

    return false
end

-------------------------------------
-- function isSkinEquipped
-- @brief 스킨 장착 여부
-------------------------------------
function StructDragonObject:isSkinEquipped()
    if (self['dragon_skin'] ~= nil) and (self['dragon_skin'] ~= 0) then
        return true
    end

    return false
end

-------------------------------------
-- function getCreatedTimestampMillisec
-- @brief 드래곤 생성 시간
---@return number
-------------------------------------
function StructDragonObject:getCreatedTimestampMillisec()
    return self['created_at']
end
-------------------------------------
-- function getUpdatedTimestampMillisec
-- @brief 드래곤 최근 정보 갱신 시간
---@return number
-------------------------------------
function StructDragonObject:getUpdatedTimestampMillisec()
    return self['updated_at']
end
-------------------------------------
-- function getPlayedTimestampMillisec
-- @brief 최근 드래곤 사용 시간
---@return number
-------------------------------------
function StructDragonObject:getPlayedTimestampMillisec()
    return self['played_at']
end