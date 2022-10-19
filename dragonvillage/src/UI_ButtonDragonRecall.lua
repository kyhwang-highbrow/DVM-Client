--@inherit UI
local PARENT = UI_ManagedButton

-------------------------------------
---@class UI_ButtonDragonRecall
-------------------------------------
UI_ButtonDragonRecall = class(PARENT, {
    m_elapsedTime = 'number',
    m_structRecallList = 'table', -- List<StructRecall>
})

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonDragonRecall:init()
    self.m_uiName = 'UI_ButtonDragonRecall'
    self.m_resName = 'button_recall.ui'
    self.m_elapsedTime = 1

    self.m_structRecallList = g_dragonsData:getRecallList()
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_ButtonDragonRecall:init_after()
    self:load(self.m_resName)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
    
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ButtonDragonRecall:initUI()
    local vars = self.vars

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ButtonDragonRecall:initButton()
    local vars = self.vars

    
    self.vars['recallBtn']:registerScriptTapHandler(function() self:click_recallBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ButtonDragonRecall:refresh()
    local vars = self.vars

    self:refreshRecallList()
end

-------------------------------------
-- function refreshRecallList
-------------------------------------
function UI_ButtonDragonRecall:refreshRecallList()
    local temp = {}

    local size = #self.m_structRecallList
    local struct_recall
    for i = 1, size do
        struct_recall = self.m_structRecallList[i]
        if not struct_recall:isAvailable() then
            self.m_structRecallList[i] = nil
        end
    end

    self.m_structRecallList = table.MapToList(self.m_structRecallList)
end

-------------------------------------
-- function update
-------------------------------------
function UI_ButtonDragonRecall:update(dt)
    self.m_elapsedTime = self.m_elapsedTime + dt

    if (self.m_elapsedTime < 1) then
        return
    end
    self.m_elapsedTime = 0
    local vars = self.vars

    self:refresh()

    ---@type StructRecall
    local struct_recall = table.getFirst(self.m_structRecallList)
    if (struct_recall == nil) then
        self.m_bMarkDelete = true
        self:callDirtyStatusCB()
        return
    end

    local time_label = vars['timeLabel']
    if time_label and struct_recall:isAvailable() then
        local time_str = struct_recall:getRemainingTimeStr()
        time_label:setString(time_str)
    end    
end

-------------------------------------
-- function click_btn
-------------------------------------
function UI_ButtonDragonRecall:click_recallBtn()
    local struct_recall = table.getFirst(self.m_structRecallList)
    local target_dragon_list = struct_recall:getTargetDragonList()

    local target_dragon_object = table.getFirst(target_dragon_list)

    if (target_dragon_object == nil) then
        UIManager:toastNotificationRed(Str('조건에 해당하는 드래곤이 없습니다.'))
        return
    end

    local doid = target_dragon_object:getObjectId()
    UINavigatorDefinition:goTo('dragon_manage', 'recall', doid)
end