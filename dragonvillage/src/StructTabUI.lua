local PARENT = Structure

-------------------------------------
-- class StructTabUI
-- @instance struct_tab_ui
-- @brief UI_TabUI_AutoGeneration 생성 시 필요한 요소 Struct
-------------------------------------
StructTabUI = class(PARENT, {
        m_lDefaultTab = 'list',             -- Depth에 따라 초기화 탭 지정 
        m_prefix = 'string',                -- 자동으로 생성되는 UI에 접두사 붙여서 구별(UIMaker에서)
        m_funcMakeChildMenu = 'function',   -- UI 생성 함수(커스텀 가능)
        m_funcSetAfter = 'function',        -- UI 생성 후 후처리 함수(커스텀 가능)
    })

local THIS = StructTabUI

-------------------------------------
-- function init
-------------------------------------
function StructTabUI:init(data)
    self.m_prefix = ''
    self.m_lDefaultTab = {}
    self.m_funcMakeChildMenu = nil
    self.m_funcSetAfter = nil
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
        return self.m_funcMakeChildMenu(self, ui_name, ui_depth)
    end
    
    return nil
end

-------------------------------------
-- function setMakeChildMenuFunc
-------------------------------------
function StructTabUI:setMakeChildMenuFunc(func)
    self.m_funcMakeChildMenu = func
end

-------------------------------------
-- function setAfterFunc
-------------------------------------
function StructTabUI:setAfterFunc(func)
    self.m_funcSetAfter = func
end

-------------------------------------
-- function setAfter
-------------------------------------
function StructTabUI:setAfter(ui_name, ui)
    if (self.m_funcSetAfter) then
        self.m_funcSetAfter(ui_name, ui)
    end
end