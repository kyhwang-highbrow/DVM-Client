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