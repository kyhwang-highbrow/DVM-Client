-------------------------------------
-- class UIC_RadioButton
-------------------------------------
UIC_RadioButton = class({
        m_selectedButton = '',
        m_buttonMap = 'list',
        m_changeCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_RadioButton:init()
    self.m_buttonMap = {}
end

-------------------------------------
-- function addButton
-------------------------------------
function UIC_RadioButton:addButton(name, button, sprite, cb)
    local t_button_data = {}
    t_button_data['name'] = name
    t_button_data['button'] = button
    t_button_data['sprite'] = sprite
    t_button_data['cb'] = cb
    t_button_data['death'] = false

    if (not button) then
        error('there is not button : ' .. name)
    end

    self.m_buttonMap[name] = t_button_data

    button:registerScriptTapHandler(function()
            if self:setSelectedButton(name) then
                if (cb) then
                    cb()
                end
            end
        end)
end

-------------------------------------
-- function addButtonWithLabel
-------------------------------------
function UIC_RadioButton:addButtonWithLabel(name, button, label, sprite, cb)
    self:addButton(name, button, sprite, cb)
    self.m_buttonMap[name]['label'] = label
end

-------------------------------------
-- function addButtonAuto
-------------------------------------
function UIC_RadioButton:addButtonAuto(name, vars, cb)
    local button = vars[name .. 'RadioBtn']
    local label = vars[name .. 'RadioLabel']
    local sprite = vars[name .. 'RadioSprite']
    self:addButtonWithLabel(name, button, label, sprite, cb)
end

-------------------------------------
-- function setSelectedButton
-------------------------------------
function UIC_RadioButton:setSelectedButton(button_name)
    if (self.m_selectedButton == button_name) then
        return false
    end

    if self.m_selectedButton then
        self:inactivate(self.m_selectedButton)
    else
        for i,v in pairs(self.m_buttonMap) do
            if (i ~= button_name) then
                self:inactivate(i)
            end
        end
    end

    self.m_selectedButton = button_name

    self:activate(button_name)
    return true
end

-------------------------------------
-- function inactivate
-------------------------------------
function UIC_RadioButton:inactivate(button_name)
    local t_button_data = self.m_buttonMap[button_name]
    if (t_button_data['death']) then
        return
    end

    local button = t_button_data['button']
    button:setEnabled(true)

    local label = t_button_data['label']
    if (label) then
        label:setTextColor(cc.c4b(240, 215, 159, 255))
    end

    self:setRadioSelectedSprite(button_name, false)
end

-------------------------------------
-- function activate
-------------------------------------
function UIC_RadioButton:activate(button_name)
    local t_button_data = self.m_buttonMap[button_name]
    if (t_button_data['death']) then
        return
    end

    local button = t_button_data['button']
    button:setEnabled(false)
    
    local label = t_button_data['label']
    if (label) then
        label:setTextColor(cc.c4b(0, 0, 0, 255))
    end

    self:setRadioSelectedSprite(button_name, true)

    if self.m_changeCB then
        self.m_changeCB(button_name)
    end
end

-------------------------------------
-- function disable
-- @brief activate, inactivate 와 유기적으로 동작하는 것이 아님. 일방향
-------------------------------------
function UIC_RadioButton:disable(button_name, cb_func)
	local t_button_data = self.m_buttonMap[button_name]
    local button = t_button_data['button']
    button:setEnabled(false)
    
    -- disabled 상태일 때 ui 커스텀 할 수 있는 콜백 함수
    if (not cb_func) then        
	    button:setColor(cc.c4b(0, 0, 0, 255)) -- 디폴트, 버튼의 색상을 어둡게
    else
        cb_func(t_button_data)
    end

	self:setRadioSelectedSprite(button_name, false)
end

-------------------------------------
-- function setChangeCB
-------------------------------------
function UIC_RadioButton:setChangeCB(func)
    self.m_changeCB = func
end

-------------------------------------
-- function existButton
-------------------------------------
function UIC_RadioButton:existButton(name)
    for btn_name,v in pairs(self.m_buttonMap) do
        if (btn_name == name ) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function killBtn
-- @brief isActive/isInactive 함수에 영향 받지 않음
-------------------------------------
function UIC_RadioButton:killBtn(button_name, cb_func)
    local t_button_data = self.m_buttonMap[button_name]
    local button = t_button_data['button']
    button:setEnabled(false)
    
    -- killed 상태일 때 ui 커스텀 할 수 있는 콜백 함수
    if (not cb_func) then        
	    button:setColor(cc.c4b(0, 0, 0, 255)) -- 디폴트, 버튼의 색상을 어둡게
    else
        cb_func(t_button_data)
    end

	self:setRadioSelectedSprite(button_name, false)

    t_button_data['button'] = true
end

-------------------------------------
-- function setRadioSelectedSprite
-- @brief 라디오 버튼 선택 표시하는 스프라이트 turn off/on
-------------------------------------
function UIC_RadioButton:setRadioSelectedSprite(button_name, is_turn_on)
    local t_button_data = self.m_buttonMap[button_name]
    local sprite = t_button_data['sprite']
    if sprite then
        sprite:setVisible(is_turn_on)
    end
end