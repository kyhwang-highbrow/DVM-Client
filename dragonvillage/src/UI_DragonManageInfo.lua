local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonManageInfo
-------------------------------------
UI_DragonManageInfo = class(PARENT,{
        -- 서버상의 드래곤 정보가 마지막으로 변경된 시간 (refresh 체크 용도)
        m_dragonListLastChangeTime = 'timestamp',

        m_dragonInfoBoardUI = 'UI_DragonInfoBoard',

        m_startSubMenu = '',
        m_tNotiIcon = 'table<Sprite>',

        -- SubMenu 종료 후 m_force_close 설정되어있으면 강제로 닫아줌
        m_force_close = 'boolean',

        m_dragonSkinManageUI = 'UI_DragonSkinManageInfo',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManageInfo:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManageInfo'
    
    self.m_subCurrency = 'memory_myth'  -- 상단 유저 재화 정보 중 서브 재화
    self.m_bVisible = true or false
    self.m_titleStr = nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_bShowInvenBtn = true 
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageInfo:init(doid, sub_menu)
    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData()

    local vars = self:load('dragon_manage.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonManageInfo')

    self:sceneFadeInAction()

    self.m_tNotiIcon = {}
    self.m_force_close = false

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    self.m_dragonListLastChangeTime = g_dragonsData:getLastChangeTimeStamp()

    self.m_startSubMenu = sub_menu
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_DragonManageInfo:init_after()
    PARENT.init_after(self)

    local sub_menu = self.m_startSubMenu
    if sub_menu then
        self:clickSubMenu(sub_menu)
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManageInfo:initUI()
    local vars = self.vars
    self:init_dragonTableView()

    -- 드래곤 정보 보드 생성
    self.m_dragonInfoBoardUI = UI_DragonInfoBoard()

    if (IS_TEST_MODE()) then
        self.m_dragonInfoBoardUI.vars['equipmentBtn']:setVisible(true)
        self.m_dragonInfoBoardUI.vars['equipmentBtn']:registerScriptTapHandler(function() self:click_equipmentBtn() end)
    else
        self.m_dragonInfoBoardUI.vars['equipmentBtn']:setVisible(false)
    end
    self.vars['infoNode']:addChild(self.m_dragonInfoBoardUI.root)
    --self.root:addChild(self.m_dragonInfoBoardUI.root)
    -- @TODO77

    -- 드래곤 실리소스
    if vars['dragonNode'] then
        self.m_dragonAnimator = UIC_DragonAnimator()
        vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
    end
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManageInfo:initButton()
    local vars = self.vars
    
	-- 우측 버튼
    do 
        -- 레벨업
        vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)

        -- 특성
        vars['masteryBtn']:registerScriptTapHandler(function() self:click_masteryBtn() end)

        -- 승급
        vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)

        -- 진화
        vars['evolutionBtn']:registerScriptTapHandler(function() self:click_evolutionBtn() end)

        -- 외형 변환
        vars['transformBtn']:registerScriptTapHandler(function() self:click_transformBtn() end)

        -- 친밀도
        vars['friendshipBtn']:registerScriptTapHandler(function() self:click_friendshipBtn() end)

		-- 스킬 강화
        vars['skillEnhanceBtn']:registerScriptTapHandler(function() self:click_skillEnhanceBtn() end)

		-- 강화
        vars['reinforceBtn']:registerScriptTapHandler(function() self:click_reinforceBtn() end)
    end

	-- 좌측 버튼
    do 
        -- 룬
        vars['runeBtn']:registerScriptTapHandler(function() self:click_runeBtn() end)
    end

	-- 하단 버튼
    do 
        -- 대표
        vars['leaderBtn']:registerScriptTapHandler(function() self:click_leaderBtn() end)

        -- 잠금
        vars['lockBtn']:registerScriptTapHandler(function() self:click_lockBtn() end)

        -- 작별
        vars['goodbyeBtn']:registerScriptTapHandler(function() self:click_goodbyeBtn() end) -- 2020-11-10 드래곤 레벨업 개편으로 변경
		
		-- 일괄 작별
		vars['goodbyeSelectBtn']:registerScriptTapHandler(function() self:click_goodbyeSelectBtn() end)
		
		-- 평가
		vars['assessBtn']:registerScriptTapHandler(function() self:click_assessBtn() end)

        -- 도감
        vars['bookBtn1']:registerScriptTapHandler(function() self:click_bookBtn() end)
        vars['bookBtn2']:registerScriptTapHandler(function() self:click_bookBtn() end)

		-- 조합
		vars['combineBtn']:registerScriptTapHandler(function() self:click_combineBtn() end)

        -- 팀보너스
		vars['teamBonusBtn']:registerScriptTapHandler(function() self:click_teamBonusBtn() end)

        -- 슈퍼슬라임 합성
        vars['slimeCombineBtn']:registerScriptTapHandler(function() self:click_slimeCombineBtn() end)

        -- 리콜
        vars['recallBtn']:registerScriptTapHandler(function() self:click_recallBtn() end)

        -- 스킨
        vars['skinBtn']:registerScriptTapHandler(function() self:click_skinBtn() end)
    end

    do -- 기타 버튼
        -- 장비 개별 버튼 1~3
        --[[ @TODO77
        vars['equipSlotBtn1']:registerScriptTapHandler(function() self:click_runeBtn(1) end)
        vars['equipSlotBtn2']:registerScriptTapHandler(function() self:click_runeBtn(2) end)
        vars['equipSlotBtn3']:registerScriptTapHandler(function() self:click_runeBtn(3) end)
        vars['equipSlotBtn4']:registerScriptTapHandler(function() self:click_runeBtn(4) end)
        vars['equipSlotBtn5']:registerScriptTapHandler(function() self:click_runeBtn(5) end)
        vars['equipSlotBtn6']:registerScriptTapHandler(function() self:click_runeBtn(6) end)
        --]]
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageInfo:refresh()
    self:refresh_buttonState()

    local t_dragon_data = self.m_selectDragonData

    self.m_dragonInfoBoardUI:refresh(t_dragon_data)

    if (not t_dragon_data) then
        return
    end

    -- 드래곤 기본 정보 갱신
    self:refresh_dragonBasicInfo(t_dragon_data)

    -- 리더 드래곤 여부 표시
    self:refresh_leaderDragon(t_dragon_data)

    -- 도감작 (해치, 해츨링, 성룡의 도감을 채워서 다이아를 받는 행위) 상태 갱신
    self:refresh_bookSprite(t_dragon_data)

    -- 진화/승급/스킬강화 알림 - 개발 하다가 중단 
    --self:refresh_buttonNoti()

	-- 조합 드래곤
	self:refresh_combination()

    local vars = self.vars

	-- 잠금 표시
	vars['lockSprite']:setVisible(t_dragon_data:getLock())

    -- 외형 변환 표시
    local b_transform_change = t_dragon_data:isPossibleTransformChange()
    vars['transformBtn']:setVisible(b_transform_change)
    vars['evolutionBtn']:setVisible(not b_transform_change)

    local is_myth_dragon = t_dragon_data:getRarity() == 'myth'
    --vars['upgradeBtn']:setEnabled(not is_myth_dragon)
    --vars['reinforceBtn']:setEnabled(not is_myth_dragon)
    --vars['goodbyeBtn']:setVisible(not is_myth_dragon)
    --vars['goodbyeSelectBtn']:setVisible(not is_myth_dragon)
    --vars['lockBtn']:setVisible(not is_myth_dragon)


    local doid = t_dragon_data:getObjectId()
    local is_recall_target = g_dragonsData:isDragonRecallTarget(doid)
    vars['recallBtn']:setVisible(is_recall_target)
    

    -- -- 스킨 버튼 표시
    -- -- @dhkim 23.02.14 만약 해당 드래곤에 스킨이 없다면 스킨 버튼 비활성화
    -- local struct_dragon_object = g_dragonsData:getDragonDataFromUidRef(doid)
    -- if struct_dragon_object then
    --     local did = struct_dragon_object:getDid()
    --     local is_skin_Exist = g_dragonSkinData:isDragonSkinExist(did)
    --     vars['skinBtn']:setVisible(is_skin_Exist)
    -- end

    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData_checkNumber()
