TEXT_V_ALIGN_TOP = 0
TEXT_V_ALIGN_CENTER = 1
TEXT_V_ALIGN_BOTTOM = 2

TEXT_H_ALIGN_LEFT = 0
TEXT_H_ALIGN_CENTER = 1
TEXT_H_ALIGN_RIGHT = 2

-- sample string
--[[
sample_rich_str = '{@#TAN:user:10001}[페이커]{@WHITE}님이 {@#GOLD:champ:10002}[5성 발키리]{@WHITE}를 {@DEEPSKYBLUE}챔피 언진화{@ORANGE}로 획득하셨습니다.'
sample_rich_str_1 = '{@TAN}실피즈{@WHITE}님이 {@GOLD}[5성 발키리]{@WHITE}를 {@DEEPSKYBLUE}챔피언 진화{@ORANGE}로 획득하셨습니다.'
sample_rich_str_2 = '{@TAN}샤키아 :{@WHITE} ㅊㅋㅊㅋ'
sample_rich_str_3 = '{@TAN}고모님 :{@WHITE} 쿠폰좀 알려주세여ㅠㅜ'
]]

-- dimensions : (공간의)크기, (높이,너비,길이의)치수

CARRIAGE_RETURN_TYPE_WORD = 0
CARRIAGE_RETURN_TYPE_CHAR = 1

local USE_LABEL_STRING_WIDTH = false
local UNDER_LINE_PNG = 'res/common/underline.png'
local EMPTY_PNG = 'res/common/empty.png'
local USE_GL_NODE = false

-------------------------------------
-- class RichLabel
-------------------------------------
RichLabel = class({
        m_root = 'cc.Node',
        m_menu = 'cc.Menu',
        m_originStr = 'string',
        m_fontSize = 'number',

        m_demensionsWidth = 'number',
        m_demensionsHeight = 'number',

        m_alignV = '',
        m_alignH = '',

        m_offsetX = 'number',
        m_offsetY = 'number',

        m_clickHandler = 'function',

        m_hTotalLength = '',
        m_vTotalLength = '',
        m_hNodeList = '',
        m_vNodeList = '',

        m_lineCount = '',

        m_carriageReturnType = '',
        m_bLimitMessage = '', -- 한줄로 표시, 지정된 길이가 넘어갈 경우 바로 자름
    })

-------------------------------------
-- function init
-- @brief
-- @param text
-- @param font_size
-- @param dimensions_width
-- @param dimensions_height
-------------------------------------
function RichLabel:init(text, font_size, dimensions_width, dimensions_height, align_h, align_v, dock_point, is_limit_message)
    self.m_bLimitMessage = is_limit_message

    -- root node 생성
    self.m_root = cc.Node:create()
    
    if dock_point then
        self.m_root:setDockPoint(dock_point)
        self.m_root:setAnchorPoint(dock_point)
    else
        self.m_root:setDockPoint(cc.p(0, 1))
        self.m_root:setAnchorPoint(cc.p(0, 1))
    end

    -- 문자열 초기화(실제 초기화는 setString 함수 내부에서)
    self.m_originStr = ''
    self.m_fontSize = font_size or 20

    -- 크기 지정
    self.m_demensionsWidth = dimensions_width or MAX_RESOLUTION_X
    self.m_demensionsHeight = dimensions_height or MAX_RESOLUTION_Y

    do -- offset 지정
        local anchor_point = self.m_root:getAnchorPoint()
        self.m_offsetX = -(self.m_demensionsWidth * anchor_point['x'])
        self.m_offsetY = (self.m_demensionsHeight * (1 - anchor_point['y']))
    end

    -- 정렬
    self.m_alignH = align_h or TEXT_H_ALIGN_LEFT
    self.m_alignV = align_v or TEXT_V_ALIGN_TOP

    self.m_carriageReturnType = CARRIAGE_RETURN_TYPE_CHAR

    self:setString(text or '')
end

