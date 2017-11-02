local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanListItem
-------------------------------------
UI_ClanListItem = class(PARENT, {
        m_structClan = 'StructClan',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanListItem:init(data)
    self.m_structClan = data
    local vars = self:load('clan_item_info.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanListItem:initUI()
    local vars = self.vars

    local struct_clan = self.m_structClan

    -- 클랜 마크(문장)
    local icon = struct_clan:makeClanMarkIcon()
    vars['userNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan:getClanName()
    vars['nameLabel']:setString(clan_name)
    
    -- 마스터 닉네임
    local master_nick = struct_clan:getMasterNick()
    vars['masterLabel']:setString(master_nick)

    -- 클랜원
    local member_cnt_text = struct_clan:getMemberCntText()
    vars['memberLabel']:setString(member_cnt_text)

    -- 자동 가입 여부
    local is_auto_join = struct_clan:isAutoJoin()
    vars['autoNode']:setVisible(is_auto_join)

    -- 클랜 소개
    local intro_text = struct_clan:getClanIntroText()
    vars['introduceLabel']:setString(intro_text)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanListItem:initButton()
    local vars = self.vars
    vars['requestBtn']:registerScriptTapHandler(function() self:click_requestBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanListItem:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_requestBtn
-------------------------------------
function UI_ClanListItem:click_requestBtn()
    local clan_object_id = self.m_structClan:getClanObjectID()

    local function finish_cb(ret)

        -- 클랜에 가입 신청 시 즉시 가입이 되었을 경우
        if g_clanData:isNeedClanInfoRefresh() then

            local function ok_cb()
                UINavigator:closeClanUI()
                UINavigator:goTo('clan')
            end

            local msg = Str('축하합니다. 클랜에 가입되었습니다.')
            local sub_msg = Str('(클랜 정보 화면으로 이동합니다)')
            MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg, ok_cb)
        end
    end

    local fail_cb = nil

    g_clanData:request_join(finish_cb, fail_cb, clan_object_id) 
end