end

-------------------------------------
-- function refresh_buttonState
-------------------------------------
function UI_DragonManageInfo:refresh_buttonState()
    local vars = self.vars
    local is_slime_object = self.m_bSlimeObject

	-- 우측 버튼들 초기화
    do 
        -- 레벨업
        vars['levelupBtn']:setEnabled(not is_slime_object)

        -- 승급
        vars['upgradeBtn']:setEnabled(not is_slime_object)

        -- 진화
        vars['evolutionBtn']:setEnabled(not is_slime_object)

        -- 친밀도
        vars['friendshipBtn']:setEnabled(not is_slime_object)

		-- 스킬 강화
        vars['skillEnhanceBtn']:setEnabled(not is_slime_object)

		-- 드래곤 강화
        vars['reinforceBtn']:setEnabled(not is_slime_object)

        -- 팀 보너스 
        vars['teamBonusBtn']:setVisible(not is_slime_object)

        -- 특성 버튼, 레벨업 버튼 노출 상태 갱신
        self:refresh_buttonState_masteryBtn()
    end

    -- 룬 버튼
	do
        self.m_dragonInfoBoardUI.vars['equipSlotBtn1']:setEnabled(not is_slime_object)
        self.m_dragonInfoBoardUI.vars['equipSlotBtn2']:setEnabled(not is_slime_object)
        self.m_dragonInfoBoardUI.vars['equipSlotBtn3']:setEnabled(not is_slime_object)
        self.m_dragonInfoBoardUI.vars['equipSlotBtn4']:setEnabled(not is_slime_object)
        self.m_dragonInfoBoardUI.vars['equipSlotBtn5']:setEnabled(not is_slime_object)
        self.m_dragonInfoBoardUI.vars['equipSlotBtn6']:setEnabled(not is_slime_object)
	end

	-- 좌측 버튼들 초기화
    do 
		-- 룬
		vars['runeBtn']:setVisible(not is_slime_object)

        -- 대표
        vars['leaderBtn']:setVisible(not is_slime_object)

        -- 작별
        vars['goodbyeBtn']:setVisible(not is_slime_object)
		
        -- 잠금
        vars['lockBtn']:setVisible(true)
    end

	-- 할인 이벤트
	local l_dc_event = g_fevertimeData:getDiscountEventList()
    for i, dc_target in ipairs(l_dc_event) do
        local name 
        if (dc_target == HOTTIME_SALE_EVENT.RUNE_RELEASE) then
            name = 'runeEventSprite'

        elseif (dc_target == HOTTIME_SALE_EVENT.RUNE_ENHANCE) then
            name = 'runeEventSprite'

        elseif (dc_target == HOTTIME_SALE_EVENT.SKILL_MOVE) then
            name = 'skillEnhanceEventSprite'

        -- 드래곤 강화 할인 이벤트
        elseif (dc_target == HOTTIME_SALE_EVENT.DRAGON_REINFORCE) then
            name = 'reinforceEventSprite'

        elseif (dc_target == FEVERTIME_SALE_EVENT.MASTERY_DC) then
            name = 'masteryEventSprite'

        end

        if (name) then
           g_fevertimeData:setDiscountEventNode(dc_target, vars, name)
        end
    end
	
    -- 드래곤 개발 API
    self.m_dragonInfoBoardUI.vars['equipmentBtn']:setEnabled(not is_slime_object)
