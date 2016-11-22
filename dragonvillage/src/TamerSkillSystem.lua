local showToolTip = function(skill_id)
    local char_type = 'tamer'
    local skill_id = skill_id
    local skill_type = nil
    local str = UI_Tooltip_Skill:getSkillDescStr(char_type, skill_id, skill_type)

    local tool_tip = UI_Tooltip_Skill(320, -220, str, true)
    tool_tip:autoRelease()
end

-------------------------------------
-- class TamerSkillSystem
-------------------------------------
TamerSkillSystem = class(IEventDispatcher:getCloneClass(), IEventListener:getCloneTable(), {
        m_world = 'GameWrold',

        m_tamerSkillCooltimeGlobal = 'number',
        m_lTamerSkillCoolTime = 'list[number]',

        m_specialPowerPoint = 'number', -- 100이 되면 스킬 사용 가능
		m_isUseSpecialSkill = 'bool', -- 궁극기 사용 여부

        m_skillVisualTop = '',
     })

-------------------------------------
-- function init
-------------------------------------
function TamerSkillSystem:init(world)
    self.m_world = world
    self.m_tamerSkillCooltimeGlobal = 0
    self.m_lTamerSkillCoolTime = {}
    self.m_isUseSpecialSkill = false

    -- 일반 스킬
    for i = 1, 3 do
		self:initTamerSkillBtn(i)
    end

    -- 궁극기
	self:initTamerSpecialSkillBtn()

    self.m_world.m_inGameUI.vars['characterMenu']:setVisible(false)
end

-------------------------------------
-- function initTamerSkillBtn
-------------------------------------
function TamerSkillSystem:initTamerSkillBtn(i)
    local ui = self.m_world.m_inGameUI
	local skill_id = self.m_world.m_tamerSkillMgr.m_skill_list[i]['sid']

	-- 1. 살짝 순차적으로 활성화
    self.m_lTamerSkillCoolTime[i] = ((2/30) * i) 

	-- 2. 버튼 핸들러 등록, 누르고 있으면 툴팁
    ui.vars['tamerSkillBtn' .. i]:registerScriptTapHandler(function() self:click_tamerSkillBtn(i) end)
    ui.vars['tamerSkillBtn' .. i].m_node:registerScriptPressHandler(function()
        showToolTip(skill_id)
    end)
        
    -- 스킬 아이콘
    do
        local icon = IconHelper:getSkillIcon('tamer', skill_id)
		local icon2 = IconHelper:getSkillIcon('tamer', skill_id)
        
		ui.vars['tamerSkillNode' .. i]:addChild(icon)
        local socketNode = ui.vars['tamerSkillVisual' .. i].m_node:getSocketNode('skill_normal')
        socketNode:addChild(icon2)
    end

    ui.vars['timeGauge' .. i]:setPercentage(0)
end

-------------------------------------
-- function initTamerSpecialSkillBtn
-------------------------------------
function TamerSkillSystem:initTamerSpecialSkillBtn()
	local idx = 4
	local ui = self.m_world.m_inGameUI
	local skill_id = self.m_world.m_tamerSkillMgr.m_skill_list[idx]['sid']

	-- 2. 버튼 핸들러 등록, 누르고 있으면 툴팁
    ui.vars['specialSkillBtn']:registerScriptTapHandler(function() self:click_specialSkillBtn() end)
	ui.vars['specialSkillBtn'].m_node:registerScriptPressHandler(function()
        showToolTip(skill_id)
    end)

    -- 스킬 아이콘
    do
        local icon = IconHelper:getSkillIcon('tamer', skill_id)
		ui.vars['specialSkillNode']:addChild(icon)
        
        local icon2 = IconHelper:getSkillIcon('tamer', skill_id)
        local socketNode = ui.vars['specialSkillVisual'].m_node:getSocketNode('skill_special')
        socketNode:addChild(icon2)

        self.m_skillVisualTop = MakeAnimator('res/ui/a2d/ingame_tamer_skill/ingame_tamer_skill.vrp')
        ui.vars['specialSkillVisual'].m_node:addChild(self.m_skillVisualTop.m_node)
    end

	-- 사용 가능한 상태로 세팅
    ui.vars['specialTimeGauge']:setPercentage(0)
end

-------------------------------------
-- function click_tamerSkillBtn
-------------------------------------
function TamerSkillSystem:click_tamerSkillBtn(idx, b)
    if not self.m_world:isPossibleControl() then return end
    
	-- 1. 사용할 스킬 테이블 가져온다.
    local t_skill = self.m_world.m_tamerSkillMgr.m_skill_list[idx]
    local skill_id = t_skill['sid']

	-- 2. 쿨타임을 계산하여 처리
    local remain_time = math_max(self.m_lTamerSkillCoolTime[idx], self.m_tamerSkillCooltimeGlobal)
    if (remain_time > 0) then
        local str = '[' .. Str(t_skill['t_name']) .. ']' .. Str('{1}초 후 사용할 수 있습니다.', math_floor(remain_time + 0.5))
        UIManager:toastNotificationRed(str)
        return
    end

	-- 3. 쿨타임이 돌았다면 스킬 실행
    self:dispatch('tamer_skill', function()
        self.m_world.m_tamerSkillMgr:doTamerSkill(idx)
    end, idx)
    
	-- 4. 쿨타임 정산
    self.m_tamerSkillCooltimeGlobal = TAMER_SKILL_GLOBAL_COOLTIME
    self.m_lTamerSkillCoolTime[idx] = t_skill['cooldown']
    self:update(0)

	-- 5. UI 툴팁 연출
    do
        showToolTip(skill_id)
    end

    self:onEvent('tamer_skill')
