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

        m_dragonSelectSprite = 'cc.Sprite',
        m_orginDid = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopup:init(dragon_object, focus_idx)
    local vars = self:load('dragon_skill_detail_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- 인디케이터 아이콘용
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_panel/ingame_panel.plist')
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SkillDetailPopup')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- initialize
	self.m_dragonObject = dragon_object
	self.m_skillMgr = MakeDragonSkillFromDragonData(dragon_object)
    self.m_dragonSelectSprite = nil

    -- 내가 소유한 드래곤의 경우만 originDid 체크
    local doid = dragon_object['id']
    if (doid) then
        if (g_dragonsData:getDragonDataFromUid(doid)) then
            self.m_orginDid = dragon_object:getDid()
        end
    end

    self:initUI()
	self:makeSkillRadioBtn(focus_idx)
    self:addSameTypeDragon()
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

    -- 변신 스킬을 보유 중이면 변신 관련 UI를 표시
    if (self.m_skillMgr:hasMetamorphosisSkill()) then
        vars['swapBtn']:setVisible(true)
        vars['swapBtn']:registerScriptTapHandler(function()
            local is_metamorphosis = vars['swapSprit2']:isVisible()
            is_metamorphosis = (not is_metamorphosis)
            
            self.m_skillMgr:changeSkillSetByMetamorphosis(is_metamorphosis)

            local focus_idx = self.m_skillRadioBtn.m_selectedButton

            -- refresh
            self:initUI()
            self:makeSkillRadioBtn(focus_idx)
        end)

        vars['swapLabel']:setVisible(true)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SkillDetailPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
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
    do
        local str, color = getSkillTypeStr_Tamer(skill_type)
        vars['skillTypeLabel']:setString(str)
        vars['skillTypeLabel']:setColor(color)
    end


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
    do
	    vars['skillEnhanceLabel']:setString(string.format('Lv. %d / %d', self.m_currLV, self.m_maxLV))
        vars['skillEnhanceLabel']:setColor(COLOR['DEEPGRAY'])
        vars['nowNode']:setVisible(false)
        if (self.m_orginDid == self.m_dragonObject:getDid()) then
			if (skill_indivisual_info:isActivated()) then
				vars['skillEnhanceLabel']:setColor(COLOR['CURR_LV'])
				vars['nowNode']:setVisible(true)
			end
        end
    end

    -- 좌측 하단 박스
    do
        -- 스킬 쿨타임 표시
        local cooltime = skill_indivisual_info:getCoolTimeDesc()
        if (cooltime) then
            vars['cooltimeLabel']:setString(cooltime)
        else
            vars['cooltimeLabel']:setString('-')
        end

        -- 스킬 타겟수
        local target_cnt = skill_indivisual_info:getTargetCount()
        if (target_cnt) then
            vars['targetLabel']:setString(target_cnt)
        else
            vars['targetLabel']:setString('-')
        end

        -- 인디케이터
        local indicator_type = skill_indivisual_info:getIndicatorType()
        vars['indicatorIconNode']:removeAllChildren()
        if (indicator_type) then
            -- 아이콘
            local icon = skill_indivisual_info:getIndicatorIcon()
            if (icon) then
                vars['indicatorIconNode']:addChild(icon)
            end

            -- 명칭
            local indicator_name = skill_indivisual_info:getIndicatorName()
            vars['indicatorLabel']:setString(indicator_name)
        else
            vars['indicatorLabel']:setString('-')
        end
    end
    
	-- 스킬 설명
    do
        local desc = skill_indivisual_info:getSkillDesc()
        vars['skillDscLabel']:setString(desc)
        local desc_mod = skill_indivisual_info:getSkillDescMod()
        vars['skillDscLabel2']:setString(desc_mod)
    end

    -- 비활성화 인 경우 잠금 해제에 대한 안내 표시
    if (skill_indivisual_info:isActivated()) then
        vars['lockNode']:setVisible(false)
    else
        vars['lockNode']:setVisible(true)
        local evo_str = evolutionName(idx)
        vars['lockLabel']:setString(Str('{1} 단계에서 해제', evo_str))
    end

    -- 변신
    if (self.m_skillMgr:hasMetamorphosisSkill()) then
        vars['swapSprit1']:setVisible(not self.m_skillMgr.m_bMetamorphosis)
        vars['swapSprit2']:setVisible(self.m_skillMgr.m_bMetamorphosis)

        if (self.m_skillMgr.m_bMetamorphosis) then
            vars['swapLabel']:setString(Str('변신 후 스킬'))
            vars['swapLabel']:setColor(COLOR['cyan'])
        else
            vars['swapLabel']:setString(Str('변신 전 스킬'))
            vars['swapLabel']:setColor(COLOR['apricot'])
        end
    end
end

-------------------------------------
-- function addSameTypeDragon
-- @brief 같은 타입 드래곤 리스트
-------------------------------------
function UI_SkillDetailPopup:addSameTypeDragon()
    local vars = self.vars

    -- origin 드래곤 정보
    local struct_dragon_object = self.m_dragonObject
    local did = struct_dragon_object:getDid()
    local attr = struct_dragon_object:getAttr()

    -- 더미가 아닌 현재 드래곤 따로 표시
    local pos_y = vars['dragonCardNode_'..attr]:getPositionY()
    vars['selectSprite']:setVisible(true)
    vars['selectSprite']:setPositionY(pos_y)

    -- select sprite 생성
    local select_sprite = IconHelper:getIcon('res/ui/frames/temp/dragon_select_frame.png')
    select_sprite:setDockPoint(CENTER_POINT)
    select_sprite:setAnchorPoint(CENTER_POINT)
    select_sprite:setPositionY(pos_y)
    select_sprite:setScale(0.5)
    vars['dragonNode']:addChild(select_sprite)
    self.m_dragonSelectSprite = select_sprite

    -- 초기화
    local l_attr = getAttrTextList()
    for _, attr in ipairs(l_attr) do
        vars['emptyNode_'..attr]:setVisible(true)
        vars['dragonCardNode_'..attr]:removeAllChildren()
    end

    -- 더미 드래곤 생성
    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(did)
    local type = t_dragon['type']
    local target_list = table_dragon:filterList('type', type)

    -- test 값 확인
    if target_list then
        local _target_list = target_list
        target_list = {}
        for i,v in pairs(_target_list) do
            if (g_dragonsData:isReleasedDragon(v['did'])) then
                table.insert(target_list, v)
            end
        end
    end

    if (not target_list) then 
        return 
    end

    for _, v in pairs(target_list) do
        
        local t_data = v
        local attr = t_data['attr']
        
        -- 더미 카드 생성
        if (t_data) then
            local node = vars['dragonCardNode_'..attr]
            local dummy_struct
            if (did == t_data['did']) then
                dummy_struct = struct_dragon_object
                dummy_struct.lv = nil
            else
                dummy_struct = self:makeDragonData(t_data)
            end
            local dragon_card = UI_DragonCard(dummy_struct)

            dragon_card.vars['clickBtn']:registerScriptTapHandler(function() 
                self:click_sameTypeCard(dummy_struct) 
            end)
            node:addChild(dragon_card.root)

            vars['emptyNode_'..attr]:setVisible(false)
        end
    end
end

-------------------------------------
-- function makeDragonData
-------------------------------------
function UI_SkillDetailPopup:makeDragonData(data)
    local t_dragon = data
    if (not t_dragon) then
        return nil
    end

    local struct_dragon_object = self.m_dragonObject

    local t_dragon_data = {}
    t_dragon_data['did'] = t_dragon['did']
    t_dragon_data['lv'] = nil
    t_dragon_data['evolution'] = struct_dragon_object:getEvolution()
    t_dragon_data['grade'] = struct_dragon_object:getGrade()
    t_dragon_data['exp'] = 0
    t_dragon_data['skill_0'] = 1
    t_dragon_data['skill_1'] = 1
    t_dragon_data['skill_2'] = (t_dragon_data['evolution'] >= 2) and 1 or 0
    t_dragon_data['skill_3'] = (t_dragon_data['evolution'] >= 3) and 1 or 0
    
    return StructDragonObject(t_dragon_data)
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

	if (self.m_currLV >= self.m_maxLV) then
		vars['nextBtn']:setEnabled(false)
    end

	if (self.m_currLV <= 1) then
		vars['prevBtn']:setEnabled(false)
	end
end

-------------------------------------
-- function click_sameTypeCard
-- @brief 같은 타입 드래곤 클릭시
-------------------------------------
function UI_SkillDetailPopup:click_sameTypeCard(struct_dragon_object)
    if (not struct_dragon_object) then return end

    self.m_dragonObject = struct_dragon_object
    self.m_skillMgr = MakeDragonSkillFromDragonData(struct_dragon_object)

    local attr = struct_dragon_object:getAttr()
    local pos_y = self.vars['dragonCardNode_'..attr]:getPositionY()
    self.m_dragonSelectSprite:setPositionY(pos_y)

    local focus_idx = self.m_skillRadioBtn.m_selectedButton

    -- refresh
    self:initUI()
    self:makeSkillRadioBtn(focus_idx)
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
	local new_info = self.m_skillMgr:makeIndividualInfoForUI(skill_type, skill_id, skill_lv)

	do -- 레벨 표시
        vars['skillEnhanceLabel']:setString(string.format('Lv. %d / %d', self.m_currLV, self.m_maxLV))
        vars['skillEnhanceLabel']:setColor(COLOR['DEEPGRAY'])
        vars['nowNode']:setVisible(false)
        if (self.m_orginDid == self.m_dragonObject:getDid()) then
            if (self.m_currLV == before_info:getSkillLevel()) then
                vars['skillEnhanceLabel']:setColor(COLOR['CURR_LV'])
                vars['nowNode']:setVisible(true)
            end
        end
    end

	do -- 스킬 강화 설명
        local desc_mod = new_info:getSkillDescMod()
        vars['skillDscLabel2']:setString(desc_mod)
    end

	self:toggleButton()
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_SkillDetailPopup:click_infoBtn()
	UI_HelpStatus()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SkillDetailPopup:click_closeBtn()
	self:close()
end
