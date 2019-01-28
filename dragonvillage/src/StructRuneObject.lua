RUNE_SLOT_MAX = 6
RUNE_LV_MAX = 15

RUNE_OPTION_TYPE =
{
    'mopt',
    'uopt',
    'sopt_1',
    'sopt_2',
    'sopt_3',
    'sopt_4'
}

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

        -- 잠금 여부
        lock = 'boolean',

        ---------------------------------------------
        created_at = 'timestamp',
        updated_at = 'timestamp',
        ---------------------------------------------

        slot = 'number',    -- 슬롯 ID 1 ~ 6
        grade = 'number',   -- 등급 1~6
        set_id = 'number',  -- 세트 ID 1~8

        item_id = 'number',

        name = 'string',

        is_ancient = 'boolean', -- 고대 룬 여부
        ---------------------------------------------
        owner_doid = 'doid', -- 룬을 장착 중인 드래곤 doid
        ---------------------------------------------
        grind_opt = 'table',
    })

StructRuneObject.OPTION_LIST = {'mopt', 'uopt', 'sopt_1', 'sopt_2', 'sopt_3', 'sopt_4'}

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

    self['is_ancient'] = (self['set_id'] > 8) and true or false

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

    local l_str = plSplit(option_str, ';')
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
    if (RUNE_LV_MAX <= lv) then
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
        text = '{@&w;mopt}' .. text_

        if for_enhance then
            local new_option_str = self:getNextLevelMopt()
            if new_option_str then
                text = text .. ' {@&O;mopt}▶ {@&G;mopt}' .. self:getRuneOptionDesc(new_option_str)
            end
        end
    end

    -- 유니크 옵션
    local text_ = self:getRuneOptionDesc(self['uopt'])
    if text_ then
        text = text .. '\n{@&apricot;uopt}' .. text_
    end

    -- 공백
    -- [성구] #룬 부옵션과 서브옵션 띄워서 표기하던 부분 수정
    --text = text .. '\n'

    do -- 서브 옵션
        local text_ = self:getRuneOptionDesc(self['sopt_1'])
        if text_ then
            text = text .. '\n{@&rune_sopt;sopt_1}' .. text_
        end

        local text_ = self:getRuneOptionDesc(self['sopt_2'])
        if text_ then
            text = text .. '\n{@&rune_sopt;sopt_2}' .. text_
        end

        local text_ = self:getRuneOptionDesc(self['sopt_3'])
        if text_ then
            text = text .. '\n{@&rune_sopt;sopt_3}' .. text_
        end

        local text_ = self:getRuneOptionDesc(self['sopt_4'])
        if text_ then
            text = text .. '\n{@&rune_sopt;sopt_4}' .. text_
        end
    end

    return text or ''
end

-------------------------------------
-- function makeEachRuneDescRichText
-------------------------------------
function StructRuneObject:makeEachRuneDescRichText(opt_type, for_enhance)
    local text = ''
    local text_ = self:getRuneOptionDesc(self[opt_type])

    if text_ then
        text = string.format('%s', text_)

        if for_enhance then
            local new_option_str = self:getNextLevelMopt()
            if new_option_str then
                text = text .. ' {@&O;mopt}▶ {@&G;mopt}' .. self:getRuneOptionDesc(new_option_str)
            end
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
    local is_max_rune_lv = (RUNE_LV_MAX <= self['lv'])
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
    local grade = self['grade']
    local table_rune_enhance = TABLE:get('table_rune_enhance')
    local t_rune_enhance = table_rune_enhance[lv]

    -- 룬 강화 할인 합산
    local dc_value = g_hotTimeData:getDiscountEventValue(HOTTIME_SALE_EVENT.RUNE_ENHANCE)
    local dc_rate = (100 - dc_value)/100

    -- 등급, 레벨별 가격이 적용되도록 변경됨 2017-09-21 sgkim
    local req_gold = math_floor(t_rune_enhance['req_gold_' .. grade] * dc_rate)

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
-- function isAncientRune
-------------------------------------
function StructRuneObject:isAncientRune()
    return self['is_ancient']

end

-------------------------------------
-- function setOwnerDragon
-------------------------------------
function StructRuneObject:setOwnerDragon(doid)
    self['owner_doid'] = doid
end

-------------------------------------
-- function getLevel
-------------------------------------
function StructRuneObject:getLevel()
	return self['lv']
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

-------------------------------------
-- function getRuneStatus
-------------------------------------
function StructRuneObject:getRuneStatus()
    local table_option = TableOption()
    local l_add_status = {}
    local l_multi_status = {}

    for i,v in pairs(StructRuneObject.OPTION_LIST) do
        local option_string = self[v]
        local option, value = self:parseRuneOptionStr(option_string)
        if option then
            local stat_type = table_option:getValue(option, 'status')
            local action = table_option:getValue(option, 'action')
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

    return l_add_status, l_multi_status
end

