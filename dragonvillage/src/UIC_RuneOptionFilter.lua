local PARENT = UIC_Node

UIC_SORT_LIST_TD_BOT_TO_TOP_LEFT = 1
UIC_SORT_LIST_TD_BOT_TO_TOP_RIGHT = 2
UIC_SORT_LIST_TD_TOP_TO_BOT_LEFT = 3
UIC_SORT_LIST_TD_TOP_TO_BOT_RIGHT = 4

local BUTTON_MARGIN = 5
local BUTTON_HEIGHT = 50
local SORT_LIST_ACTION_DURATION = 0.3

-------------------------------------
-- class UIC_RuneOptionFilter
-------------------------------------
UIC_RuneOptionFilter = class(UIC_Node, {
        m_lSortData = '',
        m_mSortData = 'table',

        m_bDirectHide = 'boolean', -- 클릭 직후 바로 숨긴다.
        m_bShow = 'boolean',
        m_direction = '',
        m_mOptionStatus = 'map', -- 선택된 옵션들은 true
        m_bIsCheckOnlyOne = 'boolean', -- 옵션 하나만 선택이 가능한가

        ------------------------------------
        m_menuWidth = '',
        m_containerMenu = '',
        m_containerBG = '',
        m_blockButton = '',
        m_closeButton = '',

        ------------------------------------
        -- 외부에서 지정
        m_extendButton = '',
        m_sortTypeLabel = '',
        m_sortChangeCB = '',


        ------------------------------------
        -- 속성
        m_buttonHeight = 'number',
        m_buttonMargin = 'number',
		m_fontSize = 'number', -- 필요한 경우에만 지정하고 이외에는 m_buttonHeight를 기준으로 계산한다
        m_nItemPerCell = 'number', -- 한 줄에 들어갈 버튼 갯수

        ------------------------------------
        -- extend 버튼 클릭 콜백
        m_extend_btn_cb = 'function',

    })

-------------------------------------
-- function init
-------------------------------------
function UIC_RuneOptionFilter:init()
    self.m_node = cc.Node:create()
    self.m_node:setDockPoint(cc.p(0.5, 0.5))
    self.m_node:setAnchorPoint(cc.p(0.5, 0.5))

    self.m_lSortData = {}
    self.m_mSortData = {}
    self.m_direction = UIC_SORT_LIST_TD_BOT_TO_TOP_LEFT
    
    self.m_mOptionStatus = {}
    self.m_bIsCheckOnlyOne = false

    self.m_buttonHeight = BUTTON_HEIGHT
    self.m_buttonMargin = BUTTON_MARGIN
    self.m_nItemPerCell = 2

    self.m_bDirectHide = true
    self.m_bShow = false

    self.m_extend_btn_cb = nil
end

