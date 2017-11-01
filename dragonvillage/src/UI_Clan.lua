local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Clan
-------------------------------------
UI_Clan = class(PARENT, {
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Clan:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Clan'
    self.m_titleStr = Str('클랜')
	--self.m_staminaType = 'pvp'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'clan_coin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function init
-------------------------------------
function UI_Clan:init()
    local vars = self:load('clan_02.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_uiName = 'UI_Clan'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Clan')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    -- 보상 안내 팝업
    local function finich_cb()
        if g_clanData:isNeedClanSetting() then
            self:click_settingBtn()
        end
    end

    self:sceneFadeInAction(nil, finich_cb)

    -- @ TUTORIAL
    --TutorialManager.getInstance():startTutorial(TUTORIAL.CLAN, self)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Clan:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Clan:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Clan:initButton()
    local vars = self.vars

    vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Clan:refresh()
    local vars = self.vars

    local struct_clan = g_clanData:getClanStruct()

    -- 클랜 마크
    local icon = struct_clan:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)

    -- 클랜 이름
    vars['clanNameLabel']:setString(struct_clan['name'])

    -- 클랜 마스터 닉네임
    vars['clanMasterLabel']:setString(struct_clan['master'])

    -- 맴버 수
    vars['clanMemberLabel']:setString(Str('클랜원 {1}/{2}', struct_clan['member_cnt'], 20))
    
    -- 클랜 공지
    vars['clanNoticeLabel']:setString(struct_clan['notice'] or Str('등록된 공지가 없습니다.'))
end

-------------------------------------
-- function click_settingBtn
-------------------------------------
function UI_Clan:click_settingBtn()
    local ui = UI_ClanSetting()

    local function close_cb()
        if ui.m_bRet then
            self:refresh()
        end
    end

    ui:setCloseCB(close_cb)
end

--@CHECK
UI:checkCompileError(UI_Clan)
