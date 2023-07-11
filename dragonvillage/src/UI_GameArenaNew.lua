local PARENT = UI_Game

-------------------------------------
-- class UI_GameArenaNew
-------------------------------------
UI_GameArenaNew = class(PARENT, {
        m_gameScene = '',
        m_orgHeroTamerGaugeScaleX = 'number',
        m_orgEnemyTamerGaugeScaleX = 'number'
    })

-------------------------------------
-- function getUIFileName
-------------------------------------
function UI_GameArenaNew:getUIFileName()
    return 'arena_ingame_new.ui'
end

-------------------------------------
-- function init
-------------------------------------
function UI_GameArenaNew:init(game_scene)
    self.m_gameScene = game_scene

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_pauseButton() end, 'UI_GameArenaNew')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameArenaNew:initUI()
    local vars = self.vars

    self.m_orgHeroTamerGaugeScaleX = vars['tamerGauge2']:getScaleX()
    self.m_orgEnemyTamerGaugeScaleX = vars['tamerGauge1']:getScaleX()

    self.vars['tamerGaugeVisual2']:setRepeat(false)
    self.vars['tamerGaugeVisual1']:setRepeat(false)

    -- 닉네임
    do
        -- 플레이어 정보
        local user_info = self.m_gameScene:getStructUserInfo_Player()
        vars['userNameLabel1']:setString(user_info.m_nickname)

        -- 상대방 벙조
        local user_info = self.m_gameScene:getStructUserInfo_Opponent()
        vars['userNameLabel2']:setString(user_info.m_nickname)
    end

     -- 연속 전투 정보
    --if (not g_gameScene.m_bFriendMatch) then
    --    self:setAutoPlayUI()
    --end

    -- 하단 패널
    vars['panelBgSprite']:setLocalZOrder(-1)

    self:initManaUI()
    self:initHotTimeUI()
end

-------------------------------------
-- function initTamerUI
-------------------------------------
function UI_GameArenaNew:initTamerUI(hero_tamer, enemy_tamer)
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

        if (not hero_tamer:getSkillIndivisualInfo('indie_time')) then
            vars['tamerGauge2']:setVisible(false)
        end
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
-- function lockButton
-------------------------------------
function UI_GameArenaNew:lockButton()
    local vars = self.vars

    -- 자동 버튼
    local is_auto_mode = g_autoPlaySetting:get('auto_mode') or false
    
    vars['autoButton']:setVisible(not is_auto_mode)
    vars['autoVisual']:setVisible(is_auto_mode)
    vars['autoLockSprite']:setVisible(not vars['autoButton']:isVisible())

    -- 수동 모드시 스프라이트 변경 처리(아군 테이머 게이지 숨김)
    if (not is_auto_mode) then
        local sprite_frame = cc.SpriteFrameCache:getInstance():getSpriteFrame('ingame_gg_pvp_0101.png')
        if (sprite_frame) then
            vars['frameSprite']:setSpriteFrame(sprite_frame)
        end
    end

    -- 자동 모드시 연속전투버튼 활성화
    --if (g_gameScene.m_bFriendMatch) then
    --    vars['autoStartButton']:setVisible(false)
    --else
    --    vars['autoStartButton']:setVisible(is_auto_mode)
    --end
end

-------------------------------------
-- function setHeroHpGauge
-------------------------------------
function UI_GameArenaNew:setHeroHpGauge(percentage)
    self.vars['hpGauge1']:runAction(cc.ProgressTo:create(0.2, percentage))
end

-------------------------------------
-- function getHeroHpGaugePercentage
-------------------------------------
function UI_GameArenaNew:getHeroHpGaugePercentage()
    return self.vars['hpGauge1']:getPercentage()
end

-------------------------------------
-- function setEnemyHpGauge
-------------------------------------
function UI_GameArenaNew:setEnemyHpGauge(percentage)
    self.vars['hpGauge2']:runAction(cc.ProgressTo:create(0.2, percentage)) 
end

-------------------------------------
-- function getEnemyHpGaugePercentage
-------------------------------------
function UI_GameArenaNew:getEnemyHpGaugePercentage()
    return self.vars['hpGauge2']:getPercentage()
end

-------------------------------------
-- function setHeroTamerGauge
-------------------------------------
function UI_GameArenaNew:setHeroTamerGauge(percentage)
    local scaleX = percentage * self.m_orgHeroTamerGaugeScaleX / 100

    self.vars['tamerGauge2']:setScaleX(scaleX)

    if (percentage >= 100) then
        self.vars['tamerGaugeVisual1']:setVisible(true)
        self.vars['tamerGaugeVisual1']:setVisual('group', 'pvp_tamer_gauge')
    end
end

-------------------------------------
-- function setEnemyTamerGauge
-------------------------------------
function UI_GameArenaNew:setEnemyTamerGauge(percentage)
    local scaleX = percentage * self.m_orgEnemyTamerGaugeScaleX / 100

    self.vars['tamerGauge1']:setScaleX(scaleX)

    if (percentage >= 100) then
        self.vars['tamerGaugeVisual2']:setVisible(true)
        self.vars['tamerGaugeVisual2']:setVisual('group', 'pvp_tamer_gauge')
    end
end

-------------------------------------
-- function click_chatBtn
-------------------------------------
function UI_GameArenaNew:click_chatBtn()
    g_chatManager:toggleChatPopup()
end

-------------------------------------
-- function init_goldUI
-------------------------------------
function UI_GameArenaNew:init_goldUI()
end

-------------------------------------
-- function init_timeUI
-------------------------------------
function UI_GameArenaNew:init_timeUI(display_wave, time)
    if (time) then
        self:setTime(time)
    end
end

-------------------------------------
-- function setGold
-------------------------------------
function UI_GameArenaNew:setGold(gold, prev_gold)
end

-------------------------------------
-- function setTime
-------------------------------------
function UI_GameArenaNew:setTime(sec)
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