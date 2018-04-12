local PARENT = UI

-------------------------------------
-- class UI_TamerSkillCard
-------------------------------------
UI_TamerSkillCard = class(PARENT, {
        m_skillIndivisualInfo = 'DragonSkillIndivisualInfo',
     })

-------------------------------------
-- function init
-- @param skill_indivisual_info DragonSkillIndivisualInfo
-------------------------------------
function UI_TamerSkillCard:init(skill_indivisual_info)
    self.m_skillIndivisualInfo = skill_indivisual_info

    local vars = self:load('tamer_skill_item.ui')

	local char_type = skill_indivisual_info.m_charType
    local skill_id = skill_indivisual_info.m_skillID
    local skill_type = skill_indivisual_info:getSkillTypeForUI()
    local icon = IconHelper:getSkillIcon(char_type, skill_id)
    vars['skillNode']:addChild(icon)

    do -- 스킬 타입 표시
        self:setTypeText(char_type, skill_type)
    end    

    -- 스킬 레벨
    local skill_lv = skill_indivisual_info.m_skillLevel
    local lv_str
    if (not skill_lv) or (skill_lv == 0) then
        lv_str = ''
    else
        lv_str = Str('Lv.{1}', skill_lv)
    end
    vars['lvLabel']:setString(lv_str)

    -- 스킬 이름
    local skill_name = self:getSkillNameStr()
    vars['skillNameLabel']:setString(skill_name)
end

-------------------------------------
-- function getSkillNameStr
-------------------------------------
function UI_TamerSkillCard:getSkillNameStr()
    local t_skill = self.m_skillIndivisualInfo.m_tSkill
    local str = '{@SKILL_NAME} ' .. Str(t_skill['t_name'])
    return str
end

-------------------------------------
-- function getSkillDescStr
-------------------------------------
function UI_TamerSkillCard:getSkillDescStr()
    local t_skill = self.m_skillIndivisualInfo.m_tSkill
    local skill_type = self.m_skillIndivisualInfo:getSkillTypeForUI()
    local skill_type_str = getSkillTypeStr(skill_type, true)
    local desc = self.m_skillIndivisualInfo:getSkillDesc()

    local str = '{@SKILL_NAME} ' .. Str(t_skill['t_name']) .. skill_type_str .. '\n {@SKILL_DESC}' .. desc
    return str
end

-------------------------------------
-- function setButtonEnabled
-------------------------------------
function UI_TamerSkillCard:setButtonEnabled(enable)
    local vars = self.vars
    vars['clickBtn']:setEnabled(enable)
end

-------------------------------------
-- function setSkillTypeText
-- @brief skill_type
-------------------------------------
function UI_TamerSkillCard:setTypeText(char_type, skill_type)
    local vars = self.vars

    if (skill_type == 'basic') then
        vars['typeLabel']:setString(Str('기본'))

    elseif (skill_type == 'leader') then
        vars['typeLabel']:setString(Str('리더'))

    elseif (skill_type == 'active') then
        if (char_type == 'tamer') then vars['typeLabel']:setString(Str('액티브'))
        else vars['typeLabel']:setString(Str('드래그'))
        end

    elseif (skill_type == 'passive') then
        vars['typeLabel']:setString(Str('패시브'))

    elseif (skill_type == 'colosseum') then
        vars['typeLabel']:setString(Str('콜로세움'))

    else
        vars['typeLabel']:setString(Str('패시브'))
        vars['typeLabel']:setColor(cc.c3b(255,231,160))
    end

    local color = self.setTypeTextColor(skill_type)
    vars['typeLabel']:setColor(color)
end

-------------------------------------
-- function setTypeTextColor
-- @brief skill_type
-------------------------------------
function UI_TamerSkillCard.setTypeTextColor(skill_type)
    if (skill_type == 'basic') then
        return cc.c3b(255,255,255)

    elseif (skill_type == 'leader') then
        return cc.c3b(199,69,255)

    elseif (skill_type == 'active') then
        return cc.c3b(244,191,5)

    elseif (skill_type == 'passive') then
        return cc.c3b(255,231,160)

    elseif (skill_type == 'colosseum') then
        return cc.c3b(255,85,149)

    else
        return cc.c3b(255,231,160)

    end
end