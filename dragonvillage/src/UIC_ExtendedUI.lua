local PARENT = UIC_Node

-------------------------------------
-- class UIC_ExtendedUI
-------------------------------------
UIC_ExtendedUI = class(PARENT, {
        m_node = 'cc.Menu',
        vars = '',
        m_bShow = 'boolean',

        m_basePosX = 'number',
        m_basePosY = 'number',

        m_lBtnInfo = 'list[BtnInfo]',
        m_actionDuration = 'number',
    })

local THIS = UIC_ExtendedUI

-------------------------------------
-- function init
-------------------------------------
function UIC_ExtendedUI:init(node)
    self.m_bShow = true
    self.m_actionDuration = 0.2
end

-------------------------------------
-- function create
-------------------------------------
function UIC_ExtendedUI:create(ui_res)
    local ui = UI()
    local vars = ui:load(ui_res)

    local extended_ui = UIC_ExtendedUI(ui.root)
    local self = extended_ui
    self.vars = vars


    do
        local base_node = vars['baseNode']
        if base_node then
            local x, y = base_node:getPosition()
            self.m_basePosX = x
            self.m_basePosY = y
        end
    end

    do
        self.m_lBtnInfo = {}
        for luaname,node in pairs(vars) do
            if pl.stringx.endswith(luaname, 'Btn') then
                local t_btn_info = {}
                t_btn_info['btn'] = node
                local x, y = node:getPosition()
                t_btn_info['x'] = x
                t_btn_info['y'] = y
                table.insert(self.m_lBtnInfo, t_btn_info)
            end
        end

        ccdump(self.m_lBtnInfo)
    end

    self:initFirst()


    return self
end

-------------------------------------
-- function ToggleVisibility
-------------------------------------
function UIC_ExtendedUI:toggleVisibility()
    if self.m_bShow then
        self:hide()
    else
        self:show()
    end
end

-------------------------------------
-- function initFirst
-------------------------------------
function UIC_ExtendedUI:initFirst()
    self.m_bShow = false

    local x = self.m_basePosX
    local y = self.m_basePosY

    for i,v in pairs(self.m_lBtnInfo) do
        local btn = v['btn']
        btn:stopAllActions()

        btn:setPosition(x, y)
        btn:setOpacity(0)

        btn:setOriginData()
        btn:setEnabled(false)
    end

    local bg_node = self.vars['bg']
    bg_node:stopAllActions()
    bg_node:setVisible(false)
    bg_node:setOpacity(0)
end

-------------------------------------
-- function show
-------------------------------------
function UIC_ExtendedUI:show()
    if (self.m_bShow) then
        return
    end

    self.m_bShow = true

    local duration = self.m_actionDuration

    for i,v in pairs(self.m_lBtnInfo) do
        local btn = v['btn']
        btn:stopAllActions()

        local x = v['x']
        local y = v['y']

        local move_to = cc.MoveTo:create(duration, cc.p(x, y))
        local scale_to = cc.ScaleTo:create(duration, 1)
        local spawn = cc.Spawn:create(move_to)
        cca.runAction(btn, cc.EaseInOut:create(spawn, 2))
        --local action = cc.EaseElasticIn:create(spawn, 1.5)
        --cca.runAction(btn, action)

        local function func()
            btn:setOriginData()
            btn:setEnabled(true)
        end

        local fade_to = cc.FadeTo:create(duration, 255)
        cca.runAction(btn, cc.Sequence:create(fade_to, cc.CallFunc:create(func)))

        btn:setVisible(true)
    end

    local bg_node = self.vars['bg']
    bg_node:stopAllActions()
    bg_node:setVisible(true)
    cca.runAction(bg_node, cc.Sequence:create(cc.FadeTo:create(duration * 2, 255)))
end

-------------------------------------
-- function hide
-------------------------------------
function UIC_ExtendedUI:hide()
    if (not self.m_bShow) then
        return
    end

    --self:cancelReserveHide()

    self.m_bShow = false

    local duration = self.m_actionDuration
    local x = self.m_basePosX
    local y = self.m_basePosY

    for i,v in pairs(self.m_lBtnInfo) do
        local btn = v['btn']
        btn:stopAllActions()

        local move_to = cc.MoveTo:create(duration, cc.p(x, y))
        local scale_to = cc.ScaleTo:create(duration, 0)
        local spawn = cc.Spawn:create(move_to)
        cca.runAction(btn, cc.EaseInOut:create(spawn, 2))
        --local action = cc.EaseElasticIn:create(spawn, 1.5)
        --cca.runAction(btn, action)

        btn:setOriginData()
        btn:setEnabled(false)

        local fade_to = cc.FadeTo:create(duration, 0)
        cca.runAction(btn, fade_to, cc.Hide:create())
    end

    local bg_node = self.vars['bg']
    bg_node:stopAllActions()
    cca.runAction(bg_node, cc.Sequence:create(cc.FadeTo:create(duration / 2, 0), cc.Hide:create()))
end