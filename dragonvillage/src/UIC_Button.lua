local PARENT = UIC_Node

local UIC_BUTTON_DISABLE = 1
local UIC_BUTTON_NORMAL = 2
local UIC_BUTTON_SELECTED = 3
local UIC_BUTTON_CLICK = 4

local UIC_BUTTON_ACTION_TAG = 100

-------------------------------------
-- class UIC_Button
-------------------------------------
UIC_Button = class(PARENT, {
        m_clickFunc = 'function',

        m_originPosX = 'number',
        m_originPosY = 'number',

        m_originScaleX = 'number',
        m_originScaleY = 'number',

        m_buttonState = 'number',

        m_clickSoundName = 'string',

        m_actionType = '',

        m_bAutoShakeAction = 'boolean', -- 버튼을 흔드는 액션 사용 여부

		m_blockMsg = 'str', -- button block 할 경우 팝업 메세지

        m_pressCB = 'function', -- 버튼이 눌려 있는동안 callback하는 함수
    })

UIC_Button.ACTION_TYPE_NORMAL = 1
UIC_Button.ACTION_TYPE_WITHOUT_SCAILING = 2

-------------------------------------
-- function init
-------------------------------------
function UIC_Button:init(node)
    self.m_clickSoundName = 'ui_touch'
    self.m_buttonState = UIC_BUTTON_NORMAL
    self.m_actionType = UIC_Button.ACTION_TYPE_NORMAL
    self.m_bAutoShakeAction = false
    self.m_node:registerScriptTapHandler(function() UIC_Button.tapHandler(self) end)
    
    self:setOriginData()

    -- 버튼이 enter로 진입되었을 때 update함수 호출
    node:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.m_node:scheduleUpdateWithPriorityLua(function() self:update() end, 0)
        end
    end)

    self.m_buttonState = UIC_BUTTON_NORMAL
    self:onButtonStateChange(self.m_buttonState)
end

-------------------------------------
-- function setActionType
-------------------------------------
function UIC_Button:setActionType(action_type)
    self.m_actionType = action_type
end

-------------------------------------
-- function tapHandler
-------------------------------------
function UIC_Button.tapHandler(self)
    if self.m_clickSoundName then
        SoundMgr:playEffect('UI', self.m_clickSoundName)
    end

    self:setClickButtonState()

    if self.m_clickFunc then
        if (self.m_blockMsg) then
            UIManager:toastNotificationRed(self.m_blockMsg)
        else
            self.m_clickFunc()
        end
    end
end

-------------------------------------
-- function registerScriptTapHandler
-------------------------------------
function UIC_Button:registerScriptTapHandler(func)
    self.m_clickFunc = func
end

-------------------------------------
-- function addScriptTapHandler
-- @brief 클릭 콜백을 추가한다. 이전 콜백과 새로운 콜백은 서로 독립적이어야 한다.
-------------------------------------
function UIC_Button:addScriptTapHandler(add_func)
    local pre_func = self.m_clickFunc
    self:registerScriptTapHandler(nil)
    self:registerScriptTapHandler(function()
        pre_func()
        add_func()
    end)
end

-------------------------------------
-- function registerScriptPressHandler
-------------------------------------
function UIC_Button:registerScriptPressHandler(func)
    self.m_node:registerScriptPressHandler(func)
end

-------------------------------------
-- function unregisterScriptPressHandler
-------------------------------------
function UIC_Button:unregisterScriptPressHandler()
    return self.m_node:unregisterScriptPressHandler()
end

-------------------------------------
-- function setOriginData
-- @brief 현재 버튼의 위치와 스케일을 저장
-------------------------------------
function UIC_Button:setOriginData()
    local node = self.m_node

    self.m_originPosX = node:getPositionX()
    self.m_originPosY = node:getPositionY()

    self.m_originScaleX = node:getScaleX()
    self.m_originScaleY = node:getScaleY()
end

