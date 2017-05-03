local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonUpgradeNew
-------------------------------------
UI_DragonUpgradeNew = class(PARENT,{
        m_mtrlTableViewTD = '', -- 재료
        m_mtrlDragonSortManager = 'SortManager_Dragon',

        --- 재료 중에서 선택된 드래곤
        m_lSelectedMtrlList = 'list',
        m_mSelectedMtrMap = 'map',

        m_selectedDragonGrade = 'number',
        m_selectedMaterialCnt = 'number',
        m_currSlotIdx = 'number',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonUpgradeNew:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonUpgradeNew'
    self.m_bVisible = true or false
    self.m_titleStr = Str('승급')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonUpgradeNew:init(doid)
    self.m_lSelectedMtrlList = {}
    self.m_mSelectedMtrMap = {}

    local vars = self:load('dragon_upgrade.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonUpgradeNew')

    -- 정렬 매니저
    self.m_mtrlDragonSortManager = SortManager_Dragon()

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonUpgradeNew:initUI()
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
function UI_DragonUpgradeNew:initButton()
    local vars = self.vars
    vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)

    do -- 정렬 관련 버튼들
        vars['sortSelectOrderBtn']:registerScriptTapHandler(function() self:clcik_sortSelectOrderBtn() end)

        vars['sortSelectBtn']:registerScriptTapHandler(function() self:click_sortSelectBtn() end)
        vars['sortSelectHpBtn']:registerScriptTapHandler(function() self:click_sortBtn('hp') end)
        vars['sortSelectDefBtn']:registerScriptTapHandler(function() self:click_sortBtn('def') end)
        vars['sortSelectAtkBtn']:registerScriptTapHandler(function() self:click_sortBtn('atk') end)
        vars['sortSelectAttrBtn']:registerScriptTapHandler(function() self:click_sortBtn('attr') end)
        vars['sortSelectLvBtn']:registerScriptTapHandler(function() self:click_sortBtn('lv') end)
        vars['sortSelectGradeBtn']:registerScriptTapHandler(function() self:click_sortBtn('grade') end)
        vars['sortSelectRarityBtn']:registerScriptTapHandler(function() self:click_sortBtn('rarity') end)
        vars['sortSelectFriendshipBtn']:registerScriptTapHandler(function() self:click_sortBtn('friendship') end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonUpgradeNew:refresh()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    local did = t_dragon_data['did']

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
        local grade = t_dragon_data['grade']
        local l_pos = getSortPosList(100, grade)
        for i=1, 5 do
            local material_node = vars['materialNode' .. i]
            material_node:setPositionX(0)
            material_node:stopAllActions()
            if (i <= grade) then
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
	local upgradeable = g_dragonsData:checkUpgradeable(self.m_selectDragonOID)
	vars['infoLabel']:setVisible(not upgradeable)

    self:refresh_dragonUpgradeMaterialTableView()
    self:refresh_upgrade(table_dragon, t_dragon_data)
    self:refresh_stats(t_dragon_data)
end

-------------------------------------
-- function refresh_stats
-- @brief 능력치
-------------------------------------
function UI_DragonUpgradeNew:refresh_stats(t_dragon_data)
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
function UI_DragonUpgradeNew:refresh_upgrade(table_dragon, t_dragon_data)
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
-- function refresh_dragonUpgradeMaterialTableView
-- @brief 드래곤 승급 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_DragonUpgradeNew:refresh_dragonUpgradeMaterialTableView()    
    local list_table_node = self.vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonUpgradeMaterial(data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_mtrlTableViewTD = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonUpgradeMaterialList(self.m_selectDragonOID)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list)

    -- 정렬
    self:refresh_sortUI()
end

-------------------------------------
-- function getDragonUpgradeMaterialList
-- @brief 드래곤 승급 재료(다른 드래곤) 리스트
-------------------------------------
function UI_DragonUpgradeNew:getDragonUpgradeMaterialList(doid)
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    
    local dragon_dic = g_dragonsData:getDragonListWithSlime()

    -- 자기 자신 드래곤 제외
    dragon_dic[doid] = nil

    for oid,v in pairs(dragon_dic) do
        if (v['grade'] < t_dragon_data['grade']) then
            dragon_dic[oid] = nil
        elseif (not g_dragonsData:possibleMaterialDragon(oid)) and (not g_slimesData:possibleMaterialSlime_upgrade(oid)) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function clcik_sortSelectOrderBtn
-------------------------------------
function UI_DragonUpgradeNew:clcik_sortSelectOrderBtn()
    local sort_manager = self.m_mtrlDragonSortManager
    sort_manager:setAllAscending(not sort_manager.m_defaultSortAscending)
    self:refresh_sortUI()
end

-------------------------------------
-- function click_sortSelectBtn
-------------------------------------
function UI_DragonUpgradeNew:click_sortSelectBtn()
    local vars = self.vars
    vars['sortSelectNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_sortBtn
-------------------------------------
function UI_DragonUpgradeNew:click_sortBtn(sort_type)
    local sort_manager = self.m_mtrlDragonSortManager
    sort_manager:pushSortOrder(sort_type)
    self:refresh_sortUI()
end

-------------------------------------
-- function refresh_sortUI
-------------------------------------
function UI_DragonUpgradeNew:refresh_sortUI()
    local vars = self.vars

    local sort_manager = self.m_mtrlDragonSortManager

    -- 테이블 뷰 정렬
    local table_view = self.m_mtrlTableViewTD
    sort_manager:sortExecution(table_view.m_itemList)
    table_view:setDirtyItemList()

    -- 선택된 정렬 이름
    local sort_type = sort_manager:getTopSortingType()
    local sort_name = sort_manager:getSortName(sort_type)
    vars['sortSelectLabel']:setString(sort_name)

    -- 오름차순일경우
    if sort_manager.m_defaultSortAscending then
        vars['sortSelectOrderSprite']:setScaleY(-1)
    -- 내림차순일경우
    else
        vars['sortSelectOrderSprite']:setScaleY(1)
    end
end

-------------------------------------
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-------------------------------------
function UI_DragonUpgradeNew:createDragonCardCB(ui, data)
    local doid = data['id']

    local upgradeable, msg = g_dragonsData:checkMaxUpgrade(doid)
    if (not upgradeable) then
        if ui then
            ui:setShadowSpriteVisible(true)
        end
    end
end

-------------------------------------
-- function checkDragonSelect
-- @brief 선택이 가능한 드래곤인지 여부
-------------------------------------
function UI_DragonUpgradeNew:checkDragonSelect(doid)
	local upgradeable, msg = g_dragonsData:checkMaxUpgrade(doid)

    if upgradeable then
        return true
    else
        UIManager:toastNotificationRed(msg)
        return false
    end
end

-------------------------------------
-- function click_dragonUpgradeMaterial
-------------------------------------
function UI_DragonUpgradeNew:click_dragonUpgradeMaterial(data)
    local vars = self.vars

    local doid = data['id']

    local list_item = self.m_mtrlTableViewTD:getItem(doid)
    local list_item_ui = list_item['ui']
    
    if self.m_mSelectedMtrMap[doid] then
        local ui = self.m_mSelectedMtrMap[doid]
        self.m_mSelectedMtrMap[doid] = nil
        self.m_lSelectedMtrlList[ui.m_tag] = nil

        ui.root:removeFromParent()

        list_item_ui:setShadowSpriteVisible(false)
        self.m_selectedMaterialCnt = (self.m_selectedMaterialCnt - 1)
    else
        if self.m_currSlotIdx then
            local ui = UI_DragonCard(data)
            ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonUpgradeMaterial(data) end)
            ui.m_tag = self.m_currSlotIdx

            self.m_mSelectedMtrMap[doid] = ui

            self.m_lSelectedMtrlList[self.m_currSlotIdx] = ui
        
            --ui.root:setScale(0.57)
            local scale = 0.57
            cca.uiReactionSlow(ui.root, scale, scale, scale * 0.7)
            vars['materialNode' .. self.m_currSlotIdx]:addChild(ui.root)

            list_item_ui:setShadowSpriteVisible(true)
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

-------------------------------------
-- function click_upgradeBtn
-------------------------------------
function UI_DragonUpgradeNew:click_upgradeBtn()
	-- 승급 가능 여부
	local upgradeable, msg = g_dragonsData:checkUpgradeable(self.m_selectDragonOID)
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

        -- 골드 갱신
        if ret['gold'] then
            g_serverData:applyServerData(ret['gold'], 'user', 'gold')
            g_topUserInfo:refreshData()
        end

        self.m_bChangeDragonList = true

        local t_next_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)

        -- 연출 시작
        self:upgradeDirecting(doid, t_prev_dragon_data, t_next_dragon_data)
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
-- function upgradeDirecting
-- @brief 강화 연출
-------------------------------------
function UI_DragonUpgradeNew:upgradeDirecting(doid, t_prev_dragon_data, t_next_dragon_data)
    local block_ui = UI_BlockPopup()

    local directing_animation
    local directing_result

    -- 에니메이션 연출
    directing_animation = function()
        local vars = self.vars

        self.vars['upgradeVisual']:setVisible(true)
        self.vars['upgradeVisual']:setVisual('group', 'idle')
        self.vars['upgradeVisual']:setRepeat(false)
        self.vars['upgradeVisual']:addAniHandler(directing_result)
        SoundMgr:playEffect('EFFECT', 'exp_gauge')
    end

    -- 결과 연출
    directing_result = function()
        block_ui:close()
        
        -- 결과 팝업 (승급)
        if (t_prev_dragon_data['grade'] < t_next_dragon_data['grade']) then
            UI_DragonUpgradeResult(t_next_dragon_data, t_prev_dragon_data)
        end

        -- UI 갱신
        --self:setSelectDragonDataRefresh()
        --self:refresh_dragonIndivisual(doid)
        self:close()
    end

    --directing_animation()
    directing_result()
end


--@CHECK
UI:checkCompileError(UI_DragonUpgradeNew)
