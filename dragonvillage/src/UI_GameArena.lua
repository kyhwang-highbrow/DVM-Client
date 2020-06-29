local PARENT = UI_Game

-------------------------------------
-- class UI_GameArena
-------------------------------------
UI_GameArena = class(PARENT, {
        m_gameScene = '',
        m_orgHeroTamerGaugeScaleX = 'number',
        m_orgEnemyTamerGaugeScaleX = 'number'
    })

-- @jsbae 2020.06.26부터 HOTTIME_UI_INFO의 키는 Fevertime의 핫타임 타입으로 설정한다.
local HOTTIME_UI_INFO = {
	['pvp_honor_up'] = {
		['button'] = 'hotTimeHonorBtn',
		['label'] = 'hotTimeHonorLabel',
		['format'] = '+%s%%',
	},
}
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
    self.m_gameScene = game_scene

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

    self.vars['tamerGaugeVisual2']:setRepeat(false)
    self.vars['tamerGaugeVisual1']:setRepeat(false)

    -- 2배속
    do
        vars['speedVisual']:setVisible(g_autoPlaySetting:get('quick_mode'))
    end

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
    if (not g_gameScene.m_bFriendMatch) then
        self:setAutoPlayUI()
    end

    -- 하단 패널
    vars['panelBgSprite']:setLocalZOrder(-1)

    self:initManaUI()
    self:initHotTimeUI()
end


-------------------------------------
-- function initHotTimeUI
-- @brief 적용된 핫타임
-------------------------------------
function UI_GameArena:initHotTimeUI()
    local vars = self.vars
    local game_key = self.m_gameScene.m_gameKey
	local game_mode = self.m_gameScene.m_gameMode

    vars['hotTimeHonorBtn']:setVisible(false)
    vars['hotTimeHonorLabel']:setString('')

    local l_item_ui = {}
    local l_hottime = g_hotTimeData:getIngameHotTimeList(game_key) or {}
    local t_hottime_calc_value = {
		['pvp_honor_up'] = 0,
	}

    local type = 'pvp_honor_up'
    local is_active, value = g_fevertimeData:isActiveFevertimeByType(type)
    value = value * 100 -- fevertime에서는 1이 100%이기 때문에 100을 곱해준다.
    t_hottime_calc_value[type] = (t_hottime_calc_value[type] + value)
    
    -- 계산한 버프 수치에 클랜 버프 추가하고 UI 처리하기 위한 데이터 생성
	for hottime_type, value in pairs(t_hottime_calc_value) do
		-- 클랜 버프 추가 -- 위쪽 코드에서 포함되도록 수정 20200608
		--if (not g_clanData:isClanGuest()) then
		--	value = value + g_clanData:getClanStruct():getClanBuffByType(CLAN_BUFF_TYPE[hottime_type:upper()])
		--end

		-- UI 처리용 데이터
		if (value > 0) then
			local t_ui_info = HOTTIME_UI_INFO[hottime_type]
			
			local btn_name = t_ui_info['button']
			vars[btn_name]:registerScriptTapHandler(function() g_hotTimeData:makeHotTimeToolTip(hottime_type, vars[btn_name]) end)
			
			local label_name = t_ui_info['label']
			vars[label_name]:setString(string.format(t_ui_info['format'], value))
			
			table.insert(l_item_ui, 1, btn_name)
		end
	end

    self:arrangeItemUI(l_item_ui)
end

-------------------------------------
-- function arrangeItemUI
-- @brief itemUI들을 정렬한다!
-------------------------------------
function UI_GameArena:arrangeItemUI(l_hottime)
    for i, ui_name in pairs(l_hottime) do
        local ui = self.vars[ui_name]

        ui:setVisible(true)
        local pos_x = 10 + ((i-1) * 72)
        ui:setPositionX(pos_x)
    end
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
function UI_GameArena:lockButton()
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
    if (g_gameScene.m_bFriendMatch) then
        vars['autoStartButton']:setVisible(false)
    else
        vars['autoStartButton']:setVisible(is_auto_mode)
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

    if (percentage >= 100) then
        self.vars['tamerGaugeVisual1']:setVisible(true)
        self.vars['tamerGaugeVisual1']:setVisual('group', 'pvp_tamer_gauge')
    end
end

-------------------------------------
-- function setEnemyTamerGauge
-------------------------------------
function UI_GameArena:setEnemyTamerGauge(percentage)
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