local PARENT = UIC_Node
-------------------------------------
-- class UIC_ScrollLabel
-------------------------------------
UIC_ScrollLabel = class(PARENT, {
        m_richLabel = 'UIC_RichLabel',

        m_offsetMinY = 'number',
        m_offsetMaxY = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_ScrollLabel:init()
end

-------------------------------------
-- function create
-------------------------------------
function UIC_ScrollLabel:create(rich_label)
    -- 인스턴스 생성
    local scroll_label = UIC_ScrollLabel()

    do -- ScrollView 생성
        local scroll_view = cc.ScrollView:create()

        -- RichLabel에서 정보 얻어옴
        local width, height = rich_label:getNormalSize()
        local size = cc.size(width, height)
        local dock_point = rich_label:getDockPoint()
        local anchor_point = rich_label:getAnchorPoint()
        local x, y = rich_label:getPosition()

        -- ScrollView에 RichLabel의 속성들 지정
        scroll_view:setNormalSize(size)
        scroll_view:setContentSize(size)
        scroll_view:setDockPoint(dock_point)
        scroll_view:setAnchorPoint(anchor_point)
        scroll_view:setPosition(x, y)

        -- 상-하 스크롤 사용
        scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        scroll_label.m_node = scroll_view

        do  -- 컨테이너 비주얼로 보이게
            --local _container = scroll_view:getContainer()
            --UIC_Node(_container):initGLNode()
        end
    end

    do
        scroll_label.m_richLabel = rich_label
        rich_label:setDockPoint(cc.p(0.5, 0.5))
        rich_label:setAnchorPoint(cc.p(0.5, 0.5))
        rich_label:setPosition(0, 0)
        scroll_label.m_node:getContainer():addChild(rich_label.m_node)
    end

    return scroll_label
end

-------------------------------------
-- function setString
-------------------------------------
function UIC_ScrollLabel:setString(str)

    -- RichLabel에 문자열 설정
    self.m_richLabel:setString(str)

    -- RichLabel의 높이를 얻어옴
    local height = self.m_richLabel:getStringHeight()

    -- 스크롤 뷰의 정보를 얻어옴
    local scroll_view = self.m_node
    local normal_size = cc.size(scroll_view:getNormalSize())
    local content_size = scroll_view:getContentSize()

    -- container사이즈 지정
    content_size['height'] = math_max(height, normal_size['height'])
    scroll_view:setContentSize(content_size)

    -- container위치 조정
    local min_container_offset = scroll_view:minContainerOffset()
    local max_container_offset = scroll_view:maxContainerOffset()

    local animated = false
    scroll_view:setContentOffset(min_container_offset, animated)

    -- 스크롤의 최상단인지 최하단인지 판단을 할 때 사용된다.
    -- 가변적인 리스트는 이걸 무조건 믿는것보다 그떄그떄 get 하는 함수를 만들어야 한다.
    self.m_offsetMinY = min_container_offset['y']
    self.m_offsetMaxY = max_container_offset['y']

end

-------------------------------------
-- function getScrollOffset
-------------------------------------
function UIC_ScrollLabel:getScrollOffset()
    -- 스크롤 뷰의 정보를 얻어옴
    local scroll_view = self.m_node

    return scroll_view:getContentOffset()
end

-------------------------------------
-- function isTopPosition
-------------------------------------
function UIC_ScrollLabel:isTopPosition()
    -- 스크롤 뷰의 정보를 얻어옴
    local scroll_view = self.m_node

    -- 현 오프셋이 최소 오프셋보다 작으면 최상단으로 간것
    local curOffset = scroll_view:getContentOffset()
    local curPosY = curOffset['y']
    local isTopPosition = curPosY <= self.m_offsetMinY

    return isTopPosition
end

-------------------------------------
-- function isBottomPosition
-------------------------------------
function UIC_ScrollLabel:isBottomPosition()
    -- 스크롤 뷰의 정보를 얻어옴
    local scroll_view = self.m_node

    -- 현 오프셋이 0보다 크면 밑바닥을 간것
    local curOffset = scroll_view:getContentOffset()
    local curPosY = curOffset['y']
    local isBottomPosition = curPosY >= self.m_offsetMaxY

    return isBottomPosition
end