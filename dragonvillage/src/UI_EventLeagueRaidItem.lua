local PARENT = UI

-------------------------------------
-- class UI_EventLeagueRaidItem
-- @brief 콜로세움 참여 이벤트 UI 아이템 클래스
-------------------------------------
UI_EventLeagueRaidItem = class(PARENT, {
    m_itemIndex = 'number',   -- 몇 번째 보상인지 (1 - 5)
    m_rewardInfo = 'g_eventLeagueRaidData', -- 
    m_rewardType = 'string', -- 보상 타
})

-------------------------------------
-- function init
-- @param reward_type 보상 타입 (play, or win)
-- @param item_index  몇 번째 보상인지 (1 - 5)
-------------------------------------
function UI_EventLeagueRaidItem:init(reward_type, item_index)
    if (reward_type == 'play') then
        self.m_rewardInfo = g_eventLeagueRaidData:getPlayRewardInfo()
    elseif (reward_type == 'win') then
        self.m_rewardInfo = g_eventLeagueRaidData:getWinRewardInfo()
    end

    self.m_itemIndex = item_index
    self.m_rewardType = reward_type
    local ui_name = 'event_raid_update_reward_item.ui'
    self:load(ui_name)

    self:initButton()
    self:initUI()
    --self:refresh()
end

-------------------------------------
-- function initUI
-- @breif 초기화, refresh 되지 않고 삭제되었다가 재 생성된다. 
-------------------------------------
function UI_EventLeagueRaidItem:initUI()
    local vars = self.vars
    local itemIndex = self.m_itemIndex
    local rewardInfo = self.m_rewardInfo

    -- 수령한 보상인지, 수령 가능한 보상인지 확인
    local is_received = rewardInfo['reward'][tostring(itemIndex)] == 1
    local count = rewardInfo['product']['price_' .. itemIndex]
    local val
    if self.m_rewardType == 'win' then
        val = g_eventLeagueRaidData:getWinCount()
        --cclog('win', val, count)
    else
        val = g_eventLeagueRaidData:getPlayCount()
        --cclog('play', val, count)
    end
    
    local can_receive = val >= count and (not is_received)

    -- 수령한 보상, 수령 가능한 보상
    vars['checkSprite']:setVisible(is_received)
    vars['playRewardSprite']:setVisible(can_receive)

    -- 참여 횟수
    if self.m_rewardType == 'win' then
        vars['countLabel']:setString(Str('{1}점', comma_value(count)))
    else
        vars['countLabel']:setString(Str('{1}회', count))
    end

    -- 아이템 Icon
    local item_id, item_count = g_itemData:parsePackageItemStrIndivisual(rewardInfo['product']['mail_content_' .. itemIndex])
    local item_icon = IconHelper:getItemIcon(item_id)
    vars['itemNode']:addChild(item_icon)

    -- 아이템 이름, 개수
    local item_name = TableItem:getItemName(item_id)
    vars['itemLabel']:setString(item_name .. '\n' .. Str('{1}개', item_count))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventLeagueRaidItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventLeagueRaidItem:refresh()
end

--@CHECK
UI:checkCompileError(UI_EventLeagueRaidItem)