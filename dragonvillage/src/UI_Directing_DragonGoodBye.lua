local PARENT = UI

-------------------------------------
-- class UI_Directing_DragonGoodBye
-------------------------------------
UI_Directing_DragonGoodBye = class(PARENT,{
		m_bgMap = 'Map',
		m_tamer = 'Animator',

		m_tDragonChar = '',
		m_lPosList = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Directing_DragonGoodBye:init(doid_map)
    local vars = self:load('empty.ui')

	-- 멤버 변수
	self.m_tDragonChar = {}
	self.m_lPosList = 	{
		{500, 200},
		{500, 300},
		{500, 400},
		{500, 500},

		{400, 250},
		{400, 350},
		{400, 450},

		{600, 250},
		{600, 350},
		{600, 450},

		{300, 300},
		{300, 400},

		{700, 300},
		{700, 400},
	}

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Directing_DragonGoodBye:initUI()
	local node = cc.Node:create()
	self.root:addChild(node, 1)
	self.vars['bgNode'] = node

	local node = cc.Node:create()
	self.root:addChild(node, 2)
	self.vars['aniNode'] = node

	self:initBG()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Directing_DragonGoodBye:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Directing_DragonGoodBye:refresh()
end

-------------------------------------
-- function initBG
-------------------------------------
function UI_Directing_DragonGoodBye:initBG()
	
	local res = 'res/scene/lobby.png'
	local animator = MakeAnimator(res)
	local scr_size = cc.Director:getInstance():getWinSize()
	animator:setAnchorPoint(cc.p(0.5, 0))
	animator:setDockPoint(cc.p(0.5, 0))
	animator:setPosition(scr_size['width']/2 - 250, 0)
	self.vars['bgNode']:addChild(animator.m_node)
	
	--[[
	self.vars['bgNode']:setLocalZOrder(-1)
    local lobby_map = LobbyMap(self.vars['bgNode'])
    self.m_bgMap = lobby_map
    lobby_map:setContainerSize(1280*3, 960)

	local scr_size = cc.Director:getInstance():getWinSize()
    lobby_map:setPosition(scr_size['width']/2 - 250, 0)

    lobby_map:addLayer(UI_Lobby:makeLobbyLayer(4), 0.7) -- 하늘
    lobby_map:addLayer(UI_Lobby:makeLobbyLayer(3), 0.8) -- 마을
    lobby_map:addLayer(UI_Lobby:makeLobbyLayer(2), 0.9) -- 분수

    local lobby_ground = UI_Lobby:makeLobbyLayer(1) -- 땅
    lobby_map:addLayer_lobbyGround(lobby_ground, 1, 1, self)
    lobby_map.m_groudNode = lobby_ground
	--]]
end

-------------------------------------
-- function initAnimators
-------------------------------------
function UI_Directing_DragonGoodBye:makeTamerChar()
	local vars = self.vars

	local res = g_tamerData:getCurrTamerTable('res_sd')
	local dir_tamer = DirectingCharacter(1)
	dir_tamer:initAnimator(res)
	dir_tamer:initShadow(-110)
	dir_tamer:changeAni('idle', true)
	dir_tamer.m_animator:setFlip(true)
	--dir_tamer:setPosition(1100, 350)

	vars['aniNode']:addChild(dir_tamer.m_rootNode)
		
	self.m_tamer = dir_tamer
end

-------------------------------------
-- function makeDragonChar
-------------------------------------
function UI_Directing_DragonGoodBye:makeDragonChar(t_dragon_data)
	local did = t_dragon_data['did']
	local evolution = t_dragon_data['evolution']
	local flv = t_dragon_data:getFlv()--['friendship']['flv']
	local scale = 0.5
	local pos = table.getRandom(self.m_lPosList)

	-- dragon ani 생성
	local dir_dragon = DirectingCharacter(scale, t_dragon_data)
	dir_dragon:initAnimatorDragon(did, evolution)
	dir_dragon:initShadow(-105)
	dir_dragon:setOpacityChildren(true)
	dir_dragon:changeAni('idle', true)
	dir_dragon:setPosition(pos[1], pos[2])

	self.vars['aniNode']:addChild(dir_dragon.m_rootNode, 500 - pos[2])

	return dir_dragon
end

-------------------------------------
-- function addDragonData
-------------------------------------
function UI_Directing_DragonGoodBye:addDragonData(doid)
	-- @@@ 걸어 들어오면서 한마디
	-- 애니 등록
	local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
	local dir_dragon = self:makeDragonChar(t_dragon_data)
	
	-- map 등록
	self.m_tDragonChar[doid] = dir_dragon

	dir_dragon:actSaying('lactea_sorrow', nil, 0, nil)
end

-------------------------------------
-- function delDragonData
-------------------------------------
function UI_Directing_DragonGoodBye:delDragonData(doid)
	-- @@ 걸어 나가면서 야호~
	-- 애니 삭제
	local dir_dragon = self.m_tDragonChar[doid]
	dir_dragon.m_rootNode:removeFromParent(true)
	
	-- map 삭제
	self.m_tDragonChar[doid] = nil
end

















-------------------------------------
-- function doDirectingAction
-------------------------------------
function UI_Directing_DragonGoodBye:doDirectingAction(t_data, directing_cb_func)
	-- 전체 드래곤 숫자
	local dcnt = table.count(self.m_tDragonChar)
	-- 소통 미만의 드래곤 카운트
	local uf_dcnt = 0
	local uf_dragon = nil
	for _, dir_dragon in pairs(self.m_tDragonChar) do
		local t_dragon_data = dir_dragon.m_tData
		if (t_dragon_data:getFlv() < 3) then
			uf_dcnt = uf_dcnt + 1
			if (not uf_dragon) then
				uf_dragon = dir_dragon
			end
		end
	end
	
	-- step 용 idx
	local idx = 1

	-- 함수 선정의
	local tamer_walk_in
	local tamer_bye

	local uf_dragon_bye
	local uf_dragon_ascension

	local f_dragon_closing
	local f_dragon_bye
	local f_dragon_ascension

	local tamer_walk_out

	local goodbye_forever

	-- 테이머 생성후 걸어서 나옴
	tamer_walk_in = function()
		self:makeTamerChar()
		self.m_tamer:setPosition(1500, 350)

		local function cb_func()
			tamer_bye()
		end
		self.m_tamer:actMove(2, cc.p(-400, 0), 1, cb_func)
	end

	-- @@ 걸어나온 후 인사
	-- 테이머의 인사
	tamer_bye = function()
		local function cb_func()
			uf_dragon_bye()
		end
		self.m_tamer:actSaying('lactea_tamer', Str('그동안 정말 고생 했어'), 0, cb_func)
	end

	-- 서먹한 드래곤들 중 대표가 인사
	uf_dragon_bye = function()
		-- 서먹한 드래곤 존재 하지 않는다면 친밀 드래곤으로 보냄
		if (uf_dcnt == 0) then
			f_dragon_closing()
			return
		end

		-- 서먹한 드래곤한테 인사를 시킨다.
		local function cb_func()
			uf_dragon_ascension()
		end
		uf_dragon:actSaying('lactea_bye', nil, 0, cb_func)
	end

	-- 서먹한 드래곤들 승천
	uf_dragon_ascension = function()
		-- 액션
		for doid, d_char in pairs(self.m_tDragonChar) do
			local t_dragon_data = d_char.m_tData
			if (t_dragon_data:getFlv() < 3) then
				local duration = math_random(300, 400)/100
				local function cb_func()
					self.m_tDragonChar[doid] = nil
					idx = self:checkStep(idx, uf_dcnt, f_dragon_closing)
				end

				d_char:actAscension(duration, cb_func)
			end
		end
	end

	-- 친한 드래곤들 앞으로 이동
	f_dragon_closing = function()
		dcnt = table.count(self.m_tDragonChar)
		
		-- 드래곤이 남아있지 않다면 탈출
		if (dcnt == 0) then
			tamer_walk_out()
		end
		
		local move_point = cc.p(100, 0)
		local delay = 0
		local function cb_func()
			idx = self:checkStep(idx, dcnt, f_dragon_bye)
		end

		for _, d_char in pairs(self.m_tDragonChar) do
			local duration = math_random(200, 250)/100
			d_char:actMove(duration, move_point, delay, cb_func)
		end
	end
	
	-- 친한 드래곤들 저마다 한마디씩 인사
	f_dragon_bye = function()
		local case_type = 'lactea_farewell'
		local function cb_func()
			idx = self:checkStep(idx, dcnt, f_dragon_ascension)
		end

		local pos_idx = 1
		for _, d_char in pairs(self.m_tDragonChar) do
			local delay = 0.5 * pos_idx
			d_char:actSaying(case_type, nil, delay, cb_func)
			d_char:actPose()

			pos_idx = pos_idx + 1
		end
	end
	
	-- 친한 드래곤들 승천
	f_dragon_ascension = function()
		for doid, d_char in pairs(self.m_tDragonChar) do
			local duration = math_random(700, 1000)/100
			local function cb_func()
				self.m_tDragonChar[doid] = nil
				idx = self:checkStep(idx, dcnt, f_dragon_closing)
			end

			d_char:actAscension(duration, cb_func)
		end

		-- 테이머는 뒤돌아서서 화면 밖으로..
		local function cb_func()
			self.m_tamer.m_rootNode:removeFromParent()
			self.m_tamer = nil
		end
		self.m_tamer.m_animator:setFlip(false)
		self.m_tamer:actMove(5, cc.p(1500, 350), 5, cb_func)
	end

	-- tamer가 밖으로 걸어나감 : 친한 드래곤 있을 경우 패스
	tamer_walk_out = function()
		local function cb_func()
			self.m_tamer.m_rootNode:removeFromParent()
			self.m_tamer = nil
		end
		self.m_tamer.m_animator:setFlip(false)
		self.m_tamer:actMove(5, cc.p(400, 0), 5, cb_func)

		goodbye_forever()
	end

	-- 라테아 획득 연출
	goodbye_forever = function()
		if (directing_cb_func) then
			directing_cb_func()
		end



		local reward_type = t_data['type']
		local reward_value = t_data['value']
		UI_ObtainPopup(reward_type, reward_value, Str('하늘 멀리 드래곤이 사라져 갑니다.\n드래곤이 남기고 간 라테아 [{1}]개를 획득했습니다.', reward_value))
	end

	-- start
	tamer_walk_in()
end

-------------------------------------
-- function checkStep
-------------------------------------
function UI_Directing_DragonGoodBye:checkStep(idx, dcnt, next_func)
	idx = idx + 1
	if (idx > dcnt) then
		idx = 1
		next_func()
	end

	return idx
end