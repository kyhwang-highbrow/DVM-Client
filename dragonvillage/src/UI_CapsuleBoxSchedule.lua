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
    UIManager:open(self, UIManager.SCENE)

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

    if (not g_capsuleBoxData.m_scheduleTable) then
        return
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['scrollNode'])
    table_view:setCellUIClass(UI_CapsuleScheduleListItem)
    table_view.m_defaultCellSize = cc.size(900, 130)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local l_item_list = g_capsuleBoxData:getCapsuleBoxScheduleList()
    local table_index = 0
    for i,v in ipairs(l_item_list) do
        if (v['day'] == g_capsuleBoxData.m_day) then
            table_index = i
            break
        end
    end

    -- 현재 판매중인 캡슐 상품 정보
    table_view:setItemList(l_item_list)
    
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view:relocateContainerFromIndex(table_index)

    -- 마지막에 추가하는 테이블 아이템
    local advance_notice_item = { ['advance_notice'] = '{@ORANGE}' .. Str('업데이트 예정')}
    table_view:addItem('advance_notice', advance_notice_item)
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
