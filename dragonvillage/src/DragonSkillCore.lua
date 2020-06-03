-------------------------------------
-- table DragonSkillCore
-- @brief 스킬 계수 계산 및 UI 텍스트 에 사용되는 로직
-------------------------------------
DragonSkillCore = {}

local THIS = DragonSkillCore

-------------------------------------
-- function applySkillLevel
-- @brief skill level에 따른 능력치를 계산하여 적용
-- @comment 실질적으론 DragonSkillIndivisual 에서 사용한다. Helper처럼 사용중
-------------------------------------
function DragonSkillCore.applySkillLevel(char_type, t_skill, skill_lv)
    local t_skill = t_skill or {}
	local skill_lv = skill_lv or 1
    local t_modify_list = {}
    local skill_id = t_skill['sid']

    if (not char_type or char_type ~= 'tamer') then
	    -- 필요한 데이터 선언
	    local mod_skill = (skill_id * 100)

        local table_dragon_skill_modify = TableDragonSkillModify()

        -- modify table을 순회하며 해당 레벨까지의 수치 증가량을 수집한다.
        for i = 1, skill_lv do
		    local mod_skill_id = mod_skill + i
            local t_dragon_skill_modify = table_dragon_skill_modify:get(mod_skill_id, true)
        
            if t_dragon_skill_modify then
                for i = 1, 5 do
                    local column = t_dragon_skill_modify[string.format('col_%.2d', i)]
                    local modify = t_dragon_skill_modify[string.format('mod_%.2d', i)]
                    local value = t_dragon_skill_modify[string.format('val_%.2d', i)]

                    if column and (column ~= '') then
                        local t_modify = t_modify_list[column]
					
					    -- 해당 column 최초 적용 시
                        if (not t_modify) then
                            t_modify = {column=column, modify=modify, value=value, mod_skill_id = mod_skill_id}
                            t_modify_list[column] = t_modify

                        else
                            if (t_modify['modify'] ~= modify) then
                                error('modify타입이 다르게 사용되었습니다. slid : ' .. skill_id)
                            end
                        
                            if (modify == 'exchange') then
                                t_modify['value'] = value
                            elseif (modify == 'add') then
                                t_modify['value'] = (t_modify['value'] + value)
                            elseif (modify == 'multiply') then
                                t_modify['value'] = (t_modify['value'] + value)
                            end
                        end
                    end
                end
            end
        end

	    THIS.applyModification(t_skill, t_modify_list)
    else
        local t_tamer_skill = TableTamerSkill():get(skill_id)
        if (t_tamer_skill) then
            local column = t_tamer_skill['mod_col_1']
            local add_value = t_tamer_skill['add_val_1']
            local base_value = t_tamer_skill[column]

            if (base_value and t_skill[column]) then
                t_skill[column] = base_value + (skill_lv - 1) * add_value
            end
        end
    end

	return t_skill, t_modify_list -- skill 성룡 강화시 사용
end

-------------------------------------
-- function applyModification
-- @brief 수집한 수치 증가량을 t_skill에 적용한다.
-------------------------------------
function DragonSkillCore.applyModification(t_skill, t_modify_list)
    for column, t_modify in pairs(t_modify_list) do
        local modify = t_modify['modify']
        local value = t_modify['value']

        if (modify == 'exchange') then
            t_skill[column] = value

        elseif (modify == 'add') then
            if (type(t_skill[column]) == 'number') then
                t_skill[column] = t_skill[column] + value
            else
                cclog('invalid skill modify slid : ' .. t_modify['mod_skill_id'])
            end

        elseif (modify == 'multiply') then
            if (type(t_skill[column]) == 'number') then
                t_skill[column] = t_skill[column] + (t_skill[column] * value)
            else
                cclog('invalid skill modify slid : ' .. t_modify['mod_skill_id'])
            end

        end
    end
end

