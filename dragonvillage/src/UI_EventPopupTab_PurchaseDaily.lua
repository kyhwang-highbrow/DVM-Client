local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_PurchaseDaily
-------------------------------------
UI_EventPopupTab_PurchaseDaily = class(PARENT,{
        m_eventVersion = '',
        
        m_rewardBoxUIList = '',

        m_todayRewardUI = 'UI',
        
        m_tabButtonCallback = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:init(event_version, is_full_popup)
    self.m_eventVersion = event_version
    self:load('event_purchase_daily.ui')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(is_full_popup)
    self:initButton()
    self:refresh()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:initUI(is_full_popup)
    local vars = self.vars

    local version = self.m_eventVersion
    local step_count = g_purchaseDailyData:getTotalStep(version)

    self.m_rewardBoxUIList = {}
    
    -- 보상 아이템 카드 UI 생성
    for step = 1, step_count do
        local item_node = vars['itemNode'..step]
        if item_node then
            item_node:setVisible(true)
            
            -- 선물 박스 프레임
            local ui_frame = UI()
            ui_frame:load('event_purchase_daily_item_01.ui')
            ui_frame.vars['rewardInfoBtn']:registerScriptTapHandler(function() self:click_rewardInfoBtn(step) end)
            ui_frame.vars['receiveBtn']:registerScriptTapHandler(function() self:click_receiveBtn(step) end)
            ui_frame.vars['dayLabel']:setString(g_purchaseDailyData.LocalizedOrdinalDay(step))
            item_node:addChild(ui_frame.root)
            
            table.insert(self.m_rewardBoxUIList, ui_frame)

        end
    end

    -- 현재 스텝의 보상 정보 UI 생성
    local curr_reward_node = vars['listNode']
    if (curr_reward_node) then
        local ui_today_reward = UI()
        ui_today_reward:load('event_purchase_daily_item_02.ui')
        ui_today_reward.vars['shopBtn']:registerScriptTapHandler(function()
            UINavigatorDefinition:goTo('package_shop', nil, function() self:refresh() end)
            --g_shopData:openShopPopup(nil, function() self:refresh() end)
        end)

        if (is_full_popup == true) then
            ui_today_reward.vars['shopBtn']:setVisible(false)
        end
        
        self.m_todayRewardUI = ui_today_reward
        
        curr_reward_node:addChild(ui_today_reward.root)
    end

    -- 개별 선물 상자 보상 UI 숨김
    vars['rewardInfoNode']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:initButton()
    local vars = self.vars
    vars['infoBtn']:registerScriptTapHandler(function() UI_GuidePopup_PurchasePoint('event_purchase_daily_popup.ui') end) 
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:refresh()
    local vars = self.vars
    local version = self.m_eventVersion

    -- 누적 결제 점수
    local purchase_point = g_purchaseDailyData:getPurchasePoint(version)
    local str = Str('누적 결제 점수: {1}점', comma_value(purchase_point))
    vars['scoreLabel']:setString(str)

    -- 누적 결제 남은 시간 안내
    local time_str = g_purchaseDailyData:getPurchasePointEventRemainTimeText(version)
    vars['timeLabel']:setString(time_str)

    
    -- 오늘의 보상 진행 정보 안내 문구
    local curr_step = g_purchaseDailyData:getCurrentStep(version)
    local target_point = g_purchaseDailyData:getTargetPoint(version, curr_step)
    local pos_x, _ = vars['itemNode' .. curr_step]:getPosition()
    vars['todaySprite']:setPositionX(pos_x)

    -- 현재 점수 안내 문구 1
    local info_text
    local width
    local info_pos_x
    if (g_purchaseDailyData:canCollectPoint(version)) then
        info_text = Str('오늘 {@yellow}{1}{@default}점을 달성했습니다. {@yellow}{2}{@default}점을 더 달성하고 추가 보상을 받으세요!', purchase_point, target_point - purchase_point)
        width = 850
        info_pos_x = 0
    else
        info_text = Str('완료')
        width = 100
        info_pos_x = pos_x
    end
    vars['infoSprite']:setContentSize(width, 40)
    vars['infoSprite']:setPositionX(info_pos_x)
    vars['infoLabel']:setString(info_text)
    vars['infoLabel']:setDimension(width, 40)
    vars['infoLabel']:setPositionX(0)
    
    -- 현재 점수 안내 문구 2
    vars['boxInfoLabel']:setString(Str('매일 결제 점수 {@yellow}{1}{@default}점 달성 시 선물상자 추가 증정!', comma_value(target_point)))

    self:refreshCurrentStepReward()
    self:refresh_rewardBoxUIList()
end

-------------------------------------
-- function update
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:update(dt)
    local vars = self.vars

    -- 서버 시간 표시
    local time_zone_str, t = datetime.getTimeUTCHourStr()
    local hour = string.format('%.2d', t.hour)
    local min = string.format('%.2d', t.min)
    local sec = string.format('%.2d', t.sec)
    local str = Str('서버 시간 : {1}시 {2}분 {3}초 ({4})', hour, min, sec, time_zone_str)
    vars['serverTimeLabel']:setString(str)
end

-------------------------------------
-- function refreshCurrentStepReward
-- @breif 현재 스텝의 상세 보상 정보 출력
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:refreshCurrentStepReward()
    if (not self.m_todayRewardUI) then
        return
    end

    -- 현재 스텝의 상세 보상 정보
    local curr_step = g_purchaseDailyData:getCurrentStep(self.m_eventVersion)
    local reward_list = g_purchaseDailyData:getRewardList(self.m_eventVersion, curr_step)
    for i, t_item in ipairs(reward_list) do
        -- 아이템 카드
        local ui_card = UI_ItemCard(t_item['item_id'], t_item['count'])
        ui_card.root:setScale(0.7)
        self.m_todayRewardUI.vars['rewardNode' .. i]:removeAllChildren(true)
        self.m_todayRewardUI.vars['rewardNode' .. i]:addChild(ui_card.root)
    end
end

-------------------------------------
-- function refresh_rewardBoxUIList
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:refresh_rewardBoxUIList()
    if (not self.m_rewardBoxUIList) then
        return
    end

    local curr_step = g_purchaseDailyData:getCurrentStep(self.m_eventVersion)
    local clear_step = g_purchaseDailyData:getClearStep(self.m_eventVersion)

    for step, ui in pairs(self.m_rewardBoxUIList) do
        local vars = ui.vars

        -- 현재 스텝 표시
        vars['todaySprite']:setVisible(step == curr_step)

        -- 획득 완료
        if (g_purchaseDailyData:isRewardReceived(self.m_eventVersion, step)) then
            vars['checkSprite']:setVisible(true)
            vars['receiveBtn']:setVisible(false)
            vars['rewardInfoBtn']:setVisible(false)
            vars['todaySprite']:setVisible(false)
            vars['boxVisual']:changeAni('box_0' .. step .. '_reward_after', true)

        -- 획득 가능한 상태
        else
            vars['checkSprite']:setVisible(false)
            
            -- 클리어 하여 보상 수령 가능
            if (clear_step >= step) then
                vars['boxVisual']:changeAni('box_0' .. step .. '_move', true)
                vars['receiveBtn']:setVisible(true)
                vars['rewardInfoBtn']:setVisible(false)

            -- 클리어 하지 못함
            else
                vars['boxVisual']:changeAni('box_0' .. step, true)
                vars['receiveBtn']:setVisible(false)
                vars['rewardInfoBtn']:setVisible(true)
            end
        end
    end
end

local mRewardDirecting = false
-------------------------------------
-- function click_receiveBtn
-- @brief
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:click_receiveBtn(reward_step)
    -- 연출 중 다시 버튼이 눌리는 경우를 막음
    if (mRewardDirecting) then
        return
    end

    mRewardDirecting = true

    -- 보상 수령
    local version = self.m_eventVersion
    local function cb_func(ret)
        -- 보상 획득
        ItemObtainResult(ret)

        -- 보상 수령 연출
        local ui = self.m_rewardBoxUIList[reward_step]
        ui.vars['boxVisual']:changeAni('box_0' .. reward_step .. '_reward')
        ui.vars['boxVisual']:addAniHandler(function() 
            mRewardDirecting = false
            self:refresh()
        end)

        if self.m_tabButtonCallback then
            self.m_tabButtonCallback()
        end
    end
    g_purchaseDailyData:request_purchasePointReward(version, reward_step, cb_func)
end

-------------------------------------
-- function click_rewardInfoBtn
-- @brief
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:click_rewardInfoBtn(tar_step)
    local vars = self.vars

    -- 화면 터치 시 개별 상자 보상 UI 숨김 처리를 위한 터치 레이어
    local visible_off_layer = UI()
	visible_off_layer:load('empty.ui')
    local function touch_func(touch, event)
        -- 숨기고 터치 레이어는 삭제
		vars['rewardInfoNode']:setVisible(false)
        visible_off_layer.root:removeFromParent(true)
	end
	UIManager:makeSkipLayer(visible_off_layer, touch_func)
    self.root:addChild(visible_off_layer.root)
    
    -- 보상 UI On
    local reward_info_node = vars['rewardInfoNode']
    reward_info_node:setVisible(true)

    -- 보상 UI 위치 설정
    local pos_x, _ = vars['itemNode' .. tar_step]:getPosition()
    reward_info_node:setPositionX(pos_x)

    -- 상세 보상 정보 출력
    local reward_list = g_purchaseDailyData:getRewardList(self.m_eventVersion, tar_step)
    for i, t_item in ipairs(reward_list) do
        -- 아이템 카드
        local ui_card = UI_ItemCard(t_item['item_id'], t_item['count'])
        --ui_card.root:setScale(0.7)
        vars['infoItemNode' .. i]:removeAllChildren(true)
        vars['infoItemNode' .. i]:addChild(ui_card.root)

        vars['itemLabel' .. i]:setString(TableItem:getItemName(t_item['item_id']))
    end
end

















--@CHECK
UI:checkCompileError(UI_EventPopupTab_PurchaseDaily)