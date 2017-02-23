-------------------------------------
-- table Util_BuffStringParser
-------------------------------------
Util_BuffStringParser = {}

-------------------------------------
-- function parseBuffString
-------------------------------------
function Util_BuffStringParser:parseBuffString(str)
    -- 테스트 문자열
    --local str = 'atk;multi;2, hit_rate;add;4'

    -- 공백 제거
    str = string.gsub(str, ' ', '')

    -- 개행 제거
    str = string.gsub(str, '\n', '')

    -- ','로 분리
    local l_element = TableClass:seperate(str, ',')

    -- ','로 분리된 개별의 문자열을 분석
    local t_ret = {}
    for i,v in ipairs(l_element) do
        local status, action, value = self:parseBuffStringIndivisual(v)
        local t_data = {}
        t_data['status'] = status
        t_data['action'] = action
        t_data['value'] = value
        table.insert(t_ret, t_data)
    end

    return t_ret
end

-------------------------------------
-- function parseBuffStringIndivisual
-------------------------------------
function Util_BuffStringParser:parseBuffStringIndivisual(str)
    local l_element = TableClass:seperate(str, ';')

    -- 능력치 타입
    local status = l_element[1]
    if (not isExistValue(status, 'atk', 'def', 'hp', 'aspd', 'cri_chance', 'cri_dmg', 'cri_avoid', 'hit_rate', 'avoid')) then
        error('status : ' .. status)
    end

    -- 액션 타입
    local action = l_element[2]
    if (not isExistValue(action, 'add', 'multi')) then
        error('action : ' .. action)
    end

    -- 값 (action이 multi일 경우 단위는 5==5%를 의미함)
    local value = tonumber(l_element[3])

    return status, action, value
end