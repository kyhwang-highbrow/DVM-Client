-------------------------------------
-- class MapManager
-------------------------------------
MapManager = class({
        m_parentNode = 'cc.Node',

        -- 스크롤맵 속도
        m_speed = 'number',
        m_colorScale = '',
    })

-------------------------------------
-- function init
-------------------------------------
function MapManager:init(node)
    self.m_parentNode = node
    self.m_speed = 0
    self.m_colorScale = 100
end


-------------------------------------
-- function update
-------------------------------------
function MapManager:update(dt)
end


-------------------------------------
-- function setSpeed
-------------------------------------
function MapManager:setSpeed(speed)

end

-------------------------------------
-- function applyWaveScript
-------------------------------------
function MapManager:applyWaveScript(script)
end

-------------------------------------
-- function fadeIn
-------------------------------------
function MapManager:fadeIn(r, g, b, duration)
    local function tint(node)
        node:stopAllActions()
        node:runAction( cc.Sequence:create(cc.TintTo:create(0.2, r, g, b), cc.TintTo:create(duration-0.2, self.m_colorR, self.m_colorG, self.m_colorB)))
    end
    doAllChildren(self.m_node, tint)
end

-------------------------------------
-- function tintTo
-------------------------------------
function MapManager:tintTo(r, g, b, duration)
    local function tint(node)
        node:stopAllActions()
        node:runAction( cc.TintTo:create(duration, r, g, b) )
    end
    doAllChildren(self.m_node, tint)
end

-------------------------------------
-- function setColor
-------------------------------------
function MapManager:setColor(r, g, b)
    local function setColor(node)
        node:stopAllActions()
        node:setColor(cc.c3b(r, g, b))
    end
    doAllChildren(self.m_node, setColor)
end
