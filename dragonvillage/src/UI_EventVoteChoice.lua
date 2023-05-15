local PARENT = UI

-------------------------------------
-- class UI_EventVoteChoice
-------------------------------------
UI_EventVoteChoice = class(PARENT,{
    m_selectDidList = 'List<Number>',
    m_selectDragonUIList = 'List<UI_EventVoteDragonCard>',
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
    self.m_selectDragonUIList = {}

    do -- 선택된 드래곤 카드
        for i = 1,5 do
            local str = string.format('itemNode%d',i)
            local ui = UI_EventVoteDragonCard()

            local select_cb = function ()
                local did = ui:getDragonDid()
                if did ~= 0 then
                    self:delete_vote(i)
                    self:refresh()
                end
            end

            ui.vars['cancelBtn']:registerScriptTapHandler(select_cb)
            vars[str]:removeAllChildren()
            vars[str]:addChild(ui.root)
            table.insert(self.m_selectDragonUIList, ui)
        end
    end
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
            if self:select_vote(did) == true then
                self:refresh()
            end 
        end)

        -- 꾹 눌렀을 떄 
        card_ui.vars['clickBtn']:registerScriptPressHandler(function ()
            UI_BookDetailPopup.openWithFrame(did, 7, 3, 1, true)
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

    do -- 투표권 갯수
        local vote_count = g_userData:get('event_vote_ticket')
        vars['numberLabel1']:setStringArg(comma_value(vote_count))
    end
    
    do -- 선택 갯수
        local select_count = #self.m_selectDidList
        vars['ticketLabel']:setStringArg(comma_value(select_count))
    end
    
    do -- 선택 드래곤 카드
        for i = 1,5 do
            local did = self.m_selectDidList[i]
            local ui = self.m_selectDragonUIList[i]
            if ui:getDragonDid() ~= did then
                ui:setDragonDid(did)
                ui:refresh()
            end
        end
    end

--[[     do -- 드래곤 리스트
        local l_card = self.m_tableViewTD.m_itemList
        for i, t_data in ipairs(l_card) do
            if (t_data['ui']) then
                local card_ui = t_data['ui']
                local did = card_ui.m_dragonData.did
                local is_selelct_visible = self:isVoteSelectDid(did)
                card_ui:setCheckSpriteVisible(is_selelct_visible)
            end
        end
    end ]]
end

-------------------------------------
-- function select_vote
-------------------------------------
function UI_EventVoteChoice:select_vote(did)
    local vote_count = g_userData:get('event_vote_ticket')
    if #self.m_selectDidList + 1 > vote_count then
        UIManager:toastNotificationRed(Str('투표권이 부족합니다.'))
        return false
    end

    if #self.m_selectDidList + 1 > 5 then
        UIManager:toastNotificationRed(Str('한번에 최대 5마리까지 투표 가능합니다.'))
        return false
    end

    table.insert(self.m_selectDidList, did)
    return true
end

-------------------------------------
-- function delete_vote
-------------------------------------
function UI_EventVoteChoice:delete_vote(idx)
    --local is_selected, idx = self:isVoteSelectDid(did)
    table.remove(self.m_selectDidList, idx)
    return true
end

-------------------------------------
-- function click_voteBtn
-------------------------------------
function UI_EventVoteChoice:click_voteBtn()
    if g_hotTimeData:isActiveEvent('event_vote') == false then
        MakeSimplePopup(POPUP_TYPE.OK, Str('이벤트가 종료되었습니다.'))
        return
    end

    -- 한마리도 선택 안함
    if #self.m_selectDidList == 0 then
        UIManager:toastNotificationRed(Str('드래곤을 선택해주세요.'))
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
    if g_hotTimeData:isActiveEvent('event_vote') == false then
        MakeSimplePopup(POPUP_TYPE.OK, Str('이벤트가 종료되었습니다.'))
        return
    end

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