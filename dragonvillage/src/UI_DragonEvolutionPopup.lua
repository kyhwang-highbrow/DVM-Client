local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonEvolutionPopup
-------------------------------------
UI_DragonEvolutionPopup = class(PARENT,{
        m_evolutionDragonID = 'number', -- 진화 대상 드래곤 ID
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonEvolutionPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonEvolutionPopup'
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonEvolutionPopup:init(dragon_id)
    self.m_evolutionDragonID = dragon_id

    local vars = self:load('evolution_window.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonEvolutionPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonEvolutionPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonEvolutionPopup:initButton()
    local vars = self.vars
    vars['invenBtn']:registerScriptTapHandler(function() self:click_invenBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonEvolutionPopup:refresh()
    -- 드래곤의 능력치를 출력
    self:refresh_evolutionStatus()

    -- 진화 전 드래곤 정보
    self:refresh_evolutionDragonInfo_Curr()

    -- 진화 후 드래곤 정보
    self:refresh_evolutionDragonInfo_Next()

    -- 진화에 필요한 진화석 갱신
    self:refresh_evolutionStone()

    -- 진화 버튼 갱신
    self:refresh_evolutionButton()
end

-------------------------------------
-- function refresh_evolutionDragonInfo_Curr
-- @brief 진화 전 드래곤 정보
-------------------------------------
function UI_DragonEvolutionPopup:refresh_evolutionDragonInfo_Curr()
    local vars = self.vars
    local dragon_id = self.m_evolutionDragonID

    -- 드래곤의 데이터를 얻어옴
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    do -- 드래곤 에니메이터
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'])
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator:setScale(1)
        vars['dragonNode']:removeAllChildren()
        vars['dragonNode']:addChild(animator.m_node)
    end

    do -- 드래곤 이름
        local evolution_lv = t_dragon_data['evolution']
        vars['nameLabel1']:setString(Str(t_dragon['t_name']) .. '-' .. evolutionName(evolution_lv))
    end

    do -- 드래곤 등급
        vars['starNode1']:removeAllChildren()
        local star_res = 'res/ui/star020' .. t_dragon_data['grade'] .. '.png'
        local star_icon = cc.Sprite:create(star_res)
        star_icon:setDockPoint(cc.p(0.5, 0.5))
        star_icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['starNode1']:addChild(star_icon)
    end

    do -- 드래곤 레벨
        local curr_lv = t_dragon_data['lv']
        local max_lv = dragonMaxLevel(t_dragon_data['evolution'])
        local lv_str = Str('{1} / {2}', curr_lv, max_lv)
        vars['lvLabel1']:setString(lv_str)

        -- 레벨 달성도 라벨
        local percentage = math_floor((curr_lv / max_lv) * 100)
        vars['levelPercentLabel']:setString(Str('{1}%', percentage))

        -- 레벨 달성도 게이지
        vars['levelGg']:stopAllActions()
        vars['levelGg']:setPercentage(0)
        vars['levelGg']:runAction(cc.ProgressTo:create(0.2, percentage)) 
    end
end

-------------------------------------
-- function refresh_evolutionDragonInfo_Next
-- @brief 진화 후 드래곤 정보
-------------------------------------
function UI_DragonEvolutionPopup:refresh_evolutionDragonInfo_Next()
    local vars = self.vars
    local dragon_id = self.m_evolutionDragonID

    -- 드래곤의 데이터를 얻어옴
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    local evolution = t_dragon_data['evolution'] + 1

    if (evolution <= 3) then
        do -- 드래곤 에니메이터
            local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution)
            animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
            animator.m_node:setDockPoint(cc.p(0.5, 0.5))
            animator:setScale(1)
            vars['afterNode']:removeAllChildren()
            vars['afterNode']:addChild(animator.m_node)
        end

        do -- 드래곤 이름
            vars['nameLabel2']:setString(Str(t_dragon['t_name']) .. '-' .. evolutionName(evolution))
        end

        do -- 드래곤 등급
            vars['starNode2']:removeAllChildren()
            local star_res = 'res/ui/star020' .. t_dragon_data['grade'] .. '.png'
            local star_icon = cc.Sprite:create(star_res)
            star_icon:setDockPoint(cc.p(0.5, 0.5))
            star_icon:setAnchorPoint(cc.p(0.5, 0.5))
            vars['starNode2']:addChild(star_icon)
        end

        do -- 드래곤 레벨
            local lv_str = Str('{1} / {2}', 1, dragonMaxLevel(evolution))
            vars['lvLabel2']:setString(lv_str)
        end
    else
        vars['afterNode']:removeAllChildren()
        vars['nameLabel2']:setString('')
        vars['starNode2']:removeAllChildren()
        vars['lvLabel2']:setString('')
    end
end

-------------------------------------
-- function refresh_evolutionStone
-- @brief 진화에 필요한 진화석 갱신
-------------------------------------
function UI_DragonEvolutionPopup:refresh_evolutionStone()
    local vars = self.vars
    local dragon_id = self.m_evolutionDragonID

    -- 모든 노드 초기화
    for i=1, 4 do
        vars['needNode' .. i]:setVisible(false)
        vars['stoneNode' .. i]:removeAllChildren()
    end

    local l_need_stone_info = self:getNeedEvolutionStoneInfo(dragon_id)

    for i,t_data in ipairs(l_need_stone_info) do
        local rarity = t_data['rarity']
        local attr = t_data['attr']
        local full_type = t_data['full_type']
        local need_stone = t_data['need_stone']

        -- 보유 갯수
        local own_stone = g_evolutionStoneData:getEvolutionStoneCount(rarity, attr)

        -- 활성화
        vars['needNode' .. i]:setVisible(true)

        -- 아이콘
        local icon = IconHelper:getItemIcon(full_type)
        vars['stoneNode' .. i]:addChild(icon)

        -- 부족 아이콘
        if (own_stone < need_stone) then
            vars['alarmSprite' .. i]:setVisible(true)
        else
            vars['alarmSprite' .. i]:setVisible(false)
        end

        -- 갯수 라벨
        vars['stoneLabel' .. i]:setString(Str('{1}/{2}', own_stone, need_stone))
    end
end

-------------------------------------
-- function getNeedEvolutionStoneInfo
-- @brief 진화에 필요한 진화석 정보 얻어옴
-------------------------------------
function UI_DragonEvolutionPopup:getNeedEvolutionStoneInfo(dragon_id)
    -- 드래곤 데이터를 얻어옴
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)

    -- 드래곤의 속성
    local attr = t_dragon['attr']

    -- 진화 정보 얻어옴
    local rarity = dragonRarityStrToNum(t_dragon['rarity'])
    local table_evolution = TABLE:get('evolution')
    local t_evolution = table_evolution[rarity]

    -- 필요 진화석
    local l_need_stone = {}
    for rarity=1, 4 do
        -- 키의 형태 'evo1_stone_01'
        local key = 'evo' .. t_dragon_data['evolution'] .. '_stone_0' .. rarity
        local need_stone = t_evolution[key]

        if need_stone > 0 then
            local full_type = g_evolutionStoneData:makeEvolutionStoneFullType(rarity, attr)
            local t_data = {}
            t_data['rarity'] = rarity
            t_data['attr'] = attr
            t_data['full_type'] = full_type
            t_data['need_stone'] = need_stone
            table.insert(l_need_stone, t_data)
        end
    end

   return l_need_stone
end

-------------------------------------
-- function refresh_evolutionStatus
-- @brief 드래곤의 능력치를 출력
-------------------------------------
function UI_DragonEvolutionPopup:refresh_evolutionStatus()
    local vars = self.vars
    local dragon_id = self.m_evolutionDragonID

    -- 드래곤의 데이터를 얻어옴
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)

    -- 최대 등급 여부 확인
    local is_max_evolution = (t_dragon_data['evolution'] >= 3)
    
    -- 능력치 계산기
    local status_calc_curr = MakeOwnDragonStatusCalculator(dragon_id)    

    -- 최대 등급이 아닐 경우
    if (not is_max_evolution) then
        local status_calc_next = MakeOwnDragonStatusCalculator(dragon_id, {evolution=1, lv=-(t_dragon_data['lv']-1)})

        self:refresh_evolutionStatusIndivisual(status_calc_curr, status_calc_next, 'atk')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, status_calc_next, 'def')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, status_calc_next, 'aspd')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, status_calc_next, 'cri_chance')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, status_calc_next, 'hp')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, status_calc_next, 'cri_avoid')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, status_calc_next, 'avoid')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, status_calc_next, 'hit_rate')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, status_calc_next, 'cri_dmg')
    else
        self:refresh_evolutionStatusIndivisual(status_calc_curr, nil, 'atk')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, nil, 'def')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, nil, 'aspd')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, nil, 'cri_chance')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, nil, 'hp')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, nil, 'cri_avoid')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, nil, 'avoid')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, nil, 'hit_rate')
        self:refresh_evolutionStatusIndivisual(status_calc_curr, nil, 'cri_dmg')
    end
