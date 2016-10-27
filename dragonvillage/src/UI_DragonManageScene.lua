local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonManageScene
-------------------------------------
UI_DragonManageScene = class(PARENT, {
        m_selectDragonButton = '',
        m_tempCondition = 'bool'
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageScene:init(isTempCondition)
    local vars = self:load('dragon_manage_scene.ui')
    
    --@TODO 임시 처리, 뒤로 갔을 때 이전 UI 나올 수 있도록
    self.m_tempCondition = isTempCondition or false
    if isTempCondition then
        UIManager:open(self, UIManager.POPUP)
    else
        UIManager:open(self, UIManager.SCENE)
    end
    
    self:init_dragonTableView()
    self:initVars()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonManageScene')

    --self:doActionReset()
    --self:doAction()
end

-------------------------------------
-- function init_dragonTableView
-------------------------------------
function UI_DragonManageScene:init_dragonTableView()
    local list_table_node = self.vars['listTableNode']

    -- 생성
    local function create_func(item)
        local ui = item['ui']
        ui.root:setScale(0.8)
    end

    -- 드래곤 클릭 콜백 함수
    local function click_dragon_item(item)
        self.m_selectDragonButton = item['ui']
        self:refreshSelectDragonInfo()
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node)
    table_view_ext:setCellInfo(120, 120)
    table_view_ext:setItemUIClass(UI_Ready_DragonListItem, click_dragon_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    table_view_ext:setItemInfo(g_dragonListData.m_lDragonList)
    table_view_ext:update()

    -- 최초 선택 드래곤 지정
    if (not self.m_selectDragonButton) then
        local item = table_view_ext.m_lItem[1]
        if item and item['ui'] then
            self.m_selectDragonButton = item['ui']
            self:refreshSelectDragonInfo()
        end
    end
end

-------------------------------------
-- function initVars
-------------------------------------
function UI_DragonManageScene:initVars()
    local vars = self.vars
    
    -- status 확장 버튼
    vars['expandBtn']:registerScriptTapHandler(function() self:click_expandBtn() end)

    -- 속성 버튼 (도움말 오픈)
    vars['attrBtn']:registerScriptTapHandler(function() self:click_helpBtn('attr') end)
    vars['roleBtn']:registerScriptTapHandler(function() self:click_helpBtn('role') end)
    vars['charTypeBtn']:registerScriptTapHandler(function() self:click_helpBtn('attack_type') end)

    -- 속성 버튼 (도움말 오픈) (능력치 상세보기 안에 포함)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_helpBtn('rarity') end)

    -- 대표 드래곤 설정
    vars['leaderBtn']:registerScriptTapHandler(function() self:click_leaderBtn() end)

    -- 드래곤 평가
    vars['assessBtn']:registerScriptTapHandler(function() self:click_assessBtn() end)

    -- 승급
    vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)

    -- 진화
    vars['evolutionBtn']:registerScriptTapHandler(function() self:evolutionBtn() end)

    -- 친밀도
    vars['friendshipBtn']:registerScriptTapHandler(function() self:click_friendshipBtn() end)

    do -- 스킬 관련 버튼
        vars['skillUpgradeBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"스킬 업그레이드" 미구현') end)
        vars['skillInfoBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"스킬 정보" 미구현') end)
    end

    vars['arrayBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"드래곤 정렬" 미구현') end)
    vars['switchBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"드래곤 리스트 변경" 미구현') end)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManageScene:click_exitBtn()
    if self.m_tempCondition then 
        UI.close(self)
    else
        local scene = SceneLobby()
        scene:runScene()
    end
end

-------------------------------------
-- function click_expandBtn
-- @brief 상세보기
-------------------------------------
function UI_DragonManageScene:click_expandBtn()
    local dragon_id = self.m_selectDragonButton.m_dataDragonID
    UI_DragonDetailPopup(dragon_id)
end

-------------------------------------
-- function click_helpBtn
-- @brief 도움말 오픈
-------------------------------------
function UI_DragonManageScene:click_helpBtn(type)
    MakeGuidePopup(type)
end

-------------------------------------
-- function click_leaderBtn
-- @brief 대표 드래곤 설정
-------------------------------------
function UI_DragonManageScene:click_leaderBtn()
    UIManager:toastNotificationRed('"대표 드래곤 설정" 미구현')
end

-------------------------------------
-- function click_assessBtn
-- @brief 드래곤 평가
-------------------------------------
function UI_DragonManageScene:click_assessBtn()
    UIManager:toastNotificationRed('"드래곤 평가" 미구현')
end

