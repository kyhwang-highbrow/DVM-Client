local PARENT = UIC_Node

-------------------------------------
-- class UIC_ClippingNode
-------------------------------------
UIC_ClippingNode = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_ClippingNode:init(node)
end

-------------------------------------
-- function setNormalSize
-------------------------------------
function UIC_ClippingNode:setNormalSize(width, height)
    local node = self.m_node

    -- Node의 setNormalSize를 호출
    node:setNormalSize(width, height)

    -- stencil의 사이즈를 normal size로 변경
    local stencil = node:getStencil()
    stencil:clear()
    local rectangle = {}
	local white = cc.c4b(1,1,1,1)
	table.insert(rectangle, cc.p(0, 0))
	table.insert(rectangle, cc.p(width or 0, 0))
	table.insert(rectangle, cc.p(width or 0, height or 0))
	table.insert(rectangle, cc.p(0,height or 0))
	stencil:drawPolygon(
			rectangle
			, 4
			, white
			, 1
			, white
	)
    
    -- 자식 node들의 transform을 update(dockpoint의 영향이 있을수 있으므로)
    node:setUpdateChildrenTransform()
end