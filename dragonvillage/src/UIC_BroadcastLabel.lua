local PARENT = UIC_Node
-------------------------------------
-- class UIC_BroadcastLabel
-------------------------------------
UIC_BroadcastLabel = class(PARENT, {
        m_bgScale9Sprite = 'cc.Scale9Sprite',
        m_scrollView = 'cc.ScrollVIew',
        m_richLabel = 'UIC_RichLabel',

        m_defalutSize = 'cc.size',

        m_bEnabled = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_BroadcastLabel:init()
    self.m_bEnabled = true
end

-------------------------------------
-- function create
-------------------------------------
function UIC_BroadcastLabel:create(bg_scale9sprite, rich_label)
    local self = UIC_BroadcastLabel()

    self.m_node = bg_scale9sprite
    self.m_bgScale9Sprite = bg_scale9sprite
    --bg_scale9sprite:setVisible(true)

    do  -- 스크롤 뷰 생성
        -- bg_scale9sprite에서 정보 얻어옴
        local width, height = bg_scale9sprite:getNormalSize()
        local size = cc.size(width, height)
        self.m_defalutSize = size -- 기본 사이즈 저장
        local dock_point = bg_scale9sprite:getDockPoint()
        local anchor_point = bg_scale9sprite:getAnchorPoint()
        local x, y = bg_scale9sprite:getPosition()

        -- 스크롤 뷰 생성
        local scroll_view = cc.ScrollView:create()
        self.m_scrollView = scroll_view
        scroll_view:setNormalSize(size)
        scroll_view:setRelativeSizeAndType(cc.size(0, 0), 3, true) -- 렐러티브 사이즈 both로 지정
        scroll_view:setContentSize(size)
        scroll_view:setDockPoint(cc.p(0.5, 0.5))
        scroll_view:setAnchorPoint(cc.p(0.5, 0.5))
        scroll_view:setPosition(0, 0)
        bg_scale9sprite:addChild(scroll_view) -- bg_scale9sprite에 붙임
        scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) -- 좌, 우 스크롤 사용

        do  -- 컨테이너 시각적으로 보이게 (디버깅 용도)
            --local _container = scroll_view:getContainer()
            --UIC_Node(_container):initGLNode()
        end

        scroll_view:setTouchEnabled(false)
    end

    do -- rich_label
        self.m_richLabel = rich_label
        rich_label:retain()
        rich_label:removeFromParent()
        rich_label:setDimension(1000, 50) -- 충분히 넓은 영역 제공
        rich_label:setPosition(0, 0)
        rich_label:setDockPoint(cc.p(0.5, 0.5))
        rich_label:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_scrollView:addChild(rich_label.m_node)
        rich_label:release()
    end

    return self
end

-------------------------------------
-- function setString
-------------------------------------
function UIC_BroadcastLabel:setString(str)
    if (not self.m_bEnabled) then 
        return 
    end

    -- RichLabel에 문자열 설정
    self.m_richLabel:setString(str)

    -- RichLabel의 넓이를 얻어옴
    local width = self.m_richLabel:getStringWidth() + 10 -- 10픽셀의 여유(여백)을 줌

    -- 스크롤 뷰의 정보를 얻어옴
    local normal_size = cc.size(self.m_node:getNormalSize())
    normal_size['width'] = math_min(width, self.m_defalutSize['width'])
    self.m_node:setNormalSize(normal_size)

    normal_size['width'] = width
    self.m_scrollView:setContentSize(normal_size)

    self.m_node:setUpdateChildrenTransform()

    self:runScrollAction()
end

-------------------------------------
-- function runScrollAction
-------------------------------------
function UIC_BroadcastLabel:runScrollAction()
    doAllChildren(self.m_node, function(node) node:setCascadeOpacityEnabled(true) end)

    -- 컨테이너의 액션 정지
    local container = self.m_scrollView:getContainer()
    container:stopAllActions()

    -- 첫 위치로 이동
    self.m_scrollView:setContentOffset(cc.p(0, 0), false)

    -- 마지막 위치 얻어옴
    local pos = self.m_scrollView:minContainerOffset()

    self:setVisible(true)
    local call_func = cc.CallFunc:create(function() self:setVisible(false) end)

    local sequence = cc.Sequence:create(cc.DelayTime:create(1), cc.MoveTo:create(2, pos), cc.DelayTime:create(6), call_func)
    container:runAction(sequence)
end

-------------------------------------
-- function clear
-------------------------------------
function UIC_BroadcastLabel:clear()
    -- RichLabel에 문자열 설정
    self.m_richLabel:setString('')
    self:setVisible(false)
end
