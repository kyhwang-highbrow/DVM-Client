local PARENT = UIC_Button

-------------------------------------
-- class UIC_CheckBox
-------------------------------------
UIC_CheckBox = class(PARENT, {
        m_bChecked = 'boolean',
        m_spriteNode = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_CheckBox:init(node, sprite_node, checked)
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
    self:setChecked(not self.m_bChecked)
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
end