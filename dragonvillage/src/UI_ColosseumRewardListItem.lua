local PARENT = UI

-------------------------------------
-- class UI_ColosseumRewardListItem
-------------------------------------
UI_ColosseumRewardListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumRewardListItem:init(tier_name)
    local vars = self:load('colosseum_reward_popup_item_01.ui')

    self:initUI(tier_name)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumRewardListItem:initUI(tier_name)
    -- 레전드는 별도 함수 사용
    if (tier_name == 'legend') then
        self:makeLegendUI()
	elseif (tier_name == 'master') then
		self:makeMasterUI()
	else
		self:makeOtherTierUI(tier_name)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumRewardListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumRewardListItem:refresh()
end

-------------------------------------
-- function makeLegendUI
-------------------------------------
function UI_ColosseumRewardListItem:makeLegendUI()
    local vars = self.vars
    local table_colosseum_reward = TableColosseumReward()
	local tier_name = 'legend'

	-- 노드 on/off
    vars['legendNode']:setVisible(true)
	vars['masterTierNode']:setVisible(false)
    vars['normalTierNode']:setVisible(false)

    -- 최소 점수
    local min_rp = table_colosseum_reward:getMinRP('legend')
    vars['legendScoreLabel']:setString(Str('{1}점+', comma_value(min_rp)))

    -- 보상
    local cash = table_colosseum_reward:getWeeklyRewardCash('legend')
    vars['legendRewardLabel']:setString(Str('{1}개', comma_value(cash)))

	-- 보상 가능 표시
	local player_info = g_colosseumData:getPlayerInfo()
	local is_same_tier = string.find(player_info.m_tier, tier_name)
	vars['legendRewardSprite']:setVisible(is_same_tier)
end

-------------------------------------
-- function makeMasterUI
-------------------------------------
function UI_ColosseumRewardListItem:makeMasterUI()
    local vars = self.vars
    local table_colosseum_reward = TableColosseumReward()
	local player_info = g_colosseumData:getPlayerInfo()
	
	local tier_name = 'master'
	local max_grade = 4

	-- 노드 on/off
    vars['legendNode']:setVisible(false)
	vars['masterTierNode']:setVisible(true)
    vars['normalTierNode']:setVisible(false)
	
	-- 보상 구간 확인 우선 off
	vars['masterRewardSprite']:setVisible(false)

    for grade = 1, max_grade do
        -- 세부 조건
        local text
        if (grade == 1) then
            text = Str('2위')
        elseif (grade == 2) then
            text = Str('3위')
        elseif (grade == 3) then
            text = Str('4~10위')
        elseif (grade == 4) then
            text = Str('11~50위')
        end
        vars['masterGradeLabel' .. grade]:setString(text)
        
        -- 최소 점수
        local min_rp = table_colosseum_reward:getMinRP(tier_name, grade)
        vars['masterScoreLabel' .. grade]:setString(Str('{1}점+', comma_value(min_rp)))

        -- 보상
        local cash = table_colosseum_reward:getWeeklyRewardCash(tier_name, grade)
        vars['masterRewardLabel' .. grade]:setString(Str('{1}개', comma_value(cash)))

		-- 보상 구간 여부 확인
		if (player_info.m_tier == tier_name .. '_' .. grade) then
			vars['masterRewardSprite']:setPositionY(60 - (30* grade))
			vars['masterRewardSprite']:setVisible(true)

			cca.uiPointingAction(vars['masterRewardSprite'], 'left_right', 10)
		end
    end
end

-------------------------------------
-- function makeOtherTierUI
-------------------------------------
function UI_ColosseumRewardListItem:makeOtherTierUI(tier_name)
    local vars = self.vars
    local table_colosseum_reward = TableColosseumReward()
	local player_info = g_colosseumData:getPlayerInfo()
	
	local tier_name = tier_name or 'bronze'
	local max_grade = 3

	-- 노드 on/off
    vars['legendNode']:setVisible(false)
	vars['masterTierNode']:setVisible(false)
    vars['normalTierNode']:setVisible(true)

	-- 보상 구간 확인 우선 off
	vars['rewardSprite']:setVisible(false)

	-- 티어 명칭
    local tier_full_name = ColosseumUserInfo:getTierName(tier_name)
    vars['tierLabel']:setString(Str(tier_full_name))

	-- 아이콘
	local icon = ColosseumUserInfo:makeTierIcon(tier_name, 'big')
    vars['tierNode']:addChild(icon)

    for grade = 1, max_grade do
        -- 세부 등급
        vars['gradeLabel' .. grade]:setString(Str('{1}등급', grade))
        
        -- 최소 점수
        local min_rp = table_colosseum_reward:getMinRP(tier_name, grade)
        vars['scoreLabel' .. grade]:setString(Str('{1}점+', comma_value(min_rp)))

        -- 보상
        local cash = table_colosseum_reward:getWeeklyRewardCash(tier_name, grade)
        vars['rewardLabel' .. grade]:setString(Str('{1}개', comma_value(cash)))

		-- 보상 구간 여부 확인
		if (player_info.m_tier == tier_name .. '_' .. grade) then
			vars['rewardSprite']:setPositionY(78 - (39 * grade))
			vars['rewardSprite']:setVisible(true)

			cca.uiPointingAction(vars['rewardSprite'], 'left_right', 10)
		end
    end
end