-------------------------------------
-- function getRuneRes
-------------------------------------
function StructRuneObject:getRuneRes()
    local slot = self['slot']
    local grade = self['grade']
    local set_id = self['set_id']
	local set_color = TableRuneSet:getRuneSetColor(set_id)
    local res = string.format('res/ui/icons/rune/%.2d_%s_%.2d.png', slot, set_color, grade)
	return res
end

-------------------------------------
-- function getRarityFrameRes
-------------------------------------
function StructRuneObject:getRarityFrameRes()
	local rarity = self['rarity'] or 0
    local rarity_str = ''

    if (rarity == 0) then
        rarity_str = 'none'

    elseif (rarity == 1) then
        rarity_str = 'common'

    elseif (rarity == 2) then
        rarity_str = 'rare'

    elseif (rarity == 3) then
        rarity_str = 'hero'

    elseif (rarity == 4) then
        rarity_str = 'legend'

    else
        error('rarity(rune_rarity) : ' .. rarity)
    end

    local res = string.format('card_rune_frame_%s.png', rarity_str)
	return res
end

-------------------------------------
-- function getLock
-------------------------------------
function StructRuneObject:getLock()
	return self['lock']
end

-------------------------------------
-- function isNewRune
-- @breif
-------------------------------------
function StructRuneObject:isNewRune()
    local roid = self['roid']

    if (not roid) then
        return
    end

    return g_highlightData:isNewRoid(roid)
end

-------------------------------------
-- function getStringData
-------------------------------------
function StructRuneObject:getStringData()
    -- 클라에서 파싱하기 위해 룬 옵션 정보의 ';'을 '|'로 변환해서 저장
    local str = string.format('%d:%d:%d:%s:%s:%s:%s:%s:%s',
        self['rid'],
        self['lv'],
        self['rarity'],
        string.gsub(self['mopt'], ';', '|'),
        string.gsub(self['uopt'], ';', '|'),
        string.gsub(self['sopt_1'], ';', '|'),
        string.gsub(self['sopt_2'], ';', '|'),
        string.gsub(self['sopt_3'], ';', '|'),
        string.gsub(self['sopt_4'], ';', '|')
    )

    return str
end

-------------------------------------
-- function getGrade
-------------------------------------
function StructRuneObject:getGrade()
    local grade = self['grade'] 
    return grade
end

-------------------------------------
-- function getIcono
-------------------------------------
function StructRuneObject:getIcon(opt_type)
    local option_type = self[opt_type]

    --if (option_type == 'mopt')

    --return grade
end

-------------------------------------
-- function getLevel
-------------------------------------
function StructRuneObject:getLevel()
    local level = self['lv'] 
    return tonumber(level)
end

-------------------------------------
-- function existOptionType
-- @param mopt, sopt..
-- @return 해당 옵션 타입이 존재한다면 true 반환
-------------------------------------
function StructRuneObject:existOptionType(option_type)
    local option_value = self[option_type] 
    if (option_value == '') then
        return false
    else
        return true
    end
end

-------------------------------------
-- function setOptionLabel
-- @brief 옵션 라벨 mopt~sopt4까지 자동으로 셋팅
-- @brief mopt_XXXLabel, mopt_XXXNode 와 같이 일정한 형식에서만 작동
-------------------------------------
function StructRuneObject:setOptionLabel(ui, label_format, show_change)
    if (not ui) then
        return
    end
    
    local vars = ui.vars

    -- 룬 옵션 세팅
    for i,v in ipairs(RUNE_OPTION_TYPE) do
        local option_label = string.format("%s_%sLabel", v, label_format) -- ex) label_vormat 이 XX의 경우, mopt_XXLabel인 라벨을 찾아서 사용
        local option_label_node = string.format("%s_%sNode", v, label_format)
        
        -- show_chage가 true 라면 주옵션만 ex) 공격력 +4% -> 공격력 +5% 표시
        if (show_change) then
            show_change = (i == 1)
        end
        
        local desc_str = self:makeEachRuneDescRichText(v, show_change)

        -- node와 label 둘 중 하나라도 없다면 출력x, 에러메세지
        if (not vars[option_label_node] or not vars[option_label]) then
            if (IS_TEST_MODE()) then
                local error_str = string.format('wrong luaname in .ui : %s, %s', option_label_node, option_label) 
                error(error_str)
            end
            return
        end

        -- 옵션 desc가 없다면 해당 옵션은 노출하지 않는다
        if (desc_str == '') then
            vars[option_label_node]:setVisible(false)
        else
            vars[option_label_node]:setVisible(true)
            vars[option_label]:setString(desc_str)
        end
    end
end

-------------------------------------
-- function getOptionLabel
-------------------------------------
function StructRuneObject:getOptionLabel(size)
    local option_label = UI()
    option_label:load('rune_info_board.ui')
    option_label.vars['runeInfo']:setVisible(true)
    option_label.vars['useMenu']:setVisible(false)

    return option_label
end