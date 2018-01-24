local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_HatcherySummonTab
-------------------------------------
UI_HatcherySummonTab = class(PARENT,{
        m_eggPicker = '',
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
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_HatcherySummonTab:onEnterTab(first)
    self.m_ownerUI:showNpc() -- NPC 등장
    self.m_ownerUI:showMileage() -- 마일리지 메뉴

    if (first == true) then
        self:initUI()
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
        
        -- 버튼 UI 설정

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

        -- 버튼 콜백
        btn.vars['summonBtn']:registerScriptTapHandler(function()
            self:requestSummon(t_data)
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
        local ui = UI_GachaResult_Dragon(gacha_type, l_dragon_list, l_slime_list, egg_id, egg_res, t_egg_data)

        local function close_cb()
            self:summonApiFinished()
        end
        ui:setCloseCB(close_cb)

        -- 이어서 뽑기 설정
        self:subsequentSummons(ui, t_egg_data)

        -- 추가된 마일리지
        local added_mileage = ret['added_mileage'] or 0
		if (added_mileage > 0) then
			UIManager:toastNotificationGreen(Str('{1}마일리지가 적립되었습니다.', added_mileage))
		end
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
        local ui = UI_GachaResult_Dragon(gacha_type, l_dragon_list, l_slime_list, egg_id, egg_res, t_egg_data)

        local function close_cb()
            self:summonApiFinished()
        end
        ui:setCloseCB(close_cb)

        -- 이어서 뽑기 설정
        self:subsequentSummons(ui, t_egg_data)

        -- 추가된 마일리지
        local added_mileage = ret['added_mileage'] or 0
		if (added_mileage > 0) then
			UIManager:toastNotificationGreen(Str('{1}마일리지가 적립되었습니다.', added_mileage))
		end
    end

    local function fail_cb()
    end

    g_hatcheryData:request_summonCash(is_bundle, is_sale, finish_cb, fail_cb)
end

-------------------------------------
-- function click_friendSummonBtn
-- @brief 우정포인트 뽑기
-------------------------------------
function UI_HatcherySummonTab:click_friendSummonBtn(is_bundle, t_egg_data, old_ui)
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
        end
        ui:setCloseCB(close_cb)
    end

    local function fail_cb()
    end

    g_hatcheryData:request_summonFriendshipPoint(is_bundle, finish_cb, fail_cb)
end

-------------------------------------
-- function requestSummon
-------------------------------------
function UI_HatcherySummonTab:requestSummon(t_egg_data, old_ui, is_again)
    local egg_id = t_egg_data['egg_id']
    local is_bundle = t_egg_data['bundle']
	local is_sale = (t_egg_data['price_type'] == 'cash') and is_again

    local function ok_btn_cb()
        if (egg_id == 700001) then
            self:click_eventSummonBtn(is_bundle, is_sale, t_egg_data, old_ui)

        elseif (egg_id == 700002) then
            self:click_cashSummonBtn(is_bundle, is_sale, t_egg_data, old_ui)

        elseif (egg_id == 700003) then
            self:click_friendSummonBtn(is_bundle, t_egg_data, old_ui)

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