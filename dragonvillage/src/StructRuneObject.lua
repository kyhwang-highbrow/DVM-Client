RUNE_SLOT_MAX = 6
RUNE_LV_MAX = 15

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
    self['set_id'] = TableRune:getRuneSetId(rid)
    self['slot'] = TableRune:getRuneSlot(rid)
    self['grade'] = TableRune:getRuneGrade(rid)
    self['name'] = TableItem:getItemName(rid) or 'none'

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
    
    -- 연마된 옵션값 초기화
    self['grind_opt'] = nil

    for i,v in pairs(data) do
        if (i == 'grind_opt') then
            for opt_name, opt_num in pairs(v) do
                self['grind_opt'] = opt_name .. '_' .. opt_num
            end
        else
            local key = replacement[i] and replacement[i] or i
            self[key] = v
        end
    end
end


-------------------------------------
-- function getObjectId
-------------------------------------
function StructRuneObject:getObjectId()
    return self['roid']
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
function StructRuneObject:getNextLevelMopt(target_level)
    local lv = self['lv']
    local grade = self['grade']
    if (RUNE_LV_MAX <= lv) then
        return nil
    end

    local option_str = self['mopt']
    local option, value = self:parseRuneOptionStr(option_str)

    local vid = option .. '_' .. grade

    local status = TableRuneMoptStatus:getStatusValue(vid, target_level)
    local new_option_str = option .. ';' .. status

    return new_option_str
end

-------------------------------------
-- function makeRuneDescRichText
-------------------------------------
function StructRuneObject:makeRuneDescRichText(target_level)
    local text = ''

    -- 주 옵션
    local text_ = self:getRuneOptionDesc(self['mopt'])
    if text_ then
        text = '{@&w;mopt}' .. text_

        if target_level then
            local new_option_str = self:getNextLevelMopt(target_level)
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
-- @param target_level : 다음 강화 레벨
-------------------------------------
function StructRuneObject:makeEachRuneDescRichText(opt_type, target_level)
    local text = ''
    local text_ = self:getRuneOptionDesc(self[opt_type])

    if text_ then
        text = string.format('%s', text_)

        if (target_level ~= nil) then
            -- 주 옵션의 경우 오르는 능력치 확실
            if (opt_type == 'mopt') then
                local new_option_str = self:getNextLevelMopt(target_level)
                if new_option_str then
                    local curr_option, curr_stat = self:parseRuneOptionStr(self['mopt'])
                    local new_option, new_stat = self:parseRuneOptionStr(new_option_str)
                    local new_stat_str = '+' .. comma_value(new_stat)
                    if (not isExistValue(curr_option, 'atk_add', 'def_add', 'hp_add')) then
                        new_stat_str = new_stat_str .. '%'
                    end

                    text = text .. ' {@&G}▶ {@&G;mopt}' .. new_stat_str
                end
            
            -- 보조 옵션이면서 오를 수도 있는 경우
            elseif (target_level % 3 == 0) and (self.lv < 12) and (not self:isMaxOption(opt_type)) then
                local create_opt_num = math_min(4, target_level / 3)
                if ((target_level ~= 15) and (self['sopt_' .. tostring(create_opt_num)]) ~= '') or (target_level == 15) then
                    local avail_option_value_str = self:getAvailOptionValueStr(opt_type, target_level)
                    text = text .. avail_option_value_str
                end
            end
        end
    
    -- 옵션이 없지만, 옵션이 생길수도 있는 경우
    else
        if (target_level ~= nil) and (target_level % 3 == 0) then
            local create_opt_num = target_level / 3
            
            if (string.find(opt_type, 'sopt')) then
                local opt_num = tonumber(plSplit(opt_type, '_')[2])
                if (opt_num <= create_opt_num) then
                    text = '{@&O;change}' .. Str('추가 옵션')
                end
            end
        end
    end

    return text or ''
end

