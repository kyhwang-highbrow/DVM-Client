local PARENT = UI

-------------------------------------
-- class UI_ConfirmPopup
-------------------------------------
UI_FevertimeConfirmPopupList = class(PARENT,{
        m_initialUsableFevertimeList = 'table'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FevertimeConfirmPopupList:init()
    local vars = self:load('event_fevertime_confirm_list_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_initialUsableFevertimeList = g_fevertimeData:getNotUsedDailyFevertime_adventure()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_FevertimeConfirmPopupMulti')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FevertimeConfirmPopupList:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FevertimeConfirmPopupList:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FevertimeConfirmPopupList:refresh()
    local vars = self.vars
    local usable_fevertime = g_fevertimeData:getNotUsedDailyFevertime_adventure()
    --local active_fevertime = self:getActivatedFevertimeListInThisPopup()

    
--[LUA-print] 1594748783451    end
--[LUA-print] 1594741583196.9  curr
--[LUA-print] 1594741583451    start
    --local all_fevertime_list = g_fevertimeData:getAllStructFevertimeList()
    --for i1, all_struct_fevertime in pairs(all_fevertime_list) do
        --if (all_struct_fevertime:isDailyHottime() == true) then
            --print('add')
            --all_struct_fevertime:isActiveFevertime()
            --if (all_struct_fevertime:isActiveFevertime() == true) then
                --table.insert(usable_fevertime, all_struct_fevertime)
            --end
        --end
    --end

    --for i, v in pairs(active_fevertime) do
        --table.insert(usable_fevertime, v)
    --end
    
    local function create_func(ui, data)
        ui:setChangeDataCB(function()
            -- 테이블 뷰에서 해당 리스트 아이템 리프레시 or 삭제
            local usable_fevertime = g_fevertimeData:getNotUsedDailyFevertime_adventure()
            if (table.count(usable_fevertime) == 0) then
                self:close()
            else
                self:refresh()
            end
        end)
    end

    local node = vars['listNode']
    node:removeAllChildren()
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(900, 100 + 50)
    require('UI_FevertimeListItem')
    table_view:setCellUIClass(UI_FevertimeListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(usable_fevertime)
end

-------------------------------------
-- function getActivatedFevertimeListInThisPopup
-------------------------------------
--function UI_FevertimeConfirmPopupList:getActivatedFevertimeListInThisPopup()
    --local all_fevertime_list = g_fevertimeData:getAllStructFevertimeList()
    --local result_list = {}
    --for i1, all_struct_fevertime in pairs(all_fevertime_list) do
        --if (all_struct_fevertime:isDailyHottime() == true) then
            --print('all')
            --ccdump(all_struct_fevertime)
            --for i2, struct_fevertime in pairs(self.m_initialUsableFevertimeList) do
                --if(struct_fevertime['id'] == all_struct_fevertime['id']) then
                    --print('struct_fevertime')
                    --ccdump(struct_fevertime)
                    --table.insert(result_list, all_struct_fevertime)
                --end
            --end
        --end
    --end
    --print('1')
    --ccdump(all_fevertime_list)
    --print('2')
    --ccdump(self.m_initialUsableFevertimeList)
    --print('3')
    --ccdump(result_list)
--
    --return result_list
--end


-------------------------------------
-- function click_backKey
-------------------------------------
function UI_FevertimeConfirmPopupList:click_backKey()
    self:click_closeBtn()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_FevertimeConfirmPopupList:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_FevertimeConfirmPopupList)
