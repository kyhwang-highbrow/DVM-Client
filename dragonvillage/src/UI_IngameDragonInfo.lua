local PARENT = class(UI_IngameUnitInfo, IEventListener:getCloneTable())

-------------------------------------
-- class UI_IngameDragonInfo
-------------------------------------
UI_IngameDragonInfo = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function UI_IngameDragonInfo:init(unit)
    if (unit.m_bLeftFormation) then
        unit:addListener('dragon_skill_gauge', self)
        unit:addListener('character_dead', self)
    end
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
    -- 4개를 넘어가면 y 값 조정
	local factor_y = 0
	if idx > 4 then 
		idx = idx - 4
		factor_y = -20
	end

    local x, y
    
	x = -20 + 18 * (idx - 1)
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
    end
end