UILua = {}

-------------------------------------
-- function doAction
-- @breif UILua:doAction() 을 통해서 원하는 node에 정의된 action을 실행
-------------------------------------
function UILua:doAction(node, action_type, param1, param2, delay)
    if (action_type == 'fadeIn') then
        UILua.doFadeIn(node, param1, param2, delay)

    elseif (action_type == 'bounce') then
        UILua.doBounce(node, param1, param2, delay)

    elseif (action_type == 'elastic') then
        UILua.doElastic(node, param1, param2, delay)

	elseif (action_type == 'arrow') then 
		UILua.doArrow(node)
    else
        cclog('##   undefined action type!!')
        UILua.doFadeIn(node, param1, param2, delay)
    end
end

-------------------------------------
-- function doFadeIn
-------------------------------------
function UILua.doFadeIn(node, param1, param2, delay)
    node:setOpacity(0)
    node:runAction(cc.Sequence:create(cc.DelayTime:create(delay * 0.025), cc.FadeIn:create(param2)))
end

-------------------------------------
-- function doBounce
-------------------------------------
function UILua.doBounce(node, param1, param2, delay)
    node:setPositionY(node:getPositionY() + param1)
    local move_action = cc.MoveBy:create(param2, cc.p(0,-param1))
    node:runAction(cc.Sequence:create(cc.DelayTime:create(delay * 0.025), cc.EaseBounceOut:create(move_action)))
end

-------------------------------------
-- function doElastic
-------------------------------------
function UILua.doElastic(node, param1, param2, delay)
    node:setPositionY(node:getPositionY() + param1)
    local move_action = cc.MoveBy:create(param2, cc.p(0,-param1))
    node:runAction(cc.Sequence:create(cc.DelayTime:create(delay * 0.025), cc.EaseElasticOut:create(move_action)))
end

-------------------------------------
-- function doArrow
-------------------------------------
function UILua.doArrow(node)
    
    local move_action = cc.MoveBy:create(param2, cc.p(0,-param1))

	--@TODO

    node:runAction(cc.Sequence:create(cc.DelayTime:create(delay * 0.025), cc.EaseElasticOut:create(move_action)))
end

------------------------------------------------------------------
--[[
local movemnet = 'arrow'
UILua[movemnet](self.vars['arrowSprite'])
]]
------------------------------------------------------------------