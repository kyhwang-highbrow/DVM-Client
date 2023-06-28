local PARENT = UIC_Node

UIC_SORT_LIST_BOT_TO_TOP = 1
UIC_SORT_LIST_TOP_TO_BOT = 2

local BUTTON_MARGIN = 5
local BUTTON_HEIGHT = 50
local SORT_LIST_ACTION_DURATION = 0.3

-------------------------------------
-- class UIC_SortList
-------------------------------------
UIC_SortList = class(UIC_Node, {
        m_lSortData = '',
        m_mSortData = 'table',

        m_bDirectHide = 'boolean', -- 클릭 직후 바로 숨긴다.
        m_bShow = 'boolean',
        m_direction = '',
        m_selectSortType = '',

        ------------------------------------
        m_menuWidth = '',
        m_containerMenu = '',
        m_containerBG = '',
        m_blockButton = '',

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

        ------------------------------------
        -- extend 버튼 클릭 콜백
        m_extend_btn_cb = 'function',

    })

-------------------------------------
-- function init
-------------------------------------
function UIC_SortList:init()
    self.m_node = cc.Node:create()
    self.m_node:setDockPoint(cc.p(0.5, 0.5))
    self.m_node:setAnchorPoint(cc.p(0.5, 0.5))

    self.m_lSortData = {}
    self.m_mSortData = {}
    self.m_direction = UIC_SORT_LIST_BOT_TO_TOP
    
    self.m_buttonHeight = BUTTON_HEIGHT
    self.m_buttonMargin = BUTTON_MARGIN

    self.m_bDirectHide = true
    self.m_bShow = false

    self.m_extend_btn_cb = nil
end

-------------------------------------
-- function init_container
-------------------------------------
function UIC_SortList:init_container()
    self.m_containerMenu = cc.Menu:create()
    self.m_containerMenu:setVisible(false)
    self.m_containerMenu:setPosition(0, 0)

    local width, heigth = self.m_node:getNormalSize()
    self.m_containerMenu:setNormalSize(width, 0)
    self.m_menuWidth = width

    local direction = self.m_direction

    -- 위에서 아래에서 위로 펼쳐짐
    if (direction == UIC_SORT_LIST_BOT_TO_TOP) then
        self.m_containerMenu:setDockPoint(cc.p(0.5, 1))
        self.m_containerMenu:setAnchorPoint(cc.p(0.5, 0))

    -- 위에서 아래로 펼쳐짐
    elseif (direction == UIC_SORT_LIST_TOP_TO_BOT) then
        self.m_containerMenu:setDockPoint(cc.p(0.5, 0))
        self.m_containerMenu:setAnchorPoint(cc.p(0.5, 1))

    end

    self.m_node:addChild(self.m_containerMenu)

    do -- 배경 이미지 생성
        self.m_containerBG = cc.Scale9Sprite:create(cc.rect(0,0,0,0), 'res/ui/frames/base_frame_0101.png')
        self.m_containerMenu:addChild(self.m_containerBG)

        -- 위에서 아래에서 위로 펼쳐짐
        if (direction == UIC_SORT_LIST_BOT_TO_TOP) then
            self.m_containerBG:setDockPoint(cc.p(0.5, 1))
            self.m_containerBG:setAnchorPoint(cc.p(0.5, 0))

        -- 위에서 아래로 펼쳐짐
        elseif (direction == UIC_SORT_LIST_TOP_TO_BOT) then
            self.m_containerBG:setDockPoint(cc.p(0.5, 0))
            self.m_containerBG:setAnchorPoint(cc.p(0.5, 1))

        end
    end

    do -- 블록 버튼 생성
        local button = cc.MenuItemImage:create(EMPTY_PNG, EMPTY_PNG)
        -- 위에서 아래에서 위로 펼쳐짐
        if (direction == UIC_SORT_LIST_BOT_TO_TOP) then
            button:setDockPoint(cc.p(0.5, 1))
            button:setAnchorPoint(cc.p(0.5, 0))

        -- 위에서 아래로 펼쳐짐
        elseif (direction == UIC_SORT_LIST_TOP_TO_BOT) then
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
function UIC_SortList:setExtendButton(button)
    self.m_extendButton = button
    self.m_extendButton:registerScriptTapHandler(function() self:toggleVisibility() end)
