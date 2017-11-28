-------------------------------------
-- class Camera
-- @brief 카메라
-------------------------------------
Camera = class({
        m_rootNode = 'cc.Node',  -- 카메라의 node
        m_aLayerList = 'table',  -- 원근감을 가지는 다중 레이어 리스트 {layer(node), perspective_ratio}
        m_stdNode = 'cc.Node',   -- 다중 레이어에 perspective_ratio를 1로 넣은 기준 노드

        m_posX = 'number',       -- 카메라의 위치 X
        m_posY = 'number',       -- 카메라의 위치 Y
        m_zoom = 'number',       -- 카메라의 줌

        m_screenSizeWidth = '',  -- 스크린 사이즈 width
        m_screenSizeHeight = '', -- 스크린 사이즈 height

        m_containerSizeWidth = '',  -- 카메라 사이즈 width
        m_containerSizeHeight = '', -- 카메라 사이즈 height

        -- 보정에 사용되는 변수들(initAdjust 함수에서 초기화)
        m_adjustPosMinX = 'number',
        m_adjustPosMaxX = 'number',
        m_adjustPosMinY = 'number',
        m_adjustPosMaxY = 'number',
        m_adjustMinZoom = 'number',
        m_adjustMaxZoom = 'number',

        -- 액션 관리에 사용되는 변수들
        m_bDoingAction = 'boolean', -- 액션 중인지 여부

        m_touchHandler = '',
    })

-------------------------------------
-- function init
-------------------------------------
function Camera:init(parent, z_order)
    local z_order = z_order or 1

    -- root node 생성
    self.m_rootNode = cc.Node:create()
    self.m_rootNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_rootNode:setAnchorPoint(cc.p(0.5, 0.5))
    parent:addChild(self.m_rootNode, z_order)

    -- 다중 레이어 리스트 초기화
    self.m_aLayerList = {}

    -- 기준 레이어 노드
    self.m_stdNode = cc.Node:create()
    self.m_stdNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_stdNode:setAnchorPoint(cc.p(0.5, 0.5))
    self:addLayer(self.m_stdNode, 1)

    -- 기본 위치 및 줌 지정
    self.m_posX = 0
    self.m_posY = 0
    self.m_zoom = 1

    -- 스크린 사이즈 초기화
    local scr_size = cc.Director:getInstance():getWinSize()
    self.m_screenSizeWidth = scr_size.width
    self.m_screenSizeHeight = scr_size.height
    --cclog({scr_size.width, scr_size.height}, '스크린 사이즈')
    -- 카메라 사이즈 초기화
    self.m_containerSizeWidth = 2048
    self.m_containerSizeHeight = 4096

    -- 보정 수치 초기화
    self:initAdjust()

    self.m_bDoingAction = false

    --self.m_touchHandler = CameraTouchHandler(self, self.m_rootNode)
end

-------------------------------------
-- function setContainerSize
-------------------------------------
function Camera:setContainerSize(width, height)
    self.m_containerSizeWidth = width
    self.m_containerSizeHeight = height
    self:initAdjust()
end

-------------------------------------
-- function addLayer
-- @brief 레이어 추가
-- @param node          카메라에 추가될 레이어(node를 상속받은 모든 객체 가능)
-- @perspective_ratio   원근 비율(기본은 1)
-------------------------------------
function Camera:addLayer(node, perspective_ratio, perspective_ratio_y)
    if (not node) then
        error()
    end

    local perspective_ratio = (perspective_ratio or 1)
    local perspective_ratio_y = (perspective_ratio_y or perspective_ratio)
    local t_layer = {node, perspective_ratio, perspective_ratio_y}

    -- 다중 레이어 리스트에 insert
    table.insert(self.m_aLayerList, t_layer)
    self.m_rootNode:addChild(node, 50)
end

-------------------------------------
-- function setPosition
-------------------------------------
function Camera:setPosition(x, y, b_adjust)
    --cclog('x : ' .. x, 'y : ' .. y)
    if b_adjust then
        self.m_posX, self.m_posY = self:adjustPos(x, y)
    else
        self.m_posX, self.m_posY = x, y
    end

    for _,data in ipairs(self.m_aLayerList) do
        local node = data[1]
        local perspective_ratio = data[2]
        local perspective_ratio_y = data[3]
        node:setPosition(self.m_posX * perspective_ratio, self.m_posY * perspective_ratio_y)
    end
end

-------------------------------------
-- function adjustPos
-------------------------------------
function Camera:adjustPos(x, y, zoom)

    if zoom then
        local gap_x = 0
        if (self.m_containerSizeWidth * zoom) > self.m_screenSizeWidth then
            gap_x = (((self.m_containerSizeWidth * zoom) - self.m_screenSizeWidth) / 2)
        end

        local min_x = -gap_x
        local max_x = gap_x

        local gap_y = 0
        if (self.m_containerSizeHeight * zoom) > self.m_screenSizeHeight then
            gap_y = (((self.m_containerSizeHeight * zoom) - self.m_screenSizeHeight) / 2)
        end
        local min_y = -gap_y
        local max_y = gap_y

        local adjust_x = math_clamp(x, min_x, max_x)
        local adjust_y = math_clamp(y, min_y, max_y)

        -- 보정 여부 X
        local adjusted_x = false
        if (x <= min_x) then adjusted_x = true
        elseif (max_x <= x) then adjusted_x = true
        end

        -- 보정 여부 Y
        local adjusted_y = false
        if (y <= min_y) then adjusted_y = true
        elseif (max_y <= y) then adjusted_y = true
        end

        return adjust_x, adjust_y, adjusted_x, adjusted_y
    else
        local adjust_x = math_clamp(x, self.m_adjustPosMinX, self.m_adjustPosMaxX)
        local adjust_y = math_clamp(y, self.m_adjustPosMinY, self.m_adjustPosMaxY)

        -- 보정 여부 X
        local adjusted_x = false
        if (x <= self.m_adjustPosMinX) then adjusted_x = true
        elseif (self.m_adjustPosMaxX <= x) then adjusted_x = true
        end

        -- 보정 여부 Y
        local adjusted_y = false
        if (y <= self.m_adjustPosMinY) then adjusted_y = true
        elseif (self.m_adjustPosMaxY <= y) then adjusted_y = true
        end

        return adjust_x, adjust_y, adjusted_x, adjusted_y
    end
