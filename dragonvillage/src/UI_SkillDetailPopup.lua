local PARENT = UI

-------------------------------------
-- class UI_SkillDetailPopup
-------------------------------------
UI_SkillDetailPopup = class(PARENT, {
        m_dragonObject = 'table',
		m_skillMgr = 'DragonSkillManager',
		m_skillRadioBtn = 'UIC_RadioButton',
		
		-- skill lv 미리보기 용
		m_currIdx = 'number',
		m_currLV = 'number',
		m_maxLV = 'number',
		m_numberLoop = 'NumberLoop',

        m_bSimpleMode = 'boolean',
        m_skillIconList = 'list',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopup:init(dragon_object, focus_idx)
    -- 플레이어의 드래곤이 아닐 경우 예외처리
    if (not self.m_bSimpleMode) then
        local uid = g_userData:get('uid')
        if (dragon_object['uid'] ~= uid) then
            self.m_bSimpleMode = true
        end
    end

    local vars = self:load('dragon_skill_detail_popup.ui')
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
	self:makeSkillRadioBtn(focus_idx)
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
    self.m_skillIconList = l_skill_icon
	for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
		local skill_node = vars['skillNode' .. i]
		skill_node:removeAllChildren()
		
		-- 스킬 아이콘 생성
		if l_skill_icon[i] then
            skill_node:addChild(l_skill_icon[i].root)
			vars['skillBtn'..i] = l_skill_icon[i].vars['clickBtn']
            vars['skillBtn'..i]:registerScriptTapHandler(function() self:refresh(i) end)
            vars['skillBtn'..i]:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)

		-- 비어있는 스킬 아이콘 생성
		else
			local empty_skill_icon = IconHelper:getEmptySkillCard()
			skill_node:addChild(empty_skill_icon)
        end
	end

	-- 만든 스킬 아이콘들을 radio button으로 래핑한다.
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SkillDetailPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
	vars['prevBtn']:registerScriptTapHandler(function() self:click_skillLvBtn(false) end)
	vars['nextBtn']:registerScriptTapHandler(function() self:click_skillLvBtn(true) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SkillDetailPopup:refresh(idx)
    local vars = self.vars
	local skill_indivisual_info = self.m_skillMgr:getSkillIndivisualInfo_usingIdx(idx)
    local skill_id = skill_indivisual_info:getSkillID()

    -- 스킬 타입
	local skill_type = skill_indivisual_info:getSkillType()

    -- 스킬 타입 텍스트
	local skill_type_str = getSkillTypeStr(skill_type, false)
	vars['skillTypeLabel']:setString(skill_type_str)
        
    -- 스킬 이름 색상
    local color = UI_DragonSkillCard.setTypeTextColor(skill_type)
    vars['skillTypeLabel']:setColor(color)

    do -- 선택 활성 이미지
        local icon = self.m_skillIconList[self.m_currIdx]
        if icon then
            icon.vars['selectSprite']:setVisible(false)
        end
        local icon = self.m_skillIconList[idx]
        if icon then
            icon.vars['selectSprite']:setVisible(true)
        end
    end

	-- 스킬 이름
	local name = skill_indivisual_info:getSkillName()
	vars['skillNameLabel']:setString(name)

	-- 스킬 레벨 미리보기용 변수
	do
		self.m_currIdx = idx
		self.m_currLV = math_max(1, skill_indivisual_info:getSkillLevel())
		self.m_maxLV = TableDragonSkillModify:getMaxLV(skill_id)
		self.m_numberLoop = NumberLoop(self.m_maxLV)
		self.m_numberLoop:setCurr(self.m_currLV)
		self:toggleButton()
	end

	-- 레벨 표시
	vars['skillEnhanceLabel']:setString(string.format('Lv. %d / %d', self.m_currLV, self.m_maxLV))

	-- 스킬 설명
    local desc = skill_indivisual_info:getSkillDesc()
    vars['skillDscLabel']:setString(desc)

    -- 스킬 쿨타임 표시
    local cooltime = skill_indivisual_info:getCoolTimeDesc()
    if (cooltime) then
        vars['skillCoolTimeNode']:setVisible(true)
        vars['cooltimeLabel']:setString(cooltime)
    else
        vars['skillCoolTimeNode']:setVisible(false)
    end

    -- 비활성화 인 경우 잠금 해제에 대한 안내 표시
    if (skill_indivisual_info:isActivated()) then
        vars['lockNode']:setVisible(false)
    else
        vars['lockNode']:setVisible(true)
        local evo_str = evolutionName(idx)
        vars['lockLabel']:setString(Str('{1} 단계에서 해제', evo_str))
    end
end

-------------------------------------
-- function makeSkillRadioBtn
-------------------------------------
function UI_SkillDetailPopup:makeSkillRadioBtn(focus_idx)
	local vars = self.vars

	-- radio button 선언
    local radio_button = UIC_RadioButton()
	radio_button:setChangeCB(function() self:onChangeOption() end)
	self.m_skillRadioBtn = radio_button

	-- 활성화 된 스킬만 라디오 버튼 붙임
	local first_idx = focus_idx
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
-- function toggleButton
-------------------------------------
function UI_SkillDetailPopup:toggleButton()
	local vars = self.vars

	-- 레벨에 따라 + 또는 - 버튼 false
	vars['prevBtn']:setEnabled(true)
	vars['nextBtn']:setEnabled(true)

	if (self.m_currLV == self.m_maxLV) then
		vars['nextBtn']:setEnabled(false)

	elseif (self.m_currLV <= 1) then
		vars['prevBtn']:setEnabled(false)

	end
end

-------------------------------------
-- function click_skillLvBtn
-------------------------------------
function UI_SkillDetailPopup:click_skillLvBtn(is_next)
	local vars = self.vars
	
	local before_info = self.m_skillMgr:getSkillIndivisualInfo_usingIdx(self.m_currIdx)
	if (is_next) then
		self.m_currLV = self.m_numberLoop:next()
	else
		self.m_currLV = self.m_numberLoop:prev()
	end

	local skill_type = before_info:getSkillType()
	local skill_id = before_info:getSkillID()
	local skill_lv = self.m_currLV
	local new_info = self.m_skillMgr:makeIndividualInfo(skill_type, skill_id, skill_lv)

	do -- 레벨 표시
        local skill_level = new_info:getSkillLevel()
        vars['skillEnhanceLabel']:setString(string.format('Lv. %d / %d', self.m_currLV, self.m_maxLV))
    end

	do -- 스킬 설명
        local desc = new_info:getSkillDesc()
        vars['skillDscLabel']:setString(desc)
    end

    -- 스킬 쿨타임 표시
    local cooltime = new_info:getCoolTimeDesc()
    if (cooltime) then
        vars['skillCoolTimeNode']:setVisible(true)
        vars['cooltimeLabel']:setString(cooltime)
    else
        vars['skillCoolTimeNode']:setVisible(false)
    end

	self:toggleButton()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SkillDetailPopup:click_closeBtn()
	self:closeWithAction()
end