end

-------------------------------------
-- function setSortTypeLabel
-------------------------------------
function UIC_SortList:setSortTypeLabel(label)
    self.m_sortTypeLabel = label
end

-------------------------------------
-- function setSortChangeCB
-------------------------------------
function UIC_SortList:setSortChangeCB(func)
    self.m_sortChangeCB = func
end

-------------------------------------
-- function setSortChangeCB
-------------------------------------
function UIC_SortList:setSortChangeCB(func)
    self.m_sortChangeCB = func
end

-------------------------------------
-- function subFromSortList
-- @brief 버튼 리스트에서 해당 타입의 버튼을 삭제
-------------------------------------
function UIC_SortList:subFromSortList(sort_type)
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
function UIC_SortList:addSortType(sort_type, sort_name, t_label_data, rich_label)

    local button = cc.MenuItemImage:create('res/ui/buttons/base_btn_0201.png', 'res/ui/buttons/base_btn_0202.png', 'res/ui/buttons/base_btn_0102.png', 1)
    local width, heigth = self.m_node:getNormalSize()
    button:setNormalSize(width - (self.m_buttonMargin * 2), self.m_buttonHeight)

    local direction = self.m_direction

    -- 위에서 아래에서 위로 펼쳐짐
    if (direction == UIC_SORT_LIST_BOT_TO_TOP) then
        button:setDockPoint(cc.p(0.5, 0))
        button:setAnchorPoint(cc.p(0.5, 0))

    -- 위에서 아래로 펼쳐짐
    elseif (direction == UIC_SORT_LIST_TOP_TO_BOT) then
        button:setDockPoint(cc.p(0.5, 1))
        button:setAnchorPoint(cc.p(0.5, 1))

    end

    button:setPosition(self:getButtonPosition())

    self.m_containerMenu:addChild(button)

    -- 라벨 생성
    local font_size = self.m_fontSize or (self.m_buttonHeight / 2 - 5) -- 버튼 사이즈의 반보다 조금 작게
    if (rich_label) then
        local rich_label = UIC_RichLabel()
        rich_label:setString(sort_name)
        rich_label:setFontSize(font_size)
        rich_label:setDimension(284, 154)
        rich_label:setPosition(0, 0)
        rich_label:setDefualtColor(COLOR['white'])
        rich_label:setDockPoint(CENTER_POINT)
        rich_label:setAnchorPoint(CENTER_POINT)
        rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        button:addChild(rich_label.m_node)
 
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
        local node = cc.Label:createWithTTF(sort_name, font_name, font_size, stroke_tickness, size, cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        -- 언어별 사이즈 비율 적용
        local font_retX, font_retY = Translate:getFontScaleRate()
        node:setScale(font_retX, font_retY)

        node:setDockPoint(cc.p(0.5, 0.5))
        node:setAnchorPoint(cc.p(.5, 0.5))
        node:setTextColor(label_color)
        node:enableOutline(outline_color, stroke_tickness)
        button:addChild(node)
    end

    local t_data
    do -- 데이터 저장
        t_data = {}
        t_data['sort_type'] = sort_type
        t_data['sort_name'] = sort_name
        t_data['button'] = button
        t_data['idx'] = #self.m_lSortData + 1
        t_data['t_label_data'] = t_label_data -- @ TODO 이부분은 정리가 필요하다 mskim

        table.insert(self.m_lSortData, t_data)
        self.m_mSortData[sort_type] = t_data
    end


    button:registerScriptTapHandler(function() self:click_sortTypeBtn(t_data) end)
end

-------------------------------------
-- function initGLNode
-------------------------------------
function UIC_SortList:initGLNode()
    -- glNode 생성
    local glNode = cc.GLNode:create()
    glNode:registerScriptDrawHandler(function(transform, transformUpdated) self:primitivesDraw(transform, transformUpdated) end)
    self.m_node:addChild(glNode)
end

-------------------------------------
-- function primitivesDraw
-- @brief RichLabel의 텍스트 영역을 draw
-------------------------------------
function UIC_SortList:primitivesDraw(transform, transformUpdated)
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
function UIC_SortList:getButtonPosition(idx)
    if (not idx) or (idx == 0) then
        idx = 1        
    end

    local pos_y = (self.m_buttonMargin * idx) + ((idx-1) * self.m_buttonHeight)

    local direction = self.m_direction

    -- 위에서 아래에서 위로 펼쳐짐
    if (direction == UIC_SORT_LIST_BOT_TO_TOP) then
        pos_y = pos_y

    -- 위에서 아래로 펼쳐짐
    elseif (direction == UIC_SORT_LIST_TOP_TO_BOT) then
        pos_y = -pos_y

    end

    return 0, pos_y
end

-------------------------------------
-- function getMenuMinSize
-------------------------------------
function UIC_SortList:getMenuMinSize()
    local button_cnt = 1
    local size = ((button_cnt+1) * self.m_buttonMargin) + (button_cnt * self.m_buttonHeight)
    return size
end

-------------------------------------
-- function getMenuMaxSize
-------------------------------------
function UIC_SortList:getMenuMaxSize()
    local button_cnt = #self.m_lSortData
    local size = ((button_cnt+1) * self.m_buttonMargin) + (button_cnt * self.m_buttonHeight)
    return size
end

-------------------------------------
-- function show
-------------------------------------
function UIC_SortList:show()
    if (self.m_bShow) then
        return
    end

    self.m_bShow = true

    self.m_containerMenu:stopAllActions()
    self.m_containerMenu:setVisible(true)


    do
        local function tween_cb(value, node)
            self.m_containerBG:setNormalSize(self.m_menuWidth, value)
        end
        local width, height = self.m_containerBG:getNormalSize()
        local tween_action = cc.ActionTweenForLua:create(SORT_LIST_ACTION_DURATION, height, self:getMenuMaxSize(), tween_cb)
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

    self:reserveHide()
end

-------------------------------------
-- function hide
-------------------------------------
function UIC_SortList:hide()
    if (not self.m_bShow) then
        return
    end

    self:cancelReserveHide()

    self.m_bShow = false

    self.m_containerMenu:stopAllActions()
    --self.m_containerMenu:setVisible(true)


    do
        local function tween_cb(value, node)
            self.m_containerBG:setNormalSize(self.m_menuWidth, value)
        end
        local width, height = self.m_containerBG:getNormalSize()
        local tween_action = cc.ActionTweenForLua:create(SORT_LIST_ACTION_DURATION, height, self:getMenuMinSize(), tween_cb)
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
function UIC_SortList:toggleVisibility()
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
function UIC_SortList:setExtendBtnCb(click_cb)
    self.m_extend_btn_cb = click_cb
end

-------------------------------------
-- function click_sortTypeBtn
-------------------------------------
function UIC_SortList:click_sortTypeBtn(t_data)   
    self:setSelectSortType(t_data['sort_type'])

    if self.m_bDirectHide then
        self:hide()
    else
        self:reserveHide()
        self:show()
    end
end

-------------------------------------
-- function setSelectSortType
-- @param no_use_cb 콜백 동작 없이 버튼 상태 변경 하고 싶을 때 사용.. uic_list가 각종 탭, 테이블과 엮여 있을 경우 사용하기 위함
-------------------------------------
function UIC_SortList:setSelectSortType(sort_type, no_use_cb)
    local t_data = nil
    if self.m_selectSortType then
        t_data = self.m_mSortData[self.m_selectSortType]
    end

    if t_data then
        t_data['button']:setEnabled(true)
    end

    -------------------------------------------------------

    self.m_selectSortType = sort_type
    local t_data = nil
    if self.m_selectSortType then
        t_data = self.m_mSortData[self.m_selectSortType]
    end

    if t_data then
        t_data['button']:setEnabled(false)

        if self.m_sortTypeLabel then
            self.m_sortTypeLabel:setString(t_data['sort_name'])

            -- @ TODO 이부분은 정리가 필요하다 mskim
            if (t_data['t_label_data']) then
                self.m_sortTypeLabel:setColor(t_data['t_label_data']['color'])
            end
        end
    else
        if self.m_sortTypeLabel then
            self.m_sortTypeLabel:setString()
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
function UIC_SortList:reserveHide()
    self.m_node:stopAllActions()
    local function func()
        self:hide()
    end
    self.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(4), cc.CallFunc:create(func)))