-------------------------------------
-- function init_container
-------------------------------------
function UIC_RuneOptionFilter:init_container()
    self.m_containerMenu = cc.Menu:create()
    self.m_containerMenu:setVisible(false)
    self.m_containerMenu:setPosition(0, 0)

    local width, heigth = self.m_node:getNormalSize()
    self.m_menuWidth = width * self.m_nItemPerCell
    self.m_containerMenu:setNormalSize(self.m_menuWidth, 0)

    local direction = self.m_direction

    -- 아래에서 위로, 오른쪽에서 왼쪽으로 펼쳐짐
    if (direction == UIC_SORT_LIST_TD_BOT_TO_TOP_LEFT) then
        self.m_containerMenu:setDockPoint(cc.p(1, 1))
        self.m_containerMenu:setAnchorPoint(cc.p(1, 0))
    
    -- 아래에서 위로, 왼쪽에서 오른쪽으로 펼쳐짐
    elseif (direction == UIC_SORT_LIST_TD_BOT_TO_TOP_RIGHT) then
        self.m_containerMenu:setDockPoint(cc.p(0, 1))
        self.m_containerMenu:setAnchorPoint(cc.p(0, 0))

    -- 위에서 아래로, 오른쪽에서 왼쪽으로 펼쳐짐
    elseif (direction == UIC_SORT_LIST_TD_TOP_TO_BOT_LEFT) then
        self.m_containerMenu:setDockPoint(cc.p(1, 0))
        self.m_containerMenu:setAnchorPoint(cc.p(1, 1))

    -- 위에서 아래로, 왼쪽에서 오른쪽으로 펼쳐짐
    elseif (direction == UIC_SORT_LIST_TD_TOP_TO_BOT_RIGHT) then
        self.m_containerMenu:setDockPoint(cc.p(0, 0))
        self.m_containerMenu:setAnchorPoint(cc.p(0, 1))

    end

    self.m_node:addChild(self.m_containerMenu)

    do -- 배경 이미지 생성
        self.m_containerBG = cc.Scale9Sprite:create(cc.rect(0,0,0,0), 'res/ui/frames/base_frame_0101.png')
        self.m_containerMenu:addChild(self.m_containerBG)

        -- 위에서 아래에서 위로 펼쳐짐
        if (direction == UIC_SORT_LIST_TD_BOT_TO_TOP_LEFT) or (direction == UIC_SORT_LIST_TD_BOT_TO_TOP_RIGHT) then
            self.m_containerBG:setDockPoint(cc.p(0.5, 1))
            self.m_containerBG:setAnchorPoint(cc.p(0.5, 0))

        -- 위에서 아래로 펼쳐짐
        elseif (direction == UIC_SORT_LIST_TD_TOP_TO_BOT_LEFT) or (direction == UIC_SORT_LIST_TD_TOP_TO_BOT_RIGHT) then
            self.m_containerBG:setDockPoint(cc.p(0.5, 0))
            self.m_containerBG:setAnchorPoint(cc.p(0.5, 1))

        end
    end

    --do -- 바깥 터치를 감지할 버튼 생성
        ----local button = cc.MenuItemImage:create('res/ui/buttons/base_btn_0201.png', 'res/ui/buttons/base_btn_0201.png', 'res/ui/buttons/base_btn_0201.png', 1)
        --local closeMenu = cc.Menu:create()
        --local button = cc.MenuItemImage:create(EMPTY_PNG, EMPTY_PNG)
--
        ---- TODO : swallowTouch
        --local win_size = cc.Director:getInstance():getWinSize()
        --closeMenu:setSwallowTouch(false)
        --closeMenu:setNormalSize(win_size['width'] * 2, win_size['height'] * 2)
        --button:setRelativeSizeAndType(cc.size(0, 0), 3, true)
        --button:registerScriptTapHandler(function() self:hide() end)
        --self.m_node:addChild(closeMenu)
        --closeMenu:addChild(button)
    --end
    
    do -- 블록 버튼 생성
        local button = cc.MenuItemImage:create(EMPTY_PNG, EMPTY_PNG)
        -- 위에서 아래에서 위로 펼쳐짐
        if (direction == UIC_SORT_LIST_TD_BOT_TO_TOP_LEFT) or (direction == UIC_SORT_LIST_TD_BOT_TO_TOP_RIGHT) then
            button:setDockPoint(cc.p(0.5, 1))
            button:setAnchorPoint(cc.p(0.5, 0))

        -- 위에서 아래로 펼쳐짐
        elseif (direction == UIC_SORT_LIST_TD_TOP_TO_BOT_LEFT) or (direction == UIC_SORT_LIST_TD_TOP_TO_BOT_RIGHT) then
            button:setDockPoint(cc.p(0.5, 0))
            button:setAnchorPoint(cc.p(0.5, 1))

        end
        button:setRelativeSizeAndType(cc.size(0, 0), 3, true)
        self.m_containerMenu:addChild(button)
        self.m_blockButton = button
    end
end



-------------------------------------
-- function setExtendButton
-------------------------------------
function UIC_RuneOptionFilter:setExtendButton(button)
    self.m_extendButton = button
    self.m_extendButton:registerScriptTapHandler(function() self:toggleVisibility() end)
