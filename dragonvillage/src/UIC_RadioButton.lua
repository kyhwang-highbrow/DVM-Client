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
-- function setSelectedButton
-------------------------------------
function UIC_RadioButton:setSelectedButton(button_name)
    if (self.m_selectedButton == button_name) then
        return false
    end

    if self.m_selectedButton then
        self:deactivate(self.m_selectedButton)
    else
        for i,v in pairs(self.m_buttonMap) do
            if (i ~= button_name) then
                self:deactivate(i)
            end
        end
    end

    self.m_selectedButton = button_name

    self:activate(button_name)
    return true
end

-------------------------------------
-- function deactivate
-------------------------------------
function UIC_RadioButton:deactivate(button_name)
    local t_button_data = self.m_buttonMap[button_name]

    local button = t_button_data['button']
    button:setEnabled(true)

    local sprite = t_button_data['sprite']
    if sprite then
        sprite:setVisible(false)
    end
end

-------------------------------------
-- function activate
-------------------------------------
function UIC_RadioButton:activate(button_name)
    local t_button_data = self.m_buttonMap[button_name]

    local button = t_button_data['button']
    button:setEnabled(false)

    local sprite = t_button_data['sprite']
    if sprite then
        sprite:setVisible(true)
    end

    if self.m_changeCB then
        self.m_changeCB(button_name)
    end
end

-------------------------------------
-- function setChangeCB
-------------------------------------
function UIC_RadioButton:setChangeCB(func)
    self.m_changeCB = func
end