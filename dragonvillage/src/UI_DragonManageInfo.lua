local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonManageInfo
-------------------------------------
UI_DragonManageInfo = class(PARENT,{
        m_selectDragonData = 'table',
        m_selectDragonOID = 'number',
        m_tableViewExt = 'TableViewExtension',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManageInfo:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManageInfo'
    self.m_bVisible = true or false
    self.m_titleStr = Str('드래곤 관리') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageInfo:init()
    local vars = self:load('dragon_management_info.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManageInfo')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManageInfo:initUI()
    self:init_dragonTableView()
    self:setDefaultSelectDragon()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManageInfo:initButton()
    local vars = self.vars
    
    do -- 우상단 버튼들 초기화
        -- 승급
        vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)

        -- 진화
        vars['evolutionBtn']:registerScriptTapHandler(function()  end)

        -- 친밀도
        vars['friendshipBtn']:registerScriptTapHandler(function() end)

        -- 장비
        vars['equipmentBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"장비" 미구현') end)

        -- 강화
        vars['reinforceBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"강화" 미구현') end)
    end

    do -- 좌상단 버튼들 초기화
        -- 보기
        vars['switchBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"보기" 미구현') end)

        -- 대표
        vars['leaderBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"대표 설정" 미구현') end)

        -- 평가
        vars['assessBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"평가" 미구현') end)

        -- 잠금
        vars['lockBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"잠금" 미구현') end)

        -- 작별
        vars['sellBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"작별" 미구현') end)
    end

    do -- 하단 버튼들 초기화
        -- 도감
        vars['collectionBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"도감" 미구현') end)
        
        -- 정렬
        vars['sortBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"정렬" 미구현') end)
        
        -- 오름차순, 내림차순
        vars['sortOrderBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"오름차순, 내림차순" 미구현') end)
    end

    do -- 기타 버튼
        -- 능력치 상세보기
        vars['detailBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"능력치 상세보기" 미구현') end)

        -- 스킬 상세보기
        vars['skillBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"스킬 상세보기" 미구현') end)

        -- 장비 개별 버튼 1~3
        vars['equipSlotBtn1']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"장비" 미구현') end)
        vars['equipSlotBtn2']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"장비" 미구현') end)
        vars['equipSlotBtn3']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"장비" 미구현') end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageInfo:refresh()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    -- 드래곤 기본 정보 변경
    self:refresh_dragonBasicInfo(t_dragon_data, t_dragon)

    -- 아이콘 갱신
    self:refresh_icons(t_dragon_data, t_dragon)

    -- 능력치 정보 갱신
    self:refresh_status(t_dragon_data, t_dragon)
end

-------------------------------------
-- function refresh_dragonBasicInfo
-- @brief 드래곤 기본 정보 변경
-------------------------------------
function UI_DragonManageInfo:refresh_dragonBasicInfo(t_dragon_data, t_dragon)
    local vars = self.vars

    do -- 드래곤 이름
        local evolution_lv = t_dragon_data['evolution']
        vars['nameLabel']:setString(Str(t_dragon['t_name']) .. '-' .. evolutionName(evolution_lv))
    end

    do -- 드래곤 등급
        vars['starNode']:removeAllChildren()
        local star_res = 'res/ui/star020' .. t_dragon_data['grade'] .. '.png'
        local star_icon = cc.Sprite:create(star_res)
        star_icon:setDockPoint(cc.p(0.5, 0.5))
        star_icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['starNode']:addChild(star_icon)
    end

    do -- 드래곤 실리소스
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'], t_dragon['attr'])
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        vars['dragonNode']:removeAllChildren(false)
        vars['dragonNode']:addChild(animator.m_node)

        animator:changeAni('pose_1', false)
        animator:addAniHandler(function() animator:changeAni('idle', true) end)
        animator:setAlpha(0)
        animator:runAction(cc.FadeIn:create(0.1))
    end
end

