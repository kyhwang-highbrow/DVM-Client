local PARENT = UI

-------------------------------------
-- class UI_DragonGuidePopup
-------------------------------------
UI_DragonGuidePopup = class(PARENT,{
        m_dragon_list = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGuidePopup:init(dragon_list)
    local vars = self:load('dragon_guide.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_dragon_list = dragon_list

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonGuidePopup')

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
function UI_DragonGuidePopup:initUI()
    local vars = self.vars

    local analysis_map = {}
    for i, v in ipairs(self.m_dragon_list) do
        local dragon_data = v['user_data']
        local analysis_result = DragonGuideNavigator:analysis(dragon_data)
        local link_list = analysis_result['link']

        if (#link_list > 0) then
            analysis_map[tostring(i)] = analysis_result
        end
    end

    local function create_func(ui, data)
        -- 성장 관련 UI에 다녀오면 데이터를 갱신
        ui.m_refreshCB = function()
            self:dragonDataRefresh()
            self:initUI()
        end
    end

    local node = vars['listNode']
    node:removeAllChildren()
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(185, 480)
    table_view:setAlignCenter(true) 
    table_view:setCellUIClass(UI_DragonGuideListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(analysis_map, true)
    
    cca.reserveFunc(self.root, 0.1, function() table_view:setScrollLock(true) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGuidePopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGuidePopup:refresh()
end

-------------------------------------
-- function dragonDataRefresh
-- @brief 드래곤의 object id로 최신 데이터로 갱신
-------------------------------------
function UI_DragonGuidePopup:dragonDataRefresh()
    for i,v in ipairs(self.m_dragon_list) do
        local object_id = v['user_data']['id']
        local dragon_data = g_dragonsData:getDragonDataFromUid(object_id)
        v['user_data'] = dragon_data
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_DragonGuidePopup:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonGuidePopup)
