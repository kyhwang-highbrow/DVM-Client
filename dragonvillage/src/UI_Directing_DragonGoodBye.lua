local PARENT = UI

-------------------------------------
-- class UI_Directing_DragonGoodBye
-------------------------------------
UI_Directing_DragonGoodBye = class(PARENT,{
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
	self.vars['tamerNode'] = node

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
end

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
		dir_tamer.m_animator:changeAni('idle', true)
		dir_tamer.m_animator:setFlip(true)

		vars['tamerNode']:addChild(dir_tamer.m_rootNode)
		vars['tamerNode']:setPosition(1100, 350)
		
		self.m_tamer = animator
	end

	-- 드래곤들
	local idx = 1
	for _, t_dragon_data in pairs(self.m_lDragonData) do
		local did = t_dragon_data['did']
		local doid = did--t_dragon_data['id']
		
		--g_dragonsData:getDragonAnimator(doid)
		
		local evolution = t_dragon_data['evolution']
		local flv = t_dragon_data['flv']

		-- dragon ani 생성
		local scale = 0.5
		local dir_dragon = DirectingCharacter(scale)
		dir_dragon:initAnimatorDragon(did, evolution)
		dir_dragon:initShadow(-105)

		local dcnt = table.count(self.m_lDragonData)
		local gap = math_clamp(900/dcnt, 90, 200)
		local start_x = 450 + (gap/2) * dcnt
		local pos_y = 300

		local pos_x = start_x - gap * (idx - 1)
		dir_dragon:setPosition(pos_x, pos_y)
		
		dir_dragon:setPosition(math_random(300, 800), math_random(250, 450))

		dir_dragon:changeAni('idle', true)
		vars['aniNode']:addChild(dir_dragon.m_rootNode)

		-- map 등록
		self.m_tDragonChar[doid] = dir_dragon
		
		-- 줄넘김 처리
		if (pos_x - gap < 0) then
			idx = 1
			pos_y = pos_y + gap
			start_x = start_x - gap/2
		else
			idx = idx + 1
		end
	end
end

-------------------------------------
-- function doDirectingAction
-------------------------------------
function UI_Directing_DragonGoodBye:doDirectingAction()
	local dcnt = table.count(self.m_tDragonChar)

	local idx = 1

	local pre_act
	local walk_act
	local tamer_bye

	local uf_dragon_bye
	local uf_dragon_ascension

	local f_dragon_closing
	local f_dragon_bye
	local f_dragon_ascension

	local goodbye_forever

	-- 사전에 뒤로 보내버림
	pre_act = function()
		for _, d_char in pairs(self.m_tDragonChar) do
			local moveby = cc.MoveBy:create(0.01, cc.p(-1000, 0))
			local delay = cc.DelayTime:create(0.5)
			local cb_func = cc.CallFunc:create(function()
				idx = self:checkStep(idx, dcnt, walk_act)
			end)

			d_char:runAction(cc.Sequence:create(moveby, delay, cb_func))
		end
	end

	-- 화면이 밝아지고 드래곤들이 천천히 걸어나옴
	walk_act = function()
		for _, d_char in pairs(self.m_tDragonChar) do
			local duration = math_random(150, 300)/100
			local moveby = cc.MoveBy:create(duration, cc.p(1000, 0))
			local delay = cc.DelayTime:create(0.5)
			local cb_func = cc.CallFunc:create(function()
				idx = self:checkStep(idx, dcnt, tamer_bye)
			end)

			d_char:runAction(cc.Sequence:create(moveby, delay, cb_func))
		end
	end

	-- @temp
	delay = function()
		local delay = cc.DelayTime:create(1)
		local cb_func = cc.CallFunc:create(function()
			tamer_bye()
		end)

		self.root:runAction(cc.Sequence:create(delay, cb_func))
	end


	-- 테이머의 인사
	tamer_bye = function()
		SensitivityHelper:doActionBubbleText_Extend{
			parent = self.vars['tamerNode'],
			case_type = 'lactea_tamer', 
			custom_str = Str('그동안 정말 고생 했어'), 
			cb_func = function()
				uf_dragon_bye()
			end
		}
	end

	-- 서먹한 드래곤들 중 대표가 인사
	uf_dragon_bye = function()
		-- 소통 미만 드래곤 존재 하지 않는다면 친밀 드래곤으로 보냄
		if not (self.m_hasUnFriendlyDragon) then
			f_dragon_closing()
			return
		end

		local t_dragon_data = self.m_lDragonData[1]
		local d_char = self.m_tDragonChar[t_dragon_data['did']] -- self.m_tDragonChar[t_dragon_data['id']]

		SensitivityHelper:doActionBubbleText_Extend{
			parent = d_char.m_rootNode,
			did = t_dragon_data['did'],
			flv = t_dragon_data['flv'],
			case_type = 'lactea_bye', 
			cb_func = function()
				uf_dragon_ascension()
			end
		}
	end

	-- 서먹한 드래곤들 승천
	uf_dragon_ascension = function()
		-- 서먹한 드래곤 찾기
		local l_doid = {}
		for _, t_dragon_data in pairs(self.m_lDragonData) do
			if (t_dragon_data['flv'] < 3) then
				table.insert(l_doid, t_dragon_data['did']) --t_dragon_data['id']
			end
		end
		
		local dragon_count = #l_doid
		for _, doid in pairs(l_doid) do
			local d_char = self.m_tDragonChar[doid]
			local duration = math_random(200, 300)/100

			local moveby = cc.MoveBy:create(duration, cc.p(0, 1000))
			local fadeout = cc.FadeOut:create(duration)
			local delay = cc.DelayTime:create(0.5)
			local remove_self = cc.RemoveSelf:create()
			local cb_func = cc.CallFunc:create(function()
				self.m_tDragonChar[doid] = nil
				idx = self:checkStep(idx, dragon_count, f_dragon_closing)
			end)

			d_char:runAction(cc.Sequence:create(cc.Spawn:create(moveby, fadeout), delay, remove_self, cb_func))
		end
	end
	
	-- 친한 드래곤들 앞으로 이동
	f_dragon_closing = function()
		dcnt = table.count(self.m_tDragonChar)
		
		-- 드래곤이 남아있지 않다면 탈출
		if (dcnt == 0) then
			goodbye_forever()
		end
		
		for _, d_char in pairs(self.m_tDragonChar) do
			local duration = math_random(200, 250)/100

			local moveby = cc.MoveBy:create(duration, cc.p(100, 0))
			local delay = cc.DelayTime:create(1.5)
			local cb_func = cc.CallFunc:create(function()
				idx = self:checkStep(idx, dcnt, f_dragon_bye)
			end)

			d_char:runAction(cc.Sequence:create(moveby, delay, cb_func))
		end
	end
	
	-- 친한 드래곤들 저마다 한마디씩 인사
	f_dragon_bye = function()
		local pos_idx = 1
		for _, t_dragon_data in pairs(self.m_lDragonData) do
			local doid = t_dragon_data['did']--t_dragon_data['id']

			local d_char = self.m_tDragonChar[doid]
			if (d_char) then
				local delay = cc.DelayTime:create(0.5 * pos_idx)
				local cb_func = cc.CallFunc:create(function()
					SensitivityHelper:doActionBubbleText_Extend{
						parent = d_char.m_rootNode,
						did = t_dragon_data['did'],
						flv = t_dragon_data['flv'],
						case_type = 'lactea_farewell',
						cb_func = function()
							idx = self:checkStep(idx, dcnt, f_dragon_ascension)
						end
					}
				end)

				d_char:runAction(cc.Sequence:create(delay, cb_func))
				pos_idx = pos_idx + 1
			end
		end
	end
	
	-- 친한 드래곤들 승천
	f_dragon_ascension = function()
		for doid, d_char in pairs(self.m_tDragonChar) do
			local duration = math_random(200, 300)/100

			local moveby = cc.MoveBy:create(duration, cc.p(0, 1000))
			local fadeout = cc.FadeOut:create(duration)
			local delay = cc.DelayTime:create(0.5)
			local remove_self = cc.RemoveSelf:create()
			local cb_func = cc.CallFunc:create(function()
				self.m_tDragonChar[doid] = nil
				idx = self:checkStep(idx, dcnt, goodbye_forever)
			end)

			d_char:runAction(cc.Sequence:create(cc.Spawn:create(moveby, fadeout), delay, remove_self, cb_func))
		end

	end

	-- 라테아 획득 연출
	goodbye_forever = function()
		ccdisplay('DONE')
	end

	-- start
	delay()
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