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

-------------------------------------
-- class UI_CapsuleBox
-------------------------------------
UI_CapsuleBox = class(PARENT,{
		m_capsuleBoxData = '',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_CapsuleBox:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_CapsuleBox'
    self.m_bVisible = true
    self.m_titleStr = Str('캡슐 신전')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBox:init()
	local vars = self:load('capsule_box.ui')
	UIManager:open(self, UIManager.SCENE)
	
	self.m_capsuleBoxData = g_capsuleBoxData:getCapsuleBoxInfo()

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_CapsuleBox')

	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBox:initUI()
	local vars = self.vars

	local capsulebox_data = self.m_capsuleBoxData

	for _, box_key in pairs(L_BOX) do
		-- 애니메이션 일단 정지..
		vars[box_key .. 'Visual']:setAnimationPause(true)

		-- price 및 가격 표시
		local struct_capsule = capsulebox_data[box_key]
		local l_price_list = struct_capsule:getPriceList()
		for i, t_price in pairs(l_price_list) do
			-- 가격 표시
			local price = t_price['value']
			vars[box_key .. 'PriceLabel' .. i]:setString(comma_value(price))

			-- 가격 아이콘
			local price_type = t_price['type']
			local price_icon = IconHelper:getPriceIcon(price_type)
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
			end
		end

		-- 남은 캡슐 비율
		local curr_per = struct_capsule_box:getCapsulePercentage()
		local text = string.format('%s : %s', Str('남은 캡슐'), curr_per)
		vars[box_key .. 'CurrentRateLabel']:setString(text)
	end

	-- 현재 보유한 캡슐 코인..
	local capsule_coin = g_userData:get('capsule_coin')
	vars['firstHaveLabel']:setString(comma_value(capsule_coin))
end

-------------------------------------
-- function click_rewardBtn
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
	local t_price = struct_capsule_box:getPrice(idx)
	
	-- 가격 정보 없을 경우
	if (not t_price) then
		ccdisplay('잘못된 요청, click_drawBtn')
		return
	end

	-- 부족 여부도 체크할까?
	local price = t_price['value']

	-- 뽑기 요청
	local price_type = t_price['type']
	local function finish_func(ret)
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
				UI_ObtainPopup(ret['items_list'])
			end
		end)
	end
	g_capsuleBoxData:request_capsuleBoxBuy(box_key, price_type, finish_func)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_CapsuleBox:click_exitBtn()
    self:close()
end


-------------------------------------
-- function click_exitBtn
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

	-- 가능 여부
	local state, color = struct_reward:getStateAndColor()
	vars['stateLabel']:setString(state)
	vars['stateLabel']:setTextColor(color)

	-- 획득 확률
	local rate = struct_reward['rate']
	vars['chanceLabel']:setString(string.format('%.3f%%', rate))

	return ui
end

--@CHECK
UI:checkCompileError(UI_CapsuleBox)
