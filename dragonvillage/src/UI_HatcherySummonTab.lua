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

    self.m_orgDragonList = TablePickDragon:getDragonList(700304, g_dragonsData.m_mReleasedDragonsByDid)

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
        --self.vars['eventNoti2']:setVisible(true)
    else
        self.vars['eventNoti1']:setVisible(false)
        --self.vars['eventNoti2']:setVisible(false)
    end
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
                count_str = Str('10 + 1회')
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

    -- 광고 보기 버튼 체크
    vars['summonNode_fp_ad']:setVisible(g_advertisingData:isAllowToShow(AD_TYPE['FSUMMON']))
    vars['summonNode_fp_ad']:runAction(cca.buttonShakeAction(2, 2))

    self:setChanceUpDragons()

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
			self:refresh(data)
		end)
        return ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cell_size
    table_view_td.m_nItemPerCell = 6
	table_view_td:setCellUIClass(create_func)
	table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:setItemList(l_item_list)

    -- 정렬
    self.m_tableViewTD = table_view_td

	-- 전체 드래곤 리스트 출력
    self.m_tableViewTD:setItemList(self.m_orgDragonList)
    --self.m_sortManager:sortExecution(self.m_tableViewTD.m_itemList)
	--self:refresh(table.getRandom(self.m_orgDragonList))

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
    self.m_tableViewTD:setItemList(l_item_list)

    -- 정렬
    self.m_sortManager:sortExecution(self.m_tableViewTD.m_itemList)

	-- ui편의를 위해 조건 변경 시 첫번째 드래곤을 화면에 띄운다
	self:refresh(table.getRandom(l_item_list))
end

-------------------------------------
-- function setChanceUpDragons
-- @brief 확률업 드래곤 
-------------------------------------
function UI_HatcherySummonTab:setChanceUpDragons()
    local vars = self.vars
    local map_target_dragons = g_eventData:getChanceUpDragons()
    if (not map_target_dragons) then
        return
    end

    local total_cnt = #table.MapToList(map_target_dragons)
    local idx = 0
    local desc_idx = 0 -- dragonName1 :드래곤 1마리 일 때, dragonName2, dragonName3 : 드래곤 2마리 일 때

    if (total_cnt == 2) then
        vars['summonAttrMenu1']:setVisible(false)
        vars['summonAttrMenu2']:setVisible(true)
    else
        vars['summonAttrMenu1']:setVisible(true)
        vars['summonAttrMenu2']:setVisible(false)        
    end

    for k, t_data in pairs(map_target_dragons) do
        local did = t_data['did']
        idx = idx + 1
        desc_idx = idx
        if (total_cnt == 2) then
            desc_idx = desc_idx + 1
        end

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


        -- 드래곤 애니메이션
        local animator = AnimatorHelper:makeDragonAnimator_usingDid(did, 3)
        -- 한 마리일 때 1 사용
        local dragon_node = nil
        if (total_cnt == 1) then
            dragon_node = vars['dragonNode1']
        else
            -- 두 마리 일 때 2,3 사용
            if (vars['dragonNode' .. idx + 1]) then
                dragon_node = vars['dragonNode' .. idx + 1]
            end
        end

        if dragon_node then
            dragon_node:addChild(animator.m_node)
            animator.m_node:setPosition(t_data['x'], t_data['y'])
            animator.m_node:setScale(t_data['scale'])
        end
    end

    -- 확률업 남은 시간 표기
    local remain_time = g_hatcheryData:getChanceUpEndDate() or ''
    vars['timeLabel']:setString(Str(remain_time))
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
-- function requestSummon
-------------------------------------
function UI_HatcherySummonTab:requestSummon(t_egg_data, old_ui, is_again)
    local egg_id = t_egg_data['egg_id']
    local is_bundle = t_egg_data['bundle']
	local is_sale = (t_egg_data['price_type'] == 'cash') and is_again
    local is_ad = t_egg_data['is_ad']

    local function ok_btn_cb()
        if (egg_id == 700001) then
            self:click_eventSummonBtn(is_bundle, is_sale, t_egg_data, old_ui)

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