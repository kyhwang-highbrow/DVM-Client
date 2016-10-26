local TAMER_SKILL_GLOBAL_COOLTIME = 3
local TAMER_SKILL_COOLTIME = 20

-------------------------------------
-- class TamerSkillSystem
-------------------------------------
TamerSkillSystem = class(IEventListener:getCloneClass(), {
        m_world = 'GameWrold',
        m_tamer = 'Tamer',

        m_tamerSkillCooltimeGlobal = 'number',
        m_lTamerSkillCoolTime = 'list[number]',

        m_specialPowerPoint = 'number', -- 100이 되면 스킬 사용 가능
     })

-------------------------------------
-- function init
-------------------------------------
function TamerSkillSystem:init(world, tamer)
    self.m_world = world
    self.m_tamer = tamer

    local t_tamer = tamer.m_charTable
    local ui = world.m_inGameUI

    ui.vars['tamerSkillBtn1']:registerScriptTapHandler(function() self:click_tamerSkillBtn(1) end)
    ui.vars['tamerSkillBtn2']:registerScriptTapHandler(function() self:click_tamerSkillBtn(2) end)
    ui.vars['tamerSkillBtn3']:registerScriptTapHandler(function() self:click_tamerSkillBtn(3) end)

    local icon = IconHelper:getSkillIcon('tamer', t_tamer['skill_1'])
    ui.vars['tamerSkillBtn1']:addChild(icon)

    local icon = IconHelper:getSkillIcon('tamer', t_tamer['skill_2'])
    ui.vars['tamerSkillBtn2']:addChild(icon)

    local icon = IconHelper:getSkillIcon('tamer', t_tamer['skill_3'])
    ui.vars['tamerSkillBtn3']:addChild(icon)

    ui.vars['characterMenu']:setVisible(false)

    self.m_tamerSkillCooltimeGlobal = 0
    self.m_lTamerSkillCoolTime = {}
    self.m_lTamerSkillCoolTime[1] = 0
    self.m_lTamerSkillCoolTime[2] = 0
    self.m_lTamerSkillCoolTime[3] = 0

    ui.vars['timeGauge1']:setLocalZOrder(1)
    ui.vars['timeGauge2']:setLocalZOrder(1)
    ui.vars['timeGauge3']:setLocalZOrder(1)

    ui.vars['timeLabel1']:setLocalZOrder(2)
    ui.vars['timeLabel2']:setLocalZOrder(2)
    ui.vars['timeLabel3']:setLocalZOrder(2)

    -- 궁극기
    do
        self.m_specialPowerPoint = 0
        ui.vars['specialGauge']:setPercentage(0)
        ui.vars['specialSkillBtn']:registerScriptTapHandler(function() self:click_specialSkillBtn() end)
    end
end

-------------------------------------
-- function click_tamerSkillBtn
-------------------------------------
function TamerSkillSystem:click_tamerSkillBtn(idx)
    local remain_time = math_max(self.m_lTamerSkillCoolTime[idx], self.m_tamerSkillCooltimeGlobal)

    local t_tamer = self.m_tamer.m_charTable
    local skill_id = t_tamer['skill_' .. idx]

    local table_skill = TABLE:get(self.m_tamer.m_charType .. '_skill')
    local t_skill = table_skill[skill_id]

    if (remain_time > 0) then
        local str = '[' .. Str(t_skill['t_name']) .. ']' .. Str('{1}초 후 사용할 수 있습니다.', math_floor(remain_time + 0.5))
        UIManager:toastNotificationRed(str)
        return
    end

    self.m_tamer:doSkill(skill_id, nil, 0, 0)

    self.m_tamerSkillCooltimeGlobal = TAMER_SKILL_GLOBAL_COOLTIME
    self.m_lTamerSkillCoolTime[idx] = TAMER_SKILL_COOLTIME
    self:update(0)

    do
        local char_type = self.m_tamer.m_charType
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

    for i=1, 3 do
        if (0 < self.m_lTamerSkillCoolTime[i]) then
            self.m_lTamerSkillCoolTime[i] = math_max(self.m_lTamerSkillCoolTime[i] - dt, 0)
        end

        if (self.m_tamerSkillCooltimeGlobal > self.m_lTamerSkillCoolTime[i]) then
            
            local percentage = (self.m_tamerSkillCooltimeGlobal / TAMER_SKILL_GLOBAL_COOLTIME) * 100
            ui.vars['timeGauge' .. i]:setPercentage(percentage)
            ui.vars['timeLabel' .. i]:setString(math_floor(self.m_tamerSkillCooltimeGlobal + 0.5))
        else
            local percentage = (self.m_lTamerSkillCoolTime[i] / TAMER_SKILL_COOLTIME) * 100
            ui.vars['timeGauge' .. i]:setPercentage(percentage)

            if (self.m_lTamerSkillCoolTime[i] <= 0) then
                ui.vars['timeLabel' .. i]:setString('')
            else
                ui.vars['timeLabel' .. i]:setString(math_floor(self.m_lTamerSkillCoolTime[i] + 0.5))
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
    ui.vars['specialGauge']:setPercentage(self.m_specialPowerPoint)

    -- 궁극기 게이지 이펙트
    if (prev ~= self.m_specialPowerPoint) then
        local visual = ui.vars['specialFullViusal']

        if (self.m_specialPowerPoint == 100) then
            visual:setVisible(true)
            visual:setVisual('group', 'effect')
            visual:setRepeat(false)
            visual:registerScriptLoopHandler(function() visual:setVisual('group', 'idle') visual:setRepeat(true) end)
        else
            visual:setVisible(false)
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
        local arg = {...}
        local char = arg[1]
        self:addSpecialPowerPoint(5)

    -- 테이머 일반 공격 1점
    elseif (event_name == 'basic_skill') then
        self:addSpecialPowerPoint(1)

    -- 테이머 스킬 사용 3점
    elseif (event_name == 'tamer_skill') then
        self:addSpecialPowerPoint(3)

    -- 아군 드래곤 협동 공격 1마리 당

    -- 테이머 HP 변경
    elseif (event_name == 'change_hp') then
        local arg = {...}
        local char = arg[1]
        local percentage = char.m_hp / char.m_maxHp * 100
        local ui = self.m_world.m_inGameUI
        ui.vars['hpGauge']:setPercentage(percentage)

    end
end