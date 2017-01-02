-------------------------------------
-- class SimplePrimitivesDraw
-------------------------------------
SimplePrimitivesDraw = class({
        m_radius = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SimplePrimitivesDraw:init(parent, x, y, radius)
    self.m_radius = radius

    local glNode = cc.GLNode:create()
    glNode:setOpacity(127)
	glNode:setAnchorPoint(cc.p(0.5, 0.5))
	glNode:setDockPoint(cc.p(0.5, 0.5))
    glNode:setPosition(x, y)
    parent:addChild(glNode)

    local function primitivesDraw(transform, transformUpdated)
        self:primitivesDraw(transform, transformUpdated)
    end
    glNode:registerScriptDrawHandler(primitivesDraw)
end

-------------------------------------
-- function primitivesDraw
-------------------------------------
function SimplePrimitivesDraw:primitivesDraw(transform, transformUpdated)
    kmGLPushMatrix()
    kmGLLoadMatrix(transform)
    
    --gl.lineWidth(1)
    --ccDrawColor4B(255, 0, 255, 127)
    cc.DrawPrimitives.drawColor4B(255, 0, 255, 127)

    ccDrawSolidCircle(cc.p(0, 0), self.m_radius, 0, 32)

    gl.lineWidth(1)
    cc.DrawPrimitives.drawColor4B(255, 255, 255, 255)
    cc.DrawPrimitives.setPointSize(1)

    kmGLPopMatrix()
end
