--@inherit UI
local PARENT = UI_ClearTicket

-------------------------------------
---@class UI_ClearTicketEtc
-------------------------------------
UI_ClearTicketEtc = class(PARENT, {
})

----------------------------------------------------------------------
-- function loadUI
----------------------------------------------------------------------
function UI_ClearTicketEtc:loadUI()
    self:load('clear_ticket_etc_dungeon_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_ClearTicketEtc' -- UI 클래스명 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClearTicketEtc') -- backkey 지정
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicketEtc:initUI()
    PARENT.initUI(self)
    local vars = self.vars
    vars['difficultyLabel']:setVisible(false)
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_ClearTicketEtc:initButton()
    local vars = self.vars
    
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['plusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(1) end)
    vars['plusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(1, true) end)
    vars['minusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(-1) end)
    vars['minusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(-1, true) end)
    vars['maxBtn']:registerScriptTapHandler(function() self:click_adjustBtn(100) end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)

    self:initSlideBar()
end

----------------------------------------------------------------------
-- function refreshDropInfo
----------------------------------------------------------------------
function UI_ClearTicketEtc:refreshDropInfo()
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_ClearTicketEtc:refresh()
    PARENT.refresh(self)
    local vars = self.vars    
    if self.m_gameMode == GAME_MODE_RUNE_GUARDIAN or -- 룬 수호자 던전
    self.m_gameMode == GAME_MODE_ANCIENT_RUIN or -- 고대 유적 던전
    self.m_gameMode == GAME_MODE_NEST_DUNGEON then  -- 악몽 던전
        self.m_availableStageNum = math_min(self.m_availableStageNum, 200)
        vars['maxCountLabel']:setStringArg(200)
        vars['countLabel']:setString(Str('{1}/{2}', comma_value(self.m_clearNum), 200))
    end
end

----------------------------------------------------------------------
-- function click_startBtn
----------------------------------------------------------------------
function UI_ClearTicketEtc:click_startBtn()  
    local game_mode = self.m_gameMode
    local function manage_func()
        UINavigatorDefinition:goTo('dragon')
    end

    local function finish_cb(ret)
        function proceeding_end_cb()
            local ui = UI_ClearTicketConfirm(self.m_clearNum, ret, Str('토벌 {1}회 결과', self.m_clearNum))
            -- Back Key unlock
            UIManager:blockBackKey(false)
            ui:setCloseCB(function() 
                self.m_clearNum = 1
                self:refresh()
            end)
        end

        local proceeding_ui = UI_Proceeding()
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
            g_stageData:request_etcClearTicket('/game/nest/clear', self.m_stageID, self.m_clearNum, finish_cb)
        elseif game_mode == GAME_MODE_ANCIENT_RUIN then
            g_stageData:request_etcClearTicket('/game/ruin/clear', self.m_stageID, self.m_clearNum, finish_cb)
        elseif game_mode == GAME_MODE_RUNE_GUARDIAN then
            g_stageData:request_etcClearTicket('/game/rune_guardian/clear', self.m_stageID, self.m_clearNum, finish_cb)
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
-- function isClearTicketAvailable
-- @brief 소탕 가능 여부
----------------------------------------------------------------------
function UI_ClearTicketEtc.isClearTicketAvailable(stage_id)
    local game_mode = g_stageData:getGameMode(stage_id)

    if game_mode == GAME_MODE_NEST_DUNGEON or game_mode == GAME_MODE_ANCIENT_RUIN then
        local next_stage_id = g_stageData:getNextStage(stage_id)
        local next_stage_clear =  next_stage_id and g_nestDungeonData:isNestDungeonStageClear(next_stage_id) or false
        local t_next_stage_info = next_stage_id and g_nestDungeonData:parseNestDungeonID(next_stage_id) or nil
        local tier = 1

        if t_next_stage_info ~= nil then
            tier = t_next_stage_info['tier']
        end

        if next_stage_clear == false then
            MakeSimplePopup(POPUP_TYPE.OK, Str('{1}단계까지 클리어 후에 이용할 수 있습니다.', tier))
            return false
        end

    elseif game_mode == GAME_MODE_RUNE_GUARDIAN then
        if g_runeGuardianData:isRuneGuardianStageClear(stage_id) == false then
            MakeSimplePopup(POPUP_TYPE.OK, Str('스테이지 클리어 후에 이용할 수 있습니다.'))
            return false
        end
    end

    return true
end