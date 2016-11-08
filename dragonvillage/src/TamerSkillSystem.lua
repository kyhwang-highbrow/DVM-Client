local TAMER_SKILL_GLOBAL_COOLTIME = 3
local TAMER_SKILL_COOLTIME = 20

-------------------------------------
-- class TamerSkillSystem
-------------------------------------
TamerSkillSystem = class(IEventListener:getCloneClass(), {
        m_world = 'GameWrold',

        m_tamerSkillCooltimeGlobal = 'number',
        m_lTamerSkillCoolTime = 'list[number]',

        m_specialPowerPoint = 'number', -- 100이 되면 스킬 사용 가능
     })

-------------------------------------
-- function init
-------------------------------------
function TamerSkillSystem:init(world, t_tamer)
    self.m_world = world
    self.m_tamerSkillCooltimeGlobal = 0
    self.m_lTamerSkillCoolTime = {}

    local ui = world.m_inGameUI

    -- 일반 스킬
    for i = 1, 3 do
        self.m_lTamerSkillCoolTime[i] = TAMER_SKILL_COOLTIME

        ui.vars['tamerSkillBtn' .. i]:registerScriptTapHandler(function() self:click_tamerSkillBtn(i) end)

        -- 스킬 아이콘
        do
            local icon = IconHelper:getSkillIcon('tamer', t_tamer['skill_' .. i])
            ui.vars['tamerSkillNode' .. i]:addChild(icon)
        end

        do
            local icon = IconHelper:getSkillIcon('tamer', t_tamer['skill_' .. i])
            local socketNode = ui.vars['tamerSkillVisual' .. i].m_node:getSocketNode('skill_normal')
            socketNode:addChild(icon)
        end

        ui.vars['timeGauge' .. i]:setPercentage(0)
    end

    -- 궁극기
    do
        self.m_specialPowerPoint = 0
        
        --ui.vars['specialSkillBtn']:registerScriptTapHandler(function() self:click_specialSkillBtn() end)
        ui.vars['specialSkillBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('미구현 기능입니다.') end)

        -- 스킬 아이콘
        do
            local icon = IconHelper:getSkillIcon('tamer', 241001)
            --ui.vars['tamerSkillNode' .. i]:addChild(icon)
        end

        do
            local icon = IconHelper:getSkillIcon('tamer', 241001)
            local socketNode = ui.vars['specialSkillVisual'].m_node:getSocketNode('skill_special')
            socketNode:addChild(icon)
        end

        ui.vars['specialTimeGauge']:setPercentage(0)
    end

    ui.vars['characterMenu']:setVisible(false)
end

-------------------------------------
-- function click_tamerSkillBtn
-------------------------------------
function TamerSkillSystem:click_tamerSkillBtn(idx)
	-- 1. 사용할 스킬 테이블 가져온다.
    local t_skill = self.m_world.m_tamerSkillMgr.m_skill_list[idx]
    local skill_id = t_skill['id']

	-- 2. 쿨타임을 계산하여 처리
    local remain_time = math_max(self.m_lTamerSkillCoolTime[idx], self.m_tamerSkillCooltimeGlobal)
    if (remain_time > 0) then
        local str = '[' .. Str(t_skill['t_name']) .. ']' .. Str('{1}초 후 사용할 수 있습니다.', math_floor(remain_time + 0.5))
        UIManager:toastNotificationRed(str)
        return
    end

	-- 3. 쿨타임이 돌았다면 스킬 실행
    self.m_world.m_tamerSkillMgr:doSkill(idx)

	-- 4. 쿨타임 정산
    self.m_tamerSkillCooltimeGlobal = TAMER_SKILL_GLOBAL_COOLTIME
    self.m_lTamerSkillCoolTime[idx] = TAMER_SKILL_COOLTIME
    self:update(0)

	-- 5. UI 툴팁 연출
    do
        local char_type = 'tamer'
        local skill_id = skill_id
        local skill_type = nil
        local str = UI_Tooltip_Skill:getSkillDescStr(char_type, skill_id, skill_type)

        local tool_tip = UI_Tooltip_Skill(320, -220, str, true)
        tool_tip:autoRelease()
    end

    self:onEvent('tamer_skill')
end

-------------------------------------
-- function click_specialSkillBtn
-- @brief 테이머 궁극기
-------------------------------------
function TamerSkillSystem:click_specialSkillBtn()
    if (self.m_specialPowerPoint < 100) then
        local str = Str('궁극기 포인트 {1}이(가) 부족합니다.', 100 - self.m_specialPowerPoint)
        UIManager:toastNotificationRed(str)
        return
    end

    -- 궁극기 포인트 감소
    self:addSpecialPowerPoint(-self.m_specialPowerPoint)

    g_gameScene:gamePause()
    local res = 'res/character/tamer/leon_i/leon_i.spine'

    local animator = MakeAnimator(res)
    animator.m_node:setDockPoint(cc.p(0.5, 0.5))
    animator:changeAni('cutscene', false)

    self.m_tamer:setActive(false)

    local function funct()
        animator:release()
        g_gameScene:gameResume()

        do
            local special_power = SpecialPowerLeon('res/character/tamer/leon/leon.spine')

            local tamer = self.m_tamer

            special_power.m_owner = self.m_tamer
            special_power.m_activityCarrier = tamer:makeAttackDamageInstance()
            special_power.m_activityCarrier.m_skillCoefficient = 0.5

            special_power:setPosition(1280/2, 0) -- 가운데서 시작
            g_gameScene.m_gameWorld:addChild2(special_power.m_rootNode)
            g_gameScene.m_gameWorld:addToUnitList(special_power)
        end
    end

    local duration = animator:getDuration()
    animator.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(funct)))


    local ui = self.m_world.m_inGameUI
    ui.root:addChild(animator.m_node)
