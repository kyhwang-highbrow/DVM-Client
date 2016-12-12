local PARENT = UIC_TableViewCore

-------------------------------------
-- class UIC_TableView
-------------------------------------
UIC_TableView = class(PARENT, {
        m_cellUIClass = 'class',
        
        m_lSortInfo = 'table', -- {name = sort_func}
        m_currSortType = 'string',

        m_cellUICreateCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_TableView:init(node)
    do -- 정렬
        self.m_lSortInfo = {}
        self.m_currSortType = nil
    end
end

-------------------------------------
-- function setCellUIClass
-------------------------------------
function UIC_TableView:setCellUIClass(ui_class, ui_create_cb)
    self.m_cellUIClass = ui_class
    self.m_cellUICreateCB = ui_create_cb
end

-------------------------------------
-- function makeItemUI
-------------------------------------
function UIC_TableView:makeItemUI(data)
    local ui = self.m_cellUIClass(data)
    ui.root:setSwallowTouch(false)
    ui.root:setDockPoint(cc.p(0, 0))
    ui.root:setAnchorPoint(cc.p(0, 0))
    ui.root:retain()

    self.m_scrollView:addChild(ui.root)

    if self.m_cellUICreateCB then
        self.m_cellUICreateCB(ui, data)
    end

    return ui
end

-------------------------------------
-- function insertSortInfo
-------------------------------------
function UIC_TableView:insertSortInfo(sort_type, sort_func)
    self.m_lSortInfo[sort_type] = sort_func
end

-------------------------------------
-- function sortTableView
-- @brief
-------------------------------------
function UIC_TableView:sortTableView(sort_type, b_force)
    if (not b_force) and (self.m_currSortType == sort_type) then
        return
    end

    self.m_currSortType = sort_type

    local sort_func = self.m_lSortInfo[sort_type]
    table.sort(self.m_itemList, sort_func)

    --
    self:expandTemp(0.5)
end

-------------------------------------
-- function sortImmediately
-- @brief
-------------------------------------
function UIC_TableView:sortImmediately(sort_type)
    self.m_currSortType = sort_type

    local sort_func = self.m_lSortInfo[sort_type]
    table.sort(self.m_itemList, sort_func)

    self:clearCellsUsed()
    self:_updateCellPositions()
    self:_updateContentSize()
    self:scrollViewDidScroll()
end

-------------------------------------
-- function getItem
-- @breif
-------------------------------------
function UIC_TableView:getItem(unique_id)
    return self.m_itemMap[unique_id]
end

-------------------------------------
-- function addItem
-- @breif
-------------------------------------
function UIC_TableView:addItem(unique_id, t_data)
    self:delItem(unique_id)

    local t_item = {}
    t_item['unique_id'] = unique_id
    t_item['data'] = t_data

    self.m_itemMap[unique_id] = t_item
    self.m_itemList[#self.m_lItem + 1] = t_item
end

-------------------------------------
-- function delItem
-- @breif
-------------------------------------
function UIC_TableView:delItem(unique_id)
    -- map리스트에서 삭제
    self.m_itemMap[unique_id] = nil

    local idx = nil
    local t_item = nil

    for i,item in pairs(self.m_itemList) do
        if (item['unique_id'] == unique_id) then
            t_item = item
            idx = i
            break
        end
    end

    if t_item then
        local ui = t_item['ui']
        if ui then
            ui.root:removeFromParent()
            ui.root:release()
            t_item['ui'] = nil

            for i, v in ipairs(self._cellsUsed) do
                if v['idx'] == t_item['idx'] then
                    table.remove(self._cellsUsed, i)
                    break
                end
            end
        end
    end

    if idx then
        table.remove(self.m_itemList, idx)
    end
end

-------------------------------------
-- function getItemCount
-- @breif
-------------------------------------
function UIC_TableView:getItemCount()
    local count = table.count(self.m_itemList)
    return count
end