--@inherit UI
local PARENT = UI

-------------------------------------
---@class UI_DragonRecallConfirm
-------------------------------------
UI_DragonRecallConfirm = class(PARENT, {
    m_structDragonObject = 'StructDragonObject',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRecallConfirm:init(struct_dragon_object)
    self.m_uiName = 'UI_DragonRecallConfirm'
    self.m_resName = 'recall_popup_confirm.ui'

    self.m_structDragonObject = struct_dragon_object
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_DragonRecallConfirm:init_after(struct_dragon_object)
    self:load(self.m_resName)
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, self.m_uiName)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRecallConfirm:initUI()
    local vars = self.vars
    local struct_dragon_object = self.m_structDragonObject 

    do -- 드래곤 아이콘
        vars['itemNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(struct_dragon_object)
        vars['itemNode']:addChild(dragon_card.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRecallConfirm:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRecallConfirm:refresh()
    local vars = self.vars

end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_DragonRecallConfirm:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_DragonRecallConfirm:click_okBtn()
    local function success_cb(ret)        
        UI_ToastPopup(Str('보상이 우편함으로 전송되었습니다.'))
        self:click_closeBtn()
    end

    local struct_dragon_object = self.m_structDragonObject
    local doid = struct_dragon_object:getObjectId()
    g_dragonsData:request_recall(doid, success_cb)
end