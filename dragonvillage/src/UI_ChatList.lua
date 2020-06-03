local USE_CHAT_LIST_GL_NODE = false

-------------------------------------
-- class UI_ChatList
-- @brief
-------------------------------------
UI_ChatList = class({
    m_width = '',       -- 리스트의 넓이
    m_height = '',      -- 리스트의 높이

    m_containerWidth = '',  -- 컨테이너의 실시간 넓이 (리스트의 넓이와 항상 같음)
    m_containerHeight = '', -- 컨에티너의 실시간 높이

    m_root = '',
    m_container = '',

    m_contentList = '', -- {node, height, type}

    m_maxCount = '',    -- 표시될 컨텐츠의 최대 갯수(nil일 경우 무한대, nil이 아닐 경우 오래된 컨텐츠 순으로 삭제)

    --
    m_bUseScrollBar = '',
    m_scrollBar = '',
})

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function UI_ChatList:init(parent, width, height, max_count)
    -- 채팅 리스트의 넓이, 높이 지정
    self.m_width = width
    self.m_height = height

    -- 컨테이너의 넓이, 높이 초기화
    self.m_containerWidth = width
    self.m_containerHeight = 0

    -- 컨텐츠의 최대 갯수 지정
    self.m_maxCount = max_count

    -- root node 생성
    self.m_root = cc.Node:create()
    self.m_root:setDockPoint(cc.p(0.5, 0))
    self.m_root:setAnchorPoint(cc.p(0.5, 0))
    parent:addChild(self.m_root)

    -- 클리핑 노드 생성
    local container_parent = self.m_root
    if true then
        -- clipping node 생성
        local clippingNode = cc.ClippingNode:create()
        container_parent = clippingNode
	    
	    -- stencil 생성
	    local stencil = cc.DrawNode:create()
	    stencil:clear()
	    local rectangle = {}
	    local white = cc.c4b(1,1,1,1)
	    table.insert(rectangle, cc.p(-(width/2), 0))
	    table.insert(rectangle, cc.p((width/2), 0))
	    table.insert(rectangle, cc.p((width/2), height))
	    table.insert(rectangle, cc.p(-(width/2), height))
	    stencil:drawPolygon(rectangle, 4, white, 1, white)
	    clippingNode:setStencil(stencil)

        self.m_root:addChild(clippingNode)
    end

    -- 컨테이너 생성(실제 컨텐츠들의 parent)
    self.m_container = cc.Node:create()
    self.m_container:setDockPoint(cc.p(0.5, 0))
    self.m_container:setAnchorPoint(cc.p(0.5, 0))
    container_parent:addChild(self.m_container)

    -- 스크롤을 위한 터치 핸들러 등록
    self:makeTouchLayer(self.m_root)
    
    -- content관련 초기화
    self:clearContent()

    self:initRootGLNode()

    -- 스크롤바 사용
    self.m_bUseScrollBar = true
    --self.m_scrollBar = cc.Scale9Sprite:create('res/ui/temp/btn_debug_02.png')
    self.m_scrollBar = cc.Scale9Sprite:create('res/common/empty.png')
    self.m_scrollBar:setDockPoint(cc.p(1, 0))
    self.m_scrollBar:setAnchorPoint(cc.p(0.5, 0))
    self.m_scrollBar:setPositionX((width/2) + 15)
    self.m_root:addChild(self.m_scrollBar)
    self:updateScrollBar()
end

-------------------------------------
-- function initRootGLNode
-------------------------------------
function UI_ChatList:initRootGLNode()
    if (not USE_CHAT_LIST_GL_NODE) then
        return
    end

    do -- glNode 생성
        local glNode = cc.GLNode:create()
        glNode:registerScriptDrawHandler(function(transform, transformUpdated) self:primitivesDraw(transform, transformUpdated) end)
        self.m_root:addChild(glNode)
    end
end

-------------------------------------
-- function initContainerGLNode
-------------------------------------
function UI_ChatList:initContainerGLNode()
    if (not USE_CHAT_LIST_GL_NODE) then
        return
    end

    do -- glNode 생성
        local glNode = cc.GLNode:create()
        glNode:registerScriptDrawHandler(function(transform, transformUpdated) self:primitivesDraw_container(transform, transformUpdated) end)
        self.m_container:addChild(glNode)
    end
end

-------------------------------------
-- function primitivesDraw
-- @brief 채팅 리스트의 크기를 시각적으로 확인하기 위해 사용
-------------------------------------
function UI_ChatList:primitivesDraw(transform, transformUpdated)
    kmGLPushMatrix()
    kmGLLoadMatrix(transform)

    local anchor_point = self.m_root:getAnchorPoint()

    local x = -(self.m_width * anchor_point['x'])
    local y = -(self.m_height * anchor_point['y'])

    local vertices =   
    {  
        cc.p(x, y),
        cc.p(x + self.m_width, y),
        cc.p(x + self.m_width, y + self.m_height),  
        cc.p(x + 0, y + self.m_height),  
    }  
    cc.DrawPrimitives.drawSolidPoly(vertices, 4, cc.c4f(0.2, 0.2, 0.2, 0.5))

    kmGLPopMatrix()
