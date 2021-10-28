-------------------------------------
-- class UI_LeagueRaidRankItem
-------------------------------------
UI_LeagueRaidRankMenu = class(UI,{

    })

-------------------------------------
-- function init
-------------------------------------
function UI_LeagueRaidRankMenu:init(owner_ui)
    local vars = self:load('league_raid_rank.ui')


    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LeagueRaidRankMenu:initUI()
    self:updateRankItems()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LeagueRaidRankMenu:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LeagueRaidRankMenu:refresh()
end

-------------------------------------
-- function updateRankItems
-------------------------------------
function UI_LeagueRaidRankMenu:updateRankItems()
    local vars = self.vars
    local promotion_list = {}
    local remaining_list = {}
    local demoted_list = {}
    local my_info = g_leagueRaidData:getMyInfo()
    local members_list = g_leagueRaidData:getMemberList()

    -- 0 승급, 1 잔류, 3 강등
    for i, v in ipairs(members_list) do
        if (v and v['status'] and v['status'] == 0) then
            table.insert(promotion_list, v)
        elseif (v and v['status'] and v['status'] == 1) then
            table.insert(remaining_list, v)
        else
            table.insert(demoted_list, v)
        end
    end

    local list_offset_y = 35
    local margin = 20

    -- 승격
    if (not vars['promotionNode']) then return end

    local table_view_promotion = UIC_TableViewTD(vars['promotionNode'])
    table_view_promotion.m_cellSize = cc.size(245, 95)
    table_view_promotion.m_nItemPerCell = 3
    table_view_promotion:setCellUIClass(UI_LeagueRaidRankItem)
    table_view_promotion:setItemList(promotion_list)
    table_view_promotion.m_scrollView:setTouchEnabled(false)
    table_view_promotion.m_node:setPositionY(0 - list_offset_y - margin)

    -- 승격 아이템 수량에 따라 잔류 위치 조정
    local line_promotion = 0
    for i, v in ipairs(promotion_list) do
        if (i % 3 == 1) then line_promotion = line_promotion + 1 end
    end

    line_promotion = line_promotion == 0 and 1 or line_promotion

    local pos_remaining_view_y = 0 - list_offset_y - (90) * line_promotion - margin


    -- 잔류
    if (not vars['remainingPannelNode'] or not vars['remainingNode']) then return end

    local table_view_remaining = UIC_TableViewTD(vars['remainingNode'])
    table_view_remaining.m_cellSize = cc.size(245, 95)
    table_view_remaining.m_nItemPerCell = 3
    table_view_remaining:setCellUIClass(UI_LeagueRaidRankItem)
    table_view_remaining:setItemList(remaining_list)
    table_view_remaining.m_scrollView:setTouchEnabled(false)
    table_view_remaining.m_node:setPositionY(0 - list_offset_y - margin)

    vars['remainingPannelNode']:setPositionY(pos_remaining_view_y)

    -- 승격 아이템 수량에 따라 잔류 위치 조정
    local line_remaining = 0
    for i, v in ipairs(remaining_list) do
        if (i % 3 == 1) then line_remaining = line_remaining + 1 end
    end

    line_remaining = line_remaining == 0 and 1 or line_remaining

    local pos_demoted_view_y = pos_remaining_view_y - list_offset_y - 90 * line_remaining - margin


    -- 강등
    if (not vars['demotedPannelNode'] or not vars['demotedNode']) then return end

    local table_view_demoted = UIC_TableViewTD(vars['demotedNode'])
    table_view_demoted.m_cellSize = cc.size(245, 95)
    table_view_demoted.m_nItemPerCell = 3
    table_view_demoted:setCellUIClass(UI_LeagueRaidRankItem)
    table_view_demoted:setItemList(demoted_list)
    table_view_demoted.m_scrollView:setTouchEnabled(false)
    table_view_demoted.m_node:setPositionY(0 - list_offset_y - margin)

    vars['demotedPannelNode']:setPositionY(pos_demoted_view_y)
end



-------------------------------------
-- class UI_LeagueRaidRankItem
-------------------------------------
UI_LeagueRaidRankItem = class(UI, ITableViewCell:getCloneTable(),{
        m_userInfo = 'table',
    })


--[[
{
                ['lv']=99;
                ['uid']='ykil';
                ['nick']='ykil';
                ['status']=0;
                ['leader']={
                        ['transform']=3;
                        ['did']=120872;
                        ['evolution']=3;
                };
                ['score']=0;
        }
]]

-----------------------------------------
-- function init
-------------------------------------
function UI_LeagueRaidRankItem:init(user_info)
    local vars = self:load('league_raid_rank_item.ui')

    self.m_userInfo = user_info

    self:initUI()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_LeagueRaidRankItem:initUI()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LeagueRaidRankItem:initButton()
    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LeagueRaidRankItem:refresh()
    local vars = self.vars

    if (not self.m_userInfo) then return end

    local number = self.m_userInfo['rank'] == nil and '-' or self.m_userInfo['rank']
    local nick_name = self.m_userInfo['nick']
    local score = self.m_userInfo['score']
    local leader_info = self.m_userInfo['leader'] == nil and {} or self.m_userInfo['leader']

    -- 기본정보
    if (vars['rankLabel']) then vars['rankLabel']:setString(Str('No. {1}', number)) end
    if (vars['userLabel']) then vars['userLabel']:setString(nick_name) end
    if (vars['scoreLabel']) then vars['scoreLabel']:setString(comma_value(score)) end


    do -- 리더 드래곤 아이콘
        local dragon_id = leader_info['did']
        local transform = leader_info['transform']
        local evolution = transform and transform or leader_info['evolution']
        local icon = IconHelper:getDragonIconFromDid(dragon_id, evolution, 0, 0)
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        icon:setFlippedX(true)
        vars['dragonNode']:addChild(icon)
    end

end
