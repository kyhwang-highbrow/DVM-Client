local PARENT = UI

-------------------------------------
-- class UI_SkillCard
-------------------------------------
UI_SkillCard = class(PARENT, {
        m_charType = 'string',
        m_skillID = 'number',
        m_skillType = 'string',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillCard:init(char_type, skill_id, skill_type, skill_lv)
    self.m_charType = char_type
    self.m_skillID = skill_id
    self.m_skillType = skill_type
    local vars = self:load('skill_item.ui')

    local icon = IconHelper:getSkillIcon(char_type, skill_id)
    vars['skillNode']:addChild(icon)

    -- 액티브, 필살기 스킬 프레임
    -- @TODO 액티브, 패시브 한글로 표시
    if isExistValue(skill_type, 'active','touch') then
        vars['activeSprite']:setVisible(false)
        vars['skillLabel']:setString('액티브')
        vars['skillLabel']:setColor(cc.c3b(0,255,0))
    else
        vars['activeSprite']:setVisible(false)
        vars['skillLabel']:setString('패시브')
        vars['skillLabel']:setColor(cc.c3b(255,255,30))
    end

    vars['clickBtn']:registerScriptTapHandler(function() self:click_clickBtn() end)
end

-------------------------------------
-- function getSkillName
-------------------------------------
function UI_SkillCard:getSkillName(skill_id, skill_type)
    local table_name = self.m_charType .. '_skill'

    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    local skill_type_str = ''
    if (skill_type == 'basic') then
        skill_type_str = Str('(기본공격)')

    elseif (skill_type == 'basic_turn') or (skill_type == 'basic_rate') then
        skill_type_str = Str('(일반)')

    elseif (skill_type == 'passive') then
        skill_type_str = Str('(패시브)')

    elseif (skill_type == 'touch') then
        skill_type_str = Str('(액티브)')

    elseif (skill_type == 'active') then
        skill_type_str = Str('(액티브)')

    elseif (skill_type == 'manual') then
        skill_type_str = ''

    else
        error('skill_type : ' .. skill_type)
    end


    return Str(t_skill['t_name'] .. skill_type_str)
end

-------------------------------------
-- function getSkillNameStr
-------------------------------------
function UI_SkillCard:getSkillNameStr(skill_id)
    local table_name = self.m_charType .. '_skill'

    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    return Str(t_skill['t_name'])
end

-------------------------------------
-- function getSkillTypeStr
-------------------------------------
function UI_SkillCard:getSkillTypeStr(skill_type)
    local skill_type_str = ''
    if (skill_type == 'basic') then
        skill_type_str = Str('기본공격')

    elseif (skill_type == 'basic_turn') or (skill_type == 'basic_rate') then
        skill_type_str = Str('일반')

    elseif (skill_type == 'passive') then
        skill_type_str = Str('패시브')

    elseif (skill_type == 'touch') then
        skill_type_str = Str('액티브')

    elseif (skill_type == 'active') then
        skill_type_str = Str('액티브')

    elseif (skill_type == 'manual') then
        skill_type_str = ''

    else
        error('skill_type : ' .. skill_type)
    end

    return skill_type_str
end

-------------------------------------
-- function getSkillDescStrPure
-------------------------------------
function UI_SkillCard:getSkillDescStrPure(skill_id, skill_type)
    local table_name = self.m_charType .. '_skill'

    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    local desc = IDragonSkillManager:getSkillDescPure(t_skill)
    return desc
end

-------------------------------------
-- function getSkillDescStr
-------------------------------------
function UI_SkillCard:getSkillDescStr(skill_id, skill_type)
    local table_name = self.m_charType .. '_skill'

    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    local skill_type_str = ''
    if (skill_type == 'basic') then
        skill_type_str = Str('(기본공격)')

    elseif (skill_type == 'basic_turn') or (skill_type == 'basic_rate') then
        skill_type_str = Str('(일반)')

    elseif (skill_type == 'passive') then
        skill_type_str = Str('(패시브)')

    elseif (skill_type == 'touch') then
        skill_type_str = Str('(액티브)')

    elseif (skill_type == 'active') then
        skill_type_str = Str('(액티브)')

    elseif (skill_type == 'manual') then
        skill_type_str = ''

    else
        error('skill_type : ' .. skill_type)
    end

    local desc = IDragonSkillManager:getSkillDescPure(t_skill)

    local str = '{@SKILL_NAME} ' .. t_skill['t_name'] .. skill_type_str .. '\n {@SKILL_DESC}' .. desc
    return str
end

-------------------------------------
-- function click_clickBtn
-------------------------------------
function UI_SkillCard:click_clickBtn()
    local str = self:getSkillDescStr(self.m_skillID, self.m_skillType)
    local tool_tip = UI_Tooltip_Skill(70, -145, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['clickBtn'])
end

-------------------------------------
-- function setLockSpriteVisible
-------------------------------------
function UI_SkillCard:setLockSpriteVisible(visible)
    local vars = self.vars
    vars['lockSprite']:setVisible(visible)
end

-------------------------------------
-- function setSkillTypeVisible
-------------------------------------
function UI_SkillCard:setSkillTypeVisible(visible)
	self.vars['skillLabel']:setVisible(visible)
end