-------------------------------------
-- function initGLNode
-------------------------------------
function RichLabel:initGLNode()
    -- glNode 생성
    local glNode = cc.GLNode:create()
    glNode:registerScriptDrawHandler(function(transform, transformUpdated) self:primitivesDraw(transform, transformUpdated) end)
    self.m_root:addChild(glNode)
end

-------------------------------------
-- function setString
-------------------------------------
function RichLabel:setString(str)
    if (self.m_originStr == str) then
        return
    end

    self.m_originStr = str

    -- 기존 label, icon 모두 삭제
    self.m_root:removeAllChildren();

    -- 모두 삭제되기 때문에 다시 생성
    if USE_GL_NODE then
        self:initGLNode()
    end

    self.m_hTotalLength = {}
    self.m_vTotalLength = {}
    self.m_hNodeList = {}

    -- 토큰으로 컨텐츠 분리
    local l_content = self:splitByToken(str)

    local idx_y = 0 -- 현재 출력중인 행(1행, 2행...)
    local pos_x = 0 -- 현재 출력중인 x포지션
    pos_x, idx_y = self:carriageReturn(pos_x, idx_y)
    local line_height = self.m_fontSize + 10 -- 행간
    local outline = 0 -- 폰트의 아웃라인(자간에도 사용됨)

    -- 컨텐츠를 순회하면서 생성
    for _,content in ipairs(l_content) do
        pos_x, idx_y = self:makeContent(content, pos_x, idx_y, line_height, outline)
    end

    -- 한줄로 표시, 지정된 길이가 넘어갈 경우 바로 자름
    if self.m_bLimitMessage then
        self.m_lineCount = 1
    end

    -- 정렬
    self:align()
end

-------------------------------------
-- function align
-------------------------------------
function RichLabel:align()
    -------------------------------------
    do -- 가로 정렬
    -------------------------------------
        -- 왼쪽 정렬
        if self.m_alignH == TEXT_H_ALIGN_LEFT then

        -- 가운데 정렬
        elseif self.m_alignH == TEXT_H_ALIGN_CENTER then
            for i,v in ipairs(self.m_hTotalLength) do
                local offset_x = (self.m_demensionsWidth - v) / 2

                for _,item in ipairs(self.m_hNodeList[i]) do
                    item['node']:setPositionX(item['pos_x'] + offset_x)
                end
            end

        -- 오른쪽 정렬
        elseif self.m_alignH == TEXT_H_ALIGN_RIGHT then
            for i,v in ipairs(self.m_hTotalLength) do
                local offset_x = (self.m_demensionsWidth - v)

                for _,item in ipairs(self.m_hNodeList[i]) do
                    item['node']:setPositionX(item['pos_x'] + offset_x)
                end
            end
        end
    end

    -------------------------------------
    do -- 세로 정렬
    -------------------------------------
        local line_height = self.m_fontSize + 10 -- 행간

        -- 위쪽 정렬
        if (self.m_alignV == TEXT_V_ALIGN_TOP) then

        -- 가운데 정렬
        elseif (self.m_alignV == TEXT_V_ALIGN_CENTER) then
            local start_i
            if (self.m_lineCount % 2) == 0 then
                start_i = (math_floor(self.m_lineCount / 2) - 0.5)
            else
                start_i = math_floor(self.m_lineCount / 2)
            end

            for i=1, self.m_lineCount do
                local pos_y = (start_i * line_height)

                for _,item in ipairs(self.m_hNodeList[i]) do
                    local node_y = pos_y
                    if item['offset_y'] then
                        node_y = node_y + item['offset_y']
                    end
                    item['node']:setPositionY(node_y)
                end

                start_i = start_i - 1
            end
        
        -- 아래쪽 정렬
        elseif (self.m_alignV == TEXT_V_ALIGN_BOTTOM) then
            local pos_y = -(self.m_demensionsHeight/2) + ((self.m_lineCount-0.5) * line_height)

            for i=1, self.m_lineCount do
                for _,item in ipairs(self.m_hNodeList[i]) do
                    local node_y = pos_y
                    if item['offset_y'] then
                        node_y = node_y + item['offset_y']
                    end
                    item['node']:setPositionY(node_y)
                end

                pos_y = pos_y - line_height
            end
        end
    end
