local PARENT = UI

-------------------------------------
-- class UI_AncientTowerBestDeckPopup
-------------------------------------
UI_AncientTowerBestDeckPopup = class(PARENT,{
        m_cur_stage_id = 'number',
        m_tData = 'table',
        m_moveCb = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerBestDeckPopup:init(cur_stage_id, t_data)
    self.m_uiName = 'UI_AncientTowerBestDeckPopup'
    local vars = self:load('tower_best_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_tData = t_data
    self.m_cur_stage_id = cur_stage_id


    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AncientTowerBestDeckPopup')

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
function UI_AncientTowerBestDeckPopup:initUI()
    local vars = self.vars
    local t_score_data = self.m_tData
    local l_deck = g_settingDeckData:getDeckAllAncient()

    if (not l_deck) then
        return 
    end

    l_deck = table.MapToList(l_deck)

    local sort_func = function(a,b)
        return tonumber(a['stage_id']) > tonumber(b['stage_id'])
    end

    table.sort(l_deck, sort_func)

    -- 덱 팝업에 덱 적용 버튼 있을 경우
    local create_func = function(ui, data)
        -- 스테이지에 해당하는 점수 테이블 보내줌
        local stage_id = tostring(data['stage_id'])
        ui:setScore(t_score_data[stage_id])

        -- 해당 층 일때 하이라이트
        if (self.m_cur_stage_id == tonumber(stage_id)) then
            ui:setHighlight(true)
        end

        ui.vars['moveBtn']:registerScriptTapHandler(function() 
            local t_data = {}
            t_data['stage'] = tonumber(data['stage_id'])
            if (self.m_moveCb) then
                self.m_moveCb(t_data)
            end
            self:close() 
        end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['listNode'])
    table_view:setCellUIClass(UI_AncientTowerBestDeckListItem, create_func)
    table_view.m_defaultCellSize = cc.size(1217, 77)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    table_view:setItemList(l_deck)
    
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view:relocateContainerFromIndex(self.m_cur_stage_id%1000)
   
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerBestDeckPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerBestDeckPopup:refresh()
    
end

-------------------------------------
-- function setMoveBtnFunc
-------------------------------------
function UI_AncientTowerBestDeckPopup:setFuncMove(func_move)
    self.m_moveCb = func_move
end


--@CHECK
UI:checkCompileError(UI_AncientTowerBestDeckPopup)
