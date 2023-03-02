local PARENT = UIC_Node

-------------------------------------
-- class UIC_RichLabel
-------------------------------------
UIC_RichLabel = class(UIC_Node, {
        m_root = 'cc.Node',
        m_defaultColor = 'cc.c3b',
        m_originString = 'string',
        m_orgRichText = 'string',
        m_lContentList = 'list',

        m_fontSize = 'number',
        m_dimension = 'cc.Size',

        -- outline
        m_outlineSize = 'number',
        m_outlineColor = 'cc.c4b',

        -- shadow
        m_bShadowEnabled = 'boolean',
        m_shadowColor = 'cc.c4b',
        m_shadowOffset = 'cc.size',
        m_shadowBlurRadius = 'number',

        m_bDirty = 'boolean',

        m_nodeList = 'list',
        m_lineCount = 'number',
        m_contentWidth = 'number',
        m_widthList = 'list',

        m_lineHeight = 'number',

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

        m_mContentNodeData = 'map',

        m_wordSpacing = 'number'
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_RichLabel:init()
    self.m_root = cc.Menu:create()
    self.m_root:setPosition(0, 0)
    self.m_node = self.m_root

    self.m_fontSize = 20
    self.m_dimension = cc.size(300, 720/2)
    self.m_root:setNormalSize(self.m_dimension)
    self.m_outlineSize = 0
    self.m_outlineColor = cc.c4b(0,0,0,255)
    self.m_bDirty = true

    self.m_lineHeight = 1.1
    self.m_wordSpacing = 0.4

    self.m_hAlignment = cc.TEXT_ALIGNMENT_LEFT
    self.m_vAlignment = cc.VERTICAL_TEXT_ALIGNMENT_TOP

    self.m_mContentNodeData = {}

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.m_root:registerScriptHandler(function(event)
        local function update(dt)
            self:update(dt)
        end

        if (event == 'enter') then
            self.m_root:scheduleUpdateWithPriorityLua(update, 0)
        end
    end)    
end



-------------------------------------
-- function setString
-------------------------------------
function UIC_RichLabel:setString(text)
    
    -- 페르시아어(fa)의 경우 숫자를 페르시아 언어로 출력
    local game_lang = Translate:getGameLang()
    if (game_lang == 'fa') then
        text = Translate:persianNumberConvert(text)
    end

    self:setRichText(text)
end

-------------------------------------
-- function setRichText
-------------------------------------
function UIC_RichLabel:setRichText(text)
    if (self.m_orgRichText == text) then
        return
    end
    
    self.m_mContentNodeData = {}

    self.m_orgRichText = text
    self.m_lContentList = self:makeContentListByRichText(text)

    if (self.m_originString == nil) then
        self.m_originString = text
    end

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

    -- 페르시아어이고, 페르시아어가 포함된 텍스트일 경우
    if (Translate:getGameLang() == 'fa') then
        if string.match(self.m_orgRichText, '[آ-ی]+') then
            self:updateAlignmnet_forRtl()
            return
        end
    end

    local line_height = self.m_fontSize * self.m_lineHeight
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
-- function updateAlignmnet_forRtl
-------------------------------------
function UIC_RichLabel:updateAlignmnet_forRtl()
    local line_height = self.m_fontSize * self.m_lineHeight
    local content_height = (self.m_lineCount * line_height)

    for i,v in ipairs(self.m_nodeList) do

        local idx_y = v['idx_y']

        -- X축 정렬
        local line_width = self.m_widthList[idx_y]
        local pos_x = v['pos_x']
        if (self.m_hAlignment == cc.TEXT_ALIGNMENT_LEFT) then
            local start_x = 0
            pos_x = start_x + line_width - (pos_x + v['node_width'])

        elseif (self.m_hAlignment == cc.TEXT_ALIGNMENT_CENTER) then
            local start_x = ((self.m_dimension['width'] - line_width) / 2)
            pos_x = start_x + line_width - (pos_x + v['node_width'])

        elseif (self.m_hAlignment == cc.TEXT_ALIGNMENT_RIGHT) then
            local start_x = self.m_dimension['width'] - line_width
            pos_x = start_x + line_width - (pos_x + v['node_width'])

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
    local is_save = t_content['is_save']

    --언어에 따라 스케일
    local rateX, rateY = Translate:getFontScaleRate()

    -- 임시

    local line_height = self.m_fontSize * self.m_lineHeight

    for i,text in ipairs(l_line) do
        -- l_line에서 두번째 항목부터는 \n로 개행했을 경우임
        if (1 < i) then
            pos_x, idx_y = self:newLine(pos_x, idx_y)
        end

        local work_text = text
        while (work_text) do
            -- label 생성
            -- TTF를 사용하지 못하는 환경에서 SystemFont Label을 사용 (자세한 내용은 UILoader:createWithTTF를 참조할 것)
            -- local label = cc.Label:createWithTTF(work_text, self:getFontName(), self.m_fontSize, self.m_outlineSize)
            local label = UILoader:createWithTTF(work_text, self:getFontName(), self.m_fontSize, self.m_outlineSize)
            label:setScaleX( rateX )
            label:setScaleY( rateY )

            -- 아웃라인 지정
            if (0 < self.m_outlineSize) then
                label:enableOutline(self.m_outlineColor, self.m_outlineSize)
            end
            -- 쉐도우 지정
            if (self.m_bShadowEnabled) then
                label:enableShadow(self.m_shadowColor, self.m_shadowOffset, self.m_shadowBlurRadius)
            end
             -- 색상 지정
            if color then
                label:setColor(self:getColor(color))
            end
            label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
            label:setDockPoint(cc.p(0, 1))
            label:setAnchorPoint(cc.p(0, 1))
            label:setAdditionalKerning(self.m_wordSpacing)


            local pre_text = work_text

            -- 가로 길이 체크
            pos_x, idx_y, work_text, carriage_return = self:makeContent_checkTextWidth(label, work_text, pos_x, idx_y, line_height, is_button)

            -- 현재 위치 계산
            local pos_y = -((idx_y - 1) * line_height)

            local content_uic = label
            local content_node = label
            if is_button then
                content_uic, content_node = self:makeTextButton(t_content, label, self:getColor(color))
            end
            
            -- 각 컨텐츠 노드 저장 (특정 노드 찾아서 따로 처리하고 싶을때)
            -- 같은 키로 노드 여러개 저장하기 위해 맵이 아닌 리스트로
            -- ex) {@&rune_sopt;save_key}
            if is_save then
                local save_key = t_content['type']
                if save_key then
                    table.insert(self.m_mContentNodeData, {save_key = save_key, node = content_node})
                end
            end

            self.m_root:addChild(content_node)
            content_uic:setPosition(pos_x, pos_y)
            
            local node_width = 0

            -- 다음 pos_x
            local prev_x = pos_x
            if (pre_text ~= work_text) then
                node_width = (label:getStringWidth() * rateX) - self.m_outlineSize
                pos_x = pos_x + node_width
            end

            -- 컨텐츠 넓이
            self.m_contentWidth = math_max(self.m_contentWidth, pos_x)

            do
                local t_data = {}
                t_data['node'] = content_uic
                t_data['node_width'] = node_width
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
-- @brief 버튼 생성
-------------------------------------
function UIC_RichLabel:makeTextButton(t_content, label, color)
    local str_width = label:getStringWidth()
    -- 언더라인은 바로 텍스트 아래에 생겨야 한다.
    local line_height = self.m_fontSize * 1.1

    local button = cc.MenuItemImage:create(EMPTY_PNG, nil, nil, 0)
    button:setDockPoint(cc.p(0, 1))
    button:setAnchorPoint(cc.p(0, 1))
    button:setContentSize(str_width, line_height)

    -- label
    button:addChild(label)

    -- 언더바 생성
    local unserline = cc.Sprite:create(UNDER_LINE_PNG)
    button:addChild(unserline)
    unserline:setDockPoint(cc.p(0, 0))
    unserline:setAnchorPoint(cc.p(0, 0))
    local scale_x = str_width/20
    unserline:setScaleX(scale_x)
    if color then
        unserline:setColor(color)
    end

    -- 클릭 핸들러 지정
    local uic_button = UIC_Button(button)
    uic_button:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    uic_button:registerScriptTapHandler(function() self:click_word(t_content, label, unserline, color) end)

    return uic_button, button
end

-------------------------------------
-- function makeContent_checkTextWidth
-------------------------------------
function UIC_RichLabel:makeContent_checkTextWidth(label, work_text, pos_x, idx_y, line_height, is_button)
    local msg_width = label:getStringWidth()
    --언어에 따라 스케일
    local rateX, rateY = Translate:getFontScaleRate()
    msg_width = msg_width * rateX
    if ((pos_x + msg_width) < self.m_dimension['width']) then
        return pos_x, idx_y, nil, false
    end

    -- 버튼일 경우 가로 길이를 넘어갈 경우 즉시 개행
    if is_button then
        pos_x, idx_y = self:newLine(pos_x, idx_y)
        work_text = nil
        return pos_x, idx_y, work_text, false
    end
    --]]
    

    --------------------------------------------------------------
    -- 단어 단위 개행
    --------------------------------------------------------------
    local b_word_line_change = false
    local game_lang = g_localData:getLang()

    -- 유저가 선택한 언어가 영어일때만 단어 단위 개행
    if (game_lang and game_lang == 'en') then
        b_word_line_change = true
    end

    if b_word_line_change then
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
    end
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
    return Translate:getFontPath()
