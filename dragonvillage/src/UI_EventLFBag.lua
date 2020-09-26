local PARENT = UI

-------------------------------------
-- class UI_EventLFBag
-------------------------------------
UI_EventLFBag = class(PARENT,{
        m_structLFBag = 'structEventLFBag',

        m_tableViewCumReward = 'UIC_TableView',
        m_tableViewReward = 'UIC_TableView',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventLFBag:init()
    local vars = self:load('event_lucky_fortune_bag.ui')

    self.m_structLFBag = g_eventLFBagData:getLFBag()

    self:initUI()
    self:initButton()
    self:refresh()

    -- touch 먹히도록 함
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
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['rankBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)

    vars['packageBtn']:registerScriptTapHandler(function() self:click_packageBtn() end)

    vars['stopBtn']:registerScriptTapHandler(function() self:click_stopBtn(false) end)
    vars['recieveBtn']:registerScriptTapHandler(function() self:click_stopBtn(true) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventLFBag:refresh()
    local vars = self.vars
    
    -- 보유 수
    local count_str = Str('{1}개', self.m_structLFBag:getCount())
    vars['numberLabel']:setString(count_str)

    -- 레벨
    local lv_str = Str('복주머니') .. ' ' .. string.format('Lv.%d', self.m_structLFBag:getLv())
    vars['levelLabel']:setString(lv_str)

    -- 최고레벨 여부
    local is_max = self.m_structLFBag:isMax()
    vars['completeSprite']:setVisible(is_max)
    vars['recieveBtn']:setVisible(is_max)
    vars['stopBtn']:setVisible(not is_max)

    -- 확률
    local prob_str = is_max and '' or Str('성공 확률 {1}%', self.m_structLFBag:getSuccessProb())
    vars['percentageLabel']:setString(prob_str)

    -- 현재 레벨의 보상 목록
    self.m_tableViewReward:clearItemList()
    self.m_tableViewReward:setItemList(self.m_structLFBag:getRewardList())

    -- 누적 보상 목록
    self.m_tableViewCumReward:clearItemList()
    self.m_tableViewCumReward:setItemList(self.m_structLFBag:getCumulativeRewardList())
end

-------------------------------------
-- function update
-------------------------------------
function UI_EventLFBag:update(dt)
    if (self.m_structLFBag == nil) then
        time_label:setString('')
    end
    
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
    tableView.m_defaultCellSize = cc.size(50, 50 + 5)
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
-- function makeRewardTableView
-------------------------------------
function UI_EventLFBag:makeRewardTableView()
    local vars = self.vars
    
    if (self.m_tableViewCumReward) then
        self.m_tableViewCumReward:destroy()
    end
    if (self.m_tableViewReward) then
        self.m_tableViewReward:destroy()
    end

    vars['cumRewardListNode']:removeAllChildren()
    vars['rewardListNode']:removeAllChildren()

    self.m_tableViewCumReward = self:makeTableView(vars['cumRewardListNode'])
    self.m_tableViewReward = self:makeTableView(vars['rewardListNode'])
end

-------------------------------------
-- function click_openBtn
-------------------------------------
function UI_EventLFBag:click_openBtn()
    -- 복주머니 체크
    if (self.m_structLFBag:isMax()) then
        UIManager:toastNotificationRed(Str('복주머니의 최대 레벨입니다.'))
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
                UIManager:toastNotificationGreen(Str('성공') .. '!')
                UIManager:toastNotificationGreen(Str('레벨이 증가했습니다.'))

            -- 실패
            else
                UIManager:toastNotificationRed(Str('실패') .. '!')
                UIManager:toastNotificationRed(Str('복주머니가 초기화됩니다.'))
                if (ret['added_items']) then
                    local l_item = ret['added_items']['items_list']
                    UI_ObtainPopup(l_item)
                    self:makeRewardTableView()
                end
                SoundMgr:playEffect('UI', 'ui_in_item_get')
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
-- function click_stopBtn
-------------------------------------
function UI_EventLFBag:click_stopBtn(is_max)
    if (self.m_structLFBag:getLv() == 1) then
        UIManager:toastNotificationRed(Str('수령할 누적 보상이 없습니다.'))
        return
    end

    local msg
    if (is_max) then
        msg = Str('축하합니다! 누적 보상을 수령하시겠습니까?')
    else
        msg = Str('복주머니를 포기하고 현재까지의 누적 보상을 수령하시겠습니까?')
    end

    local function ok_btn_cb()
        local function finish_cb(ret)
            if (ret['added_items']) then
                UIManager:toastNotificationGreen(Str('보상이 지급되었습니다'))
                self:makeRewardTableView()
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
    MakePopup('event_lucky_fortune_bag_info_popup.ui')
end

-------------------------------------
-- function click_packageBtn
-------------------------------------
function UI_EventLFBag:click_packageBtn()
    UI_Package_Bundle('package_lucky_fortune_bag', true)
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_EventLFBag:click_rankBtn()
    require('UI_EventLFBagRankingPopup')
    UI_EventLFBagRankingPopup()
end


-------------------------------------
-- function makeCellUI
-------------------------------------
function UI_EventLFBag.makeCellUI(t_data)
    local cell_ui = UI_ItemCard(t_data['item_id'], t_data['count'])
    cell_ui.root:setScale(50/150)
    return cell_ui
end