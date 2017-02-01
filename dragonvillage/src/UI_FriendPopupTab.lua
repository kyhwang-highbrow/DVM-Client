-------------------------------------
-- class UI_FriendPopupTab
-------------------------------------
UI_FriendPopupTab = class({
        vars = 'table',
        m_friendPopup = 'UI_FriendPopup',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPopupTab:init(friend_popup_ui)
    self.m_friendPopup = friend_popup_ui
    self.vars = self.m_friendPopup.vars
end

-------------------------------------
-- function onEnterFriendPopupTab
-------------------------------------
function UI_FriendPopupTab:onEnterFriendPopupTab(first)
end