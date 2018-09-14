local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ChallengeMode
-------------------------------------
UI_ChallengeMode = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeMode:init()
    local vars = self:load_keepZOrder('challenge_mode_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ChallengeMode')

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ChallengeMode:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ChallengeMode'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('그림자의 신전')
    self.m_staminaType = 'st'
    self.m_subCurrency = 'valor'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChallengeMode:initUI()
    local vars = self.vars

    if vars['bgSprite'] then
        -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
        local scr_size = cc.Director:getInstance():getWinSize()
        vars['bgSprite']:setScale(scr_size.width / 1280)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeMode:initButton()
    local vars = self.vars

    if vars['startBtn'] then
        vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChallengeMode:refresh(floor_info)
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ChallengeMode:click_exitBtn()
	self:close()
end

-------------------------------------
-- function click_startBtn
-- @brief 출전 덱 설정 버튼
-------------------------------------
function UI_ChallengeMode:click_startBtn()
    UI_ChallengeModeDeckSettings(CHALLENGE_MODE_STAGE_ID)
end

--@CHECK
UI:checkCompileError(UI_ChallengeMode)