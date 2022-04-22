local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

local BOX_KEY_1 = 'first'
local BOX_KEY_2 = 'second'
local BOX_KEY_3 = 'third'
local L_BOX = {
	BOX_KEY_1,
	BOX_KEY_2
}
-- visual ani 명 serverKey 에 맵핑
local T_ANI = {
	[BOX_KEY_1] = 'special_idle',
	[BOX_KEY_2] = 'normal_idle'
}
local CURR_Z_ORDER = 10
local RENEW_INTERVAL = 10

-------------------------------------
-- class UI_CapsuleBox
-------------------------------------
UI_CapsuleBox = class(PARENT,{
		m_capsuleBoxData = '',
		m_isBusy = 'bool',
		m_preRefreshTime = 'time',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_CapsuleBox:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_CapsuleBox'
    self.m_bVisible = true
    self.m_titleStr = Str('캡슐 뽑기')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'capsule_coin'
end

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBox:init()
	local vars = self:load('capsule_box.ui')
	UIManager:open(self, UIManager.SCENE)
	
	self.m_capsuleBoxData = g_capsuleBoxData:getCapsuleBoxInfo()
	self.m_isBusy = false
	self.m_preRefreshTime = 0

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_CapsuleBox')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	self:initUI()
	self:initButton()
	self:refresh()

	self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBox:initUI()
	local vars = self.vars

	local capsulebox_data = self.m_capsuleBoxData

	for i, box_key in pairs(L_BOX) do
		local ani = vars[box_key .. 'Visual']

		-- 애니메이션 일단 정지..
		ani:setAnimationPause(true)
		cca.dropping(ani.m_node, 1000, i)

		-- price 및 가격 표시
		local struct_capsule = capsulebox_data[box_key]
		local l_price_list = struct_capsule:getPriceList()
		for i, t_price in pairs(l_price_list) do
			-- 가격 표시
			local price = t_price['value']
            if (vars[box_key .. 'PriceLabel' .. i]) then
			    vars[box_key .. 'PriceLabel' .. i]:setString(comma_value(price))
            end

			-- 가격 아이콘
			local price_type = t_price['type']
			local price_icon

			-- 서버에서 item_type에 capsule_coin10을 주어서 숫자 제거
            local price_number = string.match(price_type, '%d+')
            if (price_number) then
                price_type = string.gsub(price_type, price_number, '')
			end
		    price_icon = IconHelper:getPriceIcon(price_type)

            if (vars[box_key .. 'PriceNode' .. i]) then
			    vars[box_key .. 'PriceNode' .. i]:removeAllChildren(true)
			    vars[box_key .. 'PriceNode' .. i]:addChild(price_icon)
            end
		end
	end

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBox:initButton()
	local vars = self.vars
	
	-- 보상 내역 확인
	vars['firstRewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn(BOX_KEY_1) end)
	vars['secondRewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn(BOX_KEY_2) end)
	
	-- 뽑기 버튼
	vars['firstDrawBtn1']:registerScriptTapHandler(function() self:click_drawBtn(BOX_KEY_1, 1) end)
    vars['firstDrawBtn2']:registerScriptTapHandler(function() self:click_drawBtn(BOX_KEY_1, 1, 10) end)
	vars['secondDrawBtn1']:registerScriptTapHandler(function() self:click_drawBtn(BOX_KEY_2, 1) end)
	vars['secondDrawBtn2']:registerScriptTapHandler(function() self:click_drawBtn(BOX_KEY_2, 2) end)
    vars['secondDrawBtn3']:registerScriptTapHandler(function() self:click_drawBtn(BOX_KEY_2, 1, 10) end)
    vars['secondDrawBtn4']:registerScriptTapHandler(function() self:click_drawBtn(BOX_KEY_2, 2, 10) end)

	-- 새로고침
	vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)

    -- 캡슐 코인 구매
	vars['firstCoinBtn']:registerScriptTapHandler(function() self:click_firstCoinBtn() end)

    -- 캡슐 코인 (5+1) 구매
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)

    -- 캡슐 뽑기 일정
    vars['rotationBtn']:registerScriptTapHandler(function() self:click_rotaionBtn() end)
    
    -- refill 정보
    vars['refillInfoBtn']:registerScriptTapHandler(function() self:click_refillInfoBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBox:refresh()
	local vars = self.vars

	local capsulebox_data = self.m_capsuleBoxData

	for _, box_key in pairs(L_BOX) do
		local struct_capsule_box = capsulebox_data[box_key]
		local rank = 1
		local l_reward = struct_capsule_box:getRankRewardList(rank)

		-- 대표 보상 표시
		for i, struct_reward in ipairs(l_reward) do
			if (i <= 3) then
				local ui = self.makeRewardCell(box_key, struct_reward, i)
				vars[box_key .. 'ItemNode' .. i]:removeAllChildren(true)
				vars[box_key .. 'ItemNode' .. i]:addChild(ui.root)
				cca.fruitReact(ui.root, i)
			end
		end

		-- 남은 캡슐 비율
		local curr_per = struct_capsule_box:getTopRewardProb()
		vars[box_key .. 'CurrentRateLabel']:setString(curr_per)
	end

    -- 현재 보유한 캡슐 코인..
	local capsule_coin = g_userData:get('capsule_coin')
	vars['firstHaveLabel']:setString(comma_value(capsule_coin))

	-- 캡슐 코인 구매 버튼 온오프
	self:refresh_firstDrawBtn()

    g_capsuleBoxData:setTodaySchedule()
    local legend_title = capsulebox_data['first']:getCapsuleTitle()
    vars['rotationTitleLabel2']:setString(legend_title)
    
    -- 캡슐 코인 5+1 패키지 갱신
    self:refresh_dailyCapsulePackage()

    self:setCapsuleBoxNoti()
end

-------------------------------------
-- function setCapsuleBoxNoti
-- @brief 특정날짜에 노티를 띄워줘야 하는 경우 (ex) 글로벌 2주년 기념 절전알 출현 기념 노티
-------------------------------------
function UI_CapsuleBox:setCapsuleBoxNoti()
    local vars = self.vars

    if (StructCapsuleBoxSchedule.isNoti_globalAnniversary()) then
        vars['1stEventMenu']:setVisible(true)

        local struct_capsule_box = self.m_capsuleBoxData[BOX_KEY_1]
        local best_reward_data = struct_capsule_box:getContents()[1]
        local item_id = best_reward_data['item_id']

        local is_dragon = TableItem():isDragonByItemId(item_id)
        local item_name = TableItem:getItemName(item_id)

        if (is_dragon) then
            vars['dragonNode']:setVisible(true)
            vars['eggVisual']:setVisible(false)

            local item_icon = IconHelper:getItemIcon(item_id)
            vars['dragonNode']:addChild(item_icon)

        else
            vars['dragonNode']:setVisible(false)
            vars['eggVisual']:setVisible(true)

        end

        vars['itemLabel']:setString(Str('전설 뽑기에 {1} 출현!', item_name))

    else
        vars['1stEventMenu']:setVisible(false)
    end

    -- capsule ui 에서 refill 정보 표시 여부
    local is_refill, is_refill_completed = g_capsuleBoxData:isRefillAndCompleted(--[[is_lobby: ]]false)
    vars['refillMenu']:setVisible(is_refill)
    if (is_refill) then
        vars['refillReservedSprite']:setVisible(not is_refill_completed)
        vars['refillCompletedSprite']:setVisible(is_refill_completed)
    end
end

-------------------------------------
-- function refresh_firstDrawBtn
-- @brief 전설 뽑기 버튼 상태 갱신
-------------------------------------
function UI_CapsuleBox:refresh_firstDrawBtn()
    local vars = self.vars

    -- 캡슐 코인 구매 버튼 온오프
    local capsule_coin = g_userData:get('capsule_coin')
	vars['firstCoinBtn']:setVisible(capsule_coin == 0)
	vars['firstDrawBtn1']:setVisible(capsule_coin ~= 0)

    -- 절대적인 전설의 알 이벤트 시에는 10뽑기 제공 x
    local is_korea_server = g_localData:isKoreaServer() -- 한국서버 여부(dev, qa 서버도 포함될 수 있음)
--    local is_noti_global_anniversary = StructCapsuleBoxSchedule.isNoti_globalAnniversary() -- 절대적인 전설의 알 이벤트 여부
    local is_refill, _ = g_capsuleBoxData:isRefillAndCompleted()
    if (is_refill) then
        vars['firstDrawBtn2']:setVisible(false)
    else
        vars['firstDrawBtn2']:setVisible(capsule_coin ~= 0)
    end
end

-------------------------------------
-- function refresh_dailyCapsulePackage
-- @brief 캡슐코인 5+1 상품은 패키지 등록되지 않은 상태서 UI_CapsuleBox에서만 구입 가능
-------------------------------------
function UI_CapsuleBox:refresh_dailyCapsulePackage()
    local vars = self.vars
    local struct_product = g_shopData:getDailyCapsulePackage()
    if (struct_product and struct_product:isItBuyable()) then
        vars['buyBtn']:setVisible(true)
        vars['buyBtn']:setAutoShake(true)

        local str_term = struct_product:getMaxBuyTermStr()
        vars['buyLabel']:setString(str_term)

        local is_tag_attached = ServerData_IAP.getInstance():setGooglePlayPromotionSaleTag(self, struct_product, nil)
        local is_sale_price_written = false
        if (is_tag_attached == true) then
            is_sale_price_written = ServerData_IAP.getInstance():setGooglePlayPromotionPrice(self, struct_product, nil)
        end

        if (is_sale_price_written == false) then
            vars['priceLabel']:setString(struct_product:getPriceStr())
        end
    else
        vars['buyBtn']:setVisible(false)
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_CapsuleBox:update(dt)
	-- 남은 시간
    if (g_capsuleBoxData:isNoticeRefillTimeNotRemainTime()) then
        self.vars['remainTimeLabel']:setString(Str('12시 충전 예정'))
    else
	    local remain_text = g_capsuleBoxData:getRemainTimeText()
	    self.vars['remainTimeLabel']:setString(Str('{1} 남음', remain_text))
    end

	-- 중복 호출 방지 처리
	if (self.m_isBusy) then
		return
	end

	-- 종료시간과 비교하여 다음날 정보를 가져온다.
	if (g_capsuleBoxData:checkReopen()) then
		-- update 중에 중복 호출 되지 않도록 사용
		self.m_isBusy = true

		local function cb_func()
			local msg = Str('캡슐 상품을 갱신합니다.')
			UIManager:toastNotificationGreen(msg)
			g_capsuleBoxData:request_capsuleBoxStatus(function()
				self:refresh()
				self.m_isBusy = false
			end)
		end
		g_capsuleBoxData:request_capsuleBoxInfo(cb_func)
		return	
	end

    -- 캡슐 코인 구매 버튼 온오프
    self:refresh_firstDrawBtn()
end

-------------------------------------
-- function click_rewardBtn
-- @brief 해당 박스의 보상 리스트 UI
-------------------------------------
function UI_CapsuleBox:click_rewardBtn(box_key)
	local struct_capsule_box = self.m_capsuleBoxData[box_key]
	UI_CapsuleBoxRewardList(struct_capsule_box)
end

-------------------------------------
-- function executeDraw
-- @brief 뽑기 실행
-------------------------------------
function UI_CapsuleBox:executeDraw(box_key, idx, count, price_type)
    -- 뽑기 중
	self.m_isBusy = true

	-- 뽑기 요청
	local function finish_func(ret)
		-- 통신 중에 UI가 닫혔을 경우
	    if (self.closed) then
			return
		end

		-- 블럭
        UIManager:blockBackKey(true)
		local block_ui = UI_BlockPopup()

		-- 연출 시작
		local ani = self.vars[box_key .. 'Visual']
		
		CURR_Z_ORDER = CURR_Z_ORDER + 1
		ani:setLocalZOrder(CURR_Z_ORDER)
        
        -- 10연뽑이면 애니 바꾸어 연출
        if (count == 10) then
            if (box_key == BOX_KEY_1) then
                ani:changeAni('special_idle_10', false)
            else
                ani:changeAni('normal_idle_10', false)
            end
        end
	    ani:setAnimationPause(false)

		-- 후속 연출
		ani:addAniHandler(function()
			ani:changeAni(T_ANI[box_key], false)
			ani:setAnimationPause(true)
			
			-- 보상 수령 확인 팝업
			if (ret['items_list']) then
                -- count 값이 없으면 기본 결과 팝업(1뽑기 용)
                if (not count) then
				    local text = Str('상품이 우편함으로 전송되었습니다.')
				    UI_ObtainPopup(ret['items_list'], text)
                else
                -- count 값이 있을 경우 보상 가로로 나열해 주는 팝업(10뽑기 용)
                    UI_CapsuleBoxResultPopup(ret['items_list'])
                end
			end

			self:refresh()

			-- 블럭 해제
			UIManager:blockBackKey(false)
			block_ui:close()

			self.m_isBusy = false
		end)
	end
	local function fail_func()
		-- 일반적인 갱신
		g_capsuleBoxData:request_capsuleBoxStatus(function()
			self:refresh()
			self.m_isBusy = false
		end)
	end

	g_capsuleBoxData:request_capsuleBoxBuy(box_key, price_type, finish_func, fail_func, count)
end
-------------------------------------
-- function click_drawBtn
-- @brief 뽑기
-------------------------------------
function UI_CapsuleBox:click_drawBtn(box_key, idx, count)
	if (self.m_isBusy) then
		return
	end

	local struct_capsule_box = self.m_capsuleBoxData[box_key]
	if (struct_capsule_box:isDone()) then
		local msg = Str('상품이 모두 소진되었습니다.')
		UIManager:toastNotificationGreen(msg)
		return
	end

    -- 10연뽑일 때 인덱스가 제각각이라 하드코딩 ex) 전설 10연뽑 보상 정보는 인덱스 2, 영웅 10연뽑 보상 정보는 인덱스 3,4
	local t_price = struct_capsule_box:getPrice(idx)
    if (count == 10)  then
        if (box_key == BOX_KEY_1) then
            t_price = struct_capsule_box:getPrice(2)
        else
            t_price = struct_capsule_box:getPrice(idx+2)
        end
        t_price['type'] = string.gsub(t_price['type'], '10', '')
    end

	-- 가격 정보 없을 경우
	if (not t_price) then
		return
	end

	-- 가격 변수
	local price_type = t_price['type']
	local price = tonumber(t_price['value'])

	-- 가격 미리 체크
	if (not ConfirmPrice(price_type, price)) then
		return
	end

    local execute_draw = function()
        self:executeDraw(box_key, idx, count, price_type)    
    end
    
    -- 10회 뽑기면 구매 의사 한 번 더 물어보는 팝업 출력
    if (count == 10) then
        local msg = ''
        if (box_key == BOX_KEY_1) then
            msg = string.format('%s %s %s', Str('전설 뽑기'), Str('{1}회', 10), Str('진행하시겠습니까?'))
        else
            msg = string.format('%s %s %s', Str('영웅 뽑기'), Str('{1}회', 10), Str('진행하시겠습니까?'))
        end
        UI_ConfirmPopup(price_type, price, msg, execute_draw, nil)  
	else
        execute_draw()
    end
end

-------------------------------------
-- function click_refreshBtn
-------------------------------------
function UI_CapsuleBox:click_refreshBtn()
	-- 갱신 가능 시간인지 체크한다
	local curr_time = Timer:getServerTime()
	if (curr_time - self.m_preRefreshTime > RENEW_INTERVAL) then
		self.m_preRefreshTime = curr_time

		-- 일반적인 갱신
		g_capsuleBoxData:request_capsuleBoxStatus(function()
			self:refresh()
		end)
	
	-- 시간이 되지 않았다면 몇초 남았는지 토스트 메세지를 띄운다
	else
		local ramain_time = math_ceil(RENEW_INTERVAL - (curr_time - self.m_preRefreshTime) + 1)
		UIManager:toastNotificationRed(Str('{1}초 후에 갱신 가능합니다.', ramain_time))

	end
end

-------------------------------------
-- function click_firstCoinBtn
-------------------------------------
function UI_CapsuleBox:click_firstCoinBtn()
	local package_name = 'package_capsule_coin'
	g_fullPopupManager:showFullPopup(package_name)
end

-------------------------------------
-- function click_buyBtn
-- @brief 캡슐코인 5+1 구매
-------------------------------------
function UI_CapsuleBox:click_buyBtn()
	local struct_product = g_shopData:getDailyCapsulePackage()
	if (struct_product) then
        local refresh_cb
        local buy_cb

        -- 캡슐 코인 갱신
        refresh_cb = function()
            self:refresh()
        end

        -- 캡슐 코인 우편함 바로 보여줌
        buy_cb = function()
            UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.GOODS, refresh_cb)
        end

        struct_product:buy(buy_cb)
    end
end

-------------------------------------
-- function click_rotaionBtn
-------------------------------------
function UI_CapsuleBox:click_rotaionBtn()
    UI_CapsuleBoxSchedule()
end

-------------------------------------
-- function click_refillInfoBtn
-------------------------------------
function UI_CapsuleBox:click_refillInfoBtn()
    local ui = UI()
    ui:load('capsule_box_chage_info.ui')
    ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)
    UIManager:open(ui, UIManager.POPUP)

    -- backkey 지정
	g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'temp')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_CapsuleBox:click_exitBtn()
    -- 연출 중이라면 UI가 닫히지 않도록 한다
	if (self.m_isBusy) then
		return
	end

    self:close()

