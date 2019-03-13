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
    tableView.m_defaultCellSize = cc.size(1000, 40)

    local l_rank_reward = g_clanRaidData:getRankRewardList()

    tableView:setCellUIClass(UI_HelpClanRewardListItem)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setItemList(l_rank_reward, false)

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
    
    local num_clan_exp = tonumber(data['clan_exp'])
    vars['clanExpLabel']:setString(comma_value(num_clan_exp))
    local reward_cnt = string.match(data['reward'], '%d+')
    -- 개인 보상 최대 퍼센트
    local personal_max_percent = 0.06
    local personal_cnt = math_floor(reward_cnt * personal_max_percent)
    vars['personalLabel']:setString(comma_value(personal_cnt))
    vars['clancoinLabel']:setString(comma_value(reward_cnt))
    local rank_str
    if (data['rank_min'] ~= data['rank_max']) then
        rank_str = Str('{1}~{2}위 ', data['rank_min'], data['rank_max'])
    else
        if(data['ratio_max'] ~= '') then
            rank_str = Str('{1}위 미만', data['ratio_max'])
        else
            rank_str = Str('{1}위', data['rank_min'])
        end
    end

    vars['rankLabel']:setString(rank_str) 
    vars['secondSprite']:setVisible(data['rank_id']%2 == 0)

end