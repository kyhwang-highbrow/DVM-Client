local PARENT = UI

-------------------------------------
-- class UI_Tooltip_Indicator
-------------------------------------
UI_Tooltip_Indicator = class(PARENT, {
		m_skillInfo = 'DragonSkillIndivisualInfo',
        m_oldSkillInfo = 'DragonSkillIndivisualInfo',

        m_titleLabel = '',
        m_descLabel = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Tooltip_Indicator:init(world)
    local vars = self:load('ingame_drag_info.ui')
    UIManager:open(self, UIManager.TOOLTIP)

    -- opacity 조절 액션도 동작하도록
    self:setOpacityChildren(true)

	self:doActionReverse()

    -- 더블 팀 모드의 경우 위치 조정
    if (isInstanceOf(world, GameWorldForDoubleTeam)) then
        if (world:getPCGroup() == PHYS.HERO_TOP) then
            vars['bottomMenu']:setAnchorPoint(cc.p(0, 0))
            vars['bottomMenu']:setDockPoint(cc.p(0, 0))
            vars['bottomMenu']:setPosition(4, 4)
        end
    end
end

-------------------------------------
-- function init_data
-------------------------------------
function UI_Tooltip_Indicator:init_data(char)
    local vars = self.vars

    if (char:getCharType() == 'tamer') then
        vars['tamerMenu']:setVisible(true)
        vars['topMenu']:setVisible(false)
        vars['bottomMenu']:setVisible(false)

        self.m_titleLabel = vars['tamerTitleLabel']
        self.m_descLabel = vars['tamerSkillDscLabel']
        
    else
        vars['tamerMenu']:setVisible(false)
        vars['bottomMenu']:setVisible(true)

        self.m_titleLabel = vars['titleLabel']
        self.m_descLabel = vars['skillDscLabel']

    end

    -- active skill info를 꺼내옴
	self.m_skillInfo = char:getSkillIndivisualInfo('active')

    -- 현재 skill_info 스킬아이디와 드래곤의 액티브스킬 아이디를 비교하여 다르다면
    -- 스킬 강화 된것으로 보고 강화되기전 스킬을 꺼내온다.
    local curr_skill_id = self.m_skillInfo:getSkillID()
    local active_skill_id = char.m_charTable['skill_active']
    if (curr_skill_id ~= active_skill_id) then
        self.m_oldSkillInfo = char:findSkillInfoByID(active_skill_id)
    end
end

-------------------------------------
-- function refresh
-- @brief public으로 사용
-------------------------------------
function UI_Tooltip_Indicator:refresh()
    local vars = self.vars

    local skill_indivisual_info = self.m_skillInfo
    local old_skill_info = self.m_oldSkillInfo
    
    local idx = 1
    local skill_desc = nil

	-- 스킬 이름
	local name = skill_indivisual_info:getSkillName()
    local lv
    if (old_skill_info) then
        lv = old_skill_info:getSkillLevel()
    else
        lv = skill_indivisual_info:getSkillLevel()
    end
	self.m_titleLabel:setString(string.format('Lv.%d %s', lv, name))

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
        local desc
        if (old_skill_info) then
            desc = old_skill_info:getSkillDesc() .. '\n' .. skill_indivisual_info:getSkillDescEnhance()
        else
            desc = skill_indivisual_info:getSkillDesc()
        end
        self.m_descLabel:setString(desc)

        local desc_mod
        if (old_skill_info) then
            desc_mod = old_skill_info:getSkillDescMod()
        else
            desc_mod = skill_indivisual_info:getSkillDescMod()
        end
        vars['skillDscLabel2']:setString(desc_mod)
    end
end

-------------------------------------
-- function show
-------------------------------------
function UI_Tooltip_Indicator:show()
    self:doActionReset()
    self:doAction()
end

-------------------------------------
-- function hide
-------------------------------------
function UI_Tooltip_Indicator:hide()
    self.m_skillInfo = nil
    self.m_oldSkillInfo = nil
    
    self.vars['skillNode']:removeAllChildren()

	-- 첫회에는 보이고 이후에는 안보이게 하고 싶다
    self.vars['topMenu']:setVisible(false)

    self:doActionReverse()
end