end






-------------------------------------
-- function makeRewardCell
-------------------------------------
function UI_CapsuleBox.makeRewardCell(box_key, struct_reward, idx, is_package_item)
	local ui = UI()
	local ui_res

	if (box_key == BOX_KEY_1) then
		ui_res = 'capsule_box_item_02.ui'
	elseif (box_key == BOX_KEY_2) then
		ui_res = 'capsule_box_item_01.ui'
	else
		error('box key를 확인! : '.. box_key)
	end

    if (is_package_item) then
        ui_res = 'package_capsule_coin_item.ui'
    end

    ui:load(ui_res)

	local vars = ui.vars
	local item_id = struct_reward['item_id']
	local item_cnt = struct_reward['item_cnt']

	-- 보상 이름
	local name = UIHelper:makeItemNamePlainByParam(item_id, item_cnt)
	vars['rewardLabel']:setString(name)

	-- 남은 개수
	local count = struct_reward:getCount()
    if is_package_item then
        vars['chanceLabel']:setString(Str('{@apricot}남은 수량 {@blue_green}{1}개',count))
    else
        -- 1등급 개별 상품 30개로 고정
        local max_count = struct_reward['total']
        vars['chanceLabel']:setString(string.format('%d/%d', count, max_count))
        vars['chanceGg']:setPercentage(0)
        vars['chanceGg']:runAction(cc.ProgressTo:create(0.5, count/max_count * 100))
    end

    -- 아이템 카드
	local item_card = UI_ItemCard(item_id, item_cnt)
	vars['rewardNode']:addChild(item_card.root)
    
    -- 뱃지 생성
    local reward_name = box_key .. '_' .. idx
    local today_schedule_info = g_capsuleBoxData:getTodaySchedule()
    local badge_ui = g_capsuleBoxData:makeBadge(today_schedule_info, reward_name)
    if (badge_ui) then
        item_card.root:addChild(badge_ui.root)
    end
    -- item_id로 드래곤 판단
    local table_item = TableItem()
    local is_dragon = table_item:isDragonByItemId(item_id)    
    local func_tap_dragon_card

    -- 드래곤이면 도감버젼으로 Info팝업 띄우는 함수 등록
    if (is_dragon) then
        item_card.vars['clickBtn']:registerScriptTapHandler(function() func_tap_dragon_card() end)
    end

    local did = table_item:getDidByItemId(item_id)
    -- 도감 팝업 출력
    func_tap_dragon_card = function()
        UI_BookDetailPopup.openWithFrame(did, nil, 1, 0.8, true)    -- param : did, grade, evolution scale, ispopup
    end
	return ui