-------------------------------------
-- function makeEachRuneDescRichText
-- @brief 강화로 인해 획득할 수 있는 룬 스텟 범위 텍스트 반환
-- @param target_level : 다음 강화 레벨, 3으로 나뉘어떨어지는 수가 들어옴
-------------------------------------
function StructRuneObject:getAvailOptionValueStr(opt_type, target_level)
    local cur_lv = self['lv'] - (self['lv'] % 3)
    
    -- 옵션에 변화가 있는 최대값인 12
    local target_level = math_min(12, target_level)
    -- 체크 시작할 옵션 인덱스
    local cur_opt_num = math_min(4, (cur_lv / 3) + 1)
    -- 옵션이 생성될 수 있는 옵션 인덱스
    local change_opt_num = math_min(4, (target_level / 3))
    
    -- 옵션 수치가 변화될 횟수
    local add_option_count = 0
    for i = cur_opt_num, change_opt_num do
        -- 이미 해당 옵션이 존재한다면 옵션이 생길 필요 없이 기존 옵션에 수치가 더해지면 된다.
        if (self['sopt_' .. i] ~= '') then
            add_option_count = add_option_count + 1
        end
    end

    -- 옵션 수치가 더해지는 경우가 없는 경우
    if (add_option_count == 0) then
        return ''
    end

    local table_opt = TableOption()
    local t_rune_opt = TABLE:get('table_rune_opt_status')

    -- 현재 변화가 생길 수 있는 옵션 갯수
    local option_count = ((self['uopt'] ~= '') and (not self:isMaxOption('uopt'))) and 1 or 0
    for i = 1, 4 do
        if (self['sopt_' .. i] ~= '') and (not self:isMaxOption('sopt_' .. i)) then
            option_count = option_count + 1
        end
    end
    
    local option, value = self:parseRuneOptionStr(self[opt_type])

    local min_add_value = (self.grade <= 6) and (t_rune_opt[option .. '_1']['single_min']) or (t_rune_opt[option .. '_2']['single_min'])
    local max_add_value = (self.grade <= 6) and (t_rune_opt[option .. '_1']['single_max']) or (t_rune_opt[option .. '_2']['single_max'])

    local min_value = value
    -- 더해질 수 있는 옵션이 1개라면 해당 옵션에만 add_option_count만큼 옵션이 더해진다고 가정할 때 가능한 최소 ~ 최대값
    if (option_count == 1) then
        min_value = min_value + (min_add_value * add_option_count)
    end

    local stat_max_value = (self.grade <= 6) and (t_rune_opt[option .. '_1']['status_max']) or (t_rune_opt[option .. '_2']['status_max'])
    local max_value = math_min(value + (add_option_count * max_add_value), stat_max_value)
    local min_max_str = '+' .. comma_value(min_value) .. '~' .. comma_value(max_value)
    
    -- % 표기 추가
    if (not isExistValue(option, 'atk_add', 'def_add', 'hp_add')) then
        min_max_str = min_max_str .. '%'
    end

    return ' {@&O;change}▶ '.. min_max_str
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
-- function isEventRune
-- @brief 아이템 번호 대역이 75번대일 경우 이벤트룬으로 식별
-------------------------------------
function StructRuneObject:isEventRune()
    local rid = self.rid
    local item_id_range = getDigit(rid, 10000, 2)
    return item_id_range == 75
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
-- function calcReqGoldForEnhance
-------------------------------------
function StructRuneObject:calcReqGoldForEnhance(lv, grade)
    if self:isMaxRuneLv() then
        return 0
    end

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
-- function getRuneBlessReqGold
-------------------------------------
function StructRuneObject:getRuneBlessReqGold()
    return 200000
end

-------------------------------------
-- function getRuneBlessReqItem
-------------------------------------
function StructRuneObject:getRuneBlessReqItem()
    return 1
end

-------------------------------------
-- function getRuneGrindReqGold
-------------------------------------
function StructRuneObject:getRuneGrindReqGold()
    local rarity = self:getRarity()
    local t_grind = TABLE:get('table_rune_grind')
    if (not t_grind[rarity]) then
        return 10000
    end

    return t_grind[rarity]['price'] or 10000
end

-------------------------------------
-- function getRuneGrindReqGrindstone
-------------------------------------
function StructRuneObject:getRuneGrindReqGrindstone()
    local rarity = self:getRarity()
    local t_grind = TABLE:get('table_rune_grind')
    if (not t_grind[rarity]) then
        return 1
    end

    return t_grind[rarity]['grindstone'] or 1
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
-- function getOwnerObjId
-------------------------------------
function StructRuneObject:getOwnerObjId()
    return self['owner_doid']
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

