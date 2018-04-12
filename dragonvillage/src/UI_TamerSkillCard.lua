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

    do -- 스킬 타입 
        local str, color = getSkillTypeStr_Tamer(skill_type)
        vars['typeLabel']:setString(str)
        vars['typeLabel']:setColor(color)
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
    local str = '{@ivory}' .. Str(t_skill['t_name'])
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

    local str = '{@ivory}' .. Str(t_skill['t_name']) .. skill_type_str .. '\n{@SKILL_DESC}' .. desc
    return str
end

-------------------------------------
-- function setButtonEnabled
-------------------------------------
function UI_TamerSkillCard:setButtonEnabled(enable)
    local vars = self.vars
    vars['clickBtn']:setEnabled(enable)
end