local PARENT = UI_GameClanRaid

-------------------------------------
-- class UI_GameIllusion
-------------------------------------
UI_GameIllusion = class(PARENT, {})

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameIllusion:initUI()
    PARENT.initUI(self)

    local vars = self.vars
    
    vars['clanRaidNode']:setVisible(true)
    vars['speedVisual']:setVisible(true)
    vars['speedButton']:setVisible(true)
    vars['autoStartVisual']:setVisible(g_autoPlaySetting:isAutoPlay())
    vars['autoStartButton']:setVisible(true)
    vars['effectBtn']:setVisible(true)
    

    vars['damageLabel']:setString('0')
end

-------------------------------------
-- function setAutoPlayUI
-- @brief 연속 전투 정보 UI
-------------------------------------
function UI_GameIllusion:setAutoPlayUI()
    local vars = self.vars

    vars['autoStartNode']:setVisible(g_autoPlaySetting:isAutoPlay())
    vars['autoStartNumberLabel']:setString(Str('{1}회 반복중', g_autoPlaySetting:getAutoPlayCnt()))
    vars['autoStartVisual']:setVisible(g_autoPlaySetting:isAutoPlay())
end

-------------------------------------
-- function click_autoStartButton
-- @brief 연속 전투 .. 자동 아님
-------------------------------------
function UI_GameIllusion:click_autoStartButton()
	-- 튜토리얼 진행 중 block
	local stage_id = self.m_gameScene.m_stageID

    local world = self.m_gameScene.m_gameWorld
    if (not world) then return end

    if (world.m_skillIndicatorMgr and world.m_skillIndicatorMgr:isControlling()) then
        world.m_skillIndicatorMgr:clear()
    end

    self.m_gameScene:gamePause()

    local function close_cb()
        -- 자동모드 여부(연속전투 활성화시 같이 활성화 시킴)
        local is_auto_mode = g_autoPlaySetting:get('auto_mode')

        -- 설정된 정보로 UI 변경
        self:setAutoPlayUI()
        self:setAutoMode(is_auto_mode)

        if (is_auto_mode) then
			world:dispatch('auto_start')
        else
			world:dispatch('auto_end')
        end

        self.m_gameScene:gameResume()
    end

    local is_auto = g_autoPlaySetting:isAutoPlay()

    -- 바로 해제
    if (is_auto) then
        g_autoPlaySetting:setAutoPlay(false)
		world:dispatch('farming_changed')
        close_cb()
    else
		local game_mode = GAME_MODE_EVENT_ILLUSION_DUNSEON
        local ui = UI_AutoPlaySettingPopup(game_mode)
        ui:setCloseCB(close_cb)
    end
end