local PARENT = UI

----------------------------------------------------------------------
-- class UI_ClearTicket
----------------------------------------------------------------------
UI_ClearTicket = class(PARENT, {
    m_stageID = 'number',       
    m_clearNum = 'number',              -- 원하는 소탕 횟수
    m_supplyType = 'string',            -- 보급소에서 소탕 정보를 얻기 위한 키값 : 'clear_type'

    m_staminaType = 'string',           -- m_stageID에 대응하는 스테이지에 필요한 입장권 종류 (ex: st 날개)
    m_requiredStaminaNum = 'number',    -- m_stageID에 대응하는 스테이지가 요구하는 입장권 갯수
    m_currStaminaNum = 'number',        -- 현재 유저가 보유하고 있는 입장권 갯수
    m_availableStageNum = 'number',     -- 입장권에 따른 최대 입장 가능 횟수
    
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_ClearTicket:init(stage_id)

    local vars = self:load('clear_ticket_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- UI 클래스명 지정
    self.m_uiName = 'UI_ClearTicket'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClearTicket')

    self:initMember(stage_id)
    self:initUI()
    self:initButton()
    self:refresh()

    
    if vars['periodLabel'] and vars['buyMenu'] then
        vars['buyMenu']:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    end
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicket:initMember(stage_id)
    self.m_stageID = stage_id
    self.m_clearNum = 1
    self.m_supplyType = 'clear_ticket'

    self.m_staminaType, self.m_requiredStaminaNum = TableDrop:getStageStaminaType(self.m_stageID)
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicket:initUI()
    local vars = self.vars
    local stage_id = self.m_stageID
    local game_mode = g_stageData:getGameMode(stage_id)

    do -- 스테이지 이름 및 난이도
        local stage_name = g_stageData:getStageName(stage_id)
        vars['titleLabel']:setString(stage_name)

        local string_width = vars['titleLabel']:getStringWidth()
        local pos_x = -(string_width / 2)
        vars['difficultyLabel']:setPositionX(pos_x - 10)

        UIHelper:setDifficultyLabelWithColor(vars['difficultyLabel'], stage_id)
    end

    do
        vars['sliderBarSprite']:setPercentage(0)
        vars['sliderBarBtn']:setPositionX(0)
    end
end


----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_ClearTicket:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    vars['plusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(1) end)
    
    vars['plusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(1, true) end)

    vars['minusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(-1) end)
    
    vars['minusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(-1, true) end)
    
    vars['maxBtn']:registerScriptTapHandler(function() self:click_adjustBtn(100) end)

    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)

    
    if g_supply:isActiveSupply(self.m_supplyType) then
        local pid = g_supply:getSupplyProductIdByType(self.m_supplyType)
        local struct_product = g_shopDataNew:getProduct('package', pid)

        if struct_product then
            vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn(struct_product) end)

            local is_tag_attached = ServerData_IAP.getInstance():setGooglePlayPromotionSaleTag(self, struct_product, nil)
            local is_sale_price_written = false
            if (is_tag_attached == true) then
                is_sale_price_written = ServerData_IAP.getInstance():setGooglePlayPromotionPrice(self, struct_product, nil)
            end

            if (is_sale_price_written == false) then
                vars['priceLabel']:setString(struct_product:getPriceStr())
            end
        else
            vars['buyBtn']:setVisible(false)
        end
    else
        vars['buyBtn']:setVisible(false)
    end


    self:initSlideBar()
end

----------------------------------------------------------------------
-- function initSlideBar
----------------------------------------------------------------------
function UI_ClearTicket:initSlideBar()
    local node = self.vars['sliderBarNode']

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self:onSliderbarTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self:onSliderbarTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self:onSliderbarTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self:onSliderbarTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end


----------------------------------------------------------------------
-- function initSlideBar
----------------------------------------------------------------------
function UI_ClearTicket:refreshDropInfo()
    local vars = self.vars

    local str = '{1}/{2}'
    vars['diaLabel']:setString(Str(str, g_userData:getDropInfoDia(), g_userData:getDropInfoMaxDia()))

    vars['goldLabel']:setString(Str(str, g_userData:getDropInfoGold(), g_userData:getDropInfoMaxGold()))

    vars['amethystLabel']:setString(Str(str, g_userData:getDropInfoAmethyst(), g_userData:getDropInfoMaxAmethyst()))

end


----------------------------------------------------------------------
-- function onSliderbarTouchBegan
----------------------------------------------------------------------
function UI_ClearTicket:onSliderbarTouchBegan(touch, event)
    local vars = self.vars

    local touched_point = touch:getLocation()

    -- 노드 영역을 벗어났는지 체크
    local bounding_box = vars['sliderBarBtn']:getBoundingBox()
    
    local converted_point = vars['sliderBarNode']:convertToNodeSpace(touched_point)
    
    return cc.rectContainsPoint(bounding_box, converted_point)
end

----------------------------------------------------------------------
-- function onSliderbarTouchMoved
----------------------------------------------------------------------
function UI_ClearTicket:onSliderbarTouchMoved(touch, event)
    local vars = self.vars
    local touched_point = touch:getLocation()

    -- 노드 영역을 벗어났는지 체크    
    local converted_point = vars['sliderBarNode']:convertToNodeSpace(touched_point)
    local slider_bar_content_size = vars['sliderBarNode']:getContentSize()
    local x = math_clamp(converted_point.x, 0, slider_bar_content_size.width)
    local percentage = x / slider_bar_content_size.width

    self.m_clearNum =  math_max(1, math_floor(percentage * self.m_availableStageNum))

    self:refresh()
end

----------------------------------------------------------------------
-- function onSliderbarTouchEnded
----------------------------------------------------------------------
function UI_ClearTicket:onSliderbarTouchEnded(touch, event)
    
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_ClearTicket:refresh(is_refreshed_by_button, is_button_pressed)
    local vars = self.vars

    -- 상단 일일 획득 드랍 아이템
    self:refreshDropInfo()

    -- 소탕 횟수
    vars['countLabel']:setString(Str('{1}회', comma_value(self.m_clearNum)))

    -- 현재 유저가 보유하고 있는 입장권(날개) 갯수
    self.m_currStaminaNum = g_staminasData:getStaminaCount(self.m_staminaType)
    -- 입장권(날개)에 따른 최대 입장 가능 횟수
    self.m_availableStageNum = math_floor(self.m_currStaminaNum /  self.m_requiredStaminaNum)

    -- 입장권 갯수 
    vars['staminaLabel']:setString(Str('{1}/{2}', comma_value(self.m_requiredStaminaNum * self.m_clearNum), comma_value(self.m_currStaminaNum)))
    
    local ratio = self.m_clearNum / self.m_availableStageNum
    local slider_bar_content_size = vars['sliderBarNode']:getContentSize()

    -- 드래그가 아닌 버튼 터치 시 
    if is_refreshed_by_button then

        vars['sliderBarBtn']:stopAllActions()
        vars['sliderBarBtn']:runAction(cc.MoveTo:create(0.2, cc.p(ratio * slider_bar_content_size.width, 0)))

        vars['sliderBarSprite']:stopAllActions()
        vars['sliderBarSprite']:runAction(cc.ProgressTo:create(0.2, ratio * 100))
    else
        vars['sliderBarBtn']:stopAllActions()
        vars['sliderBarBtn']:setPositionX(ratio * slider_bar_content_size.width)

        vars['sliderBarSprite']:stopAllActions()
        vars['sliderBarSprite']:setPercentage(ratio * 100)
    end    

    -- 
    local is_startBtn_enabled = ((self.m_requiredStaminaNum * self.m_clearNum) <= self.m_currStaminaNum) 
    vars['startBtn']:setEnabled(is_startBtn_enabled)     
    
    if is_startBtn_enabled then
        vars['startLabel']:setColor(COLOR['BLACK'])
    else
        vars['startLabel']:setColor(COLOR['DESC'])
        vars['staminaLabel']:setColor(COLOR['RED'])

        if (not is_button_pressed) then
            UIManager:toastNotificationRed(Str('날개가 부족합니다.'))
        end
    end

end

----------------------------------------------------------------------
-- function update
----------------------------------------------------------------------
function UI_ClearTicket:update(dt)
    local time_str = g_supply:getSupplyTimeRemainingString(self.m_supplyType)

    self.vars['periodLabel']:setString(time_str)
end

----------------------------------------------------------------------
-- function refresh_string
----------------------------------------------------------------------
function UI_ClearTicket:click_adjustBtn(value, is_pressed)

    local function adjust_func()
        local result = self.m_clearNum + value

        if (result > self.m_availableStageNum) then
            result = self.m_availableStageNum
        end

        if (result >= 1) and (result <= self.m_availableStageNum) then
            self.m_clearNum = result
        end

        self:refresh(not is_pressed, is_pressed)
    end

    if (not is_pressed) then
        adjust_func()
    else
        local button    
        if (value >= 0) then
            button = self.vars['plusBtn']
        else
            button = self.vars['minusBtn']
        end

        local function update_level(dt)
            if (not button:isSelected()) or (not button:isEnabled()) then
                self.root:unscheduleUpdate()
            end

            adjust_func()
        end

        self.root:scheduleUpdateWithPriorityLua(function(dt) return update_level(dt) end, 1)
    end
end

----------------------------------------------------------------------
-- function click_startBtn
----------------------------------------------------------------------
function UI_ClearTicket:click_startBtn()  
    -- 드래곤 가방 확인(최대 갯수 초과 시 획득 못함)
    local function manage_func()
        UINavigatorDefinition:goTo('dragon')
    end

    local function finish_cb(ret)
        function proceeding_end_cb()
            local ui = UI_ClearTicketConfirm(self.m_clearNum, ret)
            -- Back Key unlock
            UIManager:blockBackKey(false)
            ui:setCloseCB(function() 
                self.m_clearNum = 1
                self:refresh()
            end)
        end

        local proceeding_ui = UI_Proceeding()
        proceeding_ui.root:runAction(cc.Sequence:create(cc.DelayTime:create(2.1), 
            cc.CallFunc:create(function() 
                proceeding_ui:setCloseCB(function() 
                    proceeding_end_cb()
                end)
                proceeding_ui:close()
            end)))
    end

    clear_ticket = function()
        g_stageData:request_clearTicket(self.m_stageID, self.m_clearNum, finish_cb)
    end

    
    -- 아이템 가방 확인(최대 갯수 초과 시 획득 못함)
    check_item_inven = function()
        local function manage_func()
            -- UI_Inventory() @kwkang 룬 업데이트로 룬 관리쪽으로 이동하게 변경 
            UINavigatorDefinition:goTo('rune_forge', 'manage')
        end
        g_inventoryData:checkMaximumItems(clear_ticket, manage_func)
    end

    -- Back Key lock
    UIManager:blockBackKey(true)
    g_dragonsData:checkMaximumDragons(check_item_inven, manage_func)
end


----------------------------------------------------------------------
-- function click_buyBtn
----------------------------------------------------------------------
function UI_ClearTicket:click_buyBtn(struct_product)    
    local period = 7
    local supply_product = g_supply:getSupplyProductByType(self.m_supplyType, period)

    local function callback(ret)
        ItemObtainResult_Shop(ret, true)
    end

    require('UI_SupplyProductInfoPopup')
    local ui = UI_SupplyProductInfoPopup(supply_product)

    ui:setBuyCallback(callback)
end







----------------------------------------------------------------------
-- class UI_ClearTicketConfirm
----------------------------------------------------------------------
UI_ClearTicketConfirm = class(PARENT, {
    m_changedUserInfo = 'table',
    m_dropItems = 'table',

    m_clearNum = 'number',

    m_originalTitleLabel = 'string',

    m_levelUpDirector = 'LevelupDirector_GameResult',
})



----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_ClearTicketConfirm:init(clear_num, result_table)
    local vars = self:load('clear_ticket_popup_confirm.ui')
    UIManager:open(self, UIManager.POPUP)

    -- UI 클래스명 지정
    self.m_uiName = 'UI_ClearTicketConfirm'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClearTiUI_ClearTicketConfirmcket')


    self:initMember(clear_num, result_table)
    self:initUI()
    self:initButton()
    self:refresh()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicketConfirm:initMember(clear_num, result_table)
    local vars = self.vars

    self.m_clearNum = clear_num
    self.m_changedUserInfo = result_table['user_levelup_data']
    self.m_dropItems = result_table['drop_reward_list']
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicketConfirm:initUI()
    local vars = self.vars 

    vars['resultLabel']:setString(Str(vars['resultLabel']:getString(), self.m_clearNum))


end


----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_ClearTicketConfirm:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end



----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_ClearTicketConfirm:refresh()
    self:initDropItems()
    self:initUserInfo()    
end


----------------------------------------------------------------------
-- function initUserInfo
----------------------------------------------------------------------
function UI_ClearTicketConfirm:initUserInfo()
    local vars = self.vars

    local prev_lv = self.m_changedUserInfo['prev_lv']
    local prev_exp = self.m_changedUserInfo['prev_exp']
    local curr_lv = self.m_changedUserInfo['curr_lv']
    local curr_exp = self.m_changedUserInfo['curr_exp']

    local level_up_director = LevelupDirector_GameResult(
        vars['userLvLabel'],
        vars['userExpLabel'],
        vars['userMaxSprite'],
        vars['userExpGg'],
        vars['userLvUpVisual']
    )

    -- if (prev_lv ~= curr) then
    --     level_up_director.m_cbAniFinish = function()
    --         --self.root:stopAllActions()
            
    --         -- @ GOOGLE ACHIEVEMENT
    --         local t_data = {clear_key = 'u_lv'}
    --         GoogleHelper.updateAchievement(t_data)

    --         local ui = UI_UserLevelUp(self.m_changedUserInfo)
    --         --ui:setCloseCB(function() self:doNextWork() end)
    --     end
    -- end

    level_up_director:initLevelupDirector(prev_lv, prev_exp, curr_lv, curr_exp, 'tamer')

    self.m_levelUpDirector = level_up_director

    local function finish_cb()
        self.m_levelUpDirector:stop()  

        if (prev_lv ~= curr_lv) then
            local t_data = {clear_key = 'u_lv'}
            GoogleHelper.updateAchievement(t_data)

            local ui = UI_UserLevelUp(self.m_changedUserInfo)
        end
    end
    self.m_levelUpDirector.m_cbAniFinish = finish_cb
    self.m_levelUpDirector:start()
end



----------------------------------------------------------------------
-- function initDropItems
----------------------------------------------------------------------
function UI_ClearTicketConfirm:initDropItems()
    local vars = self.vars
    local count = #self.m_dropItems

    if (count <= 0) then
        return
    end

    local interval = 95
    local pos_list = getSortPosList(interval, count)

    for index, value in ipairs(self.m_dropItems) do
        -- value = {item_id, count, from, data}
        local item_id = value[1]
        local item_num = value[2]
        local from = value[3]
        local data = value[4]

        local item_card = UI_ItemCard(item_id, item_num, data)

        if item_card then
            item_card.root:setScale(0.6)

            vars['dropRewardMenu']:addChild(item_card.root)

            item_card.root:setPositionX(pos_list[index])

            if (from =='bonus') then
                local animator = MakeAnimator('res/item/item_marble/item_marble.vrp')
                animator:setAnchorPoint(cc.p(0.5, 0.5))
                animator:setDockPoint(cc.p(1, 1))
                animator:setScale(0.85)
                animator:setPosition(-20, -20)
                item_card.vars['clickBtn']:addChild(animator.m_node)
            end
        end
    end
end