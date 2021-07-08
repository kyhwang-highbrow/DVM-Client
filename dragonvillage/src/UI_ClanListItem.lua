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
    local vars = self:load('clan_item_info_new.ui')

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

    -- 클랜 레벨 + 이름
    local clan_name = struct_clan:getClanLvWithName()
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

    -- 지원 레벨
    local join_lv = struct_clan:getJoinLv()
    vars['levelLabel']:setString(Str('{1}레벨 이상', join_lv))
    
    -- 필수 참여 컨텐츠
    for idx = 1, 4 do
        local label = vars['contentLabel'..idx]
        label:setColor(COLOR['wood'])
    end

    local l_category = struct_clan['category']
    for idx, v in ipairs(l_category) do
        local idx = g_clanData:getNeedCategryIdxWithName(v)
        if idx then
            local label = vars['contentLabel'..idx]

            if label then
                -- 선택된 필수 참여 컨텐츠
                label:setColor(COLOR['GOLD'])
            end
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanListItem:initButton()
    local vars = self.vars
    vars['requestBtn']:registerScriptTapHandler(function() self:click_requestBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanListItem:refresh()
    local vars = self.vars

    local struct_clan = self.m_structClan
    local clan_object_id = struct_clan:getClanObjectID()
    
    -- 가입 신청 여부에 따라 "가입", "취소" 버튼 구분
    if g_clanData:isRequestedJoin(clan_object_id) then
        vars['cancelBtn']:setVisible(true)
        vars['requestBtn']:setVisible(false)
    else
        vars['cancelBtn']:setVisible(false)
        vars['requestBtn']:setVisible(true)
    end
end

-------------------------------------
-- function click_requestBtn
-------------------------------------
function UI_ClanListItem:click_requestBtn()
    local struct_clan = self.m_structClan
    local clan_object_id = struct_clan:getClanObjectID()

    local function finish_cb(ret)

        -- 클랜에 가입 신청 시 즉시 가입이 되었을 경우
        if g_clanData:isNeedClanInfoRefresh() then

            local function ok_cb()
                g_highlightData:setDirty(true)
                UINavigator:closeClanUI()
                UINavigator:goTo('clan')
            end

            local msg = Str('축하합니다. 클랜에 가입되었습니다.')
            local sub_msg = Str('(클랜 정보 화면으로 이동합니다)')
            MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg, ok_cb)
        else
            UIManager:toastNotificationGreen(Str('가입 신청을 했습니다.'))
            self:delThis()
        end
    end

    local fail_cb = nil

    if struct_clan:isAutoJoin() then
        local msg = Str('자동 가입이 설정된 클랜입니다.\n가입하시겠습니까?')
        local function ok_cb()
            g_clanData:request_join(finish_cb, fail_cb, clan_object_id) 
        end
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb)
    else
        g_clanData:request_join(finish_cb, fail_cb, clan_object_id) 
    end
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_ClanListItem:click_cancelBtn()
    local struct_clan = self.m_structClan
    local clan_object_id = struct_clan:getClanObjectID()

    local function finish_cb(ret)
        UIManager:toastNotificationGreen(Str('가입 신청을 취소했습니다.'))
        self:delThis()
    end

    local fail_cb = nil

    g_clanData:request_joinCancel(finish_cb, fail_cb, clan_object_id)
end


-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_ClanListItem:click_infoBtn()
    local clan_object_id = self.m_structClan:getClanObjectID()

    local function close_cb()
        self:refresh()
    end

    g_clanData:requestClanInfoDetailPopup(clan_object_id, close_cb)
end
