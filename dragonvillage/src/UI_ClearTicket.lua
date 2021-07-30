local PARENT = UI

----------------------------------------------------------------------
-- class UI_ClearTicket
----------------------------------------------------------------------
UI_ClearTicket = class(PARENT, {
    m_stageID = 'number',
    m_clearNum = 'number', 


    m_staminaType = 'string',
    m_requiredStaminaNum = 'number',
    m_currStaminaNum = 'number',
    m_availableStageNum = 'number',
    
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
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicket:initMember(stage_id)
    self.m_stageID = stage_id
    self.m_clearNum = 0

    
    self.m_staminaType, self.m_requiredStaminaNum = TableDrop:getStageStaminaType(self.m_stageID)
    self.m_currStaminaNum = g_staminasData:getStaminaCount(self.m_staminaType)


    self.m_availableStageNum = math_floor(self.m_currStaminaNum /  self.m_requiredStaminaNum)
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
        vars['countLabel']:setString(Str('{1}회', comma_value(0)))
        vars['sliderBarSprite']:setPercentage(0)
        vars['sliderBarBtn']:setPositionX(0)
    end


    local stamina_type, required_stamina_num = TableDrop:getStageStaminaType(stage_id)
    local curr_stamina_num = g_staminasData:getStaminaCount(stamina_type)

    vars['staminaLabel']:setString(Str('{1}/{2}', comma_value(0), comma_value(curr_stamina_num)))
end


----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_ClearTicket:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    vars['plusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(1) end)
    
    vars['plusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(1) end)

    vars['minusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(-1) end)
    
    vars['minusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(-1) end)
    
    vars['maxBtn']:registerScriptTapHandler(function() self:click_adjustBtn(100) end)

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
    local bounding_box = vars['sliderBarBtn']:getBoundingBox()
    
    local converted_point = vars['sliderBarNode']:convertToNodeSpace(touched_point)

    local slider_bar_content_size = vars['sliderBarNode']:getContentSize()

    local x = math_clamp(converted_point.x, 0, slider_bar_content_size.width)
    local percentage = x / slider_bar_content_size.width

    vars['sliderBarBtn']:stopAllActions()
    vars['sliderBarBtn']:setPositionX(x)

    vars['sliderBarSprite']:stopAllActions()
    vars['sliderBarSprite']:setPercentage(percentage * 100)


    
    self.m_clearNum =  math_floor(percentage * self.m_availableStageNum)

    self:refresh_label()
end

----------------------------------------------------------------------
-- function onSliderbarTouchEnded
----------------------------------------------------------------------
function UI_ClearTicket:onSliderbarTouchEnded(touch, event)
    
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_ClearTicket:refresh()

end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_ClearTicket:refresh_label(is_refreshed_by_button)
    local vars = self.vars

    vars['staminaLabel']:setString(Str('{1}/{2}', comma_value(self.m_requiredStaminaNum * self.m_clearNum), comma_value(self.m_currStaminaNum)))
    vars['countLabel']:setString(Str('{1}회', comma_value(self.m_clearNum)))

    if is_refreshed_by_button then
        local ratio = self.m_clearNum / self.m_availableStageNum
        local slider_bar_content_size = vars['sliderBarNode']:getContentSize()

        vars['sliderBarBtn']:stopAllActions()
        vars['sliderBarBtn']:setPositionX(ratio * slider_bar_content_size.width)

        vars['sliderBarSprite']:stopAllActions()
        vars['sliderBarSprite']:runAction(cc.ProgressTo:create(ratio * 100))
    end
end


----------------------------------------------------------------------
-- function refresh_string
----------------------------------------------------------------------
function UI_ClearTicket:click_adjustBtn(value)
    local result = self.m_clearNum + value

    if (result >= 0) and (result <= self.m_availableStageNum) then
        self.m_clearNum = result
        self:refresh_label(true)
    end
end



