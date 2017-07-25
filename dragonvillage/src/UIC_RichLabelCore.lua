-------------------------------------
-- function makeContentListByRichText
-- @brief 
-------------------------------------
function UIC_RichLabel:makeContentListByRichText(text)
    if (not self:stringStarts(text, '{@')) then
        text = '{@default}' .. text
    end

    local l_str = self:parseRichText(text)

    local l_content = {}

    local idx = 0
    while true do
        local key = l_str[idx + 1]
        local text = l_str[idx + 2]
        local is_button = false

        -- key나 value가 없을 경우 break
        if (not key) then
            break
        elseif (key) and (not text) then
            cclog('!!!error')
            break
        end

        local t_content = self:makeContentData(key, text)
        table.insert(l_content, t_content)

        -- index 증가
        idx = idx + 2
    end
    
    return l_content
end

-------------------------------------
-- function makeContentData
-- @brief 
-------------------------------------
function UIC_RichLabel:makeContentData(key, text)
    -- 개행 처리
    local l_line = self:strSplit(text, '\n')
    
    -- 시작 문자가 개행일 경우
    local _, cnt = self:stringStarts(text, '\n')
    for i=1, cnt do
        table.insert(l_line, 1, '')
    end

    -- 종료 문자가 개행일 경우
    local _, cnt = self:stringEnds(text, '\n')
    for i=1, cnt do
        table.insert(l_line, '')
    end

    -- 버튼인지 체크
    local is_button = false
    if (string.byte(key, 1) == 35) then -- '#' == 35
        key = string.gsub(key, '#', '', 1)
        is_button = true
    end

    -- 노드 저장
    local is_save = false
    if (string.byte(key, 1) == 38) then -- '&' == 38
        key = string.gsub(key, '&', '', 1)
        is_save = true
    end

    local l_key = self:strSplit(key, ';')

    local t_content = {key=l_key[1], type=l_key[2], id=l_key[3], is_button=is_button, lines=l_line, is_save=is_save}
    return t_content
end

-------------------------------------
-- function splitRichText
-- @brief 
-------------------------------------
function UIC_RichLabel:parseRichText(text)
    local l_list = self:strSplit(text, '{@')
    
    -- {@}처리되지 않은 문자열 들어왔을 시 
    if (nil == l_list) then 
        local l_ret = {}
        l_ret[1] = text
        return l_ret
    end
    
    local l_ret = {}
    for i,v in ipairs(l_list) do
        local idx = string.find(v, '}')

        if (idx == nil) then
            cclog('@@ RichLabel Error! ' .. v)
            break
        end
        
        local key = string.sub(v, 1, idx-1)
        local value = string.sub(v, idx+1, string.len(v))

        table.insert(l_ret, key)
        table.insert(l_ret, value)
    end
    
    return l_ret
end

-------------------------------------
-- function strSplit
-- @brief 문자열을 sep문자 기준으로 분리
-------------------------------------
function UIC_RichLabel:strSplit(inputstr, sep)
    if (sep == nil) then
        sep = "%s"
    end

    local t={}
    local i = 1

    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end

    return t
end

-------------------------------------
-- function stringStarts
-- @brief 문자열이 start_str문자열로 시작되는지 확인
-------------------------------------
function UIC_RichLabel:stringStarts(str, start_str)
    local str_len = string.len(start_str)
    local cnt = 0
    local idx = 1
    while true do
        local sub_str = string.sub(str, idx, idx + (str_len- 1))

        if (sub_str ~= start_str) then
            break
        end

        cnt = cnt + 1
        idx = idx + str_len
    end

    return (0 < cnt), cnt
end

-------------------------------------
-- function stringEnds
-- @brief 문자열이 start_str문자열로 종료되는지 확인
-------------------------------------
function UIC_RichLabel:stringEnds(str, end_str)
   if (end_str == '') then
    return true
   end

   local str_len = string.len(end_str)
   local cnt = 0
   local idx = string.len(str)
    while true do
        local sub_str = string.sub(str, idx - (str_len- 1), idx)

        if (sub_str ~= end_str) then
            break
        end

        cnt = cnt + 1
        idx = idx - str_len
    end

    return (0 < cnt), cnt
end


-------------------------------------
-- function contentListToPureText
-- @brief 
-------------------------------------
function UIC_RichLabel:contentListToPureText(l_content)
    local text = ''

    for _,v in ipairs(l_content) do
        for i,str in ipairs(v['lines']) do
            if (i == 1) then
                text = text .. str
            else
                text = text .. '\n' .. str
            end
        end
    end

    return text
end

-------------------------------------
-- function initGLNode
-------------------------------------
function UIC_RichLabel:initGLNode()
    -- glNode 생성
    local glNode = cc.GLNode:create()
    glNode:registerScriptDrawHandler(function(transform, transformUpdated) self:primitivesDraw(transform, transformUpdated) end)
    self.m_root:addChild(glNode)
end

-------------------------------------
-- function primitivesDraw
-- @brief RichLabel의 텍스트 영역을 draw
-------------------------------------
function UIC_RichLabel:primitivesDraw(transform, transformUpdated)
    kmGLPushMatrix()
    kmGLLoadMatrix(transform)

    local width, height = self.m_root:getNormalSize()
    local origin = cc.p(0, 0)
    local destination = cc.p(width, height)
    local color = cc.c4f(0.2, 0.2, 0.2, 0.5)
    cc.DrawPrimitives.drawSolidRect(origin, destination, color)

    kmGLPopMatrix()
end

-------------------------------------
-- function charList
-------------------------------------
function UIC_RichLabel:charList(str) -- UTF-8 을 유니코드 테이블로
    local tbl = {}
    local a = 1
    for i=1, str:len() do
        -- 1byte
        if str:byte(i) >= 0 and str:byte(i) <= 127 then
            tbl[a] = string.sub(str, i, i)
            a = a+1

        -- 2byte
        elseif str:byte(i) >= 194 and str:byte(i) <= 223 then
            tbl[a] = string.sub(str, i, i + 1)
            i = i+1
            a = a+1

        -- 3byte
        elseif str:byte(i) >= 224 and str:byte(i) <= 239 then
            tbl[a] = string.sub(str, i, i + 2)
            i = i+2
            a = a+1

        -- 4byte
        elseif str:byte(i) >= 240 and str:byte(i) <= 244 then
            tbl[a] = string.sub(str, i, i + 3)
            i = i+3
            a = a+1
        end
    end
    
    return tbl
end