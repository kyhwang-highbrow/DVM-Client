local PARENT = UI_ArenaResult

-------------------------------------
-- class UI_ChallengeModeResult
-------------------------------------
UI_ChallengeModeResult = class(PARENT, {
		m_currStage = 'number',
		m_playReward = 'table',
		m_winReward = 'table',
		m_isOpenNextStage = 'boolean',
     })

local ACTION_MOVE_Y = 700

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeModeResult:init(is_win, t_data, stage)
	self.m_currStage = stage

	-- 승리 보상, 도전 보상 확인
	local items_list = t_data['added_items']['items_list']
	if (items_list) then
		for i, t_item in ipairs(items_list) do
			if (t_item['item_id'] == ITEM_ID_GOLD) then
				if (t_item['count'] == 20000) then
					self.m_playReward = t_item
				elseif (t_item['count'] == 80000) then
					self.m_winReward = t_item
				end
			end
		end
	end

	-- 다음 스테이지 열림 체크
	self.m_isOpenNextStage = false
	if (not g_challengeMode:isOpenStage_challengeMode(stage + 1)) then
		if (is_win) then
			self.m_isOpenNextStage = true
		elseif (g_challengeMode:getChallengeModeStagePlayCnt(stage) >= 2) then
			self.m_isOpenNextStage = true
		end
	end
end

-------------------------------------
-- function initUI
-- @override
-------------------------------------
function UI_ChallengeModeResult:initUI()
    PARENT.initUI(self)

	local vars = self.vars
	vars['colosseumNode']:setVisible(false)
	vars['resultBgSprite']:setVisible(false)
end

-------------------------------------
-- function initButton
-- @override
-------------------------------------
function UI_ChallengeModeResult:initButton()
    PARENT.initButton(self)
end

-------------------------------------
-- function setWorkList
-- @override
-------------------------------------
function UI_ChallengeModeResult:setWorkList()
    self.m_workIdx = 0
    self.m_lWorkList = {}
    table.insert(self.m_lWorkList, 'direction_start')
    table.insert(self.m_lWorkList, 'direction_end')
	table.insert(self.m_lWorkList, 'direction_playReward')
	table.insert(self.m_lWorkList, 'direction_winReward')
	table.insert(self.m_lWorkList, 'direction_nextStage')
end

-------------------------------------
-- function direction_end
-- @override
-- @brief 종료 연출
-------------------------------------
function UI_ChallengeModeResult:direction_end()
    local vars = self.vars
    local resultMenu = vars['resultMenu']
    resultMenu:setVisible(true)

    -- 연출 준비
	vars['resultVisual']:setPositionY(100)
	vars['okBtn']:setPositionY(-100)
	vars['statsBtn']:setPositionY(-100)
	vars['homeBtn']:setPositionY(-100)
    vars['eventNode1']:setVisible(false)
    vars['eventNode2']:setVisible(false)

    local show_act = cc.EaseExponentialOut:create(cc.MoveBy:create(0.3, cc.p(0, ACTION_MOVE_Y)))
	resultMenu:runAction(show_act)

    self:doNextWorkWithDelayTime(0.5)
end

-------------------------------------
-- function direction_playReward
-------------------------------------
function UI_ChallengeModeResult:direction_playReward()
	local t_item = self.m_playReward
	if (not t_item) then
		self:doNextWork()
		return
	end

	self:makeRewardPopup(t_item, Str('도전 보상 획득!'))
end

-------------------------------------
-- function direction_winReward
-------------------------------------
function UI_ChallengeModeResult:direction_winReward()
	local t_item = self.m_winReward
	if (not t_item) then
		self:doNextWork()
		return
	end

	self:makeRewardPopup(t_item, Str('승리 보상 획득!'))
end

-------------------------------------
-- function direction_nextStage
-------------------------------------
function UI_ChallengeModeResult:direction_nextStage()
	if (not self.m_isOpenNextStage) then
		self:doNextWork()
		return
	end

	local function ok_func()
		self:doNextWork()
	end
	MakeSimplePopup2(POPUP_TYPE.OK, Str('다음 순위 잠금해제!'), Str('{1}위 팀에 도전할 수 있습니다.', g_challengeMode:getTopStage() - self.m_currStage), ok_func)
end

-------------------------------------
-- function makeRewardPopup
-------------------------------------
function UI_ChallengeModeResult:makeRewardPopup(t_item, title)
	local ui = UI()
	ui:load('arena_play_reward_popup.ui')
	UIManager:open(ui, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'temp')

	-- 제목
	ui.vars['playLabel']:setString(title)

	-- 우편 안내 숨김
	ui.vars['mailInfoLabel']:setVisible(false)

	-- 보상 아이템 표기
	if (t_item) then
		local icon = IconHelper:getItemIcon(t_item['item_id'])
		ui.vars['rewardNode']:addChild(icon)
		local count = comma_value(t_item['count'])
		ui.vars['rewardLabel']:setString(count)
	end

	-- 버튼
	ui.vars['okBtn']:registerScriptTapHandler(function() ui:close() end)

	-- UI 종료시 다음으로 진행
    ui:setCloseCB(function() self:doNextWork() end)
end

-------------------------------------
-- function click_okBtn
-- @override
-- @brief "확인" 버튼
-------------------------------------
function UI_ChallengeModeResult:click_okBtn()
	UINavigator:goTo('challenge_mode')
end