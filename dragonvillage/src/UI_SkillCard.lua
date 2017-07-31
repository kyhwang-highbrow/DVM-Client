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
    skill_lv = (skill_lv or 0)
    local vars = self:load('icon_skill_item.ui')

    local icon = IconHelper:getSkillIcon(char_type, skill_id)
    vars['skillNode']:addChild(icon)

	-- 스킬 타입 텍스트
	local skill_type_str = self:getSkillTypeStr(skill_type, false)
    vars['skillLabel']:setString(skill_type_str)
	if isExistValue(skill_type, 'active') then
        vars['skillLabel']:setColor(cc.c3b(0,255,0))
    else
        vars['skillLabel']:setColor(cc.c3b(255,255,30))
    end

    -- 스킬 레벨
    vars['skllLvLabel']:setString(tostring(skill_lv))

    vars['clickBtn']:registerScriptTapHandler(function() self:click_clickBtn() end)
end

-------------------------------------
-- function getSkillName
-------------------------------------
function UI_SkillCard:getSkillName(skill_id, skill_type)
    local table_name = self.m_charType .. '_skill'

    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    local skill_type_str = self:getSkillTypeStr(skill_type, true)

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
function UI_SkillCard:getSkillTypeStr(skill_type, is_use_brakets)
    return getSkillTypeStr(skill_type, is_use_brakets)
end

-------------------------------------
-- function getSkillDescStrPure
-------------------------------------
function UI_SkillCard:getSkillDescStrPure(skill_id, skill_type)
    local table_name = self.m_charType .. '_skill'

    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    local desc = DragonSkillCore.getSimpleSkillDesc(t_skill)
    return desc
end

-------------------------------------
-- function getSkillDescStr
-------------------------------------
function UI_SkillCard:getSkillDescStr(skill_id, skill_type)
    local table_name = self.m_charType .. '_skill'

    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    local skill_type_str = self:getSkillTypeStr(skill_type, true)

    local desc = DragonSkillCore.getSimpleSkillDesc(t_skill)

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