end

-------------------------------------
-- function refresh_evolutionButton
-- @brief 드래곤 진화 버튼 갱신
-------------------------------------
function UI_DragonEvolutionPopup:refresh_evolutionButton()
    local vars = self.vars
    local dragon_id = self.m_evolutionDragonID

    -- 드래곤의 데이터를 얻어옴
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    -- 최대 등급 여부 확인
    local is_max_evolution = (t_dragon_data['evolution'] >= 3)

    if (is_max_evolution == true) then
        vars['okBtn']:setEnabled(false)
        vars['priceLabel']:setString('MAX')
    else
        vars['okBtn']:setEnabled(true)

        -- 진화 정보 얻어옴
        local rarity = dragonRarityStrToNum(t_dragon['rarity'])
        local table_evolution = TABLE:get('evolution')
        local t_evolution = table_evolution[rarity]
        local key_gold = ('evo' .. t_dragon_data['evolution'] .. '_gold')
        local need_gold = t_evolution[key_gold]
        vars['priceLabel']:setString(comma_value(need_gold))
    end
end

-------------------------------------
-- function refresh_evolutionStatusIndivisual
-- @brief 드래곤 진화 능력치 개별 설정
-------------------------------------
function UI_DragonEvolutionPopup:refresh_evolutionStatusIndivisual(status_calc_curr, status_calc_next, type)
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
-- function click_invenBtn
-- @brief "보유 진화석" 버튼 클릭
-------------------------------------
function UI_DragonEvolutionPopup:click_invenBtn()
    UI_InventoryEvolutionStonePopup()
end

-------------------------------------
-- function click_okBtn
-- @brief "진화" 버튼 클릭
-------------------------------------
function UI_DragonEvolutionPopup:click_okBtn()
    local dragon_id = self.m_evolutionDragonID
    
    local success, l_invalid_data = g_dragonListData:evolutionDragon(dragon_id)

    if success then
        UI_DragonEvolutionResult(dragon_id)
        self:refresh()
    else
        for _,t_invalid_data in ipairs(l_invalid_data) do
            UIManager:toastNotificationRed(t_invalid_data['msg'])
        end
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonEvolutionPopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonEvolutionPopup)