end

-------------------------------------
-- function primitivesDraw_container
-- @brief 채팅 컨테이너의 크기를 시각적으로 확인하기 위해 사용
-------------------------------------
function UI_ChatList:primitivesDraw_container(transform, transformUpdated)
    kmGLPushMatrix()
    kmGLLoadMatrix(transform)

    local anchor_point = self.m_container:getAnchorPoint()

    local x = -(self.m_containerWidth * anchor_point['x'])
    local y = -(self.m_containerHeight * anchor_point['y'])

    local vertices =   
    {      
        cc.p(x, y),
        cc.p(x + self.m_containerWidth, y),
        cc.p(x + self.m_containerWidth, y + self.m_containerHeight),  
        cc.p(x + 0, y + self.m_containerHeight),  
    }  
    cc.DrawPrimitives.drawSolidPoly(vertices, 4, cc.c4f(1, 0, 0, 0.5))

    kmGLPopMatrix()
end




-------------------------------------
-- function clearContent
-- @brief 모든 컨텐츠 삭제
-------------------------------------
function UI_ChatList:clearContent()
    self.m_contentList = {}
    self.m_containerHeight = 0
    self.m_container:removeAllChildren()
    self.m_container:setPositionY(0)
    self:updateScrollBar()

    self:initContainerGLNode()
end

-------------------------------------
-- function addContent
-- @brief 컨텐츠 삽입
-------------------------------------
function UI_ChatList:addContent(node, height, type)

    -- 이전 컨텐츠들위 Y위치 이동
    for i,v in ipairs(self.m_contentList) do
        v['node']:setPositionY(v['node']:getPositionY() + height)
    end

    -- content생성 후 리스트에 삽입
    local t_content = {node=node, height=height, type=type}
    table.insert(self.m_contentList, t_content)
    self.m_containerHeight = self.m_containerHeight + height
    self.m_container:addChild(node)

    -- 최대 갯수가 지정되어 있을 경우
    if self.m_maxCount then
        -- 최대 갯수 초과 시 가장 먼저 생성된 content부터 삭제
        while #self.m_contentList > self.m_maxCount do
            self.m_contentList[1]['node']:removeFromParent()
            self.m_containerHeight = self.m_containerHeight - self.m_contentList[1]['height']
            table.remove(self.m_contentList, 1)
        end
    end

    self:updateScrollBar()
end




----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-------------------------------------
-- function makeTouchLayer
-- @brief 터치 레이어 생성
-------------------------------------
function UI_ChatList:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    --listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    --listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)
        		
	local eventDispatcher = target_node:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function UI_ChatList:onTouchBegan(touche, event)
    local location = touche:getLocation()

    -- 영역을 벗어났는지 체크
    local bounding_box = cc.rect(0, 0, self.m_width, self.m_height)
    local local_location = self.m_root:getParent():convertToNodeSpace(location)
    local is_contain = cc.rectContainsPoint(bounding_box, local_location)

    if is_contain then
        event:stopPropagation()
        return true
    else
        return false
    end
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function UI_ChatList:onTouchMoved(touch, event)
    local diff = touch:getDelta()

    -- 변화량이 있을 경우에만 이동
    if diff and (diff['y'] ~= 0) then
        local y = self.m_container:getPositionY() + diff.y

        -- 컨테이너가 리스트의 크기보다 작을 경우 무조건 0
        if (self.m_containerHeight <= self.m_height) then
            y = 0
        else
            local min = -(self.m_containerHeight - self.m_height)
            local max = 0
            y = math_clamp(y, min, max)
        end
    
        -- 컨테이너의 y위치 변경
        self.m_container:setPositionY(y)
        self:updateScrollBar()
    end
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function UI_ChatList:onTouchEnded(touch, event)
end

-------------------------------------
-- function updateScrollBar
-------------------------------------
function UI_ChatList:updateScrollBar()
    if self.m_bUseScrollBar then
        if (self.m_containerHeight <= self.m_height) then
            self.m_scrollBar:setVisible(false)
            self.m_scrollBar:setNormalSize(10, self.m_height)
            self.m_scrollBar:setPositionY(0)
        else
            self.m_scrollBar:setVisible(true)
            local scale = (self.m_height / self.m_containerHeight)
            local height = (self.m_height * scale)
            self.m_scrollBar:setNormalSize(10, height)

            local max_pos = (self.m_containerHeight - self.m_height)
            local pos_y = self.m_container:getPositionY()
            local pos_rate = pos_y / max_pos

            self.m_scrollBar:setPositionY(-((self.m_height-height) * pos_rate))
        end
    end
end