end

-------------------------------------
-- function refresh_buttonState_masteryBtn
-- @breif 레벨업 버튼, 특성 버튼 상태 갱신
-------------------------------------
function UI_DragonManageInfo:refresh_buttonState_masteryBtn()
    local vars = self.vars
    local is_slime_object = self.m_bSlimeObject

    -- 6성 60레벨 드래곤은 레벨업 버튼 대신 특성 버튼이 활성
    local levelupBtn_visible = false
    local masteryBtn_visible = false
    local is_levelup_enabled = true

    -- 슬라임일 경우 레벨업 버튼 노출
    if is_slime_object then
        levelupBtn_visible = true
    else
        -- StructDragonObject or StructSlimeObject
        local dragon_obj = self:getSelectDragonObj()
        local is_myth_dragon = self.m_selectDragonData and self.m_selectDragonData:getRarity() == 'myth'

        if (not dragon_obj) then
            levelupBtn_visible = true
        elseif dragon_obj:isMaxGradeAndLv() then
            if (is_myth_dragon) or (dragon_obj:isMonster()) then
                levelupBtn_visible = true
                is_levelup_enabled = false
            else
                masteryBtn_visible = true
            end
        else
            levelupBtn_visible = true
        end
    end

    vars['masteryBtn']:setVisible(masteryBtn_visible)
    vars['levelupBtn']:setVisible(levelupBtn_visible)
    vars['levelupBtn']:setEnabled(is_levelup_enabled)

    -- 마스터리 할인 피버타임 적용
    if (g_fevertimeData:isActiveFevertime_masteryDc()) then
        vars['masteryEventSprite']:setVisible(true)
    end
end

