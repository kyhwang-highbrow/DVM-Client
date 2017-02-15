local PARENT = UI

-------------------------------------
-- class UI_AttendanceSpecial
-------------------------------------
UI_AttendanceSpecial = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceSpecial:init()
    local vars = self:load('attendance_continuous.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AttendanceSpecial')

    self:initUI()
    self:initButton()
    self:refresh()

    local function action_finish()
        local first_item = g_attendanceData.m_specialAddedItems['items_list'][1]
        local message = Str('{1}일 차' .. ' ' ..  g_attendanceData.m_specialTitleText, g_attendanceData.m_specialTodayStep)
        MakeSimpleRewarPopup(message, first_item['item_id'], first_item['count'])
    end

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(action_finish, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttendanceSpecial:initUI()
    local vars = self.vars

    -- 텍스트 정보 출력
    vars['titleLabel']:setString(g_attendanceData.m_specialTitleText)
    vars['dayLabel']:setString(Str('{1}일 차 ', g_attendanceData.m_specialTodayStep))
    vars['helpLabel']:setString(Str(g_attendanceData.m_specialHelpText))

    self:initTableView()

    do -- 오늘의 보상 표시
        vars['finalDayLabel']:setString(Str('{1}일 차 ', g_attendanceData.m_specialTodayStep))
        local today_item = g_attendanceData.m_specialStepList[g_attendanceData.m_specialTodayStep]
        local item_icon = IconHelper:getItemIcon(today_item['item_id'])
        vars['itemNode']:addChild(item_icon)

        local str = TableItem():getValue(today_item['item_id'], 't_name')
        vars['quantityLabel']:setString(Str(str) .. '\n' .. comma_value(today_item['value']))
    end
    
    -- 하위 UI가 모두 opacity값을 적용되도록
    doAllChildren(self.root, function(node) node:setCascadeOpacityEnabled(true) end)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_AttendanceSpecial:initTableView()
    local node = self.vars['listNode']
    --node:removeAllChildren()

    local l_item_list = g_attendanceData.m_specialStepList

    -- 생성 콜백
    local function create_func(ui, data)
        if (data['step'] <= g_attendanceData.m_specialTodayStep) then
            ui.vars['checkSprite']:setVisible(true)
        else
            ui.vars['checkSprite']:setVisible(false)
        end 
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(160, 260)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setCellUIClass(UI_AttendanceSpecialListItem, create_func)
    table_view:setItemList(l_item_list)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttendanceSpecial:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttendanceSpecial:refresh()
end

--@CHECK
UI:checkCompileError(UI_AttendanceSpecial)
