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

        m_bShow = 'boolean',
        m_direction = '',
        m_selectSortType = '',

        ------------------------------------
        m_menuWidth = '',
        m_containerMenu = '',
        m_containerBG = '',

        ------------------------------------
        -- 외부에서 지정
        m_extendButton = '',
        m_sortTypeLabel = '',
        m_sortChangeCB = '',
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

    self.m_bShow = false
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
        self.m_containerBG = cc.Scale9Sprite:create(cc.rect(0,0,0,0), 'res/ui/frame/a_frame_03.png')
        self.m_containerBG:setDockPoint(cc.p(0.5, 0.5))
        self.m_containerBG:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_containerBG:setRelativeSizeAndType(cc.size(0, 0), 3, true)
        self.m_containerMenu:addChild(self.m_containerBG)
    end

    do -- 블록 버튼 생성
        local button = cc.MenuItemImage:create(EMPTY_PNG, EMPTY_PNG)
        button:setDockPoint(cc.p(0.5, 0.5))
        button:setAnchorPoint(cc.p(0.5, 0.5))
        button:setRelativeSizeAndType(cc.size(0, 0), 3, true)
        self.m_containerMenu:addChild(button)
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
-- function addSortType
-------------------------------------
function UIC_SortList:addSortType(sort_type, sort_name)

    local button = cc.MenuItemImage:create('res/ui/btn/a_btn_0101.png', 'res/ui/btn/a_btn_0102.png', 'res/ui/btn/a_btn_0103.png', 1)
    local width, heigth = self.m_node:getNormalSize()
    button:setNormalSize(width - (BUTTON_MARGIN * 2), BUTTON_HEIGHT)

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

    do -- 라벨 생성
        local font_name = 'res/font/common_font_01.ttf'
        local stroke_tickness = 2
        local font_size = (BUTTON_HEIGHT / 2) -- 버튼 사이즈의 반을 사용
        local size = cc.size(256, 256)
        local node = cc.Label:createWithTTF(sort_name, font_name, font_size, stroke_tickness, size, cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        node:setDockPoint(cc.p(0.5, 0.5))
        node:setAnchorPoint(cc.p(.5, 0.5))
        node:setTextColor(cc.c4b(240, 215, 159, 255))
        node:enableOutline(cc.c4b(85, 44, 25,255), stroke_tickness)
        button:addChild(node)
    end

    local t_data
    do -- 데이터 저장
        t_data = {}
        t_data['sort_type'] = sort_type
        t_data['sort_name'] = sort_name
        t_data['button'] = button
        t_data['idx'] = #self.m_lSortData + 1

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

    local pos_y = (BUTTON_MARGIN * idx) + ((idx-1) * BUTTON_HEIGHT)

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
    local size = ((button_cnt+1) * BUTTON_MARGIN) + (button_cnt * BUTTON_HEIGHT)
    return size
end

-------------------------------------
-- function getMenuMaxSize
-------------------------------------
function UIC_SortList:getMenuMaxSize()
    local button_cnt = #self.m_lSortData
    local size = ((button_cnt+1) * BUTTON_MARGIN) + (button_cnt * BUTTON_HEIGHT)
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
            self.m_containerMenu:setNormalSize(self.m_menuWidth, value)
        end
        local width, height = self.m_containerMenu:getNormalSize()
        local tween_action = cc.ActionTweenForLua:create(SORT_LIST_ACTION_DURATION, height, self:getMenuMaxSize(), tween_cb)
        local action = cc.EaseElasticOut:create(tween_action, 1.5)
        self.m_containerMenu:runAction(action)
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
            self.m_containerMenu:setNormalSize(self.m_menuWidth, value)
        end
        local width, height = self.m_containerMenu:getNormalSize()
        local tween_action = cc.ActionTweenForLua:create(SORT_LIST_ACTION_DURATION, height, self:getMenuMinSize(), tween_cb)
        local ease = cc.EaseElasticIn:create(tween_action, 1.5)
        local action = cc.Sequence:create(ease, cc.CallFunc:create(function() self.m_containerMenu:setVisible(false) end))
        self.m_containerMenu:runAction(action)
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
    if self.m_bShow then
        self:hide()
    else
        self:show()
    end
end

-------------------------------------
-- function click_sortTypeBtn
-------------------------------------
function UIC_SortList:click_sortTypeBtn(t_data)   
    self:setSelectSortType(t_data['sort_type'])
    self:reserveHide()
    self:show()
end

-------------------------------------
-- function setSelectSortType
-------------------------------------
function UIC_SortList:setSelectSortType(sort_type)
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
        end
    else
        if self.m_sortTypeLabel then
            self.m_sortTypeLabel:setString()
        end
    end


    -- 콜백
    if self.m_sortChangeCB then
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



function MakeUICSortList_dragonManage(button, label)

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)

    uic:addSortType('hp', Str('체력'))
    uic:addSortType('def', Str('방어력'))
    uic:addSortType('atk', Str('공격력'))
    uic:addSortType('attr', Str('속성'))
    uic:addSortType('lv', Str('레벨'))
    uic:addSortType('grade', Str('등급'))
    uic:addSortType('rarity', Str('희귀도'))
    uic:addSortType('friendship', Str('친밀도'))

    --uic:show()

    return uic
end

function MakeUICSortList(width, height)
    local uic = UIC_SortList()
    uic:setNormalSize(width, height)
    uic:init_container()
    return uic
end


-- show/hide
-- addSortType (sort_type, sort_name)