-------------------------------------
-- function refresh_buttonNoti
-------------------------------------
function UI_DragonManageInfo:refresh_buttonNoti()
    local doid = self.m_selectDragonOID
    local vars = self.vars

    local l_target_content = {'upgrade', 'evolution', 'skillEnhance'}
    local t_possible = {
        ['upgrade'] = g_dragonsData:possibleUpgradeable(doid),
        ['evolution'] = g_dragonsData:possibleDragonEvolution(doid),
        ['skillEnhance'] = g_dragonsData:possibleDragonSkillEnhance(doid),
    }

    for i, content in pairs(l_target_content) do
        if t_possible[content] then
            if (self.m_tNotiIcon[content]) then
                self.m_tNotiIcon[content]:setVisible(true)

            else
                local icon = IconHelper:getNotiIcon()
	            icon:setDockPoint(cc.p(1, 1))
	            icon:setPosition(-13, -5)
	            vars[content .. 'Btn']:addChild(icon)
	            self.m_tNotiIcon[content] = icon

            end

        else
            if (self.m_tNotiIcon[content]) then
                self.m_tNotiIcon[content]:setVisible(false)
            end
        end
    end
    
end

-------------------------------------
-- function refresh_combination
-- @brief 조합
-------------------------------------
function UI_DragonManageInfo:refresh_combination()
	local vars = self.vars
	local did = self.m_selectDragonData['did']
	local comb_did = TableDragonCombine:getCombinationDid(did)

	-- 조합 드래곤 있는 경우
	if (comb_did) then
		vars['combineBtn']:setVisible(true)
		vars['combineNode']:removeAllChildren()

		local comb_card = MakeBirthDragonCard(comb_did)
		comb_card.vars['clickBtn']:setEnabled(false)

		vars['combineNode']:addChild(comb_card.root)

	-- 없음
	else
		vars['combineBtn']:setVisible(false)

	end
end