end

-------------------------------------
-- function carriageReturn
-------------------------------------
function RichLabel:carriageReturn(pos_x, idx_y)
    pos_x = 0
    idx_y = idx_y + 1

    self.m_hTotalLength[idx_y] = 0
    self.m_hNodeList[idx_y] = {}

    -- 외부에서 사용하기 위해 저장
    self.m_lineCount = idx_y

    return pos_x, idx_y
end

-------------------------------------
-- function makeContent
-------------------------------------
function RichLabel:makeContent(content, pos_x, idx_y, line_height, outline)
    local color = content['key']
    local is_button = content['button']
    local l_line = content['lines']

    for line_i,text in ipairs(l_line) do

        -- l_line은 행간으로 구분되어 있으므로 개행
        if (line_i ~= 1) then
            pos_x, idx_y = self:carriageReturn(pos_x, idx_y)
        end

        -- text자체가 행간문자로 지정되었을 경우 개행
        if (text == '\n') then
            pos_x, idx_y = self:carriageReturn(pos_x, idx_y)
        else
            local work_text = text

            -- 1. work_text가 남아있는지 확인
            while (work_text ~= '') and (work_text ~= nil) do

                -- 한줄로 표시, 지정된 길이가 넘어갈 경우 바로 자름
                if self.m_bLimitMessage then
                    if idx_y > 1 then
                        return pos_x, pos_y
                    end
                end
                local label = cc.Label:createWithTTF(work_text, self:getFontName(), self.m_fontSize, outline)
                label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
                label:setDockPoint(cc.p(0.5, 0.5))
                label:setAnchorPoint(cc.p(0, 0.5))
                self.m_root:addChild(label)

                local carriage_return = false

                -- 2. 가로 길이를 넘어갈 경우
                pos_x, idx_y, work_text, carriage_return = self:makeContent_checkTextWidth(label, work_text, pos_x, idx_y, line_height, outline, is_button)

                local x = self.m_offsetX + pos_x
                local y = self.m_offsetY - (line_height/2) - ((idx_y-1) * line_height)

                -- 3. 버튼 생성
                if is_button then
                    self:makeContent_makeButton(content, label, x, y, self:getColor(color), idx_y)
                end

                local msg_width = self:calcMsgWidth(label)

                -- 행의 총 길이 저장
                self.m_hTotalLength[idx_y] = pos_x + msg_width
                table.insert(self.m_hNodeList[idx_y], {node=label, pos_x=x})

                -- 위치 지정
                label:setPosition(x, y)
                pos_x = pos_x + msg_width - outline

                

                -- 개행
                if carriage_return then
                    pos_x, idx_y = self:carriageReturn(pos_x, idx_y)
                end

                -- 생상 지정
                if color then
                    label:setColor(self:getColor(color))
                end
            end
        end
    end

    return pos_x, idx_y
end


