local PARENT = UI_Game

-------------------------------------
-- class UI_GameColosseum
-------------------------------------
UI_GameColosseum = class(PARENT, {
    m_orgEnemyTamerGaugeScaleX = 'number'
})

-------------------------------------
-- function getUIFileName
-------------------------------------
function UI_GameColosseum:getUIFileName()
    return 'colosseum_ingame.ui'
end

-------------------------------------
-- function init
-------------------------------------
function UI_GameColosseum:init(game_scene)
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_pauseButton() end, 'UI_GameColosseum')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameColosseum:initUI()
    local vars = self.vars

    self.m_orgEnemyTamerGaugeScaleX = vars['tamerGauge']:getScaleX()

    -- 닉네임
    do
        local is_friendMatch = self.m_gameScene.m_bFriendMatch
        local user_info = (is_friendMatch) and g_friendMatchData.m_playerUserInfo or g_colosseumData.m_playerUserInfo
        vars['userNameLabel1']:setString(user_info.m_nickname)

        if (self.m_gameScene.m_bDevelopMode) then
            vars['userNameLabel2']:setString(user_info.m_nickname)
        else
            user_info = (is_friendMatch) and g_friendMatchData.m_matchInfo or g_colosseumData:getMatchUserInfo()
            vars['userNameLabel2']:setString(user_info.m_nickname)
        end
    end

    -- 하단 패널
    vars['panelBgSprite']:setLocalZOrder(-1)

    self:initManaUI()
end

-------------------------------------
-- function initTamerUI
-------------------------------------
function UI_GameColosseum:initTamerUI(hero_tamer, enemy_tamer)
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
function UI_GameColosseum:setHeroHpGauge(percentage)
    self.vars['hpGauge1']:runAction(cc.ProgressTo:create(0.2, percentage)) 
end

-------------------------------------
-- function getHeroHpGaugePercentage
-------------------------------------
function UI_GameColosseum:getHeroHpGaugePercentage()
    return self.vars['hpGauge1']:getPercentage()
end

-------------------------------------
-- function setEnemyHpGauge
-------------------------------------
function UI_GameColosseum:setEnemyHpGauge(percentage)
    self.vars['hpGauge2']:runAction(cc.ProgressTo:create(0.2, percentage)) 
end

-------------------------------------
-- function getEnemyHpGaugePercentage
-------------------------------------
function UI_GameColosseum:getEnemyHpGaugePercentage()
    return self.vars['hpGauge2']:getPercentage()
end

-------------------------------------
-- function setEnemyTamerGauge
-------------------------------------
function UI_GameColosseum:setEnemyTamerGauge(percentage)
    local scaleX = percentage * self.m_orgEnemyTamerGaugeScaleX / 100

    self.vars['tamerGauge']:setScaleX(scaleX)
end

-------------------------------------
-- function click_autoStartButton
-------------------------------------
function UI_GameColosseum:click_autoStartButton()
end

-------------------------------------
-- function click_chatBtn
-------------------------------------
function UI_GameColosseum:click_chatBtn()
    g_chatManager:toggleChatPopup()
end

-------------------------------------
-- function init_goldUI
-------------------------------------
function UI_GameColosseum:init_goldUI()
end

-------------------------------------
-- function init_timeUI
-------------------------------------
function UI_GameColosseum:init_timeUI(display_wave, time)
    if (time) then
        self:setTime(time)
    end
end

-------------------------------------
-- function setGold
-------------------------------------
function UI_GameColosseum:setGold(gold, prev_gold)
end

-------------------------------------
-- function setTime
-------------------------------------
function UI_GameColosseum:setTime(sec)
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
-- function setAutoPlayUI
-- @brief 연속 전투 정보 UI
-------------------------------------
function UI_GameColosseum:setAutoPlayUI()
end