local PARENT = UI

-------------------------------------
-- class UI_ColosseumFirstReward
-------------------------------------
UI_ColosseumFirstReward = class(PARENT, {
		m_tier = 'str'
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumFirstReward:init(t_data)
    local vars = self:load('colosseum_first_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

	-- 멤버 변수 할당
	self.m_tier = t_data['tier']
  
   -- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ColosseumFirstReward')

    self:initUI()
    self:initButton()
    self:refresh()

    -- 하위 UI가 모두 opacity값을 적용되도록
    doAllChildren(self.root, function(node) node:setCascadeOpacityEnabled(true) end)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ColosseumFirstReward:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumFirstReward:initUI()
    local vars = self.vars
	local l_tier_info = stringSplit(self.m_tier, '_')
	local tier_name = l_tier_info[1]
	local tier_grade = l_tier_info[2]

	-- 티어 이름
	local tier_full_name = ColosseumUserInfo:getTierName(tier_name)
    vars['tierLabel']:setString(tier_full_name)

	-- 티어 아이콘
    local tier_icon = ColosseumUserInfo:makeTierIcon(tier_name, 'big')
    vars['tierNode']:addChild(tier_icon)

	-- 보상 지급 문구
	local reward_value = TableColosseumReward():getFirstRewardCash(tier_name, tier_grade)
    vars['rewardLabel']:setString(reward_value)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumFirstReward:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumFirstReward:refresh()
end

--@CHECK
UI:checkCompileError(UI_ColosseumFirstReward)
