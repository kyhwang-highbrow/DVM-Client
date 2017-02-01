local PARENT = UI_FriendPopupTab

-------------------------------------
-- class UI_FriendPopupTabRecommend
-------------------------------------
UI_FriendPopupTabRecommend = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPopupTabRecommend:init(friend_popup_ui)
end

-------------------------------------
-- function initFirst
-------------------------------------
function UI_FriendPopupTabRecommend:initFirst()
    local vars = self.vars
    vars['findBtn']:registerScriptTapHandler(function() self:click_findBtn() end)
end

-------------------------------------
-- function onEnterFriendPopupTab
-------------------------------------
function UI_FriendPopupTabRecommend:onEnterFriendPopupTab(first)
    if first then
        self:initFirst()
    end
end

-------------------------------------
-- function click_findBtn
-------------------------------------
function UI_FriendPopupTabRecommend:click_findBtn()
    local vars = self.vars

    local str = vars['findEditBox']:getText()
    if (str == '') then
        MakeSimplePopup(POPUP_TYPE.OK, Str('검색할 친구의 닉네임을 입력하세요.'))
        return
    end

    local t_user_info = {}
    --UI_LobbyUserInfoPopup(t_user_info)
end
