local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

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
end

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBox:init()
	local vars = self:load('capsule_box_schedule_list.ui')
	UIManager:open(self, UIManager.SCENE)
	
	self.m_capsuleBoxData = g_capsuleBoxData:getCapsuleBoxInfo()
	self.m_isBusy = false
	self.m_preRefreshTime = 0

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_CapsuleBox')

	self:initUI()
	self:initButton()
	self:refresh()
    self:initTab()
	self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBox:initUI()
	local vars = self.vars
end

-------------------------------------
-- function initTabContents
-- @brief 탭 내용물 초기화 (캡슐 애니메이션, 캡슐 아이템 정보,액션 등등)
-------------------------------------
function UI_CapsuleBox:initTabContents(i, box_key)
	local vars = self.vars

	local capsulebox_data = self.m_capsuleBoxData

	local ani = vars[box_key .. 'Visual']

	-- 애니메이션 일단 정지..
	ani:changeAni(T_ANI[box_key], false)
	ani:setAnimationPause(true)
	cca.dropping(ani.m_node, 1000, i)

	-- price 및 가격 표시
	local struct_capsule = capsulebox_data[box_key]
	local l_price_list = struct_capsule:getPriceList()
	for i, t_price in pairs(l_price_list) do
		-- 가격 표시
		local price = t_price['value']
		vars[box_key .. 'PriceLabel' .. i]:setString(comma_value(price))

		-- 가격 아이콘
		local price_type = t_price['type']
		local price_icon
		if (box_key == 'first') then
			price_icon = IconHelper:getPriceBigIcon(price_type)
		else
			price_icon = IconHelper:getPriceIcon(price_type)
		end
		vars[box_key .. 'PriceNode' .. i]:removeAllChildren(true)
		vars[box_key .. 'PriceNode' .. i]:addChild(price_icon)
	end

    local struct_capsule_box = capsulebox_data[box_key]
	local rank = 1
	local l_reward = struct_capsule_box:getRankRewardList(rank)

	-- 대표 보상 표시
	for i, struct_reward in ipairs(l_reward) do
		if (i <= 3) then
			local ui = self.makeRewardCell(box_key, struct_reward)
			vars[box_key .. 'ItemNode' .. i]:removeAllChildren(true)
			vars[box_key .. 'ItemNode' .. i]:addChild(ui.root)
			
			cca.fruitReact(ui.root, i)
		end
	end

	-- 남은 캡슐 비율
	local curr_per = struct_capsule_box:getTopRewardProb()
	vars[box_key .. 'CurrentRateLabel']:setString(curr_per)

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
	vars['secondDrawBtn1']:registerScriptTapHandler(function() self:click_drawBtn(BOX_KEY_2, 1) end)
	vars['secondDrawBtn2']:registerScriptTapHandler(function() self:click_drawBtn(BOX_KEY_2, 2) end)

	-- 새로고침
	vars['heroRefreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
    vars['legendRefreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)

	-- 캡슐 코인 구매
	vars['firstCoinBtn']:registerScriptTapHandler(function() self:click_firstCoinBtn() end)

    -- 캡슐 코인 (5+1) 구매
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_CapsuleBox:initTab()
    local vars = self.vars

    self:addTabAuto('legend_Capsule_', vars, vars['legend_Capsule_TabMenu'])
    self:addTabAuto('hero_Capsule_', vars, vars['hero_Capsule_TabMenu'])
    self:addTabAuto('capsule_Schedule_', vars, vars['capsule_Schedule_TabMenu'])
    self:setTab('legend_Capsule_', vars)

end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_CapsuleBox:onChangeTab(tab, first)
    local vars = self.vars

	-- 최초 생성만 실행
	if first then
        if (tab == 'legend_Capsule_') then
            self:initTabContents(1, BOX_KEY_1)
        elseif (tab == 'hero_Capsule_') then
            self:initTabContents(2, BOX_KEY_2)
        else
            local list = TABLE:get('table_capsule_box_schedule')
            -- 테이블 뷰 인스턴스 생성
            local table_view = UIC_TableView(vars['capsule_Schedule_TabMenu'])
            table_view:setCellUIClass(UI_CapsuleScheduleListItem, nil)
            table_view.m_defaultCellSize = cc.size(900, 190)
            table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
            table.MapToList(list)
            table_view:setItemList(list)

            -- 캡슐 판매일 지난 것부터 출력되도록 정렬
            local function sort_func(a, b)
                local a_data = a['data']
                local b_data = b['data']

                local a_time = a_data['day']
                local b_time = b_data['day']

                return a_time < b_time
            end
            table.sort(table_view.m_itemList, sort_func)
        end
	end
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
				local ui = self.makeRewardCell(box_key, struct_reward)
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
	vars['firstCoinBtn']:setVisible(capsule_coin == 0)
	vars['firstDrawBtn1']:setVisible(capsule_coin ~= 0)

    -- 캡슐 코인 5+1 패키지 갱신
    self:refresh_dailyCapsulePackage()

    --[[
    -- 1주년 스페셜 절대적인전설의 알 출현 이벤트 (9/1~9/2 양일간)
    local day = g_capsuleBoxData:getScheduleDay()
    if (day == 20180901) or (day == 20180902) then
        vars['1stEventMenu']:setVisible(true)
    else
        vars['1stEventMenu']:setVisible(false)
    end
    --]]
end

-------------------------------------
-- function refresh_dailyCapsulePackage
-- @brief 캡슐코인 5+1 상품은 패키지 등록되지 않은 상태서 UI_CapsuleBox에서만 구입 가능
-------------------------------------
function UI_CapsuleBox:refresh_dailyCapsulePackage()
    local vars = self.vars
    local struct_product = g_shopDataNew:getDailyCapsulePackage()
    if (struct_product and struct_product:isItBuyable()) then
        vars['buyBtn']:setVisible(true)
        vars['buyBtn']:setAutoShake(true)

        local str_term = struct_product:getMaxBuyTermStr()
        vars['buyLabel']:setString(str_term)

        local str_price = struct_product:getPriceStr()
        vars['priceLabel']:setString(str_price)
    else
        vars['buyBtn']:setVisible(false)
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_CapsuleBox:update(dt)
    local vars = self.vars
	-- 남은 시간
	local remain_text = g_capsuleBoxData:getRemainTimeText()
	vars['legendRemainTimeLabel']:setString(Str('{1} 남음', remain_text))
    vars['heroRemainTimeLabel']:setString(Str('{1} 남음', remain_text))

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
-- function click_drawBtn
-- @brief 뽑기
-------------------------------------
function UI_CapsuleBox:click_drawBtn(box_key, idx)
	if (self.m_isBusy) then
		return
	end

	local struct_capsule_box = self.m_capsuleBoxData[box_key]
	if (struct_capsule_box:isDone()) then
		local msg = Str('상품이 모두 소진되었습니다.')
		UIManager:toastNotificationGreen(msg)
		return
	end

	local t_price = struct_capsule_box:getPrice(idx)
	
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

		ani:setAnimationPause(false)

		-- 후속 연출
		ani:addAniHandler(function()
			ani:changeAni(T_ANI[box_key], false)
			ani:setAnimationPause(true)
			
			-- 보상 수령 확인 팝업
			if (ret['items_list']) then
				local text = Str('상품이 우편함으로 전송되었습니다.')
				UI_ObtainPopup(ret['items_list'], text)
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
	g_capsuleBoxData:request_capsuleBoxBuy(box_key, price_type, finish_func, fail_func)
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
	local struct_product = g_shopDataNew:getDailyCapsulePackage()
	if (struct_product) then
        local refresh_cb
        local buy_cb

        -- 캡슐 코인 갱신
        refresh_cb = function()
            self:refresh()
        end

        -- 캡슐 코인 우편함 바로 보여줌
        buy_cb = function()
            UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.CAPSULE_COIN, refresh_cb)
        end

        struct_product:buy(buy_cb)
    end
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
function UI_CapsuleBox.makeRewardCell(box_key, struct_reward)
	local ui = UI()
	
	if (box_key == BOX_KEY_1) then
		ui:load('capsule_box_item_02.ui')
	elseif (box_key == BOX_KEY_2) then
		ui:load('capsule_box_item_01.ui')
	else
		error('box key를 확인! : '.. box_key)
	end

	local vars = ui.vars

	local item_id = struct_reward['item_id']
	local item_cnt = struct_reward['item_cnt']

	local item_card = UI_ItemCard(item_id, item_cnt)
	vars['rewardNode']:addChild(item_card.root)

	-- 보상 이름
	local name = UIHelper:makeItemNamePlainByParam(item_id, item_cnt)
	vars['rewardLabel']:setString(name)

	-- 획득 확률
	local count = struct_reward:getCount()
	vars['chanceLabel']:setString(Str('{@apricot}남은 수량 {@blue_green}{1}개',count))

	return ui
end

--@CHECK
UI:checkCompileError(UI_CapsuleBox)