end

-------------------------------------
-- function setCapsulePackageReward
-------------------------------------
function UI_CapsuleBox.setCapsulePackageReward(target_ui)
    if (not target_ui) then
        return
    end

    local vars = target_ui.vars
    local box_key = BOX_KEY_1
    local capsulebox_data = g_capsuleBoxData:getCapsuleBoxInfo()
    if (not capsulebox_data) then
        return
    end

    local struct_capsule_box = capsulebox_data[box_key]
    local rank = 1
    local l_reward = struct_capsule_box:getRankRewardList(rank) or {}

    -- 캡슐 타이틀
    g_capsuleBoxData:setTodaySchedule()
    local legend_title = capsulebox_data[box_key]:getCapsuleTitle() or ''
    vars['rotationLabel']:setVisible(true)
    vars['rotationLabel']:setString(legend_title)
    if (not legend_title) or (legend_title  == '') then
        vars['rotationSprite']:setVisible(false)
    end

    -- 대표 보상 표시
    for i, struct_reward in ipairs(l_reward) do
    	if (i <= 3) then
    		local ui = UI_CapsuleBox.makeRewardCell(box_key, struct_reward, i, true) -- box_key, struct_reward, idx, is_package_item
    		vars['itemNode' .. i]:removeAllChildren(true)
    		vars['itemNode' .. i]:addChild(ui.root)
    	end
    end

    vars['rewardNode']:setVisible(true)

    -- 커지면서 나타나는 액션
    vars['rewardNode']:setScale(0)
    local scale_action = cc.ScaleTo:create(0.2, 1, 1)
    vars['rewardNode']:runAction(scale_action)
end

--@CHECK
UI:checkCompileError(UI_CapsuleBox)
