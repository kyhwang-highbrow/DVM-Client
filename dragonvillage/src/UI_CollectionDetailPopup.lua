local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_CollectionDetailPopup
-------------------------------------
UI_CollectionDetailPopup = class(PARENT,{
        m_lDragonsItem = 'list',
        m_currIdx = 'number',
        m_dragonEvolutionIconList = '',

        -- refresh 체크 용도
        m_collectionLastChangeTime = 'timestamp',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionDetailPopup:init(l_dragons_item, init_idx, init_evolution)
    self.m_lDragonsItem = l_dragons_item
    self.m_currIdx = nil

    local vars = self:load('collection_detail_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CollectionDetailPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(init_evolution)
    self:initButton()
    self:refresh()

    self:setIdx(init_idx)

    self:sceneFadeInAction()

    self.m_collectionLastChangeTime = g_collectionData:getLastChangeTimeStamp()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionDetailPopup:initUI(init_evolution)
    self:initTab(init_evolution)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionDetailPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)

    -- 능력치 상세보기
    vars['detailBtn']:registerScriptTapHandler(function() self:click_detailBtn() end)

    -- 인연포인트 뽑기
    vars['drawBtn']:registerScriptTapHandler(function() self:click_drawBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CollectionDetailPopup:refresh()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_CollectionDetailPopup:initTab(init_evolution)
    local vars = self.vars
    self:addTab('hatch', vars['evolutionBtn1'])
    self:addTab('hatchling', vars['evolutionBtn2'])
    self:addTab('adult', vars['evolutionBtn3'])

    if (init_evolution == 1) then
        self:setTab('hatch')

    elseif (init_evolution == 2) then
        self:setTab('hatchling')

    elseif (init_evolution == 3) then
        self:setTab('adult')

    else
        self:setTab('adult')
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_CollectionDetailPopup:onChangeTab(tab, first)
    self:onChangeEvolution()
end

-------------------------------------
-- function onChangeDragon
-------------------------------------
function UI_CollectionDetailPopup:onChangeDragon()
    local t_dragon = self:getCurrDragonTable()
    if (not t_dragon) then
        return
    end

    local vars = self.vars


    -- 드래곤 이름
    vars['nameLabel']:setString(Str(t_dragon['t_name']))

    -- 배경
    local attr = t_dragon['attr']
    if self:checkVarsKey('bgNode', attr) then    
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end   


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

    do -- 인연 포인트
        -- 드래곤 아이콘
        local did = t_dragon['did']
        local card = MakeSimpleDragonCard(did)
        card.vars['clickBtn']:setEnabled(false)
        vars['dragonCradNode']:addChild(card.root)

        -- 인연포인트 값 얻어오기
        local req_rpoint = TableDragon():getRelationPoint(did)
        local cur_rpoint = g_collectionData:getRelationPoint(did)
        
        -- 인연포인트 표시
        local str = Str('{1}/{2}', comma_value(cur_rpoint), comma_value(req_rpoint))
        vars['relationPointLabel']:setString(str)

        -- 소환 가능 개수 표시
        local num_possible = math_floor(cur_rpoint / req_rpoint)
        vars['dscLabel']:setString(Str('{1}마리 소환 가능', num_possible))

        -- 소환 가능 하일라이트
        vars['notiSprite']:setVisible(num_possible > 0)
    end

    do -- 드래곤 스토리
        local did = t_dragon['did']
        local story_str = TableDragon:getDragonStoryStr(did)
        vars['storyLabel']:setString(story_str)
    end

    do -- 진화단계별 아이콘
        self.m_dragonEvolutionIconList = {}
        for i=1, MAX_DRAGON_EVOLUTION do
            local node = vars['evolutionNode' .. i]
            node:removeAllChildren()

            -- 진화단계별 아이콘 생성
            local did = t_dragon['did']
            local card = MakeSimpleDragonCard(did, {['evolution']=i})
            card:setButtonEnabled(false) -- 아이콘의 버튼 사용하지 않음
            node:addChild(card.root)

            self.m_dragonEvolutionIconList[i] = card
        end
    end

    self:onChangeEvolution()
end

-------------------------------------
-- function onChangeEvolution
-------------------------------------
function UI_CollectionDetailPopup:onChangeEvolution()
    local t_dragon = self:getCurrDragonTable()
    if (not t_dragon) then
        return
    end

    local vars = self.vars
    local t_dragon_data = self:makeDragonData()

    do -- 선택된 드래곤 진화단계 아이콘 하일라이트 표시
        local evolution = self:getEvolutionNumber()
        for i,v in pairs(self.m_dragonEvolutionIconList) do
            local visible = (i == evolution)
            v:setHighlightSpriteVisible(visible)
        end
    end

    do -- 드래곤 인게임 리소스
        local evolution = self:getEvolutionNumber()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['dragonNode']:removeAllChildren()
        vars['dragonNode']:addChild(animator.m_node)
    end

    
    do -- 능력치 계산기
        local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data)
        vars['cri_dmg_label']:setString(status_calc:getFinalStatDisplay('cri_dmg'))
        vars['hit_rate_label']:setString(status_calc:getFinalStatDisplay('hit_rate'))
        vars['avoid_label']:setString(status_calc:getFinalStatDisplay('avoid'))
        vars['cri_avoid_label']:setString(status_calc:getFinalStatDisplay('cri_avoid'))
        vars['cri_chance_label']:setString(status_calc:getFinalStatDisplay('cri_chance'))
        vars['atk_spd_label']:setString(status_calc:getFinalStatDisplay('aspd'))
        vars['atk_label']:setString(status_calc:getFinalStatDisplay('atk'))
        vars['def_label']:setString(status_calc:getFinalStatDisplay('def'))
        vars['hp_label']:setString(status_calc:getFinalStatDisplay('hp'))
    end

    do -- 스킬 아이콘 생성
        vars['cp_label']:setString(comma_value(t_dragon_data:getCombatPower()))

        -- 스킬 상세정보 팝업
        local function func_skill_detail_btn()
            UI_SkillDetailPopup(t_dragon_data)
        end

        local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
        local l_skill_icon = skill_mgr:getDragonSkillIconList()
        for i=0, MAX_DRAGON_EVOLUTION do
            if l_skill_icon[i] then
                vars['skillNode' .. i]:removeAllChildren()
                vars['skillNode' .. i]:addChild(l_skill_icon[i].root)

                --[[
                -- 스킬 레벨 출력
                local skill_lv = skill_mgr:getSkillLevel(i)
                vars['skllLvLabel' .. i]:setString(tostring(skill_lv))
                -]]

                l_skill_icon[i].vars['clickBtn']:registerScriptTapHandler(func_skill_detail_btn)
            end
        end
    end
end

-------------------------------------
-- function setIdx
-------------------------------------
function UI_CollectionDetailPopup:setIdx(idx)
    if (self.m_currIdx == idx) then
        return
    end

    local min_idx = 1
    local max_idx = table.count(self.m_lDragonsItem)
    local idx = math_clamp(idx, min_idx, max_idx)
    self.m_currIdx = idx

    self:onChangeDragon()

    do -- 이전 버튼, 다음 버튼 활성화 여부
        local vars = self.vars

        -- prevBtn
        vars['prevBtn']:setVisible(min_idx < self.m_currIdx)

        -- nextBtn
        vars['nextBtn']:setVisible(self.m_currIdx < max_idx)
    end
end

-------------------------------------
-- function getCurrDragonTable
-------------------------------------
function UI_CollectionDetailPopup:getCurrDragonTable()
    local idx = self.m_currIdx

    if (not idx) then
        return nil
    end

    local item = self.m_lDragonsItem[idx]
    local t_dragon = item['data']
    return t_dragon
end

-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_CollectionDetailPopup:click_prevBtn()
    self:setIdx(self.m_currIdx - 1)
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_CollectionDetailPopup:click_nextBtn()
    self:setIdx(self.m_currIdx + 1)
end

-------------------------------------
-- function getEvolutionNumber
-------------------------------------
function UI_CollectionDetailPopup:getEvolutionNumber()
    local evolution_str = self.m_currTab
    local evolution = 1
    if (evolution_str == 'hatch') then
        evolution = 1
    elseif (evolution_str == 'hatchling') then
        evolution = 2
    elseif (evolution_str == 'adult') then
        evolution = 3
    end

    return evolution
end

-------------------------------------
-- function click_detailBtn
-- @brief 드래곤 상세 보기 팝업
-------------------------------------
function UI_CollectionDetailPopup:click_detailBtn()
    self.vars['detailNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_drawBtn
-- @brief 인연포인트 뽑기 버튼
-------------------------------------
function UI_CollectionDetailPopup:click_drawBtn()
    local t_dragon = self:getCurrDragonTable()

    local did = t_dragon['did']

    -- 인연포인트 값 얻어오기
    local req_rpoint = TableDragon():getRelationPoint(did)
    local cur_rpoint = g_collectionData:getRelationPoint(did)

    if (cur_rpoint < req_rpoint) then
        UIManager:toastNotificationRed(Str('인연포인트가 부족합니다.'))
    else
        local ui = UI_CollectionRelationPointDraw(did)

        local function close_cb()
            self:checkRefresh()
        end

        ui:setCloseCB(close_cb)
    end
end

-------------------------------------
-- function makeDragonData
-------------------------------------
function UI_CollectionDetailPopup:makeDragonData()
    local t_dragon = self:getCurrDragonTable()
    if (not t_dragon) then
        return nil
    end

    local grade = self:getEvolutionNumber()

    local t_dragon_data = {}
    t_dragon_data['did'] = t_dragon['did']
    t_dragon_data['lv'] = TableGradeInfo:getMaxLv(grade)
    t_dragon_data['evolution'] = self:getEvolutionNumber()
    t_dragon_data['grade'] = 6
    t_dragon_data['eclv'] = 0
    t_dragon_data['exp'] = 0
    t_dragon_data['skill_0'] = 1
    t_dragon_data['skill_1'] = 1
    t_dragon_data['skill_2'] = (t_dragon_data['evolution'] >= 2) and 1 or 0
    t_dragon_data['skill_3'] = (t_dragon_data['evolution'] >= 3) and 1 or 0
    
    return StructDragonObject(t_dragon_data)
end

-------------------------------------
-- function checkRefresh
-- @brief
-------------------------------------
function UI_CollectionDetailPopup:checkRefresh()
    local is_changed = g_collectionData:checkChange(self.m_collectionLastChangeTime)

    if is_changed then
        self.m_collectionLastChangeTime = g_collectionData:getLastChangeTimeStamp()
        self:onChangeDragon()
    end
end

--@CHECK
UI:checkCompileError(UI_CollectionDetailPopup)