end

-------------------------------------
-- function setSortTypeLabel
-------------------------------------
function UIC_RuneOptionFilter:setSortTypeLabel(label)
    self.m_sortTypeLabel = label
end

-------------------------------------
-- function setSortChangeCB
-------------------------------------
function UIC_RuneOptionFilter:setSortChangeCB(func)
    self.m_sortChangeCB = func
end

-------------------------------------
-- function setSortChangeCB
-------------------------------------
function UIC_RuneOptionFilter:setSortChangeCB(func)
    self.m_sortChangeCB = func
end

-------------------------------------
-- function subFromSortList
-- @brief 버튼 리스트에서 해당 타입의 버튼을 삭제
-------------------------------------
function UIC_RuneOptionFilter:subFromSortList(sort_type)
    local sub_list = {}

    for i, sort_data in ipairs(self.m_lSortData) do
       if (sort_data['sort_type'] == sort_type) then
           table.insert(sub_list, i)
       end
    end

    if (self.m_mSortData[sort_type]) then
        self.m_mSortData[sort_type]['button']:setVisible(false)
        self.m_mSortData[sort_type] = nil
    end

    for i, v in ipairs(sub_list) do
        table.remove(self.m_lSortData, v)
    end
end



-------------------------------------
-- function addSortType
-------------------------------------
function UIC_RuneOptionFilter:addSortType(sort_type, sort_name, t_label_data, rich_label)
    local button = cc.MenuItemImage:create('res/ui/buttons/base_btn_0201.png', 'res/ui/buttons/base_btn_0202.png', 'res/ui/buttons/base_btn_0102.png', 1)
    local width, heigth = self.m_node:getNormalSize()
    button:setNormalSize(width - (self.m_buttonMargin * 2), self.m_buttonHeight)

    local direction = self.m_direction

    -- 아래에서 위로, 오른쪽에서 왼쪽으로 펼쳐짐
    if (direction == UIC_SORT_LIST_TD_BOT_TO_TOP_LEFT) then
        button:setDockPoint(cc.p(1, 0))
        button:setAnchorPoint(cc.p(1, 0))
    
    -- 아래에서 위로, 왼쪽에서 오른쪽으로 펼쳐짐
    elseif (direction == UIC_SORT_LIST_TD_BOT_TO_TOP_RIGHT) then
        button:setDockPoint(cc.p(0, 0))
        button:setAnchorPoint(cc.p(0, 0))

    -- 위에서 아래로, 오른쪽에서 왼쪽으로 펼쳐짐
    elseif (direction == UIC_SORT_LIST_TD_TOP_TO_BOT_LEFT) then
        button:setDockPoint(cc.p(1, 1))
        button:setAnchorPoint(cc.p(1, 1))

    -- 위에서 아래로, 왼쪽에서 오른쪽으로 펼쳐짐
    elseif (direction == UIC_SORT_LIST_TD_TOP_TO_BOT_RIGHT) then
        button:setDockPoint(cc.p(0, 1))
        button:setAnchorPoint(cc.p(0, 1))

    end

    button:setPosition(self:getButtonPosition())

    self.m_containerMenu:addChild(button)

    -- 라벨 생성
    local label
    local font_size = self.m_fontSize or (self.m_buttonHeight / 2 - 5) -- 버튼 사이즈의 반보다 조금 작게
    if (rich_label) then
        label = UIC_RichLabel()
        label:setString(sort_name)
        label:setFontSize(font_size)
        label:setDimension(284, 154)
        label:setPosition(0, 0)
        label:setDefualtColor(COLOR['white'])
        label:setDockPoint(CENTER_POINT)
        label:setAnchorPoint(CENTER_POINT)
        label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        button:addChild(label.m_node)
 
    else
        local font_name = Translate:getFontPath()
        
        -- label 꾸미기
        local t_label_data = t_label_data or {}
        local label_color = t_label_data['color'] or cc.c4b(240, 215, 159, 255)
        local outline_color = t_label_data['outline_color'] or cc.c4b(85, 44, 25,255)
        local stroke_tickness = t_label_data['stroke'] or 2

        -- 버튼 크기보다 조금 크도록 gap 지정 
        local label_gap = 5
        local size = cc.size(width + label_gap, heigth + label_gap)
        label = cc.Label:createWithTTF(sort_name, font_name, font_size, stroke_tickness, size, cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        -- 언어별 사이즈 비율 적용
        local font_retX, font_retY = Translate:getFontScaleRate()
        label:setScale(font_retX, font_retY)

        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(.5, 0.5))
        label:setTextColor(label_color)
        label:enableOutline(outline_color, stroke_tickness)
        button:addChild(label)
    end

    local t_data
    do -- 데이터 저장
        t_data = {}
        t_data['sort_type'] = sort_type
        t_data['sort_name'] = sort_name
        t_data['button'] = button
        t_data['label'] = label
        t_data['idx'] = #self.m_lSortData + 1
        t_data['t_label_data'] = t_label_data -- @ TODO 이부분은 정리가 필요하다 mskim

        table.insert(self.m_lSortData, t_data)
        self.m_mSortData[sort_type] = t_data
    end


    button:registerScriptTapHandler(function() self:click_sortTypeBtn(t_data) end)
    self.m_mOptionStatus[sort_type] = false
