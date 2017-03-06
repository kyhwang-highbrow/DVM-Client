local PARENT = UI

-------------------------------------
-- class UI_AdventureFirstRewardButton
-------------------------------------
UI_AdventureFirstRewardButton = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureFirstRewardButton:init(stage_id)
    local vars = self:load('adventure_first_reward_button.ui')

    do -- 보상 아이템 아이콘 생성
        local first_reward_data = g_adventureFirstRewardData:getFirstRewardInfo(stage_id)

        local reward_str = first_reward_data['reward']
        local item_id, count = g_itemData:parsePackageItemStrIndivisual(reward_str)

        local item_card = UI_ItemCard(item_id, count)
        item_card.vars['clickBtn']:setEnabled(false)
        vars['rewardIconNode']:addChild(item_card.root)
    end

    do -- 버튼 상태 처리
        local stage_info = g_adventureData:getStageInfo(stage_id)
        local state = stage_info:getFirstClearRewardState()

        if (state == 'received') then
            vars['rewardCheckSprite']:setVisible(true)
            vars['rewardReceiveVisual']:setVisible(false)

        elseif (state == 'opend') then
            vars['rewardCheckSprite']:setVisible(false)
            vars['rewardReceiveVisual']:setVisible(true)

        elseif (state == 'lock') then
            vars['rewardCheckSprite']:setVisible(false)
            vars['rewardReceiveVisual']:setVisible(false)

        else
            error('status : ' .. status)
        end
    end

    -- 코드 파악이 편하도록 외부에서 처리함
    --vars['rewardBtn']:registerScriptTapHandler()
end