-------------------------------------
-- function refresh_icons
-- @brief 아이콘 갱신
-------------------------------------
function UI_DragonManageInfo:refresh_icons(t_dragon_data, t_dragon)
    local vars = self.vars

    do -- 희귀도
        local rarity = t_dragon['rarity']
        vars['rarityNode']:removeAllChildren()
        local icon = IconHelper:getRarityIcon(rarity)
        vars['rarityNode']:addChild(icon)

        vars['rarityLabel']:setString(dragonRarityName(rarity))
    end

    do -- 드래곤 속성
        local attr = t_dragon['attr']
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)

        vars['attrLabel']:setString(dragonAttributeName(attr))
    end

    do -- 드래곤 역할(role)
        local role_type = t_dragon['role']
        vars['roleNode']:removeAllChildren()
        local icon = IconHelper:getRoleIcon(role_type)
        vars['roleNode']:addChild(icon)

        vars['roleLabel']:setString(dragonRoleName(role_type))
    end

    do -- 드래곤 공격 타입(char_type)
        local attack_type = t_dragon['char_type']
        vars['charTypeNode']:removeAllChildren()
        local icon = IconHelper:getAttackTypeIcon(attack_type)
        vars['charTypeNode']:addChild(icon)

        vars['charTypeLabel']:setString(dragonAttackTypeName(attack_type))
    end
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonManageInfo:refresh_status(t_dragon_data, t_dragon)
    local vars = self.vars
    local dragon_id = t_dragon['did']
    local lv = t_dragon_data['lv']
    local grade = t_dragon_data['grade']
    local evolution = t_dragon_data['evolution']

    -- 능력치 계산기
    local status_calc = MakeDragonStatusCalculator(dragon_id, lv, grade, evolution)

    vars['atk_label']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['def_label']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hp_label']:setString(status_calc:getFinalStatDisplay('hp'))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManageInfo:click_exitBtn()
    self:close()
end

-------------------------------------
-- function setSelectDragonData
-------------------------------------
function UI_DragonManageInfo:setSelectDragonData(dragon_object_id, b_force)
    if (not b_force) and (self.m_selectDragonOID == dragon_object_id) then
        return
    end

    self.m_selectDragonOID = dragon_object_id
    self.m_selectDragonData = g_dragonsData:getDragonDataFromUid(dragon_object_id)

    self:refresh()
end

-------------------------------------
-- function setDefaultSelectDragon
-------------------------------------
function UI_DragonManageInfo:setDefaultSelectDragon()
    local item = self.m_tableViewExt.m_lItem[1]

    if (item) then
        local dragon_object_id = item['data']['id']
        local b_force = true
        self:setSelectDragonData(dragon_object_id, b_force)
    end
end

-------------------------------------
-- function click_upgradeBtn
-- @brief 승급 버튼
-------------------------------------
function UI_DragonManageInfo:click_upgradeBtn()
end

-------------------------------------
-- function init_dragonTableView
-------------------------------------
function UI_DragonManageInfo:init_dragonTableView()
    local list_table_node = self.vars['listTableNode']

    -- 생성
    local function create_func(item)
        local ui = item['ui']
        ui.root:setScale(0.7)
    end

    -- 드래곤 클릭 콜백 함수
    local function click_dragon_item(item)
        local data = item['data']
        local dragon_object_id = data['id']
        self:setSelectDragonData(dragon_object_id)
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node)
    table_view_ext:setCellInfo(105, 105)
    table_view_ext:setItemUIClass(UI_DragonCard, click_dragon_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    --table_view_ext:setItemInfo(g_dragonListData.m_lDragonList)
    table_view_ext:setItemInfo(g_dragonsData:getDragonsList())
    table_view_ext:update()

    -- 정렬
    local function default_sort_func(a, b)
        local a = a['data']
        local b = b['data']

        return a['did'] < b['did']
    end
    table_view_ext:insertSortInfo('default', default_sort_func)

    table_view_ext:sortTableView('default')

    self.m_tableViewExt = table_view_ext
end

--@CHECK
UI:checkCompileError(UI_DragonManageInfo)