end

-------------------------------------
-- function initGLNode
-------------------------------------
function UIC_RuneOptionFilter:initGLNode()
    -- glNode 생성
    local glNode = cc.GLNode:create()
    glNode:registerScriptDrawHandler(function(transform, transformUpdated) self:primitivesDraw(transform, transformUpdated) end)
    self.m_node:addChild(glNode)
end

-------------------------------------
-- function primitivesDraw
-- @brief RichLabel의 텍스트 영역을 draw
-------------------------------------
function UIC_RuneOptionFilter:primitivesDraw(transform, transformUpdated)
    kmGLPushMatrix()
    kmGLLoadMatrix(transform)

    local width, height = self.m_node:getNormalSize()
    local origin = cc.p(0, 0)
    local destination = cc.p(width, height)
    local color = cc.c4f(0.2, 0.2, 0.2, 0.5)
    cc.DrawPrimitives.drawSolidRect(origin, destination, color)

    kmGLPopMatrix()
end


-------------------------------------
-- function getButtonPosition
-------------------------------------
function UIC_RuneOptionFilter:getButtonPosition(idx)
    if (not idx) or (idx == 0) then
        idx = 1        
    end

    local line_y = self:calcLineIdx(idx) -- 현재 세로 순서
    local line_x = self:calcXIdx(idx) -- 현재 가로 순서
    local width, height = self.m_node:getNormalSize()
    local width = width - (self.m_buttonMargin * 2)
    local pos_x = ((line_x - 1) * width) + (((2 * line_x) - 1) * self.m_buttonMargin)
    local pos_y = (self.m_buttonMargin * line_y) + ((line_y - 1) * self.m_buttonHeight)

    local direction = self.m_direction

    -- 아래에서 위로, 오른쪽에서 왼쪽으로 펼쳐짐
    if (direction == UIC_SORT_LIST_TD_BOT_TO_TOP_LEFT) then
        pos_x = -pos_x
        pos_y = pos_y

    -- 아래에서 위로, 왼쪽에서 오른쪽으로 펼쳐짐
    elseif (direction == UIC_SORT_LIST_TD_BOT_TO_TOP_RIGHT) then
        pos_x = pos_x
        pos_y = pos_y

    -- 위에서 아래로, 오른쪽에서 왼쪽으로 펼쳐짐
    elseif (direction == UIC_SORT_LIST_TD_TOP_TO_BOT_LEFT) then
        pos_x = -pos_x
        pos_y = -pos_y

    -- 위에서 아래로, 왼쪽에서 오른쪽으로 펼쳐짐
    elseif (direction == UIC_SORT_LIST_TD_TOP_TO_BOT_RIGHT) then
        pos_x = pos_x
        pos_y = -pos_y
    end

    return pos_x, pos_y