-------------------------------------
-- function update
-- @brief
-------------------------------------
function UIC_Button:update(dt)
    local node = self.m_node

    -- 현재 버튼 상태 체크
    local curr_state
    local is_enabled = node:isEnabled()
    local is_selected = node:isSelected()
    if (is_enabled == true) then
        if (is_selected == true) then
            curr_state = UIC_BUTTON_SELECTED
        else
            curr_state = UIC_BUTTON_NORMAL
        end
    else
        curr_state = UIC_BUTTON_DISABLE
    end

    -- 상태가 변경되었을 경우 변경 액션 처리
    if (curr_state ~= self.m_buttonState) then
        self.m_buttonState = curr_state
        self:onButtonStateChange(curr_state)
    end
end

-------------------------------------
-- function setClickButtonState
-- @brief
-------------------------------------
function UIC_Button:setClickButtonState()
    self.m_buttonState = UIC_BUTTON_CLICK
    self:onButtonStateChange(self.m_buttonState)
end

-------------------------------------
-- function onButtonStateChange
-- @brief
-------------------------------------
function UIC_Button:onButtonStateChange(button_state)

    -- disable은 버튼의 액션에 관여하지 않음 (일단은.. Seong-goo Kim)
    if (button_state == UIC_BUTTON_DISABLE) then
        --return
    end

    local node = self.m_node

    -- 실행중인 액션 stop
    local action = node:getActionByTag(UIC_BUTTON_ACTION_TAG);
    if action then
        node:stopAction(action)
    end

    -- 비활성화 시
    if (button_state == UIC_BUTTON_DISABLE) then
        node:setPosition(self.m_originPosX, self.m_originPosY)
        node:setScale(self.m_originScaleX, self.m_originScaleY)
        node:setRotation(0)

    -- 일반 상태
    elseif (button_state == UIC_BUTTON_NORMAL) then
        node:setPosition(self.m_originPosX, self.m_originPosY)
        node:setScale(self.m_originScaleX, self.m_originScaleY)
        node:setRotation(0)

        if self.m_bAutoShakeAction then
            local action = cca.buttonShakeAction()
            action:setTag(UIC_BUTTON_ACTION_TAG)
            node:runAction(action)
        end

    -- 눌려진 상태
    elseif (button_state == UIC_BUTTON_SELECTED) then
        node:setPosition(self.m_originPosX, self.m_originPosY)

        if (self.m_actionType ~= UIC_Button.ACTION_TYPE_WITHOUT_SCAILING) then
            node:setScale(self.m_originScaleX * 0.95, self.m_originScaleY * 0.95)
        end

        node:setRotation(0)

        -- 눌리는 동안 콜백함수 있다면 액션하는 중간중간에 함수를 불러줌
        local press_cb = cc.CallFunc:create(function() 
            if (self.m_pressCB) then
                self.m_pressCB()
            end
        end)

        -- 눌려진 액션
        local sequence
        if (math_random(1, 2) == 1) then
            sequence = cc.Sequence:create(cc.MoveTo:create(0.05, cc.p(self.m_originPosX - 2, self.m_originPosY)),
                cc.MoveTo:create(0.05, cc.p(self.m_originPosX, self.m_originPosY)),
                cc.MoveTo:create(0.05, cc.p(self.m_originPosX + 2, self.m_originPosY)),
                cc.MoveTo:create(0.05, cc.p(self.m_originPosX, self.m_originPosY)))
        else
            sequence = cc.Sequence:create(cc.MoveTo:create(0.05, cc.p(self.m_originPosX + 2, self.m_originPosY)),
                cc.MoveTo:create(0.05, cc.p(self.m_originPosX, self.m_originPosY)),
                cc.MoveTo:create(0.05, cc.p(self.m_originPosX - 2, self.m_originPosY)),
                cc.MoveTo:create(0.05, cc.p(self.m_originPosX, self.m_originPosY)))
        end

        local sequence_with_cb = cc.Sequence:create(sequence, press_cb)
        local action = cc.RepeatForever:create(sequence_with_cb)
        action:setTag(UIC_BUTTON_ACTION_TAG)
        node:runAction(action)
    
    -- 클릭된 상태
    elseif (button_state == UIC_BUTTON_CLICK) then
        node:setPosition(self.m_originPosX, self.m_originPosY)
        node:setRotation(0)

        if (self.m_actionType ~= UIC_Button.ACTION_TYPE_WITHOUT_SCAILING) then
            node:setScale(self.m_originScaleX * 0.95, self.m_originScaleY * 0.95)
        end

        -- 클릭 액션
        local action = cc.EaseElasticOut:create(cc.ScaleTo:create(0.3, self.m_originScaleX, self.m_originScaleY), 0.3)
        sequence = cc.Sequence:create(action, cc.CallFunc:create(function()
            self.m_buttonState = UIC_BUTTON_NORMAL
            self:onButtonStateChange(self.m_buttonState)
        end))
        action:setTag(UIC_BUTTON_ACTION_TAG)
        node:runAction(action)
    end

    --[[
    -- CLICK상태일 경우 NORMAL로 강제로 변경(액션 종료 후 자동 정리)
    if (button_state == UIC_BUTTON_CLICK) then
        self.m_buttonState = UIC_BUTTON_NORMAL
    end
    --]]
