local PARENT = UI

-------------------------------------
-- class UI_RewardPopup
-------------------------------------
UI_RewardPopup = class(PARENT,{
		m_lRewardTable = 'Reward Table List',
        m_cbOKBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RewardPopup:init(l_tReward, ok_btn_cb)
    self.m_lRewardTable = l_tReward
    self.m_cbOKBtn = ok_btn_cb

    local vars = self:load('popup_reward.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_RewardPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RewardPopup:initUI()
	local vars = self.vars
    
	vars['titleLabel']:setString(Str('보상 수령'))

    self:setRewardCard()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RewardPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RewardPopup:refresh()
	local vars = self.vars
end

-------------------------------------
-- function setRewardCard
-- @brief 보상 아이콘 표시
-------------------------------------
function UI_RewardPopup:setRewardCard()
    local vars = self.vars
	
	local reward_type, reward_unit, reward_card, reward_count = nil
	local t_reward = self.m_lRewardTable
	local t_card = {}
	for i = 1, 3 do 
		reward_type = t_reward['reward_type_' .. i]
		reward_unit = t_reward['reward_unit_' .. i]
		reward_count = reward_unit * t_reward['reward_cnt']
		if (reward_type) then
		    reward_card = UI_RewardCard(reward_type, reward_count)
			table.insert(t_card, reward_type)
		end
	end

	-- 퀘스트 팝업 자체를 각 아이템이 가지기 위한 생성 콜백
	local create_cb_func = function(ui)
		ui:setParent(self)
	end

    -- 테이블 뷰 인스턴스 생성
	local node = vars['rewardNode']
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(150, 150)
	table_view:setCellUIClass(UI_RewardCard, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(t_card)
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_RewardPopup:click_backKey()
    self:click_okBtn()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_RewardPopup:click_okBtn()
    if self.m_cbOKBtn then
        self.m_cbOKBtn()
    end

    self:close()
end

--@CHECK
UI:checkCompileError(UI_RewardPopup)