end

-------------------------------------
-- function update
-------------------------------------
function TamerSkillSystem:update(dt)
    local ui = self.m_world.m_inGameUI
    
    if (0 < self.m_tamerSkillCooltimeGlobal) then
        self.m_tamerSkillCooltimeGlobal = (self.m_tamerSkillCooltimeGlobal - dt)

        if (0 > self.m_tamerSkillCooltimeGlobal) then
            self.m_tamerSkillCooltimeGlobal = 0
        end
    end

    for i = 1, 3 do
        if (0 < self.m_lTamerSkillCoolTime[i]) then
            self.m_lTamerSkillCoolTime[i] = math_max(self.m_lTamerSkillCoolTime[i] - dt, 0)
        end

        local prev_percentage = ui.vars['timeGauge' .. i]:getPercentage()
        local percentage = 0

        if (self.m_tamerSkillCooltimeGlobal > self.m_lTamerSkillCoolTime[i]) then
            percentage = (self.m_tamerSkillCooltimeGlobal / TAMER_SKILL_GLOBAL_COOLTIME) * 100
        else
            percentage = (self.m_lTamerSkillCoolTime[i] / TAMER_SKILL_COOLTIME) * 100
        end

        ui.vars['timeGauge' .. i]:setPercentage(percentage)
        
        if prev_percentage ~= percentage then
            local visual = ui.vars['tamerSkillVisual' .. i]
            visual:setVisible(false)

            if percentage <= 0 then
                visual:setVisible(true)
                visual:setVisual('skill_charging', 'normal')
                visual:setRepeat(false)
                visual:registerScriptLoopHandler(function()
                    visual:setVisual('skill_idle', 'normal')
                    visual:setRepeat(true)
                end)
            end
        end
    end
end

-------------------------------------
-- function addSpecialPowerPoint
-------------------------------------
function TamerSkillSystem:addSpecialPowerPoint(add_point)
    local prev = self.m_specialPowerPoint
    self.m_specialPowerPoint = math_clamp(self.m_specialPowerPoint + add_point, 0, 100)

    local ui = self.m_world.m_inGameUI
    ui.vars['specialTimeGauge']:setPercentage(100 - self.m_specialPowerPoint)

    -- 궁극기 게이지 이펙트
    if (prev ~= self.m_specialPowerPoint) then
        local visual = ui.vars['specialSkillVisual']
        visual:setVisible(false)

		if (self.m_specialPowerPoint == 100) then
            visual:setVisible(true)
            visual:setVisual('skill_charging', 'special')
            visual:setRepeat(false)
            visual:registerScriptLoopHandler(function()
                visual:setVisual('skill_idle', 'special')
                visual:setRepeat(true)
            end)
        end
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function TamerSkillSystem:onEvent(event_name, ...)

    -- 게임 시작 시 25점
    if (event_name == 'game_start') then
        self:addSpecialPowerPoint(25)

    -- 아군 드래곤 액티브 스킬 사용 3점
    elseif (event_name == 'active_skill') then
        self:addSpecialPowerPoint(3)
        self:addSpecialPowerPoint(20) -- 개발 편의성을 위해

    -- 드래곤 사망 5점
    elseif (event_name == 'character_dead') then
        self:addSpecialPowerPoint(5)

    -- 테이머 스킬 사용 3점
    elseif (event_name == 'tamer_skill') then
        self:addSpecialPowerPoint(3)

    end
end

-------------------------------------
-- function showSpeech
-- @debuging
-------------------------------------
function TamerSkillSystem:resetCoolTime()
    self.m_tamerSkillCooltimeGlobal = 0

	for i, _ in pairs(self.m_lTamerSkillCoolTime) do
		self.m_lTamerSkillCoolTime[i] = 0
	end
end