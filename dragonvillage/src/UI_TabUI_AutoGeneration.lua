local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_TabUI_AutoGeneration
-------------------------------------
UI_TabUI_AutoGeneration = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TabUI_AutoGeneration:init(ui_name, is_root)
    local vars = self:load(ui_name)

    if is_root then
        UIManager:open(self, UIManager.SCENE)

        -- backkey 지정
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_TabUI_AutoGeneration')
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


    if default_tab_name then
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
        local ui_name = 'help_' .. tab_name .. '.ui'
        if LuaBridge:isFileExist('res/' .. ui_name) then
            local ui = UI_TabUI_AutoGeneration(ui_name, false) -- ui_name, is_root
            vars[tab_name .. 'TabMenu']:addChild(ui.root)
        end
    end

    -- 탭할때마다 액션 
    --self:doActionReset()
    --self:doAction(nil, false)
end

--@CHECK
UI:checkCompileError(UI_TabUI_AutoGeneration)
