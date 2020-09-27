local PARENT = UI

-------------------------------------
-- class UI_EventLFBag
-------------------------------------
UI_EventLFBag = class(PARENT,{
        m_structLFBag = 'structEventLFBag',

        m_tableViewCumReward = 'UIC_TableView',
        m_tableViewReward = 'UIC_TableView',

        m_toastUI = 'cc.Node',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventLFBag:init()
    local vars = self:load('event_lucky_fortune_bag.ui')

    self.m_structLFBag = g_eventLFBagData:getLFBag()
    self.m_toastUI = self:makeToast()

    self:initUI()
    self:initButton()
    self:refresh()

    -- UI 설정
    self:setOpacityChildren(true)
    self:setSwallowTouch()
    self:startUpdate(function(dt) self:update(dt) end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventLFBag:initUI()
    local vars = self.vars

    self:makeRewardTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventLFBag:initButton()
    local vars = self.vars

    vars['openBtn']:registerScriptTapHandler(function() self:click_openBtn() end)
    vars['stopBtn']:registerScriptTapHandler(function() self:click_stopBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['rankBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)

    vars['packageBtn']:registerScriptTapHandler(function() self:click_packageBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventLFBag:refresh()
    local vars = self.vars
    
    -- 보유 수
    local count_str = self.m_structLFBag:getCount()
    vars['numberLabel']:setString(count_str)

    -- 레벨
    local lv = self.m_structLFBag:getLv()
    vars['levelLabel']:setString(Str('복주머니 {1}단계', lv))

    -- 최대 레벨 처리 .. 열기 버튼으로 보상을 수령한다.
    if self.m_structLFBag:isMax() then
        vars['openLabel']:setString(Str('수령하기'))
        vars['percentageLabel']:setString('')
    else
        vars['openLabel']:setString(Str('{1}단계 열기', lv))
        vars['percentageLabel']:setString(Str('성공 확률 {1}%', self.m_structLFBag:getSuccessProb()))
    end
    
    -- 현재 레벨의 보상 목록
    self.m_tableViewReward:setItemList(self.m_structLFBag:getRewardList())

    -- 누적 보상 목록
    local l_cum_reward_list = self.m_structLFBag:getCumulativeRewardList()
    for i = 1, 10 do
        vars['itemNode' .. i]:removeAllChildren()

        local t_item = l_cum_reward_list[i]
        if (t_item) then
            local card_ui = MakeItemCard(t_item)
            vars['itemNode' .. i]:addChild(card_ui.root)
        end
    end
    
    -- 복주머니 애니메이션 4,3,2,1
    local lfbag_ani_lv
    if (lv == 10) then
        lfbag_ani_lv = 4
    elseif (lv >= 8) then
        lfbag_ani_lv = 3
    elseif (lv >= 5) then
        lfbag_ani_lv = 2
    else
        lfbag_ani_lv = 1
    end
    vars['luckyFortuneBagVisual']:changeAni(string.format('bag_%.2d', lfbag_ani_lv), true)
end

-------------------------------------
-- function update
-------------------------------------
function UI_EventLFBag:update(dt)
    if (self.m_structLFBag == nil) then
        time_label:setString('')
    end
    
    -- 남은 시간
    local time_label = self.vars['timeLabel']
    if time_label then
        local curr_time = Timer:getServerTime()
        local end_time = self.m_structLFBag:getEndTime()
        if (0 < end_time) and (curr_time < end_time) then
            local remain_time = (end_time - curr_time)
            local str = Str('{1} 남음', datetime.makeTimeDesc(remain_time, true))
            time_label:setString(str)
        else
            time_label:setString('')
        end
    end
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_EventLFBag:makeTableView(node)
    -- 테이블 뷰 인스턴스 생성
    local tableView = UIC_TableView(node)
    tableView.m_defaultCellSize = cc.size(200, 50 + 3)
    tableView:setCellUIClass(self.makeCellUI)
    tableView:setCellCreateDirecting(99--[[연출 제외]])
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    return tableView
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventLFBag:onEnterTab()
    self:refresh()
end

-------------------------------------
-- function reset
-------------------------------------
function UI_EventLFBag:reset()
    self:makeRewardTableView()
end

-------------------------------------
-- function showCurrntReward
-------------------------------------
function UI_EventLFBag:showCurrntReward(item_str)
    local vars = self.m_toastUI.vars

    local l_item_list = g_itemData:parsePackageItemStr(item_str)
    local t_item = l_item_list[1]

    -- 정보 입력
    local item_id = t_item['item_id']
    vars['itemNode']:addChild(IconHelper:getItemIcon(item_id))
    local item_count_str = string.format('%s x%s', TableItem:getItemName(item_id), comma_value(t_item['count']))
    vars['itemLabel']:setString(item_count_str)

	cca.fadeInDelayOut(self.m_toastUI.root, 0.1, 0.5, 0.3)
end

-------------------------------------
-- function makeRewardTableView
-------------------------------------
function UI_EventLFBag:makeRewardTableView()
    local vars = self.vars
    
    -- 현재 보상 테이블 새로 생성
    if (self.m_tableViewReward) then
        self.m_tableViewReward:destroy()
    end
    vars['rewardListNode']:removeAllChildren()
    self.m_tableViewReward = self:makeTableView(vars['rewardListNode'])
end

-------------------------------------
-- function makeToast
-------------------------------------
function UI_EventLFBag:makeToast()
    local ui = UI()   
    ui:load('popup_toast_with_icon.ui')
    ui:setOpacityChildren(true)
    ui.root:setOpacity(0)
    self.root:addChild(ui.root)
    return ui
end

-------------------------------------
-- function click_openBtn
-------------------------------------
function UI_EventLFBag:click_openBtn()
    if (self.m_structLFBag:isMax()) then
        self:receiveMaxReward()
        return
    end

    -- 조건 체크
    if (not g_eventLFBagData:canPlay()) then
        UIManager:toastNotificationRed(Str('이벤트가 종료되었습니다.'))
        return

    elseif (not self.m_structLFBag:canStart()) then
        UIManager:toastNotificationRed(Str('복주머니가 부족합니다.'))
        return
    end

    -- 복주머니 열기
    local function do_open()
        local function finish_cb(ret)
            -- 성공
            if (ret['is_success']) then
                SoundMgr:playEffect('UI', 'ui_in_item_get')
                
                UIManager:toastNotificationGreen(Str('성공') .. '!')
                UIManager:toastNotificationGreen(Str('레벨이 증가했습니다.'))

                -- 이번 성공으로 획득한 보상
                if (ret['item_info']) then
                    self:showCurrntReward(ret['item_info'])
                end

            -- 실패
            else
                SoundMgr:playEffect('UI', 'ui_eat')
                
                UIManager:toastNotificationRed(Str('실패') .. '!')
                UIManager:toastNotificationRed(Str('복주머니가 초기화됩니다.'))
                
                -- 보상 수령
                if (ret['new_mail']) then
                    self:reset()
                end
            end

            self:refresh()
        end    
        g_eventLFBagData:request_eventLFBagOpen(finish_cb)
    end

    -- 누적보상 받지 못할 리스크가 있는 경우
    if (self.m_structLFBag:hasRisk()) then
        local msg = Str('이번에 실패할 경우, 누적 보상을 수령할 수 없습니다. 복주머니를 여시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, do_open)
    else
        do_open()
    end
end

-------------------------------------
-- function receiveMaxReward
-------------------------------------
function UI_EventLFBag:receiveMaxReward()
    local msg = Str('축하합니다! 누적 보상을 수령하시겠습니까?')
    local function ok_btn_cb()
        local function finish_cb(ret)
            -- 보상 수령
            if (ret['new_mail']) then
                self:reset()
            end

            self:refresh()
        end
        g_eventLFBagData:request_eventLFBagReward(finish_cb)
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb)
end

-------------------------------------
-- function click_stopBtn
-------------------------------------
function UI_EventLFBag:click_stopBtn()
    if (self.m_structLFBag:isMax()) then
        self:receiveMaxReward()
        return
    end

    -- 조건 체크
    if (not g_eventLFBagData:canPlay()) then
        UIManager:toastNotificationRed(Str('이벤트가 종료되었습니다.'))
        return
    
    elseif (self.m_structLFBag:getLv() == 1) then
        UIManager:toastNotificationRed(Str('수령할 누적 보상이 없습니다.'))
        return
    end

    local msg = Str('복주머니를 포기하고 현재까지의 누적 보상을 수령하시겠습니까?')
    local function ok_btn_cb()
        local function finish_cb(ret)
            -- 보상 수령
            if (ret['new_mail']) then
                self:reset()
            end

            self:refresh()
        end
        g_eventLFBagData:request_eventLFBagReward(finish_cb)
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_EventLFBag:click_infoBtn()
    local ui = MakePopup('event_lucky_fortune_bag_info_popup.ui')
    local vars = ui.vars
    vars['descLabel01']:setString(Str('복주머니 열기를 하면, 성공하거나 실패할 수 있습니다.'))
    vars['descLabel02']:setString(Str('열기에 성공하면 보상이 누적되며, 복주머니의 단계가 증가합니다.'))
    vars['descLabel03']:setString(Str('{1}단계 이하에서 열기에 실패하면 이전 단계까지의 누적 보상을 받고, 복주머니의 단계가 초기화됩니다.', 7))
    vars['descLabel04']:setString(Str('{@yellow}{1}단계 이상에서 열기에 실패하면 누적된 모든 보상을 받을 수 없습니다.', 8))
    vars['descLabel05']:setString(Str('중단을 하면 확보한 누적 보상을 받을 수 있으며, 복주머니의 단계가 초기화됩니다.'))
    vars['descLabel06']:setString(Str('복주머니는 주사위 이벤트, 상점을 통해 획득할 수 있습니다.'))
    vars['descLabel07']:setString(Str('복주머니를 열어 {@yellow}획득한 점수에 따라 랭킹 보상을 지급합니다.'))

end

-------------------------------------
-- function click_packageBtn
-------------------------------------
function UI_EventLFBag:click_packageBtn()
    local ui = UI_Package_Bundle('package_lucky_fortune_bag', true)

    local function buy_cb()
        UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.ITEM, function() self:refresh() end)
    end
    ui:setBuyCB(buy_cb)
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_EventLFBag:click_rankBtn()
    UI_EventLFBagRankingPopup()
end


-------------------------------------
-- function makeCellUI
-------------------------------------
function UI_EventLFBag.makeCellUI(t_data)
    local cell_ui = class(UI, ITableViewCell:getCloneTable())()
    local vars = cell_ui:load('event_lucky_fortune_bag_item.ui')

    vars['itemNode']:addChild(IconHelper:getItemIcon(t_data['item_id']))
    vars['probLabel']:setString(string.format('%d%%', t_data['pick_weight']))
    vars['countLabel']:setString(comma_value(t_data['val']))

    return cell_ui
end