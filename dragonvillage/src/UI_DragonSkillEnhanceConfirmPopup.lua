
local PARENT = UI
-------------------------------------
-- class UI_DragonSkillEnhanceConfirmPopup
-------------------------------------
UI_DragonSkillEnhanceConfirmPopup = class(PARENT,{    
    m_selectedMtrls = 'list<number>',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkillEnhanceConfirmPopup:init(mtrl_objs, ok_cb, cancel_cb) -- 드래곤의 경우 드래곤 오브젝트 아이디/ 아이템의 경우 아이템 아이디
    self:load('dragon_mastery_material_popup.ui')    
    self.m_selectedMtrls = mtrl_objs
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() cancel_cb() self:close() end, 'UI_DragonMasteryConfirmPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(ok_cb, cancel_cb)
    --self:initButton()
    self:initTableView()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkillEnhanceConfirmPopup:initUI(ok_cb, cancel_cb)
    local vars = self.vars
    local submsg = Str('드래곤 재료들이 포함되어 있습니다.')

    vars['okBtn']:registerScriptTapHandler(function() ok_cb() self:close() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['itemDscLabel']:setString(submsg)

    vars['confirmLabel']:setString(Str('스킬 레벨업을 진행하시겠습니까?'))
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_DragonSkillEnhanceConfirmPopup:initTableView()
    local vars = self.vars   
    local list_table_node = vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)
    end
    
    local function make_func(object)
        if (object['did'] == 'mastery_material') then
            return UI_ItemCard(object['item_id'], object['item_count'])
        else
            return UI_DragonCard(object)
        end
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableView(list_table_node)
    table_view_td.m_defaultCellSize = cc.size(100, 100)
    --table_view_td.m_nItemPerCell = 8
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setItemList(self.m_selectedMtrls)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view_td:setAlignCenter(true)
end