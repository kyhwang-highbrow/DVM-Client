local PARENT = UI

-------------------------------------
-- class UI_EventVoteChoice
-------------------------------------
UI_EventVoteChoice = class(PARENT,{
    m_selectDidList = 'List<Number>',
    m_tableViewTD  = 'UIC_TableViewTD',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventVoteChoice:init()
    self.m_selectDidList = {}
    local vars = self:load('event_vote_ticket_choice.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventVoteChoice')

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
function UI_EventVoteChoice:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventVoteChoice:initTableView()
    local node = self.vars['listNode']
    self.vars['listNode']:removeAllChildren()

    local l_item_list = g_eventVote:getDragonList()

	-- cell_size 지정
    local item_scale = 0.52
    local cell_size = cc.size(80, 80)

    -- 리스트 아이템 생성 콜백
    local function create_func(data)
        local did = data
		local t_data = {['evolution'] = 3, ['grade'] = 7}
        
        local card_ui = MakeSimpleDragonCard(did, t_data)
		card_ui.root:setScale(item_scale)

		-- 선택 클릭
		card_ui.vars['clickBtn']:registerScriptTapHandler(function() 
            local is_selelct_visible = self:click_selectBtn(did)
            card_ui:setCheckSpriteVisible(is_selelct_visible)
            self:refresh()
          end)

        return card_ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cell_size
    table_view_td.m_nItemPerCell = 11
	table_view_td:setCellUIClass(create_func)
	table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:setItemList(l_item_list)

    -- 정렬
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventVoteChoice:initButton()
    local vars = self.vars
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['voteBtn']:registerScriptTapHandler(function() self:click_voteBtn() end)
    vars['rankingBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)
end

-------------------------------------
-- function isVoteSelectDid
-------------------------------------
function UI_EventVoteChoice:isVoteSelectDid(did)

    local idx = table.find(self.m_selectDidList, did)
    if idx ~= nil then
        return true, idx
    end

    return false, idx
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventVoteChoice:refresh()
    local vars = self.vars

    -- 투표권 갯수
    do
        local vote_count = g_userData:get('event_vote_ticket')
        vars['numberLabel1']:setStringArg(comma_value(vote_count))
    end

    -- 선택 갯수
    do
        local select_count = #self.m_selectDidList
        vars['ticketLabel']:setStringArg(comma_value(select_count))
    end
end

-------------------------------------
-- function click_selectBtn
-------------------------------------
function UI_EventVoteChoice:click_selectBtn(did)
    local is_selected, idx = self:isVoteSelectDid(did)

    -- 셀렉트 되었으면 지움
    if is_selected == true then
        table.remove(self.m_selectDidList, idx)
        return false
    else

        local vote_count = g_userData:get('event_vote_ticket')
        if #self.m_selectDidList + 1 > vote_count then
            UIManager:toastNotificationRed(Str('더 이상 선택이 불가능합니다.'))
            return
        end

        if #self.m_selectDidList + 1 > 5 then
            UIManager:toastNotificationRed(Str('한번에 최대 5마리까지 투표 가능합니다.'))
            return
        end

        table.insert(self.m_selectDidList, did)
        return true
    end
end

-------------------------------------
-- function click_voteBtn
-------------------------------------
function UI_EventVoteChoice:click_voteBtn()
    -- 한마리도 선택 안함
    if #self.m_selectDidList == 0 then
        UIManager:toastNotificationRed(Str('최소 한 마리 이상 선택해주세요.'))
        return
    end

    local ui = UI_EventVoteChoiceConfirmPopup.open(self.m_selectDidList)
    ui:setCloseCB(function () 
        self.m_selectDidList = {}
        self:initTableView()
        self:refresh()
    end)
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_EventVoteChoice:click_rankBtn()
    UI_EventVoteRanking.open()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventVoteChoice:click_closeBtn()
    self:close()
end

-------------------------------------
-- function open
-------------------------------------
function UI_EventVoteChoice.open()
    return UI_EventVoteChoice()
end