-------------------------------------
-- function refresh_dragonBasicInfo
-- @brief 드래곤 기본 정보 갱신
-------------------------------------
function UI_DragonManageInfo:refresh_dragonBasicInfo(t_dragon_data)
    local vars = self.vars
    local vars_key = self.vars_key

    local attr = t_dragon_data:getAttr()

    -- 배경
    if self:checkVarsKey('attrBgNode', attr) then
        vars['attrBgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['attrBgNode']:addChild(animator.m_node)
    end

    -- 드래곤 실리소스
    if self.m_dragonAnimator then
        -- 외형 변환 적용 Animator
        self.m_dragonAnimator:setDragonAnimatorByTransform(t_dragon_data)
    end
end

-------------------------------------
-- function refresh_leaderDragon
-- @brief
-------------------------------------
function UI_DragonManageInfo:refresh_leaderDragon(t_dragon_data)
    local t_dragon_data = (t_dragon_data or self.m_selectDragonData)
    local doid = nil
    if (t_dragon_data) then
        doid = t_dragon_data['id']
    end
    local vars = self.vars

    -- 리더 드래곤
    if vars['leaderSprite'] then
        if doid then
            local is_leader = g_dragonsData:isLeaderDragon(doid)
            vars['leaderSprite']:setVisible(is_leader)
        else
            vars['leaderSprite']:setVisible(false)
        end
    end
end

-------------------------------------
-- function refresh_bookSprite
-- @brief 도감작 (해치, 해츨링, 성룡의 도감을 채워서 다이아를 받는 행위) 상태 갱신
-------------------------------------
function UI_DragonManageInfo:refresh_bookSprite(t_dragon_data)
    local vars = self.vars
    local did = t_dragon_data['did']
    
    -- is_exist가 true이면 해당 did의 해치, 해츨링, 성룡으 도감작이 끝난 상태
    local is_exist = g_bookData:isExist_all(did)
    
    -- 상태에 따라 버튼 종류 구분 (bookBtn2가 도감작이 남아있는 경우 체크 아이콘 표시)
    vars['bookBtn1']:setVisible(is_exist)
    vars['bookBtn2']:setVisible(not is_exist)
end


-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManageInfo:click_exitBtn()
    -- 노티 정보를 갱신하기 위해서 호출
    g_highlightData:setDirty(true)

    self:close()
end

-------------------------------------
-- function click_levelupBtn
-- @brief 드래곤 레벨업 버튼
-------------------------------------
function UI_DragonManageInfo:click_levelupBtn()
    local doid = self.m_selectDragonOID

    do -- 레벨업이 가능한지 확인
        local possible, msg = g_dragonsData:impossibleLevelupForever(doid)
        if (possible) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    -- self:openSubManageUI(UI_DragonLevelUp) 2020-11-10 드래곤 레벨업 시스템 개편으로 인한 변경
    self:openSubManageUI(UI_DragonLevelUpNew)
end

-------------------------------------
-- function click_masteryBtn
-- @brief 특성 버튼
-------------------------------------
function UI_DragonManageInfo:click_masteryBtn()
    local doid = self.m_selectDragonOID
    local did = self.m_selectDragonData['did']

    -- 슬라임
    if (self.m_bSlimeObject == true) then
        return
    end

    -- 몬스터 (1~2성)
    if (TableDragon:isUnderling(did) == true) then
        return
    end

    local dragon_obj = self:getSelectDragonObj()

    -- 드래곤 정보 없음
    if (not dragon_obj) then    
        return
    end

    -- 최대 등급, 최대 레벨 아님
    if (dragon_obj:isMaxGradeAndLv() == false) then
        return
    end

    -- 위의 모든 문제점이 없을 때 특성 UI 진입
    self:openSubManageUI(UI_DragonMasteryNew)
end

-------------------------------------
-- function click_upgradeBtn
-- @brief 승급 버튼
-------------------------------------
function UI_DragonManageInfo:click_upgradeBtn()
    local doid = self.m_selectDragonOID

    do -- 최대 등급인지 확인
        local upgradeable, msg = g_dragonsData:impossibleUpgradeForever(doid)
        if (upgradeable) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    self:openSubManageUI(UI_DragonUpgrade)
end

-------------------------------------
-- function click_evolutionBtn
-- @brief 진화 버튼
-------------------------------------
function UI_DragonManageInfo:click_evolutionBtn()
    local doid = self.m_selectDragonOID
	local did = self.m_selectDragonData['did']
	
	do -- 진화 가능 여부
        local possible, msg = g_dragonsData:impossibleEvolutionForever(doid)
        if (possible) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    self:openSubManageUI(UI_DragonEvolution)
end

-------------------------------------
-- function click_transformBtn
-- @brief 외형 변환 버튼
-------------------------------------
function UI_DragonManageInfo:click_transformBtn()
    self:openSubManageUI(UI_DragonTransformChange)
end

-------------------------------------
-- function click_friendshipBtn
-- @brief 친밀도 버튼
-------------------------------------
function UI_DragonManageInfo:click_friendshipBtn()
    local doid = self.m_selectDragonOID

    do -- 최대 친밀도인지 확인
        local upgradeable, msg = g_dragonsData:impossibleFriendshipForever(doid)
        if (upgradeable) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    self:openSubManageUI(UI_DragonFriendship)
end

-------------------------------------
-- function click_skillEnhanceBtn
-- @brief 스킬 강화 버튼
-------------------------------------
function UI_DragonManageInfo:click_skillEnhanceBtn()
	-- 스킬 강화 가능 여부
	local possible, msg = g_dragonsData:impossibleSkillEnhanceForever(self.m_selectDragonOID)
	if (possible) then
		UIManager:toastNotificationRed(msg)
        return
	end
    
    self:openSubManageUI(UI_DragonSkillEnhance)
end

-------------------------------------
-- function click_reinforceBtn
-- @brief 친밀도 버튼
-------------------------------------
function UI_DragonManageInfo:click_reinforceBtn()
	-- 스킬 강화 가능 여부
	local possible, msg = g_dragonsData:impossibleReinforcementForever(self.m_selectDragonOID)

	if (possible) then
		UIManager:toastNotificationRed(msg)
        return
	end

    self:openSubManageUI(UI_DragonReinforcement)
end

-------------------------------------
-- function click_runeBtn
-- @brief 룬 버튼
-------------------------------------
function UI_DragonManageInfo:click_runeBtn(slot_idx)
    self:openSubManageUI(UI_DragonRunes, slot_idx)
end

-------------------------------------
-- function openSubManageUI
-- @brief
-------------------------------------
function UI_DragonManageInfo:openSubManageUI(sub_manage_ui, add_param)
    -- 선탠된 드래곤과 정렬 설정
    local doid = self.m_selectDragonOID

    local ui = sub_manage_ui(doid, add_param)

    -- UI종료 후 콜백
    local function close_cb()
        -- 서브메뉴 종료 후 바로 닫아줌
        if (self.m_force_close) then
            self:click_exitBtn()
            return
        end

        if ui.m_bChangeDragonList then
            self:init_dragonTableView()
            local dragon_object_id = ui.m_selectDragonOID
            local b_force = true
            self:setSelectDragonData(dragon_object_id, b_force)
        else
            if (self.m_selectDragonOID ~= ui.m_selectDragonOID) then
                local b_force = true
                self:setSelectDragonData(ui.m_selectDragonOID, b_force)
            end
        end

        do -- 정렬
            self:apply_dragonSort_saveData()
        end

        self:sceneFadeInAction()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_equipmentBtn
-- @brief (임시로 드래곤 개발 API 팝업 호출)
-------------------------------------
function UI_DragonManageInfo:click_equipmentBtn()
    if (not self.m_selectDragonOID) then
        return
    end

    local ui = UI_DragonDevApiPopup(self.m_selectDragonOID)
    local function close_cb()
        self:refresh_dragonIndivisual(self.m_selectDragonOID)
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_leaderBtn
-- @brief 대표드래곤 지정
-------------------------------------
function UI_DragonManageInfo:click_leaderBtn()
    if (not self.m_selectDragonOID) then
        return
    end

    local leader_dragon = g_dragonsData:getLeaderDragon()
    if (leader_dragon and (leader_dragon['id'] == self.m_selectDragonOID)) then
        UIManager:toastNotificationRed(Str('이미 대표 드래곤으로 설정되어 있습니다.'))
        return
    end

    local function yes_cb()
        local function cb_func(ret)
            UIManager:toastNotificationGreen(Str('대표 드래곤으로 설정되었습니다.'))
            
			self:refreshDragonCard(ret['modified_dragons'], {}, 'leader')

            -- 리더 드래곤 여부 표시
            self:setSelectDragonDataRefresh()
            self:refresh_leaderDragon()
        end

		g_dragonsData:request_setLeaderDragon('lobby', self.m_selectDragonOID, cb_func)
    end

    
    local msg = Str('대표 드래곤으로 설정하시겠습니까?')
    local submsg = Str('대표 드래곤은 마을에서 1시간마다 테이머에게 선물을 줍니다.\n마을에서 대표 드래곤을 터치해보세요!')
    MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, yes_cb)
