local PARENT = UI

-------------------------------------
-- class UI_BannerChallengeMode
-------------------------------------
UI_BannerChallengeMode = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BannerChallengeMode:init()
    self.m_uiName = 'UI_BannerChallengeMode'
    local vars = self:load('lobby_banner_challenge_mode.ui')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BannerChallengeMode:initUI()
    local vars = self.vars

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    vars['titleLabel']:setString(Str('그림자의 신전'))
    
    -- 스페인어의 경우 그림자의 신전 번역이 잘리는 이슈 때문에 폰트 사이즈 줄임
    local cur_lang = Translate:getGameLang()
    if (cur_lang == 'es') then
        vars['titleLabel']:setFontSize(20)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BannerChallengeMode:initButton()
    local vars = self.vars
    vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BannerChallengeMode:refresh()
end

-------------------------------------
-- function update
-- @brief 매 프레임 호출되는 함수
-------------------------------------
function UI_BannerChallengeMode:update(dt)
    local vars = self.vars

    local state = g_challengeMode:getChallengeModeState()
    
    -- 이벤트 진행 중
    if (state == ServerData_ChallengeMode.STATE['OPEN']) then
        local text = g_challengeMode:getChallengeModeStatusText()
        vars['timeLabel']:setString(text)

        local struct_user_info = g_challengeMode:getPlayerArenaUserInfo()
        local rank_text = struct_user_info:getChallengeMode_RankText()

    -- 이벤트 종료 후 보상 획득 가능
    elseif (state == ServerData_ChallengeMode.STATE['REWARD']) then
        vars['timeLabel']:setString('')

        vars['descLabel']:setString(Str('보상'))

        vars['changedLabel']:setString('')
    else
        vars['timeLabel']:setString('')

        vars['descLabel']:setString('')

        vars['changedLabel']:setString('')
    end
end

-------------------------------------
-- function click_bannerBtn
-------------------------------------
function UI_BannerChallengeMode:click_bannerBtn()
    -- @brief 챌린지 모드로 이동
    UINavigator:goTo('challenge_mode')
end

--@CHECK
UI:checkCompileError(UI_BannerChallengeMode)
