-------------------------------------
-- class StructDragonObject
-- @instance dragon_obj
-------------------------------------
StructDragonObject = class({
        m_objectType = '',

        id = 'dragon_object_id',
        doid = 'dragon_object_id',

        did = 'number', -- 드래곤 ID
        lv = 'number',
        exp = 'number',
        grade = 'number', -- 승급 단계
        evolution = 'number', -- 진화 단계
        eclv = 'number', -- 초월 단계

        runes = 'table', -- 장착 룬 roid

        skill_0 = 'number',
        skill_1 = 'number',
        skill_2 = 'number',
        skill_3 = 'number',

        -- 리더 설정 정보
        leader = '',

        updated_at = 'timestamp',
        created_at = 'timestamp',
		played_at = 'timestamp',

        ----------------------------------------------
        -- 룬정보
        m_mRuneObjects = 'map', -- key roid, value rune object

        ----------------------------------------------
        -- 아직 안쓰는 정보
        lock = '',
        friendship = '',
        rlv = '',

        ----------------------------------------------
        -- 지울 것들
        uid = '',
        train_slot = '',
        train_max_reward = '',
        rune_set = '',
    })

-------------------------------------
-- function init
-------------------------------------
function StructDragonObject:init(data)
    self.m_objectType = 'dragon'
    self.rlv = 0
    self.lv = 0
    self.grade = 0
    self.m_mRuneObjects = nil

    if data then
        self:applyTableData(data)
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

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function setDragonResearchLevel
-- @breif
-------------------------------------
function StructDragonObject:setDragonResearchLevel(rlv, updated_at)
    self.rlv = rlv
    self.updated_at = (updated_at or Timer:getServerTime())
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
-- function getCombatPower
-- @breif
-------------------------------------
function StructDragonObject:getCombatPower()
    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(self)
    local combat_power = status_calc:getCombatPower()
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
-- function isLeader
-- @breif
-------------------------------------
function StructDragonObject:isLeader()
    return (self['leader'] and (0 < table.count(self['leader'])))
end