end

-------------------------------------
-- function click_specialSkillBtn
-- @brief 테이머 궁극기
-------------------------------------
function TamerSkillSystem:click_specialSkillBtn()
    if not self.m_world:isPossibleControl() then return end
	
	-- 1. 궁극기는 한번만 사용하도록 
	if self.m_isUseSpecialSkill then 
	    local str = '이미 궁극기를 사용하셨습니다..☆'
        UIManager:toastNotificationRed(str)
		return 
	end 

    -- 2. 사용할 스킬 테이블 가져온다.
    local t_skill = self.m_world.m_tamerSkillMgr.m_skill_list[4]

    -- 3. 스킬 실행
    self.m_world.m_inGameUI.root:setVisible(false)
    self:dispatch('tamer_special_skill', function()
        self.m_world.m_inGameUI.root:setVisible(true)
        self.m_world.m_tamerSkillMgr:doTamerSkill(4)
    end)

    -- 4. 후처리
    self.m_isUseSpecialSkill = true
    self.m_tamerSkillCooltimeGlobal = 5
end

-------------------------------------
-- function update
-------------------------------------
function TamerSkillSystem:update(dt)
    local ui = self.m_world.m_inGameUI
    
    -- 글로벌 쿨타임 계산
    if (0 < self.m_tamerSkillCooltimeGlobal) then
        self.m_tamerSkillCooltimeGlobal = (self.m_tamerSkillCooltimeGlobal - dt)

        if (0 > self.m_tamerSkillCooltimeGlobal) then
            self.m_tamerSkillCooltimeGlobal = 0
        end
    end

    for i = 1, 3 do
        self:updateSkillBtn(i, dt)
    end

    self:updateSpecialSkillBtn(dt)
end

-------------------------------------
-- function updateSkillBtn
-------------------------------------
function TamerSkillSystem:updateSkillBtn(i, dt)
	local ui = self.m_world.m_inGameUI
	local t_skill = self.m_world.m_tamerSkillMgr.m_skill_list[i]

    if (0 < self.m_lTamerSkillCoolTime[i]) then
        self.m_lTamerSkillCoolTime[i] = math_max(self.m_lTamerSkillCoolTime[i] - dt, 0)
    end

    local prev_percentage = ui.vars['timeGauge' .. i]:getPercentage()
    local percentage = 0

    if (self.m_tamerSkillCooltimeGlobal > self.m_lTamerSkillCoolTime[i]) then
        percentage = (self.m_tamerSkillCooltimeGlobal / TAMER_SKILL_GLOBAL_COOLTIME) * 100
    else
        percentage = (self.m_lTamerSkillCoolTime[i] / t_skill['cooldown']) * 100
    end
        
    if prev_percentage ~= percentage then
		ui.vars['timeGauge' .. i]:setPercentage(percentage)
        
		local visual = ui.vars['tamerSkillVisual' .. i]
        visual:setVisible(false)

        if percentage <= 0 then
			local icon_idx = 4 - i
            visual:setVisible(true)
            visual:setVisual('skill_charging', 'normal_0' .. icon_idx)
            visual:setRepeat(false)
            visual:registerScriptLoopHandler(function()
                visual:setVisual('skill_idle', 'normal_0' .. icon_idx)
                visual:setRepeat(true)
            end)
        end
    end
end

-------------------------------------
-- function updateSpecialSkillBtn
-------------------------------------
function TamerSkillSystem:updateSpecialSkillBtn(dt)
    local ui = self.m_world.m_inGameUI
    local visual = ui.vars['specialSkillVisual']
    local percentage = 0

    -- 이미 궁극기를 사용한 경우 항상 비활성화 표시
    if self.m_isUseSpecialSkill then
        percentage = 100
            
    -- 궁극기를 사용 가능한 경우에는 클로벌 쿨타임을 표시
    else
        percentage = (self.m_tamerSkillCooltimeGlobal / TAMER_SKILL_GLOBAL_COOLTIME) * 100
    end
    ui.vars['specialTimeGauge']:setPercentage(percentage)
    
    if percentage <= 0 and not visual:isVisible() then
        visual:setVisible(true)
        visual:setVisual('skill_charging', 'special')
        visual:setRepeat(false)
        visual:registerScriptLoopHandler(function()
            visual:setVisual('skill_idle', 'special')
            visual:setRepeat(true)

            self.m_skillVisualTop:setVisual('skill_idle', 'special_idle')
            self.m_skillVisualTop:setRepeat(true)
        end)

        self.m_skillVisualTop:setVisual('skill_charging', 'special_open')
        self.m_skillVisualTop:setRepeat(false)
    elseif percentage > 0 then
        visual:setVisible(false)
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function TamerSkillSystem:onEvent(event_name, ...)

    if (event_name == 'game_start') then

    elseif (event_name == 'dragon_skill') then
        -- 글로벌 쿨타임
        self.m_tamerSkillCooltimeGlobal = TAMER_SKILL_GLOBAL_COOLTIME

    elseif (event_name == 'character_dead') then

    elseif (event_name == 'tamer_skill') then

    end
end

-------------------------------------
-- function showSpeech
-- @debuging
-------------------------------------
function TamerSkillSystem:resetCoolTime()
    self.m_tamerSkillCooltimeGlobal = 0

	for i = 1, 3 do
		self.m_lTamerSkillCoolTime[i] = 0
	end

    self:update(0)
end

-------------------------------------
-- function isWaitingGlobalCoolTime
-- @debuging
-------------------------------------
function TamerSkillSystem:isWaitingGlobalCoolTime()
    return self.m_tamerSkillCooltimeGlobal > 0
end