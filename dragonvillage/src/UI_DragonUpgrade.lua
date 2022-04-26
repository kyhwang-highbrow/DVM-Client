local PARENT = UI_DragonManage_Base

-- 20-11-10 드래곤 레벨업 개편으로 사용 안함
-- 속성별 승급 패키지 product_id (table_shop_cash) 
--local T_UPGRADE_PACKAGE_ID_TABLE = {
		--['earth'] = 110111,
		--['water'] = 110112,
		--['fire'] = 110113,
		--['light'] = 110114,
		--['dark'] = 110115,
--}

-------------------------------------
-- class UI_DragonUpgrade
-------------------------------------
UI_DragonUpgrade = class(PARENT,{
        --- 재료 중에서 선택된 드래곤
        m_lSelectedMtrlList = 'list',
        m_mSelectedMtrMap = 'map',

        m_selectedDragonGrade = 'number',
        m_selectedMaterialCnt = 'number',
        m_currSlotIdx = 'number',
        m_upgradeMaterialCnt = 'number',
        m_updatePackageStruct = 'StructProduct',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonUpgrade:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonUpgrade'
    self.m_bVisible = true or false
    self.m_titleStr = Str('승급')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonUpgrade:init(doid)
    local vars = self:load('dragon_upgrade.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonUpgrade')
	
    self:sceneFadeInAction()
	
	-- initialize
    self.m_lSelectedMtrlList = {}
    self.m_mSelectedMtrMap = {}

    self:initUI()
    self:initButton()
    self:refresh()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    -- 정렬 도우미
    self:init_dragonSortMgr()
	self:init_mtrDragonSortMgr(false) -- slime_first

    -- 선택한 드래곤에 포커싱
    self:focusSelectedDragon(doid)

    -- 마스터의 길 승급은 허들이 심해 입장만 시키도록 함
    -- @ MASTER ROAD
    local t_data = {clear_key = 'check_grup'}
    g_masterRoadData:updateMasterRoad(t_data)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonUpgrade:initUI()
    local vars = self.vars

    self:init_dragonTableView()

    local l_pos = getSortPosList(30, 3)

    local uic_stats = UIC_IndivisualStats()
    uic_stats:initUIComponent()
    uic_stats:setPositionY(l_pos[1])
    uic_stats:setParentNode(vars['statsNode'])
    uic_stats:setStatsName(Str('공격력'))
    vars['atkStats'] = uic_stats

    local uic_stats = UIC_IndivisualStats()
    uic_stats:initUIComponent()
    uic_stats:setPositionY(l_pos[2])
    uic_stats:setParentNode(vars['statsNode'])
    uic_stats:setStatsName(Str('방어력'))
    vars['defStats'] = uic_stats

    local uic_stats = UIC_IndivisualStats()
    uic_stats:initUIComponent()
    uic_stats:setPositionY(l_pos[3])
    uic_stats:setParentNode(vars['statsNode'])
    uic_stats:setStatsName(Str('생명력'))
    vars['hpStats'] = uic_stats
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonUpgrade:initButton()
    local vars = self.vars

    vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)

    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    cca.pickMePickMe(vars['buyBtn'], 10)

    vars['upgradeMaterialBtn']:registerScriptTapHandler(function() self:click_upgradeMaterialBtn() end)
end

-------------------------------------
-- function setBuyBtn
-------------------------------------
function UI_DragonUpgrade:setBuyBtn()
    local vars = self.vars

    local buy_btn_visible = self:isBuyBtnVisible()
    vars['buyBtn']:setVisible(buy_btn_visible)
end

-------------------------------------
-- function isBuyBtnVisible
-- @brief 승급 패키지 구매 버튼(만드라고라) 노출 여부
-------------------------------------
function UI_DragonUpgrade:isBuyBtnVisible()
    local vars = self.vars    
 
    -- 상품 구입이 가능하지 않으면 노출x
    if (not self:isPackageBuyable()) then
        return false
    end

    -- 선택된 드래곤이 승급 가능 상태가 아니면(레벨max) 노출x
    local upgradeable = g_dragonsData:possibleUpgradeable(self.m_selectDragonOID)
    if (not upgradeable) then
        return true
    end

    -- 재료가 충분하다면 노출x
    if (self.m_upgradeMaterialCnt >= self.m_selectedDragonGrade) then
        return false
    end

    return true
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonUpgrade:refresh()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    local did = t_dragon_data['did']

    local attr = t_dragon_data:getAttr()
    local role_type = t_dragon_data:getRole()
    local rarity_type = nil
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    -- 배경
    local attr = TableDragon:getDragonAttr(did)
    if self:checkVarsKey('bgNode', attr) then    
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(t_dragon_data:getDragonNameWithEclv())
    end

    do -- 드래곤 속성
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    end

    do -- 드래곤 역할(role)
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    end
    
    do -- 드래곤 현재 정보 카드
        vars['dragonIconNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(t_dragon_data)
        vars['dragonIconNode']:addChild(dragon_card.root)
    end

    do -- 드래곤 리소스
        local evolution = t_dragon_data['evolution']
        vars['dragonNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:changeAni('idle', true)

        vars['dragonNode']:addChild(animator.m_node)
    end

    do -- 재료 중에서 선택된 드래곤 항목들 정리
        for i,v in pairs(self.m_lSelectedMtrlList) do
            v.root:removeFromParent()
        end

        self.m_lSelectedMtrlList = {}
        self.m_mSelectedMtrMap = {}
        self.m_selectedDragonGrade = t_dragon_data['grade']
        self.m_currSlotIdx = 1
        self.m_selectedMaterialCnt = 0
    end

    do -- 선택된 드래곤별 재료 슬롯 정렬
        local l_pos = getSortPosList(100, self.m_selectedDragonGrade)
        for i=1, 5 do
            local material_node = vars['materialNode' .. i]
            material_node:setPositionX(0)
            material_node:stopAllActions()
            if (i <= self.m_selectedDragonGrade) then
                material_node:setVisible(true)

                -- 이즈액션으로 이동
                local x = l_pos[i]
                local action = cca.makeBasicEaseMove(0.3, x, 0)
                cca.runAction(material_node, action)
                cca.uiReactionSlow(material_node)
            else
                material_node:setVisible(false)
            end
        end
    end

	-- 승급 가능 여부 처리
	local upgradeable = g_dragonsData:possibleUpgradeable(self.m_selectDragonOID)
    if (not upgradeable) then
        local max_lv = TableGradeInfo:getMaxLv(self.m_selectedDragonGrade)
	    vars['lockSprite']:setVisible(true)
        vars['infoLabel2']:setString(Str('{1}레벨 달성시 승급할 수 있어요', max_lv))
    else
        vars['lockSprite']:setVisible(false)
    end

    self:refresh_upgrade(table_dragon, t_dragon_data)
    self:refresh_stats(t_dragon_data)
	
    self:refresh_dragonMaterialTableView()

    -- 승급 패키지 구매 버튼(만드라고라) 노출 갱신
    self:setBuyBtn()
end

-------------------------------------
-- function refresh_stats
-- @brief 능력치
-------------------------------------
function UI_DragonUpgrade:refresh_stats(t_dragon_data)
    local vars = self.vars
    local doid = t_dragon_data['id']

    -- 현재 레벨의 능력치 계산기
    local status_calc = MakeOwnDragonStatusCalculator(doid)

    -- 현재 레벨의 능력치
    local curr_atk = status_calc:getFinalStat('atk')
    local curr_def = status_calc:getFinalStat('def')
    local curr_hp = status_calc:getFinalStat('hp')
    local curr_cp = status_calc:getCombatPower()

    vars['atkStats']:setBeforeStats(curr_atk)
    vars['defStats']:setBeforeStats(curr_def)
    vars['hpStats']:setBeforeStats(curr_hp)

    -- 변경된 레벨의 능력치 계산기
    local chaged_dragon_data = {}
    local grade = t_dragon_data['grade']
    chaged_dragon_data['grade'] = math_min((grade + 1), MAX_DRAGON_GRADE)
    chaged_dragon_data['lv'] = 1
    local changed_status_calc = MakeOwnDragonStatusCalculator(doid, chaged_dragon_data)

    -- 변경된 레벨의 능력치
    local changed_atk = changed_status_calc:getFinalStat('atk')
    local changed_def = changed_status_calc:getFinalStat('def')
    local changed_hp = changed_status_calc:getFinalStat('hp')
    local changed_cp = changed_status_calc:getCombatPower()

    vars['atkStats']:setAfterStats(changed_atk)
    vars['defStats']:setAfterStats(changed_def)
    vars['hpStats']:setAfterStats(changed_hp)
end

-------------------------------------
-- function refresh_upgrade
-------------------------------------
function UI_DragonUpgrade:refresh_upgrade(table_dragon, t_dragon_data)
    local vars = self.vars

    -- 등급 테이블
    local table_grade_info = TableGradeInfo()
    local t_grade_info = table_grade_info:get(t_dragon_data['grade'])
    local t_next_grade_info = table_grade_info:get(t_dragon_data['grade'] + 1)

    do -- 승급에 필요한 가격
        local grade = t_dragon_data['grade']
        local req_gold = table_grade_info:getValue(grade, 'req_gold')
        vars['priceLabel']:setString(comma_value(req_gold))
    end
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonUpgrade:getDragonList()
    local dragon_dic = g_dragonsData:getDragonListWithSlime()

    -- 절대 레벨업 불가능한 드래곤 제외
    for oid, v in pairs(dragon_dic) do
        if (g_dragonsData:impossibleUpgradeForever(oid)) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트 : 승급
-- @override
-------------------------------------
function UI_DragonUpgrade:getDragonMaterialList(doid)
    local dragon_dic = g_dragonsData:getDragonListWithSlime()

    -- 자기 자신 드래곤 제외
    if (doid) then
        dragon_dic[doid] = nil
    end

    self.m_upgradeMaterialCnt = 0

    -- 예외적으로 보다 낮은 등급 드래곤은 아예 빼버림
    -- 승급용이 아닌 슬라임도 제외
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    for oid,v in pairs(dragon_dic) do
        local invalid_dragon_oid = nil
        if (v['grade'] < t_dragon_data['grade']) then
            invalid_dragon_oid = oid

        -- 슬라임의 경우
        elseif (v:getObjectType() == 'slime') then

            -- 슬라임 타입이 upgrade가 아니면 제외
            local slime_type = v:getSlimeType()
            if (slime_type ~= 'upgrade') then
                invalid_dragon_oid = oid
            end
        end

        if (invalid_dragon_oid) then
            dragon_dic[invalid_dragon_oid] = nil
        -- 재료로 적합할 경우 lock 상태인지 확인 후 재료 갯수에 추가 
        else
            if (not v['lock']) then
                self.m_upgradeMaterialCnt = self.m_upgradeMaterialCnt + 1
            end
        end
    end

    return dragon_dic
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief 재료 카드 만든 후..
-------------------------------------
function UI_DragonUpgrade:createMtrlDragonCardCB(ui, data)
    if (not ui) then
        return
    end

    -- 재료 드래곤이 재료 가능한지 판별
    doid = data['id']
    local is_shadow = false
    if (data:getObjectType() == 'dragon') then
        if (not g_dragonsData:possibleMaterialDragon(doid)) then
            is_shadow = true
        else
            is_shadow = false
        end

    elseif (data:getObjectType() == 'slime') then
        if (not g_slimesData:possibleMaterialSlime(doid, 'upgrade')) then
            is_shadow = true
        else
            is_shadow = false
        end
    end

    ui:setShadowSpriteVisible(is_shadow)

    -- 프레스 함수 세팅
    local press_card_cb = function()
        local doid = data['id']
        if doid and (doid ~= '') then
            local ui = UI_SimpleDragonInfoPopup(data)
			local is_selected = self.m_mSelectedMtrMap[doid]
            ui:setLockPossible(true, is_selected)
            ui:setRefreshFunc(function()
                self:refresh_dragonIndivisual(doid)          -- 하단의 드래곤 tableview
                self:refresh_dragonIndivisual_material(doid) -- 특성 재료 tableview
                
                -- 특성 UI 뒤의 드래곤관리UI를 갱신하도록 한다.
                self.m_bChangeDragonList = true
            end)
        end
    end

    ui.vars['clickBtn']:registerScriptPressHandler(press_card_cb)

    -- 선택한 드래곤이 승급 가능한지 판단
    local doid = self.m_selectDragonOID
    if (not g_dragonsData:possibleUpgradeable(doid)) then
        ui:setShadowSpriteVisible(true)
    end
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonUpgrade:click_dragonMaterial(data)
    local vars = self.vars
    local doid = data['id']

    -- 선택한 드래곤이 승급 가능한지 판단
    local possible, msg = g_dragonsData:possibleUpgradeable(self.m_selectDragonOID)
    if (not possible) then
        UIManager:toastNotificationRed(msg)
        return
    end

    -- 선택가능한 재료인지 체크
    if (data:getObjectType() == 'dragon') then
        local possible, msg = g_dragonsData:possibleMaterialDragon(doid)
        if (not possible) then
            UIManager:toastNotificationRed(msg)
            return 
        end

    elseif (data:getObjectType() == 'slime') then
        local possible, msg = g_slimesData:possibleMaterialSlime(doid, 'upgrade')
        if (not possible) then
            UIManager:toastNotificationRed(msg)
            return 
        end
    end

    local function next_func()
        local list_item = self.m_mtrlTableViewTD:getItem(doid)
        local list_item_ui = list_item['ui']
    
        if self.m_mSelectedMtrMap[doid] then
            local ui = self.m_mSelectedMtrMap[doid]
            self.m_mSelectedMtrMap[doid] = nil
            self.m_lSelectedMtrlList[ui.m_tag] = nil

            ui.root:removeFromParent()

            list_item_ui:setCheckSpriteVisible(false)
            self.m_selectedMaterialCnt = (self.m_selectedMaterialCnt - 1)
        else
            if self.m_currSlotIdx then
                local ui = UI_DragonCard(data)
                ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(data) end)
                ui.m_tag = self.m_currSlotIdx

                self.m_mSelectedMtrMap[doid] = ui

                self.m_lSelectedMtrlList[self.m_currSlotIdx] = ui
        
                --ui.root:setScale(0.57)
                local scale = 0.57
                cca.uiReactionSlow(ui.root, scale, scale, scale * 0.7)
                vars['materialNode' .. self.m_currSlotIdx]:addChild(ui.root)

                list_item_ui:setCheckSpriteVisible(true)
                self.m_selectedMaterialCnt = (self.m_selectedMaterialCnt + 1)
            end
        end

        self.m_currSlotIdx = nil
        for i=1, self.m_selectedDragonGrade do
            if (not self.m_lSelectedMtrlList[i] ) then
                self.m_currSlotIdx = i
                break
            end
        end
    end

    -- 재료 경고
    if self.m_mSelectedMtrMap[doid] then
        next_func()
    else
        local oid = doid
        local grade = self.m_selectDragonData['grade'] + 1
        g_dragonsData:dragonMaterialWarning(oid, next_func, {grade=grade})
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_DragonUpgrade:click_buyBtn()
    local struct_product = self.m_updatePackageStruct
    
	local ui = UI_Package({struct_product}, true) -- is_popup

	-- @mskim 익명 함수를 사용하여 가독성을 높이는 경우라고 생각..!
	-- 구매 후 간이 우편함 출력
	-- 간이 우편함 닫을 때 패키지UI 닫고 진화UI 갱신
	ui:setBuyCB(function() 
		UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.UPDATE_PACK, function()
			ui:close()
			self:refresh()
		end)
	end)
end

-------------------------------------
-- function click_upgradeBtn
-------------------------------------
function UI_DragonUpgrade:click_upgradeBtn()
	-- 승급 가능 여부
	local upgradeable, msg = g_dragonsData:possibleUpgradeable(self.m_selectDragonOID)
	if (not upgradeable) then
		UIManager:toastNotificationRed(msg)
        return
	end

	-- 재료 요건 여부
    if (self.m_selectedMaterialCnt < self.m_selectedDragonGrade) then
        UIManager:toastNotificationRed(Str('같은 별 개수의 드래곤이 필요합니다.'))
        local vars = self.vars
        cca.uiImpossibleAction(vars['materialNode1'])
        cca.uiImpossibleAction(vars['materialNode2'])
        cca.uiImpossibleAction(vars['materialNode3'])
        cca.uiImpossibleAction(vars['materialNode4'])
        cca.uiImpossibleAction(vars['materialNode5'])
        return
    end

    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID
    local src_doids = ''
    local src_soids = ''
    for _,v in pairs(self.m_lSelectedMtrlList) do
        local _doid = v.m_dragonData['id']
        local _dragon_object = g_dragonsData:getDragonObject(_doid)
       
        -- 드래곤     
        if (_dragon_object.m_objectType == 'dragon') then
            if (src_doids == '') then
                src_doids = tostring(_doid)
            else
                src_doids = src_doids .. ',' .. tostring(_doid)
            end
        -- 슬라임
        elseif (_dragon_object.m_objectType == 'slime') then
            if (src_soids == '') then
                src_soids = tostring(_doid)
            else
                src_soids = src_soids .. ',' .. tostring(_doid)
            end
        end
    end

    local function success_cb(ret)
        local t_prev_dragon_data = self.m_selectDragonData

        -- @analytics
        do
            Analytics:trackUseGoodsWithRet(ret, '드래곤 승급')

            local pre_grade = tostring(t_prev_dragon_data['grade'])
            local grade = tostring(pre_grade + 1)
            local msg = string.format('DragonUpgrade_%sto%s', pre_grade, grade)
            Analytics:firstTimeExperience(msg)

            local desc = string.format('%d성 드래곤', grade)
            Analytics:trackEvent(CUS_CATEGORY.GROWTH, CUS_EVENT.DRA_UP, 1, desc)

            -- @adjust
            Adjust:trackEvent(Adjust.EVENT.DRAGON_RANKUP)
            if (grade == 6) then 
                Adjust:trackEvent(Adjust.EVENT.DRAGON_MAKE_6GRADE)
            end
        end

        -- 재료로 사용된 드래곤 삭제
        if ret['deleted_dragons_oid'] then
            for _,doid in pairs(ret['deleted_dragons_oid']) do
                g_dragonsData:delDragonData(doid)

                -- 드래곤 리스트 갱신
                self.m_tableViewExt:delItem(doid)
            end
        end

        -- 슬라임
        if ret['deleted_slimes_oid'] then
            for _,soid in pairs(ret['deleted_slimes_oid']) do
                g_slimesData:delSlimeObject(soid)

                -- 리스트 갱신
                self.m_tableViewExt:delItem(soid)
            end
        end

        -- 드래곤 정보 갱신
        g_dragonsData:applyDragonData(ret['modified_dragon'])

        -- 드래곤 성장일지 : 드래곤 승급 체크
        local start_dragon_data = g_dragonDiaryData:getStartDragonData(ret['modified_dragon'])
        if (start_dragon_data) then
            -- @ DRAGON DIARY
            local t_data = {clear_key = 'd_grup_s', sub_data = start_dragon_data}
            g_dragonDiaryData:updateDragonDiary(t_data)
        end

        -- 갱신
        g_serverData:networkCommonRespone(ret)

        self.m_bChangeDragonList = true

        local t_next_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)

        -- 연출 시작
        self:upgradeDirecting(doid, t_prev_dragon_data, t_next_dragon_data)

        -- @ master road
        g_masterRoadData:addRawData('d_grup')
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/upgrade')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('src_doids', src_doids)
    ui_network:setParam('src_soids', src_soids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function click_upgradeMaterialBtn
-------------------------------------
function UI_DragonUpgrade:click_upgradeMaterialBtn()
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
-- function upgradeDirecting
-- @brief 강화 연출
-------------------------------------
function UI_DragonUpgrade:upgradeDirecting(doid, t_prev_dragon_data, t_next_dragon_data)
    local block_ui = UI_BlockPopup()

    local directing_animation
    local directing_result

    -- 결과 연출
    directing_result = function()
        block_ui:close()

        -- UI 갱신
        self:close()
        
        -- 결과 팝업 (승급)
        if (t_prev_dragon_data['grade'] < t_next_dragon_data['grade']) then
            UI_DragonUpgradeResult(t_next_dragon_data, t_prev_dragon_data)
        end
    end

    directing_result()
end

-------------------------------------
-- function isPackageBuyable
-------------------------------------
function UI_DragonUpgrade:isPackageBuyable()

    -- 드래곤 정보 있는 지 확인
	local struct_dragon_object = self.m_selectDragonData
    if (not struct_dragon_object) then
        return false
    end

	-- pid 찾아서 StructProduct 찾아서 구매 가능 여부 확인
	local attr = struct_dragon_object:getAttr()
    --local pid = T_UPGRADE_PACKAGE_ID_TABLE[attr]
    local pid = 110116 -- 20-11-10 드래곤 레벨업 개편에 따른 승급 패키지 통일화
	local struct_product = g_shopDataNew:getProduct('package', pid)

	-- 구매할때 쓰기 위해서 따로 저장
	self.m_updatePackageStruct = struct_product

	return struct_product:checkMaxBuyCount()
end


-------------------------------------
-- function refresh_dragonIndivisual_material
-------------------------------------
function UI_DragonUpgrade:refresh_dragonIndivisual_material(doid)
    local item = self.m_mtrlTableViewTD.m_itemMap[doid]

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

    if (not t_dragon_data) then
        t_dragon_data = g_slimesData:getSlimeObject(doid)
    end

    -- 테이블뷰 리스트의 데이터 갱신
    item['data'] = t_dragon_data

    -- UI card 버튼이 있을 경우 데이터 갱신
    if item and item['ui'] then
        local ui = item['ui']
        ui.m_dragonData = t_dragon_data
        ui:refreshDragonInfo()
        self:createMtrlDragonCardCB(ui, t_dragon_data)
    end
end

-------------------------------------
-- function checkSelectedDragonCondition
-------------------------------------
function UI_DragonUpgrade:checkSelectedDragonCondition(dragon_object)
    if (not dragon_object) then
        return false
    end
    -- StructSlimeObject는 soid (== id)
    -- StructDragonObject는 doid (== id)
    -- 두 클래스 모두 id에 값을 저장하고 있다
    local doid = dragon_object['id']
    local object_type = dragon_object:getObjectType()
    local upgradeable, msg = g_dragonsData:impossibleUpgradeForever(doid)
    if (upgradeable) then
        UIManager:toastNotificationRed(msg)
        return false
    end
    return true
end

--@CHECK
UI:checkCompileError(UI_DragonUpgrade)
