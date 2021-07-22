local PARENT = UIC_Button

-------------------------------------
-- class UIC_CheckBox
-------------------------------------
UIC_CheckBox = class(PARENT, {
        m_bChecked = 'boolean',
        m_spriteNode = '',
        m_manualMode = 'boolean',
        m_onChangeCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_CheckBox:init(node, sprite_node, checked)
    self.m_manualMode = false
    self.m_bChecked = false
    self.m_spriteNode = sprite_node
    self.m_node:registerScriptTapHandler(function() UIC_CheckBox.tapHandler(self) end)
    self:setChecked(checked)
end

-------------------------------------
-- function isChecked
-------------------------------------
function UIC_CheckBox:isChecked()
    return self.m_bChecked
end

-------------------------------------
-- function tapHandler
-------------------------------------
function UIC_CheckBox.tapHandler(self)
    if (self.m_manualMode == false) then
        self:setChecked(not self.m_bChecked)
    end
    UIC_Button.tapHandler(self)
end

-------------------------------------
-- function setChecked
-------------------------------------
function UIC_CheckBox:setChecked(checked)
    if (self.m_bChecked == checked) then
        return
    end

    self.m_bChecked = checked
    if self.m_spriteNode then
        self.m_spriteNode:setVisible(checked)
    end

    if self.m_onChangeCB then
        self.m_onChangeCB(checked)
    end
end

-------------------------------------
-- function setManualMode
-------------------------------------
function UIC_CheckBox:setManualMode(manual_mode)
    self.m_manualMode = manual_mode
end

-------------------------------------
-- function setChangeCB
-- @param function func(bool checked) end
-------------------------------------
function UIC_CheckBox:setChangeCB(func)
    self.m_onChangeCB = func
end