-------------------------------------
-- function makeContent_checkTextWidth
-------------------------------------
function RichLabel:makeContent_checkTextWidth(label, work_text, pos_x, idx_y, line_height, outline, is_button)
    local msg_width = label:getContentSize()['width']

    if self.m_demensionsWidth >= (pos_x + msg_width) then
        return pos_x, idx_y, nil, false
    end

    -- 버튼일 경우 즉시 개행
    if is_button then
        pos_x, idx_y = self:carriageReturn(pos_x, idx_y)
        work_text = nil
        return pos_x, idx_y, work_text, false
    end

    --------------------------------------------------------------
    -- 단어 단위 개행
    --------------------------------------------------------------
    if (self.m_carriageReturnType == CARRIAGE_RETURN_TYPE_WORD) then
        local l_text = nil

        -- 공백' '으로 문자들을 분리
        local temp_text = string.gsub(work_text, ' ', '#@ ')
        l_text = self:strSplit(temp_text, '#@')

        -- 끝단어부터 하나씩 제거하면서 길이 확인
        local end_idx = #l_text
        local temp_str = work_text
        local carriage_return = false
        while true do
            temp_str = ''
            for i=1, end_idx do
                temp_str = temp_str .. l_text[i]
            end
            label:setString(temp_str)

            -- 하나의 단어만 남아도 길이가 넘어갈 경우 즉시 개행
            if (end_idx < 1) then

                -- 한줄로 표시, 지정된 길이가 넘어갈 경우 바로 자름
                if self.m_bLimitMessage then
                    return pos_x, idx_y, '', true
                end

                -- 개행 초기화
                pos_x, idx_y = self:carriageReturn(pos_x, idx_y)

                -- 첫 문자를 그대로 사용
                temp_str = l_text[1]

                -- 줄바꿈 시 첫번째 문자가 ' '(공백)일 경우 공백 제거
                if (string.byte(temp_str, 1) == 32) then -- '' 
                    temp_str = string.gsub(temp_str, ' ', '', 1)
                end
                label:setString(temp_str)
                         
                -- 처리되지 않은 남은 문자열 저장       
                work_text = ''
                for i=2, #l_text do
                    work_text = work_text .. l_text[i]
                end
                break

            -- 하나 이상의 문자가 남았고, 개행이 가능할 경우
            elseif (self.m_demensionsWidth >= (pos_x + self:calcMsgWidth(label))) then
                -- 처리되지 않은 남은 문자열 저장
                work_text = ''
                for i=end_idx+1, #l_text do
                    work_text = work_text .. l_text[i]
                end

                -- 문자열 출력 후 개행 명령
                carriage_return = true
                break
            end

            end_idx = end_idx - 1
        end

        return pos_x, idx_y, work_text, carriage_return

    --------------------------------------------------------------
    -- 문자 단위 개행
    --------------------------------------------------------------
    elseif (self.m_carriageReturnType == CARRIAGE_RETURN_TYPE_CHAR) then

        if (self.m_demensionsWidth < (pos_x + 22)) then
            pos_x, idx_y = self:carriageReturn(pos_x, idx_y)
            label:setString('')
            pos_x = 0
            return pos_x, idx_y, work_text, false
        end
        
        local buf = ''
        local str = nil
        local text = ''
        local carriage_return = false
        for c in string.gmatch(work_text, '.') do
            if (str == nil) then
                buf = buf .. c
                label:setString(buf)
                local width = self:calcMsgWidth(label)
                if (self.m_demensionsWidth < (pos_x + width + 22)) then
                    str = buf
                    carriage_return = true
                end
            else
                text = text .. c
            end
        end
        label:setString(str)
        work_text = text

        return pos_x, idx_y, work_text, carriage_return
    end
end

-------------------------------------
-- function makeContent_makeButton
-- @brief 텍스트 버튼 생성
-------------------------------------
function RichLabel:makeContent_makeButton(content, label, x, y, color, idx_y)
    local str = label:getString()
    local str_width = self:calcMsgWidth(label)
    local unserline = nil

    do -- underline 생성
        local x = x + (str_width/2)
        local y = y - (self.m_fontSize/2) - 1
        local scale_x = str_width/20

        local sprite = cc.Sprite:create(UNDER_LINE_PNG)
        self.m_root:addChild(sprite)
        sprite:setPosition(x, y)
        sprite:setScaleX(scale_x)

        if color then
            sprite:setColor(color)
        end
        unserline = sprite

        -- 정력 리스트에 삽입
        table.insert(self.m_hNodeList[idx_y], {node=sprite, pos_x=x, offset_y= -(self.m_fontSize/2)-1})
    end

    -- menu객체가 없을 경우 생성
    if (self.m_menu == nil) then
        self.m_menu = cc.Menu:create()
        self.m_menu:setDockPoint(cc.p(0.5, 0.5))
        self.m_menu:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_menu:setNormalSize(self.m_demensionsWidth, self.m_demensionsHeight)
        self.m_menu:setPosition(0, 0)
        self.m_root:addChild(self.m_menu, 1)
    end

    do -- 버튼 생성
        local x = x + (str_width/2)

        local button = cc.MenuItemImage:create(EMPTY_PNG, nil, nil, 0)
        button:setDockPoint(cc.p(0.5, 0.5))
        button:setAnchorPoint(cc.p(0.5, 0.5))
        button:setPosition(x, y)
        button:setContentSize(str_width, self.m_fontSize + 10)
        self.m_menu:addChild(button)

        -- 클릭 핸들러 지정
        local uic_button = UIC_Button(button)
        uic_button:registerScriptTapHandler(function() self:click_word(content, label, unserline, color, str) end)

        -- 정력 리스트에 삽입
        table.insert(self.m_hNodeList[idx_y], {node=button ,pos_x=x})
    end
