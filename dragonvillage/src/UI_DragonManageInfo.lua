local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonManageInfo
-------------------------------------
UI_DragonManageInfo = class(PARENT,{
        -- 서버상의 드래곤 정보가 마지막으로 변경된 시간 (refresh 체크 용도)
        m_dragonListLastChangeTime = 'timestamp',

        m_dragonInfoBoardUI = 'UI_DragonInfoBoard',

        m_startSubMenu = '',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManageInfo:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManageInfo'
    self.m_bVisible = true or false
    self.m_titleStr = nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageInfo:init(doid, sub_menu)
    local vars = self:load('dragon_manage.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonManageInfo')

    self:sceneFadeInAction()

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

        -- 승급
        vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)

        -- 진화
        vars['evolutionBtn']:registerScriptTapHandler(function() self:click_evolutionBtn() end)

        -- 친밀도
        vars['friendshipBtn']:registerScriptTapHandler(function() self:click_friendshipBtn() end)

		-- 스킬 강화
        vars['skillEnhanceBtn']:registerScriptTapHandler(function() self:click_skillEnhanceBtn() end)

		-- 판매
        vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
    end

	-- 좌측 버튼
    do 
        -- 룬
        vars['runeBtn']:registerScriptTapHandler(function() self:click_runeBtn() end)

        -- 대표
        vars['leaderBtn']:registerScriptTapHandler(function() self:click_leaderBtn() end)

        -- 잠금
        vars['lockBtn']:registerScriptTapHandler(function() self:click_lockBtn() end)

        -- 작별
        vars['goodbyeBtn']:registerScriptTapHandler(function() self:click_goodbyeBtn() end)

		-- 평가
		vars['assessBtn']:registerScriptTapHandler(function() self:click_assessBtn() end)
    end

    -- 상단 버튼
    do
        vars['inventoryBtn']:registerScriptTapHandler(function() self:click_inventoryBtn() end)
    end

	-- 하단 버튼
    do 
        -- 도감
        vars['collectionBtn']:registerScriptTapHandler(function() self:click_collectionBtn() end)
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

    -- 드래곤이 장착 중인 룬 정보 갱신
    --self:refresh_dragonRunes(t_dragon_data)
    -- @TODO77

    -- 리더 드래곤 여부 표시
    self:refresh_leaderDragon(t_dragon_data)

    -- 가방
    self:refresh_inventoryLabel()

	-- 잠금 표시
	self.vars['lockSprite']:setVisible(t_dragon_data:getLock())
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

        -- 판매
        vars['sellBtn']:setEnabled(true)
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

        -- 스킬 버튼
        self.m_dragonInfoBoardUI.vars['equipSlotBtn1']:setEnabled(not is_slime_object)
        self.m_dragonInfoBoardUI.vars['equipSlotBtn2']:setEnabled(not is_slime_object)
        self.m_dragonInfoBoardUI.vars['equipSlotBtn3']:setEnabled(not is_slime_object)
        self.m_dragonInfoBoardUI.vars['equipSlotBtn4']:setEnabled(not is_slime_object)
        self.m_dragonInfoBoardUI.vars['equipSlotBtn5']:setEnabled(not is_slime_object)
        self.m_dragonInfoBoardUI.vars['equipSlotBtn6']:setEnabled(not is_slime_object)
    end

    do -- 기타 버튼
        -- 장비 개별 버튼 1~3
        --[[ @TODO77
        vars['equipSlotBtn1']:setVisible(not is_slime_object)
        vars['equipSlotBtn2']:setVisible(not is_slime_object)
        vars['equipSlotBtn3']:setVisible(not is_slime_object)
        vars['equipSlotBtn4']:setVisible(not is_slime_object)
        vars['equipSlotBtn5']:setVisible(not is_slime_object)
        vars['equipSlotBtn6']:setVisible(not is_slime_object)
        --]]
    end

    -- 드래곤 개발 API
    self.m_dragonInfoBoardUI.vars['equipmentBtn']:setEnabled(not is_slime_object)
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
        self.m_dragonAnimator:setDragonAnimator(t_dragon_data['did'], t_dragon_data['evolution'], t_dragon_data:getFlv())
    end
end

-------------------------------------
-- function refresh_dragonRunes
-- @brief 드래곤이 장착 중인 룬 정보 갱신
-------------------------------------
function UI_DragonManageInfo:refresh_dragonRunes(t_dragon_data)
    local vars = self.vars

    if (t_dragon_data.m_objectType ~= 'dragon') then
        for slot=1, RUNE_SLOT_MAX do
            vars['runeSlotNode' .. slot]:removeAllChildren()
        end

        vars['runeSetNode']:removeAllChildren()
        return
    end

    do -- 장착된 룬 표시
        for slot=1, RUNE_SLOT_MAX do
            vars['runeSlotNode' .. slot]:removeAllChildren()
            local rune_obj = t_dragon_data:getRuneObjectBySlot(slot)
            if rune_obj then
                local icon = IconHelper:getItemIcon(rune_obj['item_id'], rune_obj)
                vars['runeSlotNode' .. slot]:addChild(icon)
            end
        end
    end

    do -- 룬 세트
        local rune_set_obj = t_dragon_data:getStructRuneSetObject()
        local active_set_list = rune_set_obj:getActiveRuneSetList()
        vars['runeSetNode']:removeAllChildren()

        local l_pos = getSortPosList(70, #active_set_list)
        for i,set_id in ipairs(active_set_list) do
            local ui = UI()
            ui:load('dragon_manage_rune_set.ui')

            -- 색상 지정
            local c3b = TableRuneSet:getRuneSetColorC3b(set_id)
            ui.vars['runeBgSprite']:setColor(c3b)

            -- 세트 이름
            local set_name = TableRuneSet:getRuneSetName(set_id)
            ui.vars['runeSetLabel']:setString(set_name)

            -- AddCHild, 위치 지정
            vars['runeSetNode']:addChild(ui.root)
            ui.root:setPositionX(l_pos[i])
        end
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
-- function refresh_inventoryLabel
-- @brief
-------------------------------------
function UI_DragonManageInfo:refresh_inventoryLabel()
    local vars = self.vars
    local inven_type = 'dragon'
    local dragon_count = g_dragonsData:getDragonsCnt()
    local max_count = g_inventoryData:getMaxCount(inven_type)
    self.vars['inventoryLabel']:setString(Str('{1}/{2}', dragon_count, max_count))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManageInfo:click_exitBtn()
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

    self:openSubManageUI(UI_DragonLevelUp)
end

-------------------------------------
-- function click_upgradeBtn
-- @brief 승급 버튼
-------------------------------------
function UI_DragonManageInfo:click_upgradeBtn()
    local doid = self.m_selectDragonOID

    do -- 최대 등급인지 확인
        local upgradeable, msg = g_dragonsData:checkMaxUpgrade(doid)
        if (not upgradeable) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    self:openSubManageUI(UI_DragonUpgradeNew)
end

-------------------------------------
-- function click_evolutionBtn
-- @brief 진화 버튼
-------------------------------------
function UI_DragonManageInfo:click_evolutionBtn()
    local doid = self.m_selectDragonOID
	local did = self.m_selectDragonData['did']
	
	do -- 진화 가능 여부
        local possible, msg = g_dragonsData:checkDragonEvolution(doid)
        if (not possible) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    self:openSubManageUI(UI_DragonManagementEvolution)
end

-------------------------------------
-- function click_friendshipBtn
-- @brief 친밀도 버튼
-------------------------------------
function UI_DragonManageInfo:click_friendshipBtn()
    self:openSubManageUI(UI_DragonFriendship)
end

-------------------------------------
-- function click_skillEnhanceBtn
-- @brief 스킬 강화 버튼
-------------------------------------
function UI_DragonManageInfo:click_skillEnhanceBtn()
	-- 스킬 강화 가능 여부
	local possible, msg = g_dragonsData:checkDragonSkillEnhancable(self.m_selectDragonOID)
	if (not possible) then
		UIManager:toastNotificationRed(msg)
        return
	end

    self:openSubManageUI(UI_DragonSkillEnhance)
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

    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('대표 드래곤으로 설정하시겠습니까?'), yes_cb)
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
            item['data'] = clone(v)
            if item['ui'] then
				item['ui'].m_dragonData = StructDragonObject(v)
				
				if (ref_type == 'leader') then
					item['ui']:refresh_LeaderIcon()

				elseif (ref_type == 'lock') then
					item['ui']:refresh_Lock()

				end
            end
        end
    end

	-- 슬라임
	for i,v in pairs(modified_slimes) do
        local doid = v['id']
        local item = self.m_tableViewExt:getItem(doid)

        if item then
            item['data'] = clone(v)
            if item['ui'] then
				item['ui'].m_dragonData = StructSlimeObject(v)
				
				if (ref_type == 'lock') then
					item['ui']:refresh_Lock()

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
	local function cb_func(ret)
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
-- @brief 작별
-- @comment 나중에 외부로 뺄 예정
-------------------------------------
function UI_DragonManageInfo:click_goodbyeBtn()
    if (not self.m_selectDragonOID) then
        return
    end

    -- 작별 가능한지 체크
	local possible, msg = g_dragonsData:possibleGoodbye(self.m_selectDragonOID)
	if (not possible) then
		UIManager:toastNotificationRed(msg)
        return false
	end

	local table_dragon = TableDragon()
	local did = self.m_selectDragonData['did']
	local name = table_dragon:getDragonName(did)
	local birth_grade = table_dragon:getBirthGrade(did)

	local really_warning_popup
	local rarity_warning_popup
    local network_func
    local show_effect
	local finish_cb

	-- 정말 작별 하는지 되물음
	really_warning_popup = function()
		local goodbye_str = Str('드래곤과 작별하고 다른 드래곤의 인연 포인트를 획득합니다. 정말로 {@DEEPSKYBLUE}{1}{@DESC}(와)과 작별하시겠습니까?', name)
        goodbye_str = goodbye_str .. '\n' .. Str('{@RED}(친밀도 등급이 높을수록, 더 높은 등급의 인연포인트를 얻을 확률이 증가합니다)')
		MakeSimplePopup(POPUP_TYPE.YES_NO, goodbye_str, rarity_warning_popup)
	end

	-- 레어도가 높다면 한번 더 경고
	rarity_warning_popup = function()
		-- 영웅 이상
		if (birth_grade >= 4) then
			local goodbye_str_2 = Str(' {@DEEPSKYBLUE}{1}{@DESC}(은)는 매우 희귀한 드래곤으로, 작별하게 되면 다시 복구할 수 없습니다. 그래도 {@DEEPSKYBLUE}{1}{@DESC}(와)과 작별하시겠습니까?', name)
			MakeSimplePopup(POPUP_TYPE.YES_NO, goodbye_str_2, network_func)
		else
			network_func()
		end
	end

	-- 작별 통신
	network_func = function()
		-- 복수를 고려함
		local src_doids = self.m_selectDragonOID
		g_dragonsData:request_dragonGoodbye(src_doids, show_effect)
	end

    -- 작별 연출
    show_effect = function(ret)
        
        local finish_cb = function()
		    -- 테이블 아이템갱신
		    self:init_dragonTableView()

		    -- 기존에 선택되어 있던 드래곤 교체
		    self:setDefaultSelectDragon()

		    -- 정렬
		    self:apply_dragonSort_saveData()
	    end

        local dragon_data = self.m_selectDragonData
        local info_data = ret
        local ui = UI_DragonGoodbyeResult(dragon_data, info_data)
        ui:setCloseCB(finish_cb)
    end

	-- start
	really_warning_popup()
end

-------------------------------------
-- function click_sellBtn
-- @brief 드래곤 판매
-------------------------------------
function UI_DragonManageInfo:click_sellBtn()
    -- 작별 가능한지 체크
    if self.m_selectDragonOID then

		-- 슬라임은 판매 가능
        local object = g_dragonsData:getDragonObject(self.m_selectDragonOID)
        if (object.m_objectType ~= 'slime') then
	        local possible, msg = g_dragonsData:possibleMaterialDragon(self.m_selectDragonOID)
	        if (not possible) then
		        UIManager:toastNotificationRed(msg)
                return
	        end
        end
    end

	local ui = UI_DragonSell()

	local function close_cb()
	    if ui.m_bChangeDragonList then
			-- 테이블 아이템갱신
			self:init_dragonTableView()

			-- 기존에 선택되어 있던 드래곤 교체
			self:setDefaultSelectDragon()

			-- 정렬
			self:apply_dragonSort_saveData()
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
-- function click_collectionBtn
-- @brief 도감
-------------------------------------
function UI_DragonManageInfo:click_collectionBtn()
    local function close_cb()
        self:checkDragonListRefresh()
    end
    UI_Book():setCloseCB(close_cb)
end

-------------------------------------
-- function click_inventoryBtn
-- @brief 인벤 확장
-------------------------------------
function UI_DragonManageInfo:click_inventoryBtn()
    local item_type = 'dragon'
    local function finish_cb()
        self:refresh_inventoryLabel()
    end

    g_inventoryData:extendInventory(item_type, finish_cb)
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

    end
end

--@CHECK
UI:checkCompileError(UI_DragonManageInfo)
