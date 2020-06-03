local PARENT = class(UI,  ITabUI:getCloneTable())

-------------------------------------
-- class UI_StartingTamer
-------------------------------------
UI_StartingTamer = class(PARENT,{
		m_selectIdx = 'number',
		m_makeAccountFunc = 'func',
        m_workListHelper = 'WorkListHelper',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_StartingTamer:init(idx, make_account_func)
    local vars = self:load('starting_tamer_scene.ui')
    UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_StartingTamer')

	self.m_selectIdx = idx
	self.m_makeAccountFunc = make_account_func

    -- 씬 전환 효과
    self:sceneFadeInAction()

	self:initUI()
    self:initButton()
	--self:initTab()

    self:setTamerRes(1, 110001)
    self:setTamerRes(2, 110002)
    self:setTamerRes(3, 110003)
    self:setTamerRes(4, 110004)
    self:setTamerRes(5, 110005)

    self:initWorkListHelper()

    -- 탭할때마다 액션 
    --self:doActionReset()
    --self:doAction(nil, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StartingTamer:initUI()
    local vars = self.vars

    self:setTamerAni(1, 110001)
    self:setTamerAni(2, 110002)

    --[[
	-- 리소스 미리 생성
	local l_starting_data = UI_SelectStartingDragon.getStartingData()
	for i, t_data in pairs(l_starting_data) do
		UI_SelectStartingDragon.setDragonAni(vars, i, t_data['did'])
		self:setTamerAni(i, t_data['tid'])
	end
    --]]
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_StartingTamer:initButton()
    local vars = self.vars

    --[[
	-- 스킬 버튼 등록
	local l_starting_data = UI_SelectStartingDragon.getStartingData()
	for i, t_data in pairs(l_starting_data) do
		for _, j in ipairs(IDragonSkillManager:getSkillKeyList()) do
			local node_name = string.format('skillBtn_%d_%s', i, j)
			local btn = vars[node_name]
			if (btn) then
				btn:registerScriptTapHandler(function() self:click_skillBtn(t_data['did'], j, btn) end)
			end
		end
	end

	-- 닉네임 입력으로 ~
    vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end)

	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    --]]
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_StartingTamer:initTab()
    local vars = self.vars

    self:addTab(1, vars['dragonBtn1'], vars['dragonMenu1'])
    self:addTab(2, vars['dragonBtn2'], vars['dragonMenu2'])
    self:setTab(1)
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)

    --[[
	local l_starting_data = UI_SelectStartingDragon.getStartingData()
	for i, _ in pairs(l_starting_data) do
		self:addTab(i, vars['dragonBtn' .. i], vars['dragonMenu' .. i])
	end
	self:setTab(self.m_selectIdx)
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
    --]]
end	

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_StartingTamer:onChangeTab(tab, first)
    -- 탭할때마다 액션 
    self:doActionReset()
    self:doAction(nil, false)

	self.m_selectIdx = tab
end

-------------------------------------
-- function initWorkListHelper
-------------------------------------
function UI_StartingTamer:initWorkListHelper()
    self.m_workListHelper = WorkListHelper()

    --self:addWork_tamer1()
    self:addWork_checkStartPos()
    --self:addWork_tamer2()
    --self:addWork_tamerFinish()

    self.m_workListHelper:doNextWork()
end

-------------------------------------
-- function addWork_checkStartPos
-------------------------------------
function UI_StartingTamer:addWork_checkStartPos()
    local name = 'tamer_start_position'
    local vars = self.vars

    local function func_enter()

        local l_tamer_start_pos = {}
        l_tamer_start_pos[1] = cc.p(-500, 0)
        l_tamer_start_pos[2] = cc.p(-250, 0)
        l_tamer_start_pos[3] = cc.p(0, 0)
        l_tamer_start_pos[4] = cc.p(250, 0)
        l_tamer_start_pos[5] = cc.p(500, 0)

        for i=1, 5 do
            vars['tamerNode0' .. i]:setScale(1)
            vars['tamerNode0' .. i]:setVisible(true)

            local pos = l_tamer_start_pos[i]
            vars['tamerNode0' .. i]:setPosition(pos.x, pos.y)
        end
    end
    local func_work = nil
    local func_exit = nil

    self.m_workListHelper:addWork(name, func_enter, funk_work, func_exit)
end


-------------------------------------
-- function addWork_tamer1
-------------------------------------
function UI_StartingTamer:addWork_tamer1()
    local vars = self.vars

    local name = 'tamer1'

    local function func_enter()
        vars['tamerNode01']:setVisible(true)
        vars['tamerNode02']:setVisible(false)
        vars['tamerNode03']:setVisible(false)
        vars['tamerNode04']:setVisible(false)
        vars['tamerNode05']:setVisible(false)

        vars['tamerNode01']:setPosition(0, -960)        
    end

    local function funk_work()
        local func_action
        local func_next

        func_action = function()
            local action = cc.Sequence:create(cc.EaseInOut:create(cc.MoveTo:create(0.3, cc.p(0, 0)), 2), cc.CallFunc:create(func_next))
            vars['tamerNode01']:runAction(action)
        end

        func_next = function()
            self.m_workListHelper:doNextWork()
        end
       
        func_action() 
    end
    
    local function func_exit()
    end

    self.m_workListHelper:addWork(name, func_enter, funk_work, func_exit)
end

-------------------------------------
-- function addWork_tamer2
-------------------------------------
function UI_StartingTamer:addWork_tamer2()
    local vars = self.vars

    local l_finish_pos = {}
    l_finish_pos[1] = cc.p(-500, 200)
    l_finish_pos[2] = cc.p(-250, 200)
    l_finish_pos[3] = cc.p(0, 200)
    l_finish_pos[4] = cc.p(250, 200)
    l_finish_pos[5] = cc.p(500, 200)

    for i=1, 5 do
        local name = 'tamer' .. i

        vars['tamerNode0' .. i]:setScale(0.9)

        local function func_enter()
            vars['tamerNode01']:setVisible(1 <= i)
            vars['tamerNode02']:setVisible(2 <= i)
            vars['tamerNode03']:setVisible(3 <= i)
            vars['tamerNode04']:setVisible(4 <= i)
            vars['tamerNode05']:setVisible(5 <= i)

            vars['tamerNode01']:setPosition(l_finish_pos[1].x, conditionalOperator(1 == i, -960, l_finish_pos[1].y))
            vars['tamerNode02']:setPosition(l_finish_pos[2].x, conditionalOperator(2 == i, -960, l_finish_pos[2].y))
            vars['tamerNode03']:setPosition(l_finish_pos[3].x, conditionalOperator(3 == i, -960, l_finish_pos[3].y))
            vars['tamerNode04']:setPosition(l_finish_pos[4].x, conditionalOperator(4 == i, -960, l_finish_pos[4].y))
            vars['tamerNode05']:setPosition(l_finish_pos[5].x, conditionalOperator(5 == i, -960, l_finish_pos[5].y))
        end

        local function funk_work()
            local func_action
            local func_next

            func_action = function()
                local action = cc.Sequence:create(cc.EaseInOut:create(cc.MoveTo:create(0.3, l_finish_pos[i]), 2), cc.CallFunc:create(func_next))
                vars['tamerNode0' .. i]:runAction(action)
            end

            func_next = function()
                self.m_workListHelper:doNextWork()
            end
       
            func_action() 
        end
    
        local function func_exit()
        end

        self.m_workListHelper:addWork(name, func_enter, funk_work, func_exit)
    end
end

-------------------------------------
-- function addWork_tamerFinish
-------------------------------------
function UI_StartingTamer:addWork_tamerFinish()
    local vars = self.vars


    local name = 'tamerFinish'

    local function func_enter()
        vars['tamerNode01']:setVisible(true)
        vars['tamerNode02']:setVisible(true)
        vars['tamerNode03']:setVisible(true)
        vars['tamerNode04']:setVisible(true)
        vars['tamerNode05']:setVisible(true)

        vars['tamerNode01']:stopAllActions()
        vars['tamerNode02']:stopAllActions()
        vars['tamerNode03']:stopAllActions()
        vars['tamerNode04']:stopAllActions()
        vars['tamerNode05']:stopAllActions()
    end

    local function funk_work()

        local l_finish_pos = {}
        l_finish_pos[1] = cc.p(-500, 100)
        l_finish_pos[2] = cc.p(-200, 100)
        l_finish_pos[3] = cc.p(0, 100)
        l_finish_pos[4] = cc.p(150, 100)
        l_finish_pos[5] = cc.p(350, 100)

        local scale = 0.6

        for i=2, 5 do
            local action = cc.Sequence:create(cc.EaseInOut:create(cc.ScaleTo:create(0.3, scale), 2))
            vars['tamerNode0' .. i]:runAction(action)

            local action = cc.Sequence:create(cc.EaseInOut:create(cc.MoveTo:create(0.3, l_finish_pos[i]), 2))
            vars['tamerNode0' .. i]:runAction(action)

            
        end

        local action = cc.Sequence:create(cc.EaseInOut:create(cc.FadeTo:create(0.3, 150), 2))
        vars['tamerBlackLayer']:runAction(action)

            
        
        --[[
        local func_action
        local func_next

        func_action = function()
            local action = cc.Sequence:create(cc.EaseInOut:create(cc.MoveTo:create(0.3, l_finish_pos[i]), 2), cc.CallFunc:create(func_next))
            vars['tamerNode0' .. i]:runAction(action)
        end

        func_next = function()
            self.m_workListHelper:doNextWork()
        end
       
        func_action() 
        --]]
    end
    
    local function func_exit()
    end

    self.m_workListHelper:addWork(name, func_enter, funk_work, func_exit)
end

-------------------------------------
-- function setTamerRes
-------------------------------------
function UI_StartingTamer:setTamerRes(idx, tid)
    local vars = self.vars
    local t_tamer = TableTamer():get(tid)
    local ani_tamer = AnimatorHelper:makeTamerAnimator(t_tamer['res'])
    vars['tamerNode0' .. idx]:removeAllChildren()
	vars['tamerNode0' .. idx]:addChild(ani_tamer.m_node)
end

-------------------------------------
-- function setTamerAni
-------------------------------------
function UI_StartingTamer:setTamerAni(idx, tid)
    local vars = self.vars
    local t_tamer = TableTamer():get(tid)
    local ani_tamer = AnimatorHelper:makeTamerAnimator(t_tamer['res'])
    vars['tamerNode' .. idx]:removeAllChildren()
	vars['tamerNode' .. idx]:addChild(ani_tamer.m_node)
end

-------------------------------------
-- function click_skillBtn
-------------------------------------
function UI_StartingTamer:click_skillBtn(did, j, btn)
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
	local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
	local skill_individual_info = skill_mgr:getSkillIndivisualInfo_usingIdx(j)

	-- 스킬 텍스트 생성
	local skill_name = skill_individual_info:getSkillName()
    local desc = skill_individual_info:getSkillDesc()
    local str = '{@SKILL_NAME} ' .. skill_name .. '\n {@SKILL_DESC}' .. desc

	-- skill tool tip 생성
	local tool_tip = UI_Tooltip_Skill(0, 0, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(btn)
end

-------------------------------------
-- function click_selectBtn
-- @brief 드래곤 선택
-------------------------------------
function UI_StartingTamer:click_selectBtn()
    -- @analytics
    Analytics:firstTimeExperience('Select_Start_DragonDetail')

	local function cb_func()
		self.m_makeAccountFunc()
		self:close()
	end

    -- @jhakim 닉네임 결정하는 시점에서 유저 이탈이 일어나는 걸로 의심되어 닉네임 결정하는 스텝을 제거
    --  UI_SelectNickname(self.m_selectIdx, cb_func)
    self:makeTempNick(cb_func)
end

-------------------------------------
-- function makeTempNick
-- @brief 신규 계정 생성 시, 아무 닉네임이나 주면 서버에서 임시 닉네임을 부여해줌
-------------------------------------
function UI_StartingTamer:makeTempNick(cb_func)
    local vars = self.vars
    local idx = self.m_selectIdx

	local l_starting_data = UI_SelectStartingDragon.getStartingData()
    local user_type = l_starting_data[idx]['user_type']

    g_startTamerData:request_createAccount(user_type, nil, 'temporary_nick', cb_func)
end
