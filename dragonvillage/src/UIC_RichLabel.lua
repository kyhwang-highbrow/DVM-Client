-------------------------------------
-- class UIC_RichLabel
-------------------------------------
UIC_RichLabel = class({
        m_root = 'cc.Node',
        m_orgRichText = 'string',
        m_lContentList = 'list',

        m_fontSize = 'number',
        m_dimension = 'cc.Size',

        m_bDirty = 'boolean',

        m_nodeList = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_RichLabel:init()
    self.m_root = cc.Node:create()

    self.m_fontSize = 20
    self.m_dimension = cc.size(300, 720/2)
    self.m_root:setNormalSize(self.m_dimension)
    self.m_bDirty = true

    local function update(dt)
        self:update(dt)
    end
    self.m_root:scheduleUpdateWithPriorityLua(update, 0)

    self:initGLNode()
end

-------------------------------------
-- function setRichText
-------------------------------------
function UIC_RichLabel:setRichText(text)
    if (self.m_orgRichText == text) then
        return
    end

    self.m_orgRichText = text
    self.m_lContentList = self:makeContentListByRichText(text)

    self:setDirty()
end

-------------------------------------
-- function setDirty
-------------------------------------
function UIC_RichLabel:setDirty()
    self.m_bDirty = true
end

-------------------------------------
-- function update
-------------------------------------
function UIC_RichLabel:update(dt)
    if self.m_bDirty then
        self:makeContents()
        self.m_bDirty = false
    end
end

-------------------------------------
-- function makeContents
-------------------------------------
function UIC_RichLabel:makeContents()

    -- m_root에 붙어있는 node
    if self.m_nodeList then
        for i,v in pairs(self.m_nodeList) do
            v:removeFromParent()
        end
    end
    self.m_nodeList = {}


    local l_content = self.m_lContentList

    local pos_x, idx_y = 0, 0
    pos_x, idx_y = self:newLine(pos_x, idx_y)

    for _,t_content in ipairs(l_content) do
        pos_x, idx_y = self:makeIndivisualContent(t_content, pos_x, idx_y)
    end
end

-------------------------------------
-- function makeIndivisualContent
-------------------------------------
function UIC_RichLabel:makeIndivisualContent(t_content, pos_x, idx_y)
    local color = t_content['key']
    local is_button = t_content['is_button']
    local l_line = t_content['lines']

    -- 임시

    local outline = 1
    local line_height = self.m_fontSize * 1.1

    for i,text in ipairs(l_line) do

        -- l_line에서 두번째 항목부터는 \n로 개행했을 경우임
        if (1 < i) then
            pos_x, idx_y = self:newLine(pos_x, idx_y)
        end

        local work_text = text
        while (work_text) do
            -- label 생성
            local label = cc.Label:createWithTTF(work_text, self:getFontName(), self.m_fontSize, outline)
            label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
            label:setDockPoint(cc.p(0, 1))
            label:setAnchorPoint(cc.p(0, 1))
            self.m_root:addChild(label)
            table.insert(self.m_nodeList, label)

            -- 가로 길이 체크
            pos_x, idx_y, work_text, carriage_return = self:makeContent_checkTextWidth(label, work_text, pos_x, idx_y, line_height, outline, is_button)

            -- 현재 위치 지정
            local pos_y = -((idx_y - 1) * line_height)
            label:setPosition(pos_x, pos_y)

            -- 생상 지정
            if color then
                label:setColor(self:getColor(color))
            end

            -- 다음 pos_x
            pos_x = pos_x + label:getStringWidth() - outline -- (outline의 경우 자간에 영향을 줌)

            if carriage_return then
                pos_x, idx_y = self:newLine(pos_x, idx_y)
            end
        end
    end

    return pos_x, idx_y
end

-------------------------------------
-- function makeContent_checkTextWidth
-------------------------------------
function UIC_RichLabel:makeContent_checkTextWidth(label, work_text, pos_x, idx_y, line_height, outline, is_button)
    local msg_width = label:getStringWidth()

    if ((pos_x + msg_width) < self.m_dimension['width']) then
        return pos_x, idx_y, nil, false
    end

    -- 버튼일 경우 즉시 개행
    if is_button then
        work_text = nil
        return pos_x, idx_y, work_text, true
    end
    
    --[[
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
    --]]

        -- 한 글자라도 넘어가는 경우에는 즉시 리턴
        if (self.m_dimension['width'] < (pos_x + self.m_fontSize)) then
            label:setString('')
            local carriage_return = true
            return pos_x, idx_y, work_text, carriage_return
        end

        -- 문자 리스트를 얻어옴 (byte가 아닌 글자 단위 리스트)
        local l_char_list = self:charList(work_text)

        local buf = ''
        local str = nil
        local remain_text = ''
        local carriage_return = false
        for i, c in ipairs(l_char_list) do
            if (str == nil) then
                buf = buf .. c
                label:setString(buf)
                local width = label:getStringWidth()

                -- 개행이 되는 경우 체크
                if (self.m_dimension['width'] < (pos_x + width + self.m_fontSize)) then
                    str = buf
                    carriage_return = true
                end
            else
                -- 남은 텍스트 처리
                remain_text = remain_text .. c
            end
        end
        label:setString(str)
        work_text = remain_text

        return pos_x, idx_y, work_text, carriage_return
    --end
end

-------------------------------------
-- function newLine
-------------------------------------
function UIC_RichLabel:newLine(pos_x, idx_y)
    pos_x = 0
    idx_y = idx_y + 1

    --self.m_hTotalLength[idx_y] = 0
    --self.m_hNodeList[idx_y] = {}

    -- 외부에서 사용하기 위해 저장
    --self.m_lineCount = idx_y

    return pos_x, idx_y
end

-------------------------------------
-- function getFontName
-------------------------------------
function UIC_RichLabel:getFontName()
    return 'res/font/common_font_01.ttf'
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

-------------------------------------
-- function getColor
-------------------------------------
function UIC_RichLabel:getColor(color)
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
        COLOR['YELLOW'] = cc.c3b(255,255,0)
        COLOR['RED'] = cc.c3b(255,0,0)

        COLOR['SKILL_NAME'] = cc.c3b(255, 145, 0)
        COLOR['SKILL_DESC'] = cc.c3b(245, 233, 220)

        COLOR['SPEECH'] = cc.c3b(102, 88, 71)

        return COLOR[color] or cc.c3b(255,255,255)
    end
end

-------------------------------------
-- function setFontSize
-------------------------------------
function UIC_RichLabel:setFontSize(font_size)
    if (self.m_fontSize == font_size) then
        return
    end

    self.m_fontSize = font_size
    self:setDirty()
end

-------------------------------------
-- function setDimension
-------------------------------------
function UIC_RichLabel:setDimension(width, height)
    self.m_dimension = cc.size(width, height)
    self.m_root:setNormalSize(self.m_dimension)
    self:setDirty()
end