local PARENT = UI_FriendPopupTab

-------------------------------------
-- class UI_FriendPopupTabInvite
-------------------------------------
UI_FriendPopupTabInvite = class(PARENT, {
        m_tableView = 'UIC_TableView',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPopupTabInvite:init(friend_popup_ui)
    local vars = self.vars

    vars['soulMateBtn']:registerScriptTapHandler(function() self:click_soulMateBtn() end)
    vars['bestFriendBtn']:registerScriptTapHandler(function() self:click_bestFriendBtn() end)
end

-------------------------------------
-- function onEnterFriendPopupTab
-------------------------------------
function UI_FriendPopupTabInvite:onEnterFriendPopupTab(first)
end

-------------------------------------
-- function click_soulMateBtn
-------------------------------------
function UI_FriendPopupTabInvite:click_soulMateBtn()
    local vars = self.vars
    local nick = vars['smEditBox']:getText()
    self:requestSpecialFriend('soulmate', nick)
end

-------------------------------------
-- function click_bestFriendBtn
-------------------------------------
function UI_FriendPopupTabInvite:click_bestFriendBtn()
    local vars = self.vars
    local nick = vars['bfEditBox']:getText()
    self:requestSpecialFriend('bestfriend', nick)
end

-------------------------------------
-- function requestSpecialFriend
-------------------------------------
function UI_FriendPopupTabInvite:requestSpecialFriend(type, nick)
    if (nick == '') then
        MakeSimplePopup(POPUP_TYPE.OK, Str('추가할 친구의 닉네임을 입력하세요.'))
        return
    end

    local find_friend
    local add_friend

    -- 유저 검색
    find_friend = function()
        local function finish_cb(ret)
            local l_user_list = ret['users_list']
            local t_friend_info = l_user_list[1]

            if (not t_friend_info) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('[{1}]님을 찾지 못하였습니다.', nick))
            else
                add_friend(t_friend_info['uid'])
            end
        end

        -- 친구 검색
        g_friendData:request_find(nick, finish_cb)
    end

    -- 특별 친구 추가
    add_friend = function(friend_uid)
        -- 파라미터
        local uid = g_userData:get('uid')

        -- 콜백 함수
        local function success_cb(ret)
        end

        local friend_type
        if (type == 'soulmate') then
            friend_type = 3

        elseif (type == 'bestfriend') then
            friend_type = 2

        else
            error('type : ' .. type)
        end

        -- 네트워크 통신 UI 생성
        local ui_network = UI_Network()
        ui_network:setUrl('/socials/add_friends')
        ui_network:setParam('uid', uid)
        ui_network:setParam('friends', friend_uid)
        ui_network:setParam('type', friend_type)
        ui_network:setSuccessCB(success_cb)
        ui_network:setRevocable(true)
        ui_network:setReuse(false)
        ui_network:request()
    end


    find_friend()
end