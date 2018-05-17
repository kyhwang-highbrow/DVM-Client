local PARENT = UI_Game

-------------------------------------
-- class UI_GameArena
-------------------------------------
UI_GameArena = class(PARENT, {
    m_orgHeroTamerGaugeScaleX = 'number',
    m_orgEnemyTamerGaugeScaleX = 'number'
})

-------------------------------------
-- function getUIFileName
-------------------------------------
function UI_GameArena:getUIFileName()
    return 'arena_ingame.ui'
end

-------------------------------------
-- function init
-------------------------------------
function UI_GameArena:init(game_scene)
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_pauseButton() end, 'UI_GameArena')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameArena:initUI()
    local vars = self.vars

    self.m_orgHeroTamerGaugeScaleX = vars['tamerGauge2']:getScaleX()
    self.m_orgEnemyTamerGaugeScaleX = vars['tamerGauge1']:getScaleX()

    -- 2배속
    do
        vars['speedVisual']:setVisible(g_autoPlaySetting:get('quick_mode'))
    end

    -- 닉네임
    do
        local is_friendMatch = self.m_gameScene.m_bFriendMatch
        local user_info = g_arenaData.m_playerUserInfo
        vars['userNameLabel1']:setString(user_info.m_nickname)

        if (self.m_gameScene.m_bDevelopMode) then
            user_info = g_arenaData:getMatchUserInfo()
            vars['userNameLabel2']:setString(user_info.m_nickname)
        else
            user_info = g_arenaData:getMatchUserInfo()
            vars['userNameLabel2']:setString(user_info.m_nickname)
        end
    end

    -- 하단 패널
    vars['panelBgSprite']:setLocalZOrder(-1)

    -- 자동 버튼 숨김
    vars['autoButton']:setVisible(false)
    vars['autoVisual']:setVisible(false)

    self:initManaUI()
end

-------------------------------------
-- function initTamerUI
-------------------------------------
function UI_GameArena:initTamerUI(hero_tamer, enemy_tamer)
    local vars = self.vars
    do
        local icon
        if (hero_tamer.m_costumeData) then
            local costume_id = hero_tamer.m_costumeData:getCid()
            icon = IconHelper:getTamerProfileIconWithCostumeID(costume_id)
        else
            icon = IconHelper:makeTamerReadyIcon(hero_tamer.m_tamerID)
        end
        vars['tamerNode1']:addChild(icon, 1)
    end

    do
        local icon
        if (enemy_tamer.m_costumeData) then
            local costume_id = enemy_tamer.m_costumeData:getCid()
            icon = IconHelper:getTamerProfileIconWithCostumeID(costume_id)
        else
            icon = IconHelper:makeTamerReadyIcon(enemy_tamer.m_tamerID)
        end
        vars['tamerNode2']:addChild(icon, 1)
    end
end

-------------------------------------
-- function setHeroHpGauge
-------------------------------------
function UI_GameArena:setHeroHpGauge(percentage)
    self.vars['hpGauge1']:runAction(cc.ProgressTo:create(0.2, percentage)) 
end

-------------------------------------
-- function getHeroHpGaugePercentage
-------------------------------------
function UI_GameArena:getHeroHpGaugePercentage()
    return self.vars['hpGauge1']:getPercentage()
end

-------------------------------------
-- function setEnemyHpGauge
-------------------------------------
function UI_GameArena:setEnemyHpGauge(percentage)
    self.vars['hpGauge2']:runAction(cc.ProgressTo:create(0.2, percentage)) 
end

-------------------------------------
-- function getEnemyHpGaugePercentage
-------------------------------------
function UI_GameArena:getEnemyHpGaugePercentage()
    return self.vars['hpGauge2']:getPercentage()
end

-------------------------------------
-- function setHeroTamerGauge
-------------------------------------
function UI_GameArena:setHeroTamerGauge(percentage)
    local scaleX = percentage * self.m_orgHeroTamerGaugeScaleX / 100

    self.vars['tamerGauge2']:setScaleX(scaleX)
end

-------------------------------------
-- function setEnemyTamerGauge
-------------------------------------
function UI_GameArena:setEnemyTamerGauge(percentage)
    local scaleX = percentage * self.m_orgEnemyTamerGaugeScaleX / 100

    self.vars['tamerGauge1']:setScaleX(scaleX)
end

-------------------------------------
-- function click_autoStartButton
-------------------------------------
function UI_GameArena:click_autoStartButton()
end

-------------------------------------
-- function click_chatBtn
-------------------------------------
function UI_GameArena:click_chatBtn()
    g_chatManager:toggleChatPopup()
end

-------------------------------------
-- function click_speedButton
-------------------------------------
function UI_GameArena:click_speedButton()
    local world = self.m_gameScene.m_gameWorld
    if (not world) then return end

	local gameTimeScale = world.m_gameTimeScale
	local quick_time_scale = g_constant:get('INGAME', 'QUICK_MODE_TIME_SCALE')

    if (gameTimeScale:getBase() >= quick_time_scale) then
        UIManager:toastNotificationGreen(Str('빠른모드 비활성화'))

        gameTimeScale:setBase(COLOSSEUM__TIME_SCALE)

         g_autoPlaySetting:setWithoutSaving('quick_mode', false)
    else
        UIManager:toastNotificationGreen(Str('빠른모드 활성화'))

        gameTimeScale:setBase(COLOSSEUM__TIME_SCALE * quick_time_scale)

        g_autoPlaySetting:setWithoutSaving('quick_mode', true)
    end

    self.vars['speedVisual']:setVisible((gameTimeScale:getBase() >= quick_time_scale))
end

-------------------------------------
-- function init_goldUI
-------------------------------------
function UI_GameArena:init_goldUI()
end

-------------------------------------
-- function init_timeUI
-------------------------------------
function UI_GameArena:init_timeUI(display_wave, time)
    if (time) then
        self:setTime(time)
    end
end

-------------------------------------
-- function setGold
-------------------------------------
function UI_GameArena:setGold(gold, prev_gold)
end

-------------------------------------
-- function setTime
-------------------------------------
function UI_GameArena:setTime(sec)
    local vars = self.vars

    vars['timeLabel']:setVisible(true)
    vars['timeLabel']:setString(math_floor(sec))
    
    -- 20초이하인 경우 붉은색으로 색상 변경
    if (sec <= 20) then
        vars['timeLabel']:setColor(cc.c3b(255, 0, 0))
    else
        vars['timeLabel']:setColor(cc.c3b(0, 255, 0))
    end
end

-------------------------------------
-- function setAutoMode
-- @brief 자동 모드 설정
-------------------------------------
function UI_GameArena:setAutoMode(b)
end

-------------------------------------
-- function setAutoPlayUI
-- @brief 연속 전투 정보 UI
-------------------------------------
function UI_GameArena:setAutoPlayUI()
end