end

-------------------------------------
-- function splitByToken
-- @brief 문자열의 색상, 버튼지정, 개행 등의 정보를 추출
-- ex) '{@#TAN}실피즈{@WHITE}님이 {@GOLD}[5성 발키리]{@WHITE}를 {@DEEPSKYBLUE}챔피언 진화{@ORANGE}로 획득하셨습니다.'
--     '{@%내용}'의 형태로 뒤에 등장할 문자열의 색상, 버튼을 지정함
--     WHITE, GOLD, DEEPSKYBLUE등은 색상을 지정
--     #는 버튼 기능을 추가
-------------------------------------
function RichLabel:splitByToken(str)
    local l_str = self:parseRichStr(str)

    local l_content = {}

    local idx = 0
    while true do
        local key = l_str[idx + 1]
        local text = l_str[idx + 2]
        local button = nil

        -- key나 value가 없을 경우 break
        if (not key) then
            break
        elseif (key) and (not text) then
            cclog('!!!error')
            break
        end

        -- 개행 처리
        local l_line = self:strSplit(text, '\n')

        -- 시작 문자가 개행일 경우
        if self:stringStarts(text, '\n') then
            table.insert(l_line, #l_line, '\n')
        end

        -- 종료 문자가 개행일 경우
        if self:stringEnds(text, '\n') then
            table.insert(l_line, '\n')
        end

        -- 버튼인지 체크
        if (string.byte(key, 1) == 35) then -- '#' == 35
            key = string.gsub(key, '#', '', 1)
            button = true
        end

        local l_key = self:strSplit(key, ':')

        local t_content = {key=l_key[1], type=l_key[2], id=l_key[3], button=button, lines=l_line}
        table.insert(l_content, t_content)

        -- index 증가
        idx = idx + 2
    end
    
    return l_content
end

-------------------------------------
-- function setPosition
-------------------------------------
function RichLabel:setPosition(x, y)
    self.m_root:setPosition(x, y)
end

-------------------------------------
-- function primitivesDraw
-- @brief RichLabel의 텍스트 영역을 draw
-------------------------------------
function RichLabel:primitivesDraw(transform, transformUpdated)
    kmGLPushMatrix()
    kmGLLoadMatrix(transform)

    local anchor_point = self.m_root:getAnchorPoint()

    local x = -(self.m_demensionsWidth * anchor_point['x'])
    local y = -(self.m_demensionsHeight * anchor_point['y'])

    local vertices =   
    {  
        
        cc.p(x, y),
        cc.p(x + self.m_demensionsWidth, y),
        cc.p(x + self.m_demensionsWidth, y + self.m_demensionsHeight),  
        cc.p(x + 0, y + self.m_demensionsHeight),  
    }  
    cc.DrawPrimitives.drawSolidPoly(vertices, 4, cc.c4f(0.2, 0.2, 0.2, 0.5))

    kmGLPopMatrix()
end

-------------------------------------
-- function registerClickHandler
-- @brief 버튼 클릭 핸들러 등록
-------------------------------------
function RichLabel:registerClickHandler(func)
    self.m_clickHandler = func
end

-------------------------------------
-- function click_word
-- @brief 버튼 클릭 핸들러
-------------------------------------
function RichLabel:click_word(content, label, underline, color, str)
    if self.m_clickHandler then
        self.m_clickHandler(content)
    end

    self:makeClickReaction(label, color)
    self:makeClickReaction(underline, color)
end

-- 클릭했을 시 색상
local CLICK_COLOR = cc.c3b(163, 73, 164)

-------------------------------------
-- function makeClickReaction
-------------------------------------
function RichLabel:makeClickReaction(node, org_color)
    if (not node) then
        return
    end

    -- 기존 액션 삭제
    node:stopAllActions()

    -- 클릭 색상으로 변경
    node:setColor(CLICK_COLOR)
    
    -- 액션 생성
    local sequence = cc.Sequence:create(
            --cc.TintTo:create(0.05, org_color['r'], org_color['g'], org_color['b']),
            --cc.TintTo:create(0.05, CLICK_COLOR['r'], CLICK_COLOR['g'], CLICK_COLOR['b']),
            --cc.DelayTime:create(1),
            cc.DelayTime:create(0.2),
            cc.TintTo:create(0.3, org_color['r'], org_color['g'], org_color['b'])
        )
    node:runAction(sequence)
end

-------------------------------------
-- function parseRichStr
-- @brief 
-------------------------------------
function RichLabel:parseRichStr(str)
    local l_list = seperate(str, '{@')
    
    -- {@}처리되지 않은 문자열 들어왔을 시 
    if nil == l_list then 
        local l_ret = {}
        l_ret[1] = str
        return l_ret
    end
    
    if (l_list[1] == '') then
        table.remove(l_list, 1)
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
-- function getPureStr
-- @brief 
-------------------------------------
function RichLabel:getPureStr(str)
    local l_list = seperate(str, '{@')

    if (not l_list) then
        return ''
    end

    if (l_list[1] == '') then
        table.remove(l_list, 1)
    end

    local pure_str = ''

    for i,v in ipairs(l_list) do
        local idx = string.find(v, '}')

        if (idx == nil) then
            cclog('@@ RichLabel Error! ' .. v)
            break
        end

        local value = string.sub(v, idx+1, string.len(v))
        pure_str = pure_str .. value
    end

    return pure_str
end

-------------------------------------
-- function strSplit
-- @brief 문자열을 sep문자 기준으로 분리
-------------------------------------
function RichLabel:strSplit(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
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
function RichLabel:stringStarts(str, start_str)
    return (string.sub(str, 1, string.len(start_str)) == start_str)
end

-------------------------------------
-- function stringEnds
-- @brief 문자열이 start_str문자열로 종료되는지 확인
-------------------------------------
function RichLabel:stringEnds(string, end_str)
   return (end_str == '') or (string.sub(string, -string.len(end_str)) == end_str)
end

-------------------------------------
-- function getStringWidth
-------------------------------------
function RichLabel:getStringWidth()
    local width = 0
    for i,v in ipairs(self.m_hTotalLength) do
        if width < v then
            width = v
        end
    end

    return width
end

-------------------------------------
-- function getStringHeight
-------------------------------------
function RichLabel:getStringHeight()
    local height = (self.m_lineCount * self.m_fontSize) + ((self.m_lineCount-1) * 10)
    return height
end

-------------------------------------
-- function getLineCount
-------------------------------------
function RichLabel:getLineCount()
    return self.m_lineCount
end

-------------------------------------
-- function calcMsgWidth
-------------------------------------
function RichLabel:calcMsgWidth(label)
    if USE_LABEL_STRING_WIDTH then
        return label:getStringWidth()
    else
        local msg = label:getString()

        local label = cc.Label:createWithTTF(msg, self:getFontName(), self.m_fontSize, 0)
        return label:getContentSize()['width']
    end
end

-------------------------------------
-- function makeAnEllipsis
-- @brief 말줄임표 생성(아직 개발 중)
-------------------------------------
function RichLabel:makeAnEllipsis()
    local pos_x = self.m_hTotalLength[1]

    local line_height = self.m_fontSize + 10 -- 행간
    local outline = 0 -- 폰트의 아웃라인(자간에도 사용됨)

    local label = cc.Label:createWithTTF('...', Translate:getFontPath(), self.m_fontSize, outline)
    label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0, 0.5))
    self.m_root:addChild(label)

    local x = self.m_offsetX + pos_x
    local y = self.m_offsetY - (line_height/2) - ((1-1) * line_height)


    local msg_width = self:calcMsgWidth(label:getString())

    -- 행의 총 길이 저장
    self.m_hTotalLength[1] = pos_x + msg_width

    table.insert(self.m_hNodeList[1], {node=label, pos_x=x})