end

-------------------------------------
-- function cancelReserveHide
-------------------------------------
function UIC_SortList:cancelReserveHide()
    self.m_node:stopAllActions()
end



function MakeUICSortList_dragonManage(button, label, direction, is_simple_mode)

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()
    local direction = direction or UIC_SORT_LIST_BOT_TO_TOP

    local uic = UIC_SortList()
	uic.m_buttonHeight = 40
	uic.m_fontSize = 20
    uic.m_direction = direction
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)

	if (not is_simple_mode) then
		uic:addSortType('combat_power', Str('전투력'))
		uic:addSortType('grade', Str('등급'))
		uic:addSortType('lv', Str('레벨'))
		uic:addSortType('hp', Str('체력'))
		uic:addSortType('def', Str('방어력'))
		uic:addSortType('atk', Str('공격력'))
		uic:addSortType('friendship', Str('친밀도'))
		uic:addSortType('created_at', Str('획득순'))
	end
    uic:addSortType('rarity', Str('희귀도'))
	uic:addSortType('attr', Str('속성'))
	uic:addSortType('did', Str('종류'))
    --uic:show()

    return uic
end

function MakeUICSortList_DragonUpgradeMaterialCombine(button, label)

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()

    uic.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)

    uic:addSortType(1, Str('1등급'))
    uic:addSortType(2, Str('2등급'))
    uic:addSortType(3, Str('3등급'))
    uic:addSortType(4, Str('4등급'))

    return uic
