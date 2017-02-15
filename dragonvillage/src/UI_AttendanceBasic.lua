local PARENT = UI

-------------------------------------
-- class UI_AttendanceBasic
-------------------------------------
UI_AttendanceBasic = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceBasic:init()    
    local vars = self:load('attendance_basic.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AttendanceBasic')
   

    self:initUI()
    self:initButton()
    self:refresh()

    --self:sceneFadeInAction()

    local function action_finish()
        local first_item = g_attendanceData.m_basicAddedItems['items_list'][1]
        MakeSimpleRewarPopup(Str('출석체크 보상'), first_item['item_id'], first_item['count'])
    end

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(action_finish, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttendanceBasic:initUI()
    local vars = self.vars
    local l_step_list = g_attendanceData.m_basicStepList

    for i,v in ipairs(l_step_list) do
        local item_id = v['item_id']

        local t_sub_data = nil
        --local icon = IconHelper:getItemIcon(item_id, t_sub_data)

        local item = UI_ItemCard(item_id)
        item.root:setScale(0.66)
        item.vars['bgSprite']:setVisible(false)
        item.vars['commonSprite']:setVisible(false)
        local step = v['step']
        vars['rewardNode' .. step]:addChild(item.root)
    end

    -- 하위 UI가 모두 opacity값을 적용되도록
    doAllChildren(self.root, function(node) node:setCascadeOpacityEnabled(true) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttendanceBasic:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttendanceBasic:refresh()
end

--@CHECK
UI:checkCompileError(UI_AttendanceBasic)
