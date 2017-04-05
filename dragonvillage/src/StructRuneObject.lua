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

        ---------------------------------------------
        owner_doid = 'doid', -- 룬을 장착 중인 드래곤 doid
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

    local option, value = self:parseRuneOptionStr(uopt)
    if (not option) then
        return nil
    end

    local prefix = TableOption:getRunePrefix(option)

    if (prefix == '') then
        return nil
    end

    return prefix
end

-------------------------------------
-- function parseRuneOptionStr
-- @brief 옵션 능력치 분석
-------------------------------------
function StructRuneObject:parseRuneOptionStr(option_str)
    if (not option_str) or (option_str == '') then
        return nil
    end

    local l_str = stringSplit(option_str, ';')
    local option = l_str[1]
    local value = l_str[2]

    return option, value
end

-------------------------------------
-- function getRuneOptionDesc
-- @brief 옵션 능력치 desc
-------------------------------------
function StructRuneObject:getRuneOptionDesc(option_str)
    local option, value = self:parseRuneOptionStr(option_str)

    if (not option) then
        return nil
    end

    local text = TableOption:getOptionDesc(option, value)
    return text
end

-------------------------------------
-- function getNextLevelMopt
-------------------------------------
function StructRuneObject:getNextLevelMopt()
    local lv = self['lv']
    local grade = self['grade']
    if (15 <= lv) then
        return nil
    end

    local option_str = self['mopt']
    local option, value = self:parseRuneOptionStr(option_str)

    local vid = option .. '_' .. grade
    local lv = lv + 1

    local status = TableRuneMoptStatus:getStatusValue(vid, lv)
    local new_option_str = option .. ';' .. status

    return new_option_str
end

-------------------------------------
-- function makeRuneDescRichText
-------------------------------------
function StructRuneObject:makeRuneDescRichText(for_enhance)
    local text = ''

    -- 주 옵션
    local text_ = self:getRuneOptionDesc(self['mopt'])
    if text_ then
        text = '{@w}' .. text_

        if for_enhance then
            local new_option_str = self:getNextLevelMopt()
            if new_option_str then
                text = text .. ' {@O}▶ {@G}' .. self:getRuneOptionDesc(new_option_str)
            end
        end
    end

    -- 유니크 옵션
    local text_ = self:getRuneOptionDesc(self['uopt'])
    if text_ then
        text = text .. '\n{@g}' .. text_
    end

    -- 공백
    text = text .. '\n'

    do -- 서브 옵션
        local text_ = self:getRuneOptionDesc(self['sopt_1'])
        if text_ then
            text = text .. '\n{@rune_sopt}' .. text_
        end

        local text_ = self:getRuneOptionDesc(self['sopt_2'])
        if text_ then
            text = text .. '\n{@rune_sopt}' .. text_
        end

        local text_ = self:getRuneOptionDesc(self['sopt_3'])
        if text_ then
            text = text .. '\n{@rune_sopt}' .. text_
        end

        local text_ = self:getRuneOptionDesc(self['sopt_4'])
        if text_ then
            text = text .. '\n{@rune_sopt}' .. text_
        end
    end

    return text or ''
end

-------------------------------------
-- function makeRuneSetDescRichText
-------------------------------------
function StructRuneObject:makeRuneSetDescRichText()
    local set_id = self['set_id']
    local text = TableRuneSet:makeRuneSetDescRichText(set_id)
    return text
end

-------------------------------------
-- function isMaxRuneLv
-------------------------------------
function StructRuneObject:isMaxRuneLv()
    local is_max_rune_lv = (15 <= self['lv'])
    return is_max_rune_lv
end

-------------------------------------
-- function getRuneEnhanceReqGold
-------------------------------------
function StructRuneObject:getRuneEnhanceReqGold()
    if self:isMaxRuneLv() then
        return 0
    end

    local lv = self['lv']
    local table_rune_enhance = TABLE:get('table_rune_enhance')
    local t_rune_enhance = table_rune_enhance[lv]
    local req_gold = t_rune_enhance['req_gold']

    return req_gold
end

-------------------------------------
-- function isEquippedRune
-------------------------------------
function StructRuneObject:isEquippedRune()
    if self['owner_doid'] then
        return true
    else
        return false
    end
end

-------------------------------------
-- function setOwnerDragon
-------------------------------------
function StructRuneObject:setOwnerDragon(doid)
    self['owner_doid'] = doid
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

-------------------------------------
-- function getRarityName
-------------------------------------
function StructRuneObject:getRarityName(rarity)
    local rarity = (rarity or self['rarity'])
    
    local name

    -- 일반 (common)
    if (rarity == 1) then
        name = Str('일반')

    -- 희귀 (rare)
    elseif (rarity == 2) then
        name = Str('희귀')

    -- 영웅 (hero)
    elseif (rarity == 3) then
        name = Str('영웅')

    -- 전설 (legend)
    elseif (rarity == 4) then
        name = Str('전설')

    else
        error('rarity : ' .. rarity)
    end

    return name
end

-------------------------------------
-- function getRarityColor
-------------------------------------
function StructRuneObject:getRarityColor(rarity)
    local rarity = (rarity or self['rarity'])

    local color

    -- 일반 (common)
    if (rarity == 1) then
        color = cc.c3b(174, 172, 162)

    -- 희귀 (rare)
    elseif (rarity == 2) then
        color = cc.c3b(62, 139, 255)

    -- 영웅 (hero)
    elseif (rarity == 3) then
        color = cc.c3b(213, 57, 246)

    -- 전설 (legend)
    elseif (rarity == 4) then
        color = cc.c3b(255, 210, 0)

    else
        error('rarity : ' .. rarity)
    end

    return color
end