-------------------------------------
-- function substituteSkillDesc
-- @brief desc column에서 수정할 column명을 가져와 대체
-------------------------------------
function DragonSkillCore.substituteSkillDesc(t_skill)
	for idx = 1, 5 do
		local raw_data = t_skill['desc_' .. idx]
		if (raw_data) and (raw_data ~= '') then
			local desc_value
			-- 1. 연산이 필요한지 확인하고 필요하다면 연산하여 산출
			if string.find(raw_data, '[*+/-]') then
				local operator = string.match(raw_data, '[*+/-]')
				local l_parsed = seperate(raw_data, operator)

				-- 숫자가 들어갔을 경우도 고려되어있다.
				local column_name_1 = trim(l_parsed[1])
				local value_1
				if (tonumber(column_name_1)) then
					value_1 = column_name_1
				else
					value_1 = t_skill[column_name_1]
				end

				-- 숫자가 들어갔을 경우도 고려되어있다.
				local column_name_2 = trim(l_parsed[2])
				local value_2
				if (tonumber(column_name_2)) then
					value_2 = column_name_2
				else
					value_2 = t_skill[column_name_2]
				end

				-- 연산자에 따른 실제 연산 실행
				if (operator == '*') then
					desc_value = value_1 * value_2
				elseif (operator == '/') then
					desc_value = value_1 / value_2
				elseif (operator == '+') then
					desc_value = value_1 + value_2
				elseif (operator == '-') then
					desc_value = value_1 - value_2
				end
		
			-- 2. 단순 숫자라면 그대로 추출
			elseif (type(raw_data) == 'number') then
				desc_value = raw_data

			-- 3. 이외는 column명으로 가정하고 테이블에서 추출
			else
				desc_value =  t_skill[raw_data]
			end

			-- 4. 실제 들어가야할 숫자로 치환
			t_skill['desc_' .. idx] = desc_value
		end
	end

	return t_skill
end

-------------------------------------
-- function getSkillDescPure
-- @brief 스킬 설명 리턴
-- @comment individual_info에서 재조립된 스킬테이블 사용
-------------------------------------
function DragonSkillCore.getSkillDescPure(t_skill)
    local val_1 = (t_skill['desc_1'])
    local val_2 = (t_skill['desc_2'])
    local val_3 = (t_skill['desc_3'])
    local val_4 = (t_skill['desc_4'])
    local val_5 = (t_skill['desc_5'])
    return THIS.getRichTemplate(Str(t_skill['t_desc'], val_1, val_2, val_3, val_4, val_5))
end

-------------------------------------
-- function getSkillEnhanceDesc
-- @brief 스킬 설명 리턴
-- @comment individual_info에서 재조립된 스킬테이블 사용
-------------------------------------
function DragonSkillCore.getSkillEnhanceDesc(t_skill)
    local val_1 = (t_skill['desc_1'])
    local val_2 = (t_skill['desc_2'])
    local val_3 = (t_skill['desc_3'])
    local val_4 = (t_skill['desc_4'])
    local val_5 = (t_skill['desc_5'])
    return THIS.getRichTemplateEnhance(Str(t_skill['t_desc'], val_1, val_2, val_3, val_4, val_5))
end

-------------------------------------
-- function getSkillModDesc
-- @brief 스킬 설명 리턴
-- @comment individual_info에서 재조립된 스킬테이블 사용
-------------------------------------
function DragonSkillCore.getSkillModDesc(t_skill, skill_lv)
    local desc = TableDragonSkillModify:getSkillModDesc(t_skill['sid'], skill_lv)
    return THIS.getRichTemplateMod(desc)
end

local L_CASE = {
    '(%d+[.]%d+)(배)',
    '(%d+)(배)',
    '(%d+[.]%d+)(%%)',
    '(%d+)(%%)',
    '(%d+)(명)',
    '(%d+)(회)',
    '(%d+)(개)',
    '(%d+[.]%d+)(초)',
    '(%d+)(초)',
    '(%d+)(열)',
}
-------------------------------------
-- function getRichTemplate
-------------------------------------
function DragonSkillCore.getRichTemplate(desc)
    if (desc) then
        -- lua pattern capture 참조
        for _, case in pairs(L_CASE) do
            desc = desc:gsub(case, '{@SKILL_VALUE}%1%2{@SKILL_DESC}')
        end
        return '{@SKILL_DESC}' .. desc
    end
end
-------------------------------------
-- function getRichTemplateEnhance
-------------------------------------
function DragonSkillCore.getRichTemplateEnhance(desc)
    if (desc) then
        -- lua pattern capture 참조
        for _, case in pairs(L_CASE) do
            desc = desc:gsub(case, '{@SKILL_VALUE_MOD}%1%2{@SKILL_DESC_ENHANCE}')
        end

        return '{@SKILL_DESC_ENHANCE}' .. desc
    end
end
-------------------------------------
-- function getRichTemplateMod
-------------------------------------
function DragonSkillCore.getRichTemplateMod(desc)
    if (desc) then
        -- lua pattern capture 참조
        for _, case in pairs(L_CASE) do
            desc = desc:gsub(case, '{@SKILL_VALUE_MOD}%1%2{@SKILL_DESC_MOD}')
        end

        return '{@SKILL_DESC_MOD}' .. desc
    end
end

-------------------------------------
-- function getSimpleSkillDesc
-- @brief 스킬 설명 리턴
-- @comment 단순 스킬 테이블을 기반으로 사용할 수 있도록 치환 + 생성 함
-------------------------------------
function DragonSkillCore.getSimpleSkillDesc(t_skill, lv)
    local t_skill = THIS.substituteSkillDesc(t_skill)
    return THIS.getSkillDescPure(t_skill)
end