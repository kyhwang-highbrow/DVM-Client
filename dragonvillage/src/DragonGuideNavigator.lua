DragonGuideNavigator = {}

local THIS = DragonGuideNavigator

local MAX_GUIDE_CNT = 3 -- 최대 가이드 갯수

-------------------------------------
-- function analysis
-- @brief 드래곤 육성 가이드 분석
-------------------------------------
function DragonGuideNavigator:analysis(dragon_data)
    if (not dragon_data) then
        return nil
    end

    local link_list = {}
    local is_myth_dragon = dragon_data:getRarity() == 'myth'
    local check_list = THIS:getCheckList(is_myth_dragon)

    local cnt = 0
    for _, name in ipairs(check_list) do
        if (cnt == MAX_GUIDE_CNT) then
            break
        end

        local func_name = 'analysis_' .. name
        if (THIS[func_name]) then
            local guide = THIS[func_name](dragon_data)
            if (guide) then
                cnt = cnt + 1
                table.insert(link_list, name)
            end
        end
    end

    return { dragon_data = dragon_data, link = link_list }

    --[[ ## data ex)
    {
        ['link']={
                'skill_enc';
                'reinforce';
        };
        ['dragon_data'] = 'StructDragonObject';
    }
    ]]--
end

-------------------------------------
-- function getCheckList
-- @brief 드래곤 육성 가이드 체크 리스트 
-- @brief ## 순서대로 조건 체크, 함수 이름과 동일해야함 ex) analysis_level_up -> level_up
-- @brief ## UI_DragonManageInfo의 서브메뉴 이름과 동일해야함 
-------------------------------------
function DragonGuideNavigator:getCheckList(is_myth_dragon)
    local check_list = {}

    table.insert(check_list, 'level_up')
    table.insert(check_list, 'rune')
    table.insert(check_list, 'friendship')
    table.insert(check_list, 'evolution')
    table.insert(check_list, 'grade')
    table.insert(check_list, 'skill_enc')
    if (not is_myth_dragon) then table.insert(check_list, 'reinforce') end

    return check_list
end

-------------------------------------
-- function analysis_level_up
-- @brief 레벨업이 가능한지
-------------------------------------
function DragonGuideNavigator.analysis_level_up(dragon_data)
    local curr_lv = dragon_data['lv']
    local curr_grade = dragon_data['grade']
    local max_lv = THIS:getDragonMaxLv(curr_grade)

    local guide = curr_lv < max_lv
    return guide
end

-------------------------------------
-- function analysis_rune
-- @brief 빈 룬슬롯이 있는지
-------------------------------------
function DragonGuideNavigator.analysis_rune(dragon_data)
    local runes = dragon_data['runes']
    local cnt = 0
    for k, v in pairs(runes) do
        cnt = cnt + 1
    end
    local max_slot = RUNE_SLOT_MAX

    local guide = cnt < max_slot
    return guide
end

-------------------------------------
-- function analysis_friendship
-- @brief 친밀도 레벨업이 가능한지
-------------------------------------
function DragonGuideNavigator.analysis_friendship(dragon_data)
    local friendship = dragon_data['friendship']
    local curr_lv = friendship['flv']
    local max_lv = 9 -- 서버에서 오는 flv는 9가 max

    local guide = curr_lv < max_lv
    return guide
end

-------------------------------------
-- function analysis_evolution
-- @brief 진화가 가능한지 (몬스터 제외)
-------------------------------------
function DragonGuideNavigator.analysis_evolution(dragon_data)
    local did = dragon_data['did']
	if (TableDragon:isUnderling(did)) then
		return false
	end

    local curr_evolution = dragon_data['evolution']
    local max_evolution = MAX_DRAGON_EVOLUTION

    local guide = curr_evolution < max_evolution
    return guide
end

-------------------------------------
-- function analysis_grade
-- @brief 승급이 가능한지
-------------------------------------
function DragonGuideNavigator.analysis_grade(dragon_data)
    local curr_grade = dragon_data['grade']
    local max_grade = MAX_DRAGON_GRADE

    local guide = curr_grade < max_grade
    return guide
end

-------------------------------------
-- function analysis_skill_enc
-- @brief 스킬 레벨업이 가능한지
-------------------------------------
function DragonGuideNavigator.analysis_skill_enc(dragon_data)
    local doid = dragon_data['id']
    local guide = g_dragonsData:haveSkillSpareLV(doid)
    return guide
end

-------------------------------------
-- function analysis_reinforce
-- @brief 드래곤 강화가 가능한지 (몬스터 제외)
-------------------------------------
function DragonGuideNavigator.analysis_reinforce(dragon_data)
    local did = dragon_data['did']
	if (TableDragon:isUnderling(did)) then
		return false
	end

    local curr_reinforce = dragon_data['reinforce']['lv']
    local max_reinforce = MAX_DRAGON_REINFORCE

    local guide = curr_reinforce < max_reinforce
    return guide
end






-------------------------------------
-- function getDragonMaxLv
-- @brief Max 레벨 반환
-------------------------------------
function DragonGuideNavigator:getDragonMaxLv(grade)
    local table_dragon_exp = TableDragonExp()
    local l_exp_data = table_dragon_exp:filterList('grade', grade)

    local max_lv = 0
    for i,v in pairs(l_exp_data) do
        local level =  v['lv']
        local level_number = tonumber(level)
        if level_number then
            max_lv = math_max(max_lv, level_number)
        end
    end

    return max_lv
end

-------------------------------------
-- function getText
-- @brief 서브메뉴 텍스트 반환
-------------------------------------
function DragonGuideNavigator:getText(link)
    local text = ''

    if (link == 'level_up') then
        text = Str('레벨업')

    elseif (link == 'rune') then
        text = Str('룬 관리')

    elseif (link == 'friendship') then
        text = Str('친밀도')

    elseif (link == 'evolution') then
        text = Str('진화')

    elseif (link == 'grade') then
        text = Str('승급')

    elseif (link == 'skill_enc') then
        text = Str('스킬 레벨업')

    elseif (link == 'reinforce') then
        text = Str('강화')
    end

    return text
end