local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_RuneEnchantPopup
-------------------------------------
UI_RuneEnchantPopup = class(PARENT, {
        m_tRuneData = 'table',
        m_tableViewMaterials = 'UIC_TableViewTD',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneEnchantPopup:init(t_rune_data)
    self.m_tRuneData = t_rune_data

    local vars = self:load('dragon_rune_enhance.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RuneEnchantPopup')

    self:sceneFadeInAction()

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_RuneEnchantPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_RuneEnchantPopup'
    self.m_bVisible = true
    self.m_titleStr = Str('룬 강화')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RuneEnchantPopup:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneEnchantPopup:initUI()
    self:init_runeEnchantMaterials()
end

-------------------------------------
-- function init_runeEnchantMaterials
-------------------------------------
function UI_RuneEnchantPopup:init_runeEnchantMaterials()
    local roid = self.m_tRuneData['id']
    local node = self.vars['selectListNode']

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.7)
        
        local function click_func()
            local t_rune_data = data
            self:click_enchantMaterial(t_rune_data)
        end
        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(105, 105)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_RuneCard, create_func)
    table_view_td:setItemList(g_runesData:getRuneEnchantMaterials(roid))

    self.m_tableViewMaterials = table_view_td
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneEnchantPopup:initButton()
    local vars = self.vars
    --vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    --enhanceBtn
end

-------------------------------------
-- function refresh
-- @brief dragon_id로 드래곤의 상세 정보를 출력
-------------------------------------
function UI_RuneEnchantPopup:refresh()
    local vars = self.vars

    t_rune_data = self.m_tRuneData

    local t_rune_information = t_rune_data['information']

    do -- 룬 아이콘 표시
        vars['runeNode']:removeAllChildren()
        local rid = t_rune_data['rid']
        local count = 1
        local icon = UI_ItemCard(rid, count, t_rune_information)
        vars['runeNode']:addChild(icon.root)
    end

    -- 룬 이름
    vars['runeNameLabel']:setString(t_rune_information['full_name'])

    local str

    -- 메인 옵션
    str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['mopt'], 'category')
    vars['mainOptionLabel']:setString(str)
    str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['mopt'], 'value')
    vars['mainOptionStatusLabel']:setString(str)
    do -- 다음 레벨의 메인 옵션
        local next_lv_t_rune_data = clone(t_rune_data)
        next_lv_t_rune_data['lv'] = (next_lv_t_rune_data['lv'] + 1)
        local l_next_lv_rune_status = ServerData_Runes:makeRuneStatus(next_lv_t_rune_data)
        str = TableRuneStatus:makeRuneOptionStr(l_next_lv_rune_status['mopt'], 'next_value')
        vars['mainOptionStatusUpLabel']:setString(str)
    end

    -- 서브 옵션
    str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['sopt'], 'category')
    vars['subOptionLabel']:setString(str)
    str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['sopt'], 'value')
    vars['subOptionStatusLabel']:setString(str)

    -- 세트 효과
    vars['runeSetLabel']:setVisible(false)
end

-------------------------------------
-- function click_enchantMaterial
-- @brief 룬 강화 재료 클릭
-------------------------------------
function UI_RuneEnchantPopup:click_enchantMaterial(t_rune_data)
    ccdump(t_rune_data)
end

--@CHECK
UI:checkCompileError(UI_RuneEnchantPopup)
