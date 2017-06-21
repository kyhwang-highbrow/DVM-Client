local PARENT = UI

-------------------------------------
-- class UI_BookDetailPopup
-------------------------------------
UI_BookDetailPopup = class(PARENT,{
		m_dragonEvolutionIconList = 'table',
        -- refresh 체크 용도
        m_collectionLastChangeTime = 'timestamp',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BookDetailPopup:init(t_dragon, t_data)
    local vars = self:load('collection_detail_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BookDetailPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:sceneFadeInAction()

    self.m_collectionLastChangeTime = g_bookData:getLastChangeTimeStamp()

    self:initUI()
    self:initButton()
    self:refresh(t_dragon, t_data)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BookDetailPopup:initUI(init_evolution)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BookDetailPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)

    -- 능력치 상세보기
    vars['detailBtn']:registerScriptTapHandler(function() self:click_detailBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BookDetailPopup:refresh(t_dragon, t_data)
	self:onChangeDragon(t_dragon, t_data)
	self:onChangeEvolution(t_dragon, t_data)
end

-------------------------------------
-- function onChangeDragon
-------------------------------------
function UI_BookDetailPopup:onChangeDragon(t_dragon, t_data)
    local t_dragon = t_dragon
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
end

-------------------------------------
-- function onChangeEvolution
-------------------------------------
function UI_BookDetailPopup:onChangeEvolution(t_dragon, t_data)
    local t_dragon = t_dragon
    if (not t_dragon) then
        return
    end

    local vars = self.vars
    local t_dragon_data = self:makeDragonData(t_dragon, t_data)

    do -- 선택된 드래곤 진화단계 아이콘 하일라이트 표시
        local evolution = t_data['evolution']
        for i,v in pairs(self.m_dragonEvolutionIconList) do
            local visible = (i == evolution)
            v:setHighlightSpriteVisible(visible)
        end
    end

    do -- 드래곤 인게임 리소스
        local evolution = t_data['evolution']
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['dragonNode']:removeAllChildren()
        vars['dragonNode']:addChild(animator.m_node)

		-- 자코 추가 이후 리소스별 크기가 다른 문제가 있어 테이블에서 스케일을 참조하도록 함(인게임 스케일 사용)
		-- 다만 0.9 ~ 1.5 사이값으로 제한 (mskim)
		vars['dragonNode']:setScale(math_clamp(t_dragon['scale'], 0.9, 1.5))
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

        local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
        local l_skill_icon = skill_mgr:getDragonSkillIconList()

        for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
            if l_skill_icon[i] then
                vars['skillNode' .. i]:removeAllChildren()
                vars['skillNode' .. i]:addChild(l_skill_icon[i].root)

                l_skill_icon[i].vars['clickBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
                l_skill_icon[i].vars['clickBtn']:registerScriptTapHandler(function()
					UI_SkillDetailPopup(t_dragon_data, i)
				end)

            end
        end
    end
end

-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_BookDetailPopup:click_prevBtn()
    self:setIdx(self.m_currIdx - 1)
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_BookDetailPopup:click_nextBtn()
    self:setIdx(self.m_currIdx + 1)
end

-------------------------------------
-- function click_detailBtn
-- @brief 드래곤 상세 보기 팝업
-------------------------------------
function UI_BookDetailPopup:click_detailBtn()
    self.vars['detailNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function makeDragonData
-------------------------------------
function UI_BookDetailPopup:makeDragonData(t_dragon, t_data)
    local t_dragon = t_dragon
    if (not t_dragon) then
        return nil
    end

    local grade = t_data['grade']

    local t_dragon_data = {}
    t_dragon_data['did'] = t_dragon['did']
    t_dragon_data['lv'] = 1 --TableGradeInfo:getMaxLv(grade)
    t_dragon_data['evolution'] = t_data['evolution']
    t_dragon_data['grade'] = grade
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
function UI_BookDetailPopup:checkRefresh()
    local is_changed = g_bookData:checkChange(self.m_collectionLastChangeTime)

    if is_changed then
        self.m_collectionLastChangeTime = g_bookData:getLastChangeTimeStamp()
        self:onChangeDragon()
    end
end

--@CHECK
UI:checkCompileError(UI_BookDetailPopup)
