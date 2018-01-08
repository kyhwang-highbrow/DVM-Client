local PARENT = UI

-------------------------------------
-- class UI_PickDragon
-------------------------------------
UI_PickDragon = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PickDragon:init()
    local vars = self:load('clan_raid_reward.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_PickDragon'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_PickDragon')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:initTab()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PickDragon:initUI()
    local vars = self.vars
--    self:makeMyRank()
--    self:initTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PickDragon:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_PickDragon:initTab()
    local vars = self.vars

    self:addTabWithLabel(TAB_REWARD_FIGHT, vars['rewardTabBtn1'], vars['rewardTabLabel1'], vars['rewardNode1'])
    self:addTabWithLabel(TAB_REWARD_CLEAR, vars['rewardTabBtn2'], vars['rewardTabLabel2'], vars['rewardNode2'])
    self:addTabWithLabel(TAB_REWARD_SEASON, vars['rewardTabBtn3'], vars['rewardTabLabel3'], vars['rewardNode3'])
    self:setTab(TAB_REWARD_FIGHT)
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_PickDragon:onChangeTab(tab, first)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PickDragon:refresh()
    local vars = self.vars
    -- 종료 시간
    local status_text = g_clanRaidData:getClanRaidStatusText()
    vars['timeLabel']:setString(status_text)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_PickDragon:initTableView()
    local vars = self.vars
	local node = vars['listNode']
	local l_rank_list = self.m_rank_data

    -- 생성 콜백
    local function create_func(ui, data)

    end

	do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(1000, 100 + 5)
        table_view:setCellUIClass(UI_PickDragon.makeRankCell, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_rank_list)
    end
end

-------------------------------------
-- function makeRankCell
-------------------------------------
function UI_PickDragon.makeRankCell(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('clan_raid_rank_item.ui')
    if (not t_data) then
        return ui
    end
    if (t_data == 'next') then
        return ui
    end
    if (t_data == 'prev') then
        return ui
    end

    local struct_clan_rank = t_data

    -- 클랜 마크
    local icon = struct_clan_rank:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan_rank:getClanName()
    vars['clanLabel']:setString(clan_name)

    -- 클랜 마스터
    local clan_master = struct_clan_rank:getMasterNick()
    vars['masterLabel']:setString(clan_master)

    -- 점수
    local clan_score = struct_clan_rank:getClanScore()
    vars['scoreLabel']:setString(clan_score)
    
    -- 등수 
    local clan_rank = struct_clan_rank:getClanRank()
    vars['rankLabel']:setString(clan_rank)
    
    -- 내클랜
    if (struct_clan_rank:isMyClan()) then
        vars['mySprite']:setVisible(true)
        vars['infoBtn']:setVisible(false)
    end

    -- 정보 보기 버튼
    vars['infoBtn']:registerScriptTapHandler(function()
        local clan_object_id = struct_clan_rank:getClanObjectID()
        g_clanData:requestClanInfoDetailPopup(clan_object_id)
    end)

	return ui
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_PickDragon:click_closeBtn()
    self:close()
end