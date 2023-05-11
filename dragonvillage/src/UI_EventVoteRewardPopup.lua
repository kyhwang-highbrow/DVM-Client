local PARENT = UI

-------------------------------------
-- class UI_EventVoteRewardPopup
-------------------------------------
UI_EventVoteRewardPopup = class(PARENT,{
    m_itemList = 'List<Table>',
    m_tableViewTD  = 'UIC_TableViewTD',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventVoteRewardPopup:init(t_item_list)
    self.m_itemList = t_item_list

    local vars = self:load('event_vote_ticket_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventVoteRewardPopup')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:initTableView()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventVoteRewardPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventVoteRewardPopup:initTableView()
    local node = self.vars['rewardListNode']
    local l_item_list = self.m_itemList

	-- cell_size 지정
    local cell_size = 1 --cc.size(80, 80)
    local item_scale = 0.8

    -- 리스트 아이템 생성 콜백
    local function create_func(data)
        local t_item = data
        local ui = MakeItemCard(t_item)
		ui.root:setScale(item_scale)
        return ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(130, 125)
	table_view:setCellUIClass(create_func)
	table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_item_list)
    table_view:setAlignCenter(true)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventVoteRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventVoteRewardPopup:refresh()
    local vars = self.vars
end


-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventVoteRewardPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function open
-------------------------------------
function UI_EventVoteRewardPopup.open(t_item_list)
    return UI_EventVoteRewardPopup(t_item_list)
end