-------------------------------------
-- class StructDragonObject
-- @instance dragon_obj
-------------------------------------
StructDragonObject = class({
        id = 'dragon_object_id',
        doid = 'dragon_object_id',

        did = 'number', -- 드래곤 ID
        lv = 'number',
        exp = 'number',
        grade = 'number', -- 승급 단계
        evolution = 'number', -- 진화 단계
        eclv = 'number', -- 초월 단계

        runes = 'table', -- 장착 룬 roid

        -- 친밀도
        flv = 'number',
        fexp = 'number',
        can_rollback = 'boolean',
        def = '',
        atk = '',
        hp = '',

        skill_0 = 'number',
        skill_1 = 'number',
        skill_2 = 'number',
        skill_3 = 'number',

        -- 리더 설정 정보
        leader = '',

        updated_at = 'timestamp',
        created_at = 'timestamp',

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
    self.m_mRuneObjects = nil

    if data then
        self:applyTableData(data)
    end
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