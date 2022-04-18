-------------------------------------
-- class UI_EventRouletteRewardPopup
-- @brief 룰렛 보상 화면
-------------------------------------
UI_EventRouletteRewardPopup = class(UI, {

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRouletteRewardPopup:init(reward_table)
    local vars = self:load('event_roulette_popup_reward.ui')
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRouletteRewardPopup')    

    self.m_uiName = 'UI_EventRouletteRewardPopup'  

    vars['okBtn']:registerScriptTapHandler(function() self:close() end)    


    if (reward_table) then
        local msg
        -- score
        if reward_table['bonus_score'] and (reward_table['bonus_score'] ~= '') then
            msg = Str('대박 점수: {1}점', reward_table['bonus_score'])
        elseif reward_table['score'] and (reward_table['score'] ~= '') then
            msg = Str('점수: {1}점', reward_table['score'])
        else
            msg = ''
        end

        -- item
        if reward_table['mail_item_info'] then
            local id = reward_table['mail_item_info']['item_id']
            local count = reward_table['mail_item_info']['count']
            local item_card = UI_ItemCard(id, count)

            if item_card then
                vars['itemNode']:addChild(item_card.root)
            end
        end

        vars['scoreLabel']:setString(msg)

        g_highlightData:setHighlightMail()

    end
end

