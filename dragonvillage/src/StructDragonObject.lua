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
        -- 아직 안쓰는 정보
        lock = '',
        friendship = '',

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