end

-------------------------------------
-- function setZoom
-------------------------------------
function Camera:setZoom(zoom, b_adjust)

    if b_adjust then
        self.m_zoom = self:adjustZoom(zoom)
        self:initAdjust()
        self:setPosition(self.m_posX, self.m_posY, true)
    else
        self.m_zoom = zoom
        self:initAdjust()
    end

    for _,data in ipairs(self.m_aLayerList) do
        local node = data[1]
        local rate = data[2]
        node:setScale(self.m_zoom)
    end
end

-------------------------------------
-- function adjustZoom
-------------------------------------
function Camera:adjustZoom(zoom)
    local adjust_zoom = math_clamp(zoom, self.m_adjustMinZoom, self.m_adjustMaxZoom)
    return adjust_zoom
end

-------------------------------------
-- function initAdjust
-------------------------------------
function Camera:initAdjust()

    do -- Zoom 범위 지정
        local min_zoom_h = (self.m_screenSizeWidth / self.m_containerSizeWidth)
        local min_zoom_v = (self.m_screenSizeHeight / self.m_containerSizeHeight)
        local min_zoom = math_max(min_zoom_h, min_zoom_v)

        self.m_adjustMinZoom = min_zoom
        self.m_adjustMaxZoom = 1.5
    end

    do -- Position 범위 지정
        local zoom = self.m_zoom or 1

        local gap_x = 0
        if (self.m_containerSizeWidth * zoom) > self.m_screenSizeWidth then
            gap_x = (((self.m_containerSizeWidth * zoom) - self.m_screenSizeWidth) / 2)
        end

        self.m_adjustPosMinX = -gap_x
        self.m_adjustPosMaxX = gap_x

        local gap_y = 0
        if (self.m_containerSizeHeight * zoom) > self.m_screenSizeHeight then
            gap_y = (((self.m_containerSizeHeight * zoom) - self.m_screenSizeHeight) / 2)
        end

        self.m_adjustPosMinY = -gap_y
        self.m_adjustPosMaxY = gap_y
    end

end

-------------------------------------
-- function actionMoveAndZoom
-------------------------------------
function Camera:actionMoveAndZoom(duration, x, y, zoom)
    -- 실행중인 액션이 있으면 중지
    if self.m_bDoingAction then
        self:stopAction()
    end

    local zoom = zoom or self.m_zoom
    zoom = self:adjustZoom(zoom)

    local pos_x = nil
    local pos_y = nil

    if x then
        pos_x = x * zoom
    else
        pos_x = self.m_posX
    end

    if y then
        pos_y = y * zoom
    else
        pos_y = self.m_posY
    end

    pos_x, pos_y = self:adjustPos(pos_x, pos_y, zoom)

    for _,data in ipairs(self.m_aLayerList) do
        local node = data[1]
        local perspective_ratio = data[2]

        local action = cc.ScaleTo:create(duration, zoom, zoom)
        node:runAction(cc.EaseInOut:create(action, 2))

        local action = cc.MoveTo:create(duration, cc.p(pos_x * perspective_ratio, pos_y * perspective_ratio))
        node:runAction(cc.EaseInOut:create(action, 2))
    end

    self.m_bDoingAction = true

    -- 액션 종료 콜백 함수 등록
    local sequence = cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function() self:stopAction() end))
    self.m_stdNode:runAction(sequence)
end

-------------------------------------
-- function actionZoom
-------------------------------------
function Camera:actionZoom(duration, zoom)
    self:actionMoveAndZoom(duration, nil, nil, zoom)
end

-------------------------------------
-- function actionMove
-------------------------------------
function Camera:actionMove(duration, x, y)
    self:actionMoveAndZoom(duration, x, y)
end

-------------------------------------
-- function stopAction
-------------------------------------
function Camera:stopAction()

    -- 모든 레이어의 액션을 종료
    for _,data in ipairs(self.m_aLayerList) do
        local node = data[1]
        local perspective_ratio = data[2]
        node:stopAllActions()
    end

    local zoom = self.m_stdNode:getScale()
    local pos_x, pos_y = self.m_stdNode:getPosition()

    self:setZoom(zoom, true)
    self:setPosition(pos_x, pos_y, true)

    self:initAdjust()

    self.m_bDoingAction = false

    -- 자동 이동하는 속도 초기화
    if self.m_touchHandler then
        self.m_touchHandler.m_velocityX = nil
        self.m_touchHandler.m_velocityY = nil
    end
end

-------------------------------------
-- function destroy
-------------------------------------
function Camera:destroy()
    --self.m_rootNode:removeAllChilderen(true)
    self.m_rootNode:removeFromParent()

end

-------------------------------------
-- function setColorAllLayer
-- @brief layer로 추가된 node의 자식들로 이미지가 붙어있기 때문에 자식까지 처리
-- @brief LobbyMap과 ForestTerritory에서 사용
-------------------------------------
function Camera:setColorAllLayer(color)
	for i, t_layer in pairs(self.m_aLayerList) do
		local node = t_layer[1]
		local childs = node:getChildren()
		for i,v in pairs(childs) do
			v:setColor(color)
		end
	end
end