end

-------------------------------------
-- function setDefualtColor
-------------------------------------
function UIC_RichLabel:setDefualtColor(color)
    self.m_defaultColor = color
end

-------------------------------------
-- function getColor
-------------------------------------
function UIC_RichLabel:getColor(color)
    if (string.upper(color) == 'DEFAULT') and self.m_defaultColor then
        return self.m_defaultColor
    end

    return COLOR[color] or cc.c3b(255,255,255)
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
    --self.m_root:setContentSize(self.m_dimension)
    --self.m_root:setUpdateTransform()
    --self.m_root:setUpdateChildrenTransform()
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
-- function setBold
-------------------------------------
function UIC_RichLabel:setBold(b)
    if (b) then
        self:enableOutline(cc.c4b(255, 255, 255, 100), 2)
    else
        self:enableOutline(nil, 0)
    end
end

-------------------------------------
-- function setItalic
-------------------------------------
function UIC_RichLabel:setItalic(b)
    if (b) then
        self.m_node:setSkewY(20)
    else
        self.m_node:setSkewY(0)
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

-------------------------------------
-- function enableShadow
-------------------------------------
function UIC_RichLabel:enableShadow(color, shadow_offset, blurRadius)
    self.m_bShadowEnabled = true
    self.m_shadowColor = color
    self.m_shadowOffset = shadow_offset
    self.m_shadowBlurRadius = (blurRadius or 0)
    self:setDirty()