-------------------------------------
-- function click_upgradeBtn
-- @brief 승급 버튼
-------------------------------------
function UI_DragonManageScene:click_upgradeBtn()
    local function close_cb()
        self:refreshSelectDragonInfo()
    end

    local dragon_id = self.m_selectDragonButton.m_dataDragonID
    local ui = UI_DragonUpgradePopup(dragon_id)
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_evolutionBtn
-- @brief 진화 버튼
-------------------------------------
function UI_DragonManageScene:evolutionBtn()    
    local function close_cb()
        self:refreshSelectDragonInfo()
    end

    local dragon_id = self.m_selectDragonButton.m_dataDragonID
    local ui = UI_DragonEvolutionPopup(dragon_id)
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_friendshipBtn
-- @brief 친밀도 버튼
-------------------------------------
function UI_DragonManageScene:click_friendshipBtn()   
    local function close_cb()
        self:refreshSelectDragonInfo()
    end

    local dragon_id = self.m_selectDragonButton.m_dataDragonID
    local ui = UI_DragonFriendshipPopup(dragon_id)
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManageScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManageScene'
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function refreshSelectDragonInfo
-- @brief 선택된 드래곤 정보 갱신
-------------------------------------
function UI_DragonManageScene:refreshSelectDragonInfo()
    if (not self.m_selectDragonButton) then
        return
    end

    local vars = self.vars
    local dragon_id = self.m_selectDragonButton.m_dataDragonID

    -- 유저가 보유하고있는 드래곤의 정보
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)

    -- 테이블에 있는 드래곤의 정보
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]
    local attr = t_dragon['attr']
    local rarity = t_dragon['rarity']
    local stat_type = t_dragon['stat_type']

    do -- 드래곤 이름
        local evolution_lv = t_dragon_data['evolution']
        vars['nameLabel']:setString(Str(t_dragon['t_name']) .. '-' .. evolutionName(evolution_lv))
    end

    do -- 드래곤 실리소스
        local animator = self.m_selectDragonButton:getCharAnimator()
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 1))
        animator:setScale(1)
        vars['dragonNode']:removeAllChildren(false)
        vars['dragonNode']:addChild(animator.m_node)
    end
    
    do -- 드래곤 등급
        vars['starNode']:removeAllChildren()
        local star_res = 'res/ui/star010' .. t_dragon_data['grade'] .. '.png'
        local star_icon = cc.Sprite:create(star_res)
        star_icon:setDockPoint(cc.p(0.5, 0.5))
        star_icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['starNode']:addChild(star_icon)
    end

    do -- 드래곤 속성
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)
    end

    do -- 드래곤 역할(role)
        vars['roleNode']:removeAllChildren()
        local icon = IconHelper:getRoleIcon(t_dragon['role'])
        vars['roleNode']:addChild(icon)
    end

    do -- 드래곤 공격 타입(char_type)
        local attack_type = t_dragon['char_type']
        vars['charTypeNode']:removeAllChildren()
        local icon = IconHelper:getAttackTypeIcon(attack_type)
        vars['charTypeNode']:addChild(icon)
    end

    -- 능력치 계산기
    local status_calc = MakeOwnDragonStatusCalculator(dragon_id)

    do -- level
        local lv_str = Str('{1} / {2}', t_dragon_data['lv'], dragonMaxLevel(t_dragon_data['evolution']))
        vars['lvLabel']:setString(lv_str)
    end
    
    do -- 경혐치 exp
        local lv = t_dragon_data['lv']
        local table_exp = TABLE:get('exp_dragon')
        local t_exp = table_exp[lv] 
        local max_exp = t_exp['exp_d']
        local percentage = (t_dragon_data['exp'] / max_exp) * 100
        percentage = math_floor(percentage)
        vars['expLabel']:setString(Str('{1}%', percentage))

        vars['expGg']:stopAllActions()
        vars['expGg']:setPercentage(0)
        vars['expGg']:runAction(cc.ProgressTo:create(0.2, percentage)) 
    end

    do -- 기본 status
        vars['hp_label']:setString(status_calc:getFinalStatDisplay('hp'))
        vars['atk_p_label']:setString(status_calc:getFinalStatDisplay('atk'))
        vars['def_p_label']:setString(status_calc:getFinalStatDisplay('def'))
        vars['aspd_label']:setString(status_calc:getFinalStatDisplay('aspd'))
        vars['avoid_label']:setString(status_calc:getFinalStatDisplay('avoid'))
        vars['hit_rate_label']:setString(status_calc:getFinalStatDisplay('hit_rate'))
    end

    do -- 친밀도
        local t_friendship_data, t_friendship = g_friendshipData:getFriendship(dragon_id)

        -- label
        local friendship_lv = t_friendship_data['lv']
        local friendship_max_lv = 200
        local percentage = math_floor((friendship_lv / friendship_max_lv) * 100)
        vars['friendshipLabel']:setString(tostring(percentage))

        -- progress
        vars['friendshipGg']:stopAllActions()
        vars['friendshipGg']:setPercentage(0)
        vars['friendshipGg']:runAction(cc.ProgressTo:create(0.2, percentage)) 
    end

    do -- 스킬 아이콘 생성
        local skill_mgr = DragonSkillManager('dragon', dragon_id, t_dragon_data['grade'])
        local l_skill_icon = skill_mgr:getSkillIconList()
        for i=0, 6 do
            if l_skill_icon[i] then
                vars['skillNode' .. i]:removeAllChildren()
                vars['skillNode' .. i]:addChild(l_skill_icon[i].root)
                local lock = (t_dragon_data['grade'] < i)
                l_skill_icon[i]:setLockSpriteVisible(lock)
            end
        end
    end

    self.m_selectDragonButton:refreshDragonInfo()
end