function StructRuneObject:getSlot()
    return self['slot']
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

            -- 공격 속도 옵션은 무조건 multi를 사용하지 않고 add로 처리(kyhwang 23.04.26)
            -- 이벤트 한정 룬에 설정된 공격 속도 옵션이 multi로 적용해서 문제가 생김
            if stat_type == 'aspd' then
                action = 'add'
            end

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
    -- 이벤트 룬이고 png리소스가 설정되어 있을 경우 작동
    if self:isEventRune() == true then
        local res_icon = TableItem:getItemIcon(self['rid']) or ''
        if string.find(res_icon, '.png') ~= nil then
            return res_icon
        end
    end

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
function StructRuneObject:setLock(is_lock)
	self['lock'] = is_lock
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
-- function getIcon
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
-- function getRarity
-------------------------------------
function StructRuneObject:getRarity()
    local rarity = self['rarity'] 
    return tonumber(rarity)
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
-- @param target_level : number, 값이 있을 경우 주 옵션 강화 시 변하는 수치 보여줌
-------------------------------------
function StructRuneObject:setOptionLabel(ui, label_format, target_level)
    if (not ui) then
        return
    end
    
    local vars = ui.vars

    -- 룬 옵션 세팅
    for i,v in ipairs(StructRuneObject.OPTION_LIST) do
        local option_label = string.format("%s_%sLabel", v, label_format)
        local option_label_node = string.format("%s_%sNode", v, label_format)
        
        -- target_level가 입력되었다면 주옵션만 ex) 공격력 +4% -> 공격력 +5% 표시
        local desc_str = self:makeEachRuneDescRichText(v, target_level)
        
        local is_max = self:isMaxOption(v) and (self.grade <= 6)

        -- 추가옵션은 max, 연마 표시
        if (i > 2) then
            if (is_max) then
                desc_str = desc_str .. '{@yellow} [MAX]'
            end
        
            local is_grinded_opt = self:isGrindedOption(v)
            local grind_icon_node = string.format('%s_grindIconNode', v)
            local icon_node = string.format('%s_useIconNode', v)
            ui.vars[icon_node]:setVisible(not is_grinded_opt)
            ui.vars[grind_icon_node]:setVisible(is_grinded_opt)         
        end


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
            
            -- 다음 강화에 수치가 증가할 확률이 있는 옵션의 경우
            local l_change_list = vars[option_label]:findContentNodeWithkey('change')
            for _, v in ipairs(l_change_list) do
                local duration = 1.8
                -- local tint_action = cca.repeatTintToRuneOpt(duration, 255, 104, 32)
                local tint_action = cca.repeatFadeInOutRuneOpt(duration)
                v:runAction(tint_action)
            end
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

-------------------------------------
-- function getGrindedOption
-------------------------------------
function StructRuneObject:getGrindedOption()
    return self.grind_opt
end

-------------------------------------
-- function setGrindedOption
-------------------------------------
function StructRuneObject:setGrindedOption(opt_name)
     self.grind_opt = opt_name
end

-------------------------------------
-- function isMaxOption
-------------------------------------
function StructRuneObject:isMaxOption(opt_name)
    local max_value = 0
    local t_rune_opt_max = TABLE:get('table_rune_opt_status')
    local option, opt_value = self:parseRuneOptionStr(self[opt_name])

    if (not t_rune_opt_max) then
        return false
    end

    -- ex)hp_mult;30 를 파싱하여
    -- hp_multi를 키로 사용해 max값을 구한다
    local opt_str = self[opt_name]

    if opt_str == nil then
        return false      
    end

    opt_str = pl.stringx.split(opt_str, ';')
    
    if (#opt_str>0) then
        local option_name = opt_str[1]
        max_value = (self.grade <= 6) and (t_rune_opt_max[option_name .. '_1']['status_max']) or (t_rune_opt_max[option_name .. '_2']['status_max'])
    end

    if (not opt_value) then
        return false
    end

    if (not max_value) then
        return false
    end

    if (tonumber(opt_value) >= tonumber(max_value)) then
        return true
    end

    return false
end

-------------------------------------
-- function getOptionMinValue
-------------------------------------
function StructRuneObject:getOptionMinValue(opt_name) -- ex) atk_multi
    local min_value = 0
    local t_rune_opt_max = TABLE:get('table_rune_opt_status')
    local opt_name = (self.grade <= 6) and (opt_name .. '_1') or (opt_name .. '_2')

    if (t_rune_opt_max[opt_name]) then
        min_value = t_rune_opt_max[opt_name]['single_min']   
    end

    if (not min_value) then
        min_value = 0
    end

    return min_value
