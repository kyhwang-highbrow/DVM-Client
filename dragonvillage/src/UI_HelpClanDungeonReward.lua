local PARENT = UI_TabUI_AutoGeneration

-------------------------------------
-- class UI_HelpClanDungeonReward
-------------------------------------
UI_HelpClanDungeonReward = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HelpClanDungeonReward:init(ui_name, is_root, ui_depth, struct_tab_ui)
    self.m_uiName = 'UI_HelpClanDungeonReward'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HelpClanDungeonReward:initUI()

    local vars = self.vars
    
    local node = vars['cldg_rewardScrollNode']
    -- 테이블 뷰 인스턴스 생성
    local tableView = UIC_TableView(node)
    --self.m_tableView:setUseVariableSize(true)
    tableView.m_defaultCellSize = cc.size(1000, 40)

    local l_reward = TABLE:get('table_clan_reward')
    ccdump(l_reward)
    tableView:setCellUIClass(UI_HelpClanRewardListItem)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setItemList(l_reward, false)

    --self.m_tableView.m_scrollView:setLimitedOffset(true)

    -- 개인 보상 최대 퍼센트
    local personal_max_percent = 0.08
    --[[
    for i, cnt in ipairs(t_clan_coin_max) do
        if (vars['clancoinLabel'..i]) then
            vars['clancoinLabel'..i]:setString(Str('{1}개', comma_value(cnt)))
        end
        
        local personal_cnt = math_floor(cnt * personal_max_percent)
        if (vars['personalLabel'..i]) then
            vars['personalLabel'..i]:setString(Str('{1}개', comma_value(personal_cnt)))
        end
    end
    --]]
    PARENT.initUI(self)
end









local _PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_HelpClanRewardListItem
-------------------------------------
UI_HelpClanRewardListItem = class(_PARENT, {
        m_tdata = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HelpClanRewardListItem:init(t_data)
    local vars = self:load('help_clan_dungeon_reward_item.ui')
    
    self.m_tdata = t_data
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HelpClanRewardListItem:initUI()
    local vars = self.vars
    local data = self.m_tdata
    --[[  
        ['clan_exp']=25000;
        ['category']='dungeon';
        ['t_name']='36~40위';
        ['ratio_min']='';
        ['rank_min']=36;
        ['ratio_max']='';
        ['rank_max']=40;
        ['week']=1;
        ['rank_id']=3024;
        ['reward']='clancoin;1850';
    --]]

    vars['clanExpLabel']:setString(data['clan_exp'])
    local reward_cnt = string.match(data['reward'], '%d+')
    -- 개인 보상 최대 퍼센트
    local personal_max_percent = 0.08
    local personal_cnt = math_floor(reward_cnt * personal_max_percent)
    vars['personalLabel']:setString(personal_cnt)
    vars['clancoinLabel']:setString(reward_cnt)
    vars['rankLabel']:setString(data['t_name'])
    vars['secondSprite']:setVisible(false)

end