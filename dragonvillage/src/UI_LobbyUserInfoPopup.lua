local PARENT = UI

-------------------------------------
-- class UI_LobbyUserInfoPopup
-------------------------------------
UI_LobbyUserInfoPopup = class(PARENT, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_LobbyUserInfoPopup:init(t_user_info)
    local vars = self:load('lobby_user_info_02.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_LobbyUserInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh(t_user_info)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_LobbyUserInfoPopup:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_LobbyUserInfoPopup:initUI()
    local vars = self.vars
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LobbyUserInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-- @brief dragon_id로 드래곤의 상세 정보를 출력
-------------------------------------
function UI_LobbyUserInfoPopup:refresh(t_user_info)
    local vars = self.vars

    vars['guildLabel']:setString(t_user_info['guild'])
    vars['nameLabel']:setString(t_user_info['nick'])
    vars['lvLabel']:setString(Str('레벨 {1}', t_user_info['lv']))

    local t_dragon_data = t_user_info['leader']
    local dragon_card = UI_DragonCard(t_dragon_data)
    vars['dragonNode']:addChild(dragon_card.root)


    
    dragon_card.vars['clickBtn']:registerScriptTapHandler(function()
        UI_SimpleDragonInfoPopup(t_dragon_data)
    end)

end

--@CHECK
UI:checkCompileError(UI_LobbyUserInfoPopup)
