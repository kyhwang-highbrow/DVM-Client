local PARENT = UI

-------------------------------------
-- class UI_DragonSkillInfo
-------------------------------------
UI_DragonSkillInfo = class(PARENT, {
        m_dragon_data = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkillInfo:init(dragon_data)
    self.m_dragon_data = dragon_data

    local vars = self:load('dragon_skill_enhance_move_item.ui')
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkillInfo:initUI()
    local vars = self.vars
    local t_dragon_data = self.m_dragon_data

    do -- 드래곤 현재 정보 카드
        vars['dragonIconNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(t_dragon_data)
        vars['dragonIconNode']:addChild(dragon_card.root)
    end

    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(t_dragon_data:getDragonNameWithEclv())
    end

    do -- 드래곤 속성
        local attr = t_dragon_data:getAttr()
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIconButton(attr)
        vars['attrNode']:addChild(icon)
    end

    do -- 드래곤 역할(role)
        local role_type = t_dragon_data:getRole()
        vars['typeLabel']:setString(dragonRoleTypeName(role_type))
    end

    do -- 드래곤 스킬 
        local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
        local l_skill_icon = skill_mgr:getDragonSkillIconList()

        for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
	        local skill_node = vars['skillNode' .. i]
	        skill_node:removeAllChildren()
            
	        -- 스킬 아이콘 생성
	        if l_skill_icon[i] then
		        skill_node:addChild(l_skill_icon[i].root)
                l_skill_icon[i].vars['clickBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
                l_skill_icon[i].vars['clickBtn']:registerScriptTapHandler(function()
			        UI_SkillDetailPopup(t_dragon_data, i)
		        end)

	        -- 비어있는 스킬 아이콘 생성
	        else
		        local empty_skill_icon = IconHelper:getEmptySkillCard()
		        skill_node:addChild(empty_skill_icon)
	        end
        end
    end
end