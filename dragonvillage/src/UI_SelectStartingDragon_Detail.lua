local PARENT = class(UI,  ITabUI:getCloneTable())

-------------------------------------
-- class UI_SelectStartingDragon_Detail
-------------------------------------
UI_SelectStartingDragon_Detail = class(PARENT,{
		m_selectIdx = 'number',
		m_makeAccountFunc = 'func',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SelectStartingDragon_Detail:init(idx, make_account_func)
    local vars = self:load('account_create_02.ui')
    UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SelectStartingDragon_Detail')

	self.m_selectIdx = idx
	self.m_makeAccountFunc = make_account_func

    -- 씬 전환 효과
    self:sceneFadeInAction()

	self:initUI()
    self:initButton()
	self:initTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SelectStartingDragon_Detail:initUI()
    local vars = self.vars

	-- 리소스 미리 생성
	local l_starting_data = UI_SelectStartingDragon.getStartingData()
	for i, t_data in pairs(l_starting_data) do
		UI_SelectStartingDragon.setDragonAni(vars, i, t_data['did'])
		self:setTamerAni(i, t_data['tid'])
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SelectStartingDragon_Detail:initButton()
    local vars = self.vars

	-- 스킬 버튼 등록
	local l_starting_data = UI_SelectStartingDragon.getStartingData()
	for i, t_data in pairs(l_starting_data) do
		vars['skillBtn' .. i]:registerScriptTapHandler(function() self:click_skillBtn(t_data['did']) end)
	end

	-- 닉네임 입력으로 ~
    vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end)

	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_SelectStartingDragon_Detail:initTab()
    local vars = self.vars

	local l_starting_data = UI_SelectStartingDragon.getStartingData()
	for i, _ in pairs(l_starting_data) do
		self:addTab(i, vars['dragonBtn' .. i], vars['dragonMenu' .. i])
	end
	self:setTab(self.m_selectIdx)
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end	

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_SelectStartingDragon_Detail:onChangeTab(tab, first)
    -- 탭할때마다 액션 
    self:doActionReset()
    self:doAction(nil, false)

	self.m_selectIdx = tab
end

-------------------------------------
-- function setTamerAni
-------------------------------------
function UI_SelectStartingDragon_Detail:setTamerAni(idx, tid)
    local vars = self.vars
    local t_tamer = TableTamer():get(tid)
    local ani_tamer = AnimatorHelper:makeTamerAnimator(t_tamer['res'])
    vars['tamerNode' .. idx]:removeAllChildren()
	vars['tamerNode' .. idx]:addChild(ani_tamer.m_node)
end

-------------------------------------
-- function setSkillIcon
-------------------------------------
function UI_SelectStartingDragon_Detail:click_skillBtn(did)
	local t_data = {
		['did'] = did,
		['lv'] = 1,
		['evolution'] = 3,
		['grade'] = 6,
		['exp'] = 0,
		['skill_0'] = 1,
		['skill_1'] = 1,
		['skill_2'] = 1,
		['skill_3'] = 1
	}
    local t_dragon_data = StructDragonObject(t_data)
    UI_SkillDetailPopup(t_dragon_data, 1)
end

-------------------------------------
-- function click_selectBtn
-- @brief 드래곤 선택
-------------------------------------
function UI_SelectStartingDragon_Detail:click_selectBtn()
    UI_SelectNickname(self.m_selectIdx, self.m_makeAccountFunc)
end
