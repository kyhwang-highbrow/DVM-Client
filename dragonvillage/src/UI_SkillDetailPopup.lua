local PARENT = UI

-------------------------------------
-- class UI_SkillDetailPopup
-------------------------------------
UI_SkillDetailPopup = class(PARENT, {
        m_dragonObject = 'table',
		m_skillMgr = 'DragonSkillManager',
		m_skillRadioBtn = 'UIC_RadioButton',

        m_bSimpleMode = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopup:init(dragon_object)
    -- 플레이어의 드래곤이 아닐 경우 예외처리
    if (not self.m_bSimpleMode) then
        local uid = g_userData:get('uid')
        if (dragon_object['uid'] ~= uid) then
            self.m_bSimpleMode = true
        end
    end

    local vars = self:load('dragon_skill_detail_popup_new.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SkillDetailPopup')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- initialize
	self.m_dragonObject = dragon_object
	self.m_skillMgr = MakeDragonSkillFromDragonData(dragon_object)

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SkillDetailPopup:initUI()
	local vars = self.vars

	-- skill icon 상단 리스트
	local l_skill_icon = self.m_skillMgr:getDragonSkillIconList()
	for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
		local skill_node = vars['skillNode' .. i]
		skill_node:removeAllChildren()
		
		-- 스킬 아이콘 생성
		if l_skill_icon[i] then
            skill_node:addChild(l_skill_icon[i].root)
			l_skill_icon[i]:setLeaderLabelToggle(i == 'Leader')
			vars['skillBtn'..i] = l_skill_icon[i].vars['clickBtn']
            vars['skillBtn'..i]:registerScriptTapHandler(function() self:refresh(i) end)
            vars['skillBtn'..i]:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)

		-- 비어있는 스킬 아이콘 생성
		else
			local empty_skill_icon = IconHelper:getEmptySkillIcon()
			skill_node:addChild(empty_skill_icon)
        end
	end

	-- 만든 스킬 아이콘들을 radio button으로 래핑한다.
	self:makeSkillRadioBtn()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SkillDetailPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
	vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
	vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SkillDetailPopup:refresh(idx)
    local vars = self.vars
	local skill_indivisual_info = self.m_skillMgr:getSkillIndivisualInfo_usingIdx(idx)

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
-- function makeSkillRadioBtn
-------------------------------------
function UI_SkillDetailPopup:makeSkillRadioBtn()
	local vars = self.vars

	-- radio button 선언
    local radio_button = UIC_RadioButton()
	radio_button:setChangeCB(function() self:onChangeOption() end)
	self.m_skillRadioBtn = radio_button

	local first_idx
	for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
		local skill_indivisual_info = self.m_skillMgr:getSkillIndivisualInfo_usingIdx(i)
		if (skill_indivisual_info) then
			radio_button:addButton(i, vars['skillBtn'.. i])
			if (not first_idx) then
				first_idx = i
			end
		end
	end

	-- 첫번째 스킬을 선택한다.
	radio_button:setSelectedButton(first_idx)
end

-------------------------------------
-- function onChangeOption
-------------------------------------
function UI_SkillDetailPopup:onChangeOption()
    local skill_idx = self.m_skillRadioBtn.m_selectedButton
	self:refresh(skill_idx)
end

-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_SkillDetailPopup:click_prevBtn()

end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_SkillDetailPopup:click_nextBtn()

end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SkillDetailPopup:click_closeBtn()
	self:closeWithAction()
end
