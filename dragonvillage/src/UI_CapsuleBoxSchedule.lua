local PARENT = UI

-------------------------------------
-- class UI_CapsuleBoxSchedule
-------------------------------------
UI_CapsuleBoxSchedule = class(PARENT,{
      
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBoxSchedule:init()
    self.m_uiName = 'UI_CapsuleBoxSchedule'
    local vars = self:load('capsule_box_schedule_pop_up.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CapsuleBoxSchedule')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBoxSchedule:initUI()
    local vars = self.vars

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['scrollNode'])
    table_view:setCellUIClass(UI_CapsuleScheduleListItem, nil)
    table_view.m_defaultCellSize = cc.size(900, 130)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    
    -- 마지막에 추가하는 테이블 아이템
    local l_item_list = g_capsuleBoxData.m_sortedScheduleList
    local advance_notice_item = { advance_notice = Str('{@ORANGE}다음 업데이트를\n기다려 주세요') }
    l_item_list['advance_notice'] = advance_notice_item

    -- 현재 판매중인 캡슐 상품 정보
    table_view:setItemList(l_item_list)
    
    -- 현재 판매중인 캡슐 상품 인덱스
    local idx = g_capsuleBoxData.m_todayScheduleIdx
    
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view:relocateContainerFromIndex(idx)

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBoxSchedule:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBoxSchedule:refresh()
    
end


--@CHECK
UI:checkCompileError(UI_CapsuleBoxSchedule)
