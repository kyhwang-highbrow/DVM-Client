local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_HatcherySummonTab
-------------------------------------
UI_HatcherySummonTab = class(PARENT,{
        m_isCustomPick = '',

        m_orgDragonList = '',

        m_tableViewTD = '',
		m_roleRadioButton = 'UIC_RadioButton',
        m_attrRadioButton = 'UIC_RadioButton',

        m_sortManager = 'SortManager',

        m_summonCategoryTab = '{pickup, cash, friend}',

        m_selectedDragonList = 'table',  -- 한 속성에서 왔다갔다 선택 했을 때의 체크표시 처리 용
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HatcherySummonTab:init(owner_ui)
    local vars = self:load('hatchery_summon.ui')

	-- @ TUTORIAL : 1-7 end, 101
	local tutorial_key = TUTORIAL.ADV_01_07_END
	local check_step = 101
	TutorialManager.getInstance():continueTutorial(tutorial_key, check_step, self)

    -- 고급 소환은 5성 전설(일반)만 선택 가능하기 때문에
    -- 전설드래곤 선택권(일반) 과 같은 리스트를 써도 됨
    self.m_orgDragonList = TablePickDragon:getDragonList(700304, g_dragonsData.m_mReleasedDragonsByDid)
    self.m_selectedDragonList = {}
    self.m_summonCategoryTab = {pickup = vars['chanceUpTabMenu'], cash = vars['premiumMenu'], friend = vars['friendshipTabMenu']}

    self:initSortManager()
end

-------------------------------------
-- function initSortManager
-- @brief
-------------------------------------
function UI_HatcherySummonTab:initSortManager()
    local sort_manager = SortManager_Dragon()
    sort_manager:pushSortOrder('did')
	sort_manager:pushSortOrder('attr')
    self.m_sortManager = sort_manager
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_HatcherySummonTab:onEnterTab(first)
    self.m_ownerUI:hideNpc() -- NPC 등장
    self.m_ownerUI:hideMileage() -- 마일리지 메뉴

    if (first == true) then
        self:initUI()
    end

    -- 전설 확률 2배 이벤트일 경우 해당 메뉴를 켜준다
    if (g_hotTimeData:isActiveEvent('event_legend_chance_up') or g_fevertimeData:isActiveFevertime_summonLegendUp()) then
        self.vars['eventNoti1']:setVisible(true)
    else
        self.vars['eventNoti1']:setVisible(false)
    end

    self:onChangeCategory('pickup')
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_HatcherySummonTab:onExitTab()
    self.m_ownerUI:hideMileage()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HatcherySummonTab:initUI()
    local vars = self.vars

    for i, t_data in pairs(g_hatcheryData:getGachaList()) do
        local btn = UI()
        btn:load('hatchery_summon_item.ui')

        -- addChild
        local ui_type = t_data['ui_type']
        vars['summonNode_' .. ui_type]:addChild(btn.root)
        
        -- 광고 무료 뽑기
        if (t_data['is_ad']) then
            btn.vars['priceLabel']:setString(Str('1일 1회'))
            btn.vars['priceLabel']:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
            btn.vars['priceNode']:removeAllChildren()

            btn.vars['countLabel']:setString(Str('무료 소환'))
            btn.vars['countLabel']:setTextColor(COLOR['diff_normal'])

        -- 버튼 UI 설정
        else
            -- 가격
            local price = t_data['price']
            btn.vars['priceLabel']:setString(comma_value(price))

            -- 가격 아이콘
            local price_type = t_data['price_type']
            local price_icon = IconHelper:getPriceIcon(price_type)
            btn.vars['priceNode']:removeAllChildren()
            btn.vars['priceNode']:addChild(price_icon)
            
            -- 뽑기 횟수 안내
            local count_str
            if (t_data['bundle']) then
                count_str = t_data['egg_id'] == 700001 and Str('10회') or Str('10 + 1회')
                btn.vars['countLabel']:setTextColor(cc.c4b(255, 215, 0, 255))
            else
                count_str = Str('1회')
            end
            btn.vars['countLabel']:setString(count_str)
        end

        -- 버튼 콜백
        btn.vars['summonBtn']:registerScriptTapHandler(function()
            self:requestSummon(t_data)

            -- @tutorial 에서 갱신 시키는 목적
			if (ui_type == 'cash11') then
				local price = btn.vars['priceLabel']:getString()
				price = tonumber(price)
				if (price == nil) then
					btn.vars['priceLabel']:setString(comma_value(t_data['price']))
				end
			end
        end)
        
		-- tutorial 에서 접근하기 위함
		if (ui_type == 'cash11') then
			if (TutorialManager.getInstance():isDoing()) then
				self.m_ownerUI.vars['tutorialSummon11Btn'] = btn.vars['summonBtn']
				btn.vars['priceLabel']:setString(Str('무료'))
			end
		end
    end

    -- 소환 확률 안내 (네이버 sdk 링크)
    NaverCafeManager:setPluginInfoBtn(vars['plugInfoBtn'], 'summon_info')

    vars['chanceUpTabBtn']:registerScriptTapHandler(function() self:onChangeCategory('pickup') end)
    vars['premiumTabBtn']:registerScriptTapHandler(function() self:onChangeCategory('cash') end)
    vars['friendshipTabBtn']:registerScriptTapHandler(function() self:onChangeCategory('friend') end)

    vars['infoBtn']:registerScriptTapHandler(function() UI_HacheryInfoBtnPopup() end)


    -- 광고 보기 버튼 체크
    vars['summonNode_fp_ad']:setVisible(g_advertisingData:isAllowToShow(AD_TYPE['FSUMMON']))
    vars['summonNode_fp_ad']:runAction(cca.buttonShakeAction(2, 2))

    self:initTableView()

    self:initRadioButton()
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_HatcherySummonTab:initTableView()
    local node = self.vars['listNode']

	-- did 지정 타입 선택권인 경우 길이 늘림 (다른 버튼을 숨기므로 허전)
	if (self.m_isCustomPick) then
		node:setContentSize(700, 550)	
	end

    local l_item_list = {}

	-- cell_size 지정
    local item_size = 151
    local item_scale = 0.66
    local cell_size = cc.size(item_size*item_scale + 0, item_size*item_scale + 0)

    -- 리스트 아이템 생성 콜백
    local function create_func(data)
        local did = data['did']
		local t_data = {['evolution'] = 1, ['grade'] = data['birthgrade']}
		
        local ui = MakeSimpleDragonCard(did, t_data)
		ui.root:setScale(item_scale)

		-- 클릭
		ui.vars['clickBtn']:registerScriptTapHandler(function()
            self:requestSelectPickup(data)
		end)
        return ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cell_size
    table_view_td.m_nItemPerCell = 6
	table_view_td:setCellUIClass(create_func)
	table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- 정렬
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HatcherySummonTab:refresh()
    -- normal_did 물불땅 / unique_did 빛어둠
    -- 바로 알아볼 수 있게 같은 로직 두번 돌림
    local normal_did, unique_did = g_hatcheryData:getSelectedPickup()
    local dragon_card

    for i, did in ipairs(self.m_selectedDragonList) do
        dragon_card = self.m_tableViewTD:getCellUI(did)

        if (dragon_card) then dragon_card:setCheckSpriteVisible(false) end
    end

    self.m_selectedDragonList = {}

    if (normal_did) then 
        dragon_card = self.m_tableViewTD:getCellUI(normal_did)
        if (dragon_card) then 
            dragon_card:setCheckSpriteVisible(true)
            table.insert(self.m_selectedDragonList, normal_did)
        end
    end

    if (unique_did) then 
        dragon_card = self.m_tableViewTD:getCellUI(unique_did)
        if (dragon_card) then 
            dragon_card:setCheckSpriteVisible(true)
            table.insert(self.m_selectedDragonList, unique_did)
        end
    end

    self:setChanceUpDragons()

    local is_definite_pickup = g_hatcheryData.m_isDefinitePickup == true
    if (self.vars['rateNoti']) then self.vars['rateNoti']:setVisible(is_definite_pickup) end
    
end

-------------------------------------
-- function onChangeOption
-- @brief
-------------------------------------
function UI_HatcherySummonTab:onChangeCategory(category)
    for name, tab_object in pairs(self.m_summonCategoryTab) do
        local is_same_category = name == category
        tab_object:setVisible(is_same_category) 
    end
end



-------------------------------------
-- function makeDragonInfoMap
-- @brief 
-------------------------------------
function UI_HatcherySummonTab:makeDragonInfoMap(list)
    local l_dragon = list or self.m_orgDragonList
    local dragon_map = {}

    for k, v in pairs(l_dragon) do
        if (v) and (not isNullOrEmpty(v['did'])) then
            dragon_map[v['did']] = v
        end
    end

    return dragon_map
end


-------------------------------------
-- function initRadioButton
-------------------------------------
function UI_HatcherySummonTab:initRadioButton()
    local vars = self.vars

    do -- 역할(role)
        local radio_button = UIC_RadioButton()
        radio_button:addButtonWithLabel('all', vars['roleAllRadioBtn'], vars['roleAllRadioLabel'])
        radio_button:addButtonAuto('tanker', vars)
        radio_button:addButtonAuto('dealer', vars)
        radio_button:addButtonAuto('supporter', vars)
        radio_button:addButtonAuto('healer', vars)
        radio_button:setSelectedButton('all')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_roleRadioButton = radio_button
    end

    do -- 속성(attribute)
        local radio_button = UIC_RadioButton()
        radio_button:addButtonAuto('earth', vars)
        radio_button:addButtonAuto('water', vars)
        radio_button:addButtonAuto('fire', vars)
        radio_button:addButtonAuto('light', vars)
        radio_button:addButtonAuto('dark', vars)
        radio_button:setSelectedButton('earth')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_attrRadioButton = radio_button
    end

    -- 최초에 한번 실행
    self:onChangeOption()
end

-------------------------------------
-- function onChangeOption
-- @brief
-------------------------------------
function UI_HatcherySummonTab:onChangeOption()
    local role_option = self.m_roleRadioButton.m_selectedButton
    local attr_option = self.m_attrRadioButton.m_selectedButton

    local l_item_list = {}
	for _, t_dragon in ipairs(self.m_orgDragonList) do
		local b = true

		-- 직군
		if (role_option ~= 'all') and (role_option ~= t_dragon['role']) then 
			b = false
		end

		-- 속성
		if (attr_option ~= t_dragon['attr']) then
			b = false
		end

		if (b) then
			table.insert(l_item_list, t_dragon)
		end
	end
	
    -- 리스트 갱신
    self.m_tableViewTD:setItemList(self:makeDragonInfoMap(l_item_list))

    -- 정렬
    self.m_sortManager:sortExecution(self.m_tableViewTD.m_itemList)

    self.m_tableViewTD:update(0)
    self.m_tableViewTD:relocateContainerFromIndex(1)
    
	-- ui편의를 위해 조건 변경 시 첫번째 드래곤을 화면에 띄운다
	self:refresh()
end


-------------------------------------
-- function setChanceUpDragons
-- @brief 확률업 드래곤 
-------------------------------------
function UI_HatcherySummonTab:setChanceUpDragons()
    local vars = self.vars

    local idx = 0
    local desc_idx = 0 -- dragonName1 :드래곤 1마리 일 때, dragonName2, dragonName3 : 드래곤 2마리 일 때

    -- 이제 픽업은 직접 선택한다.
    vars['summonAttrMenu1']:setVisible(false)
    vars['summonAttrMenu2']:setVisible(true)

    -- normal_did 물불땅 / unique_did 빛어둠
    -- 바로 알아볼 수 있게 같은 로직 두번 돌림
    local normal_did, unique_did = g_hatcheryData:getSelectedPickup()
    local l_dragon = {}

    if (normal_did) then table.insert(l_dragon, {did = normal_did}) end
    if (unique_did) then table.insert(l_dragon, {did = unique_did}) end

    local pickup_dragon_map = self:makeDragonInfoMap(l_dragon)

    if (table.count(pickup_dragon_map) <= 0) then
        vars['dragonNameLabel2']:setString('')
        vars['dragonNameLabel3']:setString('')
    end

    for _, t_data in pairs(pickup_dragon_map) do
        local did = t_data['did']
        local attr = TableDragon:getDragonAttr(did)

        -- 빛어둠 3 / 땅물불 2
        idx = isExistValue(attr, 'light', 'dark') and 3 or 2
        desc_idx = idx

        -- 드래곤 이름
        local name = TableDragon:getChanceUpDragonName2(did)

        vars['dragonNameLabel'..desc_idx]:setString(name)

        -- 드래곤 카드
        do
            local t_dragon_data = {}
            t_dragon_data['did'] = did
            t_dragon_data['evolution'] = 1
            t_dragon_data['grade'] = 5
            t_dragon_data['skill_0'] = 1
            t_dragon_data['skill_1'] = 1
            t_dragon_data['skill_2'] = 0
            t_dragon_data['skill_3'] = 0

            -- 드래곤 클릭 시, 도감 팝업
            local func_tap = function()
                UI_BookDetailPopup.openWithFrame(did, nil, 1, 0.8, true)    -- param : did, grade, evolution scale, ispopup
            end

            local dragon_card = UI_DragonCard(StructDragonObject(t_dragon_data))
            dragon_card.root:setScale(0.66)
            dragon_card.vars['clickBtn']:registerScriptTapHandler(function() func_tap() end)
            vars['dragonCard'..desc_idx]:addChild(dragon_card.root)
        end
    end
end




-------------------------------------
-- function click_eventSummonBtn
-- @brief 확률업
-------------------------------------
function UI_HatcherySummonTab:click_eventSummonBtn(is_bundle, is_sale, t_egg_data, old_ui)
    -- 드래곤 최대치 보유가 넘었는지 체크
    local summon_cnt = 1
    if (is_bundle == true) then
        summon_cnt = 11
    end
    if (not g_dragonsData:checkDragonSummonMaximum(summon_cnt)) then
        return
    end

    local function finish_cb(ret)
        -- 이어서 뽑기를 했을 때 이전 결과 UI가 통신 후에 닫히도록 처리
        if (old_ui) then
            old_ui:setCloseCB(nil)
            old_ui:close()
        end

		local gacha_type = 'cash'
        local l_dragon_list = ret['added_dragons']
        local l_slime_list = ret['added_slimes']
        local egg_id = t_egg_data['egg_id']
        local egg_res = t_egg_data['egg_res']
        local added_mileage = ret['added_mileage'] or 0

        local ui = UI_GachaResult_Dragon(gacha_type, l_dragon_list, l_slime_list, egg_id, egg_res, t_egg_data, added_mileage)

        local function close_cb()
            self:summonApiFinished()
        end
        ui:setCloseCB(close_cb)

        -- 이어서 뽑기 설정
        self:subsequentSummons(ui, t_egg_data)
    end

    local function fail_cb()
    end

    g_hatcheryData:request_summonCashEvent(is_bundle, is_sale, finish_cb, fail_cb)
end

-------------------------------------
-- function click_cashSummonBtn
-- @brief 캐시 뽑기
-------------------------------------
function UI_HatcherySummonTab:click_cashSummonBtn(is_bundle, is_sale, t_egg_data, old_ui)

    -- 드래곤 최대치 보유가 넘었는지 체크
    local summon_cnt = 1
    if (is_bundle == true) then
        summon_cnt = 11
    end
    if (not g_dragonsData:checkDragonSummonMaximum(summon_cnt)) then
        return
    end

    local function finish_cb(ret)
        -- 이어서 뽑기를 했을 때 이전 결과 UI가 통신 후에 닫히도록 처리
        if (old_ui) then
            old_ui:setCloseCB(nil)
            old_ui:close()
        end

		local gacha_type = 'cash'
        local l_dragon_list = ret['added_dragons']
        local l_slime_list = ret['added_slimes']
        local egg_res = t_egg_data['egg_res']
        local egg_id = t_egg_data['egg_id']
        local added_mileage = ret['added_mileage'] or 0
        local ui = UI_GachaResult_Dragon(gacha_type, l_dragon_list, l_slime_list, egg_id, egg_res, t_egg_data, added_mileage)

        local function close_cb()
            self:summonApiFinished()
        end
        ui:setCloseCB(close_cb)

        -- 이어서 뽑기 설정
        self:subsequentSummons(ui, t_egg_data)
    end

    local function fail_cb()
    end

    g_hatcheryData:request_summonCash(is_bundle, is_sale, finish_cb, fail_cb)
end

-------------------------------------
-- function click_friendSummonBtn
-- @brief 우정포인트 뽑기
-------------------------------------
function UI_HatcherySummonTab:click_friendSummonBtn(is_bundle, is_ad, t_egg_data, old_ui)
    -- 드래곤 최대치 보유가 넘었는지 체크
    local summon_cnt = 1
    if (is_bundle == true) then
        summon_cnt = 10 -- 우정 포인트는 소환은 bundle이 10개임 보너스 1개가 없음
    end
    if (not g_dragonsData:checkDragonSummonMaximum(summon_cnt)) then
        return
    end

    local function finish_cb(ret)
        -- 이어서 뽑기를 했을 때 이전 결과 UI가 통신 후에 닫히도록 처리
        if (old_ui) then
            old_ui:setCloseCB(nil)
            old_ui:close()
        end

		local gacha_type = 'fp'
        local l_dragon_list = ret['added_dragons']
        local l_slime_list = ret['added_slimes']
        local egg_id = t_egg_data['egg_id']
        local egg_res = t_egg_data['egg_res']
        local ui = UI_GachaResult_Dragon(gacha_type, l_dragon_list, l_slime_list, egg_id, egg_res, t_egg_data)

        -- 이어서 뽑기 설정
        self:subsequentSummons(ui, t_egg_data)

        local function close_cb()
            self:summonApiFinished()

            if (is_ad) then
                -- 광고 보기 버튼 체크
                self.vars['summonNode_fp_ad']:setVisible(false)
            end
        end
        ui:setCloseCB(close_cb)
    end

    local function fail_cb()
    end

    -- 무료 뽑기는 광고 시청
    if (is_ad) then
        AdSDKSelector:showDailyAd(AD_TYPE['FSUMMON'], function()
            g_hatcheryData:request_summonFriendshipPoint(is_bundle, is_ad, finish_cb, fail_cb)
        end)
    else
        g_hatcheryData:request_summonFriendshipPoint(is_bundle, is_ad, finish_cb, fail_cb)
    end
end

-------------------------------------
-- function click_pickupSummonBtn
-- @brief 확률업
-------------------------------------
function UI_HatcherySummonTab:click_pickupSummonBtn(is_bundle, is_sale, t_egg_data, old_ui)
    -- 드래곤 최대치 보유가 넘었는지 체크
    local summon_cnt = 1
    if (is_bundle == true) then
        summon_cnt = 10
    end

    if (not g_dragonsData:checkDragonSummonMaximum(summon_cnt)) then
        return
    end

    local function finish_cb(ret)
        -- 이어서 뽑기를 했을 때 이전 결과 UI가 통신 후에 닫히도록 처리
        if (old_ui) then
            old_ui:setCloseCB(nil)
            old_ui:close()
        end

		local gacha_type = 'cash'
        local l_dragon_list = ret['added_dragons']
        local l_slime_list = ret['added_slimes']
        local egg_id = t_egg_data['egg_id']
        local egg_res = t_egg_data['egg_res']
        local added_mileage = ret['added_mileage'] or 0

        local ui = UI_GachaResult_Dragon(gacha_type, l_dragon_list, l_slime_list, egg_id, egg_res, t_egg_data, added_mileage)

        local function close_cb()
            self:summonApiFinished()

            self:refresh()
        end
        ui:setCloseCB(close_cb)

        -- 이어서 뽑기 설정
        self:subsequentSummons(ui, t_egg_data)
    end

    local function fail_cb()
    end

    g_hatcheryData:request_summonPickup(is_bundle, is_sale, finish_cb, fail_cb)
end




-------------------------------------
-- function requestSummon
-------------------------------------
function UI_HatcherySummonTab:requestSummon(t_egg_data, old_ui, is_again)
    local egg_id = t_egg_data['egg_id']
    local is_bundle = t_egg_data['bundle']
	local is_sale = (t_egg_data['price_type'] == 'cash') and is_again
    local is_ad = t_egg_data['is_ad']

    local function ok_btn_cb()
        if (egg_id == 700001) then
            --self:click_eventSummonBtn(is_bundle, is_sale, t_egg_data, old_ui)
            self:click_pickupSummonBtn(is_bundle, is_ad, t_egg_data, old_ui)

        elseif (egg_id == 700002) then
            self:click_cashSummonBtn(is_bundle, is_sale, t_egg_data, old_ui)

        elseif (egg_id == 700003) then
            self:click_friendSummonBtn(is_bundle, is_ad, t_egg_data, old_ui)

        else
            error('egg_id ' .. egg_id)
        end
            
        -- @ GOOGLE ACHIEVEMENT
        local t_data = {['clear_key'] = 'smn'}
        GoogleHelper.updateAchievement(t_data)
    end

    -- 무료 대상 확인
    if t_egg_data['free_target'] then
        if g_hatcheryData:getSummonFreeInfo() then
            g_hatcheryData:setDirty()
            ok_btn_cb()
            return
        end
    end

    local cancel_btn_cb = nil

    local item_key = t_egg_data['price_type']
    local item_value = t_egg_data['price']

    -- 이어 뽑기 10% 할인
    if (is_sale) then
        item_value = item_value - (item_value * 0.1)
    end
    
    -- 이어 뽑기일 경우 의사를 묻지 않고 바로 시작
    if is_sale then
        if ConfirmPrice(item_key, item_value) then
            ok_btn_cb()
        else
            -- ConfirmPrice함수에서 false를 리턴했을 경우 안내 팝업이 뜬 상태
        end
	elseif (TutorialManager.getInstance():isDoing()) then
		ok_btn_cb()

    elseif (is_ad) then
		-- 광고 비활성화 시
		if (AdSDKSelector:isAdInactive()) then
			AdSDKSelector:makePopupAdInactive()
			return
		end

        -- 광고 프리로드 요청
        AdSDKSelector:adPreload(AD_TYPE['FSUMMON'])

        -- 탐험 광고 안내 팝업
        local msg = Str("동영상 광고를 보시면 무료 우정 소환이 가능합니다.") .. '\n' .. Str("광고를 보시겠습니까?")
        local submsg = Str("무료 우정 소환은 1일 1회 가능합니다.")
        MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)

    elseif (egg_id == 700001) then
        local normal_did, unique_did = g_hatcheryData:getSelectedPickup()
        local is_allowed = (normal_did and unique_did) or (not normal_did and not unique_did)
        local msg

        -- 둘다 설정되던지 아님 둘다 안설정 되던지
        if (is_allowed) then
            msg = Str('\'땅/물/불\' 속성과 \'빛/어둠\' 속성의 드래곤을 모두 선택해야 확률 UP 고급소환을 진행할 수 있습니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)

        else
            msg = Str('"{1}" 진행하시겠습니까?', t_egg_data['name'])
            UI_HacheryPickupBtnPopup(self, t_egg_data['name'], item_value, msg, ok_btn_cb, cancel_btn_cb)

        end
    else
        local msg = Str('"{1}" 진행하시겠습니까?', t_egg_data['name'])
        MakeSimplePopup_Confirm(item_key, item_value, msg, ok_btn_cb, cancel_btn_cb)
    end
end

-------------------------------------
-- function subsequentSummons
-- @brief 이어서 뽑기 설정
-------------------------------------
function UI_HatcherySummonTab:subsequentSummons(gacha_result_ui, t_egg_data)
    local vars = gacha_result_ui.vars

	-- 다시하기 버튼 등록
    vars['againBtn']:registerScriptTapHandler(function()
        self:requestSummon(t_egg_data, gacha_result_ui, true) -- is_again
    end)
end

-------------------------------------
-- function summonApiFinished
-- @brief
-------------------------------------
function UI_HatcherySummonTab:summonApiFinished()
    local function finish_cb()
        self:sceneFadeInAction()

        -- 갱신
        self.m_ownerUI:refresh()
    end

    local fail_cb = nil
    g_hatcheryData:update_hatcheryInfo(finish_cb, fail_cb)
end

-------------------------------------
-- function requestSelectPickup
-------------------------------------
function UI_HatcherySummonTab:requestSelectPickup(t_dragon_data)
    local did = t_dragon_data['did']

    if (isNullOrEmpty(did)) then return end

    g_hatcheryData:request_selectPickup(did, function() self:refresh() end)
end



--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------
-- class UI_HacheryInfoBtnPopup
-- @brief 
----------------------------------------------------------------------
UI_HacheryInfoBtnPopup = class(UI, {})
 
----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_HacheryInfoBtnPopup:init()
	self.m_uiName = 'UI_HacheryInfoBtnPopup'

    local vars = self:load('hatchery_summon_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HacheryInfoBtnPopup')
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------
-- class UI_HacheryPickupBtnPopup
-- @brief 
----------------------------------------------------------------------
UI_HacheryPickupBtnPopup = class(UI, {
    m_parent = 'UI_HatcherySummonTab',
})
 
----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_HacheryPickupBtnPopup:init(parent, title, item_value, msg, ok_btn_cb, cancel_btn_cb)
	self.m_uiName = 'UI_HacheryPickupBtnPopup'

    local vars = self:load('hatchery_summon_confirm_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HacheryPickupBtnPopup')

    
    vars['okBtn']:registerScriptTapHandler(function() 
        ok_btn_cb()
        self:close()
    end)

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)

    self.m_parent = parent

    vars['titleLabel']:setString(title)
    vars['selectLabel']:setString(msg)
    vars['priceLabel']:setString(comma_value(item_value))
    vars['unselectLabel']:setString(msg)

    local normal_did, unique_did = g_hatcheryData:getSelectedPickup()
    local has_empty_slot = not normal_did or not unique_did
    vars['unselectMenu']:setVisible(has_empty_slot)
    vars['selectMenu']:setVisible(not has_empty_slot)

    if (not has_empty_slot) then self:setChanceUpDragons() end
    
end


-------------------------------------
-- function setChanceUpDragons
-- @brief 확률업 드래곤 
-------------------------------------
function UI_HacheryPickupBtnPopup:setChanceUpDragons()
    local vars = self.vars

    local idx = 0
    local desc_idx = 0 -- dragonName1 :드래곤 1마리 일 때, dragonName2, dragonName3 : 드래곤 2마리 일 때

    -- normal_did 물불땅 / unique_did 빛어둠
    -- 바로 알아볼 수 있게 같은 로직 두번 돌림
    local normal_did, unique_did = g_hatcheryData:getSelectedPickup()
    local l_dragon = {}

    if (normal_did) then table.insert(l_dragon, {did = normal_did}) end
    if (unique_did) then table.insert(l_dragon, {did = unique_did}) end

    local pickup_dragon_map = self.m_parent:makeDragonInfoMap(l_dragon)

    for _, t_data in pairs(pickup_dragon_map) do
        local did = t_data['did']
        local attr = TableDragon:getDragonAttr(did)

        -- 빛어둠 3 / 땅물불 2
        idx = isExistValue(attr, 'light', 'dark') and 2 or 1
        desc_idx = idx

        -- 드래곤 이름
        local name = TableDragon:getChanceUpDragonName2(did)

        vars['dragonNameLabel'..desc_idx]:setString(name)
        vars['selectVisual'..desc_idx]:setVisible(true)
        
        -- 드래곤 카드
        do
            local t_dragon_data = {}
            t_dragon_data['did'] = did
            t_dragon_data['evolution'] = 1
            t_dragon_data['grade'] = 5
            t_dragon_data['skill_0'] = 1
            t_dragon_data['skill_1'] = 1
            t_dragon_data['skill_2'] = 0
            t_dragon_data['skill_3'] = 0

            -- 드래곤 클릭 시, 도감 팝업
            local func_tap = function()
                UI_BookDetailPopup.openWithFrame(did, nil, 1, 0.8, true)    -- param : did, grade, evolution scale, ispopup
            end

            local dragon_card = UI_DragonCard(StructDragonObject(t_dragon_data))
            dragon_card.root:setScale(0.66)
            dragon_card.vars['clickBtn']:registerScriptTapHandler(function() func_tap() end)
            vars['dragonCard'..desc_idx]:addChild(dragon_card.root)
        end
    end
end