end

-------------------------------------
-- function refreshDragonCard
-- @brief 카드를 갱신한다.
-------------------------------------
function UI_DragonManageInfo:refreshDragonCard(modified_dragons, modified_slimes, ref_type)
	-- 드래곤
    for i,v in pairs(modified_dragons) do
        local doid = v['id']
        local item = self.m_tableViewExt:getItem(doid)

        if item then
            item['data'] = StructDragonObject(v)
            if item['ui'] then
				item['ui'].m_dragonData = item['data']
				
				if (ref_type == 'leader') then
					item['ui']:refresh_LeaderIcon()

				elseif (ref_type == 'lock') then
					item['ui']:refresh_lock()

				end
            end
        end
    end

	-- 슬라임
	for i,v in pairs(modified_slimes) do
        local doid = v['id']
        local item = self.m_tableViewExt:getItem(doid)

        if item then
            item['data'] = StructSlimeObject(v)
            if item['ui'] then
				item['ui'].m_dragonData = item['data']
				
				if (ref_type == 'lock') then
					item['ui']:refresh_lock()

				end
            end
        end
    end

end

-------------------------------------
-- function click_lockBtn
-- @brief 잠금
-- @comment ,로 oid 보내는것들은 다 리팩토링 해야함
-------------------------------------
function UI_DragonManageInfo:click_lockBtn()
    if (not self.m_selectDragonOID) then
        return
    end
	
	local struct_dragon_data
	local doids = ''
	local soids = ''
	if (self.m_bSlimeObject) then
		soids = self.m_selectDragonOID
		struct_dragon_data = g_slimesData:getSlimeObject(self.m_selectDragonOID)
	else
		doids = self.m_selectDragonOID
		struct_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)
	end

	local lock = (not struct_dragon_data:getLock())

	--[[
		-- 드래곤 성장일지 제거
		local start_dragon_doid = g_userData:get('start_dragon')
	    if (start_dragon_doid) and (not g_dragonDiaryData:isClearAll()) then
	        
	        if (doids == start_dragon_doid) then
	            local msg = Str('육성 퀘스트가 진행중인 드래곤입니다.\n퀘스트를 모두 수행해야 잠금 해제가 가능합니다.')
	            MakeSimplePopup(POPUP_TYPE.OK, msg)
	            return
	        end
	    end
	--]]

    -- 슬라임이 아닐 경우에만 드래곤 성장일지 잠금 체크
    if (not self.m_bSlimeObject) then
        -- 드래곤 성장일지 (퀘스트 진행중이면 잠금 풀 수 없음)
        if (g_dragonDiaryData:isSelectedDragonLock(doids)) then
            local msg = ''
	    	if (not g_dragonDiaryData:isEnable()) then
	    		msg = Str('함께 모험을 시작한 드래곤입니다.\n5성 달성 시 잠금 해제가 가능합니다')
	    	else
	    		msg = Str('육성 퀘스트가 진행중인 드래곤입니다.\n퀘스트를 모두 수행해야 잠금 해제가 가능합니다.')
	    	end
	    	
	    	MakeSimplePopup(POPUP_TYPE.OK, msg)
	    	return
        end
    end

	local function cb_func(ret)
        -- 선택된 드래곤 데이터 최신화(잠금 여부 수정)
        self:setSelectDragonDataRefresh()

		-- 메인 잠금 표시 해제
		self.vars['lockSprite']:setVisible(lock)
		
		-- 잠금 안내 팝업
		local msg = lock and Str('잠금되었습니다.') or Str('잠금이 해제되었습니다.')
		UIManager:toastNotificationGreen(msg)

		-- 하단 리스트 갱신
		self:refreshDragonCard(ret['modified_dragons'], ret['modified_slimes'], 'lock')
	end

	g_dragonsData:request_dragonLock(doids, soids, lock, cb_func)
