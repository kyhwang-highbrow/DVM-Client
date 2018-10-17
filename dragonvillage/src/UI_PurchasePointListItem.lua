local PARENT = UI

-------------------------------------
-- class UI_PurchasePointListItem
-------------------------------------
UI_PurchasePointListItem = class(PARENT, {
        m_version = '',
        m_step = '',
    })

-------------------------------------
-- function init
-- @param
-------------------------------------
function UI_PurchasePointListItem:init(version, step)
    self.m_version = version
    self.m_step = step
    local vars = self:load('event_purchase_point_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PurchasePointListItem:initUI()
    local vars = self.vars

    local version = self.m_version
    local step = self.m_step

    local t_step, reward_state = g_purchasePointData:getPurchasePoint_rewardStepInfo(version, step)
    local package_item_str = t_step['item']
    local l_reward = ServerData_Item:parsePackageItemStr(package_item_str)

    -- 구조상 다중 보상 지급이 가능하나, 현재로선 하나만 처리 중 sgkim 2018.10.17
    local first_item = l_reward[1]
    local item_id = first_item['item_id']
    local count = first_item['count']

    -- 아이템 아이콘
    local item_card = UI_ItemCard(item_id, count)
    vars['itemNode']:addChild(item_card.root)

    -- 아이템 이름
    local item_name = TableItem:getItemName(item_id)
    vars['itemLabel']:setString(item_name)

    -- 필요 결제 점수
    local purchase_point = t_step['purchase_point']
    local str = Str('{1}점 이상', comma_value(purchase_point))
    if (purchase_point <= 1) then
        str = Str('첫 구매')
    end
    vars['scoreLabel']:setString(str)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PurchasePointListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PurchasePointListItem:refresh()
    local vars = self.vars
    local version = self.m_version
    local step = self.m_step

    local t_step, reward_state = g_purchasePointData:getPurchasePoint_rewardStepInfo(version, step)


    vars['checkSprite']:setVisible(false)
    vars['readySprite']:setVisible(false)
    vars['receiveBtn']:setVisible(false)

    -- 획득 완료
    if (reward_state == 1) then
        vars['checkSprite']:setVisible(true)
    
    -- 획득 가능
    elseif (reward_state == 0) then
        vars['receiveBtn']:setVisible(true)

    -- 획득 불가
    --elseif (reward_state == -1) then
    else
        vars['readySprite']:setVisible(true)
    end
end

-------------------------------------
-- function click_clickBtn
-------------------------------------
function UI_PurchasePointListItem:click_clickBtn()
end