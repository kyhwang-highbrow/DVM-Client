-------------------------------------
-- table LobbyMapFactory
-------------------------------------
LobbyMapFactory = {}

-- 로비 낮/밤 전환용 임시 변수
USE_NIGHT = false
SKIP_CHECK_DAY_OR_NIGHT = false

local LAYER_INFO_LIST = {
	{'left', -1280}, 
	{'center', 0}, 
	{'right', 1280}
}

-------------------------------------
-- function createLobbyWorld
-------------------------------------
function LobbyMapFactory:createLobbyWorld(parent_node, ui_lobby)

	-- 할로윈 밤 고정
	--self:chcekDayOrNight()
	USE_NIGHT = true

    local lobby_map = LobbyMap(parent_node)
    lobby_map:setContainerSize(1280*3, 960)
    
    lobby_map:addLayer(self:makeLobbyLayer(4), 0.7) -- 하늘
    lobby_map:addLayer(self:makeLobbyLayer(3), 0.8) -- 마을
    lobby_map:addLayer(self:makeLobbyLayer(2), 0.9) -- 분수
	--lobby_map:addLayer(self:makeLobbyDecoLayer('blossom'), 1) -- 벚꽃

	do -- 땅
		local lobby_ground = self:makeLobbyLayer(1)
		lobby_map:addLayer_lobbyGround(lobby_ground, 1, 1, ui_lobby)
		
		-- 할로윈 장식
		self:makeLobbyDeco_onLayer(lobby_ground, 'halloween')
	end

	lobby_map:addLayer(self:makeLobbyDecoLayer('halloween'), 1) -- 근경 할로윈 장식
    --lobby_map:addLayer(self:makeLobbyLayer(0), 1) -- 근경

    return lobby_map
end

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

	for _, l_info in ipairs(LAYER_INFO_LIST) do
		local dir = l_info[1]
		local pos_x = l_info[2]
		
		local res_name = string.format('lobby_layer_%.2d_%s%s', idx, dir, night)
		local path = string.format('res/lobby/%s/%s.vrp', res_name, res_name)
		
		if (cc.FileUtils:getInstance():isFileExist(path) == false) then
			path = string.format('res/lobby/%s.png', res_name)
		end

		animator = MakeAnimator(path, skip_error_msg)
		if (animator.m_node) then
			animator:setDockPoint(CENTER_POINT)
			animator:setAnchorPoint(CENTER_POINT)
			animator:setPositionX(pos_x)
			node:addChild(animator.m_node)
		end
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

	-- 할로윈 0번 레이어
	elseif (deco_type == 'halloween') then
		local l_layer_info = {
			{'left', -1280}, {'right', 1280}
		}

		for _, l_info in ipairs(l_layer_info) do
			local name = l_info[1]
			local pos_x = l_info[2]
			local full_path = string.format('res/lobby/lobby_season_deco/halloween/lobby_halloween_00_%s.png', name)
			animator = MakeAnimator(full_path, skip_error_msg)
			if (animator.m_node) then
				animator:setDockPoint(CENTER_POINT)
				animator:setAnchorPoint(CENTER_POINT)
				animator:setPositionX(pos_x)
				node:addChild(animator.m_node)
			end
		end

	end

	return node
end

-------------------------------------
-- function makeLobbyDeco_onLayer
-- @brief 바닥과 테이머 사이에 찍기 위해서 ground_node에 직접 붙임
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
			animator:setPosition(645, 110, 1)
			node:addChild(animator.m_node)
		end
	
	-- 크리스마스 트리
	elseif (deco_type == 'christmas') then
		animator = MakeAnimator('res/lobby/lobby_layer_01_center_tree/lobby_layer_01_center_tree.vrp')
		if (animator.m_node) then
			animator:setDockPoint(CENTER_POINT)
			animator:setAnchorPoint(CENTER_POINT)
			animator:setPosition(235, 145)
			node:addChild(animator.m_node)
		end
		
	-- 1주년 기념
	elseif (deco_type == '1st_annivasary') then
		animator = MakeAnimator('res/lobby/lobby_layer_01_center_cake/lobby_layer_01_center_cake.vrp')
		if (animator.m_node) then
			animator:setPosition(0, 0)
			self.m_tree:changeAni(USE_NIGHT and 'idle_02' or 'idle_01', true)
			node:addChild(animator.m_node)
		end

	-- 할로윈 1번 레이어
	elseif (deco_type == 'halloween') then
		for _, l_info in ipairs(LAYER_INFO_LIST) do
			local name = l_info[1]
			local pos_x = l_info[2]
			local full_path = string.format('res/lobby/lobby_season_deco/halloween/lobby_halloween_01_%s.png', name)
			animator = MakeAnimator(full_path, skip_error_msg)
			if (animator.m_node) then
				animator:setDockPoint(CENTER_POINT)
				animator:setAnchorPoint(CENTER_POINT)
				animator:setPositionX(pos_x)
				node:addChild(animator.m_node)
			end
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