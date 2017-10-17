local PARENT = UI

-------------------------------------
-- class UI_DragonSkillEnhance_Result
-------------------------------------
UI_DragonSkillEnhance_Result = class(PARENT,{
		m_dragonData = 'StructDragonObject',
		m_enhancedIdx = 'num',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkillEnhance_Result:init(old_struct_dragon, mod_struct_dragon)
    local vars = self:load('dragon_skill_enhance_result.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonSkillEnhance_Result')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- initialize
	self.m_dragonData = mod_struct_dragon
	self:findEnhancedSkillIdx(old_struct_dragon, mod_struct_dragon)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkillEnhance_Result:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSkillEnhance_Result:initButton()
	self.vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkillEnhance_Result:refresh()
    local vars = self.vars

	local skill_mgr = MakeDragonSkillFromDragonData(self.m_dragonData)
	local skill_indivisual_info = skill_mgr:getSkillIndivisualInfo_usingIdx(self.m_enhancedIdx)

    do -- 스킬 타입
        local str = skill_indivisual_info:getSkillType()
		str = getSkillTypeStr(str, false)
        vars['skillTypeLabel']:setString(str)
    end

    do -- 스킬 아이콘
		vars['skillNode']:removeAllChildren(true)
        local skill_id = skill_indivisual_info:getSkillID()
        local icon = IconHelper:getSkillIcon('dragon', skill_id)
        vars['skillNode']:addChild(icon)
    end

    do -- 스킬 이름
        local name = skill_indivisual_info:getSkillName()
        vars['skillNameLabel']:setString(name)
    end

	do -- 레벨 표시
        local skill_level = skill_indivisual_info:getSkillLevel()
        vars['skillEnhanceLabel']:setString(string.format('Lv. %d', skill_level))
    end

	do -- 스킬 설명
        local desc = skill_indivisual_info:getSkillDesc()
        vars['skillDscLabel']:setString(desc)
    end
end

-------------------------------------
-- function findEnhancedSkillIdx
-------------------------------------
function UI_DragonSkillEnhance_Result:findEnhancedSkillIdx(old_struct_dragon, mod_struct_dragon)
	for i = 0, 3 do 
		local a_lv = old_struct_dragon['skill_' .. i]
		local b_lv = mod_struct_dragon['skill_' .. i]
		if (a_lv ~= b_lv) then
			self.m_enhancedIdx = i
			break
		end
	end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonSkillEnhance_Result:click_exitBtn()
    self:closeWithAction()
end
