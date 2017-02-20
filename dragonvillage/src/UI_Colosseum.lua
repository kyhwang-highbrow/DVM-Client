local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Colosseum
-------------------------------------
UI_Colosseum = class(PARENT, {
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Colosseum:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Colosseum'
    self.m_bVisible = true
    self.m_titleStr = Str('콜로세움')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_Colosseum:init()
    local vars = self:load('colosseum.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Colosseum')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Colosseum:click_exitBtn()
    local scene = SceneLobby()
    scene:runScene()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Colosseum:initUI()
    local vars = self.vars

    local player_info = g_colosseumData:getPlayerInfo()

    -- 티어
    local icon = player_info:getTierIcon()
    cca.uiReactionSlow(icon)
    vars['myTierIconNode']:addChild(icon)
    vars['myTierLabel']:setString(player_info:getTierText())
    
    -- 플레이어 정보
    vars['myRankLabel']:setString(player_info:getRankText())
    vars['myPointLabel']:setString(player_info:getRPText())
    vars['myWinRateLabel']:setString(player_info:getWinRateText())
    vars['myWinstreakLabel']:setString(player_info:getWinstreakText())

    -- 콜로세움 오픈 시간 표시
    vars['timeLabel']:setString(g_colosseumData:getWeekTimeText())
    vars['timeGauge']:setPercentage(g_colosseumData:getWeekTimePercent())

    vars['rewardInfoBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"보상 정보" 준비 중') end)
    vars['honorShopBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"명예 상점" 준비 중') end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Colosseum:initButton()
    local vars = self.vars
    vars['readyBtn']:registerScriptTapHandler(function() self:click_readyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Colosseum:refresh()
end

-------------------------------------
-- function click_secretBtn
-------------------------------------
function UI_Colosseum:click_readyBtn()
    local function cb(ret)
        local scene = SceneGameColosseum()
        scene:runScene()
    end

    g_colosseumData:request_colosseumStart(cb)
end

--@CHECK
UI:checkCompileError(UI_Colosseum)
