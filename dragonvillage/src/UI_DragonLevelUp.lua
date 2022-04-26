local PARENT = class(UI_DragonManage_Base, ITabUI:getCloneTable())
local MAX_DRAGON_LEVELUP_MATERIAL_MAX = 30 -- 한 번에 사용 가능한 재료 수

local DRAGON_FOOD_EXP = 20000
local DRAGON_FOOD_GOLD = 2500

local L_LEVELUP_MTL = {}
L_LEVELUP_MTL.FOOD = 'food_lvup'
L_LEVELUP_MTL.DRAGON = 'dragon_lvup'

-------------------------------------
-- class UI_DragonLevelUp
-------------------------------------
UI_DragonLevelUp = class(PARENT,{
        m_dragonLevelUpUIHelper = 'UI_DragonLevelUpHelper',

        m_dragonFoodCnt = 'number',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonLevelUp:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonLevelUp'
    self.m_bVisible = true or false
    self.m_titleStr = Str('드래곤 레벨업')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLevelUp:init(doid)
    local vars = self:load('dragon_levelup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonLevelUp')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    -- 정렬 도우미
    self:init_dragonSortMgr()
	self:init_mtrDragonSortMgr(true) -- slime_first

    -- 선택한 드래곤에 포커싱
    self:focusSelectedDragon(doid)

    self:initDagonFoodMenu()
    self:initTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLevelUp:initUI()
    local vars = self.vars
    self:init_dragonTableView()
    self:initStatusUI()
end

-------------------------------------
-- function initStatusUI
-------------------------------------
function UI_DragonLevelUp:initStatusUI()
    local vars = self.vars
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
-- function initTab
-------------------------------------
function UI_DragonLevelUp:initTab()
    local vars = self.vars

    self:addTabAuto(L_LEVELUP_MTL.FOOD, vars, vars['food_lvupTabMenu'])
    self:addTabAuto(L_LEVELUP_MTL.DRAGON, vars, vars['dragon_lvupTabMenu'])
    self:setTab(L_LEVELUP_MTL.FOOD)

    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_DragonLevelUp:onChangeTab(tab, first)

    if (tab == L_LEVELUP_MTL.FOOD) then
        -- 펼침
        self:setFoodMenu(true)
        
        -- 기존 선택된 재료 리셋
        self.m_dragonLevelUpUIHelper:resetMaterial() 
    else
        -- 접힘
        self:setFoodMenu(false)
        
        -- 기존 선택된 자수정 리셋
        self.m_dragonFoodCnt = 0
    end
    
    self:refreshDagonFoodMenu(true) -- is_refresh_card
    self:refresh()
end

-------------------------------------
-- function initDagonFoodMenu
-------------------------------------
function UI_DragonLevelUp:initDagonFoodMenu()
    local vars = self.vars
    self.m_dragonFoodCnt = 0

    -- 버튼 누르고 있을 때 먹이 증/감 하도록 
    vars['plusBtn']:setPressedCB(function() self:countDagonFood(1) end)
    vars['minusBtn']:setPressedCB(function() self:countDagonFood(-1) end)

    vars['plusBtn']:registerScriptTapHandler(function() self:countDagonFood(1) end)
    vars['minusBtn']:registerScriptTapHandler(function() self:countDagonFood(-1) end)

    vars['foodShopBtn']:registerScriptTapHandler(function() self:buyDragonFood() end)

    vars['numLabel']:setString(0)
    vars['expLabel2']:setVisible(false)
    vars['itemLabel']:setVisible(false)
end

-------------------------------------
-- function refreshDagonFoodMenu
-------------------------------------
function UI_DragonLevelUp:refreshDagonFoodMenu(is_refresh_card)
    local vars = self.vars
    vars['numLabel']:setString(comma_value(self.m_dragonFoodCnt))

    if (is_refresh_card) then
        local dragonFood = g_userData:get('dragon_food')
        local item_card = UI_ItemCard(700016, dragonFood) -- 드래곤 먹이 아이템
        item_card:showZeroCount()
        vars['itemNode']:removeAllChildren()
        vars['itemNode']:addChild(item_card.root)
    end
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonLevelUp:initButton()
    local vars = self.vars
    vars['levelupBtn']:registerScriptTapHandler(function() 
        if (self.m_currTab == L_LEVELUP_MTL.FOOD) then
            self:click_dragonFoodLevelupBtn()
        else
            self:click_levelupBtn()
        end 
    end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLevelUp:refresh()

    if self.m_selectDragonOID then
        self.m_dragonLevelUpUIHelper = UI_DragonLevelUpHelper(self.m_selectDragonOID, MAX_DRAGON_LEVELUP_MATERIAL_MAX)
    end

    self.m_dragonFoodCnt = 0
    self:refreshDagonFoodMenu()
    
    self:refresh_dragonInfo()
    self:refresh_selectedMaterial()
    
	self:refresh_dragonMaterialTableView()
end

-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonLevelUp:refresh_dragonInfo()
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
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'])
    end

    do -- 드래곤 역할(role)
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'])
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

    -- 레벨업 가능 여부 처리
	local possible = g_dragonsData:possibleDragonLevelUp(self.m_selectDragonOID)
	vars['lockSprite']:setVisible(not possible)
    if (not possible) then
        local next_grade = t_dragon_data['grade'] + 1
        vars['infoLabel2']:setString(Str('{1}성 승급시 레벨업 할 수 있어요', next_grade))
    end
end

-------------------------------------
-- function setAttrBonusLabel
-- @brief 레벨업 할 드래곤과 재료 드래곤의 속성이 같으면 50% 추가 텍스트 표시
-------------------------------------
function UI_DragonLevelUp:setAttrBonusLabel(dragon_card)
    local dragon_object = self.m_selectDragonData
    if (not dragon_object) then
        return
    end

    -- 레벨업 할 드래곤의 속성
    local attr = dragon_object:getAttr()

    -- 재료의 속성
    local attr2 = dragon_card.m_dragonData:getAttr()

    -- 속성이 도일할 경우
    if (attr == attr2) then
        dragon_card:setExpSpriteVisible(true)
    end
end

-------------------------------------
-- function setDefaultSelectDragon
-- @brief 지정된 드래곤이 없을 경우 기본 드래곤을 설정
-------------------------------------
function UI_DragonLevelUp:setDefaultSelectDragon(doid)
	-- 레벨업 마스터의 길 ... 불속성 슬라임이니 불속성 공격형 드래곤을 선택하도록 한다
	if (g_masterRoadData:getFocusRoad() == 10010) then
		local profer_doid = nil

		for i, t_item in pairs(self.m_tableViewExt.m_itemList) do
			local data = t_item['data']
			-- 불속성 공격형
			if (data:getAttr() == T_ATTR_LIST[ATTR_FIRE]) and (data:getRole() == 'dealer') then
				profer_doid = data['id']
				self.m_selectDragonOID = profer_doid
				local b_force = true
				self:setSelectDragonData(profer_doid, b_force)
				break
			end
		end

		-- 불속성 드래곤이 없을린 없지만 없다면 기존 로직을 태움
		if (profer_doid) then
			return
		end
	end

    PARENT.setDefaultSelectDragon(self, doid)
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonLevelUp:getDragonList()
    local dragon_dic = g_dragonsData:getDragonListWithSlime()

    -- 절대 레벨업 불가능한 드래곤 제외
    for oid, v in pairs(dragon_dic) do
        if (g_dragonsData:impossibleLevelupForever(oid)) then
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
function UI_DragonLevelUp:getDragonMaterialList(doid)
    local dragon_dic = g_dragonsData:getDragonsList()

    -- 자기 자신 드래곤 제외
    if doid then
        dragon_dic[doid] = nil
    end

    local slime_dic = g_slimesData:getSlimeList()
    for oid, v in pairs(slime_dic) do
    	-- 레벨업 슬라임 추가
        if (v:getSlimeType() == 'exp') then
			dragon_dic[oid] = v
		end
    end

    return dragon_dic
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonLevelUp:click_dragonMaterial(t_dragon_data)
    local doid = t_dragon_data['id']

    -- 재료로 사용 가능한 드래곤 검증
    if (t_dragon_data:getObjectType() == 'dragon') then
        local possible, noti_str = g_dragonsData:possibleMaterialDragon(doid)
        if (not possible) then
            UIManager:toastNotificationRed(noti_str)
            return
        end
    -- 재료로 사용 가능한 슬라임 검증
    elseif (t_dragon_data:getObjectType() == 'slime') then
        local possible, noti_str = g_slimesData:possibleMaterialSlime(doid, 'exp')
        if (not possible) then
            UIManager:toastNotificationRed(noti_str)
            return
        end
    end

    local helper = self.m_dragonLevelUpUIHelper
    if (not helper:isSelectedDragon(doid)) then
        local is_can_add, fail_type = helper:isCanAdd()

        if (not is_can_add) then
            if (fail_type == 'max_cnt') then
                UIManager:toastNotificationRed(Str('한 번에 최대 {1}마리까지 가능합니다.', MAX_DRAGON_LEVELUP_MATERIAL_MAX))
            elseif (fail_type == 'max_lv') then
                UIManager:toastNotificationRed(Str('더 이상 레벨업할 수 없습니다.', MAX_DRAGON_LEVELUP_MATERIAL_MAX))
            end
            return
        end
    end

    local function next_func()
        self.m_dragonLevelUpUIHelper:modifyMaterial(doid)
        self:refresh_materialDragonIndivisual(doid)
        self:refresh_selectedMaterial()
    end

    -- 재료 경고
    if self.m_dragonLevelUpUIHelper:isSelectedDragon(doid) then
        -- 해제
        next_func()
    else
        -- 선택
        local oid = t_dragon_data['id']
        g_dragonsData:dragonMaterialWarning(oid, next_func)
    end
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonLevelUp:refresh_materialDragonIndivisual(doid)
    if (not self.m_mtrlTableViewTD) then
        return
    end

    local item = self.m_mtrlTableViewTD:getItem(doid)
    if (not item) then
        return
    end
    
    local ui = item['ui']
    if (not ui) then
        return
    end

    local helper = self.m_dragonLevelUpUIHelper
    local is_selected = helper:isSelectedDragon(doid)
    ui:setCheckSpriteVisible(is_selected)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonLevelUp:refresh_selectedMaterial()
    local vars = self.vars
    
    local helper = self.m_dragonLevelUpUIHelper
    if (not helper) then
        return
    end

    local t_dragon_data = self.m_selectDragonData
    local doid = t_dragon_data['id']

    vars['selectLabel']:setString(helper:getMaterialCountString())
    vars['expGauge']:runAction(cc.ProgressTo:create(0.2, (helper.m_expPercentage)))

    vars['levelLabel']:setString(Str('레벨{1}/{2}', helper.m_changedLevel, helper.m_maxLevel))
    vars['expLabel']:setString(Str('{1}/{2}', comma_value(helper.m_changedExp), comma_value(helper.m_changedMaxExp)))

    local plus_level = helper:getPlusLevel()
    vars['gradeLabel']:setString(Str('+{1}', plus_level))
    
    -- 레벨업 가능 여부에 따라 문구 변경
    local price = ''
    local info_str = ''

    -- 드래곤 먹이를 사용할 경우 소모 골드 표시
    if (self.m_currTab == L_LEVELUP_MTL.FOOD) then
        price = comma_value(self.m_dragonFoodCnt * DRAGON_FOOD_GOLD)
        info_str = ''
    else
        if (g_dragonsData:possibleDragonLevelUp(doid)) then
            price = comma_value(helper.m_price)
            info_str = Str('TIP. 대상 드래곤의 친밀도가 높으면 보너스 경험치 획득 확률이 높아져요')
        else
            price = Str('불가')
            info_str = Str('TIP. 승급을 하면 레벨을 올릴 수 있습니다.')
        end
    end
    vars['priceLabel']:setString(price)
    vars['infoLabel']:setString(info_str)

    -- 능력치 정보 갱신
    self:refresh_stats(t_dragon_data, helper.m_changedLevel)
end

-------------------------------------
-- function refresh_stats
-- @brief 능력치
-------------------------------------
function UI_DragonLevelUp:refresh_stats(t_dragon_data, lv)
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
    chaged_dragon_data['lv'] = lv
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
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-- @override
-------------------------------------
function UI_DragonLevelUp:createDragonCardCB(ui, data)
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief 재료 카드 만든 후..
-------------------------------------
function UI_DragonLevelUp:createMtrlDragonCardCB(ui, data)
    if (not ui) then
        return
    end

    -- 선택한 드래곤이 레벨업 가능한지 판단
    local doid = self.m_selectDragonOID
    if (not g_dragonsData:possibleDragonLevelUp(doid)) then
        ui:setShadowSpriteVisible(true)
        return
    end

    -- 재료 드래곤이 재료 가능한지 판별
    doid = data['id']
    local is_shadow = false
    if (data:getObjectType() == 'dragon') then
        is_shadow = not g_dragonsData:possibleMaterialDragon(doid)
    elseif (data:getObjectType() == 'slime') then
        is_shadow = not g_slimesData:possibleMaterialSlime(doid, 'exp')
    end

    ui:setShadowSpriteVisible(is_shadow)
    self:setAttrBonusLabel(ui)

    -- 프레스 함수 세팅
    local press_card_cb = function()
        local doid = data['id']
        if doid and (doid ~= '') then
            local ui = UI_SimpleDragonInfoPopup(data)
			local is_selected = self.m_dragonLevelUpUIHelper:isSelectedDragon(doid)
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
end

-------------------------------------
-- function click_levelupBtn
-- @brief
-------------------------------------
function UI_DragonLevelUp:click_levelupBtn()
    local doid = self.m_selectDragonOID

    -- 현재 레벨업 가능한 드래곤인지 검증
    local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)
    if (not possible) then
        UIManager:toastNotificationRed(msg)
        return
    end

    local helper = self.m_dragonLevelUpUIHelper

    if (helper.m_materialCount <= 0) then
        UIManager:toastNotificationRed(Str('재료 드래곤을 선택해주세요!'))
        return
    end

    -- 골드가 충분히 있는지 확인
    if (not ConfirmPrice('gold', self.m_dragonLevelUpUIHelper.m_price)) then
        return
    end

    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '드래곤 레벨업')

        local prev_lv = self.m_selectDragonData['lv']
        local prev_exp = self.m_selectDragonData['exp']
        local curr_lv = ret['modified_dragon']['lv']
        local bonus_rate = (ret['bonus'] or 100) -- 100일 경우 보너스 발동을 안한 상태

        if (prev_lv == curr_lv) then
            self:response_levelup(ret, bonus_rate)
        else
            -- 드래곤 성장일지 : 드래곤 등급, 레벨 체크
            local start_dragon_data = g_dragonDiaryData:getStartDragonData(ret['modified_dragon'])
            if (start_dragon_data) then
                -- @ DRAGON DIARY
                local t_data = {clear_key = 'd_lv', sub_data = start_dragon_data}
                g_dragonDiaryData:updateDragonDiary(t_data)
            end

            -- 드래곤 정보 갱신 (임시 위치)
            g_dragonsData:applyDragonData(ret['modified_dragon'])
            local ui = UI_DragonLevelupResult(StructDragonObject(ret['modified_dragon']), prev_lv, prev_exp, bonus_rate)
            local function close_cb()
                self:response_levelup(ret)
            end
            ui:setCloseCB(close_cb)
        end

    end

    local uid = g_userData:get('uid')
    local src_doids = ''
    local src_soids = ''
    do
        for _doid,type in pairs(helper.m_materialDoidMap) do
            if (type == 'dragon') then
                if (src_doids == '') then
                    src_doids = tostring(_doid)
                else
                    src_doids = src_doids .. ',' .. tostring(_doid)
                end
            elseif (type == 'slime') then
                if (src_soids == '') then
                    src_soids = tostring(_doid)
                else
                    src_soids = src_soids .. ',' .. tostring(_doid)
                end
            end
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/levelup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('src_doids', src_doids)
    ui_network:setParam('src_soids', src_soids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function response_levelup
-- @brief
-------------------------------------
function UI_DragonLevelUp:response_levelup(ret, bonus_rate)

    -- 보너스 표시
    if bonus_rate and (100 < bonus_rate) then
        self.vars['bonusVisual']:setVisible(true)
        self.vars['bonusVisual']:changeAni('success_' .. tostring(bonus_rate))
        local function ani_handler()
            self.vars['bonusVisual']:setVisible(false)    
        end
        self.vars['bonusVisual']:addAniHandler(ani_handler)
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

    -- 골드 갱신
    g_serverData:networkCommonRespone(ret)

    self.m_bChangeDragonList = true

    self:setSelectDragonDataRefresh()

    local doid = self.m_selectDragonOID
    self:refresh_dragonIndivisual(doid)

    -- @ MASTER ROAD
    local t_data = {clear_key = 'd_lvup'}
    g_masterRoadData:updateMasterRoad(t_data)

    -- @ DRAGON DIARY
    local t_data = {clear_key = 'd_lvup', ret = ret}
    g_dragonDiaryData:updateDragonDiary(t_data)
end

-------------------------------------
-- function refresh_dragonIndivisual_material
-------------------------------------
function UI_DragonLevelUp:refresh_dragonIndivisual_material(doid)
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

    -- 갱신된 드래곤이 선택된 드래곤일 경우
    if (doid == self.m_selectDragonOID) then
        self:setSelectDragonData(doid, true)
    end
end


-------------------------------------
-- function countDagonFood
-------------------------------------
function UI_DragonLevelUp:countDagonFood(cnt)
    local dragonFood = g_userData:get('dragon_food')
    local used_dragonFood = self.m_dragonFoodCnt
    local helper = self.m_dragonLevelUpUIHelper

    if (cnt > 0) then
        if (used_dragonFood + cnt > dragonFood) then
            UIManager:toastNotificationRed(Str('드래곤 먹이가 부족합니다.', MAX_DRAGON_LEVELUP_MATERIAL_MAX))
            return
        end

        -- 최대 레벨 달성했을 경우 더이상 추가하는 걸 막음
        local is_can_add, fail_type = helper:isCanAdd()
        if (not is_can_add) then
            UIManager:toastNotificationRed(Str('더 이상 레벨업할 수 없습니다.', MAX_DRAGON_LEVELUP_MATERIAL_MAX))
            return
        end
    end

    if (cnt < 0) then 
        if (used_dragonFood == 0) then
            return
        end
    end


    self.m_dragonFoodCnt = self.m_dragonFoodCnt + cnt
    self:refreshDagonFoodMenu()

    helper:addExp(cnt * DRAGON_FOOD_EXP)
    self:refresh_selectedMaterial()
end

-------------------------------------
-- function setFoodMenu
-------------------------------------
function UI_DragonLevelUp:setFoodMenu(is_enable)
    local vars = self.vars

    -- 비/활성화 일 때 가져주는 항목들
    for i = 1, 4 do
        if (vars['colorSprite' .. i]) then
            vars['colorSprite' .. i]:setVisible(is_enable)
        end
    end
end

-------------------------------------
-- function buyDragonFood
-------------------------------------
function UI_DragonLevelUp:buyDragonFood()
    -- 드래곤 먹이 product_struct
    local product_struct = g_shopDataNew:getProduct('amethyst', 220026)
    product_struct:buy(function(ret)
        ItemObtainResult_Shop(ret) 
        self:refreshDagonFoodMenu(true)
    end)
end

-------------------------------------
-- function click_dragonFoodLevelupBtn
-------------------------------------
function UI_DragonLevelUp:click_dragonFoodLevelupBtn()
    if (self.m_dragonFoodCnt == 0) then
        return
    end

    local dragon_food_cnt = g_userData:get('dragon_food') 
    if (self.m_dragonFoodCnt > dragon_food_cnt) then
        UIManager:toastNotificationRed(Str('재료가 부족합니다.'))
        return
    end

    -- 골드가 충분히 있는지 확인
    if (not ConfirmPrice('gold', self.m_dragonFoodCnt * DRAGON_FOOD_GOLD)) then
        return
    end

    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '드래곤 레벨업')

        local prev_lv = self.m_selectDragonData['lv']
        local prev_exp = self.m_selectDragonData['exp']
        local curr_lv = ret['modified_dragon']['lv']
        local bonus_rate = (ret['bonus'] or 100) -- 100일 경우 보너스 발동을 안한 상태

        if (prev_lv == curr_lv) then
            self:response_levelup(ret, bonus_rate)
            self.m_dragonFoodCnt = 0
            self:refreshDagonFoodMenu(true) -- is_refresh_card
        else
            -- 드래곤 성장일지 : 드래곤 등급, 레벨 체크
            local start_dragon_data = g_dragonDiaryData:getStartDragonData(ret['modified_dragon'])
            if (start_dragon_data) then
                -- @ DRAGON DIARY
                local t_data = {clear_key = 'd_lv', sub_data = start_dragon_data}
                g_dragonDiaryData:updateDragonDiary(t_data)
            end

            -- 드래곤 정보 갱신 (임시 위치)
            g_dragonsData:applyDragonData(ret['modified_dragon'])
            local ui = UI_DragonLevelupResult(StructDragonObject(ret['modified_dragon']), prev_lv, prev_exp, bonus_rate)
            local function close_cb()
                self:response_levelup(ret)
                self.m_dragonFoodCnt = 0
                self:refreshDagonFoodMenu(true) -- is_refresh_card
            end
            ui:setCloseCB(close_cb)
        end
    end

    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID

    local src_doids = ''
    local src_soids = ''
    local dragon_food = self.m_dragonFoodCnt

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/levelup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('food_cnt', dragon_food)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function checkSelectedDragonCondition
-------------------------------------
function UI_DragonLevelUp:checkSelectedDragonCondition(dragon_object)
    if (not dragon_object) then
        return false
    end
    -- StructSlimeObject는 soid (== id)
    -- StructDragonObject는 doid (== id)
    -- 두 클래스 모두 id에 값을 저장하고 있다
    local doid = dragon_object['id']
    local object_type = dragon_object:getObjectType()
    local upgradeable, msg = g_dragonsData:impossibleLevelupForever(doid)
    if (upgradeable) then
        UIManager:toastNotificationRed(msg)
        return false
    end
    return true
end

--@CHECK
UI:checkCompileError(UI_DragonLevelUp)
