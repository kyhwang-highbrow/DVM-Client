--@inherit UI
local PARENT = UI_ClearTicket

-------------------------------------
---@class UI_ClearTicketDungeons
-------------------------------------
UI_ClearTicketDungeons = class(PARENT, {
    m_requiredDungeonClearTicketNum = 'number',
    m_currDungeonClearTicketNum = 'number',
})


----------------------------------------------------------------------
-- function initMember
----------------------------------------------------------------------
function UI_ClearTicketDungeons:initMember(stage_id)
    PARENT.initMember(self, stage_id)
    self.m_requiredDungeonClearTicketNum = 1
    self.m_currDungeonClearTicketNum = g_userData:get('subjugation_ticket') or 0
end

----------------------------------------------------------------------
-- function loadUI
----------------------------------------------------------------------
function UI_ClearTicketDungeons:loadUI()
    self:load('clear_ticket_etc_dungeon_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_ClearTicketDungeons' -- UI 클래스명 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClearTicketDungeons') -- backkey 지정
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicketDungeons:initUI()
    PARENT.initUI(self)
    local vars = self.vars
    vars['difficultyLabel']:setVisible(false)
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_ClearTicketDungeons:initButton()
    local vars = self.vars
    
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['plusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(1) end)
    vars['plusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(1, true) end)
    vars['minusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(-1) end)
    vars['minusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(-1, true) end)
    vars['maxBtn']:registerScriptTapHandler(function() self:click_adjustBtn(100) end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)

    vars['staminaBtn']:registerScriptTapHandler(function() self:click_itemTooltip('stamina', 'staminaBtn') end)
    vars['dungeonClearTicketBtn']:registerScriptTapHandler(function() self:click_itemTooltip('subjugation_ticket', 'dungeonClearTicketBtn') end)

    self:initSlideBar()
end

----------------------------------------------------------------------
-- function refreshDropInfo
----------------------------------------------------------------------
function UI_ClearTicketDungeons:refreshDropInfo()
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_ClearTicketDungeons:refresh(is_refreshed_by_button, is_button_pressed)
    local vars = self.vars
    -- 상단 일일 획득 드랍 아이템
    self:refreshDropInfo()
    -- 현재 유저가 보유하고 있는 입장권(날개) 갯수
    self.m_currStaminaNum = g_staminasData:getStaminaCount(self.m_staminaType)
    -- 입장권(날개)에 따른 최대 입장 가능 횟수
    self.m_availableStageNum = math_floor(self.m_currStaminaNum /  self.m_requiredStaminaNum)
    -- 토벌석
    self.m_availableStageNum = math_min(self.m_availableStageNum, g_userData:get('subjugation_ticket') or 0)
    -- 200회 제한
    self.m_availableStageNum = math_min(self.m_availableStageNum, 200)
    -- 시도 횟수
    vars['countLabel']:setString(Str('{1}/{2}', comma_value(self.m_clearNum), 200))
    -- 입장권 갯수 
    vars['staminaLabel']:setString(Str('{1}/{2}', comma_value(self.m_requiredStaminaNum * self.m_clearNum), comma_value(self.m_currStaminaNum)))
    -- 토벌권 갯수 
    vars['dungeonClearTicketLabel']:setString(Str('{1}/{2}', 
        comma_value(self.m_requiredDungeonClearTicketNum * self.m_clearNum), comma_value(self.m_currDungeonClearTicketNum)))
    
    local ratio = self.m_clearNum / self.m_availableStageNum
    local slider_bar_content_size = vars['sliderBarNode']:getContentSize()

    -- 드래그가 아닌 버튼 터치 시 
    if is_refreshed_by_button then
        vars['sliderBarBtn']:stopAllActions()
        vars['sliderBarBtn']:runAction(cc.MoveTo:create(0.2, cc.p(ratio * slider_bar_content_size.width, 0)))

        vars['sliderBarSprite']:stopAllActions()
        vars['sliderBarSprite']:runAction(cc.ProgressTo:create(0.2, ratio * 100))
    else
        vars['sliderBarBtn']:stopAllActions()
        vars['sliderBarBtn']:setPositionX(ratio * slider_bar_content_size.width)

        vars['sliderBarSprite']:stopAllActions()
        vars['sliderBarSprite']:setPercentage(ratio * 100)
    end

    local is_startBtn_enabled = ((self.m_requiredStaminaNum * self.m_clearNum) <= self.m_currStaminaNum) 
    vars['startBtn']:setEnabled(is_startBtn_enabled)     
    
    if is_startBtn_enabled then
        vars['startLabel']:setColor(COLOR['BLACK'])
    else
        vars['startLabel']:setColor(COLOR['DESC'])
        vars['staminaLabel']:setColor(COLOR['RED'])

        if (not is_button_pressed) then
            UIManager:toastNotificationRed(Str('날개가 부족합니다.'))
        end
    end
end

-------------------------------------
-- virtual function onFocusing
-- @brief UI가 focus되었을 때 (화면상 최상단에 표시되었을 때)
-------------------------------------
function UI_ClearTicketDungeons:onFocusing(is_first)
    if is_first ~= true then
        local ticket_count = g_userData:get('subjugation_ticket') or 0
        if ticket_count ~= self.m_currDungeonClearTicketNum then
            self.m_currDungeonClearTicketNum =ticket_count
            self.m_clearNum = 1
            self:refresh()
        end
    end
end

----------------------------------------------------------------------
-- function click_startBtn
----------------------------------------------------------------------
function UI_ClearTicketDungeons:click_startBtn()  
    local game_mode = self.m_gameMode
    local stage_id = self.m_stageID
    local clear_num = self.m_clearNum

    cclog('m_clearNum', clear_num)

    if UI_ClearTicketDungeons.isClearTicketAvailable(stage_id, true) == false then
        return
    end

    local function manage_func()
        UINavigatorDefinition:goTo('dragon')
    end

    local function finish_cb(ret)
        function proceeding_end_cb()
            local ui = UI_ClearTicketConfirm(clear_num, ret, Str('토벌 {1}회 결과', clear_num))
            -- Back Key unlock
            UIManager:blockBackKey(false)
            ui:setCloseCB(function() 
                self.m_currDungeonClearTicketNum = g_userData:get('subjugation_ticket') or 0
                self.m_clearNum = 1
                self:refresh()
            end)
        end

        local bg_script_res = 'map_nightmare'
        if game_mode == GAME_MODE_NEST_DUNGEON then
            local dungeon_mode = g_nestDungeonData:getDungeonMode(self.m_stageID)
            if dungeon_mode == NEST_DUNGEON_NIGHTMARE then
                bg_script_res = 'map_nightmare'
            elseif dungeon_mode == NEST_DUNGEON_TREE then
                bg_script_res = 'map_nest_fire'
            elseif dungeon_mode == NEST_DUNGEON_EVO_STONE then
                bg_script_res = 'map_sky_temple'
            end

        elseif game_mode == GAME_MODE_ANCIENT_RUIN then
            bg_script_res = 'map_ancient_ruin'
        elseif game_mode == GAME_MODE_RUNE_GUARDIAN then
            bg_script_res = 'map_rune_guardian_dungeon'
        end

        local proceeding_ui = UI_Proceeding(bg_script_res)
        proceeding_ui.vars['descLabel']:setString(Str('토벌 중..'))
        proceeding_ui.root:runAction(cc.Sequence:create(cc.DelayTime:create(2.1), 
            cc.CallFunc:create(function() 
                proceeding_ui:setCloseCB(function() 
                    proceeding_end_cb()
                end)
                proceeding_ui:close()
            end)))
    end

    clear_ticket = function()
        if game_mode == GAME_MODE_NEST_DUNGEON then
            g_stageData:request_etcClearTicket('/game/nest/clear', self.m_stageID, clear_num, finish_cb)
        elseif game_mode == GAME_MODE_ANCIENT_RUIN then
            g_stageData:request_etcClearTicket('/game/ruin/clear', self.m_stageID, clear_num, finish_cb)
        elseif game_mode == GAME_MODE_RUNE_GUARDIAN then
            g_stageData:request_etcClearTicket('/game/rune_guardian/clear', self.m_stageID, clear_num, finish_cb)
        end
    end

    -- 아이템 가방 확인(최대 갯수 초과 시 획득 못함)
    check_item_inven = function()
        local function manage_func()
            -- UI_Inventory() @kwkang 룬 업데이트로 룬 관리쪽으로 이동하게 변경 
            UINavigatorDefinition:goTo('rune_forge', 'manage')
        end
        g_inventoryData:checkMaximumItems(clear_ticket, manage_func)
    end

    -- Back Key lock
    UIManager:blockBackKey(true)
    g_dragonsData:checkMaximumDragons(check_item_inven, manage_func)
end

----------------------------------------------------------------------
-- function click_itemTooltip
----------------------------------------------------------------------
function UI_ClearTicketDungeons:click_itemTooltip(goods_type, btn_name)
    local vars = self.vars
    local item_id = TableItem:getItemIDFromItemType(goods_type)
    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]
    -- @delete_rune
    if (not t_item) then
        return '{@SKILL_NAME}none'
    end
    local desc = t_item['t_desc']

    -- 설정된 별도의 이름이 있으면 우선 사용
    local name = t_item['t_name']
    local str = Str('{@SKILL_NAME}{1}\n{@DEFAULT}{2}', Str(name), Str(desc))
    
    local tool_tip = UI_Tooltip_Skill(70, -145, str)
    -- 자동 위치 지정
    tool_tip:autoPositioning(vars[btn_name])
end

----------------------------------------------------------------------
-- function isClearTicketAvailable
-- @brief 소탕 가능 여부
----------------------------------------------------------------------
function UI_ClearTicketDungeons.isClearTicketAvailable(stage_id, use_toast)
    local game_mode = g_stageData:getGameMode(stage_id)

    if game_mode == GAME_MODE_NEST_DUNGEON or game_mode == GAME_MODE_ANCIENT_RUIN then
        local next_stage_id = g_stageData:getNextStage(stage_id)
        local next_stage_clear =  next_stage_id and g_nestDungeonData:isNestDungeonStageClear(next_stage_id) or false

        if next_stage_clear == false then
            if use_toast == true then
                local str = g_nestDungeonData:getStageName(next_stage_id)
                MakeSimplePopup(POPUP_TYPE.OK, Str('{@ORANGE}[{1}]{@} 클리어 후에 이용할 수 있습니다.', str))
            end
            return false
        end

    elseif game_mode == GAME_MODE_RUNE_GUARDIAN then
        if g_runeGuardianData:isRuneGuardianStageClear(stage_id) == false then
            if use_toast == true then
                MakeSimplePopup(POPUP_TYPE.OK, Str('스테이지 클리어 후에 이용할 수 있습니다.'))
            end
            return false
        end
    end

    -- 캐쉬가 충분히 있는지 확인
    if (use_toast == true) then
        if not ConfirmPrice_original('subjugation_ticket', 1) then
            return false
        end
    end

    local value = g_userData:get('subjugation_ticket') or 0
    if value == 0 then
        return false
    end

    return true
end