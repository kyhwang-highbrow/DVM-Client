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
    self.m_lobbyMap = lobby_map
    lobby_map:setContainerSize(1280*3, 960)
    
    lobby_map:addLayer(self:makeLobbyLayer(4), 0.7) -- 하늘
    lobby_map:addLayer(self:makeLobbyLayer(3), 0.8) -- 마을
    lobby_map:addLayer(self:makeLobbyLayer(2), 0.9) -- 분수
	lobby_map:addLayer(self:makeLobbyDecoLayer('blossom'), 1) -- 벚꽃

	do -- 땅
		local lobby_ground = self:makeLobbyLayer(1)
		lobby_map:addLayer_lobbyGround(lobby_ground, 1, 1, ui_lobby)
		self:makeLobbyDeco_onLayer(lobby_ground, 'wanted') -- 전단지
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


-------------------------------------
-- function createClanLobbyWorld
-------------------------------------
function LobbyMapFactory:createClanLobbyWorld(parent_node, ui_lobby)

	self:chcekDayOrNight()

    local lobby_map = LobbyMap(parent_node)
    self.m_lobbyMap = lobby_map
	lobby_map:setContainerSize(1800*2+1200, 960)

	lobby_map:addLayer(self:makeClanLobbyLayer(5), 0.9) -- outdoor 호수 하늘
	lobby_map:addLayer(self:makeClanLobbyLayer(4), 1) -- out&in 땅
	lobby_map:addLayer(self:makeClanLobbyObjectLayer('bed_b'), 1) -- 뒷침대
	lobby_map:addLayer(self:makeClanLobbyLayer(3), 1) -- indoor 뒷침대 덮는 선반 장식
	
	-- ground node 생성
	lobby_map:addLayer_lobbyGround(cc.Node:create(), 1, 1, ui_lobby)

	lobby_map:addLayer(self:makeClanLobbyLayer(2), 1) -- indoor 앞 선반 및 지붕
	lobby_map:addLayer(self:makeClanLobbyObjectLayer('bed_f'), 1) -- 앞침대
    lobby_map:addLayer(self:makeClanLobbyLayer(1), 1) -- out&in 근경
	lobby_map:addLayer(self:makeClanLobbyObjectLayer('food'), 1) -- 음식
	lobby_map:addLayer(self:makeClanLobbyLayer(0), 1) -- 창문 불빛

	lobby_map:setZoom(1)
	lobby_map.getGroundRange = function()
		return -2400, 2400, -300, -80
	end

    return lobby_map
end

-------------------------------------
-- function makeClanLobbyLayer
-------------------------------------
function LobbyMapFactory:makeClanLobbyLayer(idx)
    local node = cc.Node:create()
    node:setDockPoint(CENTER_POINT)
    node:setAnchorPoint(CENTER_POINT)

    local skip_error_msg = true
	local animator = nil
	
	-- 1. vrp를 먼저 찾고
	-- 2. 없으면 png를 찾는다
	-- 3. png도 없다면 불러오지 않는다
	
	-- outdoor
	local res_name = string.format('clan_lobby_outdoor_%.2d', idx)
	local path = string.format('res/clan_lobby/%s/%s.a2d', res_name, res_name)
	if (cc.FileUtils:getInstance():isFileExist(path) == false) then
		path = string.format('res/clan_lobby/%s.png', res_name)
	end
	animator = MakeAnimator(path, skip_error_msg)
	if (animator.m_node) then
		animator:setDockPoint(CENTER_POINT)
		animator:setAnchorPoint(CENTER_POINT)
		animator:setPositionX(1600)
		node:addChild(animator.m_node)
		if (USE_NIGHT) then
			animator:changeAni('idle_night', true)
		end
	end
	
	-- right
	local res_name = string.format('clan_lobby_indoor_%.2d_right', idx)
	local path = string.format('res/clan_lobby/%s/%s.a2d', res_name, res_name)
	if (cc.FileUtils:getInstance():isFileExist(path) == false) then
        path = string.format('res/clan_lobby/%s.png', res_name)
    end
	animator = MakeAnimator(path, skip_error_msg)
	if (animator.m_node) then
		animator:setDockPoint(CENTER_POINT)
		animator:setAnchorPoint(CENTER_POINT)
		animator:setPositionX(300)
		if (res_name == 'clan_lobby_indoor_02_right') then
			--animator:setAlpha(0.5)
		end
		node:addChild(animator.m_node)
	end
	
	-- left
	local res_name = string.format('clan_lobby_indoor_%.2d_left', idx)
	local path = string.format('res/clan_lobby/%s/%s.a2d', res_name, res_name)
	if (cc.FileUtils:getInstance():isFileExist(path) == false) then
		path = string.format('res/clan_lobby/%s.png', res_name)
	end
	animator = MakeAnimator(path, skip_error_msg)
	if (animator.m_node) then
		animator:setDockPoint(CENTER_POINT)
		animator:setAnchorPoint(CENTER_POINT)
		if (res_name == 'clan_lobby_indoor_01_left') then
			animator:setPositionX(-950)
		else
			animator:setPositionX(-1500)
		end
		node:addChild(animator.m_node)
	end
		
    return node
end

local L_CLAN_LOBBY_FOOD = {
	{
		['food'] = 'omelet',
		['x'] = -270 
	},
	{
		['food'] = 'sashimi',
		['x'] = -110 
	},
	{
		['food'] = 'spaghetti',
		['x'] = 60
	},
	{
		['food'] = 'steak',
		['x'] = 220 
	}
}
local L_BACK_BED = {
	-1220,
	-1480,
	-1740,
	-2200,
}
local L_FRONT_BED = {
	-860,
	-860 - 260,
	-860 - 520,

	-1800,
	-1800 - 260,
	-1800 - 520 ,
}
-------------------------------------
-- function makeClanLobbyObjectLayer
-------------------------------------
function LobbyMapFactory:makeClanLobbyObjectLayer(object_type)
    local node = cc.Node:create()
    node:setDockPoint(CENTER_POINT)
    node:setAnchorPoint(CENTER_POINT)

	if (object_type == 'bed_b') then
		for i = 1, 4 do
			local animator = MakeAnimator('res/character/tamer/durun_sleep/durun_sleep_l.spine')
			animator:setPosition(L_BACK_BED[i], 50)
			node:addChild(animator.m_node)

			local animator = MakeAnimator('res/character/tamer/dede_sleep/dede_sleep_h.spine')
			animator:setPosition(L_BACK_BED[i], 50)
			node:addChild(animator.m_node)
		end

	elseif (object_type == 'bed_f') then
		for i = 1, 6 do
			local animator = MakeAnimator('res/character/tamer/dede_sleep/dede_sleep_l.spine')
			animator:setPosition(L_FRONT_BED[i], -320)
			node:addChild(animator.m_node)

			local animator = MakeAnimator('res/character/tamer/durun_sleep/durun_sleep_h.spine')
			animator:setPosition(L_FRONT_BED[i], -320)
			node:addChild(animator.m_node)
		end

	elseif (object_type == 'food') then
		for _, t_food in ipairs(L_CLAN_LOBBY_FOOD) do
			local animator = MakeAnimator('res/clan_lobby/clan_lobby_indoor_food/clan_lobby_indoor_food.a2d')
			animator:changeAni('smoke_' .. t_food['food'], true)
			animator:setPosition(t_food['x'], -300)
			node:addChild(animator.m_node)
		end
	end

	return node
end