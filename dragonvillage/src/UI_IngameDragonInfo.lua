local PARENT = class(UI_IngameUnitInfo, IEventListener:getCloneTable())

-------------------------------------
-- class UI_IngameDragonInfo
-------------------------------------
UI_IngameDragonInfo = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function UI_IngameDragonInfo:init(unit)
    unit:addListener('dragon_skill_gauge', self)
    unit:addListener('character_dead', self)
    unit:addListener('character_metamorphosis', self)
end

-------------------------------------
-- function loadUI
-------------------------------------
function UI_IngameDragonInfo:loadUI()
    local vars = self:load_useSpriteFrames('ingame_dragon_info.ui')
    return vars
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameDragonInfo:initUI()
    PARENT.initUI(self)

    local vars = self.vars
    local skill_id = self.m_owner:getSkillID('active')
    local t_skill = self.m_owner:getSkillTable(skill_id)
    if (t_skill) then
        if (SkillHelper:isEnemyTargetingType(t_skill)) then
            vars['gaugeVisual']:changeAni('gg_full_atk', true)
        else
            vars['gaugeVisual']:changeAni('gg_full_heal', true)
        end
    end

    -- 디버깅용 label
	self:makeDebugingLabel()
    self.m_label:setPosition(70, 0)
end

-------------------------------------
-- function getPositionForStatusIcon
-------------------------------------
function UI_IngameDragonInfo:getPositionForStatusIcon(bLeftFormation, idx)
    -- max_idx개를 넘어가면 y 값 조정
    --  idx가 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 이고, max_idx가 4이면
    --  x  =  0, 1, 2, 3, 0, 1, 2, 3, 0, 1 
    --  y  =  0, 0, 0, 0, 1, 1, 1, 1, 2, 2
    --  로 만들어서 해당 x,y idx에 각각의 gap을 곱해준다.

    local game_mode = g_gameScene.m_gameMode
    local t_constant = g_constant:get('UI', 'STATUS_EFFECT_ICON_GAP')
    local max_idx, gap_x, gap_y

    local constants = t_constant[IN_GAME_MODE[game_mode]]
    if(not constants) then
        constants = t_constant['COMMON']
    end

    max_idx, gap_x, gap_y = constants[1], constants[2], constants[3]
    idx = idx + max_idx - 1
    local factor_y = 0

    local quotient = math.floor(idx / max_idx) - 1
    idx = idx % max_idx
	factor_y = - gap_y * quotient

    local x, y
    
	x = -20 + gap_x * idx
    y = -23 + factor_y
	
    return x, y
end

-------------------------------------
-- function onEvent
-------------------------------------
function UI_IngameDragonInfo:onEvent(event_name, t_event, ...)
    local vars = self.vars

    -- 드래곤 드래그 스킬 게이지 변경 Event
    if (event_name == 'dragon_skill_gauge') then
        local b = (t_event['percentage'] >= 100 and t_event['enough_mana'])
        vars['gaugeVisual']:setVisible(b)

    -- 드래곤 사망 시
    elseif (event_name == 'character_dead') then
        vars['gaugeVisual']:setVisible(false)

    -- 드래곤 변신
    elseif (event_name == 'character_metamorphosis') then
        local skill_id = self.m_owner:getSkillID('active')
        local t_skill = self.m_owner:getSkillTable(skill_id)
        if (t_skill) then
            if (SkillHelper:isEnemyTargetingType(t_skill)) then
                vars['gaugeVisual']:changeAni('gg_full_atk', true)
            else
                vars['gaugeVisual']:changeAni('gg_full_heal', true)
            end
        end
    end
end