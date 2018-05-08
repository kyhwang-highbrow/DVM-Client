local PARENT = UI_GamePause

-------------------------------------
-- class UI_GamePause_Arena
-------------------------------------
UI_GamePause_Arena = class(PARENT, {
        m_bFriendMatch = 'boolean',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GamePause_Arena:init(stage_id, gamekey, start_cb, end_cb)
    self.m_bFriendMatch = g_gameScene.m_bFriendMatch or false
    local vars = self.vars

    if (self.m_bFriendMatch) then
        vars['contentsLabel']:setString(Str('친구대전'))
    end
end

-------------------------------------
-- function click_homeButton
-- @brief 로비로 가기 버튼
-------------------------------------
function UI_GamePause_Arena:click_homeButton()
    local function ok_cb()
	    local is_use_loading = true
        local scene = SceneLobby(is_use_loading)
        scene:runScene()
    end

    self:confirmExit(ok_cb)
end

-------------------------------------
-- function click_retryButton
-- @brief 다시하기 버튼
-------------------------------------
function UI_GamePause_Arena:click_retryButton()
    local function ok_cb()
        local target = self.m_bFriendMatch and 'friend' or 'colosseum' 
        UINavigator:goTo(target)
    end

    self:confirmExit(ok_cb)
end