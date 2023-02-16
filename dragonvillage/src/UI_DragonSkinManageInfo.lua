local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonSkinManageInfo
-------------------------------------
UI_DragonSkinManageInfo = class(PARENT,{
        -- 서버상의 드래곤 정보가 마지막으로 변경된 시간 (refresh 체크 용도)
        m_dragonListLastChangeTime = 'timestamp',

        m_skinTableView = 'UIC_TableView',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonSkinManageInfo:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonSkinManageInfo'
    
    self.m_subCurrency = 'memory_myth'  -- 상단 유저 재화 정보 중 서브 재화
    self.m_bVisible = true or false
    self.m_titleStr = nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_bShowInvenBtn = true 
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkinManageInfo:init(struct_dragon_object)
    self.m_uiName = 'UI_DragonSkinManageInfo'
    self.m_resName = 'dragon_skin.ui'
    self.m_titleStr = Str('드래곤 스킨')
    self.m_bVisible = true
    self.m_bUseExitBtn = true

    self.m_selectDragonOID = struct_dragon_object:getObjectId()
    self.m_selectDragonData = struct_dragon_object
    self.m_elapsedTime = 1
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_DragonSkinManageInfo:init_after(struct_dragon_object)
    local vars = self:load(self.m_resName)
    UIManager:open(self, UIManager.SCENE)

    PARENT.init_after(self)

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, self.m_uiName)


    -- 정렬 도우미
    self:init_dragonSortMgr()

    self.m_dragonListLastChangeTime = g_dragonsData:getLastChangeTimeStamp()

    -- local sub_menu = self.m_startSubMenu
    -- if sub_menu then
    --     self:clickSubMenu(sub_menu)
    -- end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkinManageInfo:initUI()
    local vars = self.vars
    self:init_dragonTableView()

    -- -- 드래곤 정보 보드 생성
    -- self.m_dragonInfoBoardUI = UI_DragonInfoBoard()

    -- if (IS_TEST_MODE()) then
    --     self.m_dragonInfoBoardUI.vars['equipmentBtn']:setVisible(true)
    --     self.m_dragonInfoBoardUI.vars['equipmentBtn']:registerScriptTapHandler(function() self:click_equipmentBtn() end)
    -- else
    --     self.m_dragonInfoBoardUI.vars['equipmentBtn']:setVisible(false)
    -- end
    -- self.vars['infoNode']:addChild(self.m_dragonInfoBoardUI.root)
    --self.root:addChild(self.m_dragonInfoBoardUI.root)
    -- @TODO77

    vars['evolutionLabel1']:setString(Str("해치"))
    vars['evolutionLabel2']:setString(Str("해츨링"))
    vars['evolutionLabel3']:setString(Str("성룡"))

    local did = self.m_selectDragonData['did']
    local dragon_name = TableDragon:getDragonName(did)
    vars['dragonNameLabel']:setString(Str(dragon_name))

    for i = 1, 3 do 
        local node = vars['dragonNode'..i]
        if (node) then
            local data = clone(self.m_selectDragonData)
            data['evolution'] = i

            local card = UI_BookDragonCard(data)
            card.root:setSwallowTouch(false)
            card.root:setScale(0.8)
            node:addChild(card.root)

            -- -- 수집 여부에 따른 음영 처리
            -- if (not g_bookData:isExist(data)) then
            --     card:setShadowSpriteVisible(true)
            -- end

            -- 등급 표시 안함
            card.vars['starNode']:setVisible(false)
            -- -- 선택한 카드 표시
            -- card:setHighlightSpriteVisibleWithNoAction(i == self.m_evolution)
            -- 진화 단계 선택 
            card.vars['clickBtn']:registerScriptTapHandler(function()
                self:click_evolutionBtn(i)
            end)
            -- self.m_mapEvolutionBtnUI[i] = card
        end
    end


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
function UI_DragonSkinManageInfo:initButton()
    local vars = self.vars
    
	-- -- 우측 버튼
    -- do 
 
    -- end

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
function UI_DragonSkinManageInfo:refresh()
    -- self:refresh_buttonState()

    local t_dragon_data = self.m_selectDragonData

    -- self.m_dragonInfoBoardUI:refresh(t_dragon_data)

    if (not t_dragon_data) then
        return
    end

    -- -- 드래곤 기본 정보 갱신
    self:refresh_dragonBasicInfo(t_dragon_data)

    -- -- 리더 드래곤 여부 표시
    -- self:refresh_leaderDragon(t_dragon_data)

    -- -- 도감작 (해치, 해츨링, 성룡의 도감을 채워서 다이아를 받는 행위) 상태 갱신
    -- self:refresh_bookSprite(t_dragon_data)

    -- -- 진화/승급/스킬강화 알림 - 개발 하다가 중단 
    -- --self:refresh_buttonNoti()

	-- -- 조합 드래곤
	-- self:refresh_combination()

    local vars = self.vars

	-- -- 잠금 표시
	-- vars['lockSprite']:setVisible(t_dragon_data:getLock())

    -- -- 외형 변환 표시
    -- local b_transform_change = t_dragon_data:isPossibleTransformChange()
    -- vars['transformBtn']:setVisible(b_transform_change)
    -- vars['evolutionBtn']:setVisible(not b_transform_change)

    local is_myth_dragon = t_dragon_data:getRarity() == 'myth'
    --vars['upgradeBtn']:setEnabled(not is_myth_dragon)
    --vars['reinforceBtn']:setEnabled(not is_myth_dragon)
    --vars['goodbyeBtn']:setVisible(not is_myth_dragon)
    --vars['goodbyeSelectBtn']:setVisible(not is_myth_dragon)
    --vars['lockBtn']:setVisible(not is_myth_dragon)


    -- local doid = t_dragon_data:getObjectId()
    -- local is_recall_target = g_dragonsData:isDragonRecallTarget(doid)
    -- vars['recallBtn']:setVisible(is_recall_target)

    local did = self.m_selectDragonData['did']
    local dragon_name = TableDragon:getDragonName(did)
    vars['dragonNameLabel']:setString(dragon_name)

    for i = 1, 3 do 
        local node = vars['dragonNode'..i]
        if (node) then
            local data = clone(self.m_selectDragonData)
            data['evolution'] = i

            local card = UI_BookDragonCard(data)
            card.root:setSwallowTouch(false)
            card.root:setScale(0.8)
            node:addChild(card.root)

            -- -- 수집 여부에 따른 음영 처리
            -- if (not g_bookData:isExist(data)) then
            --     card:setShadowSpriteVisible(true)
            -- end

            -- 등급 표시 안함
            card.vars['starNode']:setVisible(false)
            -- -- 선택한 카드 표시
            -- card:setHighlightSpriteVisibleWithNoAction(i == self.m_evolution)
            -- 진화 단계 선택 
            card.vars['clickBtn']:registerScriptTapHandler(function()
                self:click_evolutionBtn(i)
            end)
            -- self.m_mapEvolutionBtnUI[i] = card
        end
    end
    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData_checkNumber()

    self:setDragonSkin()
end

-------------------------------------
-- function click_evolutionBtn
-------------------------------------
function UI_DragonSkinManageInfo:click_evolutionBtn(i)
    cclog('CLICK EVOLUTION BTN : ' .. i)
    do -- 드래곤 리소스
        self.m_dragonAnimator:setDragonAnimator(self.m_selectDragonData['did'], i)
    end
end

-------------------------------------
-- function refresh_dragonBasicInfo
-- @brief 드래곤 기본 정보 갱신
-------------------------------------
function UI_DragonSkinManageInfo:refresh_dragonBasicInfo(t_dragon_data)
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
-- function click_exitBtn
-------------------------------------
function UI_DragonSkinManageInfo:click_exitBtn()
    self:close()
end

-------------------------------------
-- function setDragonSkin
-- @brief 해당 드래곤 스킨 테이블뷰 생성
-------------------------------------
function UI_DragonSkinManageInfo:setDragonSkin()
	local vars = self.vars

    local node = vars['skinListNode']
    node:removeAllChildren()

    local l_struct_dragon_skin = g_dragonSkinData:makeStructSkinList(self.m_selectDragonData['did'])

    -- 코스튬 버튼
    local function create_func(ui, data)
        -- -- 코스튬 미리보기
        -- ui.vars['costumeBtn']:registerScriptTapHandler(function()
        --     self:click_costume(ui.m_costumeData)
        -- end)

        -- -- 코스튬 선택하기
        -- ui.vars['selectBtn']:registerScriptTapHandler(function()
        --     self:click_select_costume(ui.m_costumeData)
        -- end)

        -- -- 코스튬 구입하기
        -- ui.vars['buyBtn']:registerScriptTapHandler(function()
        --     self:click_buy_costume(ui.m_costumeData)
        -- end)

        --  -- 상점으로 이동
        -- ui.vars['gotoBtn']:registerScriptTapHandler(function()
        --     self:click_go_shop(ui.m_costumeData)
        -- end)
    end

     -- 상품 정보 주지 않는 코스튬은 리스트에서 제외(토파즈 부류만) 
    -- local sale_list = self:removeCostume_WithoutShopInfo(l_struct_dragon_skin)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(221, 393)
    table_view:setCellUIClass(UI_DragonSkinListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_struct_dragon_skin)

    self.m_skinTableView = table_view
end

-------------------------------------
-- function refreshDragonCard
-- @brief 카드를 갱신한다.
-------------------------------------
function UI_DragonSkinManageInfo:refreshDragonCard(modified_dragons, modified_slimes, ref_type)
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
function UI_DragonSkinManageInfo:click_lockBtn()
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
function UI_DragonSkinManageInfo:click_goodbyeBtn()
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
function UI_DragonSkinManageInfo:click_goodbyeSelectBtn()
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
function UI_DragonSkinManageInfo:click_assessBtn()
	UI_DragonBoardPopup(self.m_selectDragonData)
end

-------------------------------------
-- function click_bookBtn
-- @brief 도감
-------------------------------------
function UI_DragonSkinManageInfo:click_bookBtn()
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
function UI_DragonSkinManageInfo:click_combineBtn()
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
function UI_DragonSkinManageInfo:click_teamBonusBtn()
    local sel_did = self.m_selectDragonData['did']
	UI_TeamBonus(TEAM_BONUS_MODE.DRAGON, nil, sel_did)
end

-------------------------------------
-- function click_slimeCombineBtn
-- @brief 슈퍼 슬라임 합성
-------------------------------------
function UI_DragonSkinManageInfo:click_slimeCombineBtn()
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
function UI_DragonSkinManageInfo:click_skinBtn()
    local t_dragon_data = self.m_selectDragonData
	local did = t_dragon_data['did']
    local doid = t_dragon_data:getObjectId()

    local ui = UI_DragonSkin()

    local function close_cb()
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_recallBtn
-------------------------------------
function UI_DragonSkinManageInfo:click_recallBtn()
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
function UI_DragonSkinManageInfo:checkDragonListRefresh()
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
function UI_DragonSkinManageInfo:clickSubMenu(sub_menu)
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
UI:checkCompileError(UI_DragonSkinManageInfo)
