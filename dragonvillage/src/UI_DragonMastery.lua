local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonMastery
-------------------------------------
UI_DragonMastery = class(PARENT,{
        m_masteryBoardUI = 'UI_DragonMasteryBoard',

        -- skill lv 미리보기 용
		m_currIdx = 'number',
		m_currLV = 'number',
		m_maxLV = 'number',
		m_numberLoop = 'NumberLoop',
    })

UI_DragonMastery.TAB_LVUP = 'mastery' -- 특성 레벨업
UI_DragonMastery.TAB_SKILL = 'skill' -- 특성 스킬

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonMastery:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonMastery'
    self.m_bVisible = true or false
    self.m_titleStr = Str('특성')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMastery:init(doid)
    local vars = self:load('dragon_mastery.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonMastery')

    self:sceneFadeInAction()

    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    -- 정렬 도우미
    self:init_dragonSortMgr()
	--self:init_mtrDragonSortMgr(true) -- slime_first
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMastery:initUI()
    local vars = self.vars
    self:init_dragonTableView()
    self:initStatusUI()

    do -- 아모르의 서
        local table_item = TableItem()
        local item_id = ITEM_ID_AMOR
        do -- 아이템 이름
            local name = Str(table_item:getValue(item_id, 't_name'))
            vars['amorNameLabel']:setString(name)
        end

        do -- 아모르의 서 아이콘
            vars['amorItemNode']:removeAllChildren()
            local item_icon = IconHelper:getItemIcon(item_id)
            vars['amorItemNode']:addChild(item_icon)
        end
    end

    -- 특성 보드
    -- 테이블 뷰 인스턴스 생성
    -- 생성 콜백
    local function create_func(ui, data)
        self.m_masteryBoardUI = UI_DragonMasteryBoard()
        local _ui = self.m_masteryBoardUI
        ui.root:addChild(_ui.root)

        local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
        self.m_masteryBoardUI:refresh(dragon_obj)

        self.m_masteryBoardUI:setMasterySkillSelectCB(function(tier, index) self:onChange_selectedSkill(tier, index) end)
        self.m_masteryBoardUI:setSelectedMasterySkill(1, 1) -- 첫 스킬로 선택되도록
    end
    
    local table_view = UIC_TableView(vars['masterySkillViewNode'])
    table_view.m_defaultCellSize = cc.size(505, 1092)
    table_view:setCellUIClass(UIC_TableViewCell, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList({1}) -- 하나만 사용하기 위해 임시로 추가
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_DragonMastery:initTab()
    local vars = self.vars
    self:addTabAuto(UI_DragonMastery.TAB_LVUP, vars, vars['masteryLvUpMenu'])
    self:addTabAuto(UI_DragonMastery.TAB_SKILL, vars, vars['masterySkillMenu'], vars['masterySkillViewNode'])
    self:setTab(UI_DragonMastery.TAB_LVUP)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_DragonMastery:onChangeTab(tab, first)
    local vars = self.vars
end

-------------------------------------
-- function initStatusUI
-------------------------------------
function UI_DragonMastery:initStatusUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonMastery:initButton()
    local vars = self.vars
    vars['masteryLvUpBtn']:registerScriptTapHandler(function() self:click_masteryLvUpBtn() end)
    vars['amorBtn']:registerScriptTapHandler(function() self:click_amorBtn() end)
    vars['skillEnhanceBtn']:registerScriptTapHandler(function() self:click_skillEnhanceBtn() end)

    -- 특성 스킬 미리보기 관련
    vars['minusBtn']:registerScriptTapHandler(function() self:click_skillLvBtn(false) end)
    vars['plusBtn']:registerScriptTapHandler(function() self:click_skillLvBtn(true) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMastery:refresh()
    self:refresh_dragonInfo()
    self:refresh_masteryInfo()

    if self.m_masteryBoardUI then
        local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
        self.m_masteryBoardUI:refresh(dragon_obj)
    end
end

-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonMastery:refresh_dragonInfo()
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local vars = self.vars

    -- 배경
    local attr = dragon_obj:getAttr()
    if self:checkVarsKey('bgNode', attr) then    
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(dragon_obj:getDragonNameWithEclv())
    end

    do -- 드래곤 속성
        local attr = dragon_obj:getAttr()
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)
    end

    do -- 드래곤 역할(role)
        local role_type = dragon_obj:getRole()
        vars['typeLabel']:setString(dragonRoleTypeName(role_type))
    end

    do -- 드래곤 현재 정보 카드
        vars['dragonIconNode1']:removeAllChildren()
        local dragon_card = UI_DragonCard(dragon_obj)
        vars['dragonIconNode1']:addChild(dragon_card.root)
    end
end

-------------------------------------
-- function refresh_masteryInfo
-- @brief 특성 정보
-------------------------------------
function UI_DragonMastery:refresh_masteryInfo()
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local vars = self.vars

    -- 특성 레벨
    local mastery_lv = tonumber(dragon_obj['mastery_lv']) or 0
    if (mastery_lv <= 0) then
        vars['startNormalLvMenu']:setVisible(true)
        vars['startMasteryLvMenu']:setVisible(false)

        -- UI에 박혀있어서 설정할 필요가 없음
        -- vars['normalLvLabel1']:setString('60')
        -- vars['normalLvLabel2']:setString('1')
    else
        vars['startNormalLvMenu']:setVisible(false)
        vars['startMasteryLvMenu']:setVisible(true)

        vars['masteryLvLabel1']:setString(tostring(mastery_lv))
        vars['masteryLvLabel2']:setString(tostring(mastery_lv + 1))
    end


    -- 특성 포인트(남은 것)
    local mastery_point = tonumber(dragon_obj['mastery_point']) or 0
    vars['skillPointLabel1']:setString(tostring(mastery_point))
    vars['skillPointLabel2']:setString(tostring(mastery_point + 1))

    -- 아모르의 서
    local rarity_str = dragon_obj:getRarity()
    local req_count = TableMastery:getRequiredAmorQuantity(rarity_str, mastery_lv + 1)
    local own_count = g_userData:get('amor') or 0
    local str = Str('{1} / {2}', own_count, req_count)
    if (req_count <= own_count) then
        str = '{@possible}' .. str
    else
        str = '{@impossible}' .. str
    end
    vars['amorNumberLabel']:setString(str)
end

-------------------------------------
-- function refresh_skillInfo
-- @brief 특성 스킬 정보 (오른쪽 탭)
-------------------------------------
function UI_DragonMastery:refresh_skillInfo(tier, index)
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local rarity_str = dragon_obj:getRarity()
    local role_str = dragon_obj:getRole()

    local vars = self.vars

    -- 특성 스킬 ID
    local mastery_skill_id = TableMasterySkill:makeMasterySkillID(rarity_str, role_str, tier, index)

    -- 특성 스킬 LV
    local mastery_skill_lv = dragon_obj:getMasterySkilLevel(mastery_skill_id)

    vars['skillNode']:removeAllChildren()
    local ui = UI_DragonMasterySkillCard(mastery_skill_id, mastery_skill_lv)
    vars['skillNode']:addChild(ui.root)

    -- 특성 스킬 설명 
    local desc = TableMasterySkill:getMasterySkillOptionDesc(mastery_skill_id, math_max(mastery_skill_lv, 1), true)
    vars['skillInfoLabel1']:setString(desc or '')

	do -- 스킬 레벨 미리보기용 변수
		self.m_currIdx = mastery_skill_lv
		self.m_currLV = math_max(1, mastery_skill_lv)
		self.m_maxLV = TableMasterySkill:getMaxMasteryLV(tier)
		self.m_numberLoop = NumberLoop(self.m_maxLV)
		self.m_numberLoop:setCurr(self.m_currLV)
		self:toggleButton()
	end

    do -- 특성 스킬 포인트
        local req_count = 1
        local own_count = dragon_obj:getMasteryPoint()
        local str = Str('{1} / {2}', own_count, req_count)
        if (req_count <= own_count) then
            str = '{@possible}' .. str
        else
            str = '{@impossible}' .. str
        end
        vars['useSkillPointLabel']:setString(str)
    end
end

-------------------------------------
-- function toggleButton
-------------------------------------
function UI_DragonMastery:toggleButton()
	local vars = self.vars

	-- 레벨에 따라 + 또는 - 버튼 false
	vars['minusBtn']:setEnabled(true)
	vars['plusBtn']:setEnabled(true)

	if (self.m_currLV >= self.m_maxLV) then
		vars['plusBtn']:setEnabled(false)
    end

	if (self.m_currLV <= 1) then
		vars['minusBtn']:setEnabled(false)
	end

    do -- 레벨 표시
        vars['skillNumberLabel']:setString(string.format('%d / %d', self.m_currLV, self.m_maxLV))
        vars['skillNumberLabel']:setColor(COLOR['DEEPGRAY'])
        vars['nowNode']:setVisible(false)

        if (self.m_currIdx == self.m_currLV) then
            vars['skillNumberLabel']:setColor(COLOR['CURR_LV'])
            vars['nowNode']:setVisible(true)
        end
    end

    -- 특성 스킬 설명 
    local mastery_skill_id = self:getCurrMasterySkillID()

    if (self.m_currIdx == self.m_currLV) then
        vars['skillInfoLabel1']:setColor(COLOR['WHITE'])
        local desc = TableMasterySkill:getMasterySkillOptionDesc(mastery_skill_id, math_max(self.m_currLV, 1), true)
        vars['skillInfoLabel1']:setString(desc or '')
    else
        vars['skillInfoLabel1']:setColor(COLOR['DEEPGRAY'])
        local desc = TableMasterySkill:getMasterySkillOptionDesc(mastery_skill_id, math_max(self.m_currLV, 1), false)
        vars['skillInfoLabel1']:setString(desc or '')
    end
end


-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonMastery:getDragonList()
    local dragon_dic = g_dragonsData:getDragonsList()

    -- 특성 조건이 되지 않는 드래곤 제거 (6성 60레벨)
    for oid, v in pairs(dragon_dic) do
        if (v:isMaxGradeAndLv() == false) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트 : 레벨업
-- @override
-------------------------------------
function UI_DragonMastery:getDragonMaterialList(doid)
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonMastery:click_dragonMaterial(t_dragon_data)
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonMastery:refresh_materialDragonIndivisual(doid)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonMastery:refresh_selectedMaterial()
end

-------------------------------------
-- function refresh_stats
-- @brief 능력치
-------------------------------------
function UI_DragonMastery:refresh_stats(t_dragon_data, lv)
end

-------------------------------------
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-- @override
-------------------------------------
function UI_DragonMastery:createDragonCardCB(ui, data)
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief 재료 카드 만든 후..
-------------------------------------
function UI_DragonMastery:createMtrlDragonCardCB(ui, data)
end

-------------------------------------
-- function click_masteryLvUpBtn
-- @brief 특성 레벨업 버튼
-------------------------------------
function UI_DragonMastery:click_masteryLvUpBtn()
    local possible = false
    local msg = '(테스트)레벨업 불가로 처리 중'

    if (not possible) then
        UIManager:toastNotificationRed(msg)
        local vars = self.vars

        cca.uiImpossibleAction(vars['amorBtn'])
        cca.uiImpossibleAction(vars['dragonIconNode2'])
        return
    end
end

-------------------------------------
-- function click_amorBtn
-- @brief 특성 레벨업 버튼
-------------------------------------
function UI_DragonMastery:click_amorBtn()
    UI_ItemInfoPopup(ITEM_ID_AMOR)
end

-------------------------------------
-- function click_skillEnhanceBtn
-- @brief 특성 스킬 강화
-------------------------------------
function UI_DragonMastery:click_skillEnhanceBtn()
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local tier, index = self.m_masteryBoardUI:getSelectedTierAndIndex()
    local rarity_str = dragon_obj:getRarity()
    local role_str = dragon_obj:getRole()
    local mastery_skill_id = TableMasterySkill:makeMasterySkillID(rarity_str, role_str, tier, index)

    local doid = dragon_obj['doid']
    local mastery_id = mastery_skill_id

    local function cb_func(ret)
        self:refresh()
    end
    local function fail_cb()
    end

    self:request_mastery_skillup(doid, mastery_id, cb_func, fail_cb)
end

-------------------------------------
-- function onChange_selectedSkill
-- @brief 선택된 특성 스킬이 변경되었을 경우
-------------------------------------
function UI_DragonMastery:onChange_selectedSkill(tier, index)
    self:refresh_skillInfo(tier, index)
end

-------------------------------------
-- function getCurrMasterySkillID
-- @brief
-------------------------------------
function UI_DragonMastery:getCurrMasterySkillID()
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local tier, index = self.m_masteryBoardUI:getSelectedTierAndIndex()
    local rarity_str = dragon_obj:getRarity()
    local role_str = dragon_obj:getRole()
    local mastery_skill_id = TableMasterySkill:makeMasterySkillID(rarity_str, role_str, tier, index)

    return mastery_skill_id
end



-------------------------------------
-- function request_mastery_skillup
-- @brief
-------------------------------------
function UI_DragonMastery:request_mastery_skillup(doid, mastery_id, cb_func, fail_cb)
    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID

    --[[
    -- 에러코드 처리
    local function response_status_cb(ret)
        self:refresh_fail(rid, rcnt)
        return true
    end

    -- 통신실패 처리
    local function response_fail_cb(ret)
        self:refresh_fail(rid, rcnt)
        if (fail_cb) then
            fail_cb()
        end
    end
    --]]

    local function success_cb(ret)
		-- @analytics
        --Analytics:firstTimeExperience('dragon reinforcement')

		-- 드래곤 갱신
		g_dragonsData:applyDragonData(ret['modified_dragon'])

		-- 골드 갱신
		g_serverData:networkCommonRespone(ret)

        self:refresh_dragonIndivisual(doid)
		
        -- 통신 실패할 경우 원복할 골드
        --self.m_oriGold = g_userData:get('gold') 

		-- 인연포인트 (전체 갱신)
		--if (ret['relation']) then
		--	g_bookData:applyRelationPoints(ret['relation'])
		--end

		-- 드래곤 관리 UI 갱신
		--self.m_bChangeDragonList = true

		-- 강화 레벨업 시 결과화면
        --[[
		if (ret['is_rlevelup']) then
			local ui = UI_DragonReinforceResult(ret['dragon'])
			ui:setCloseCB(function()
				self:refresh_dragonIndivisual(doid)
			end)
		end
        --]]

		if (cb_func) then
			cb_func()
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/mastery_skillup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('mastery_id', mastery_id)
	--ui_network:hideLoading()
    ui_network:setRevocable(true)
    --ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    --ui_network:setFailCB(response_fail_cb)
    ui_network:request()
end

-------------------------------------
-- function click_skillLvBtn
-------------------------------------
function UI_DragonMastery:click_skillLvBtn(is_next)
	local vars = self.vars
	
	if (is_next) then
		self.m_currLV = self.m_numberLoop:next()
	else
		self.m_currLV = self.m_numberLoop:prev()
	end

	self:toggleButton()
end

--@CHECK
UI:checkCompileError(UI_DragonMastery)
