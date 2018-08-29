-------------------------------------
-- table LobbyMapFactory
-------------------------------------
LobbyMapFactory = {}

-------------------------------------
-- function createLobbyWorld
-------------------------------------
function LobbyMapFactory:createLobbyWorld(parent_node, ui_lobby)

	self:chcekDayOrNight()

    local lobby_map = LobbyMap(parent_node)
    lobby_map:setContainerSize(1280*3, 960)
    
    lobby_map:addLayer(self:makeLobbyLayer(4), 0.7) -- 하늘
    lobby_map:addLayer(self:makeLobbyLayer(3), 0.8) -- 마을
    lobby_map:addLayer(self:makeLobbyLayer(2), 0.9) -- 분수
	--lobby_map:addLayer(self:makeLobbyDecoLayer('blossom'), 1) -- 벚꽃

	do -- 땅
		local lobby_ground = self:makeLobbyLayer(1)
		lobby_map:addLayer_lobbyGround(lobby_ground, 1, 1, ui_lobby, 'lobby')
		--self:makeLobbyDeco_onLayer(lobby_ground, 'wanted') -- 전단지
	end

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
SKIP_CHECK_DAY_OR_NIGHT = false

-------------------------------------
-- function makeLobbyLayer
-------------------------------------
function LobbyMapFactory:makeLobbyLayer(idx)
    local node = cc.Node:create()
    node:setDockPoint(CENTER_POINT)
    node:setAnchorPoint(CENTER_POINT)

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
		animator:setDockPoint(CENTER_POINT)
		animator:setAnchorPoint(CENTER_POINT)
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
		animator:setDockPoint(CENTER_POINT)
		animator:setAnchorPoint(CENTER_POINT)
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
		animator:setDockPoint(CENTER_POINT)
		animator:setAnchorPoint(CENTER_POINT)
		animator:setPositionX(1280)
		node:addChild(animator.m_node)
	end

    return node
end

-------------------------------------
-- function makeLobbyDecoLayer
-------------------------------------
function LobbyMapFactory:makeLobbyDecoLayer(deco_type)
    local node = cc.Node:create()
    node:setDockPoint(CENTER_POINT)
    node:setAnchorPoint(CENTER_POINT)

    local skip_error_msg = false
	local animator = nil

	local night = ''
	if USE_NIGHT then
		night = '_night'
	end

	-- 벚꽃 나무
	if (deco_type == 'blossom') then
		local full_path = string.format('res/lobby/lobby_season_deco/lobby_blossom%s.png', night)
		animator = MakeAnimator(full_path, skip_error_msg)
		if (animator.m_node) then
			animator:setDockPoint(CENTER_POINT)
			animator:setAnchorPoint(CENTER_POINT)
			animator:setPosition(200, 0)
			node:addChild(animator.m_node)
		end
	end

	return node
end

-------------------------------------
-- function makeLobbyDeco_onLayer
-------------------------------------
function LobbyMapFactory:makeLobbyDeco_onLayer(node, deco_type)
	local night = ''
	if USE_NIGHT then
		night = '_night'
	end

	-- 전단지
	if (deco_type == 'wanted') then
		local full_path = string.format('res/lobby/lobby_season_deco/lobby_wanted%s.png', night)
		animator = MakeAnimator(full_path, skip_error_msg)
		if (animator.m_node) then
			animator:setDockPoint(CENTER_POINT)
			animator:setAnchorPoint(CENTER_POINT)
			animator:setPosition(645, 110)
			animator:setLocalZOrder(1)
			node:addChild(animator.m_node)
		end
	end
end

-------------------------------------
-- function chcekDayOrNight
-- @brief 낮/밤을 체크한다
-------------------------------------
function LobbyMapFactory:chcekDayOrNight()
    if SKIP_CHECK_DAY_OR_NIGHT then
        return
    end

	local curr_time = os.time()
	local date = pl.Date()
	date:set(curr_time)

	local hour = date:hour()

	-- 오전 6시 ~ 오후 6시 사이는 낮
	if (hour > 6) and (hour < 18) then
		USE_NIGHT = false

	-- 밤
	else
		USE_NIGHT = true
	end
end