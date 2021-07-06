local PARENT = UI

-------------------------------------
-- class UI_EventArenaPlay
-- @brief 
-------------------------------------
UI_EventArenaPlay = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventArenaPlay:init(popup_key)
    ui_name = 'event_update_reward.ui'    
    self:load(ui_name)

    self:initButton()
    --self:initUI()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @breif 초기화
-------------------------------------
function UI_EventArenaPlay:initUI()
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_EventArenaPlay:initButton()
    local vars = self.vars
    
    if (vars['rewardPlayBtn']) then vars['rewardPlayBtn']:registerScriptTapHandler(function() self:click_rewardBtn('play') end) end
    if (vars['rewardWinBtn']) then  vars['rewardWinBtn']:registerScriptTapHandler(function() self:click_rewardBtn('win') end) end

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventArenaPlay:refresh()
    local vars = self.vars

    if (vars['timeLabel']) then vars['timeLabel']:setString(g_eventArenaPlayData:getRemainEventTimeStr()) end
    if (vars['playNumberLabel']) then  vars['playNumberLabel']:setString(Str('승리 횟수 보상: {1}회', g_eventArenaPlayData:getWinCount())) end
    if (vars['winNumberLabel']) then  vars['winNumberLabel']:setString(Str('승리 횟수 보상: {1}회', g_eventArenaPlayData:getPlayCount())) end

    
    local play_reward_info = g_eventArenaPlayData:getPlayRewardInfo()
    local win_reward_info = g_eventArenaPlayData:getWinRewardInfo()

    local play_reward_step = play_reward_info['product']['step']
    local win_reward_step = play_reward_info['product']['step']

    local idx_play_item_start = 1
    local idx_win_item_start = 6

    for idx = 1, play_reward_step do
        local is_received = play_reward_info['reward'][idx] == 1
        vars['checkSprite' .. idx_play_item_start + (idx - idx_play_item_start)]:setVisible(is_received)
    end

    for idx = 1, win_reward_step do
        local is_received = win_reward_info['reward'][idx] == 1
        vars['checkSprite' .. idx_win_item_start + (idx - idx_play_item_start)]:setVisible(is_received)
    end

    if (vars['rewardPlayBtn']) then vars['rewardPlayBtn']:setEnabled(g_eventArenaPlayData:hasReward('play')) end
    if (vars['rewardWinBtn']) then vars['rewardWinBtn']:setEnabled(g_eventArenaPlayData:hasReward('win')) end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventArenaPlay:click_rewardBtn(reward_type)
    -- play or win
    g_eventArenaPlayData:request_eventReward(reward_type, function() self:refresh() end)
end

--@CHECK
UI:checkCompileError(UI_EventArenaPlay)