local PARENT = UI

-------------------------------------
-- class UI_ClanwarRewardInfoPopup
-------------------------------------
UI_ClanwarRewardInfoPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanwarRewardInfoPopup:init()
    local vars = self:load('clan_war_reward_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
	self:initUI()
	self:initButton()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanwarRewardInfoPopup')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanwarRewardInfoPopup:initUI()
    local vars = self.vars
    
    -- 클랜전 보상 정보만 빼온다.
    local l_item_list = {}
    for rank_id, t_data in pairs(TABLE:get('table_clan_reward')) do
        if (t_data['category'] == 'clanwar_league') or (t_data['category'] == 'clanwar_tournament') then
            table.insert(l_item_list, t_data)
        end
    end

    -- 테이블 정렬
    table.sort(l_item_list, function(a, b)
        return tonumber(a['rank_id']) < tonumber(b['rank_id'])
    end)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['listNode'])
    table_view.m_defaultCellSize = cc.size(550, 52 + 5)
	table_view:setCellUIClass(UI_ClanwarRewardInfoPopupList)
	table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

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
