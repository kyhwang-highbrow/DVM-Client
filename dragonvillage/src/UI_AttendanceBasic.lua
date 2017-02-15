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

    local function action_finish()
        local first_item = g_attendanceData.m_basicAddedItems['items_list'][1]
        local message = Str('{1}일 차 출석 보너스', g_attendanceData.m_todayStep)
        MakeSimpleRewarPopup(message, first_item['item_id'], first_item['count'])
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

    -- 가이드 드래곤 생성
    local animator = AnimatorHelper:makeDragonAnimator_usingDid(g_attendanceData.m_basicGuideDragon)
    vars['dragonNode']:addChild(animator.m_node)

    -- 텍스트 정보 출력
    vars['dayLabel']:setString(Str('{1}일 차 ', g_attendanceData.m_todayStep))
    vars['descLabel']:setString(Str(g_attendanceData.m_basicDescText))
    vars['helpLabel']:setString(Str(g_attendanceData.m_basicHelpText))

    -- 보상 리스트 출력
    local l_step_list = g_attendanceData.m_basicStepList
    for i,v in ipairs(l_step_list) do
        local step = v['step']
        local item_id = v['item_id']
        local ui = UI_AttendanceBasicListItem(v)
        vars['rewardNode' .. step]:addChild(ui.root)

        if (i <= g_attendanceData.m_todayStep) then
            ui.vars['checkSprite']:setVisible(true)
        else
            ui.vars['checkSprite']:setVisible(false)
        end
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