end

-------------------------------------
-- function setPosition
-- @brief
-------------------------------------
function UIC_Button:setPosition(x, y)
    PARENT.setPosition(self, x, y)
    self:setOriginData()
end

-------------------------------------
-- function setPositionX
-- @brief
-------------------------------------
function UIC_Button:setPositionX(x)
    PARENT.setPositionX(self, x)
    self:setOriginData()
end

-------------------------------------
-- function setPositionY
-- @brief
-------------------------------------
function UIC_Button:setPositionY(y)
    PARENT.setPositionY(self, y)
    self:setOriginData()
end

-------------------------------------
-- function isSelected
-- @brief
-------------------------------------
function UIC_Button:isEnabled()
    return self.m_node:isEnabled()
end

-------------------------------------
-- function isSelected
-- @brief
-------------------------------------
function UIC_Button:isSelected()
    return (self.m_buttonState == UIC_BUTTON_SELECTED)
end

-------------------------------------
-- function setNormalSpriteFrame
-- @brief
-------------------------------------
function UIC_Button:setNormalSpriteFrame(sprite_frame)
    return self.m_node:setNormalSpriteFrame(sprite_frame)
end

-------------------------------------
-- function setNormalImage
-- @brief
-------------------------------------
function UIC_Button:setNormalImage(node)
    return self.m_node:setNormalImage(node)
end

-------------------------------------
-- function setSelectedImage
-- @brief
-------------------------------------
function UIC_Button:setSelectedImage(node)
    return self.m_node:setSelectedImage(node)
end

-------------------------------------
-- function setDisabledImage
-- @brief
-------------------------------------
function UIC_Button:setDisabledImage(node)
    return self.m_node:setDisabledImage(node)
end

-------------------------------------
-- function setAutoShake
-- @brief
-------------------------------------
function UIC_Button:setAutoShake(auto_shake)
    self.m_bAutoShakeAction = auto_shake

    if (self.m_buttonState == UIC_BUTTON_NORMAL) then
        self:onButtonStateChange(self.m_buttonState)
    end
end

-------------------------------------
-- function setBlockMsg
-- @brief 버튼을 block하고 클릭시 toast메세지를 띄운다.
--        더블어 setColor를 통해 disabled된 느낌을 준다.
-------------------------------------
function UIC_Button:setBlockMsg(msg)
    self.m_blockMsg = msg
    if (msg) then
        self.m_node:setColor(COLOR['deep_gray'])
    else
        self.m_node:setColor(COLOR['white'])
    end
end

-------------------------------------
-- function setClickSoundName
-------------------------------------
function UIC_Button:setClickSoundName(sound_name)
    self.m_clickSoundName = sound_name
end

-------------------------------------
-- function func_press
-------------------------------------
function UIC_Button:setPressedCB(func_press)
    self.m_pressCB = func_press
end

