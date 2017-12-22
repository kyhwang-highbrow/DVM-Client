local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-- 서버/테이블과 UI 간 key 다름
local T_BOX = {
	['first'] = 'legend', 
	['second'] = 'hero',
}

local BOX_KEY_1 = 'first'
local BOX_KEY_2 = 'second'
local BOX_KEY_3 = 'third'
local L_BOX = {
	BOX_KEY_1,
	BOX_KEY_2
}
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
	ccdump(capsulebox_data)

	for _, box_key in pairs(T_BOX) do
		-- 애니메이션 일단 정지..
		vars[box_key .. 'Visual']:setAnimationPause(true)
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBox:initButton()
	local vars = self.vars

	vars['legendRewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn('first') end)
	vars['legendDrawBtn']:registerScriptTapHandler(function() self:click_drawBtn('first') end)

	vars['heroRewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn('second') end)
	vars['heroDrawBtn1']:registerScriptTapHandler(function() self:click_drawBtn('second') end)
	vars['heroDrawBtn2']:registerScriptTapHandler(function() self:click_drawBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBox:refresh()
	local vars = self.vars

	local capsulebox_data = self.m_capsuleBoxData

	-- 대표 보상 표시
	for server_box_key, ui_box_key in pairs(T_BOX) do
		local struct_capsule_box = capsulebox_data[server_box_key]
		local rank = 1
		local l_reward = struct_capsule_box:getRankRewardList(rank)
		
		-- 대표 보상 표시
		for i, struct_reward in ipairs(l_reward) do
			if (i <= 3) then
				local ui = self.makeRewardCell(ui_box_key, struct_reward)
				vars[ui_box_key .. 'ItemNode' .. i]:removeAllChildren(true)
				vars[ui_box_key .. 'ItemNode' .. i]:addChild(ui.root)
			end
		end
	end
end

-------------------------------------
-- function click_purchaseBtn
-------------------------------------
function UI_CapsuleBox:click_purchaseBtn()
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
	
	if (box_key == 'legend') then
		ui:load('capsule_box_item_02.ui')
	elseif (box_key == 'hero') then
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
	local state = struct_reward:getState()
	vars['stateLabel']:setString(state)
	vars['stateLabel']:setTextColor(cc.c4b(45, 255, 107, 255))
	-- cc.c4b(255, 70, 70, 255)

	-- 획득 확률
	local rate = struct_reward['rate']
	vars['chanceLabel']:setString(string.format('%.3f%%', rate))

	return ui
end

--@CHECK
UI:checkCompileError(UI_CapsuleBox)