end

-------------------------------------
-- function click_goodbyeBtn
-- @brief 드래곤 레벨업 시스템 개편으로 
-- 새로 만든 개별 작별
-------------------------------------
function UI_DragonManageInfo:click_goodbyeBtn()
	require('UI_DragonGoodbyePopup')

    if (not self.m_selectDragonOID) then
        return
    end

	local oid = self.m_selectDragonOID
    
	-- 작별 가능한지 체크
	local possible, msg = g_dragonsData:possibleMaterialDragon(oid)
	if (not possible) then
		UIManager:toastNotificationRed(msg)
        return false
	end
	
	local dragon_data = self.m_selectDragonData
	local msg = g_dragonsData:dragonStateStr(oid, nil)

    local idx = self.m_tableViewExt:getIndexFromId(oid) or 1

	-- 작별 연출
    local function show_effect(ret)
        
        local finish_cb = function()
		    -- 테이블 아이템갱신
		    self:init_dragonTableView()

		    -- 정렬
		    self:apply_dragonSort_saveData()

            local next_idx = math_min(idx, self.m_tableViewExt:getItemCount())
            local next_doid = self.m_tableViewExt:getIdFromIndex(next_idx)

            -- 기존에 선택되어 있던 드래곤 교체
		    self:setDefaultSelectDragon(next_doid)
	    end

        local dragon_data = self.m_selectDragonData
        local info_data = ret
        local ui = UI_DragonGoodbyeResult(dragon_data, info_data)
        
		ui:setCloseCB(finish_cb)
    end

    local ui = UI_DragonGoodbyePopup(oid, dragon_data, msg, show_effect)
end

-------------------------------------
-- function click_goodbyeSelectBtn
-- @brief 일괄 작별
-------------------------------------
function UI_DragonManageInfo:click_goodbyeSelectBtn()
    require('UI_DragonGoodbyeSelect')
    local ui = UI_DragonGoodbyeSelect()
	
    local oid = self.m_selectDragonOID
    local idx = self.m_tableViewExt:getIndexFromId(oid) or 1

    local function close_cb()
	    if ui.m_bChangeDragonList then
			-- 테이블 아이템갱신
			self:init_dragonTableView()

			-- 정렬
			self:apply_dragonSort_saveData()

            local next_idx = math_min(idx, self.m_tableViewExt:getItemCount())
            local next_doid = self.m_tableViewExt:getIdFromIndex(next_idx)

			-- 기존에 선택되어 있던 드래곤 교체
			self:setDefaultSelectDragon(next_doid)

            self:sceneFadeInAction()
		end
	end
	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_assessBtn
-- @brief 평가 게시판
-------------------------------------
function UI_DragonManageInfo:click_assessBtn()
	UI_DragonBoardPopup(self.m_selectDragonData)
end

-------------------------------------
-- function click_bookBtn
-- @brief 도감
-------------------------------------
function UI_DragonManageInfo:click_bookBtn()
    local t_dragon_data = self.m_selectDragonData

	local did = t_dragon_data['did']
    local grade = t_dragon_data['grade']
    local evolution = t_dragon_data['evolution']

    UI_BookDetailPopup.open(did, grade, evolution)
end

-------------------------------------
-- function click_combineBtn
-- @brief 조합 하러가기
-------------------------------------
function UI_DragonManageInfo:click_combineBtn()
	local did = self.m_selectDragonData['did']
	local comb_did = TableDragonCombine:getCombinationDid(did)

	if (comb_did) then
		local ui = UI_HatcheryCombinePopup(comb_did)
		ui:setCloseCB(function()
			if (ui:isDirty()) then
				-- 테이블 아이템갱신
				self:init_dragonTableView()

				-- 기존에 선택되어 있던 드래곤 교체
				self:setDefaultSelectDragon()

				-- 정렬
				self:apply_dragonSort_saveData()
			end
		end)
	end
end

