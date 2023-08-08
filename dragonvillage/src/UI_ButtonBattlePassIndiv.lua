local PARENT = UI_ManagedButton

-------------------------------------
-- class UI_ButtonBattlePassIndiv
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at 
-------------------------------------
UI_ButtonBattlePassIndiv = class(PARENT, {
        m_bActive = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonBattlePassIndiv:init()
    self:load('button_battle_pass_indiv.ui')
    self.m_bActive = false

    local vars = self.vars
    vars['passBtn']:registerScriptTapHandler(
        function () 
            self:click_battlePassBtn()
        end)
end

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonBattlePassIndiv:isActive()
    return self.m_bActive
end

-------------------------------------
-- function update
-- @brief UI_Lobby에서 매 프레임 호출됨
-------------------------------------
function UI_ButtonBattlePassIndiv:update(dt)

end

-------------------------------------
-- function click_battlePassBtn
-------------------------------------
function UI_ButtonBattlePassIndiv:click_battlePassBtn()
    local list = g_indivPassData:getEventRepresentProductList()

    if #list == 0 then
        local cb_func = function()
            self:updateButtonStatus()
            UIManager:toastNotificationGreen(Str('이벤트가 종료되었습니다.'))
        end

        g_indivPassData:request_info(cb_func)
        return
    end

    local ui = UI_IndivPassScene()
end

-------------------------------------
-- function updateButtonStatus
-------------------------------------
function UI_ButtonBattlePassIndiv:updateButtonStatus()
    local vars = self.vars

    local list = g_indivPassData:getEventRepresentProductList()
    local is_available = #list > 0

    vars['passBtn']:setVisible(is_available)
    self.m_bActive = is_available

    local is_available_reward = g_indivPassData:isAvailableIndivPassExpPointReward()
    vars['passNotiSprite']:setVisible(is_available_reward)

end