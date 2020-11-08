-------------------------------------
-- International System of Units, 국제단위계
-- 1000단위마다 단위를 붙여 숫자를 짧게 표시하기 위한 유틸
-- 195604 -> 195K
-- 56419564 -> 56M
-------------------------------------
local PREFIXES = {}
PREFIXES[24] = 'Y'
PREFIXES[21] = 'Z'
PREFIXES[18] = 'E'
PREFIXES[15] = 'P'
PREFIXES[12] = 'T'
PREFIXES[9] = 'G'
PREFIXES[6] = 'M'
PREFIXES[3] = 'k'
PREFIXES[0] = ''
PREFIXES[-3] = 'm'
PREFIXES[-6] = 'µ'
PREFIXES[-9] = 'n'
PREFIXES[-12] = 'p'
PREFIXES[-15] = 'f'
PREFIXES[-18] = 'a'
PREFIXES[-21] = 'z'
PREFIXES[-24] = 'y'

-------------------------------------
-- function FormatSIPrefix
-- @brief 숫자를 K, M과 같은 1000자리의 단위를 붙여 문자열로 리턴
-- @param num number e.g. 97124
-- @return string e.g. 97K
-------------------------------------
function FormatSIPrefix(num)
    if (tonumber(num) == nil) then
        return ''
    end

    if (num == 0) then
        return '0'
    end

    local sig = math_abs(num) -- significand
    local exponent = 0;

    -- while문의 조건을 1000이 아닌 10000으로 하는 이유는 네자리까지는 보여주기 위함이다.
    -- e.g.1 9999
    --       X : 9K
    --       O : 9999
    -- e.g.1 99999
    --       O : 99K
    --       X : 99999
    while ((sig >= 10000) and (exponent < 24)) do
        sig = (sig / 1000)
        exponent = (exponent + 3)
    end

    while (sig < 1) and (exponent > -24) do
        sig = (sig * 1000)
        exponent = (exponent - 3)
    end

    -- 양수, 음수 표기
    local sig_prefix = ''
    if (num < 0) then
        sig_prefix = '-'
    else
        sig_prefix = ''
    end

    -- 소수점은 표시하지 않는다.(floor로 버림 처리)
    return sig_prefix .. math_floor(sig) .. PREFIXES[exponent]
end