local PARENT = UI

-------------------------------------
-- class UI_DragonSkillCard
-------------------------------------
UI_DragonSkillCard = class(PARENT, {
        m_skillIndivisualInfo = 'DragonSkillIndivisualInfo',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkillCard:init(skill_indivisual_info)
    self.m_skillIndivisualInfo = skill_indivisual_info

    local vars = self:load('icon_skill_item_new.ui')

	local char_type = skill_indivisual_info.m_charType
    local skill_id = skill_indivisual_info.m_skillID
    local skill_type = skill_indivisual_info.m_skillType
    local icon = IconHelper:getSkillIcon(char_type, skill_id)
    vars['skillNode']:addChild(icon)

    do -- 스킬 타입 표시
        self:setTypeText(skill_type)
    end    

    do -- 스킬 lock
        local is_lock = (skill_indivisual_info.m_skillLevel <= 0)
        self:setLockSpriteVisible(is_lock)
    end

    -- 스킬 레벨
    local skill_lv = skill_indivisual_info.m_skillLevel
    local lv_str
    if (not skill_lv) or (skill_lv == 0) then
        lv_str = ''
    else
        lv_str = Str('Lv.{1}', skill_lv)
    end
    vars['levelLabel']:setString(lv_str)

    -- button
    vars['clickBtn']:registerScriptTapHandler(function() self:click_clickBtn() end)
end

-------------------------------------
-- function click_clickBtn
-------------------------------------
function UI_DragonSkillCard:click_clickBtn()
    local str = self:getSkillDescStr()
    local tool_tip = UI_Tooltip_Skill(0, 0, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['clickBtn'])
end

-------------------------------------
-- function getSkillDescStr
-------------------------------------
function UI_DragonSkillCard:getSkillDescStr()
    local t_skill = self.m_skillIndivisualInfo.m_tSkill
    local skill_type = self.m_skillIndivisualInfo.m_skillType

    local skill_type_str = getSkillTypeStr(skill_type, true)

    local desc = IDragonSkillManager:getSkillDescPure(t_skill)

    local str = '{@SKILL_NAME} ' .. t_skill['t_name'] .. skill_type_str .. '\n {@SKILL_DESC}' .. desc
    return str
end

-------------------------------------
-- function setButtonEnabled
-------------------------------------
function UI_DragonSkillCard:setButtonEnabled(enable)
    local vars = self.vars
    vars['clickBtn']:setEnabled(enable)
end

-------------------------------------
-- function setLockSpriteVisible
-------------------------------------
function UI_DragonSkillCard:setLockSpriteVisible(visible)
    local vars = self.vars
    vars['lockSprite']:setVisible(visible)
end

-------------------------------------
-- function setSkillTypeVisible
-------------------------------------
function UI_DragonSkillCard:setSkillTypeVisible(visible)
	self.vars['typeLabel']:setVisible(visible)
end

-------------------------------------
-- function setNoLv
-------------------------------------
function UI_DragonSkillCard:setNoLv()
    --self.vars['frameSprite1']:setVisible(false)
	--self.vars['frameSprite2']:setVisible(true)
    self:setLockSpriteVisible(false)
end

-------------------------------------
-- function setSimple
-- @brief dragon_info, info_mini, 도감 등에서 사용하도록 simple_mode로 세팅!
-------------------------------------
function UI_DragonSkillCard:setSimple()
    local vars = self.vars

    -- 필요없는것 다 꺼버림
    vars['typeLabel']:setVisible(false)
    vars['baseSprite']:setVisible(false)
    vars['emptySprite']:setVisible(false)

    -- lockSprite 교체
    local is_lock = vars['lockSprite']:isVisible()
    vars['lockSprite']:removeFromParent(true)
    vars['lockSprite'] = IconHelper:getIcon('res/ui/buttons/skill_btn_0105.png')
    vars['lockSprite']:setVisible(is_lock)
    self.root:addChild(vars['lockSprite'])

    -- lv label 위치 조정
    vars['levelLabel']:setPosition(0, -30)
    vars['levelLabel']:setScale(1.5)

    -- 스킬 아이콘 및 버튼 위치 조정
    vars['skillNode']:setScale(1)
    vars['skillNode']:setPosition(0, 0)
    vars['clickBtn']:setNormalSize(100, 100)
end

-------------------------------------
-- function setSkillTypeText
-- @brief skill_type
-------------------------------------
function UI_DragonSkillCard:setTypeText(skill_type)
    local vars = self.vars

    if (skill_type == 'basic') then
        vars['typeLabel']:setString('기본')
        vars['typeLabel']:setColor(cc.c3b(255,255,255))

    elseif (skill_type == 'leader') then
        vars['typeLabel']:setString('리더')
        vars['typeLabel']:setColor(cc.c3b(199,69,255))

    elseif (skill_type == 'active') then
        vars['typeLabel']:setString('액티브')
        vars['typeLabel']:setColor(cc.c3b(244,191,5))

    elseif (skill_type == 'passive') then
        vars['typeLabel']:setString('패시브')
        vars['typeLabel']:setColor(cc.c3b(255,231,160))

    elseif (skill_type == 'colosseum') then
        vars['typeLabel']:setString('콜로세움')
        vars['typeLabel']:setColor(cc.c3b(255,85,149))

    --elseif isExistValue(skill_type, 'basic_turn', 'basic_rate', 'hit_cri', 'indie_turn', 'indie_time', 'indie_rate') then
    else
        vars['typeLabel']:setString('패시브')
        vars['typeLabel']:setColor(cc.c3b(255,231,160))

    end
end