end

-------------------------------------
-- function getOptionMaxValue
-------------------------------------
function StructRuneObject:getOptionMaxValue(opt_name) -- ex) atk_multi
    local max_value = 0
    local t_rune_opt_max = TABLE:get('table_rune_opt_status')
    local opt_name = (self.grade <= 6) and (opt_name .. '_1') or (opt_name .. '_2')
    if (t_rune_opt_max[opt_name]) then
        max_value = t_rune_opt_max[opt_name]['status_max']   
    end

    if (not max_value) then
        max_value = 0
    end

    return max_value
end

-------------------------------------
-- function hasMainOption
-- @return true이면 해당 옵션들 중 하나를(or 연산) 주옵션으로 가지고 있음
-------------------------------------
function StructRuneObject:hasMainOption(l_opt_list) -- ex) {atk_multi}
    local main_opt_name, main_opt_value = self:parseRuneOptionStr(self['mopt'])
    
    for j, option_name in ipairs(l_opt_list) do
        if (main_opt_name == option_name) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function hasAuxiliaryOption
-- @return true이면 해당 옵션들을 전부(and 연산) 보조옵션(부옵션 + 추가옵션)으로 가지고 있음
-------------------------------------
function StructRuneObject:hasAuxiliaryOption(l_opt_list) -- ex) {atk_multi}
    local l_check_option_key = {'uopt', 'sopt_1', 'sopt_2', 'sopt_3', 'sopt_4'}
    
    local check_count = table.count(l_opt_list)

    for i, key in ipairs(l_check_option_key) do
        if (self[key]) then
            local sub_opt_name, sub_opt_value = self:parseRuneOptionStr(self[key]) 
            
            for j, option_name in ipairs(l_opt_list) do
                if (sub_opt_name == option_name) then
                    check_count = check_count - 1
                    break
                end
            end
        end
    end

    return (check_count == 0)
end

-------------------------------------
-- function isGrindedOption
-------------------------------------
function StructRuneObject:isGrindedOption(opt_name)
    return self.grind_opt == opt_name
end

-------------------------------------
-- function createSimpleRuneByItemId
-- @brief 룬 획득하기 전의 옵션 정보를 보여주고 싶은 경우, 임시 룬 오브젝트 생성
-------------------------------------
function StructRuneObject:createSimpleRuneByItemId(item_id)
    local attr = TableItem:getItemAttr(item_id)

    local t_rune_data = {}
    local replacement = {}
    replacement['id'] = 'rid'
    replacement['sopt1'] = 'sopt_1'
    replacement['sopt2'] = 'sopt_2'
    replacement['sopt3'] = 'sopt_3'
    replacement['sopt4'] = 'sopt_4'
    -- 주옵션의 경우 획득 시 서버에서 계산한다. 획득하기 전에는 모른다. 그래서 깡 수치를 뿌려준다.
    replacement['mopt_show'] = 'mopt' 

    -- id;750616,lv;15,mopt;atk_add,uopt;cri_chance_add;8,sopt1;cri_dmg_add;6,sopt2;hit_rate_add;6,sopt3;atk_multi;6,sopt4;hp_multi;6
    local l_item = plSplit(attr, ',')
    for _, str in ipairs(l_item) do
        local parse_list = plSplit(str, ';')
        local key = clone(parse_list[1])
        table.remove(parse_list, 1)
        local val = table.concat(parse_list, ';')
        if replacement[key] ~= nil then
            t_rune_data[replacement[key]] = tonumber(val) or val
        else
            t_rune_data[key] = tonumber(val) or val
        end
    end

    local struct_rune_obj = StructRuneObject(t_rune_data)
    return struct_rune_obj
end