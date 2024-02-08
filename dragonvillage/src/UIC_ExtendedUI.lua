local PARENT = UIC_Node

-------------------------------------
-- class UIC_ExtendedUI
-------------------------------------
UIC_ExtendedUI = class(PARENT, {
        m_node = 'cc.Menu', -- ui파일의 root
        vars = '',  -- ui파일의 vars
        m_bShow = 'boolean', -- 현재 보여지고 있는지 여부

        m_basePosX = 'number', -- 숨겨져있던 버튼들의 숨겨진 첫 위치 x
        m_basePosY = 'number', -- 숨겨져있던 버튼들의 숨겨진 첫 위치 y

        m_bgNode = 'cc.Node', -- 배경 노드
        m_lBtnInfo = 'list[BtnInfo]', -- 버튼들의 정보 {['btn']=UIC_Button, ['x']=x, ['y']=y}
        
        m_actionDuration = 'number', -- 액션 재생 시간
    })

local THIS = UIC_ExtendedUI

-------------------------------------
-- function init
-- @brief 숨겨있던 UI가 확장되는 형태의 UI Component
--        생성하는 과정에 여러 프로세스가 있어서 반드시 create함수로 생성할 것
-------------------------------------
function UIC_ExtendedUI:init(node)
    self.m_bShow = true
    self.m_actionDuration = 0.2
    self.m_basePosX = 0
    self.m_basePosY = 0
end

-------------------------------------
--- @function init_after
-------------------------------------
function UIC_ExtendedUI:init_after()
end

-------------------------------------
-- function create
-------------------------------------
function UIC_ExtendedUI:create(ui_res)
    -- UI파일을 읽어옴
    local ui = UI()
    local vars = ui:load(ui_res)

    -- UIC_ExtendedUI instance를 생성
    local extended_ui = UIC_ExtendedUI(ui.root)
    local self = extended_ui
    self.vars = vars

    do -- 숨겨져있던 버튼들의 숨겨진 첫 위치를 지정
        local base_node = vars['baseNode']
        if base_node then
            local x, y = base_node:getPosition()
            self.m_basePosX = x
            self.m_basePosY = y
        end
    end

    do -- luaname으로 버튼들의 정보를 생성 'Btn'으로 종료되는 node
        self.m_lBtnInfo = {}
        for luaname,node in pairs(vars) do
            if pl.stringx.endswith(luaname, 'Btn') then
                -- 버튼 정보 생성 후 리스트에 저장
                local t_btn_info = {}
                t_btn_info['btn'] = node

                local x, y = node:getPosition()
                t_btn_info['x'] = x
                t_btn_info['y'] = y
                table.insert(self.m_lBtnInfo, t_btn_info)
            end
        end
    end

    -- 배경 이미지 지정
    self.m_bgNode = vars['bg'] or self.m_node

    -- 첫 위치를 잡아줌
    self:initFirst()


    return self
end

-------------------------------------
-- function toggleVisibility
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

    local bg_node = self.m_bgNode
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

    local bg_node = self.m_bgNode
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

    local bg_node = self.m_bgNode
    bg_node:stopAllActions()
    cca.runAction(bg_node, cc.Sequence:create(cc.FadeTo:create(duration / 2, 0), cc.Hide:create()))
end