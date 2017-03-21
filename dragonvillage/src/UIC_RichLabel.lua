local PARENT = UIC_Node

-------------------------------------
-- class UIC_RichLabel
-------------------------------------
UIC_RichLabel = class(UIC_Node, {
        m_root = 'cc.Node',
        m_orgRichText = 'string',
        m_lContentList = 'list',

        m_fontSize = 'number',
        m_dimension = 'cc.Size',
        m_outlineSize = 'number',
        m_outlineColor = 'cc.c4b',

        m_bDirty = 'boolean',

        m_nodeList = 'list',
        m_lineCount = 'number',
        m_contentWidth = 'number',
        m_widthList = 'list',

        -- 정렬
        m_hAlignment = '',
        --cc.TEXT_ALIGNMENT_CENTER    = 0x1
        --cc.TEXT_ALIGNMENT_LEFT  = 0x0
        --cc.TEXT_ALIGNMENT_RIGHT = 0x2

        m_vAlignment = '',
        -- cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM   = 0x2
        -- cc.VERTICAL_TEXT_ALIGNMENT_CENTER   = 0x1
        -- cc.VERTICAL_TEXT_ALIGNMENT_TOP  = 0x0

        m_bDirtyAlignment = 'boolean',


        --------------------------------확장

        m_menu = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_RichLabel:init()
    self.m_root = cc.Node:create()
    self.m_node = self.m_root

    self.m_fontSize = 20
    self.m_dimension = cc.size(300, 720/2)
    self.m_root:setNormalSize(self.m_dimension)
    self.m_outlineSize = 0
    self.m_outlineColor = cc.c4b(0,0,0,255)
    self.m_bDirty = true

    self.m_hAlignment = cc.TEXT_ALIGNMENT_LEFT
    self.m_vAlignment = cc.VERTICAL_TEXT_ALIGNMENT_TOP

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
    if (not self.m_orgRichText) then
        return
    end

    if self.m_bDirty then
        self:makeContents()
        self.m_bDirty = false

        self:updateAlignmnet()
        self.m_bDirtyAlignment = false
    elseif self.m_bDirtyAlignment then
        self:updateAlignmnet()
        self.m_bDirtyAlignment = false
    end
end

-------------------------------------
-- function makeContents
-------------------------------------
function UIC_RichLabel:makeContents()

    -- m_root에 붙어있는 node
    if self.m_nodeList then
        for i,v in pairs(self.m_nodeList) do
            v.node:removeFromParent()
        end
    end
    self.m_nodeList = {}
    self.m_lineCount = 0
    self.m_contentWidth = 0
    self.m_widthList = {}

    local l_content = self.m_lContentList

    local pos_x, idx_y = 0, 0
    pos_x, idx_y = self:newLine(pos_x, idx_y)

    for _,t_content in ipairs(l_content) do
        pos_x, idx_y = self:makeIndivisualContent(t_content, pos_x, idx_y)
    end
end

-------------------------------------
-- function updateAlignmnet
-------------------------------------
function UIC_RichLabel:updateAlignmnet()

    local line_height = self.m_fontSize * 1.1
    local content_height = (self.m_lineCount * line_height)

    for i,v in ipairs(self.m_nodeList) do

        local idx_y = v['idx_y']

        -- X축 정렬
        local line_width = self.m_widthList[idx_y]
        local pos_x = v['pos_x']
        if (self.m_hAlignment == cc.TEXT_ALIGNMENT_LEFT) then

        elseif (self.m_hAlignment == cc.TEXT_ALIGNMENT_CENTER) then
            pos_x = pos_x + ((self.m_dimension['width'] - line_width) / 2)

        elseif (self.m_hAlignment == cc.TEXT_ALIGNMENT_RIGHT) then
            pos_x = pos_x + (self.m_dimension['width'] - line_width)

        end

        -- Y축 정렬
        local pos_y = -((idx_y - 1) * line_height)
        if (self.m_vAlignment == cc.VERTICAL_TEXT_ALIGNMENT_TOP) then

        elseif (self.m_vAlignment == cc.VERTICAL_TEXT_ALIGNMENT_CENTER) then
            pos_y = pos_y - ((self.m_dimension['height'] - content_height) / 2)

        elseif (self.m_vAlignment == cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM) then
            pos_y = pos_y - (self.m_dimension['height'] - content_height)

        end

        -- X, Y 설정
        v['node']:setPosition(pos_x, pos_y)
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

    local line_height = self.m_fontSize * 1.1

    for i,text in ipairs(l_line) do
        -- l_line에서 두번째 항목부터는 \n로 개행했을 경우임
        if (1 < i) then
            pos_x, idx_y = self:newLine(pos_x, idx_y)
        end

        local work_text = text
        while (work_text) do
            -- label 생성
            local label = cc.Label:createWithTTF(work_text, self:getFontName(), self.m_fontSize, self.m_outlineSize)
            if (0 < self.m_outlineSize) then
                label:enableOutline(self.m_outlineColor, self.m_outlineSize)
            end
            label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
            label:setDockPoint(cc.p(0, 1))
            label:setAnchorPoint(cc.p(0, 1))
            self.m_root:addChild(label)

            -- 가로 길이 체크
            pos_x, idx_y, work_text, carriage_return = self:makeContent_checkTextWidth(label, work_text, pos_x, idx_y, line_height, is_button)



            -- 현재 위치 지정
            local pos_y = -((idx_y - 1) * line_height)
            label:setPosition(pos_x, pos_y)            

            --[[
            if is_button then
                self:makeTextButton(content, label, pos_x, pos_y, self:getColor(color), idx_y)
            end
            --]]

            -- 생상 지정
            if color then
                label:setColor(self:getColor(color))
            end

            -- 다음 pos_x
            local prev_x = pos_x
            pos_x = pos_x + label:getStringWidth() - self.m_outlineSize -- (outline의 경우 자간에 영향을 줌)

            -- 컨텐츠 넓이
            self.m_contentWidth = math_max(self.m_contentWidth, pos_x)

            do
                local t_data = {}
                t_data['node'] = label
                t_data['pos_x'] = prev_x
                t_data['idx_y'] = idx_y
                table.insert(self.m_nodeList, t_data)

                -- 라인별 넓이 저장
                self.m_widthList[idx_y] = pos_x
            end

            if carriage_return then
                pos_x, idx_y = self:newLine(pos_x, idx_y)
            end
        end
    end

    return pos_x, idx_y
end

-------------------------------------
-- function makeTextButton
-- @brief 작업 중
-------------------------------------
function UIC_RichLabel:makeTextButton(t_content, label, x, y, color, idx_y)
    -- menu객체가 없을 경우 생성
    if (self.m_menu == nil) then
        self.m_menu = cc.Menu:create()
        self.m_menu:setDockPoint(cc.p(0.5, 0.5))
        self.m_menu:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_menu:setNormalSize(self.m_dimension['width'], self.m_dimension['height'])
        self.m_menu:setPosition(0, 0)
        self.m_root:addChild(self.m_menu, 1)
    end

    local str = label:getString()
    local str_width = label:getStringWidth()
    local unserline = nil

    local line_height = self.m_fontSize * 1.1


    do -- underline 생성
        --local x = x + (str_width/2)
        --local y = y - (self.m_fontSize/2) - 1
        local scale_x = str_width/20
        local y = y - (line_height) + (self.m_fontSize / 10)

        local sprite = cc.Sprite:create(UNDER_LINE_PNG)
        self.m_root:addChild(sprite)
        sprite:setPosition(x, y)
        sprite:setDockPoint(cc.p(0, 1))
        sprite:setAnchorPoint(cc.p(0, 1))
        sprite:setScaleX(scale_x)

        if color then
            sprite:setColor(color)
        end
        unserline = sprite

        -- 정력 리스트에 삽입
        --table.insert(self.m_hNodeList[idx_y], {node=sprite, pos_x=x, offset_y= -(self.m_fontSize/2)-1})
    end

    --[[
    do -- 버튼 생성
        local x = x + (str_width/2)

        local button = cc.MenuItemImage:create(UNDER_LINE_PNG, nil, nil, 0)
        button:setDockPoint(cc.p(0, 1))
        button:setAnchorPoint(cc.p(0.5, 1))
        button:setPosition(x, y)
        cclog('x' .. x)
        cclog('y' .. y)
        button:setContentSize(str_width, line_height)
        self.m_menu:addChild(button)

        -- 클릭 핸들러 지정
        local uic_button = UIC_Button(button)
        --uic_button:registerScriptTapHandler(function() self:click_word(content, label, unserline, color, str) end)

        -- 정력 리스트에 삽입
        --table.insert(self.m_hNodeList[idx_y], {node=button ,pos_x=x})
    end
    --]]
end

-------------------------------------
-- function makeContent_checkTextWidth
-------------------------------------
function UIC_RichLabel:makeContent_checkTextWidth(label, work_text, pos_x, idx_y, line_height, is_button)
    local msg_width = label:getStringWidth()

    if ((pos_x + msg_width) < self.m_dimension['width']) then
        return pos_x, idx_y, nil, false
    end

    --[[
    -- 버튼일 경우 즉시 개행
    if is_button then
        work_text = nil
        return pos_x, idx_y, work_text, true
    end
    --]]
    

    --------------------------------------------------------------
    -- 단어 단위 개행
    --------------------------------------------------------------
    --[[
    if true then
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

                -- 개행 초기화
                pos_x, idx_y = self:newLine(pos_x, idx_y)

                -- 첫 문자를 그대로 사용
                temp_str = l_text[1]

                label:setString(temp_str)
                         
                -- 처리되지 않은 남은 문자열 저장       
                work_text = ''
                for i=2, #l_text do
                    work_text = work_text .. l_text[i]
                end
                break

            -- 하나 이상의 문자가 남았고, 개행이 가능할 경우
            elseif (self.m_dimension['width'] >= (pos_x + label:getStringWidth())) then
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
    else
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

    self.m_widthList[idx_y] = 0
    --self.m_hNodeList[idx_y] = {}

    -- 외부에서 사용하기 위해 저장
    self.m_lineCount = idx_y

    return pos_x, idx_y
end

-------------------------------------
-- function getFontName
-------------------------------------
function UIC_RichLabel:getFontName()
    return 'res/font/common_font_01.ttf'
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

-------------------------------------
-- function setAlignment
-------------------------------------
function UIC_RichLabel:setAlignment(h_alignment, v_alignment)
    if (self.m_hAlignment ~= h_alignment) or (self.m_vAlignment ~= v_alignment) then
        self.m_hAlignment = h_alignment
        self.m_vAlignment = v_alignment
        self.m_bDirtyAlignment = true
    end
end

-------------------------------------
-- function enableOutline
-- @param color cc.c4b
-- @param stroke_thickness number
-------------------------------------
function UIC_RichLabel:enableOutline(color, stroke_thickness)
    self.m_outlineColor = color
    self.m_outlineSize = stroke_thickness
    self:setDirty()
end

