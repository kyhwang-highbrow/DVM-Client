local PARENT = UI

-------------------------------------
-- class UI_EventArenaPlayItem
-- @brief 콜로세움 참여 이벤트 UI 아이템 클래스
-------------------------------------
UI_EventArenaPlayItem = class(PARENT, {
    m_itemIndex = 'number',   -- 몇 번째 보상인지 (1 - 5)
    m_rewardInfo = 'g_eventArenaPlayData'
})

-------------------------------------
-- function init
-- @param reward_type 보상 타입 (play, or win)
-- @param item_index  몇 번째 보상인지 (1 - 5)
-------------------------------------
function UI_EventArenaPlayItem:init(reward_type, item_index)
    if (reward_type == 'play') then
        self.m_rewardInfo = g_eventArenaPlayData:getPlayRewardInfo()
    elseif (reward_type == 'win') then
        self.m_rewardInfo = g_eventArenaPlayData:getWinRewardInfo()
    end
        
    self.m_itemIndex = item_index
    
    local ui_name = 'event_update_reward_item.ui'
    self:load(ui_name)

    self:initButton()
    self:initUI()
    --self:refresh()
end

-------------------------------------
-- function initUI
-- @breif 초기화, refresh 되지 않고 삭제되었다가 재 생성된다. 
-------------------------------------
function UI_EventArenaPlayItem:initUI()
    local vars = self.vars
    local itemIndex = self.m_itemIndex
    local rewardInfo = self.m_rewardInfo

    -- 수령한 보상인지, 수령 가능한 보상인지 확인
    local is_received = rewardInfo['reward'][tostring(itemIndex)] == 1
    local can_receive = g_eventArenaPlayData:getPlayCount() >= rewardInfo['product']['price_' .. itemIndex] and (not is_received)

    -- 수령한 보상, 수령 가능한 보상
    vars['checkSprite']:setVisible(is_received)
    vars['playRewardSprite']:setVisible(can_receive)

    -- 참여 횟수
    local count = rewardInfo['product']['price_' .. itemIndex]
    vars['countLabel']:setString(Str('{1} 회', count))

    -- 아이템 Icon
    local item_id, item_count = g_itemData:parsePackageItemStrIndivisual(rewardInfo['product']['mail_content_' .. itemIndex])
    local item_icon = IconHelper:getItemIcon(item_id)
    vars['itemNode']:addChild(item_icon)

    -- 아이템 이름, 개수
    local item_name = TableItem:getItemName(item_id)
    vars['itemLabel']:setString(Str('{1}\n{2}개', item_name, item_count))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventArenaPlayItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventArenaPlayItem:refresh()
end

--@CHECK
UI:checkCompileError(UI_EventArenaPlayItem)