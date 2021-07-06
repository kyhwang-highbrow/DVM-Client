local PARENT = class(UI, ITabUI:getCloneTable(), IEventDispatcher:getCloneTable())

-------------------------------------
-- class UI_AutoPlaySettingPopup
-------------------------------------
UI_AutoPlaySettingPopup = class(PARENT, {
        m_gameMode = '',
        m_loadDeckCb = 'function',
        
        -- 인게임중 생성된 팝업인지 판단
        m_isInGame = 'boolean',
    })

UI_AutoPlaySettingPopup.TAB_SKILL = 1
UI_AutoPlaySettingPopup.TAB_CONTINUOUS_BATTLE = 2

-------------------------------------
-- function init
-------------------------------------
function UI_AutoPlaySettingPopup:init(game_mode, is_ingame)
    self.m_uiName = 'UI_AutoPlaySettingPopup'
    local vars = self:load('battle_ready_auto_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AutoPlaySettingPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

	self.m_gameMode = game_mode
    self.m_isInGame = is_ingame
    
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function click_autoStartOnBtn
-------------------------------------
function UI_AutoPlaySettingPopup:click_autoStartOnBtn()
    local vars = self.vars

    local checked = vars['autoStartOnBtn']:isChecked()

    -- 비활성 상태일 경우 리턴
    if (checked == false) then
        return
    end

    -- 룬 자동 판매 UI가 활성화일 경우
    local rune_auto_sell_menu = vars['runAutoSellMenu']
    if (rune_auto_sell_menu and rune_auto_sell_menu:isVisible()) then
        if vars['autoStartBtn6']:isChecked() then
            
            local t_setting = {}
            t_setting[1] = vars['starBtn1']:isChecked()
            t_setting[2] = vars['starBtn2']:isChecked()
            t_setting[3] = vars['starBtn3']:isChecked()
            t_setting[4] = vars['starBtn4']:isChecked()
            t_setting[5] = vars['starBtn5']:isChecked()

            -- 설정값이 0보다 커야 하나라도 설정된 상태
            local sell_value = g_autoPlaySetting:getRuneAutoSellValue(t_setting)
            if (sell_value > 0) then
                local function ok_btn_cb()
                    self:close()
                end

                local function cancel_btn_cb()
                    vars['autoStartOnBtn']:setChecked(false)
                end

                UI_RuneAutoSellAgreePopup(ok_btn_cb, cancel_btn_cb, t_setting)
                return
            end
        end
    end
    
  
    -- 베스트 덱 자동으로 불러오기 사용할 경우
    if vars['autoLoadBtn']:isChecked() then
        if (self.m_loadDeckCb) then
            self.m_loadDeckCb()
        end
    end

    -- 활성 상태일 경우 창을 닫음
    self:close()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AutoPlaySettingPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AutoPlaySettingPopup:initUI()
    local vars = self.vars

    -- visible off
    vars['runAutoSellMenu']:setVisible(false)
    vars['autoMenu6']:setVisible(false)
    vars['advNextStageMenu']:setVisible(false)
    vars['autoMenu2']:setVisible(false) -- 20-11-10 업데이트로 어떠한 경우에든지 '드래곤 최대 레벨 달성 시 연속 전투 종료' 옵션 안보이도록 함
	vars['autoMenu3']:setVisible(false) -- 20-11-10 업데이트로 어떠한 경우에든지 '6성 드래곤만 스킬 사용' 옵션 안보이도록 함

	-- 고대의탑 분기처리
    if (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
        if (not g_ancientTowerData:isAttrChallengeMode()) then
            vars['autoLoadBtn']:setVisible(true)
        else
            vars['autoLoadBtn']:setVisible(false)
            vars['loadTeamLock']:setVisible(false)
        end
        vars['autoMenu4']:setVisible(true)
		vars['autoMenu5']:setVisible(false)

    -- 콜로세움 분기처리
	elseif (self.m_gameMode == GAME_MODE_ARENA) then
		vars['autoMenu4']:setVisible(false)
		vars['autoMenu5']:setVisible(false)
        vars['autoMenu6']:setVisible(true)

    -- 신규 콜로세움 분기처리
	elseif (self.m_gameMode == GAME_MODE_ARENA_NEW) then
		vars['autoMenu4']:setVisible(false)
		vars['autoMenu5']:setVisible(false)
        vars['autoMenu6']:setVisible(true)

    -- 그랜드 콜로세움 분기처리
	elseif (self.m_gameMode == GAME_MODE_EVENT_ARENA) then
		vars['autoMenu4']:setVisible(false)
		vars['autoMenu5']:setVisible(false)
        vars['autoMenu6']:setVisible(true)
        vars['autoStartInfoLabel']:setString(Str('연속 전투시 상대 팀이 자동으로 선택됩니다.'))

    -- 환상 던전 분기처리
	elseif (self.m_gameMode == GAME_MODE_EVENT_ILLUSION_DUNSEON) then
        vars['autoMenu5']:setVisible(false)
        vars['autoMenu4']:setVisible(false)
        vars['autoMenu6']:setVisible(false)
        vars['autoEventDungeon']:setVisible(true)
	else
		vars['autoMenu4']:setVisible(false)
		vars['autoMenu5']:setVisible(true)

        local is_adv = self.m_gameMode == GAME_MODE_ADVENTURE
        -- 모험 자동 진행 .. 튜토리얼 1-7 뿁기 까지 완료해야 사용 가능
        vars['advNextStageMenu']:setVisible(is_adv and g_adventureData:isClearStage(1110107))

        -- 룬 자동 판매 (모험, 악몽, 고대 유적)
        if isExistValue(self.m_gameMode, GAME_MODE_ADVENTURE, GAME_MODE_NEST_DUNGEON, GAME_MODE_ANCIENT_RUIN, GAME_MODE_RUNE_GUARDIAN) then
            vars['runAutoSellMenu']:setVisible(true)
        end
	end

    do -- 활성화된 버튼 정렬
        local l_luaname = {}
        -- 가장 위쪽에 보여질 node
        table.insert(l_luaname, 'advNextStageMenu') -- 승리시 다음 스테이지 도전 (모험)
        table.insert(l_luaname, 'autoMenu1') -- 패배시 연속 전투 종료
        table.insert(l_luaname, 'autoMenu5') -- 인연 던전 발견 시 연속 전투 종료
        table.insert(l_luaname, 'autoMenu2') -- 드래곤 최대 레벨 달성 시 연속 전투 종료
        table.insert(l_luaname, 'autoMenu3') -- 6성 드래곤만 스킬 사용
        table.insert(l_luaname, 'autoMenu4') -- 승리시 다음 층 도전
        table.insert(l_luaname, 'autoMenu6') -- 콜로세움 안내 문구
        table.insert(l_luaname, 'runAutoSellMenu') -- 룬 자동 판매
        table.insert(l_luaname, 'autoEventDungeon') -- (환상 던전)일일 최대 환상 토큰 획득 시 전투 종료
        -- 가장 아래쪽에 보여질 node
        
    
        -- 활성화된 버튼들을 담는 리스트와 버튼들의 총 높이 계산
        local l_active_luaname = {}
        local total_height = 0
        for i,v in ipairs(l_luaname) do
            local node = vars[v]
            if node and node:isVisible() then
                table.insert(l_active_luaname, v)
                local width, height = node:getNormalSize()
                total_height = (total_height + height)
            end
        end

        -- 버튼들의 간격 지정
        local interval = 10
        local count = table.count(l_active_luaname)
        total_height = total_height + (interval * (count-1))

        -- 위쪽부터 순차적으로 y position을 지정
        local pos_y = (total_height / 2)
        for i,v in ipairs(l_active_luaname) do
            local node = vars[v]
            local width, height = vars[v]:getNormalSize()
            if (1 < i) then
                pos_y = pos_y - interval
            end
            node:setPositionY(pos_y - (height/2))
            pos_y = pos_y - height
        end
    end

    local ui_inven = UI_InventoryBtn()
    vars['inventoryNode']:addChild(ui_inven.root)
    vars['inventoryNode']:setVisible(true)
    ui_inven:setInGame(self.m_isInGame)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AutoPlaySettingPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

	-- common
    vars['autoStartBtn1']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn2']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn1'] = UIC_CheckBox(vars['autoStartBtn1'].m_node, vars['autoStartSprite1'], true)
    vars['autoStartBtn2'] = UIC_CheckBox(vars['autoStartBtn2'].m_node, vars['autoStartSprite2'], false)
    
	-- tower
    vars['autoStartBtn4']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn5']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoLoadBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn4'] = UIC_CheckBox(vars['autoStartBtn4'].m_node, vars['autoStartSprite4'], false)
    vars['autoStartBtn5'] = UIC_CheckBox(vars['autoStartBtn5'].m_node, vars['autoStartSprite5'], false)
    vars['autoLoadBtn'] = UIC_CheckBox(vars['autoLoadBtn'].m_node, vars['autoLoadSprite'], false) 
    
    -- illusion dungeon
    vars['autoStartBtn7']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn7'] = UIC_CheckBox(vars['autoStartBtn7'].m_node, vars['autoStartSprite7'], false)

    -- 고대의 탑에서  승리시 다음 층-베스트팀 불러오기 버튼 연계
    local function on_load_change_cb(checked)
        if (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
            if (not g_ancientTowerData:isAttrChallengeMode()) then
                vars['loadTeamLock']:setVisible(not checked)
                if (not checked) then
                    vars['autoLoadBtn']:setChecked(false)
                end 
            end
        end
    end
    vars['autoStartBtn4']:setChangeCB(on_load_change_cb)

	-- farming
	vars['autoStartBtn3']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
	vars['autoStartBtn3'] = UIC_CheckBox(vars['autoStartBtn3'].m_node, vars['autoStartSprite3'], false)
    
    -- 모험 자동 진행
    vars['advNextStageBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['advNextStageBtn'] = UIC_CheckBox(vars['advNextStageBtn'].m_node, vars['advNextStageSprite'], false)
    
    do-- rune quto sell
        -- 자동 판매 여부 체크박스
	    vars['autoStartBtn6']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
	    vars['autoStartBtn6'] = UIC_CheckBox(vars['autoStartBtn6'].m_node, vars['autoStartSprite6'], false)

        -- 등급 설정 잠금
        vars['runeAutoSellLock']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
        local function on_change_cb(checked)
            vars['runeAutoSellLock']:setVisible(not checked)
        end
        vars['autoStartBtn6']:setChangeCB(on_change_cb)

        -- 등급 설정 체크박스
        vars['starBtn1'] = UIC_CheckBox(vars['starBtn1'].m_node, vars['starSprite1'], false)
        vars['starBtn2'] = UIC_CheckBox(vars['starBtn2'].m_node, vars['starSprite2'], false)
        vars['starBtn3'] = UIC_CheckBox(vars['starBtn3'].m_node, vars['starSprite3'], false)
        vars['starBtn4'] = UIC_CheckBox(vars['starBtn4'].m_node, vars['starSprite4'], false)
        vars['starBtn5'] = UIC_CheckBox(vars['starBtn5'].m_node, vars['starSprite5'], false)
    end

	-- main
    vars['autoStartOnBtn'] = UIC_CheckBox(vars['autoStartOnBtn'].m_node, vars['autoStartOnSprite'], false)
    vars['autoStartOnBtn']:registerScriptTapHandler(function() self:click_autoStartOnBtn() end)    
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_AutoPlaySettingPopup:refresh()
    local vars = self.vars

	-- common
    vars['autoStartBtn1']:setChecked(g_autoPlaySetting:get('stop_condition_lose'))
    vars['autoStartBtn2']:setChecked(g_autoPlaySetting:get('stop_condition_dragon_lv_max'))

	-- tower
    vars['autoStartBtn4']:setChecked(g_autoPlaySetting:get('tower_next_floor'))
    vars['autoStartBtn5']:setChecked(g_autoPlaySetting:get('stop_condition_find_rel_dungeon'))
	vars['autoLoadBtn']:setChecked(g_autoPlaySetting:get('load_best_deck'))	
	-- farming
	vars['autoStartBtn3']:setChecked(g_autoPlaySetting:get('dragon_farming_mode'))
    vars['advNextStageBtn']:setChecked(g_autoPlaySetting:get('adv_next_stage'))
	 
    -- rune quto sell
    vars['autoStartBtn6']:setChecked(g_autoPlaySetting:get('rune_auto_sell'))
    vars['starBtn1']:setChecked(g_autoPlaySetting:get('rune_auto_sell_grade1'))
    vars['starBtn2']:setChecked(g_autoPlaySetting:get('rune_auto_sell_grade2'))
    vars['starBtn3']:setChecked(g_autoPlaySetting:get('rune_auto_sell_grade3'))
    vars['starBtn4']:setChecked(g_autoPlaySetting:get('rune_auto_sell_grade4'))
    vars['starBtn5']:setChecked(g_autoPlaySetting:get('rune_auto_sell_grade5'))

    -- illusion dungeon
    vars['autoStartBtn7']:setChecked(g_autoPlaySetting:get('illusion_max_try'))

    vars['autoStartOnBtn']:setChecked(g_autoPlaySetting:isAutoPlay())

end

-------------------------------------
-- function close
-------------------------------------
function UI_AutoPlaySettingPopup:close()
    local vars = self.vars

	-- common
    g_autoPlaySetting:set('stop_condition_lose', vars['autoStartBtn1']:isChecked())
    --g_autoPlaySetting:set('stop_condition_dragon_lv_max', vars['autoStartBtn2']:isChecked())
    g_autoPlaySetting:set('stop_condition_dragon_lv_max', false) -- 20-11-10 드래곤 레벨업 개편으로 인해 항상 해당 옵션은 false로 저장하도록 함
    
	-- tower
    g_autoPlaySetting:set('tower_next_floor', vars['autoStartBtn4']:isChecked())
    g_autoPlaySetting:set('stop_condition_find_rel_dungeon', vars['autoStartBtn5']:isChecked())
    g_autoPlaySetting:set('load_best_deck', vars['autoLoadBtn']:isChecked())
	-- farming
	-- g_autoPlaySetting:set('dragon_farming_mode', vars['autoStartBtn3']:isChecked())
	g_autoPlaySetting:set('dragon_farming_mode', false) -- 20-11-10 드래곤 레벨업 개편으로 인해 항상 해당 옵션은 false로 저장하도록 함
    g_autoPlaySetting:set('adv_next_stage', vars['advNextStageBtn']:isChecked())
    
    -- rune auto sell
	g_autoPlaySetting:set('rune_auto_sell', vars['autoStartBtn6']:isChecked())
    g_autoPlaySetting:set('rune_auto_sell_grade1', vars['starBtn1']:isChecked())
    g_autoPlaySetting:set('rune_auto_sell_grade2', vars['starBtn2']:isChecked())
    g_autoPlaySetting:set('rune_auto_sell_grade3', vars['starBtn3']:isChecked())
    g_autoPlaySetting:set('rune_auto_sell_grade4', vars['starBtn4']:isChecked())
    g_autoPlaySetting:set('rune_auto_sell_grade5', vars['starBtn5']:isChecked())

	g_autoPlaySetting:setAutoPlay(vars['autoStartOnBtn']:isChecked())

    -- illusion dungeon
    g_autoPlaySetting:set('illusion_max_try', vars['autoStartBtn7']:isChecked())

	if (g_gameScene) then
		g_gameScene:getGameWorld():dispatch('farming_changed')
	end
	
    PARENT.close(self)
end

-------------------------------------
-- function setLoadDeckCb
-------------------------------------
function UI_AutoPlaySettingPopup:setLoadDeckCb(func_load_deck)
    self.m_loadDeckCb = func_load_deck
end

--@CHECK
UI:checkCompileError(UI_AutoPlaySettingPopup)