end

-------------------------------------
-- function getColor
-------------------------------------
function RichLabel:getColor(color)
    if COLOR then
        return COLOR[color] or cc.c3b(255,255,255)
    else
        local COLOR = {}
        COLOR['ORANGE'] = cc.c3b(255,165,0)
        COLOR['GOLD'] = cc.c3b(255,215,0)
        COLOR['TAN'] = cc.c3b(210,180,140)
        COLOR['DEEPSKYBLUE'] = cc.c3b(0,191,255)

        -- 드래곤히어로즈 기존 채팅에서 사용되던 색상
        COLOR['NORMAL'] = cc.c3b(255, 255, 255)
        COLOR['GUILD'] = cc.c3b(0, 191, 255)
        COLOR['NOTICE'] = cc.c3b(165, 224, 0)
        COLOR['SYSTEM'] = cc.c3b(255, 231, 48)
        COLOR['WARNING'] = cc.c3b(255, 48, 48)

		-- 명조 색상
        COLOR['BLACK'] = cc.c3b(0, 0, 0)
		COLOR['DEEPGRAY'] = cc.c3b(100,100,100)
		COLOR['GRAY'] = cc.c3b(150,150,150)
		COLOR['LIGHTGRAY'] = cc.c3b(192,192,102)
        COLOR['WHITE'] = cc.c3b(255,255,255)

        COLOR['SKILL_NAME'] = cc.c3b(255, 145, 0)
        COLOR['SKILL_DESC'] = cc.c3b(245, 233, 220)

        COLOR['SPEECH'] = cc.c3b(102, 88, 71)

        return COLOR[color] or cc.c3b(255,255,255)
    end
