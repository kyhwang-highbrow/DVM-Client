local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerRewardListItem
-------------------------------------
UI_AncientTowerRewardListItem = class(PARENT, {
        m_rewardInfo = '',
    })

local REWARD_CNT = 3

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerRewardListItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    local vars = self:load('tower_scene_reward_item.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerRewardListItem:initUI()
    local vars = self.vars
    local t_reward_info = self.m_rewardInfo
    
    vars['rankingLabel']:setString(t_reward_info['t_name'])

    for i = 1, REWARD_CNT do
        local l_str = seperate(t_reward_info['reward_'..i], ';')
        local item_type = l_str[1]
        local id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
        
        local icon = IconHelper:getItemIcon(id)
        icon:setScale(0.4)
        vars['rewardNode'..i]:addChild(icon)

        --[[
        local ui = UI_ItemCard(id)
        ui.root:setScale(0.4)
        vars['rewardNode'..i]:addChild(ui.root)
        ]]--

        local name = TableItem:getItemName(id)
        local cnt = l_str[2]
        vars['rewardLabel'..i]:setString(Str('{1} x{2}', name, cnt))
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerRewardListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerRewardListItem:refresh()
end
