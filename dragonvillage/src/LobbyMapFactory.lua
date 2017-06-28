-------------------------------------
-- table LobbyMapFactory
-------------------------------------
LobbyMapFactory = {}

-------------------------------------
-- function createLobbyWorld
-------------------------------------
function LobbyMapFactory:createLobbyWorld(parent_node, ui_lobby)

    local lobby_map = LobbyMap(parent_node)
    self.m_lobbyMap = lobby_map
    lobby_map:setContainerSize(1280*3, 960)
    
    lobby_map:addLayer(self:makeLobbyLayer(4), 0.7) -- 하늘
    lobby_map:addLayer(self:makeLobbyLayer(3), 0.8) -- 마을
    lobby_map:addLayer(self:makeLobbyLayer(2), 0.9) -- 분수

    local lobby_ground = self:makeLobbyLayer(1) -- 땅

    lobby_map:addLayer_lobbyGround(lobby_ground, 1, 1, ui_lobby)
    lobby_map.m_groudNode = lobby_ground

    lobby_map:addLayer(self:makeLobbyLayer(0), 1) -- 근경

    --[[
    lobby_map:setMoveStartCB(function()
        self:doActionReverse()
        g_topUserInfo:doActionReverse()
    end)

    lobby_map:setMoveEndCB(function()
        self:doAction(nil, nil, 0.5)
        g_topUserInfo:doAction(nil, nil, 0.5)
    end)
    --]]

    return lobby_map
end

-------------------------------------
-- function makeLobbyLayer
-------------------------------------
function LobbyMapFactory:makeLobbyLayer(idx)
    local node = cc.Node:create()
    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))

    local skip_error_msg = true
	local animator = nil
	
	local res_name = string.format('res/lobby/lobby_layer_%.2d_left/lobby_layer_%.2d_left.vrp', idx, idx)
	if (cc.FileUtils:getInstance():isFileExist(res_name)) then
		animator = MakeAnimator(res_name, skip_error_msg)
    else
        animator = MakeAnimator(string.format('res/lobby/lobby_layer_%.2d_left.png', idx))
    end
    animator:setDockPoint(cc.p(0.5, 0.5))
    animator:setAnchorPoint(cc.p(0.5, 0.5))
    animator:setPositionX(-1280)
    node:addChild(animator.m_node)

	local res_name = string.format('res/lobby/lobby_layer_%.2d_center/lobby_layer_%.2d_center.vrp', idx, idx)
	if (cc.FileUtils:getInstance():isFileExist(res_name)) then
		animator = MakeAnimator(res_name, skip_error_msg)
    else
        animator = MakeAnimator(string.format('res/lobby/lobby_layer_%.2d_center.png', idx))
    end
    animator:setDockPoint(cc.p(0.5, 0.5))
    animator:setAnchorPoint(cc.p(0.5, 0.5))
    node:addChild(animator.m_node)

	local res_name = string.format('res/lobby/lobby_layer_%.2d_right/lobby_layer_%.2d_right.vrp', idx, idx)
	if (cc.FileUtils:getInstance():isFileExist(res_name)) then
		animator = MakeAnimator(res_name, skip_error_msg)
	else
        animator = MakeAnimator(string.format('res/lobby/lobby_layer_%.2d_right.png', idx))
    end
    animator:setDockPoint(cc.p(0.5, 0.5))
    animator:setAnchorPoint(cc.p(0.5, 0.5))
    animator:setPositionX(1280)
    node:addChild(animator.m_node)

    return node
end