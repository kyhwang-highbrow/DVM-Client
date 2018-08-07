-- 2018.09.07 sgkim
-- 드래곤 특성 스킬 아이콘
-- UI_DragonSkillCard.lua파일을 복사해서 수정함
local PARENT = UI

-------------------------------------
-- class UI_DragonMasterySkillCard
-------------------------------------
UI_DragonMasterySkillCard = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMasterySkillCard:init(mastery_skill_id, mastery_skill_lv)
    local vars = self:load('icon_skill_item.ui')

    -- 버튼 기능을 사용하지 않음
    self:setButtonEnabled(false)
    self:setSkillTypeVisible(false)

    -- 특성 스킬 아이콘에서는 typeLabel를 사용하지 않기 때문에 levelLabel을 가운데로 정렬
    vars['levelLabel']:setPositionY(0)

    self:refresh_masterySkillInfo(mastery_skill_id, mastery_skill_lv)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMasterySkillCard:refresh_masterySkillInfo(mastery_skill_id, mastery_skill_lv)
    local vars = self.vars

    -- 특성 아이콘
    local res_name = TableMasterySkill():getValue(mastery_skill_id, 'icon')
    local icon = IconHelper:getIcon(res_name)
    vars['skillNode']:removeAllChildren()
    vars['skillNode']:addChild(icon)


    -- 특성 스킬 레벨 표기
    vars['levelLabel']:setString(tostring(mastery_skill_lv or 0))
end

-------------------------------------
-- function setButtonEnabled
-------------------------------------
function UI_DragonMasterySkillCard:setButtonEnabled(enable)
    local vars = self.vars
    vars['clickBtn']:setEnabled(enable)
end

-------------------------------------
-- function setLockSpriteVisible
-------------------------------------
function UI_DragonMasterySkillCard:setLockSpriteVisible(visible)
    local vars = self.vars
    vars['lockSprite']:setVisible(visible)
end

-------------------------------------
-- function setSkillTypeVisible
-------------------------------------
function UI_DragonMasterySkillCard:setSkillTypeVisible(visible)
	self.vars['typeLabel']:setVisible(visible)
end


