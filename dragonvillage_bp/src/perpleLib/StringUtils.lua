--[[
Copyright (C) 2012 Thomas Farr a.k.a tomass1996 [farr.thomas@gmail.com]

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

-The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-Visible credit is given to the original author.
-The software is distributed in a non-profit way.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

function toCharTable(str)  --Returns table of @str's chars
    if not str then return nil end
    str = tostring(str)
    local chars = {}
    for n=1,#str do
        chars[n] = str:sub(n,n)
    end
    return chars
end

function toByteTable(str)  --Returns table of @str's bytes
    if not str then return nil end
    str = tostring(str)
    local bytes = {}
    for n=1,#str do
        bytes[n] = str:byte(n)
    end
    return bytes
end

function fromCharTable(chars)  --Returns string made of chracters in @chars
    if not chars or type(chars)~="table" then return nil end
    return table.concat(chars)
end

function fromByteTable(bytes)  --Returns string made of bytes in @bytes
    if not bytes or type(bytes)~="table" then return nil end
    local str = ""
    for n=1,#bytes do
        str = str..string.char(bytes[n])
    end
    return str
end

function contains(str,find)  --Returns true if @str contains @find
    if not str then return nil end
    str = tostring(str)
    for n=1, #str-#find+1 do
        if str:sub(n,n+#find-1) == find then return true end
    end
    return false
end

function startsWith(str,Start) --Check if @str starts with @Start
    if not str then return nil end
    str = tostring(str)
    return str:sub(1,Start:len())==Start
end

function endsWith(str,End)  --Check if @str ends with @End
    if not str then return nil end
    str = tostring(str)
    return End=='' or str:sub(#str-#End+1)==End
end

function trim(str)  --Trim @str of initial/trailing whitespace
    if not str then return nil end
    str = tostring(str)
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

function firstLetterUpper(str)  --Capitilizes first letter of @str
    if not str then return nil end
    str = tostring(str)
    str = str:gsub("%a", string.upper, 1)
    return str
end

function titleCase(str)  --Changes @str to title case
    if not str then return nil end
    str = tostring(str)
    local function tchelper(first, rest)
        return first:upper()..rest:lower()
    end
    str = str:gsub("(%a)([%w_']*)", tchelper)
    return str
end

function isRepetition(str, pat)  --Checks if @str is a repetition of @pat
    if not str then return nil end
    str = tostring(str)
    return "" == str:gsub(pat, "")
end

function isRepetitionWS(str, pat)  --Checks if @str is a repetition of @pat seperated by whitespaces
    if not str then return nil end
    str = tostring(str)
    return not str:gsub(pat, ""):find"%S"
end

function urlDecode(str)  --Url decodes @str
    if not str then return nil end
    str = tostring(str)
    str = string.gsub (str, "+", " ")
    str = string.gsub (str, "%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
    str = string.gsub (str, "\r\n", "\n")
    return str
end

function urlEncode(str)  --Url encodes @str
    if not str then return nil end
    str = tostring(str)
    if (str) then
        str = string.gsub (str, "\n", "\r\n")
        str = string.gsub (str, "([^%w ])", function (c) return string.format ("%%%02X", string.byte(c)) end)
        str = string.gsub (str, " ", "+")
    end
    return str
end

function isEmailAddress(str)  --Checks if @str is a valid email address
    if not str then return nil end
    str = tostring(str)
    if (str:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then
        return true
    else
        return false
    end
end

function chunk(str, size)  --Splits @str into chunks of length @size
    if not size then return nil end
    str = tostring(str)
    local num2App = size - (#str%size)
    str = str..(string.rep(string.char(0), num2App) or "")
    assert(#str%size==0)
    local chunks = {}
    local numChunks = #str / size
    local chunk = 0
    while chunk < numChunks do
        local start = chunk * size + 1
        chunk = chunk+1
        if start+size-1 > #str-num2App then
            if str:sub(start, #str-num2App) ~= (nil or "") then
                chunks[chunk] = str:sub(start, #str-num2App)
            end
        else
            chunks[chunk] = str:sub(start, start+size-1)
        end
    end
    return chunks
end

function find(str, match, startIndex)  --Finds @match in @str optionally after @startIndex
    if not match then return nil end
    str = tostring(str)
    local _ = startIndex or 1
    local _s = nil
    local _e = nil
    local _len = match:len()
    while true do
        local _t = str:sub( _ , _len + _ - 1)
        if _t == match then
            _s = _
            _e = _ + _len - 1
            break
        end
        _ = _ + 1
        if _ > str:len() then break end
    end
    if _s == nil then return nil else return _s, _e end
end

function seperate(str, divider)  --Separates @str on @divider
    if not divider then return nil end
    str = tostring(str)
    if str == "" then return nil end
    local start = {}
    local endS = {}
    local n=1
    repeat
        if n==1 then
            start[n], endS[n] = find(str, divider)
        else
            start[n], endS[n] = find(str, divider, endS[n-1]+1)
        end
        n=n+1
    until start[n-1]==nil
    if #start == 0 then return nil end
    local subs = {}
    for n=1, #start+1 do
        if n==1 then
            subs[n] = str:sub(1, start[n]-1)
        elseif n==#start+1 then
            subs[n] = str:sub(endS[n-1]+1)
        else
            subs[n] = str:sub(endS[n-1]+1, start[n]-1)
        end
    end
    return subs
end

function seperate_line(str)  --Separates @str
    local t_str = {}
    for token in string.gmatch(str, '([^-]+)') do
        table.insert(t_str, token)
    end

    return t_str
end

function seperate_semiconlon(str)  --Separates @str
    local t_str = {}
    for token in string.gmatch(str, '([^;]+)') do
        table.insert(t_str, token)
    end

    return t_str
end

function seperate_dot(str)  --Separates @str
    local t_str = {}
    for token in string.gmatch(str, '([^.]+)') do
        table.insert(t_str, token)
    end

    return t_str
end

function replace(str, from, to)  --Replaces @from to @to in @str
    if not from then return nil end
    str = tostring(str)
    local pcs = seperate(str, from)
    str = pcs[1]
    for n=2,#pcs do
        str = str..to..pcs[n]
    end
    return str
end

function jumble(str)  --Jumbles @str
    if not str then return nil end
    str = tostring(str)
    local chars = {}
    for i = 1, #str do
        chars[i] = str:sub(i, i)
    end
    local usedNums = ":"
    local res = ""
    local rand = 0
    for i=1, #chars do
        while true do
            rand = math_random(#chars)
            if find(usedNums, ":"..rand..":") == nil then break end
        end
        res = res..chars[rand]
        usedNums = usedNums..rand..":"
    end
    return res
end

-------------------------------------
-- @function u8touc
-- @brief UTF-8 을 유니코드 테이블로
-------------------------------------
function u8touc(str)
    local tbl = {}
    local tbl_char_end_byte = {} -- 각 문자의 종료 byte index를 저장 (외부에서 문자열을 자를 때 사용하기 위함)
    local byte_len = str:len() -- 문자열의 byte 길이
    local str_len = 0 -- 문자열의 char 길이
    
    local i = 1 -- 문자의 시작 idx
    while (i <= byte_len) do
        -- 현재 문자의 byte
        local char_byte = 0
        if (str:byte(i) >= 0 and str:byte(i) <= 127) then
            char_byte = 1
        elseif (str:byte(i) >= 194 and str:byte(i) <= 223) then
            char_byte = 2
        elseif (str:byte(i) >= 224 and str:byte(i) <= 239) then
            char_byte = 3
        elseif (str:byte(i) >= 240 and str:byte(i) <= 244) then
            char_byte = 4
        else
            break
        end

        -- 현재 문자의 byte index가 문자열의 byte_len을 넘어설 경우 stop
        if (byte_len < i+(char_byte-1)) then
            break
        end

        -- 현재 문자의 byte별 처리
        if (char_byte == 1) then
            tbl[str_len] = str:byte(i)

        elseif (char_byte == 2) then
            tbl[str_len] = ((str:byte(i) - 192) * 64) + (str:byte(i+1) - 128)

        elseif (char_byte == 3) then
            tbl[str_len] = ((str:byte(i) - 224) * 64 * 64) + ((str:byte(i+1) - 128) * 64) + (str:byte(i+2) - 128)

        elseif (char_byte == 4) then
            print (str:byte(i,i+3)) -- sgkim 이건 뭐지???

        end

        -- byte index 증가
        i = (i + char_byte)

        -- 문자열 길이 증가
        str_len = (str_len + 1)

        -- 문자의 종료 byte를 저장
        tbl_char_end_byte[str_len] = (i - 1)
    end

    -- for key,value in pairs(tbl) do tbl[key] = string.format("%04X", value) print(key, tbl[key]) end
    return tbl, str_len, tbl_char_end_byte
end

-------------------------------------
-- @function uc_len
-- @brief 실제 문자열의 길이 (byte 길이 X)
-------------------------------------
function uc_len(str)
    if (not str) then
        return 0
    end

    local tbl, str_len, tbl_char_end_byte = u8touc(str)
    return str_len
end

-------------------------------------
-- @function utf8_sub
-- @brief utf8인코딩의 문자열에서 문자 단위로 len길이 만큼만 자른 문자열 리턴
-------------------------------------
function utf8_sub(str, len)
    local tbl, str_len, tbl_char_end_byte = u8touc(str)

    -- len이 없으면 분석된 문자열의 길이로 수행
    len = (len or str_len)
    local target_len = math_min(str_len, len)

    local _str = string.sub(str, 1, tbl_char_end_byte[target_len])
    return _str
end


--do not want to change rand seed. (2012/10/31 by jjo)
--[[
function setRandSeed(seed)  --Sets random seed to @seed
    math_randomseed(seed)
end

setRandSeed(os.time())
--]]

-------------------------------------
-- @table ValidStrUtils
-- @brief 유효한 텍스트인지 확인하는 유틸
-------------------------------------
ValidStrUtils = {}

-------------------------------------
-- @function checkRange_3byte
-- @brief 3바이트 문자들의 범위 확인
-------------------------------------
function ValidStrUtils:checkRange_3byte(str, idx, start_1, start_2, start_3, end_1, end_2, end_3)
    local byte_1 = string.byte(str, idx)
    local byte_2 = string.byte(str, idx + 1)
    local byte_3 = string.byte(str, idx + 2)

    -- 유효하지 않은 byte일 경우
    if (not byte_1) or (not byte_2) or (not byte_3) then
        return false
    end

    -- 작을 경우 리턴
    if byte_1 < start_1 then
        return false

    -- 첫 바이트 같을 경우
    elseif byte_1 == start_1 then
        if byte_2 < start_2 then
            return false
        elseif byte_2 == start_2 then
            if byte_3 < start_3 then
                return false
            else
                return true
            end
        else
            return true
        end

    -- 가운데 문자
    elseif start_1 < byte_1 and byte_1 < end_1 then
        return true

    -- 마지막 바이트가 같을 경우
    elseif byte_1 == end_1 then
        if end_2 < byte_2 then
            return false
        elseif byte_2 == end_2 then
            if end_3 < byte_3 then
                return false
            else
                return true
            end
        else
            return true
        end

    -- 클 경우 리턴
    elseif byte_1 > end_1 then
        return false
    end
end

-------------------------------------
-- @function checkRange_4byte
-- @brief 4바이트 문자들의 범위 확인
-------------------------------------
function ValidStrUtils:checkRange_4byte(str, idx, start_1, start_2, start_3, start_4, end_1, end_2, end_3, end_4)
    local byte_1 = string.byte(str, idx)
    local byte_2 = string.byte(str, idx + 1)
    local byte_3 = string.byte(str, idx + 2)
    local byte_4 = string.byte(str, idx + 3)

    -- 유효하지 않은 byte일 경우
    if (not byte_1) or (not byte_2) or (not byte_3) or (not byte_4) then
        return false
    end

    -- 작을 경우 리턴
    if byte_1 < start_1 then
        return false

    -- 첫 바이트 같을 경우
    elseif byte_1 == start_1 then
        if byte_2 < start_2 then
            return false
        elseif byte_2 == start_2 then
            if byte_3 < start_3 then
                return false
            elseif byte_3 == start_3 then
                if byte_4 < start_4 then
                    return false
                else
                    return true
                end
            else
                return true
            end
        else
            return true
        end

    -- 가운데 문자
    elseif start_1 < byte_1 and byte_1 < end_1 then
        return true

    -- 마지막 바이트가 같을 경우
    elseif byte_1 == end_1 then
        if end_2 < byte_2 then
            return false
        elseif byte_2 == end_2 then
            if end_3 < byte_3 then
                return false
            elseif end_3 == byte_3 then
                if end_4 < byte_4 then
                    return false
                else
                    return true
                end
            else
                return true
            end
        else
            return true
        end

    -- 클 경우 리턴
    elseif byte_1 > end_1 then
        return false
    end
end

-------------------------------------
-- @function checkNumber
-- @brief 숫자 확인 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
-------------------------------------
function ValidStrUtils:checkNumber(str, idx)
    local byte = string.byte(str, idx)

    if (not byte) then
        return false
    elseif 48 <= byte and byte <= 57 then
        return true
    else
        return false
    end
end

-------------------------------------
-- @function checkEnglish_Capital
-- @brief 영어 대문자 확인 A-Z
-------------------------------------
function ValidStrUtils:checkEnglish_Capital(str, idx)
    local byte = string.byte(str, idx)

    if (not byte) then
        return false

    -- 대문자
    elseif 65 <= byte and byte <= 90 then
        return true

    else
        return false
    end
end

-------------------------------------
-- @function checkEnglish_Small
-- @brief 영어 소문자 확인 A-Z
-------------------------------------
function ValidStrUtils:checkEnglish_Small(str, idx)
    local byte = string.byte(str, idx)

    if (not byte) then
        return false

    -- 소문자
    elseif 97 <= byte and byte <= 122 then
        return true

    else
        return false
    end
end

-------------------------------------
-- @function checkKorean
-- @brief 한국어 확인 가-힣 (234 176 128 ~ 237 158 163)
-------------------------------------
function ValidStrUtils:checkKorean(str, idx)
    return self:checkRange_3byte(str, idx, 234, 176, 128, 237, 158, 163)
end

-------------------------------------
-- @function checkJapanese
-- @brief 일본어 확인
-- 히라가나 (227 129 129 ~ 227 130 150)
-- 카타카나 (227 130 153 ~ 227 131 191)
-------------------------------------
function ValidStrUtils:checkJapanese(str, idx)
    return self:checkRange_3byte(str, idx, 227, 129, 129, 227, 131, 191)
end

-------------------------------------
-- @function checkChinese_3byte
-- @brief 중국어 확인 3바이트
-------------------------------------
function ValidStrUtils:checkChinese_3byte(str, idx)

    while true do

        -- <CJK Ideograph Extension A, First> 227 144 128 한자
        -- <CJK Ideograph Extension A, Last> 228 182 181 한자
        if self:checkRange_3byte(str, idx, 227, 144, 128, 228 ,182 ,181) then
            return true
        end

        -- <CJK Ideograph, First> 228 184 128 한자
        -- <CJK Ideograph> 233 190 187 한자끝
        -- <CJK Ideograph, Last> 233 191 140 네모
        if self:checkRange_3byte(str, idx, 228, 184, 128, 233, 190, 187) then
            return true
        end

        -- <CJK COMPATIBILITY IDEOGRAPH-F900> 239 164 128 한자
        -- <CJK COMPATIBILITY IDEOGRAPH-FA6A> 239 169 170 한자끝
        -- <CJK COMPATIBILITY IDEOGRAPH-FAD9> 239 171 153 네모
        if self:checkRange_3byte(str, idx, 239, 164, 128, 239, 169, 170) then
            return true
        end

        break
    end

    return false
    
end

-------------------------------------
-- @function checkChinese_4byte
-- @brief 중국어 확인 4바이트
-------------------------------------
function ValidStrUtils:checkChinese_4byte(str, idx)
    -- <CJK Ideograph Extension B, First> 240 160 128 128 한자
    -- <CJK Ideograph Extension B, Last> 240 170 155 150 한자
    return self:checkRange_4byte(str, idx, 240, 160, 128, 128, 240, 170, 155, 150)

    -- <CJK Ideograph Extension C, First> 240 170 156 128 네모
    -- <CJK Ideograph Extension C, Last> 240 171 156 180 네모

    -- <CJK Ideograph Extension D, First> 240 171 157 128 네모
    -- <CJK Ideograph Extension D, Last> 240 171 160 157 네모
end

-------------------------------------
-- @function checkThai_3byte
-- @brief 태국어 확인 3바이트
-------------------------------------
function ValidStrUtils:checkThai_3byte(str, idx)
    return self:checkRange_3byte(str, idx, 224, 184, 129, 224, 185, 155)
end

-------------------------------------
-- @function checkNickName_forGsp
-- @brief gps에서 사용하는 닉네임 체크
-------------------------------------
function ValidStrUtils:checkNickName_forGsp(str)
    local idx = 1
    local len = string.len(str)
    while true do
        -- 마지막 byte까지 확인 완료
        if len == (idx -1) then
            --cclog('# checkNickName_forGsp : true')
            return true

        -- 문자열 길이를 벗어났을 경우
        elseif len < (idx -1) then
            --cclog('# checkNickName_forGsp : false')
            return false
        end

        -- 숫자
        if self:checkNumber(str, idx) then
            idx = idx + 1

        -- 영어 대문자
        elseif self:checkEnglish_Capital(str, idx) then
            idx = idx + 1

        -- 영어 소문자
        elseif self:checkEnglish_Small(str, idx) then
            idx = idx + 1

        -- 한글
        elseif self:checkKorean(str, idx) then
            idx = idx + 3

        --[[
        -- 일본어
        elseif self:checkJapanese(str, idx) then
            idx = idx + 3

        -- 중국어 3바이트
        elseif self:checkChinese_3byte(str, idx) then
            idx = idx + 3

        -- 중국어 4바이트
        elseif self:checkChinese_4byte(str, idx) then
            idx = idx + 4

        -- 태국어
        elseif self:checkThai_3byte(str, idx) then
            idx = idx + 3
        ]]

        else
            --cclog('# checkNickName_forGsp : false', idx)
            return false

        end
    end

    return false
end

function getFileName(url)
    return url:match("(.+)%..+")
end

function getFileExtension(url)
    return url:match('^.+(%..+)$')
end