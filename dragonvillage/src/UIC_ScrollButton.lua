local PARENT = UIC_Node
-------------------------------------
-- class UIC_ScrollButton
-------------------------------------
UIC_ScrollButton = class(PARENT, {
        m_scrollView = 'cc.ScrollVIew',
        m_defalutSize = 'cc.size',

        m_bEnabled = 'boolean',
        m_buttonList = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_ScrollButton:init()
    self.m_bEnabled = true
end

-------------------------------------
-- function create
-------------------------------------
function UIC_ScrollButton:create(node, l_button)
    local self = UIC_ScrollButton()
    self.m_node = node
    self.m_buttonList = l_button

    local width, height = node:getNormalSize()
    local size = cc.size(width, height)

    do  -- 스크롤 뷰 생성    
        self.m_defalutSize = size -- 기본 사이즈 저장
        local dock_point = node:getDockPoint()
        local anchor_point = node:getAnchorPoint()
        local x, y = node:getPosition()

        -- 스크롤 뷰 생성
        local scroll_view = cc.ScrollView:create()
        self.m_scrollView = scroll_view
        scroll_view:setNormalSize(size)
        scroll_view:setRelativeSizeAndType(cc.size(0, 0), 3, true) -- 렐러티브 사이즈 both로 지정
        scroll_view:setContentSize(cc.size(width * #l_button, height))
        scroll_view:setDockPoint(cc.p(0.5, 0.5))
        scroll_view:setAnchorPoint(cc.p(0.5, 0.5))
        scroll_view:setPosition(0, 0)
        node:addChild(scroll_view) -- node에 붙임
        scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) -- 좌, 우 스크롤 사용

        scroll_view:setTouchEnabled(false)
    end

    -- 메뉴 생성 
    local menu = cc.Menu:create()
    menu:setDockPoint(ZERO_POINT)
    menu:setAnchorPoint(ZERO_POINT)
    menu:setNormalSize(cc.size(width * #l_button, height))
    menu:setPosition(ZERO_POINT)
    menu:setSwallowTouch(false)
    self.m_scrollView:addChild(menu)

    -- 버튼 등록
    for i, button in ipairs(l_button) do
        button:setPosition(width * (i-1), 0)
        menu:addChild(button)
    end

    return self
end

-------------------------------------
-- function runScrollAction
-------------------------------------
function UIC_ScrollButton:runScrollAction()
    local l_button = self.m_buttonList
    -- 버튼 1개라면 스크롤 x
    if (#l_button <= 1) then
        return
    end
    
    doAllChildren(self.m_node, function(node) node:setCascadeOpacityEnabled(true) end)

    -- 컨테이너의 액션 정지
    local container = self.m_scrollView:getContainer()
    container:stopAllActions()

    -- 첫 위치로 이동
    self.m_scrollView:setContentOffset(cc.p(0, 0), false)

    -- 마지막 위치 얻어옴
    local pos = self.m_scrollView:minContainerOffset()
    local node = self.m_node
    local width, height = node:getNormalSize()

    self:setVisible(true)
    local call_func = cc.CallFunc:create(function()
        if (math_abs(container:getPositionX()) == width * (#l_button - 1)) then
            self.m_scrollView:setContentOffset(cc.p(0, 0), false)
        end  
    end)

    local move_by = cc.MoveBy:create(0.4, cc.p(-width, 0))
    local action = cc.EaseInOut:create(move_by, 2)

    local sequence = cc.Sequence:create(cc.DelayTime:create(3), action, call_func)
    container:runAction(cc.RepeatForever:create(sequence))
end

-------------------------------------
-- function clear
-------------------------------------
function UIC_ScrollButton:clear()
    self:setVisible(false)
end
