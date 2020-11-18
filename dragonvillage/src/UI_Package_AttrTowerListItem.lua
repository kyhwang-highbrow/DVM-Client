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
    self.m_data = data
    local vars = self:load('package_attr_tower_fire_item.ui')

    self:initUI()
    --self:initButton()
    --self:refresh()
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
    vars['linkBtn']:registerScriptTapHandler(function() self:click_linkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AttrTowerListItem:refresh()
    local vars = self.vars
    local data = self.m_data

    if g_adventureClearPackageData03:isActive() then
        local stage_id = data['stage']
        if g_adventureClearPackageData03:isReceived(stage_id) then
            vars['receiveSprite']:setVisible(true)
            vars['rewardBtn']:setVisible(false)
            vars['linkBtn']:setVisible(false)
        else
            vars['receiveSprite']:setVisible(false)
            vars['rewardBtn']:setVisible(true)

            local stage_info = g_adventureData:getStageInfo(stage_id)
            local star = stage_info:getNumberOfStars()

            if (star < 3) then
                vars['rewardBtn']:setVisible(false)
                vars['rewardBtn']:setEnabled(true)
                vars['linkBtn']:setVisible(true)
            else
                vars['rewardBtn']:setVisible(true)
                vars['rewardBtn']:setEnabled(true)
                vars['linkBtn']:setVisible(false)
            end
        end
    else
        vars['receiveSprite']:setVisible(false)
        vars['rewardBtn']:setVisible(true)
        vars['rewardBtn']:setEnabled(false)
    end

    do -- 획득한 별 표시
        local stage_id = data['stage']
        local stage_info = g_adventureData:getStageInfo(stage_id)
        local star = stage_info:getNumberOfStars()
        for i=1, 3 do
            local node = vars['starSprite' .. i]
            if node then
                node:setVisible(i <= star)
            end
        end
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
    local stage_id = data['stage']

    local stage_info = g_adventureData:getStageInfo(stage_id)
    local star = stage_info:getNumberOfStars()

    if (star < 3) then
        UIManager:toastNotificationRed(Str('별 3개로 클리어 시 보상을 획득할 수 있습니다.'))
        return
    end

    local function cb_func(ret)
        self:refresh()

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
    end

    g_adventureClearPackageData03:request_adventureClearReward(stage_id, cb_func)
end

-------------------------------------
-- function click_linkBtn
-- @brief 스테이지 바로가기 버튼
-------------------------------------
function UI_Package_AttrTowerListItem:click_linkBtn()
    local data = self.m_data
    local stage_id = data['stage']
    UINavigator:goTo('adventure', stage_id)
end