end

-------------------------------------
-- function getOriginString
-------------------------------------
function UIC_RichLabel:getOriginString()
    return self.m_originString
end

-------------------------------------
-- function getString
-------------------------------------
function UIC_RichLabel:getString()
    return self.m_orgRichText
end

-------------------------------------
-- function getStringWidth
-------------------------------------
function UIC_RichLabel:getStringWidth()
    if self.m_bDirty then
        self:update(0)
    end

    return self.m_contentWidth
end

-------------------------------------
-- function getStringHeight
-------------------------------------
function UIC_RichLabel:getStringHeight()
    if self.m_bDirty then
        self:update(0)
    end

    local line_height = self.m_fontSize * self.m_lineHeight
    local content_height = (self.m_lineCount * line_height)
    return content_height
end

-------------------------------------
-- function getTotalHeight
-- @brief ccLabel과 호환성을 위해 추가
-------------------------------------
function UIC_RichLabel:getTotalHeight()
    return self:getStringHeight()
end

-------------------------------------
-- function findContentNodeWithkey
-- @brief 
-------------------------------------
function UIC_RichLabel:findContentNodeWithkey(find_key)
    if self.m_bDirty then
        self:update(0)
    end

    local node_list = {}
    for _, v in ipairs(self.m_mContentNodeData) do
        if (v['save_key'] == find_key) then 
            table.insert(node_list, v['node'])
        end
    end

    return node_list
