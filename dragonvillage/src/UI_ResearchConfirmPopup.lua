local PARENT = UI
-------------------------------------
--- @class UI_ResearchConfirmPopup
-------------------------------------
UI_ResearchConfirmPopup = class(PARENT,{
    m_researchIdList = 'number',
    m_researchType = 'number',
    m_researchCostMap = 'number',
    m_viewType = 'string', -- 'buy', 'only_view'
})

-------------------------------------
-- function init
-------------------------------------
function UI_ResearchConfirmPopup:init(research_id, view_type)
    self.m_viewType = view_type
    self:makeResearchIdList(research_id, view_type)
    self.m_uiName = 'UI_ResearchConfirmPopup'
    self:load('research_confirm_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ResearchConfirmPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:makeTableView()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function makeResearchIdList
-------------------------------------
function UI_ResearchConfirmPopup:makeResearchIdList(research_id, view_type)
    if view_type == 'view' then
        self.m_researchIdList = {research_id}
        self.m_researchCostMap = {}
        local item_id = TableResearch:getInstance():getResearchCostItemId(research_id)
        local cost = TableResearch:getInstance():getResearchCost(research_id)
        self.m_researchCostMap[item_id] = cost
    else
        local research_type = TableResearch:getInstance():getResearchType(research_id)
        local item_list, cost_map  = g_researchData:getAvailableResearchIdList(research_id, research_type)
        self.m_researchIdList = item_list
        self.m_researchCostMap = cost_map
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ResearchConfirmPopup:initUI()
	local vars = self.vars
    local item_list = self.m_researchIdList

    do -- 능력치 텍스트
        local str = TableResearch:getInstance():getResearchBuffStr(item_list)
        vars['infoLabel']:setString(str)
    end

    do -- 가격
        for item_id, price_value in pairs(self.m_researchCostMap) do
            local price_icon = IconHelper:getPriceIcon(item_id)
            vars['priceNode']:removeAllChildren()
            vars['priceNode']:addChild(price_icon)            
            vars['priceLabel']:setString(comma_value(price_value))

            if g_researchData:getUserRearchItem(item_id) < price_value then
                vars['priceLabel']:setStringArg(string.format('{@RED}%s{@}', comma_value(price_value)))
            else
                vars['priceLabel']:setStringArg(comma_value(price_value))
            end

            AlignUIPos({ vars['priceNode'], vars['priceLabel'] }, 'HORIZONTAL', 'CENTER', 10) -- 가로 방향으로 가운데 정렬, offset = 10
            
            break
        end
    end

    do -- 버튼
        if self.m_viewType == 'view' then
            vars['okBtn']:setBlockMsg('')
            vars['okBtn']:setEnabled(false)
        else
            vars['okBtn']:setBlockMsg(nil)
            vars['okBtn']:setEnabled(true)
        end
    end
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_ResearchConfirmPopup:makeTableView()
    local vars = self.vars
    local item_list = self.m_researchIdList
    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['infoBtn']:registerScriptTapHandler(function()

        end)
    end
    
    local table_view = UIC_TableView(vars['listNode'])
    table_view.m_defaultCellSize = cc.size(120, 200)
    table_view:setCellUIClass(UI_ResearchItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(item_list)
    table_view:setAlignCenter(true)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ResearchConfirmPopup:initButton()
    local vars = self.vars
    vars['cancelBtn']:registerScriptTapHandler(function() 
        self:close()
    end)

    vars['okBtn']:registerScriptTapHandler(function() 
        self:click_upgradeBtn()
    end)
end
--[[ 
-------------------------------------
--- @function isEnoughCost
-- @boolean number
-------------------------------------
function UI_ResearchConfirmPopup:isEnoughCost()
    for item_id, need_cost in pairs(self.m_researchCostMap) do
        if need_cost > g_researchData:getUserRearchItem(item_id) then
            return false
        end
    end
    return true
end ]]

-------------------------------------
--- @function refresh
-------------------------------------
function UI_ResearchConfirmPopup:refresh()
    local vars = self.vars
end

-------------------------------------
--- @function click_upgradeBtn
-------------------------------------
function UI_ResearchConfirmPopup:click_upgradeBtn()
    local success_cb = function(ret)
        UIManager:toastNotificationGreen(Str('연구가 완료되었습니다.'))
        self:close()
    end

    local research_id = self.m_researchIdList[#self.m_researchIdList]
    local price = table.getFirst(self.m_researchCostMap)

   g_researchData:request_researchUpgrade(research_id, price, success_cb)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ResearchConfirmPopup.open(research_id, research_type, view_type)

end

--@CHECK
UI:checkCompileError(UI_ResearchConfirmPopup)