end

function MakeUICSortList_runeManage(button, label)

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()

    uic.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)

    uic:addSortType('set_id', Str('세트'))
    uic:addSortType('grade', Str('등급'))
    uic:addSortType('lv', Str('강화'))
    uic:addSortType('rarity', Str('희귀도'))
	uic:addSortType('created_at', Str('획득순'))
    uic:addSortType('mopt', Str('주옵션'))
    uic:addSortType('equipped', Str('장착'))
    uic:addSortType('filter_point', Str('룬점수'))

    return uic
end

function MakeUICSortList_runeManageFilter(button, label)
    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()

    uic.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    
    -- 커스텀하게 조절
    --uic.m_buttonHeight = 38
    uic.m_buttonMargin = 2

    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)

    -- 0은 전체
    uic:addSortType(0, Str('전체'))

    -- set_id는 자연수
    local table_rune_set = TableRuneSet()

    for i,v in ipairs(table_rune_set.m_orgTable) do
        local set_id = i
        local text = TableRuneSet:makeRuneSetFullNameRichText(set_id)
        uic:addSortType(set_id, text, nil, true)
    end

    return uic
end

function MakeUICSortList_runeCombine(button, label)

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()

    uic.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)

    uic:addSortType(0, Str('전체'))
    uic:addSortType(1, Str('1등급'))
    uic:addSortType(2, Str('2등급'))
    uic:addSortType(3, Str('3등급'))
    uic:addSortType(4, Str('4등급'))
	uic:addSortType(5, Str('5등급'))
    uic:addSortType(6, Str('6등급'))
    uic:addSortType(7, Str('7등급'))

    return uic
