local PARENT = UI

-------------------------------------
-- class UI_MonsterSkillCard
-------------------------------------
UI_MonsterSkillCard = class(PARENT, {
        m_charType = 'string',
        m_skillID = 'number',
        m_skillType = 'string',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_MonsterSkillCard:init(char_type, skill_id, skill_type, skill_lv)
    self.m_charType = char_type
    self.m_skillID = skill_id
    self.m_skillType = skill_type
    skill_lv = (skill_lv or 0)

    local vars = self:load('icon_skill_item_monster.ui')
    local icon = IconHelper:getSkillIconWithId(skill_id)
    vars['skillNode']:addChild(icon)
    vars['clickBtn']:registerScriptTapHandler(function() self:click_clickBtn() end)
end

-------------------------------------
-- function getSkillName
-------------------------------------
function UI_MonsterSkillCard:getSkillName(skill_id, skill_type)
    local table_name = self.m_charType .. '_skill'

    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    local skill_type_str = self:getSkillTypeStr(skill_type, true)

    return Str(t_skill['t_name'] .. skill_type_str)
end

-------------------------------------
-- function getSkillNameStr
-------------------------------------
function UI_MonsterSkillCard:getSkillNameStr(skill_id)
    local table_name = self.m_charType .. '_skill'

    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    return Str(t_skill['t_name'])
end

-------------------------------------
-- function getSkillTypeStr
-------------------------------------
function UI_MonsterSkillCard:getSkillTypeStr(skill_type, is_use_brakets)
    return getSkillTypeStr(skill_type, is_use_brakets)
end

-------------------------------------
-- function getSkillDescStrPure
-------------------------------------
function UI_MonsterSkillCard:getSkillDescStrPure(skill_id, skill_type)
    local table_name = self.m_charType .. '_skill'

    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    local desc =  DragonSkillCore.getSimpleSkillDesc(t_skill)
    return desc
end

-------------------------------------
-- function getSkillDescStr
-------------------------------------
function UI_MonsterSkillCard:getSkillDescStr(skill_id, skill_type)
    local table_name = self.m_charType .. '_skill'

    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    local skill_type_str = self:getSkillTypeStr(skill_type, true)

    local desc =  DragonSkillCore.getSimpleSkillDesc(t_skill)

    local str = '{@SKILL_NAME} ' .. t_skill['t_name'] .. skill_type_str .. '\n {@SKILL_DESC}' .. desc
    return str
end

-------------------------------------
-- function getSkillDescStrAll
-------------------------------------
function UI_MonsterSkillCard:getSkillDescStrAll(skill_id, skill_type)
    local monster_skill = 'monster_skill'
    local dragon_skill = 'dragon_skill'

    local table_skill = TABLE:get(monster_skill)
    local t_skill = table_skill[skill_id]
    
    if (not t_skill) then
        table_skill = TABLE:get(dragon_skill)
        t_skill = table_skill[skill_id]
    end

    local desc =  DragonSkillCore.getSimpleSkillDesc(t_skill)

    local str = '{@SKILL_NAME} ' .. Str(t_skill['t_name']) .. '\n {@SKILL_DESC}' .. desc
    return str
end

-------------------------------------
-- function click_clickBtn
-------------------------------------
function UI_MonsterSkillCard:click_clickBtn()
    local str = self:getSkillDescStrAll(self.m_skillID, self.m_skillType)
    local tool_tip = UI_Tooltip_Skill(70, -145, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['clickBtn'])
end

-------------------------------------
-- function setLockSpriteVisible
-------------------------------------
function UI_MonsterSkillCard:setLockSpriteVisible(visible)
    local vars = self.vars
    vars['lockSprite']:setVisible(visible)
end

-------------------------------------
-- function setSkillTypeVisible
-------------------------------------
function UI_MonsterSkillCard:setSkillTypeVisible(visible)
	self.vars['skillLabel']:setVisible(visible)
end