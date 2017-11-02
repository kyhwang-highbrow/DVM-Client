local PARENT = UI

-------------------------------------
-- class UI_ClanSetting
-------------------------------------
UI_ClanSetting = class(PARENT, {
        m_bChangedClanSet = 'bool',
        m_bRet = 'bool',

        --
        m_structClanMark = 'StructClanMark',
        m_clanAutoJoin = 'boolean',
        m_clanIntroText = 'string',
        m_clanNoticeText = 'string',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanSetting:init()
    local vars = self:load('clan_setting.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_ClanSetting'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanSetting')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    g_clanData.m_needClanSetting = false
    self.m_bRet = false
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanSetting:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanSetting:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanSetting:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['disbandBtn']:registerScriptTapHandler(function() self:click_disbandBtn() end)
    vars['leaveBtn']:registerScriptTapHandler(function() self:click_leaveBtn() end)
    vars['markBtn']:registerScriptTapHandler(function() self:click_markBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanSetting:refresh()
    local vars = self.vars

    local struct_clan = g_clanData:getClanStruct()

    -- 클랜 마크
    local struct_clan_mark = self:getClanMarkStruct()
    local icon = struct_clan_mark:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan:getName()
    vars['nameLabel']:setString(clan_name)

    -- 클랜 가입 방식
    
    -- 클랜 소개
    local clan_intro = struct_clan:getIntro()

    -- 클랜 공지사항
    local clan_notice = struct_clan:getNotice()

    -- 탈퇴 / 해체 버튼 처리
    local my_nic = g_userData:get('nick')
    local master_nic = struct_clan:getMaster()
    local is_master = (my_nic == master_nic)
    vars['disbandBtn']:setVisible(is_master)
    vars['leaveBtn']:setVisible(not is_master)
end

-------------------------------------
-- function click_disbandBtn
-- @brief 클랜 해체
-------------------------------------
function UI_ClanSetting:click_disbandBtn()

    local ask_func
    local request_func
    local popup_func
    local finish_cb

    ask_func = function()
        local msg = Str('클랜을 해체하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_func)
    end

    request_func = function()
        g_clanData:request_clanDestroy(popup_func)
    end

    popup_func = function()
        local msg = Str('클랜이 해체되었습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg, finish_cb)
    end

    finish_cb = function(ret)
        if g_clanData:isNeedClanInfoRefresh() then
            UINavigator:closeClanUI()
            UINavigator:goTo('clan')
        end
    end

    ask_func()
end

-------------------------------------
-- function click_leaveBtn
-- @brief 클랜 탈퇴
-------------------------------------
function UI_ClanSetting:click_leaveBtn()

    local ask_func
    local request_func
    local popup_func
    local finish_cb

    ask_func = function()
        local msg = Str('클랜을 탈퇴하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_func)
    end

    request_func = function()
        g_clanData:request_clanExit(popup_func)
    end

    popup_func = function()
        local msg = Str('클랜에서 탈퇴하였습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg, finish_cb)
    end

    finish_cb = function(ret)
        if g_clanData:isNeedClanInfoRefresh() then
            UINavigator:closeClanUI()
            UINavigator:goTo('clan')
        end
    end

    ask_func()
end

-------------------------------------
-- function click_markBtn
-- @brief 클랜 마크
-------------------------------------
function UI_ClanSetting:click_markBtn()
    local ui = UI_ClanMark(self:getClanMarkStruct())

    local function close_cb()
        if ui.m_bChanged then
            self.m_bChangedClanSet = true
            self.m_structClanMark = ui.m_structClanMark
            self:refresh()
        end
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_okBtn
-- @brief 적용 버튼
-------------------------------------
function UI_ClanSetting:click_okBtn()
    local finish_cb = function()
        self.m_bRet = true
        local msg = Str('변경사항이 적용되었습니다.')
        local ok_cb = function()
            self:close()
        end
        MakeSimplePopup(POPUP_TYPE.OK, msg, ok_cb)
    end

    local fail_cb = nil

    local intro = self.m_clanIntroText
    local notice = self.m_clanNoticeText
    local join = self.m_clanAutoJoin
    local mark = nil
    if self.m_structClanMark then
        mark = self.m_structClanMark:tostring()
    end

    g_clanData:request_clanSetting(finish_cb, fail_cb, intro, notice, join, mark)
end

-------------------------------------
-- function getClanMarkStruct
-- @brief
-------------------------------------
function UI_ClanSetting:getClanMarkStruct()
    if self.m_structClanMark then
        return self.m_structClanMark
    end

    local struct_clan = g_clanData:getClanStruct()
    return struct_clan.m_structClanMark
end

--@CHECK
UI:checkCompileError(UI_ClanSetting)
