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
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_Button:init(node)
    self.m_node:registerScriptTapHandler(function() UIC_Button.tapHandler(self) end)
    
    self:setOriginData()

    -- ��ư�� enter�� ���ԵǾ��� �� update�Լ� ȣ��
    node:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.m_node:scheduleUpdateWithPriorityLua(function() self:update() end, 0)
        end
    end)
end

-------------------------------------
-- function tapHandler
-------------------------------------
function UIC_Button.tapHandler(self)
    self.m_buttonState = UIC_BUTTON_CLICK
    self:onButtonStateChange(self.m_buttonState)

    if self.m_clickFunc then
        self.m_clickFunc()
    end
end

-------------------------------------
-- function registerScriptTapHandler
-------------------------------------
function UIC_Button:registerScriptTapHandler(func)
    self.m_clickFunc = func
end

-------------------------------------
-- function setOriginData
-- @brief ���� ��ư�� ��ġ�� �������� ����
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

    -- ���� ��ư ���� üũ
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

    -- ���°� ����Ǿ��� ��� ���� �׼� ó��
    if (curr_state ~= self.m_buttonState) then
        self.m_buttonState = curr_state
        self:onButtonStateChange(curr_state)
    end
end

-------------------------------------
-- function onButtonStateChange
-- @brief
-------------------------------------
function UIC_Button:onButtonStateChange(button_state)
    local node = self.m_node

    -- �������� �׼� stop
    local action = node:getActionByTag(UIC_BUTTON_ACTION_TAG);
    if action then
        node:stopAction(action)
    end

    -- ��Ȱ��ȭ ��
    if (button_state == UIC_BUTTON_DISABLE) then
        node:setPosition(self.m_originPosX, self.m_originPosY)
        node:setScale(self.m_originScaleX, self.m_originScaleY)

    -- �Ϲ� ����
    elseif (button_state == UIC_BUTTON_NORMAL) then
        node:setPosition(self.m_originPosX, self.m_originPosY)
        node:setScale(self.m_originScaleX, self.m_originScaleY)

    -- ������ ����
    elseif (button_state == UIC_BUTTON_SELECTED) then
        node:setPosition(self.m_originPosX + 2, self.m_originPosY)
        node:setScale(self.m_originScaleX * 0.9, self.m_originScaleY * 0.9)

        -- ������ �׼�
        local sequence = cc.Sequence:create(cc.MoveTo:create(0.1, cc.p(self.m_originPosX-2, self.m_originPosY)), cc.MoveTo:create(0.1, cc.p(self.m_originPosX + 2, self.m_originPosY)))
        local action = cc.RepeatForever:create(sequence)
        action:setTag(UIC_BUTTON_ACTION_TAG)
        node:runAction(action)
    
    -- Ŭ���� ����
    elseif (button_state == UIC_BUTTON_CLICK) then
        node:setPosition(self.m_originPosX, self.m_originPosY)
        node:setScale(self.m_originScaleX * 0.9, self.m_originScaleY * 0.9)

        -- Ŭ�� �׼�
        local action = cc.EaseElasticOut:create(cc.ScaleTo:create(0.3, self.m_originScaleX, self.m_originScaleY), 0.3)
        action:setTag(UIC_BUTTON_ACTION_TAG)
        node:runAction(action)
    end

    -- CLICK������ ��� NORMAL�� ������ ����(�׼� ���� �� �ڵ� ����)
    if (button_state == UIC_BUTTON_CLICK) then
        self.m_buttonState = UIC_BUTTON_NORMAL
    end
end