-------------------------------------
-- function click_teamBonusBtn
-- @brief 팀 보너스
-------------------------------------
function UI_DragonManageInfo:click_teamBonusBtn()
    local sel_did = self.m_selectDragonData['did']
	UI_TeamBonus(TEAM_BONUS_MODE.DRAGON, nil, sel_did)
end

-------------------------------------
-- function click_slimeCombineBtn
-- @brief 슈퍼 슬라임 합성
-------------------------------------
function UI_DragonManageInfo:click_slimeCombineBtn()
    local ui = UI_DragonUpgradeCombineMaterial()

    local function close_cb()
        -- 슬라임 합성을 한 경우 
        if (ui.m_bDirty) then
            -- 테이블 아이템 갱신
			self:init_dragonTableView()

            local dragon_object_id = self.m_selectDragonOID
            local b_force = true
            self:setSelectDragonData(dragon_object_id, b_force)

            -- 정렬
			self:apply_dragonSort_saveData()
        end        
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_skinBtn
-- @brief 드래곤 스킨 버튼
-------------------------------------
function UI_DragonManageInfo:click_skinBtn()

    local t_dragon_data = self.m_selectDragonData
    if t_dragon_data then
        local did = t_dragon_data:getDid()
        local is_skin_Exist = g_dragonSkinData:isDragonSkinExist(did)
        
        if is_skin_Exist then
            self.m_dragonSkinManageUI = UI_DragonSkinManageInfo(t_dragon_data)

            local function close_cb()
                -- 테이블 아이템갱신
                self:init_dragonTableView()
        
                -- 정렬
                self:apply_dragonSort_saveData()
            end
        
            self.m_dragonSkinManageUI:setCloseCB(close_cb)
        end
    end


end

-------------------------------------
-- function click_recallBtn
-------------------------------------
function UI_DragonManageInfo:click_recallBtn()
    local t_dragon_data = self.m_selectDragonData
	local did = t_dragon_data['did']
    local doid = t_dragon_data:getObjectId()

    -- 리콜 대상 드래곤이 아닌 경우
    if (g_dragonsData:isDragonRecallTarget(doid) == false) then
        UIManager:toastNotificationRed(Str('대상이 없습니다.'))
        return
    end

    require('UI_DragonRecall')
    
	local oid = self.m_selectDragonOID
    local idx = self.m_tableViewExt:getIndexFromId(oid) or 1

    local close_cb = function()
        -- 테이블 아이템갱신
        self:init_dragonTableView()

        -- 정렬
        self:apply_dragonSort_saveData()

        local next_idx = math_min(idx, self.m_tableViewExt:getItemCount())
        local next_doid = self.m_tableViewExt:getIdFromIndex(next_idx)

        -- 기존에 선택되어 있던 드래곤 교체
        self:setDefaultSelectDragon(next_doid)
    end

    local struct_dragon_object = self.m_selectDragonData
    local ui = UI_DragonRecall(struct_dragon_object)
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function checkDragonListRefresh
-- @brief 드래곤 리스트에 변경이 있는지 확인 후 갱신
-------------------------------------
function UI_DragonManageInfo:checkDragonListRefresh()
    local is_changed = g_dragonsData:checkChange(self.m_dragonListLastChangeTime)

    if is_changed then
        self.m_dragonListLastChangeTime = g_dragonsData:getLastChangeTimeStamp()
        
        -- 드래곤 리스트 새로 생성
        self:init_dragonTableView()

        -- 정렬
        self:apply_dragonSort_saveData()
    end
end

-------------------------------------
-- function clickSubMenu
-- @brief
-------------------------------------
function UI_DragonManageInfo:clickSubMenu(sub_menu)
	-- 하위 메뉴는 정부 슬라임 이용 불가이므로 이경우 슬라임은 선택되지 않도록 한다
	self:checkSelectedDragonIsSlime()

    if (not sub_menu) then
        -- nothing to do

    elseif (sub_menu == 'level_up') then
        self:click_levelupBtn()

    elseif (sub_menu == 'grade') then
        self:click_upgradeBtn()

    elseif (sub_menu == 'evolution') then
        self:click_evolutionBtn()

    elseif (sub_menu == 'friendship') then
        self:click_friendshipBtn()

    elseif (sub_menu == 'skill_enc') then
        self:click_skillEnhanceBtn()

    elseif (sub_menu == 'rune') then
        self:click_runeBtn()

    elseif (sub_menu == 'reinforce') then
        self:click_reinforceBtn()

    elseif (sub_menu == 'mastery') then
        self:click_masteryBtn()
    elseif (sub_menu == 'recall') then
        self:click_recallBtn()

    end
end

--@CHECK
UI:checkCompileError(UI_DragonManageInfo)
