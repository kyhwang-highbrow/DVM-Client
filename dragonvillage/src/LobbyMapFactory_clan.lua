-------------------------------------
-- function createClanLobbyWorld
-------------------------------------
function LobbyMapFactory:createClanLobbyWorld(parent_node, ui_lobby)

	self:chcekDayOrNight()
    g_clanLobbyManager:clearBedRes()

    local lobby_map = LobbyMap(parent_node)
	lobby_map:setContainerSize(1800*2+1200, 960)

	lobby_map:addLayer(self:makeClanLobbyLayer(5), 0.9) -- outdoor 호수 하늘
	lobby_map:addLayer(self:makeClanLobbyLayer(4), 1) -- out&in 땅
	lobby_map:addLayer(self:makeClanLobbyObjectLayer('bed_b'), 1) -- 뒷침대
	lobby_map:addLayer(self:makeClanLobbyLayer(3), 1) -- indoor 뒷침대 덮는 선반 장식
	
	-- ground node 생성
	lobby_map:addLayer_lobbyGround(cc.Node:create(), 1, 1, ui_lobby, 'clan')

	lobby_map:addLayer(self:makeClanLobbyLayer(2), 1) -- indoor 앞 선반 및 지붕
	lobby_map:addLayer(self:makeClanLobbyObjectLayer('bed_f'), 1) -- 앞침대
    lobby_map:addLayer(self:makeClanLobbyLayer(1), 1) -- out&in 근경
	lobby_map:addLayer(self:makeClanLobbyObjectLayer('food'), 1) -- 음식
	lobby_map:addLayer(self:makeClanLobbyLayer(0), 1) -- 창문 불빛

	lobby_map:setZoom(1)
	lobby_map.getGroundRange = function()
		return -2400, 2400, -300, -80
	end
    g_clanLobbyManager:applyBedRes() 

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
	local path = string.format('res/clan_lobby/%s/%s.vrp', res_name, res_name)
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
	local path = string.format('res/clan_lobby/%s/%s.vrp', res_name, res_name)
	if (cc.FileUtils:getInstance():isFileExist(path) == false) then
        path = string.format('res/clan_lobby/%s.png', res_name)
    end
	animator = MakeAnimator(path, skip_error_msg)
	if (animator.m_node) then
		animator:setDockPoint(CENTER_POINT)
		animator:setAnchorPoint(CENTER_POINT)
		animator:setPositionX(300)
		if (res_name == 'clan_lobby_indoor_02_right') then
			animator:setAlpha(0.5)
		end
		node:addChild(animator.m_node)
	end
	
	-- left
	local res_name = string.format('clan_lobby_indoor_%.2d_left', idx)
	local path = string.format('res/clan_lobby/%s/%s.vrp', res_name, res_name)
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
			local animator = MakeAnimator('res/character/tamer/tamer_sleep_l/tamer_sleep_l.spine')
			animator:setPosition(L_BACK_BED[i], 50)
            animator:changeAni('blank', true)
			node:addChild(animator.m_node)
            g_clanLobbyManager:addBedRes(animator)

			local animator = MakeAnimator('res/character/tamer/tamer_sleep_h/tamer_sleep_h.spine')
			animator:setPosition(L_BACK_BED[i], 50)
            animator:changeAni('blank', true)
			node:addChild(animator.m_node)
            g_clanLobbyManager:addBedRes(animator)
		end

	elseif (object_type == 'bed_f') then
		for i = 1, 6 do
			local animator = MakeAnimator('res/character/tamer/tamer_sleep_l/tamer_sleep_l.spine')
			animator:setPosition(L_FRONT_BED[i], -320)
            animator:changeAni('blank', true)
			node:addChild(animator.m_node)
            g_clanLobbyManager:addBedRes(animator)

			local animator = MakeAnimator('res/character/tamer/tamer_sleep_h/tamer_sleep_h.spine')
			animator:setPosition(L_FRONT_BED[i], -320)
            animator:changeAni('blank', true)
			node:addChild(animator.m_node)
            g_clanLobbyManager:addBedRes(animator)
		end

	elseif (object_type == 'food') then
		for _, t_food in ipairs(L_CLAN_LOBBY_FOOD) do
			local animator = MakeAnimator('res/clan_lobby/clan_lobby_indoor_food/clan_lobby_indoor_food.vrp')
			animator:changeAni('smoke_' .. t_food['food'], true)
			animator:setPosition(t_food['x'], -300)
			node:addChild(animator.m_node)
		end
	end

	return node
end