end

-------------------------------------
-- function calcLineIdx
-------------------------------------
function UIC_RuneOptionFilter:calcLineIdx(idx)
    local lineIdx = math_floor(idx / self.m_nItemPerCell)
    local rest_of_division = (idx % self.m_nItemPerCell)
    if (rest_of_division > 0) then
        lineIdx = lineIdx + 1
    end
    return lineIdx
end

-------------------------------------
-- function calcXIdx
-------------------------------------
function UIC_RuneOptionFilter:calcXIdx(idx)
    if (idx == 0) then
        return 0
    elseif (idx % self.m_nItemPerCell) == 0 then
        return self.m_nItemPerCell
    else
        return idx % self.m_nItemPerCell
    end
end

-------------------------------------
-- function getMenuMinSize
-------------------------------------
function UIC_RuneOptionFilter:getMenuMinSize()
    local line_cnt = 1
    local size = ((line_cnt + 1) * self.m_buttonMargin) + (line_cnt * self.m_buttonHeight)
    return size
end

-------------------------------------
-- function getMenuMaxSize
-------------------------------------
function UIC_RuneOptionFilter:getMenuMaxSize()
    local total_data_cnt = #self.m_lSortData
    local line_cnt = self:calcLineIdx(total_data_cnt)
    local size = ((line_cnt + 1) * self.m_buttonMargin) + (line_cnt * self.m_buttonHeight)
    return size
end

-------------------------------------
-- function show
-------------------------------------
function UIC_RuneOptionFilter:show()
    if (self.m_bShow) then
        return
    end

    self.m_bShow = true

    self.m_containerMenu:stopAllActions()
    self.m_containerMenu:setVisible(true)


    do
        local function tween_cb_width(value, node)
            local width, height = self.m_containerBG:getNormalSize()
            self.m_containerBG:setNormalSize(value, height)
        end
        local function tween_cb_height(value, node)
            local width, height = self.m_containerBG:getNormalSize()
            self.m_containerBG:setNormalSize(width, value)
        end

        local width, height = self.m_containerBG:getNormalSize()
        local tween_action_height = cc.ActionTweenForLua:create(SORT_LIST_ACTION_DURATION, height, self:getMenuMaxSize(), tween_cb_height)
        local tween_action_width = cc.ActionTweenForLua:create(SORT_LIST_ACTION_DURATION, width, self.m_menuWidth, tween_cb_width)
        local tween_action = cc.Spawn:create(tween_action_height, tween_action_width)
        local action = cc.EaseElasticOut:create(tween_action, 1.5)
        self.m_containerBG:runAction(action)

        -- 하단 UI 클릭을 막는 버튼도 크기 조정
        self.m_blockButton:setNormalSize(self.m_menuWidth, self:getMenuMaxSize())
    end

    for i,v in ipairs(self.m_lSortData) do
        local x, y = self:getButtonPosition(i) 
        v['button']:stopAllActions()
        local move_to = cc.MoveTo:create(SORT_LIST_ACTION_DURATION, cc.p(x, y))
        local action = cc.EaseElasticOut:create(move_to, 1.5)
        cca.runAction(v['button'], action)
    end

    -- self:reserveHide()
end

