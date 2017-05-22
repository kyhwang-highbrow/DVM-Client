local PARENT = UI

-------------------------------------
-- class UI_Directing_DragonGoodBye
-------------------------------------
UI_Directing_DragonGoodBye = class(PARENT,{
		m_bgMap = 'Map',
		m_tamer = 'Animator',

		m_tDragonChar = '',
		m_lPosList = '',

		m_directingData = 'table',
		m_finalCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Directing_DragonGoodBye:init(doid_map)
    local vars = self:load('empty.ui')

	-- 멤버 변수
	self.m_tDragonChar = {}
	self.m_lPosList = 	{
		{-100, -100},
		
		{-200, -50},
		{-200, -150},
		
		{-300, -50},
		{-300, -150},
		--{-300, -250},
	
		{-400, 0},
		{-400, -100},
		{-400, -200},
		--{-400, -300},
	}

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Directing_DragonGoodBye:initUI()
	-- 배경 노드
	local node = cc.Node:create()
	node:setAnchorPoint(CENTER_POINT)
	node:setDockPoint(CENTER_POINT)
	self.root:addChild(node, 1)
	self.vars['bgNode'] = node

	-- 연출 노드
	local node = cc.Node:create()
	node:setAnchorPoint(CENTER_POINT)
	node:setDockPoint(CENTER_POINT)
	self.root:addChild(node, 2)
	self.vars['aniNode'] = node

	-- 스킵 버튼
	do
	    local node = cc.MenuItemImage:create(EMPTY_PNG, nil, nil, 1)
        node:setDockPoint(cc.p(1, 1))
        node:setAnchorPoint(CENTER_POINT)
        node:setPosition(-96, -26)
		node:setNormalSize(180, 40)
        UIC_Button(node)

        self.root:addChild(node, 3)
        self.vars['skipBtn'] = node
		self.vars['skipBtn']:setVisible(false)

		-- 버튼 라벨
		local label = cc.Label:createWithTTF(Str('건너뛰기'), 'res/font/common_font_01.ttf', 22, 1, cc.size(177, 31), cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER) 
		label:setDockPoint(CENTER_POINT)
        label:setAnchorPoint(CENTER_POINT)
		label:setPosition(-31, 0)
		self.vars['skipBtn']:addChild(label)

		local sprite = cc.Sprite:create('res/ui/icon/skip.png')
		sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
		sprite:setPosition(72, 0)
		self.vars['skipBtn']:addChild(sprite)
	end

	self:initBG()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Directing_DragonGoodBye:initButton()
	self.vars['skipBtn']:registerScriptTapHandler(function() self:goodbye_forever() end)
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
	local res = 'res/bg/ui/dragon_bg_earth/dragon_bg_earth.vrp'
	local animator = MakeAnimator(res)
	self.vars['bgNode']:addChild(animator.m_node)
end

-------------------------------------
-- function initAnimators
-------------------------------------
function UI_Directing_DragonGoodBye:makeTamerChar()
	local res = g_tamerData:getCurrTamerTable('res_sd')
	local dir_tamer = DirectingCharacter(1)
	dir_tamer:initAnimator(res)
	dir_tamer:initShadow(-DirectingCharacter.SHADOW_POS_Y)
	dir_tamer:changeAni('idle', true)
	dir_tamer.m_animator:setFlip(true)

	self.vars['aniNode']:addChild(dir_tamer.m_rootNode)
		
	self.m_tamer = dir_tamer
end

-------------------------------------
-- function makeDragonChar
-------------------------------------
function UI_Directing_DragonGoodBye:makeDragonChar(t_dragon_data)
	local did = t_dragon_data['did']
	local evolution = t_dragon_data['evolution']
	local flv = t_dragon_data:getFlv()
	local scale = 0.5
	local pos = self:getDragonPos()

	-- dragon ani 생성
	local dir_dragon = DirectingCharacter(scale, t_dragon_data)
	dir_dragon:initAnimatorDragon(did, evolution)
	dir_dragon:initShadow(-DirectingCharacter.SHADOW_POS_Y)
	dir_dragon:setOpacityChildren(true)
	dir_dragon:changeAni('idle', true)
	dir_dragon:setPosition(pos[1], pos[2])

	self.vars['aniNode']:addChild(dir_dragon.m_rootNode, 500 - pos[2])

	return dir_dragon
end

-------------------------------------
-- function getDragonPos
-------------------------------------
function UI_Directing_DragonGoodBye:getDragonPos()
	return self.m_lPosList[table.count(self.m_tDragonChar) + 1]
end

-------------------------------------
-- function addDragonData
-------------------------------------
function UI_Directing_DragonGoodBye:addDragonData(doid)
	if (table.count(self.m_tDragonChar) >= table.count(self.m_lPosList)) then
		return
	end

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
	if (not self.m_tDragonChar[doid]) then 
		return
	end

	-- @@ 걸어 나가면서 야호~
	-- 애니 삭제
	local dir_dragon = self.m_tDragonChar[doid]
	dir_dragon.m_rootNode:removeFromParent(true)
	
	-- map 삭제
	self.m_tDragonChar[doid] = nil
end

















-------------------------------------
-- function doDirectingAction
-- @public
-------------------------------------
function UI_Directing_DragonGoodBye:doDirectingAction(t_data, directing_cb_func)
	-- skip 버튼 세팅
	self:activateSkip(true)

	-- 외부 데이터 등록 (스킵 용)
	self.m_directingData = t_data
	self.m_finalCB = directing_cb_func

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
	
	local dragon_gift
	local tamer_walk_out

	local goodbye_forever

	-- 테이머 생성후 걸어서 나옴
	tamer_walk_in = function()
		self:makeTamerChar()
		self.m_tamer:setPosition(800, -200)

		local function cb_func()
			tamer_bye()
		end
		self.m_tamer:actMove(2, cc.p(-600, 0), 1, cb_func)
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
			dragon_gift()
		end
		
		local move_point = cc.p(20, 0)
		local delay = 0
		local function cb_func()
			idx = self:checkStep(idx, dcnt, f_dragon_bye)
		end

		for _, d_char in pairs(self.m_tDragonChar) do
			local duration = math_random(100, 150)/100
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
			local duration = math_random(400, 500)/100
			local function cb_func()
				self.m_tDragonChar[doid] = nil
				idx = self:checkStep(idx, dcnt, dragon_gift)
			end

			d_char:actAscension(duration, cb_func)
		end

		-- 뒤돌아서서 감정에 복받친다
		self.m_tamer.m_animator:setFlip(false)
	end

	-- 드래곤이 선물을 두고간다.
	dragon_gift = function()
		local animator = MakeAnimator('res/ui/a2d/dragon_lactea/dragon_lactea.vrp')
		self.vars['aniNode']:addChild(animator.m_node)
		
		animator:setPosition(0, -300)
		animator:changeAni('lectea_appear', false)
		animator:addAniHandler(function()
			-- 선물 취득 액션
			cca.actGetObject(animator.m_node, cc.p(-100, 500))
			tamer_walk_out()
		end)
	end

	-- tamer가 밖으로 걸어나감 : 친한 드래곤 있을 경우 패스
	tamer_walk_out = function()
		local function cb_func()
			self.m_tamer.m_rootNode:removeFromParent()
			self.m_tamer = nil
		end
		self.m_tamer.m_animator:setFlip(false)
		self.m_tamer:actMove(5, cc.p(600, 0), 0, cb_func)

		goodbye_forever()
	end

	-- 라테아 획득 연출
	goodbye_forever = function()
		self:goodbye_forever()
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

-------------------------------------
-- function delDragonData
-------------------------------------
function UI_Directing_DragonGoodBye:activateSkip(is_activate)
	self.vars['skipBtn']:setVisible(is_activate)

	if (is_activate) then
		g_currScene:pushBackKeyListener(self, function() self:goodbye_forever() end, 'UI_Directing')
	else
		g_currScene:removeBackKeyListener(self)
	end
end

-------------------------------------
-- function checkStep
-------------------------------------
function UI_Directing_DragonGoodBye:goodbye_forever()
	-- 데이터 apply 등 후속 처리
	if (self.m_finalCB) then
		self.m_finalCB()
	end

	-- 화면 정리
	local fadeout = cc.FadeOut:create(1)
	local callback = cc.CallFunc:create(function()
		self.vars['aniNode']:removeAllChildren(true)
	end)
	self.vars['aniNode']:runAction(cc.Sequence:create(fadeout, callback))
	self:activateSkip(false)

	-- 수령 팝업
	local reward_type = self.m_directingData['type']
	local reward_value = self.m_directingData['value']
	UI_ObtainPopup(reward_type, reward_value, Str('하늘 멀리 드래곤이 사라져 갑니다.\n드래곤이 남기고 간 라테아 [{1}]개를 획득했습니다.', reward_value))
end