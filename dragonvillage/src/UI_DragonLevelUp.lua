local PARENT = UI_DragonManage_Base
local MAX_DRAGON_LEVELUP_MATERIAL_MAX = 30 -- 한 번에 사용 가능한 재료 수

-------------------------------------
-- class UI_DragonLevelUp
-------------------------------------
UI_DragonLevelUp = class(PARENT,{
        m_mtrlTableViewTD = '', -- 재료
        m_mtrlDragonSortManager = 'SortManager_Dragon',

        m_dragonLevelUpUIHelper = 'UI_DragonLevelUpHelper',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonLevelUp:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonLevelUp'
    self.m_bVisible = true or false
    self.m_titleStr = Str('드래곤 레벨업')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLevelUp:init(doid, b_ascending_sort, sort_type)
    local vars = self:load('dragon_management_levelup_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonLevelUp')

    -- 정렬 매니저
    self.m_mtrlDragonSortManager = SortManager_Dragon()

    

    self:sceneFadeInAction()

    self:initUI()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr(b_ascending_sort, sort_type)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLevelUp:initUI()
    local vars = self.vars
    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonLevelUp:initButton()
    local vars = self.vars
    vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)

    do -- 정렬 관련 버튼들
        vars['sortSelectOrderBtn']:registerScriptTapHandler(function() self:clcik_sortSelectOrderBtn() end)

        vars['sortSelectBtn']:registerScriptTapHandler(function() self:click_sortSelectBtn() end)
        vars['sortSelectHpBtn']:registerScriptTapHandler(function() self:click_sortBtn('hp') end)
        vars['sortSelectDefBtn']:registerScriptTapHandler(function() self:click_sortBtn('def') end)
        vars['sortSelectAtkBtn']:registerScriptTapHandler(function() self:click_sortBtn('atk') end)
        vars['sortSelectAttrBtn']:registerScriptTapHandler(function() self:click_sortBtn('attr') end)
        vars['sortSelectLvBtn']:registerScriptTapHandler(function() self:click_sortBtn('lv') end)
        vars['sortSelectGradeBtn']:registerScriptTapHandler(function() self:click_sortBtn('grade') end)
        vars['sortSelectRarityBtn']:registerScriptTapHandler(function() self:click_sortBtn('rarity') end)
        vars['sortSelectFriendshipBtn']:registerScriptTapHandler(function() self:click_sortBtn('friendship') end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLevelUp:refresh()
    if self.m_selectDragonOID then
        self.m_dragonLevelUpUIHelper = UI_DragonLevelUpHelper(self.m_selectDragonOID, MAX_DRAGON_LEVELUP_MATERIAL_MAX)
    end
    self:refresh_dragonInfo()
    self:refresh_dragonLevelupMaterialTableView()
    self:refresh_selectedMaterial()
end

-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonLevelUp:refresh_dragonInfo()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    local vars = self.vars
    local did = t_dragon_data['did']

    -- 배경
    local attr = TableDragon:getDragonAttr(did)
    if self:checkVarsKey('bgNode', attr) then    
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

        -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(Str(t_dragon['t_name']))
    end
    
    do -- 드래곤 현재 정보 카드
        vars['dragonIconNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(t_dragon_data)
        vars['dragonIconNode']:addChild(dragon_card.root)
    end

    do -- 드래곤 리소스
        local evolution = t_dragon_data['evolution']
        vars['dragonNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:changeAni('idle', true)

        vars['dragonNode']:addChild(animator.m_node)
    end
end

-------------------------------------
-- function refresh_dragonLevelupMaterialTableView
-- @brief 드래곤 승급 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_DragonLevelUp:refresh_dragonLevelupMaterialTableView()
    local list_table_node = self.vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    
    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel(Str('레벨업을 도와줄 드래곤이 없어요 ㅠㅠ\n(리더로 설정되거나 모험 중인 드래곤은 사용할 수 없습니다)'))

    self.m_mtrlTableViewTD = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonLevelupMaterialList(self.m_selectDragonOID)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list)

    -- 정렬
    self:refresh_sortUI()
end

-------------------------------------
-- function getDragonLevelupMaterialList
-- @brief 드래곤 레벨업 재료
-------------------------------------
function UI_DragonLevelUp:getDragonLevelupMaterialList(doid)
    local l_dragon_list = g_dragonsData:getDragonsList()-- clone된 데이터를 사용

    -- 자기 자신 드래곤 제외
    l_dragon_list[doid] = nil

    -- 재료로 사용 불가능한 드래곤 제외
    for doid,v in pairs(l_dragon_list) do
        if (not g_dragonsData:possibleMaterialDragon(doid)) then
            l_dragon_list[doid] = nil
        end
    end

    return l_dragon_list
end

-------------------------------------
-- function clcik_sortSelectOrderBtn
-------------------------------------
function UI_DragonLevelUp:clcik_sortSelectOrderBtn()
    local sort_manager = self.m_mtrlDragonSortManager
    sort_manager:setAllAscending(not sort_manager.m_defaultSortAscending)
    self:refresh_sortUI()
end

-------------------------------------
-- function click_sortSelectBtn
-------------------------------------
function UI_DragonLevelUp:click_sortSelectBtn()
    local vars = self.vars
    vars['sortSelectNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_sortBtn
-------------------------------------
function UI_DragonLevelUp:click_sortBtn(sort_type)
    local sort_manager = self.m_mtrlDragonSortManager
    sort_manager:pushSortOrder(sort_type)
    self:refresh_sortUI()
end

-------------------------------------
-- function refresh_sortUI
-------------------------------------
function UI_DragonLevelUp:refresh_sortUI()
    local vars = self.vars

    local sort_manager = self.m_mtrlDragonSortManager

    -- 테이블 뷰 정렬
    local table_view = self.m_mtrlTableViewTD
    sort_manager:sortExecution(table_view.m_itemList)
    table_view:setDirtyItemList()

    -- 선택된 정렬 이름
    local sort_type = sort_manager:getTopSortingType()
    local sort_name = sort_manager:getSortName(sort_type)
    vars['sortSelectLabel']:setString(sort_name)

    -- 오름차순일경우
    if sort_manager.m_defaultSortAscending then
        vars['sortSelectOrderSprite']:setScaleY(-1)
    -- 내림차순일경우
    else
        vars['sortSelectOrderSprite']:setScaleY(1)
    end
end

-------------------------------------
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-------------------------------------
function UI_DragonLevelUp:createDragonCardCB(ui, data)
    local doid = data['id']

    local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)
    if (not possible) then
        if ui then
            ui:setShadowSpriteVisible(true)
        end
    end
end

-------------------------------------
-- function checkDragonSelect
-- @brief 선택이 가능한 드래곤인지 여부
-------------------------------------
function UI_DragonLevelUp:checkDragonSelect(doid)
    local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)

    if possible then
        return true
    else
        UIManager:toastNotificationRed(msg)
        return false
    end
end

-------------------------------------
-- function click_dragonMaterial
-------------------------------------
function UI_DragonLevelUp:click_dragonMaterial(t_dragon_data)
    local doid = t_dragon_data['id']

    local helper = self.m_dragonLevelUpUIHelper

    if (not helper:isSelectedDragon(doid)) then
        local is_can_add, fail_type = helper:isCanAdd()

        if (not is_can_add) then
            if (fail_type == 'max_cnt') then
                UIManager:toastNotificationRed(Str('한 번에 최대 {1}마리까지 가능합니다.', MAX_DRAGON_LEVELUP_MATERIAL_MAX))
            elseif (fail_type == 'max_lv') then
                UIManager:toastNotificationRed(Str('더 이상 레벨업할 수 없습니다.', MAX_DRAGON_LEVELUP_MATERIAL_MAX))
            end
            return
        end
    end

    self.m_dragonLevelUpUIHelper:modifyMaterial(doid)
    self:refresh_materialDragonIndivisual(doid)
    self:refresh_selectedMaterial()
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonLevelUp:refresh_materialDragonIndivisual(doid)
    if (not self.m_mtrlTableViewTD) then
        return
    end

    local item = self.m_mtrlTableViewTD:getItem(doid)
    if (not item) then
        return
    end
    
    local ui = item['ui']
    if (not ui) then
        return
    end

    local helper = self.m_dragonLevelUpUIHelper
    local is_selected = helper:isSelectedDragon(doid)
    ui:setShadowSpriteVisible(is_selected)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonLevelUp:refresh_selectedMaterial()
    local vars = self.vars
    
    local helper = self.m_dragonLevelUpUIHelper
    if (not helper) then
        return
    end

    local t_dragon_data = self.m_selectDragonData
    local doid = t_dragon_data['id']
    local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)

    vars['selectLabel']:setString(helper:getMaterialCountString())
    vars['priceLabel']:setString(comma_value(helper.m_price))
    vars['expGauge']:setPercentage(helper.m_expPercentage)
    
    vars['levelLabel']:setString(Str('레벨{1}/{2}', helper.m_changedLevel, helper.m_maxLevel))

    if possible then
        vars['expLabel']:setString(Str('{1}/{2}', helper.m_changedExp, helper.m_changedMaxExp))
    else
        vars['expLabel']:setString('')
        vars['expGauge']:setPercentage(100)
    end

    local plus_level = helper:getPlusLevel()
    vars['gradeLabel']:setString(Str('+{1}', plus_level))
end

-------------------------------------
-- function click_levelupBtn
-- @brief
-------------------------------------
function UI_DragonLevelUp:click_levelupBtn()
    local helper = self.m_dragonLevelUpUIHelper

    if (helper.m_materialCount <= 0) then
        UIManager:toastNotificationRed(Str('재료 드래곤을 선택해주세요!'))
        return
    end

    local function success_cb(ret)

        -- 재료로 사용된 드래곤 삭제
        if ret['deleted_dragons_oid'] then
            for _,doid in pairs(ret['deleted_dragons_oid']) do
                g_dragonsData:delDragonData(doid)

                -- 드래곤 리스트 갱신
                self.m_tableViewExt:delItem(doid)
            end
        end

        -- 드래곤 정보 갱신
        g_dragonsData:applyDragonData(ret['modified_dragon'])

        -- 골드 갱신
        if ret['gold'] then
            g_serverData:applyServerData(ret['gold'], 'user', 'gold')
            g_topUserInfo:refreshData()
        end

        self.m_bChangeDragonList = true

        self:setSelectDragonDataRefresh()

        local doid = self.m_selectDragonOID
        self:refresh_dragonIndivisual(doid)


        local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)
        if (not possible) then
            MakeSimplePopup(POPUP_TYPE.OK, msg, function() self:close() end)
        end
    end

    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID
    local src_doids = ''
    do
        for _doid,_ in pairs(helper.m_materialDoidMap) do
            if (src_doids == '') then
                src_doids = tostring(_doid)
            else
                src_doids = src_doids .. ',' .. tostring(_doid)
            end
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/levelup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('src_doids', src_doids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

--@CHECK
UI:checkCompileError(UI_DragonLevelUp)
