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

        -- 순위 차이 (현재 랭킹 - 지난 랭킹)
        local diff_rank = g_challengeMode:getDiffRankFromLastDay()
        local diff_rank_msg

        local my_rank = string.match(rank_text,'%d+')
        
        -- 자기 랭크가 없을 때에는 표기 안함
        if (not my_rank or my_rank == 0) then
            diff_rank_msg = ''
        else
            -- 순위 변동 메세지
            if (diff_rank > 0) then
                diff_rank_msg = '{@defualt}({@red}▼{@defualt}-' .. math.abs(diff_rank) .. ')'
            elseif(diff_rank < 0) then
                diff_rank_msg = '{@defualt}({@light_blue}▲{@defualt}+' .. math.abs(diff_rank) .. ')'
            else   
                diff_rank_msg = '{@defualt}(-)'
            end   
        end

        vars['descLabel']:setString(rank_text)
        vars['changedLabel']:setString(diff_rank_msg)

        if (my_rank) then
            -- 1000위 (@-10000) 길이가 너무 길 경우 폰트 사이즈 조절 - 전체 글자수로 해야할 듯
            if (my_rank * diff_rank > 10000000) then
                vars['descLabel']:setFontSize(25)
                vars['changedLabel']:setFontSize(18)
            end
        end

    -- 이벤트 종료 후 보상 획득 가능
    elseif (state == ServerData_ChallengeMode.STATE['REWARD']) then
        vars['timeLabel']:setString('')

        vars['descLabel']:setString(Str('보상'))
    else
        vars['timeLabel']:setString('')

        vars['descLabel']:setString('')
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
