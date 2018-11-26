local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_TabUI_AutoGeneration
-------------------------------------
UI_TabUI_AutoGeneration = class(PARENT,{
        m_uiDepth = 'number',
        m_structTabUI = 'StructTabUI',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TabUI_AutoGeneration:init(ui_name, is_root, ui_depth, struct_tab_ui)
    self.m_uiName = 'UI_TabUI_AutoGeneration (' .. ui_name .. ')'
    local vars = self:load(ui_name)
    self.m_structTabUI = struct_tab_ui or StructTabUI()

    if is_root then
        UIManager:open(self, UIManager.SCENE)

        -- backkey 지정
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_TabUI_AutoGeneration')
        self.m_uiDepth = 1
    else
        self.m_uiDepth = ui_depth
    end

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TabUI_AutoGeneration:initUI()
    local vars = self.vars
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TabUI_AutoGeneration:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TabUI_AutoGeneration:refresh()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_TabUI_AutoGeneration:initTab()
    local vars = self.vars

    --
    local default_tab_y = nil
    local default_tab_x = nil
    local default_tab_name = nil

    for lua_name,node in pairs(vars) do
        if (pl.stringx.endswith(lua_name, 'TabBtn')) then
            local tab_name = pl.stringx.rpartition(lua_name,'TabBtn')

            local valid = true

            -- 탭 버튼
            if (not vars[tab_name .. 'TabBtn']) then
                valid = false
            end

            -- 탭 라벨
            if (not vars[tab_name .. 'TabLabel']) then
                valid = false
            end

            -- 탭 메뉴
            if (not vars[tab_name .. 'TabMenu']) then
                valid = false
            end

            if (valid == true) then
                self:addTabAuto(tab_name, vars, vars[tab_name .. 'TabMenu'])

                if (not default_tab_name) or (default_tab_y < node:getPositionY()) or (default_tab_x > node:getPositionX()) then
                    default_tab_name = tab_name
                    default_tab_y = node:getPositionY()
                    default_tab_x = node:getPositionX()
                end
                
            end
        end
    end

    -- 외부에서 설정된 초기 탭이 있다면
    local initial_tab = self.m_structTabUI:getDefaultTab(self.m_uiDepth)
    if not (initial_tab and self:existTab(initial_tab)) then
        initial_tab = nil
    end   

    if initial_tab then
        self:setTab(self.m_structTabUI:getDefaultTab(self.m_uiDepth))

    elseif default_tab_name then
        self:setTab(default_tab_name)
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_TabUI_AutoGeneration:onChangeTab(tab, first)
    local tab_name = tab
    local vars = self.vars

    if (first == true) then
        local ui = self:makeChildMenu(tab_name)
        if ui then
            vars[tab_name .. 'TabMenu']:addChild(ui.root)
        end
    end
end

-------------------------------------
-- function makeChildMenu
-------------------------------------
function UI_TabUI_AutoGeneration:makeChildMenu(tab_name)
    local vars = self.vars
    local ui_depth = (self.m_uiDepth + 1)
    local prefix = self.m_structTabUI:getPrefix()
    local ui_name = prefix .. tab_name .. '.ui'

    local ui = self.m_structTabUI:makeChildMenu(ui_name, ui_depth)
    if ui then
        return ui
    end

    if LuaBridge:isFileExist('res/' .. ui_name) then
        local ui = UI_TabUI_AutoGeneration(ui_name, false, ui_depth, self.m_structTabUI) -- ui_name, is_root, ui_depth, struct_tab_ui
        return ui
    end

    return nil
end


--@CHECK
UI:checkCompileError(UI_TabUI_AutoGeneration)
