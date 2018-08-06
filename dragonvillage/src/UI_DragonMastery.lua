local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonMastery
-------------------------------------
UI_DragonMastery = class(PARENT,{
    })

UI_DragonMastery.TAB_LVUP = 'mastery' -- 특성 레벨업
UI_DragonMastery.TAB_SKILL = 'skill' -- 특성 스킬

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonMastery:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonMastery'
    self.m_bVisible = true or false
    self.m_titleStr = Str('특성')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMastery:init(doid)
    local vars = self:load('dragon_mastery.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonMastery')

    self:sceneFadeInAction()

    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    -- 정렬 도우미
    self:init_dragonSortMgr()
	--self:init_mtrDragonSortMgr(true) -- slime_first
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMastery:initUI()
    local vars = self.vars
    self:init_dragonTableView()
    self:initStatusUI()


    do -- 아모르의 서
        local table_item = TableItem()
        local item_id = ITEM_ID_AMOR
        do -- 아이템 이름
            local name = Str(table_item:getValue(item_id, 't_name'))
            vars['amorNameLabel']:setString(name)
        end

        do -- 아모르의 서 아이콘
            vars['amorItemNode']:removeAllChildren()
            local item_icon = IconHelper:getItemIcon(item_id)
            vars['amorItemNode']:addChild(item_icon)
        end
    end
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_DragonMastery:initTab()
    local vars = self.vars
    self:addTabAuto(UI_DragonMastery.TAB_LVUP, vars, vars['masteryLvUpMenu'])
    self:addTabAuto(UI_DragonMastery.TAB_SKILL, vars, vars['masterySkillMenu'])
    self:setTab(UI_DragonMastery.TAB_LVUP)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_DragonMastery:onChangeTab(tab, first)
    local vars = self.vars
end

-------------------------------------
-- function initStatusUI
-------------------------------------
function UI_DragonMastery:initStatusUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonMastery:initButton()
    local vars = self.vars
    vars['masteryLvUpBtn']:registerScriptTapHandler(function() self:click_masteryLvUpBtn() end)
    vars['amorBtn']:registerScriptTapHandler(function() self:click_amorBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMastery:refresh()
    self:refresh_dragonInfo()
    self:refresh_masteryInfo()
end

-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonMastery:refresh_dragonInfo()
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local vars = self.vars

    -- 배경
    local attr = dragon_obj:getAttr()
    if self:checkVarsKey('bgNode', attr) then    
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(dragon_obj:getDragonNameWithEclv())
    end

    do -- 드래곤 속성
        local attr = dragon_obj:getAttr()
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)
    end

    do -- 드래곤 역할(role)
        local role_type = dragon_obj:getRole()
        vars['typeLabel']:setString(dragonRoleTypeName(role_type))
    end

    do -- 드래곤 현재 정보 카드
        vars['dragonIconNode1']:removeAllChildren()
        local dragon_card = UI_DragonCard(dragon_obj)
        vars['dragonIconNode1']:addChild(dragon_card.root)
    end
end

-------------------------------------
-- function refresh_masteryInfo
-- @brief 특성 정보
-------------------------------------
function UI_DragonMastery:refresh_masteryInfo()
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local vars = self.vars

    -- 아모르의 서
    local req_count = 10 -- 임시로 하드코딩
    local own_count = g_userData:get('amor') or 0
    local str = Str('{1} / {2}', own_count, req_count)
    if (req_count <= own_count) then
        str = '{@possible}' .. str
    else
        str = '{@impossible}' .. str
    end
    vars['amorNumberLabel']:setString(str)


    -- 특성 레벨
    local mastery_lv = tonumber(dragon_obj['mastery_lv']) or 0
    if (mastery_lv <= 0) then
        vars['startNormalLvMenu']:setVisible(true)
        vars['startMasteryLvMenu']:setVisible(false)

        -- UI에 박혀있어서 설정할 필요가 없음
        -- vars['normalLvLabel1']:setString('60')
        -- vars['normalLvLabel2']:setString('1')
    else
        vars['startNormalLvMenu']:setVisible(false)
        vars['startMasteryLvMenu']:setVisible(true)

        vars['masteryLvLabel1']:setString(tostring(mastery_lv))
        vars['masteryLvLabel2']:setString(tostring(mastery_lv + 1))
    end


    -- 특성 포인트(남은 것)
    local mastery_point = tonumber(dragon_obj['mastery_point']) or 0
    vars['skillPointLabel1']:setString(tostring(mastery_point))
    vars['skillPointLabel2']:setString(tostring(mastery_point + 1))
end


-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonMastery:getDragonList()
    local dragon_dic = g_dragonsData:getDragonsList()

    -- 특성 조건이 되지 않는 드래곤 제거 (6성 60레벨)
    for oid, v in pairs(dragon_dic) do
        if (v:isMaxGradeAndLv() == false) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트 : 레벨업
-- @override
-------------------------------------
function UI_DragonMastery:getDragonMaterialList(doid)
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonMastery:click_dragonMaterial(t_dragon_data)
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonMastery:refresh_materialDragonIndivisual(doid)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonMastery:refresh_selectedMaterial()
end

-------------------------------------
-- function refresh_stats
-- @brief 능력치
-------------------------------------
function UI_DragonMastery:refresh_stats(t_dragon_data, lv)
end

-------------------------------------
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-- @override
-------------------------------------
function UI_DragonMastery:createDragonCardCB(ui, data)
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief 재료 카드 만든 후..
-------------------------------------
function UI_DragonMastery:createMtrlDragonCardCB(ui, data)
end

-------------------------------------
-- function click_masteryLvUpBtn
-- @brief 특성 레벨업 버튼
-------------------------------------
function UI_DragonMastery:click_masteryLvUpBtn()
    local possible = false
    local msg = '(테스트)레벨업 불가로 처리 중'

    if (not possible) then
        UIManager:toastNotificationRed(msg)
        local vars = self.vars

        cca.uiImpossibleAction(vars['amorBtn'])
        cca.uiImpossibleAction(vars['dragonIconNode2'])
        return
    end
end

-------------------------------------
-- function click_amorBtn
-- @brief 특성 레벨업 버튼
-------------------------------------
function UI_DragonMastery:click_amorBtn()
    UI_ItemInfoPopup(ITEM_ID_AMOR)
end

--@CHECK
UI:checkCompileError(UI_DragonMastery)
