local PARENT = UI

-------------------------------------
-- class UI_ClanwarRewardInfoPopup
-------------------------------------
UI_ClanwarRewardInfoPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanwarRewardInfoPopup:init(is_league, my_rank)
    local vars = self:load('clan_war_reward_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
	self:initUI(is_league, my_rank)
	self:initButton()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanwarRewardInfoPopup')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanwarRewardInfoPopup:initUI(is_league, _my_rank)
    local vars = self.vars
    local my_rank = _my_rank or 0

    -- 클랜전 보상 정보만
    -- 32부터라면, 32강까지만, 그룹 보상이 4위부터면 4위까지만
    local max_round = g_clanWarData:getMaxRound()
    local max_clan_group = g_clanWarData:getMaxGroup()
    local l_item_list = {}
    for rank_id, t_data in pairs(TABLE:get('table_clan_reward')) do
        if (t_data['category'] == 'clanwar_league') then
            if (t_data['rank_max'] <= max_clan_group) then
                table.insert(l_item_list, t_data)
            end
        end

        if (t_data['category'] == 'clanwar_tournament') then
            if (t_data['rank_max'] <= max_round) then
                table.insert(l_item_list, t_data)
            end
        end
    end

    -- 테이블 정렬
    table.sort(l_item_list, function(a, b)
        return tonumber(a['rank_id']) < tonumber(b['rank_id'])
    end)

    -- 조별리그 1-2등은 토너먼트 랭크에 포커싱
    local category = 'clanwar_tournament'
    if (is_league) then
        if (my_rank <= 2) then
            my_rank = max_round
        else
            category = 'clanwar_league'
        end
    end

    local create_func = function(ui, data)
        if (data['category'] == category) then
            ui.vars['meSprite']:setVisible(true)
        end
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['listNode'])
    table_view.m_defaultCellSize = cc.size(550, 52 + 5)
	table_view:setCellUIClass(UI_ClanwarRewardInfoPopupList)
	table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    local focus_idx = 0
    for i, t_data in ipairs(l_item_list) do
        if (t_data['category'] == category) then
            if (t_data['rank_min'] <= my_rank) and (t_data['rank_max'] >= my_rank) then
                focus_idx = i
                break
            end
        end
    end

    table_view:update(0)
    table_view:relocateContainerFromIndex(focus_idx)

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end












local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanwarRewardInfoPopupList
-------------------------------------
UI_ClanwarRewardInfoPopupList = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanwarRewardInfoPopupList:init(data)
    local vars = self:load('clan_war_reward_info_popup_item.ui')
    
	self:initUI(data)
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanwarRewardInfoPopupList:initUI(data)
    local vars = self.vars

    -- 랭킹
    local rank = data['t_name']
    vars['rankLabel']:setString(Str(rank))
    
    -- 보상1
    local reward = data['reward']
    local l_reward = pl.stringx.split(reward, ';')
    if (l_reward[2]) then
        vars['rewardLabel1']:setString(l_reward[2])
    end

    -- 보상2
    local clan_exp = data['clan_exp']
    vars['rewardLabel2']:setString(clan_exp)
end
