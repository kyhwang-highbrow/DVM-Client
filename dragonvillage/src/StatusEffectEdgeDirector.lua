-------------------------------------
-- class StatusEffectDirector
-------------------------------------
StatusEffectEdgeDirector = class({
        m_type = 'string',
        m_rootNode = 'cc.Node',
        m_resEdge = 'string',

        m_curCount = 'number',
        m_maxCount = 'number',

        m_lEdgeAnimator = 'table',
        m_lStartPos = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function StatusEffectEdgeDirector:init(type, root_node, res_edge, max_count)
    self.m_type = type
    self.m_rootNode = root_node
    self.m_resEdge = res_edge

    self.m_curCount = 0
    self.m_maxCount = max_count

    self.m_lEdgeAnimator = {}

    self.m_lStartPos = self:makeStartPosList(self.m_type, self.m_maxCount)
end

-------------------------------------
-- function release
-------------------------------------
function StatusEffectEdgeDirector:release()
    for i, animator in ipairs(self.m_lEdgeAnimator) do
        animator:release()
    end

    self.m_curCount = 0
    self.m_lEdgeAnimator = {}
end

-------------------------------------
-- function addEdge
-------------------------------------
function StatusEffectEdgeDirector:addEdge()
    local animator = MakeAnimator(self.m_resEdge)
    if (not animator) then return end

    local new_idx = self.m_curCount + 1
    local pos = self.m_lStartPos[new_idx]
    if (pos) then
        animator:setPosition(pos['x'], pos['y'])
    end
    self.m_rootNode:addChild(animator.m_node)

    table.insert(self.m_lEdgeAnimator, animator)

    self.m_curCount = self.m_curCount + 1
end


-------------------------------------
-- function removeEdge
-------------------------------------
function StatusEffectEdgeDirector:removeEdge()
    if (self.m_curCount <= 0) then return end
    
    local animator = table.remove(self.m_lEdgeAnimator, self.m_curCount)
    if (animator) then
        animator:release()

        self.m_curCount = self.m_curCount - 1
    end
end

-------------------------------------
-- function makeStartPosList
-------------------------------------
function StatusEffectEdgeDirector:makeStartPosList(type, max_count)
    local l_ret = {}

    if (type == 'polygons') then
        local angle_unit = (360 / max_count)
	    local distance = 100

	    -- ��ǥ ���
	    for i = 1, max_count do
		    local angle = angle_unit * (i - 1)
		    local pos = getPointFromAngleAndDistance(angle, distance)
		    table.insert(l_ret, pos)
	    end
    end

    return l_ret
end

-------------------------------------
-- function getEdgePos
-------------------------------------
function StatusEffectEdgeDirector:getEdgePos(idx)
    local pos

    local animator = self.m_lEdgeAnimator[idx]
    if (animator) then
        local x, y = animator:getPosition()
        pos = { x = x, y = y }
    else
        pos = { x = 0, y = 0 }
    end

    return pos
end