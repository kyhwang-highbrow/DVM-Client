local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerClanRewardListItem
-------------------------------------
UI_AncientTowerClanRewardListItem = class(PARENT, {
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerClanRewardListItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    local vars = self:load('tower_scene_reward_item_clan.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerClanRewardListItem:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerClanRewardListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerClanRewardListItem:refresh()
    local vars = self.vars
    local t_reward_info = self.m_rewardInfo
    ccdump(t_reward_info)
    vars['rankLabel']:setString(t_reward_info['t_name'])
    
    -- º¸»ó
    do
        local l_str = plSplit(t_reward_info['reward'], ';')
        local item_type = l_str[1]
        local id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
        local name = TableItem:getItemName(id)
        local cnt = l_str[2]
        vars['rewardLabel']:setString(Str('{1} x{2}', name, cnt))

        --[[
        local icon = IconHelper:getItemIcon(id)
        
        local table_item = TABLE:get('item')
        local t_item = table_item[id]

        local scale = 0.4
        if (t_item and t_item['type'] == 'relation_point') then
            scale = 0.3
        end
        
        icon:setScale(scale)
        vars['rewardNode']:addChild(icon)
        ]]

    end
end
