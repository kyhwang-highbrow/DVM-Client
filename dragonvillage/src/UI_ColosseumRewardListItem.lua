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
        self:initUI_legend()
        return
    end

    local vars = self.vars
    local icon = ColosseumUserInfo:makeTierIcon(tier_name, 'big')
    vars['tierNode']:addChild(icon)

    local table_colosseum_reward = TableColosseumReward()

    -- 마스터는 4개의 세부 등급 나머지는 3개의 세부 등급
    local max_num
    if (tier_name == 'master') then
        max_num = 4
    else
        max_num = 3
        vars['gradeLabel4']:setVisible(false)
        vars['scoreNode4']:setVisible(false)
        vars['rewardNode4']:setVisible(false)
    end

    -- 티어 명칭
    local tier_full_name = ColosseumUserInfo:getTierName(tier_name)
    vars['tierLabel']:setString(Str(tier_full_name))

    for i=1, max_num do
        -- 세부 등급
        local grade = i
        vars['gradeLabel' .. i]:setString(Str('{1}등급', grade))
        
        -- 최소 점수
        local min_rp = table_colosseum_reward:getMinRP(tier_name, grade)
        vars['scoreLabel' .. i]:setString(Str('{1}점+', comma_value(min_rp)))

        -- 보상
        local cash = table_colosseum_reward:getWeeklyRewardCash(tier_name, grade)
        vars['rewardLabel' .. i]:setString(Str('{1}개', comma_value(cash)))
    end

    -- 마스터는 조건 별도로 표기
    if (tier_name == 'master') then
        for i=1, 4 do
            local grade = i
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

            vars['gradeLabel' .. i]:setString(text)
        end
    end
end

-------------------------------------
-- function initUI_legend
-------------------------------------
function UI_ColosseumRewardListItem:initUI_legend()
    local vars = self.vars

    local table_colosseum_reward = TableColosseumReward()

    vars['legendNode']:setVisible(true)
    vars['normalTierNode']:setVisible(false)

    -- 아이콘
    local icon = ColosseumUserInfo:makeTierIcon(tier_name, 'big')
    vars['legendIcon']:addChild(icon)

    -- 최소 점수
    local min_rp = table_colosseum_reward:getMinRP('legend')
    vars['legendScoreLabel']:setString(Str('{1}점+', comma_value(min_rp)))

    -- 보상
    local cash = table_colosseum_reward:getWeeklyRewardCash('legend')
    vars['legendRewardLabel']:setString(Str('{1}개', comma_value(cash)))
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