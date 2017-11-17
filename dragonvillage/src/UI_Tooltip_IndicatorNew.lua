local PARENT = UI

-------------------------------------
-- class UI_Tooltip_IndicatorNew
-------------------------------------
UI_Tooltip_IndicatorNew = class(PARENT, {
		m_skillInfo = 'DragonSkillIndivisualInfo',
        m_oldSkillInfo = 'DragonSkillIndivisualInfo',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Tooltip_IndicatorNew:init()
    local vars = self:load('ingame_drag_info.ui')
    UIManager:open(self, UIManager.TOOLTIP)

    -- opacity 조절 액션도 동작하도록
    self:setOpacityChildren(true)

    --self:initUI()
    --self:initButton()
    --self:refresh()
end

-------------------------------------
-- function init_data
-------------------------------------
function UI_Tooltip_IndicatorNew:setDragon(dragon)
    -- active skill info를 꺼내옴
	self.m_skillInfo = dragon:getSkillIndivisualInfo('active')

    -- 현재 skill_info 스킬아이디와 드래곤의 액티브스킬 아이디를 비교하여 다르다면
    -- 스킬 강화 된것으로 보고 강화되기전 스킬을 꺼내온다.
    local curr_skill_id = self.m_skillInfo:getSkillID()
    local active_skill_id = dragon.m_charTable['skill_active']
    if (curr_skill_id ~= active_skill_id) then
        self.m_oldSkillInfo = dragon:getSkillInfoByID(active_skill_id)
    end
end

-------------------------------------
-- function displayData
-- @brief public으로 사용
-------------------------------------
function UI_Tooltip_IndicatorNew:refresh()
    local vars = self.vars

    local skill_indivisual_info = self.m_skillInfo
    local old_skill_info = self.m_oldSkillInfo
    
    local idx = 1
    local skill_desc = nil

	-- 스킬 이름
	local name = skill_indivisual_info:getSkillName()
	vars['titleLabel']:setString(name)

    -- 스킬 아이콘
    do
        vars['skillNode']:removeAllChildren()
        local ui = UI_DragonSkillCard(skill_indivisual_info)
        ui:setSimple()
        vars['skillNode']:addChild(ui.root)
        vars['cooltimeLabel']:setString('')
    end

    -- 좌측 하단 박스
    do
        -- 스킬 쿨타임 표시
        local cooltime = skill_indivisual_info:getCoolTimeDesc()
        if (cooltime) then
            vars['timeLabel']:setString(cooltime)
        else
            vars['timeLabel']:setString('-')
        end

        -- 스킬 타겟수
        local target_cnt = skill_indivisual_info:getTargetCount()
        if (target_cnt) then
            vars['targetLabel']:setString(target_cnt)
        else
            vars['targetLabel']:setString('-')
        end

        -- 인디케이터
        local indicator_type = skill_indivisual_info:getIndicatorType()
        vars['indicatorIconNode']:removeAllChildren()
        if (indicator_type) then
            -- 아이콘
            local icon = skill_indivisual_info:getIndicatorIcon()
            if (icon) then
                vars['indicatorIconNode']:addChild(icon)
            end

            -- 명칭
            local indicator_name = skill_indivisual_info:getIndicatorName()
            vars['indicatorLabel']:setString(indicator_name)
        else
            vars['indicatorLabel']:setString('-')
        end
    end
    
	-- 스킬 설명
    do
        local desc = skill_indivisual_info:getSkillDesc()
        vars['skillDscLabel']:setString(desc)
        local desc_mod = skill_indivisual_info:getSkillDescMod()
        vars['skillDscLabel2']:setString(desc_mod)
    end
end

-------------------------------------
-- function show
-------------------------------------
function UI_Tooltip_IndicatorNew:show()
    self:doActionReset()
    self:doAction()
end

-------------------------------------
-- function hide
-------------------------------------
function UI_Tooltip_IndicatorNew:hide()
    self.m_skillInfo = nil
    self.m_oldSkillInfo = nil
    
    self.vars['skillNode']:removeAllChildren()

    self:doActionReverse()
end
