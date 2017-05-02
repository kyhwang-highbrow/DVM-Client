-------------------------------------
-- class StructSlimeObject
-- @instance dragon_obj
-------------------------------------
StructSlimeObject = class({
        m_objectType = '',

        id = 'slime_object_id',
        soid = 'slime_object_id',

        slime_id = 'number',
        lv = 'number',
        exp = 'number',
        grade = 'number', -- 승급 단계
        evolution = 'number', -- 진화 단계

        updated_at = 'timestamp',
        created_at = 'timestamp',

        -- 지울 것들
        uid = '',


        -- 드래곤인척 하기 위해
        did = '',
    })

-------------------------------------
-- function init
-------------------------------------
function StructSlimeObject:init(data)
    self.m_objectType = 'slime'

    if data then
        self:applyTableData(data)
    end

    self.soid = self.id
    self.did = self.slime_id
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructSlimeObject:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    --replacement['id'] = 'soid'

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function getFlv
-- @breif 드래곤인척하기위해
-------------------------------------
function StructSlimeObject:getFlv()
    return 0
end

-------------------------------------
-- function getRole
-- @breif
-------------------------------------
function StructSlimeObject:getRole()
    return TableSlime:getValue(self['slime_id'], 'role')
end

-------------------------------------
-- function getAttr
-- @breif
-------------------------------------
function StructSlimeObject:getAttr()
    return TableSlime:getValue(self['slime_id'], 'attr')
end

-------------------------------------
-- function getRarity
-- @breif
-------------------------------------
function StructSlimeObject:getRarity()
    return TableSlime:getValue(self['slime_id'], 'rarity')
end

-------------------------------------
-- function getDragonNameWithEclv
-- @breif
-------------------------------------
function StructSlimeObject:getDragonNameWithEclv()
    local name = TableSlime:getValue(self['slime_id'], 't_name')
    return name
end

-------------------------------------
-- function getEclv
-- @breif
-------------------------------------
function StructSlimeObject:getEclv()
    return 0
end

-------------------------------------
-- function getGrade
-- @breif
-------------------------------------
function StructSlimeObject:getGrade()
    return self['grade']
end

