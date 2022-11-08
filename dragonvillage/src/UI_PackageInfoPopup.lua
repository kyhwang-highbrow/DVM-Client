--@inherit UI
local PARENT = UI

-------------------------------------
---@class UI_PackageInfoPopup
-------------------------------------
UI_PackageInfoPopup = class(PARENT, {
    m_itemList = 'table'
})

-------------------------------------
-- function init
-------------------------------------
function UI_PackageInfoPopup:init(item_list, ui_name)
    self.m_uiName = 'UI_PackageInfoPopup'
    self.m_resName = ui_name

    self.m_itemList = item_list
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_PackageInfoPopup:init_after()
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
function UI_PackageInfoPopup:initUI()
    local vars = self.vars

    if isTable(self.m_itemList) then
        local total_weight = 0
        for i, v in ipairs(self.m_itemList) do
            total_weight = total_weight + v['pick_weight']
        end

        for i, v in ipairs(self.m_itemList) do
            local item_id = v['item_id']
            local item_count = comma_value(v['count'])
            local item_draw_probability = v['pick_weight'] / total_weight * 100

            -- 아이템 아이콘
            local item_node = vars['itemNode' .. i]
            if (item_node ~= nil) then
                local item_icon = IconHelper:getItemIcon(item_id)
                item_node:addChild(item_icon)
            end

            -- 아이템 이름 및 개수
            local item_label = vars['itemLabel' .. i]
            if (item_label ~= nil) then
                local item_name = TableItem:getItemName(item_id)
                item_label:setString(Str('{1} {2}개', item_name, item_count))
            end

            local percent_label = vars['percentLabel' .. i]
            if (percent_label ~= nil) then
                local percent_str = string.format('%d%%', item_draw_probability)
                percent_label:setString(percent_str)
            end
        end
    end

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PackageInfoPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PackageInfoPopup:refresh()
    local vars = self.vars

end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_PackageInfoPopup:click_closeBtn()
    self:close()
end