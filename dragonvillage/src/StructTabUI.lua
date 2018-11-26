local PARENT = Structure

-------------------------------------
-- class StructTabUI
-- @instance struct_tab_ui
-------------------------------------
StructTabUI = class(PARENT, {
        m_lDefaultTab = 'list',
        m_prefix = 'string',
        m_funcMakeChildMenu = 'function',
    })

local THIS = StructTabUI

-------------------------------------
-- function init
-------------------------------------
function StructTabUI:init(data)
    self.m_prefix = ''
    self.m_lDefaultTab = {}
end

-------------------------------------
-- function getClassName
-- @brief 클래스명 리턴
-------------------------------------
function StructTabUI:getClassName()
    return 'StructTabUI'
end

-------------------------------------
-- function getThis
-- @brief 클래스를 리턴 (classDef)
-------------------------------------
function StructTabUI:getThis()
    return THIS
end

-------------------------------------
-- function setPrefix
-------------------------------------
function StructTabUI:setPrefix(prefix)
    self.m_prefix = prefix
end

-------------------------------------
-- function getPrefix
-------------------------------------
function StructTabUI:getPrefix()
    return self.m_prefix or ''
end

-------------------------------------
-- function setDefaultTab
-------------------------------------
function StructTabUI:setDefaultTab(...)
    local args = {...}

    self.m_lDefaultTab = {}
    for i,v in ipairs(args) do
        self.m_lDefaultTab[i] = v
    end
end

-------------------------------------
-- function getDefaultTab
-------------------------------------
function StructTabUI:getDefaultTab(idx)
    return self.m_lDefaultTab[idx]
end

-------------------------------------
-- function makeChildMenu
-------------------------------------
function StructTabUI:makeChildMenu(ui_name, ui_depth)

    if self.m_funcMakeChildMenu then
        return self.m_funcMakeChildMenu(ui_name, ui_depth)
    end
    
    return nil
end

-------------------------------------
-- function setMakeChildMenuFunc
-------------------------------------
function StructTabUI:setMakeChildMenuFunc(func)
    self.m_funcMakeChildMenu = func
end