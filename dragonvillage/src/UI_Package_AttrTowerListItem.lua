local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_Package_AttrTowerListItem
-------------------------------------
UI_Package_AttrTowerListItem = class(PARENT, {
        m_data = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_AttrTowerListItem:init(data)
    local vars = self:load('package_attr_tower_item.ui')
    
    self.m_data = data

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AttrTowerListItem:initUI()
    local vars = self.vars
    local t_data = self.m_data
    
    -- 층
    local floor = t_data['floor']
    vars['attrLabel']:setString(Str('{1}층', floor))

    self:initItemCard()
end

-------------------------------------
-- function initItemCard
-------------------------------------
function UI_Package_AttrTowerListItem:initItemCard()
    local vars = self.vars
    local t_data = self.m_data
    
    local total_item_table = {}
    local reward_info = t_data['reward_info'] 
    local reward_items_list = g_itemData:parsePackageItemStr(reward_info)

    for idx, item_info in ipairs(reward_items_list) do
        local node = vars['itemNode' .. idx]
        if (node ~= nil) then
            local item_id = item_info['item_id']
            local item_count = item_info['count']
            local item_ui = UI_ItemCard(item_id, item_count)
            node:addChild(item_ui.root)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AttrTowerListItem:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    --vars['linkBtn']:registerScriptTapHandler(function() self:click_linkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AttrTowerListItem:refresh()
    local vars = self.vars
    local t_data = self.m_data
    local product_id = t_data['product_id']
    local floor = t_data['floor']

    if (g_attrTowerPackageData:isActive(product_id)) then
        -- 수령 가능한지
        local challenge_floor = g_attrTowerData:getChallengingFloor()
        local clear_floor = challenge_floor - 1
    
        -- 이미 수령한 경우
        if (g_attrTowerPackageData:isReceived(product_id, floor)) then
            vars['receiveSprite']:setVisible(true)
            vars['rewardBtn']:setVisible(false)
    
        -- 수령이 가능한 경우
        elseif (clear_floor >= floor) then
            vars['receiveSprite']:setVisible(false)
            vars['rewardBtn']:setVisible(true)
            vars['rewardBtn']:setEnabled(true)
        end
    else
        vars['receiveSprite']:setVisible(false)
        vars['rewardBtn']:setVisible(true)
        vars['rewardBtn']:setEnabled(false)
    end

    if vars['rewardBtn']:isEnabled() then
        vars['infoLabel']:setTextColor(cc.c4b(0, 0, 0, 255))
    else
        vars['infoLabel']:setTextColor(cc.c4b(240, 215, 159, 255))
    end
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_Package_AttrTowerListItem:click_rewardBtn()
    local data = self.m_data
    local product_id = data['product_id']
    local floor = data['floor']

    local challenge_floor = g_attrTowerData:getChallengingFloor()
    local clear_floor = challenge_floor - 1

    -- 이전 보상을 받지 않았다면
    if (not g_attrTowerPackageData:availReceive(product_id, floor)) then
        UIManager:toastNotificationRed(Str('이전 단계의 보상을 수령하지 않았습니다.')) 
        return 
    end

    local function cb_func(ret)
        self:refresh()

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
    end

    g_attrTowerPackageData:request_attrTowerPackReward(product_id, floor, cb_func)
end

-------------------------------------
-- function click_linkBtn
-- @brief 스테이지 바로가기 버튼
-------------------------------------
function UI_Package_AttrTowerListItem:click_linkBtn()
    local data = self.m_data
end