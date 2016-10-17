local PARENT = UI

-------------------------------------
-- class UI_DragonUpgradePopup
-------------------------------------
UI_DragonUpgradePopup = class(PARENT, ITopUserInfo_EventListener:getCloneTable(), {
        m_upgradeDragonID = 'number',
        m_upgradeDragonAnimator = 'Animator',
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonUpgradePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonUpgradePopup'
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonUpgradePopup:init(dragon_id)
    self.m_upgradeDragonID = dragon_id

    local vars = self:load('upgrade_window.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonUpgradePopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh(dragon_id) 
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonUpgradePopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonUpgradePopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['skillInfoBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"스킬 정보" 미구현') end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonUpgradePopup:refresh()
    local dragon_id = self.m_upgradeDragonID

    local vars = self.vars

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)
    
    local is_max_grade = (t_dragon_data['grade'] >= 6)
    local next_grade = t_dragon_data['grade'] + 1

    if is_max_grade then
        vars['okBtn']:setVisible(false)
        vars['upgradeSprite']:setVisible(false)
        vars['maxLabel']:setVisible(true)
        vars['starVisual']:setVisual('group', 'grade_06')
    else
        vars['okBtn']:setVisible(true)
        vars['upgradeSprite']:setVisible(true)
        vars['maxLabel']:setVisible(false)
        vars['starVisual']:setVisual('group', 'upgrade' .. next_grade)
    end

    do -- 카드 보유 갯수
        local rarity = dragonRarityStrToNum(t_dragon['rarity'])
        local table_upgrade = TABLE:get('upgrade')
        local t_upgrade = table_upgrade[rarity]

        local key = 'cost_card_0' .. t_dragon_data['grade']
        local max_count = t_upgrade[key]
        local count = t_dragon_data['cnt']

        if (max_count == 0) then
            vars['cardGg']:setPercentage(100)
            vars['cardLabel']:setString(Str('{1}/{2}', count, 'MAX'))
        else
            local percentage = math_floor((count / max_count) * 100)
            vars['cardGg']:setPercentage(percentage)
            vars['cardLabel']:setString(Str('{1}/{2}', count, max_count))

            -- 금액
            local key = 'cost_gold_0' .. t_dragon_data['grade']
            local need_gold = t_upgrade[key]
            vars['priceLabel']:setString(comma_value(need_gold))
        end
    end

    -- 드래곤 정보 갱신
    self:refresh_dragonInfo(dragon_id)

    -- 드래곤 승급 능력치 갱신
    self:refresh_upgradeStatus(dragon_id)

    -- 스킬 아이콘 생성
    self:refresh_skillIcons(dragon_id)
end

-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonUpgradePopup:refresh_dragonInfo(dragon_id)
    local vars = self.vars
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)

    -- 드래곤 명칭
    vars['nameLabel']:setString(Str(t_dragon['t_name']) .. '-' .. evolutionName(t_dragon_data['evolution']))

    -- 레벨 표기
    vars['lvLabel']:setString(Str('레벨{1}/{2}', t_dragon_data['lv'], 60))

    -- 드래곤 에니메이션
    if (not self.m_upgradeDragonAnimator) then
        vars['dragonNode']:removeAllChildren()

        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'])
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        vars['dragonNode']:addChild(animator.m_node)
        animator:changeAni('idle', true)

        self.m_upgradeDragonAnimator = animator
    end
end

-------------------------------------
-- function refresh_upgradeStatus
-- @brief 드래곤 승급 능력치
-------------------------------------
function UI_DragonUpgradePopup:refresh_upgradeStatus(dragon_id)
    local vars = self.vars
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)

    -- 능력치 계산기
    local status_calc_curr = MakeOwnDragonStatusCalculator(dragon_id)

    local is_max_grade = (t_dragon_data['grade'] >= 6)

    if (not is_max_grade) then
        local status_calc_next = MakeOwnDragonStatusCalculator(dragon_id, {grade=1})

        self:refresh_upgradeStatusIndivisual(status_calc_curr, status_calc_next, 'atk')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, status_calc_next, 'def')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, status_calc_next, 'aspd')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, status_calc_next, 'cri_chance')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, status_calc_next, 'hp')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, status_calc_next, 'cri_avoid')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, status_calc_next, 'avoid')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, status_calc_next, 'hit_rate')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, status_calc_next, 'cri_dmg')
    else
        self:refresh_upgradeStatusIndivisual(status_calc_curr, nil, 'atk')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, nil, 'def')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, nil, 'aspd')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, nil, 'cri_chance')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, nil, 'hp')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, nil, 'cri_avoid')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, nil, 'avoid')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, nil, 'hit_rate')
        self:refresh_upgradeStatusIndivisual(status_calc_curr, nil, 'cri_dmg')
    end
    
end

-------------------------------------
-- function refresh_upgradeStatusIndivisual
-- @brief 드래곤 승급 능력치 개별 설정
-------------------------------------
function UI_DragonUpgradePopup:refresh_upgradeStatusIndivisual(status_calc_curr, status_calc_next, type)
    do -- 현재 능력치
        local label = self.vars['base_' .. type .. '_label']
        local curr_stat = status_calc_curr:getFinalStat(type)
        label:setString(comma_value(math_floor(curr_stat)))
    end

    do -- 업그레이드 후 능력치
        local label = self.vars[type .. '_label']
        if status_calc_next then
            local next_stat = status_calc_next:getFinalStat(type)
            local str = comma_value(math_floor(next_stat))
            label:setString(str)
        else
            label:setString('')
        end
    end
end

-------------------------------------
-- function refresh_skillIcons
-- @brief 스킬 아이콘
-------------------------------------
function UI_DragonUpgradePopup:refresh_skillIcons(dragon_id)
    local vars = self.vars
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)

    -- 스킬 아이콘 생성
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

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonUpgradePopup:click_exitBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self:close()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonUpgradePopup:click_okBtn()
    -- 드래곤 ID
    local dragon_id = self.m_upgradeDragonID

    local success, msg = g_dragonListData:upgradeDragon(dragon_id)

    if success then
        UI_DragonUpgradeResult(dragon_id)
        self:refresh()
    else
        UIManager:toastNotificationRed(msg)
    end
end

--@CHECK
UI:checkCompileError(UI_DragonUpgradePopup)
