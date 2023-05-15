local PARENT = UI

-------------------------------------
-- class UI_EventVoteChoiceConfirmPopup
-------------------------------------
UI_EventVoteChoiceConfirmPopup = class(PARENT,{
    m_selectDidList = 'List<Number>',
    m_tableViewTD  = 'UIC_TableViewTD',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventVoteChoiceConfirmPopup:init(did_list)
    self.m_selectDidList = did_list

    local vars = self:load('event_vote_ticket_confirm_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_EventVoteChoiceConfirmPopup')

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
function UI_EventVoteChoiceConfirmPopup:initUI()
    local vars = self.vars
    vars['ticketLabel']:setStringArg(#self.m_selectDidList)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventVoteChoiceConfirmPopup:initTableView()
    local node = self.vars['listNode']
    local l_item_list = self.m_selectDidList

	-- cell_size 지정
    local cell_size = 1 --cc.size(80, 80)
    local item_scale = 0.8

    -- 리스트 아이템 생성 콜백
    local function create_func(data)
        local did = data
		local t_data = {['evolution'] = 3, ['grade'] = 7}
        
        local ui = MakeSimpleDragonCard(did, t_data)
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

    -- 정렬
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventVoteChoiceConfirmPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_voteBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventVoteChoiceConfirmPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_voteBtn
-------------------------------------
function UI_EventVoteChoiceConfirmPopup:click_voteBtn()
    if g_hotTimeData:isActiveEvent('event_vote') == false then
        MakeSimplePopup(POPUP_TYPE.OK, Str('이벤트가 종료되었습니다.'))
        return
    end

    local did_str = table.concat(self.m_selectDidList, ',')
    local success_cb = function (ret)
        local l_item_list = ret['mail_item_info'] or {}
        local ui = UI_EventVoteRewardPopup.open(l_item_list)
        ui:setCloseCB(function ()
            self:close()
        end)

--[[         local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg) ]]
    end

    g_eventVote:requestEventVoteDragon(did_str, success_cb)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventVoteChoiceConfirmPopup:click_closeBtn()
    self:closeWithoutCB()
end

-------------------------------------
-- function open
-------------------------------------
function UI_EventVoteChoiceConfirmPopup.open(did_list)
    return UI_EventVoteChoiceConfirmPopup(did_list)
end