end

-------------------------------------
-- function getFontName
-------------------------------------
function RichLabel:getFontName()
    --return Translate:getFontPath()
    return 'res/font/common_font_01.ttf'
end

-------------------------------------
-- function release
-------------------------------------
function RichLabel:release()
    if (self.m_root) then
        self.m_root:removeFromParent()
    end
    self.m_root = nil
end












-------------------------------------
-- function RichLabelSample
-------------------------------------
function RichLabelSample(parent_node)

    -- 1. getFontName() 함수에서 폰트명을 지정해 주셔야 합니다.
    -- 2. local UNDER_LINE_PNG = 'res/common/underline.png' 을 지정해 주셔야 합니다. (버튼에서 아래쪽 라인을 그려줄 png)
    -- 3. local EMPTY_PNG = 'res/common/empty.png' (눈에 보이지 않는 버튼을 생성하기 위한 png)


    -- label의 영역을 gl draw로 표시 여부
    USE_GL_NODE = false

    -- 매개변수 설정
    local text = '{@#TAN:user:10001}[페이커]{@WHITE}님이 {@#GOLD:champ:10002}[5성 발키리]{@WHITE}를 {@DEEPSKYBLUE}챔피 언진화{@ORANGE}로 획득하셨습니다.'
    local font_size = 20
    local dimensions_width = 640
    local dimensions_height = 320
    local align_h = TEXT_H_ALIGN_LEFT -- TEXT_H_ALIGN_LEFT, TEXT_H_ALIGN_CENTER, TEXT_H_ALIGN_RIGHT
    local align_v = TEXT_V_ALIGN_TOP -- TEXT_V_ALIGN_TOP, TEXT_V_ALIGN_CENTER, TEXT_V_ALIGN_BOTTOM
    local dock_point = cc.p(0.5, 0.5)
    local is_limit_message = false

    -- 인스턴스 생성
    local rich_label = RichLabel(text, font_size, dimensions_width, dimensions_height, align_h, align_v, dock_point, is_limit_message)

    -- addChild
    parent_node:addChild(rich_label.m_root)
end
