local PARENT = UI

-------------------------------------
-- class UI_DragonUpgradeCombineMaterialConfirmPopup
-------------------------------------
UI_DragonUpgradeCombineMaterialConfirmPopup = class(PARENT, {
        m_grade = 'number',
        m_lCombineDataList = 'list',
        m_finishCB = 'function',
    })

-------------------------------------
-- function init
-- @param grade : 합성 등급
-- @param l_combine_data_list : 합성 정보 리스트
-------------------------------------
function UI_DragonUpgradeCombineMaterialConfirmPopup:init(grade, l_combine_data_list, finish_cb)
    self.m_uiName = 'UI_DragonUpgradeCombineMaterialConfirmPopup'
    local vars = self:load('dragon_upgrade_material_confirm_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_cancelBtn() end, 'UI_DragonUpgradeCombineMaterialConfirmPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self.m_grade = grade
    self.m_lCombineDataList = l_combine_data_list
    self.m_finishCB = finish_cb

    self:initUI()

    self:initTableView()

    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonUpgradeCombineMaterialConfirmPopup:initUI()
    local vars = self.vars
    
    -- info label 
    local slime_grade = self.m_grade + 1
    local slime_id = 779104 + 10 * slime_grade
    
    local table_item = TABLE:get('item')
    local t_item = table_item[slime_id]
    local slime_name = t_item['t_name']
    
    local slime_count = #self.m_lCombineDataList
    vars['infoLabel']:setString(Str('{@default}다음과 같이 재료를 사용하여 {@yellow}{1} {2}마리{@default}를 합성합니다.\n합성하시겠습니까?', slime_name, slime_count))

    -- price label    
    local user_dragon_exp = g_userData:get('dragon_exp')
    local need_dragon_exp = 0
    local user_gold = g_userData:get('gold')
    local need_gold = 0

    for i, combine_data in ipairs(self.m_lCombineDataList) do
        need_dragon_exp = need_dragon_exp + combine_data.m_needExp
        need_gold = need_gold + combine_data.m_needGold
    end

    vars['dragonExpLabel']:setString(Str('{1}/{2}', comma_value(user_dragon_exp), comma_value(need_dragon_exp)))
    vars['goldLabel']:setString(Str('{1}/{2}', comma_value(user_gold), comma_value(need_gold)))
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_DragonUpgradeCombineMaterialConfirmPopup:initTableView()
    local vars = self.vars
    
    local node = vars['itemListNode']

    local l_material_list = {}

    for idx, combine_data in ipairs(self.m_lCombineDataList) do
        for doid, dragon_data in pairs(combine_data.m_mDragonObjectMap) do
            l_material_list[doid] = dragon_data
        end    
    end

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(150, 150)
    table_view.m_bAlignCenterInInsufficient = true -- 가운데 정렬
    table_view:setCellUIClass(UI_DragonCard)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	table_view:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view:setItemList(l_material_list)

    local sort_manager = SortManager_Dragon()
    sort_manager:addPreSortType('object_type', false, function(a, b, ascending) return sort_manager:sort_object_type(a, b, ascending) end)
    sort_manager:pushSortOrder('underling')
    sort_manager:pushSortOrder('lv')
    sort_manager:pushSortOrder('evolution')

    sort_manager:sortExecution(table_view.m_itemList)

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonUpgradeCombineMaterialConfirmPopup:initButton()
    local vars = self.vars

    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonUpgradeCombineMaterialConfirmPopup:refresh()
    local vars = self.vars
    
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_DragonUpgradeCombineMaterialConfirmPopup:click_cancelBtn()
    self.m_closeCB = nil
    self:close()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_DragonUpgradeCombineMaterialConfirmPopup:click_okBtn()
    local function finish_cb(ret)
        if (self.m_finishCB) then
            self.m_finishCB()
        end
        
        self:close()
    end

    local total_doids = ''
    local require_count = self.m_grade + 1

    for _, combine_data in ipairs(self.m_lCombineDataList) do
        local doids = ''
        
        for idx = 1, require_count do
            local t_dragon_data = combine_data.m_mDragonMappingIndex[idx]
            local doid = t_dragon_data['id']

            if (doids == '') then
                doids = doid
            else
                doids = doids .. ',' .. doid
            end
        end

        if (total_doids == '') then
            total_doids = doids
        else
            total_doids = total_doids .. '-' .. doids
        end
    end

    g_dragonsData:request_dragonCombine(total_doids, finish_cb) -- @param : doids, finish_cb (doids ex : a,b,c,d-e,f,g,b-h,i,j,k)
end


