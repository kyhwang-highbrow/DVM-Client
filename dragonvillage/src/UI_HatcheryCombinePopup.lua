local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_HatcheryCombinePopup
-------------------------------------
UI_HatcheryCombinePopup = class(PARENT,{
        m_dragonID = 'number',
        m_tableViewTD = 'UIC_TableViewTD',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_HatcheryCombinePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_HatcheryCombinePopup'
    self.m_bVisible = true or false
    self.m_titleStr = Str('조합') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_HatcheryCombinePopup:init(did)
    self.m_dragonID = did

    local vars = self:load('hatchery_combine_02.ui')
    UIManager:open(self, UIManager.POPUP, true)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_HatcheryCombinePopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HatcheryCombinePopup:initUI()
    local vars = self.vars

    self:init_TableView()

    do -- 드래곤 현재 정보 카드
        vars['dragonIconNode']:removeAllChildren()
        local dragon_card = MakeBirthDragonCard(self.m_dragonID)
        vars['dragonIconNode']:addChild(dragon_card.root)
    end

    do -- 드래곤 이름
        local name = TableDragon:getDragonName(self.m_dragonID)
        vars['dragonNameLabel']:setString(name)
    end

    do
        local table_dragon_combine = TableDragonCombine()
        local t_dragon_combine = table_dragon_combine:get(self.m_dragonID)

        local req_grade = t_dragon_combine['material_grade']
        local req_grade_max_lv = TableGradeInfo:getMaxLv(req_grade)
        local req_evolution = t_dragon_combine['material_evolution']

        -- 재료 조건 설명
        local msg = Str('{1}성 최대 레벨(Lv.{2}) 이상, {3} 이상 드래곤', req_grade, req_grade_max_lv, evolutionName(req_evolution))
        vars['descLabel']:setString(msg)

        -- 가격 표시
        vars['priceLabel']:setString(comma_value(t_dragon_combine['req_gold']))


        for i=1, 4 do
            local _did = t_dragon_combine['material_' .. i]
            local t_data = {}
            t_data['grade'] = req_grade
            t_data['lv'] = req_grade_max_lv
            t_data['evolution'] = req_evolution
            local dragon_card = MakeSimpleDragonCard(_did, t_data)
            vars['mtrlBG' .. i]:addChild(dragon_card.root)
            dragon_card.root:setScale(86/150)
            dragon_card:setShadowSpriteVisible(true)
            dragon_card.vars['shadowSprite']:setOpacity(100)

            dragon_card.vars['clickBtn']:registerScriptTapHandler(function()
                    local name = TableDragon:getDragonName(_did)
                    UIManager:toastNotificationRed(name)
                end)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HatcheryCombinePopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HatcheryCombinePopup:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_HatcheryCombinePopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_HatcheryCombinePopup:init_TableView()
    local list_table_node = self.vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)

        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data['did']) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100 + 10, 100 + 10)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_tableViewTD = table_view_td

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel('')

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonList()
    table_view_td:setItemList(l_dragon_list)
end

-------------------------------------
-- function getDragonList
-------------------------------------
function UI_HatcheryCombinePopup:getDragonList()
    local did = self.m_dragonID
    local t_ret = g_hatcheryData:combineMaterialList(did)

    return t_ret
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_HatcheryCombinePopup:click_dragonCard(did)
end

--@CHECK
UI:checkCompileError(UI_HatcheryCombinePopup)
