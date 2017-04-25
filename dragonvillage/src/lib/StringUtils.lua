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
            rand = math.random(#chars)
            if find(usedNums, ":"..rand..":") == nil then break end
        end
        res = res..chars[rand]
        usedNums = usedNums..rand..":"
    end
    return res
end

function stringExample()
    cclog(string.format('%.3d', 8)) -- 008
    cclog(string.format('%.2f', 8)) -- 8.00
end

function getFileName(url)
    return url:match("(.+)%..+")
end

function getFileExtension(url)
    return url:match('^.+(%..+)$')
end