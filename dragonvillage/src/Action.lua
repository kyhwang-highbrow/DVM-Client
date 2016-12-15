cca = {}

-------------------------------------
-- function widthTo
-- @param node
-- @param duration  지속 시간
-- @param width     변경할 width
-------------------------------------
function cca.widthTo(node, duration, width)
    local curr_width, curr_height = node:getNormalSize()

    local func = function(value)
        node:setNormalSize(value, curr_height)
    end

    local tween = cc.ActionTweenForLua:create(duration, curr_width, width, func)
    return tween
end


-------------------------------------
-- function runAction
-- @brief 액션을 실행
-------------------------------------
function cca.runAction(node, action, stop_action)
    -- 모든 Action을 중지할 경우
    if (stop_action == true) then
        node:stopAllActions()
    end

    -- 특정 Tag의 Action을 중지할 경우
    local tag = nil
    if (type(stop_action) == 'number') then
        local _action = node:getActionByTag(stop_action)
        if _action then
            node:stopAction(_action)
        end
        tag = stop_action
    end

    if tag then
        action:setTag(tag)
    end

    node:runAction(action)
end