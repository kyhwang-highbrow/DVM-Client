-------------------------------------
-- class StructRuneObject
-- @instance rune_obj
-------------------------------------
StructRuneObject = class({
        -- 룬 오브젝트 ID
        roid = 'rune_object_id',

        rid = 'number',     -- 룬 ID
        lv = 'number',      -- 강화 단계
        rarity = 'number',  -- 레어도

        -- 메인 옵션
        mopt = 'string',

        -- 유니크 옵션 (접두어를 결정하는 옵션)
        uopt = 'string',

        -- 서브 옵션
        sopt_1 = 'string',
        sopt_2 = 'string',
        sopt_3 = 'string',
        sopt_4 = 'string',

        ---------------------------------------------
        created_at = 'timestamp',
        updated_at = 'timestamp',
        ---------------------------------------------

        slot = 'number',    -- 슬롯 ID 1 ~ 6
        grade = 'number',   -- 등급 1~6
        set_id = 'number',  -- 세트 ID 1~8

        item_id = 'number',

        name = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function StructRuneObject:init(data)
    if data then
        self:applyTableData(data)
    end

    local rid = self['rid']

    -- 아이템ID는 룬ID와 동일하게 사용
    self['item_id'] = rid

    -- 룬 ID를 통해 세트ID, 슬롯, 등급 정보를 가져옴
    -- 710111
    -- 71xxxx -- 룬 아이디 식별 코드
    -- xx01xx -- set_id 1번 세트
    -- xxxx1x -- slot 1번 슬롯
    -- xxxxx1 -- grade 등급
    self['set_id'] = getDigit(rid, 100, 2)
    self['slot'] = getDigit(rid, 10, 1)
    self['grade'] = getDigit(rid, 1, 1)
    self['name'] = TableItem:getItemName(rid)

    local prefix = self:makeRunePrefix()
    if prefix then
        self['name'] = prefix .. ' ' .. self['name']
    end
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructRuneObject:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    replacement['id'] = 'roid'

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function makeRunePrefix
-------------------------------------
function StructRuneObject:makeRunePrefix()
    local uopt = self['uopt']
    if (not uopt) or (uopt == '') then
        return
    end

    local l_str = stringSplit(uopt, ';')
    local option = l_str[1]
    local value = l_str[2]

    local prefix = TableOption:getRunePrefix(option)

    if (prefix == '') then
        return nil
    end

    return prefix
end

-------------------------------------
-- function makeSampleData
-------------------------------------
function StructRuneObject:makeSampleData()
    local data = {
        -- 오브젝트 ID
        ['id'] = '58d20465e89193694ea1ceb0',

        ['rid'] = 710123,   -- 룬 ID
        ['lv'] = 5,         -- 강화 단계
        ['rarity'] = 3,     -- 진화도

        -- 메인 옵션
        ['mopt'] = 'cri_dmg_add;15',

        -- 유니크 옵션 (접두어 옵션)
        ['uopt'] = 'atk_multi;15',

        -- 서브 옵션
        ['sopt_1'] = 'atk_multi;15',
        ['sopt_2'] = 'atk_multi;15',
        ['sopt_3'] = 'atk_multi;15',
        ['sopt_4'] = '',

        ['created_at'] = 1489996009399,
    }

    return data
end