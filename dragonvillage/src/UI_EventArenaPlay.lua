local PARENT = UI

-------------------------------------
-- class UI_EventArenaPlay
-- @brief
-------------------------------------
UI_EventArenaPlay = class(PARENT,{

    
    m_tabButtonCallback = 'function',
 })

-------------------------------------
-- function init
-------------------------------------
function UI_EventArenaPlay:init(popup_key)
    require('UI_EventArenaPlayItem')

    local ui_name = 'event_update_reward.ui'
    self:load(ui_name)

    self:initButton()
    self:initUI()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @breif 초기화
-------------------------------------
function UI_EventArenaPlay:initUI()
end

-------------------------------------
-- function onEnterTab
-- @breif 탭 진입
-------------------------------------
function UI_EventArenaPlay:onEnterTab()
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
    if (vars['playNumberLabel']) then  vars['playNumberLabel']:setString(Str('참여 횟수 보상: {1}회', g_eventArenaPlayData:getPlayCount())) end
    if (vars['winNumberLabel']) then  vars['winNumberLabel']:setString(Str('승리 횟수 보상: {1}회', g_eventArenaPlayData:getWinCount())) end
    
    local play_reward_info = g_eventArenaPlayData:getPlayRewardInfo()
    local win_reward_info = g_eventArenaPlayData:getWinRewardInfo()

    local play_reward_step = play_reward_info['product']['step']
    local win_reward_step = win_reward_info['product']['step']

    -- 참여 보상 아이템
    for idx = 1, play_reward_step do
        
        local itemNode = vars["itemNode" .. idx]

        if itemNode then
            -- itemNode 하위 존재하면 지워주고 다시 생성 해야 한다
            itemNode:removeAllChildren()
            local play_reward_item = UI_EventArenaPlayItem('play', idx)
            itemNode:addChild(play_reward_item.root)
        end
    end

    -- 승리 보상 아이템
    for idx = 1, win_reward_step do

        local itemNode = vars["itemNode" .. (idx + play_reward_step)]

        if itemNode then
            -- itemNode 하위 존재하면 지워주고 다시 생성 해야 한다
            itemNode:removeAllChildren()
            local win_reward_item = UI_EventArenaPlayItem('win', idx)
            itemNode:addChild(win_reward_item.root)
        end
    end

    -- 참여 횟수 버튼
    local has_play_reward = g_eventArenaPlayData:hasReward('play')
    local is_all_play_received = g_eventArenaPlayData:isAllReceived('play')

    if (vars['receivePlaySprite']) then vars['receivePlaySprite']:setVisible(is_all_play_received) end
    if (vars['rewardPlayBtn']) then 
        vars['rewardPlayBtn']:setEnabled(has_play_reward)
        if (is_all_play_received) then
            vars['rewardPlayBtn']:setVisible(false)
        else
            vars['rewardPlayBtn']:setVisible(true)
            vars['rewardPlayBtn']:setEnabled(has_play_reward)
            if (vars['rewardPlayLabel']) then 
                local color = has_play_reward and COLOR['black'] or COLOR['DESC']
                vars['rewardPlayLabel']:setColor(color)
            end
        end
    end

    -- 승리 횟수 버튼
    local has_win_reward = g_eventArenaPlayData:hasReward('win')
    local is_all_win_received = g_eventArenaPlayData:isAllReceived('win')

    if (vars['receiveWinSprite']) then vars['receiveWinSprite']:setVisible(is_all_win_received) end
    if (vars['rewardWinBtn']) then
        if (is_all_win_received) then
            vars['rewardWinBtn']:setVisible(false)
        else
            vars['rewardWinBtn']:setVisible(true)
            vars['rewardWinBtn']:setEnabled(has_win_reward)
            if (vars['rewardWinLabel']) then
                local color = has_win_reward and COLOR['black'] or COLOR['DESC']
                vars['rewardWinLabel']:setColor(color)
            end
        end
        
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventArenaPlay:click_rewardBtn(reward_type)
    function finish_cb(ret)
        UI_ToastPopup(Str('보상이 우편함으로 전송되었습니다.'))
        self:refresh()

        if self.m_tabButtonCallback then
            self.m_tabButtonCallback()
        end
    end

    -- play or win
    g_eventArenaPlayData:request_eventReward(reward_type, finish_cb)
end

--@CHECK
UI:checkCompileError(UI_EventArenaPlay)