-------------------------------------
-- function hide
-------------------------------------
function UIC_RuneOptionFilter:hide()
    if (not self.m_bShow) then
        return
    end

    self:cancelReserveHide()

    self.m_bShow = false

    self.m_containerMenu:stopAllActions()
    --self.m_containerMenu:setVisible(true)

    do

        local function tween_cb_width(value, node)
            local width, height = self.m_containerBG:getNormalSize()
            self.m_containerBG:setNormalSize(value, height)
        end
        local function tween_cb_height(value, node)
            local width, height = self.m_containerBG:getNormalSize()
            self.m_containerBG:setNormalSize(width, value)
        end

        local width, height = self.m_containerBG:getNormalSize()
        local node_width, node_heigth = self.m_node:getNormalSize()
        local min_width = node_width - (self.m_buttonMargin * 2)
        local tween_action_height = cc.ActionTweenForLua:create(SORT_LIST_ACTION_DURATION, height, self:getMenuMinSize(), tween_cb_height)
        local tween_action_width = cc.ActionTweenForLua:create(SORT_LIST_ACTION_DURATION, width, min_width, tween_cb_width)
        local tween_action = cc.Spawn:create(tween_action_height, tween_action_width)
        local ease = cc.EaseElasticIn:create(tween_action, 1.5)
        local action = cc.Sequence:create(ease, cc.CallFunc:create(function() self.m_containerMenu:setVisible(false) end))
        self.m_containerBG:runAction(action)
    end

    for i,v in ipairs(self.m_lSortData) do
        local x, y = self:getButtonPosition(0)
        v['button']:stopAllActions()
        local move_to = cc.MoveTo:create(SORT_LIST_ACTION_DURATION, cc.p(x, y))
        local action = cc.EaseElasticIn:create(move_to, 1.5)
        cca.runAction(v['button'], action)
    end
end

-------------------------------------
-- function toggleVisibility
-------------------------------------
function UIC_RuneOptionFilter:toggleVisibility()
    if (self.m_extend_btn_cb) then
        self.m_extend_btn_cb()
    end

    if self.m_bShow then
        self:hide()
    else
        self:show()
    end
end

-------------------------------------
-- function setExtendBtnCb
-------------------------------------
function UIC_RuneOptionFilter:setExtendBtnCb(click_cb)
    self.m_extend_btn_cb = click_cb
end

-------------------------------------
-- function click_sortTypeBtn
-------------------------------------
function UIC_RuneOptionFilter:click_sortTypeBtn(t_data)   
    self:setSelectSortType(t_data['sort_type'])

    --if self.m_bDirectHide then
        --self:hide()
    --else
        --self:reserveHide()
        --self:show()
    --end
end

-------------------------------------
-- function setSelectSortType
-- @param no_use_cb 콜백 동작 없이 버튼 상태 변경 하고 싶을 때 사용.. uic_list가 각종 탭, 테이블과 엮여 있을 경우 사용하기 위함
-------------------------------------
function UIC_RuneOptionFilter:setSelectSortType(select_option, no_use_cb)
    -- '전체' 옵션을 선택한 경우
    if (select_option == 'all') then
        if (self.m_mOptionStatus['all'] == true) then
            return
        end
        
        -- 다른 개별 옵션들을 전부 끈다. 
        for option, b_is_active in pairs(self.m_mOptionStatus) do
            if (option ~= 'all') and (b_is_active == true) then
                self.m_mOptionStatus[option] = false
                local t_data = self.m_mSortData[option]
                local label_color = cc.c4b(240, 215, 159, 255)
                t_data['label']:setTextColor(label_color)
            end
        end
        
        self.m_mOptionStatus['all'] = true

        local t_data = self.m_mSortData['all']
        local label_color = cc.c4b(0, 0, 0, 255)
        t_data['label']:setTextColor(label_color)

        self.m_sortTypeLabel:setTextColor(cc.c4b(240, 215, 159, 255))
        
    -- 개별 옵션을 선택한 경우
    else
        -- '전체' 옵션이 켜져있던 경우 끈다.
        if (self.m_mOptionStatus['all'] == true) then
            self.m_mOptionStatus['all'] = false
            local t_data = self.m_mSortData['all']
            local label_color = cc.c4b(240, 215, 159, 255)
            t_data['label']:setTextColor(label_color)
        end

        self.m_mOptionStatus[select_option] = not self.m_mOptionStatus[select_option]
        
        -- 단일 옵션 체크인 경우 다른 옵션 꺼준다
        if ((self.m_mOptionStatus[select_option] == true) and (self.m_bIsCheckOnlyOne == true)) then
            for option, b_is_active in pairs(self.m_mOptionStatus) do
                if (option ~= select_option) and (b_is_active == true) then
                    self.m_mOptionStatus[option] = false
                    local t_data = self.m_mSortData[option]
                    local label_color = cc.c4b(240, 215, 159, 255)
                    t_data['label']:setTextColor(label_color)
                end
            end
        end

        local t_data = self.m_mSortData[select_option]
        local label_color = (self.m_mOptionStatus[select_option] == true) and cc.c4b(0, 0, 0, 255) or cc.c4b(240, 215, 159, 255)
        t_data['label']:setTextColor(label_color)
        
        
        -- 모든 옵션이 꺼진 경우 '전체' 옵션을 켜준다.
        local b_is_all_inactive = true
        for option, b_is_active in pairs(self.m_mOptionStatus) do
            if (b_is_active == true) then
                b_is_all_inactive = false
                break
            end
        end

        if (b_is_all_inactive == true) then
            self.m_mOptionStatus['all'] = true
            local t_data = self.m_mSortData['all']
            local label_color = cc.c4b(0, 0, 0, 255)
            t_data['label']:setTextColor(label_color)
            self.m_sortTypeLabel:setTextColor(cc.c4b(240, 215, 159, 255))

        else
            self.m_sortTypeLabel:setTextColor(cc.c4b(255, 255, 0, 255))
        end
    end

    -- 콜백
    if self.m_sortChangeCB and (not no_use_cb) then
        self.m_sortChangeCB(sort_type)
    end
