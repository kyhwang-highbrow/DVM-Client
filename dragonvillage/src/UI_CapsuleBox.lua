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
		m_isDirecting = 'bool',
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
	local vars = self:load('capsule_box.ui')
	UIManager:open(self, UIManager.SCENE)
	
	self.m_capsuleBoxData = g_capsuleBoxData:getCapsuleBoxInfo()
	self.m_isDirecting = false
	self.m_preRefreshTime = 0

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_CapsuleBox')

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
	vars['secondDrawBtn1']:registerScriptTapHandler(function() self:click_drawBtn(BOX_KEY_2, 1) end)
	vars['secondDrawBtn2']:registerScriptTapHandler(function() self:click_drawBtn(BOX_KEY_2, 2) end)

	-- 새로고침
	vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)

	-- 캡슐 코인 구매
	vars['firstCoinBtn']:registerScriptTapHandler(function() self:click_firstCoinBtn() end)
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
end

-------------------------------------
-- function update
-------------------------------------
function UI_CapsuleBox:update(dt)
	-- 남은 시간
	local remain_text = g_capsuleBoxData:getRemainTimeText()
	self.vars['remainTimeLabel']:setString(Str('{1} 남음', remain_text))

	-- 연출 중에는 체크하지 않는다
	if (self.m_isDirecting) then
		return
	end

	-- 종료시간과 비교하여 다음날 정보를 가져온다.
	if (g_capsuleBoxData:checkReopen()) then
		self.m_isDirecting = true

		local function cb_func()
			local msg = Str('캡슐 상품을 갱신합니다.')
			UIManager:toastNotificationGreen(msg)
			self:close()
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
	local price = t_price['value']

	-- 캡슐 코인이 없다면 패키지를 띄워준다
	if (price_type == 'capsule_coin') then
		if (g_userData:get('capsule_coin') == 0) then
			
			ccdisplay('11')
		end
	end

	-- 뽑기 요청
	local function finish_func(ret)
	    
		-- 블럭
        UIManager:blockBackKey(true)
		local block_ui = UI_BlockPopup()

		self.m_isDirecting = true

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

			self.m_isDirecting = false
		end)
	end

	g_capsuleBoxData:request_capsuleBoxBuy(box_key, price_type, finish_func)
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
-- function click_exitBtn
-------------------------------------
function UI_CapsuleBox:click_exitBtn()
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
