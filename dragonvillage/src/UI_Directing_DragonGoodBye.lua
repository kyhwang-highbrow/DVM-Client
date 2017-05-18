local PARENT = UI

-------------------------------------
-- class UI_Directing_DragonGoodBye
-------------------------------------
UI_Directing_DragonGoodBye = class(PARENT,{
		m_bgMap = 'Map',
		m_tamer = 'Animator',
		m_lDragonData = '',
		m_tDragonChar = '',

		m_hasUnFriendlyDragon = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Directing_DragonGoodBye:init(doid_map)
    local vars = self:load('empty.ui')
	UIManager:open(self, UIManager.SCENE)

	self:sceneFadeInAction()

	-- 멤버 변수
	self.m_lDragonData = {}
	self.m_tDragonChar = {}
	self.m_hasUnFriendlyDragon = false

	-- @TEST
	local doid_map = {}
	doid_map[120213] = true
	doid_map[120215] = true
	doid_map[120122] = true
	doid_map[120405] = true

	doid_map[120165] = true
	doid_map[120355] = true
	doid_map[120294] = true
	doid_map[120162] = true

	doid_map[120395] = true
	doid_map[120223] = true

	self:makeDataPretty(doid_map)
    self:initUI()
    self:initButton()
    self:refresh()

	self:doDirectingAction()
end


-------------------------------------
-- function makeDataPretty
-------------------------------------
function UI_Directing_DragonGoodBye:makeDataPretty(doid_map)
	-- doid에서 데이터 순으로 정렬
	for doid, _ in pairs(doid_map) do
		local t_dragon_data = {
			did = doid,
			evolution = 3,
			grade = 5,
			flv = math_random(9)
		}--g_dragonsData:getDragonDataFromUid(doid)
		
		-- 소통 미만의 드래곤인지 체크
		if (t_dragon_data['flv'] < 3) then
			self.m_hasUnFriendlyDragon = true
		end

		table.insert(self.m_lDragonData, t_dragon_data)
	end

	--[[친밀도 순으로 정렬
	table.sort(self.m_lDragonData, function(a, b)
		return a.flv < b.flv
	end)
	--]]
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
	self:initAnimators()
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

local T_POS = 
{
	{600, 200},
	{600, 300},
	{600, 400},
	{600, 500},

	{500, 250},
	{500, 350},
	{500, 450},

	{700, 250},
	{700, 350},
	{700, 450},

	{400, 300},
	{400, 400},

	{800, 300},
	{800, 400},
}

-------------------------------------
-- function initAnimators
-------------------------------------
function UI_Directing_DragonGoodBye:initAnimators()
	local vars = self.vars

	-- 테이머
	do
		local t_tamer = TableTamer():get(110002) -- g_tamerData:getCurrTamerTable('res_sd')
		local dir_tamer = DirectingCharacter(1)
		dir_tamer:initAnimator(t_tamer['res_sd'])
		dir_tamer:initShadow(-110)
		dir_tamer:changeAni('idle', true)
		dir_tamer.m_animator:setFlip(true)
		dir_tamer:setPosition(1100, 350)

		vars['aniNode']:addChild(dir_tamer.m_rootNode)
		
		self.m_tamer = dir_tamer
	end

	-- 드래곤들
	local l_pos = table.getRandomList(T_POS, table.count(self.m_lDragonData))
	for idx, t_dragon_data in pairs(self.m_lDragonData) do
		local did = t_dragon_data['did']
		local doid = did--t_dragon_data['id']
		
		--g_dragonsData:getDragonAnimator(doid)
		
		local evolution = t_dragon_data['evolution']
		local flv = t_dragon_data['flv']
		local scale = 0.5
		local pos = l_pos[idx]

		-- dragon ani 생성
		local dir_dragon = DirectingCharacter(scale, t_dragon_data)
		dir_dragon:initAnimatorDragon(did, evolution)
		dir_dragon:initShadow(-105)
		dir_dragon:setOpacityChildren(true)
		dir_dragon:changeAni('idle', true)
		dir_dragon:setPosition(pos[1], pos[2])

		vars['aniNode']:addChild(dir_dragon.m_rootNode, 500 - pos[2])

		-- map 등록
		self.m_tDragonChar[doid] = dir_dragon
	end
end

-------------------------------------
-- function doDirectingAction
-------------------------------------
function UI_Directing_DragonGoodBye:doDirectingAction()
	local dcnt = table.count(self.m_tDragonChar)

	local idx = 1

	local pre_delay
	local tamer_bye

	local uf_dragon_bye
	local uf_dragon_ascension

	local f_dragon_closing
	local f_dragon_bye
	local f_dragon_ascension

	local goodbye_forever

	-- @temp
	pre_delay = function()
		local delay = cc.DelayTime:create(1)
		local cb_func = cc.CallFunc:create(function()
			tamer_bye()
		end)

		self.root:runAction(cc.Sequence:create(delay, cb_func))
	end

	-- 테이머의 인사
	tamer_bye = function()
		local function cb_func()
			uf_dragon_bye()
		end
		self.m_tamer:actSaying('lactea_tamer', Str('그동안 정말 고생 했어'), 0, cb_func)
	end

	-- 서먹한 드래곤들 중 대표가 인사
	uf_dragon_bye = function()
		-- 소통 미만 드래곤 존재 하지 않는다면 친밀 드래곤으로 보냄
		if not (self.m_hasUnFriendlyDragon) then
			f_dragon_closing()
			return
		end

		for doid, d_char in pairs(self.m_tDragonChar) do
			local t_dragon_data = d_char.m_tData
			if (t_dragon_data['flv'] < 3) then
				local function cb_func()
					uf_dragon_ascension()
				end
				d_char:actSaying('lactea_bye', nil, 0, cb_func)
				break
			end
		end
	end

	-- 서먹한 드래곤들 승천
	uf_dragon_ascension = function()
		-- 서먹한 드래곤 숫자 계산
		local uf_dcnt = 0
		for _, t_dragon_data in pairs(self.m_lDragonData) do
			if (t_dragon_data['flv'] < 3) then
				uf_dcnt = uf_dcnt + 1
			end
		end

		-- 액션
		for doid, d_char in pairs(self.m_tDragonChar) do
			local t_dragon_data = d_char.m_tData
			if (t_dragon_data['flv'] < 3) then
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
			goodbye_forever()
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

		self.m_tamer.m_animator:setFlip(false)
	end

	-- 라테아 획득 연출
	goodbye_forever = function()
		ccdisplay('DONE')
	end

	-- start
	pre_delay()
end

-------------------------------------
-- function doDirectingAction
-------------------------------------
function UI_Directing_DragonGoodBye:checkStep(idx, dcnt, next_func)
	idx = idx + 1
	if (idx > dcnt) then
		idx = 1
		next_func()
	end

	return idx
end