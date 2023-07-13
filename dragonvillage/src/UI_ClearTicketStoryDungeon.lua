--@inherit UI
local PARENT = UI_ClearTicket

-------------------------------------
---@class UI_ClearTicketStoryDungeon
-------------------------------------
UI_ClearTicketStoryDungeon = class(PARENT, {
})

----------------------------------------------------------------------
-- function loadUI
----------------------------------------------------------------------
function UI_ClearTicketStoryDungeon:loadUI()
    self:load('clear_ticket_story_dungeon_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_ClearTicketStoryDungeon' -- UI 클래스명 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClearTicketStoryDungeon') -- backkey 지정
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicketStoryDungeon:initMember(stage_id)
    self.m_stageID = stage_id
    self.m_clearNum = 1
    self.m_supplyType = 'clear_ticket'
    self.m_staminaType, self.m_requiredStaminaNum = TableDrop:getStageStaminaType(self.m_stageID)
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicketStoryDungeon:initUI()
    PARENT.initUI(self)
    local vars = self.vars
    vars['difficultyLabel']:setVisible(false)
end

----------------------------------------------------------------------
-- function refreshDropInfo
----------------------------------------------------------------------
function UI_ClearTicketStoryDungeon:refreshDropInfo()
    local vars = self.vars
end

----------------------------------------------------------------------
-- function click_startBtn
----------------------------------------------------------------------
function UI_ClearTicketStoryDungeon:click_startBtn()  
    local function manage_func()
        UINavigatorDefinition:goTo('dragon')
    end

    local function finish_cb(ret)
        function proceeding_end_cb()
            local ui = UI_ClearTicketConfirm(self.m_clearNum, ret)
            -- Back Key unlock
            UIManager:blockBackKey(false)
            ui:setCloseCB(function() 
                self.m_clearNum = 1
                self:refresh()
            end)
        end

        local proceeding_ui = UI_Proceeding()
        proceeding_ui.root:runAction(cc.Sequence:create(cc.DelayTime:create(2.1), 
            cc.CallFunc:create(function() 
                proceeding_ui:setCloseCB(function() 
                    proceeding_end_cb()
                end)
                proceeding_ui:close()
            end)))
    end

    clear_ticket = function()
        g_eventDragonStoryDungeon:requestStoryDungeonStageClearTicket(self.m_stageID, self.m_clearNum, finish_cb)        
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