end


-------------------------------------
-- function click_word
-- @brief 버튼 클릭 핸들러
-------------------------------------
function UIC_RichLabel:click_word(t_content, label, underline, color)
    --[[
    if self.m_clickHandler then
        self.m_clickHandler(content)
    end
    --]]

    -- 하이퍼링크!!!
    -- type 이 url일 때는 id 가 웹주소로 들어온다
    if t_content then
        if t_content['type'] and t_content['type'] == 'url' then
        
            local webUrl = t_content['id']

            if webUrl and webUrl ~= '' then
                SDKManager:goToWeb(webUrl)
            end

        end
    end

    self:makeClickReaction(label, color)
    self:makeClickReaction(underline, color)
end

-- 클릭했을 시 색상
local CLICK_COLOR = cc.c3b(163, 73, 164)

-------------------------------------
-- function makeClickReaction
-------------------------------------
function UIC_RichLabel:makeClickReaction(node, org_color)
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
            cc.TintTo:create(0.15, org_color['r'], org_color['g'], org_color['b'])
        )
    node:runAction(sequence)
end

-------------------------------------
-- function setStringArg
-- @brief 처음 생성될 때의 라벨 텍스트의 값에 Str 함수를 취해서 처리
-------------------------------------
function UIC_RichLabel:setStringArg(...)
    self:setString(Str(self.m_originString, ...))
end

-------------------------------------
-- function UIC_RichLabel_Sample
-------------------------------------
function UIC_RichLabel_Sample(parent_node)

    -- 1. getFontName() 함수에서 폰트명을 지정해 주셔야 합니다.
    -- 2. local UNDER_LINE_PNG = 'res/common/underline.png' 을 지정해 주셔야 합니다. (버튼에서 아래쪽 라인을 그려줄 png)
    -- 3. local EMPTY_PNG = 'res/common/empty.png' (눈에 보이지 않는 버튼을 생성하기 위한 png)

    local text = '{@#TAN;user;10001}[페이커]{@WHITE}님이dfd {@#GOLD;champ;10002}[5성발키리]{@#WHITE}를 {@#DEEPSKYBLUE}챔피언진화로 획득하셨습니다.'
    --local text = '{@TAN;user;10001}[페이커]님이 [5성 발키리]를 챔피언진화로 획득하셨습니다.'
    --local text = '[페이커]님이 [5성 발키리]를 챔피언진화로 획득하셨습니다.'
    --text = '{@TAN}실피즈{@WHITE}님이 {@GOLD}[5성 발키리]{@WHITE}를 {@DEEPSKYBLUE}챔피언 진화{@ORANGE}로 획득하셨습니다.'
    --text = '{@E}wwwwwwwwwww'
    text = '{@TAN;user;10001}[페이커]{@WHITE}님이dfd {@#GOLD;champ;10002}[5성발키리]{@WHITE}를 {@#DEEPSKYBLUE}챔피언진화로 획득하셨습니다.{@#w}챔피언진화로 획득하셨습니다.'


    local rich_label = UIC_RichLabel()
    
    rich_label:initGLNode()

    -- label의 속성들
    rich_label:setString(text)
    rich_label:setFontSize(30)
    rich_label:setDimension(280 + 100, 300)
    rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    rich_label:enableOutline(cc.c4b(255, 0, 0, 127), 3)
    rich_label:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)

    -- Node의 기본 속성들 (UIC_Node 참고)
    rich_label:setDockPoint(cc.p(0.5, 0.5))
    rich_label:setAnchorPoint(cc.p(0.5, 0.5))
    rich_label:setScale(1)
    rich_label:setRotation(45)

    -- m_node맴버 변수를 addChild
    parent_node:addChild(rich_label.m_node)
end

