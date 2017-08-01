local PARENT = UI

-------------------------------------
-- class UI_LobbyObject
-------------------------------------
UI_LobbyObject = class(PARENT, {
        m_type = 'number',
     })

UI_LobbyObject.BATTLE = 1
UI_LobbyObject.BOARD = 2
UI_LobbyObject.DRAGON_MANAGE = 3
UI_LobbyObject.SHIP = 4
UI_LobbyObject.SHOP = 5

t_object_pos = {}
t_object_pos[UI_LobbyObject.BATTLE] = {x=-1679, y=40.5}
t_object_pos[UI_LobbyObject.BOARD] = {x=652.5, y=96}
t_object_pos[UI_LobbyObject.DRAGON_MANAGE] = {x=1784.5, y=54}
t_object_pos[UI_LobbyObject.SHIP] = {x=-1212, y=93}
t_object_pos[UI_LobbyObject.SHOP] = {x=1081.5, y=94}

-------------------------------------
-- function init
-------------------------------------
function UI_LobbyObject:init(type)
    self.m_type = type

    local ui_name = ''

    if (type == UI_LobbyObject.BATTLE) then
        ui_name = 'lobby_btn_dungeon.ui'
    elseif (type == UI_LobbyObject.BOARD) then
        ui_name = 'lobby_btn_quest.ui'
    elseif (type == UI_LobbyObject.DRAGON_MANAGE) then
        ui_name = 'lobby_dragon_manage.ui'
    elseif (type == UI_LobbyObject.SHIP) then
        ui_name = 'lobby_btn_adventure.ui'
    elseif (type == UI_LobbyObject.SHOP) then
        ui_name = 'lobby_btn_shop.ui'
    end

    local vars = self:load(ui_name)
    vars['image']:setOpacity(0)
    self:positioning()

    self:makeKeypad(self.root)
    self.vars['labelNode']:setScale(0)
end

-------------------------------------
-- function positioning
-------------------------------------
function UI_LobbyObject:positioning()
    local type = self.m_type

    local pos = t_object_pos[type]
    self.root:setPosition(pos['x'], pos['y'])
end

-------------------------------------
-- function setActive
-------------------------------------
function UI_LobbyObject:setActive(active)
    local action = nil
    if active then
        action = cc.EaseInOut:create(cc.ScaleTo:create(0.15, 1), 2)
    else
        action = cc.EaseInOut:create(cc.ScaleTo:create(0.15, 0), 2)
    end

    cca.runAction(self.vars['labelNode'], action, 100)
end

-------------------------------------
-- function MakeLobbyObjectUI
-------------------------------------
function MakeLobbyObjectUI(parent, ui_lobby, type)
    local ui = UI_LobbyObject(type)
    parent:addChild(ui.root, 5)

    if ui_lobby then
        if (type == UI_LobbyObject.BATTLE) then
            ui.vars['clickBtn']:registerScriptTapHandler(function() ui_lobby:click_battleBtn() end)

        elseif (type == UI_LobbyObject.BOARD) then
            ui.vars['clickBtn']:registerScriptTapHandler(function() ui_lobby:click_questBtn() end)

        elseif (type == UI_LobbyObject.DRAGON_MANAGE) then
            ui.vars['clickBtn']:registerScriptTapHandler(function() ui_lobby:click_dragonManageBtn() end)

        elseif (type == UI_LobbyObject.SHIP) then
            ui.vars['clickBtn']:registerScriptTapHandler(function() ui_lobby:click_adventureBtn() end)

        elseif (type == UI_LobbyObject.SHOP) then
            ui.vars['clickBtn']:registerScriptTapHandler(function() ui_lobby:click_shopBtn() end)
        else
            error('type : ' .. type)
        end
    end
    
    return ui
end












-------------------------------------
-- function makeKeypad
-- @brief 키패드 생성 (윈도우에서 멀티터치 대용으로 사용)
-------------------------------------
function UI_LobbyObject:makeKeypad(target_node)
    local listener = cc.EventListenerKeyboard:create()

    listener:registerScriptHandler(function(keyCode, event) return self:onKeyPressed(keyCode, event) end, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(function(keyCode, event) return self:onKeyReleased(keyCode, event) end, cc.Handler.EVENT_KEYBOARD_RELEASED)

    local eventDispatcher = target_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onKeyPressed
-------------------------------------
function UI_LobbyObject:onKeyPressed(keyCode, event)
end

-------------------------------------
-- function onKeyReleased
-------------------------------------
function UI_LobbyObject:onKeyReleased(keyCode, event)
    -- 현재 웨이브를 클리어
    if (keyCode == KEY_R) then
        self:positioning()
    elseif (keyCode == KEY_E) then
        self.root:runAction(cc.ToggleVisibility:create())
    end
end