end

function MakeUICSortList_teamList(button, label, type)

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()

    uic.m_direction = UIC_SORT_LIST_BOT_TO_TOP
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)

    if (type == 'adventure') then
        uic:addSortType('1', Str('1팀'))
        uic:addSortType('2', Str('2팀'))
        uic:addSortType('3', Str('3팀'))
    else
        uic:addSortType('1', Str('1팀'))
        uic:addSortType('2', Str('2팀'))
        uic:addSortType('3', Str('3팀'))
        uic:addSortType('pvp', Str('콜로세움'))
    end

    return uic
end

-------------------------------------
-- function MakeUICSortList_scenarioPlayerSetting
-- @brief 시나리오 재생 설정
--        1. 최초 1회만 보기
--        2. 항상 보기
--        3. 항상 보지 않기
-------------------------------------
function MakeUICSortList_scenarioPlayerSetting(button, label, type)

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()

    uic.m_direction = UIC_SORT_LIST_BOT_TO_TOP
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)

    uic:addSortType('first', Str('최초 1회만 보기'))
    uic:addSortType('always', Str('항상 보기'))
    uic:addSortType('off', Str('항상 보지 않기'))

    return uic
end

function MakeUICSortList_clanMember(button, label, direction)

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()
    local direction = direction or UIC_SORT_LIST_BOT_TO_TOP

    local uic = UIC_SortList()
    uic.m_direction = direction
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    local z_order = 100
    parent:addChild(uic.m_node, z_order)

    uic:addSortType('level', Str('레벨'))
    uic:addSortType('active_time', Str('최종접속'))
    uic:addSortType('member_type', Str('직책'))
	uic:addSortType('contribute_exp', Str('경험치'))

    return uic
end

function MakeUICSortList_clanRequest(button, label, direction)

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()
    local direction = direction or UIC_SORT_LIST_BOT_TO_TOP

    local uic = UIC_SortList()
    uic.m_direction = direction
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    local z_order = 100
    parent:addChild(uic.m_node, z_order)

    uic:addSortType('level', Str('레벨'))
    uic:addSortType('active_time', Str('최종접속'))

    return uic
end

-- show/hide
-- addSortType (sort_type, sort_name)



-------------------------------------
-- function MakeUICSortList_challengModeStage
-- @brief 정렬 버튼
-------------------------------------
function MakeUICSortList_challengModeStage(button, label, direction)

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()
    local direction = direction or UIC_SORT_LIST_TOP_TO_BOT

    local uic = UIC_SortList()
	uic.m_buttonHeight = 40
	uic.m_fontSize = 18
    uic.m_direction = direction
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node, 1)

    -- 버튼 리스트 세팅
	uic:addSortType('stage', Str('스테이지'))
    uic:addSortType('victory_mode', Str('승리 난이도'))

    --uic:show()

    return uic
end


-------------------------------------
-- function MakeUICSortList_RuneEnhance
-- @brief 정렬 버튼
-------------------------------------
function MakeUICSortList_RuneEnhance(button, label, direction)
    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()
    local direction = direction or UIC_SORT_LIST_TOP_TO_BOT

    local uic = UIC_SortList()
	uic.m_buttonHeight = 40
	uic.m_fontSize = 18
    uic.m_direction = direction
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node, 1)

    -- 버튼 리스트 세팅
	uic:addSortType('enhance_cnt_0', Str('반복 없음'))
    for i = 1, 5 do 
        uic:addSortType('enhance_cnt_' .. i * 3, Str('+{1} 까지 강화', i*3))
    end

    return uic
end