end

-------------------------------------
-- function reserveHide
-------------------------------------
function UIC_RuneOptionFilter:reserveHide()
    self.m_node:stopAllActions()
    local function func()
        self:hide()
    end
    self.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(4), cc.CallFunc:create(func)))
end

-------------------------------------
-- function cancelReserveHide
-------------------------------------
function UIC_RuneOptionFilter:cancelReserveHide()
    self.m_node:stopAllActions()
end

-------------------------------------
-- function getOptionList
-- @return nil 반환하면 전체 옵션, list 반환하면 해당 옵션만
-------------------------------------
function UIC_RuneOptionFilter:getOptionList()
    local l_option_list = {}
    
    if (self.m_mOptionStatus['all'] == false) then
        for option, b_is_active in pairs(self.m_mOptionStatus) do
            if (b_is_active == true) then
                table.insert(l_option_list, option)
            end
        end
    else
        l_option_list = nil
    end

    return l_option_list
end



function MakeUIC_RuneOptionFilter(button, label, option_type)

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_RuneOptionFilter()

    uic.m_direction = UIC_SORT_LIST_TD_TOP_TO_BOT_RIGHT
    uic.m_nItemPerCell = 2
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    uic.m_bIsCheckOnlyOne = (option_type == 'mopt') and true or false

    parent:addChild(uic.m_node)

    uic:addSortType('all', Str('전체'))
	uic:addSortType('aspd_add', Str('공격 속도') .. ' %')
    uic:addSortType('atk_multi', Str('공격력') .. ' %')
    uic:addSortType('atk_add', Str('공격력') .. ' +')
    uic:addSortType('def_multi', Str('방어력') .. ' %')
    uic:addSortType('def_add', Str('방어력') .. ' +')
    uic:addSortType('hp_multi', Str('생명력') .. ' %')
    uic:addSortType('hp_add', Str('생명력') .. ' +')
    uic:addSortType('cri_chance_add', Str('치명 확률') .. ' %')
    uic:addSortType('cri_dmg_add', Str('치명 피해') .. ' %')
    uic:addSortType('hit_rate_add', Str('적중') .. ' %')
    uic:addSortType('avoid_add', Str('회피') .. ' %')
    uic:addSortType('accuracy_add', Str('효과 적중') .. ' %')
    uic:addSortType('resistance_add', Str('효과 저항') .. ' %')

    return uic
end