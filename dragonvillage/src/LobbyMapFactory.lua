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

-- 로비 낮/밤 전환용 임시 변수
USE_NIGHT = false

-------------------------------------
-- function makeLobbyLayer
-------------------------------------
function LobbyMapFactory:makeLobbyLayer(idx)
    local node = cc.Node:create()
    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))

    local skip_error_msg = true
	local animator = nil

	local night = ''
	if USE_NIGHT then
		night = '_night'
	end

	-- 1. vrp를 먼저 찾고
	-- 2. 없으면 png를 찾는다
	-- 3. png도 없다면 불러오지 않는다

	-- left
	local res_name = string.format('lobby_layer_%.2d_left%s', idx, night)
	local path = string.format('res/lobby/%s/%s.vrp', res_name, res_name)
	if (cc.FileUtils:getInstance():isFileExist(path) == false) then
        path = string.format('res/lobby/%s.png', res_name)
    end
	animator = MakeAnimator(path, skip_error_msg)
	if (animator.m_node) then
		animator:setDockPoint(cc.p(0.5, 0.5))
		animator:setAnchorPoint(cc.p(0.5, 0.5))
		animator:setPositionX(-1280)
		node:addChild(animator.m_node)
	end

	-- center
	local res_name = string.format('lobby_layer_%.2d_center%s', idx, night)
	local path = string.format('res/lobby/%s/%s.vrp', res_name, res_name)
	if (cc.FileUtils:getInstance():isFileExist(path) == false) then
        path = string.format('res/lobby/%s.png', res_name)
    end
	animator = MakeAnimator(path, skip_error_msg)
	if (animator.m_node) then
		animator:setDockPoint(cc.p(0.5, 0.5))
		animator:setAnchorPoint(cc.p(0.5, 0.5))
		node:addChild(animator.m_node)
	end

	-- right
	local res_name = string.format('lobby_layer_%.2d_right%s', idx, night)
	local path = string.format('res/lobby/%s/%s.vrp', res_name, res_name)
	if (cc.FileUtils:getInstance():isFileExist(path) == false) then
        path = string.format('res/lobby/%s.png', res_name)
    end
	animator = MakeAnimator(path, skip_error_msg)
	if (animator.m_node) then
		animator:setDockPoint(cc.p(0.5, 0.5))
		animator:setAnchorPoint(cc.p(0.5, 0.5))
		animator:setPositionX(1280)
		node:addChild(animator.m_node)
	end

    return node
end