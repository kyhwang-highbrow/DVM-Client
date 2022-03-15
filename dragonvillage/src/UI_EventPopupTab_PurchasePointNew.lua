local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_PurchasePointNew
-------------------------------------
UI_EventPopupTab_PurchasePointNew = class(PARENT,{
        m_eventVersion = '',
        m_rewardUIList = '',
        m_rewardBoxUIList = '',

        m_rewardList = 'table', --이벤트 보상 리스트
        m_rewardListCount = 'number',
        m_selectedLastRewardIdx = 'number', -- 선택된 마지막 보상 idx

        m_tabButtonCallback = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:init(event_version)
    self:initData(event_version)
    self:load('event_purchase_point_new.ui')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initData
-- @breif UI Class Data 초기화
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:initData(event_version)
    self.m_selectedLastRewardIdx = 1
    self.m_eventVersion = event_version
    self.m_rewardUIList = {}
    self.m_rewardBoxUIList = {}

    local version = self.m_eventVersion
    self.m_rewardList = g_purchasePointData:getPurchasePoint_rewardList(version)
    self.m_rewardListCount = g_purchasePointData:getPurchasePoint_stepCount(version)
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:initUI()
    local vars = self.vars
    local version = self.m_eventVersion
    local step_count = self.m_rewardListCount

    vars['selectLabel']:setString(Str('선택 가능한 {1}단계 보상', step_count))
    for step=1, step_count do
        local item_node = vars['itemNode'..step]
        item_node:setVisible(true)
        if item_node then
            --add Item
            local item_id, count = self:getRewardInfoByStep(version, step)
            local UI_Item = self:getUI_NewItem1(step, item_id, count)
            item_node:addChild(UI_Item.root)
            table.insert(self.m_rewardBoxUIList, UI_Item)
        end
    end

    vars['purchaseGg']:setPercentage(0)
    --프로그래스바 사이즈 수정
    local Pg_Scale = vars['purchaseGg']:getScaleX()
    Pg_Scale = (Pg_Scale/2) + (Pg_Scale * (step_count-1))
    vars['purchaseGg']:setScaleX(Pg_Scale)

    local PgBar_Scale = vars['purchaseGgSprite']:getScaleY()
    PgBar_Scale = (PgBar_Scale/2) + (PgBar_Scale * (step_count-1))
    vars['purchaseGgSprite']:setScaleY(PgBar_Scale)
    
    -- 타입에 따른 누적 결제 배경UI
    local last_reward_type = g_purchasePointData:getLastRewardType(version)
    local last_reward_item_id, count = self:getRewardInfoByStep(version, step_count)
    local ui_bg = UI_PurchasePointBgNew(last_reward_type, last_reward_item_id, count, version)
    if (ui_bg) then
        vars['productNode']:addChild(ui_bg.root)
    end

    -- 마지막 단계 보상 3개 버튼 생성
    for reward_idx=1, 3 do
        local item_id, item_cnt = self:getRewardInfoByStep(version, step_count, reward_idx)
        local ui = UI()
        ui:load('event_purchase_point_item_new_03.ui')
        
        -- 아이템 카드
        local ui_card = UI_ItemCard(item_id, item_cnt)
        ui_card:setEnabledClickBtn(false) -- 아이콘 클릭 안되게
        ui.vars['itemNode']:addChild(ui_card.root)
    
        -- 아이템 이름 (수량)
        local item_name = TableItem:getItemName(item_id)
        if (item_cnt > 1) then
            item_name =  Str('{1} {2}개', item_name, comma_value(item_cnt))
        end
        ui.vars['itemLabel']:setString(item_name)
    
        -- 버튼
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_lastRewardIdx(reward_idx) end)
        vars['clickNode' .. reward_idx]:addChild(ui.root) -- clickNode1, clickNode2, clickNode3
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:initButton()
    local vars = self.vars
    vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
end

-------------------------------------
-- function getRewardInfoByStep
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:getRewardInfoByStep(version, step, reward_idx)
    local reward_idx = (reward_idx or 1)

    local t_step = self.m_rewardList[tostring(step)]
    local package_item_str = t_step['item']
    if (reward_idx ~= 1) then
        package_item_str = t_step['item_' .. tostring(reward_idx)]
    end
    local l_reward = ServerData_Item:parsePackageItemStr(package_item_str)
    
    -- 구조상 다중 보상 지급이 가능하나, 현재로선 하나만 처리 중 sgkim 2018.10.17
    local first_item = l_reward[1]
    local item_id = first_item['item_id']
    local count = first_item['count']

    return item_id, count
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:refresh()
    local vars = self.vars
    local version = self.m_eventVersion

    -- 이벤트 종료까지 남은 시간
    local str = g_purchasePointData:getPurchasePointEventRemainTimeText(version)
    vars['timeLabel']:setString(str)
    vars['timeLabel']:setVisible(true)

    -- 누적 결제 점수
    local purchase_point = g_purchasePointData:getPurchasePoint(version)
    local str = Str('누적 결제 점수: {1}점', comma_value(purchase_point))
    vars['scoreLabel']:setString(str)

    -- 보상 수령 상태 안내 메세지
    local last_step = self.m_rewardListCount
    local curr_step = g_purchasePointData:getPurchaseRewardStep(version)
    local str = ''
    if (last_step <= curr_step) then
        str = Str('보상 수령 완료')
    else
        local next_purchase_point = g_purchasePointData:getPurchasePoint_step(version, (curr_step + 1))
        local value = (next_purchase_point - purchase_point)
        if (value < 0) then
            str = Str('보상 수령 가능')
        else
            str = Str('다음 보상까지 {1}점 남았습니다.', comma_value(value))
        end
    end
    vars['nextStepLabel']:setString(str)

    --프로그래스바 각자 할당된 퍼센트 계산
    local data = {}
    local defValue = (1/last_step)
    data[1] = defValue / 2  --0 -> 1로 가는 지점을 절반으로 할당
    local shareValue = data[1]/(last_step-1) --남은 절반에 대한 영역을 서로 나눠 가짐
    for i=2, last_step do
        data[i] = defValue + shareValue
    end
    -- 결제 포인트 게이지
    local _purchase_point = purchase_point
    local percentage = 0
    local prev_point = 0
    for i=1, last_step do
        local _point = g_purchasePointData:getPurchasePoint_step(version, i)
        local temp = prev_point
        prev_point = _point
        _point = (_point - temp)

        --보상 포인트를 넘는 경우
        if (_point <= _purchase_point) then 
            percentage = (percentage + data[i])
        else--보상 포인트까지 부족 경우.
            percentage = (percentage + ((_purchase_point/_point)*data[i]))
            break
        end
        _purchase_point = (_purchase_point - _point)
    end
    percentage = math_clamp((percentage * 100), 0, 100)

    vars['purchaseGg']:runAction(cc.ProgressTo:create(0.1, percentage))

    self:SetInfoLabel()
    self:refresh_rewardBoxUIList()
end

-------------------------------------
-- function refresh_rewardUIList
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:refresh_rewardUIList()
    if (not self.m_rewardUIList) then
        return
    end

    for _,ui in pairs(self.m_rewardUIList) do
        ui:refresh()
    end
end

-------------------------------------
-- function refresh_rewardBoxUIList
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:refresh_rewardBoxUIList()
    if (not self.m_rewardBoxUIList) then
        return
    end

    local version = self.m_eventVersion

    for step,ui in pairs(self.m_rewardBoxUIList) do
        local vars = ui.vars
        local t_step, reward_state = g_purchasePointData:getPurchasePoint_rewardStepInfo(version, step)
        vars['checkSprite']:setVisible(false)
        vars['receiveBtn']:setVisible(false)

        -- 획득 완료
        if (reward_state == 1) then
            vars['checkSprite']:setVisible(true)
            vars['receiveBtn']:setVisible(false)
        -- 획득 가능
        elseif (reward_state == 0) then
            vars['checkSprite']:setVisible(false)
            vars['receiveBtn']:setVisible(true)

        -- 획득 불가
        --elseif (reward_state == -1) then
        else
            --vars['closeSprite']:setVisible(true)
        end

    end
end


-------------------------------------
-- function click_helpBtn
-- @brief 도움말
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:click_helpBtn()
    UI_GuidePopup_PurchasePoint()
end

-------------------------------------
-- function click_receiveBtn
-- @brief
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:click_receiveBtn(reward_step)

    if (reward_step == self.m_rewardListCount) then
        local ui = UI_PurchasePointRewardSelectPopup(self.m_eventVersion, self.m_rewardListCount)
        ui:setCloseCB(function() self:refresh() end)
        return
    end

    local function cb_func(ret)
        -- 보상 획득
        ItemObtainResult(ret)

        self:refresh()

        if self.m_tabButtonCallback then
            self.m_tabButtonCallback()
        end
    end

    local version = self.m_eventVersion
    g_purchasePointData:request_purchasePointReward(version, reward_step, 1, cb_func)
end

-------------------------------------
-- function click_lastRewardIdx
-- @brief 마지막 보상 선택 버튼
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:click_lastRewardIdx(reward_idx)
    if (self.m_selectedLastRewardIdx == reward_idx) then
        return
    end
    self.m_selectedLastRewardIdx = reward_idx

    self:SetInfoLabel()
    self:refresh_lastReward(reward_idx)
    self:refresh_rewardBoxUIList()
end

-------------------------------------
-- function refresh_lastReward
-- @brief idx에 맞는 마지막 보상 UI 출력
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:refresh_lastReward(idx)
    local vars = self.vars    
    local version = self.m_eventVersion
    -- 배경 생성
    vars['productNode']:removeAllChildren()
    local step_count = self.m_rewardListCount

    -- 타입에 따른 누적 결제 배경UI
    local last_reward_type = g_purchasePointData:getLastRewardType(version, idx)
    if (last_reward_type == nil) then
        last_reward_type = 'item'
    end
    local last_reward_item_id, count = self:getRewardInfoByStep(version, step_count, idx)
    local ui_bg = UI_PurchasePointBgNew(last_reward_type, last_reward_item_id, count, version)
    if (ui_bg) then
        vars['productNode']:addChild(ui_bg.root)
    end

    -- 아이템 프레임
    local step = self.m_rewardListCount
    local item_node = vars['itemNode'..step]

    local item_id, count = self:getRewardInfoByStep(version, step, idx)
    local UI_Item = self:getUI_NewItem1(step, item_id, count)

    item_node:removeAllChildren()
    item_node:addChild(UI_Item.root)
    self.m_rewardBoxUIList[step] = UI_Item
end

-------------------------------------
-- function SetInfoLabel
-- @brief Step에 따른 InfoLabel 변경
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:SetInfoLabel()
    local version = self.m_eventVersion

    local last_step = self.m_rewardListCount
    local item_id, count = self:getRewardInfoByStep(version, last_step, self.m_selectedLastRewardIdx)
    local did = tonumber(TableItem:getDidByItemId(item_id))

    --문자열 합쳐주는 함수
    local function addString(str, addStr)
        --비어있는 경우
        if(str == nil) or (str == '') then
            str = addStr
        else --문자열이 있는 경우 띄어쓰기 적용
            str = (str .. ' ' .. addStr)
        end
        return str
    end

    local ItemName = TableItem:getItemName(item_id)
    local str_Info = Str('{1} X {2} 획득 기회!', ItemName, count)
    if did and (0 < did) then
        local type = TableDragon:getDragonType(did)
        if type then
            local prevStr = nil
            local rarity = TableDragon:getValue(did,'rarity')
            if (rarity == 'myth') then
                prevStr = addString(prevStr, Str('신화'))
            end

            local category = TableDragon:getValue(did, 'category')
            if (category == 'cardpack') then
                prevStr = addString(prevStr, Str('토파즈'))
            elseif (category == 'event') then
                prevStr = addString(prevStr, Str('이벤트'))
            elseif (category == 'limited') then
                prevStr = addString(prevStr, Str('한정'))
            end

            prevStr = addString(prevStr, Str('드래곤'))
            local dragonName = string.format('{@%s}%s{@white}', TableDragon:getDragonAttr(did), ItemName)
            str_Info =  Str('{1} {2} 획득 기회!', prevStr, dragonName)
        end
    end
    self.vars['infoLabel']:setString(str_Info)
end

-------------------------------------
-- function getStepNodeNumberIcon
-- @brief Step에 따른 Number Icon 획득
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:getStepNodeNumberIcon(step)
    local res_name = 'res/ui/event/purchase_point/event_purchase_number_0' .. tostring(step) .. '.png'
    local res = IconHelper:getIcon(res_name)
    return res
end

-------------------------------------
-- function getStepNodeBgBarImg
-- @brief 드래곤 속성에 따른 Bar Img 획득
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:getStepNodeBgBarImg(attr)
    local res_name = 'res/ui/event/purchase_point/event_purchase_frame_' .. attr .. '.png'
    local res = IconHelper:getIcon(res_name)
    return res
end

-------------------------------------
-- function addUI_NewItem1
-- @brief Step 따라 NewItem1를 세팅해서 리턴해준다.
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:getUI_NewItem1(step, item_id, count)
    local version = self.m_eventVersion
    
    local ui_frame = UI()
    ui_frame:load('event_purchase_point_item_new_01.ui')

    local vars = ui_frame.vars

    --보상 받기 버튼
    vars['receiveBtn']:registerScriptTapHandler(function() self:click_receiveBtn(step) end)

    -- 아이템 카드
    local ui_card = UI_ItemCard(item_id, count)
    -- 만약 드래곤 카드라면 드래곤 정보 팝업
    local did = tonumber(TableItem:getDidByItemId(item_id))
    if did and (0 < did) then
        ui_card.vars['clickBtn']:registerScriptTapHandler(function() UI_BookDetailPopup.openWithFrame(did, nil, 3, 0.8, true) end)
        local attr = TableDragon:getDragonAttr(did)
        vars['bgNode']:removeAllChildren()
        vars['bgNode']:addChild(self:getStepNodeBgBarImg(attr))
    end

    -- 보상 점수
    local point = g_purchasePointData:getPurchasePoint_step(version, step)
    vars['scoreLabel']:setString(Str('{1}점', comma_value(point)))

    vars['stepNode']:removeAllChildren()
    vars['stepNode']:addChild(self:getStepNodeNumberIcon(step))

    ui_frame.root:setScale(1.2)
    ui_card.root:setScale(0.7)

    vars['iconNode']:addChild(ui_card.root)
    -- 보상 점수
    local point = g_purchasePointData:getPurchasePoint_step(version, step)
    vars['scoreLabel']:setString(Str('{1}점', comma_value(point)))

    return ui_frame
end
--@CHECK
UI:checkCompileError(UI_EventPopupTab_PurchasePointNew)
