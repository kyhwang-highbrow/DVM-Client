local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonEvolution
-------------------------------------
UI_DragonEvolution = class(PARENT,{
        m_bEnoughSvolutionStones = 'boolean',

        m_itemID1 = '',
        m_itemID2 = '',
        m_itemID3 = '',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonEvolution:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonEvolution'
    self.m_bVisible = true or false
    self.m_titleStr = Str('진화') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonEvolution:init(doid)
    local vars = self:load('dragon_evolution.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonEvolution')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonEvolution:initUI()
    local vars = self.vars
    self:init_dragonTableView()

    local l_pos = getSortPosList(30, 3)

    local uic_stats = UIC_IndivisualStats()
    uic_stats:initUIComponent()
    uic_stats:setPositionY(l_pos[1])
    uic_stats:setParentNode(vars['statsNode'])
    uic_stats:setStatsName(Str('공격력'))
    vars['atkStats'] = uic_stats

    local uic_stats = UIC_IndivisualStats()
    uic_stats:initUIComponent()
    uic_stats:setPositionY(l_pos[2])
    uic_stats:setParentNode(vars['statsNode'])
    uic_stats:setStatsName(Str('방어력'))
    vars['defStats'] = uic_stats

    local uic_stats = UIC_IndivisualStats()
    uic_stats:initUIComponent()
    uic_stats:setPositionY(l_pos[3])
    uic_stats:setParentNode(vars['statsNode'])
    uic_stats:setStatsName(Str('생명력'))
    vars['hpStats'] = uic_stats
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonEvolution:initButton()
    local vars = self.vars
    vars['evolutionBtn']:registerScriptTapHandler(function() self:click_evolutionBtn() end)
    vars['combineBtn']:registerScriptTapHandler(function() self:click_combineBtn() end)

    vars['moveBtn1']:registerScriptTapHandler(function() self:click_evolutionStone(1) end)
    vars['moveBtn2']:registerScriptTapHandler(function() self:click_evolutionStone(2) end)
    vars['moveBtn3']:registerScriptTapHandler(function() self:click_evolutionStone(3) end)
end

-------------------------------------
-- function refresh
-- @brief 선택된 드래곤이 변경되거나 갱신되었을 때 호출
-------------------------------------
function UI_DragonEvolution:refresh()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    -- 최대 진화도인지 여부
    local is_max_evolution = (t_dragon_data['evolution'] >= MAX_DRAGON_EVOLUTION)

    if is_max_evolution then
        UIManager:toastNotificationGreen(Str('최대 진화단계의 드래곤입니다.'))
    end

    -- 배경
    local attr = t_dragon['attr']
    if self:checkVarsKey('bgNode', attr) then    
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    -- 왼쪽 정보(현재 진화 단계)
    self:refresh_currDragonInfo(t_dragon_data, t_dragon)

    -- 가운데 정보(다음 진화 단계)
    self:refresh_nextDragonInfo(t_dragon_data, t_dragon, is_max_evolution)

    -- 오른쪽 정보(스킬)
    self:refresh_nextSkillInfo(t_dragon_data, t_dragon, is_max_evolution)

    -- 진화 재료
    self:refresh_evolutionStones(t_dragon_data, t_dragon, is_max_evolution)

    -- 진화하기 버튼 갱싱
    self:refresh_evolutionButton(t_dragon_data, t_dragon, is_max_evolution)

    -- 능력치
    self:refresh_stats(t_dragon_data, t_dragon, is_max_evolution)
end

-------------------------------------
-- function refresh_stats
-- @brief 능력치
-------------------------------------
function UI_DragonEvolution:refresh_stats(t_dragon_data, t_dragon, is_max_evolution)
    local vars = self.vars
    local doid = t_dragon_data['id']

    -- 현재 레벨의 능력치 계산기
    local status_calc = MakeOwnDragonStatusCalculator(doid)

    -- 현재 레벨의 능력치
    local curr_atk = status_calc:getFinalStat('atk')
    local curr_def = status_calc:getFinalStat('def')
    local curr_hp = status_calc:getFinalStat('hp')
    local curr_cp = status_calc:getCombatPower()

    vars['atkStats']:setBeforeStats(curr_atk)
    vars['defStats']:setBeforeStats(curr_def)
    vars['hpStats']:setBeforeStats(curr_hp)

    -- 변경된 레벨의 능력치 계산기
    local chaged_dragon_data = {}
    local evolution = t_dragon_data['evolution']
    chaged_dragon_data['evolution'] = math_min((evolution + 1), MAX_DRAGON_EVOLUTION)
    local changed_status_calc = MakeOwnDragonStatusCalculator(doid, chaged_dragon_data)

    -- 변경된 레벨의 능력치
    local changed_atk = changed_status_calc:getFinalStat('atk')
    local changed_def = changed_status_calc:getFinalStat('def')
    local changed_hp = changed_status_calc:getFinalStat('hp')
    local changed_cp = changed_status_calc:getCombatPower()

    vars['atkStats']:setAfterStats(changed_atk)
    vars['defStats']:setAfterStats(changed_def)
    vars['hpStats']:setAfterStats(changed_hp)
end

-------------------------------------
-- function refresh_currDragonInfo
-- @brief 왼쪽 정보(현재 진화 단계)
-------------------------------------
function UI_DragonEvolution:refresh_currDragonInfo(t_dragon_data, t_dragon)
    local vars = self.vars

    -- 드래곤 이름
    vars['dragonNameLabel']:setString(t_dragon_data:getDragonNameWithEclv())

    do -- 드래곤 속성
        local attr = t_dragon_data:getAttr()
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)

        -- 여기선 attrLabel이 없음
        --vars['attrLabel']:setString(dragonAttributeName(attr))
    end

    do -- 드래곤 역할(role)
        local role_type = t_dragon_data:getRole()
        -- 여기선 typeNode가 없음
        --vars['typeNode']:removeAllChildren()
        --local icon = IconHelper:getRoleIcon(role_type)
        --vars['typeNode']:addChild(icon)

        vars['typeLabel']:setString(dragonRoleName(role_type))
    end

    do -- 드래곤 리소스
        local evolution = t_dragon_data['evolution']
        vars['dragonBeforeNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:changeAni('idle', true)
        --animator:setAnimationPause(true)

        vars['dragonBeforeNode']:addChild(animator.m_node)
    end

    do -- 드래곤 아이콘
        vars['dragonNode']:removeAllChildren()
        local ui = UI_DragonCard(t_dragon_data)
        vars['dragonNode']:addChild(ui.root)
    end
end

-------------------------------------
-- function refresh_nextDragonInfo
-------------------------------------
function UI_DragonEvolution:refresh_nextDragonInfo(t_dragon_data, t_dragon, is_max_evolution)
    local vars = self.vars

    -- 진화도 (해치, 해츨링, 성룡)
    local evolution = t_dragon_data['evolution'] + 1
    local evolution_name = evolutionName(evolution)
    vars['evolutionLabel']:setString(evolution_name)

    do -- 드래곤 리소스
        local evolution = t_dragon_data['evolution'] + 1
        vars['dragonAfterNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:changeAni('pose_1', false)
        animator:addAniHandler(function() animator:changeAni('idle', true) end)
        vars['dragonAfterNode']:addChild(animator.m_node)
    end
end

-------------------------------------
-- function refresh_nextSkillInfo
-- @brief 오른쪽 정보(스킬)
-------------------------------------
function UI_DragonEvolution:refresh_nextSkillInfo(t_dragon_data, t_dragon, is_max_evolution)
    local vars = self.vars

    vars['skillNode']:removeAllChildren()
    vars['skillNameLabel']:setString('')
    vars['skillTypeLabel']:setString('')
    vars['skillInfoLabel']:setString('')

    if is_max_evolution then
        return        
    end

    local evolution = t_dragon_data['evolution'] + 1
    local skill_id = t_dragon['skill_' .. evolution]
    local skill_type = TableDragonSkill():getSkillType(skill_id)
    local skill_lv = 1

    if (skill_id == '') then
        vars['skillInfoLabel']:setString('스킬이 지정되지 않았습니다.')
    else
        local skill_individual_info = DragonSkillIndivisualInfo('dragon', skill_type, skill_id, skill_lv)
        skill_individual_info:applySkillLevel()
        skill_individual_info:applySkillDesc()

        -- 스킬 아이콘
        local spr = IconHelper:getSkillIcon('dragon', skill_id)
        vars['skillNode']:addChild(spr)

        -- 스킬 이름
        local str = skill_individual_info:getSkillName()
        vars['skillNameLabel']:setString(str)

        -- 스킬 타입
        local str = skill_individual_info:getSkillType()
        vars['skillTypeLabel']:setString(str)

        -- 스킬 설명
        local str = skill_individual_info:getSkillDesc()
        vars['skillInfoLabel']:setString(str)

        -- 스킬 타입
        local str = getSkillType_byEvolution(evolution)
        vars['skillTypeLabel']:setString(str)
    end


    cca.uiReactionSlow(vars['skillInfoNode'])
end

-------------------------------------
-- function refresh_evolutionStones
-- @brief 진화재료
-------------------------------------
function UI_DragonEvolution:refresh_evolutionStones(t_dragon_data, t_dragon, is_max_evolution)
    local vars = self.vars

    local did = t_dragon['did']

    local table_dragon_evolution = TABLE:get('dragon_evolution')
    local t_dragon_evolution = table_dragon_evolution[did]

    if (not t_dragon_evolution) then
        error('table_dragon_evolution.csv error did : ' .. did)
    end
    
    if is_max_evolution then
        for i=1,3 do
            vars['plusSprite' .. i]:setVisible(false) -- ??
            vars['moveBtn' .. i]:setVisible(false)
            vars['numberLabel' .. i]:setString('')
            vars['materialLabel' .. i]:setString('')
            vars['materialItemNode' .. i]:removeAllChildren()
        end
        return
    end

    -- 진화 단계에 따른 문자열
    local evolution = t_dragon_data['evolution'] + 1
    local evolution_str = ''
    if (evolution == 2) then
        evolution_str = 'hatchling'
    elseif (evolution == 3) then
        evolution_str = 'adult'
    else
        error('evolution : ' .. evolution)
    end

    -- 진화 재료 1~3개 셋팅
    local table_item = TableItem()
    self.m_bEnoughSvolutionStones = true
    for i=1,3 do
        vars['moveBtn' .. i]:setVisible(true)

        local item_id = t_dragon_evolution[evolution_str .. '_item' .. i]
        local item_value = t_dragon_evolution[evolution_str .. '_value' .. i]

        self['m_itemID' .. i] = item_id

        do -- 진화재료 이름
            local name = Str(table_item:getValue(item_id, 't_name'))
            vars['materialLabel' .. i]:setString(name)
        end

        do -- 진화재료 아이콘
            vars['materialItemNode' .. i]:removeAllChildren()
            local item_icon = IconHelper:getItemIcon(item_id)
            vars['materialItemNode' .. i]:addChild(item_icon)
        end
        
        do -- 갯수 체크
            local req_count = item_value
            local own_count = g_userData:get('evolution_stones', tostring(item_id)) or 0
            local str = Str('{1} / {2}', own_count, req_count)

            if (req_count <= own_count) then
                str = '{@possible}' .. str
            else
                str = '{@impossible}' .. str
                self.m_bEnoughSvolutionStones = false
            end

            vars['numberLabel' .. i]:setString(str)
        end
    end
end

-------------------------------------
-- function refresh_evolutionButton
-- @brief 진화하기 버튼 갱신
-------------------------------------
function UI_DragonEvolution:refresh_evolutionButton(t_dragon_data, t_dragon, is_max_evolution)
    local vars = self.vars
    local did = t_dragon['did']
    local doid = self.m_selectDragonOID
    local evolution = t_dragon_data:getEvolution()

    -- 진화 불가한 경우
    local possible, msg = g_dragonsData:possibleDragonEvolution(doid)
    if (not possible) then
        local birth_grade = TableDragon:getValue(did, 'birthgrade')
        local need_grade = (evolution == 1) and birth_grade or birth_grade + 1
         
        vars['dragonLockSprite']:setVisible(true)
        vars['conditionLabel']:setString(Str('진화 조건 - {1}성 승급', need_grade))
        return
    else
        vars['dragonLockSprite']:setVisible(false)
        vars['conditionLabel']:setString('')
    end

    local table_dragon_evolution = TABLE:get('dragon_evolution')
    local t_dragon_evolution = table_dragon_evolution[did]

    -- 진화 단계에 따른 문자열
    evolution = evolution + 1
    local evolution_str = ''
    if (evolution == 2) then
        evolution_str = 'hatchling'
    elseif (evolution == 3) then
        evolution_str = 'adult'
    else
        error('evolution : ' .. evolution)
    end

    -- 가격 설정
    local price = t_dragon_evolution[evolution_str .. '_gold']
    vars['priceLabel']:setString(comma_value(price))
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonEvolution:getDragonList()
    local dragon_dic = g_dragonsData:getDragonListWithSlime()

    -- 절대 진화 불가능한 드래곤 제외
    for oid, v in pairs(dragon_dic) do
        if (g_dragonsData:impossibleEvolutionForever(oid)) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function click_evolutionBtn
-------------------------------------
function UI_DragonEvolution:click_evolutionBtn()
    local doid = self.m_selectDragonOID
    
    -- 진화 조건 불충족
    local possible, msg = g_dragonsData:possibleDragonEvolution(doid)
    if (not possible) then
        UIManager:toastNotificationRed(msg)
        local vars = self.vars

        cca.uiImpossibleAction(vars['moveBtn1'])
        cca.uiImpossibleAction(vars['moveBtn2'])
        cca.uiImpossibleAction(vars['moveBtn3'])
        return
    end

    -- 진화 재료 부족
    if (not self.m_bEnoughSvolutionStones) then
        UIManager:toastNotificationRed(Str('진화재료가 부족합니다.'))
        local vars = self.vars

        cca.uiImpossibleAction(vars['moveBtn1'])
        cca.uiImpossibleAction(vars['moveBtn2'])
        cca.uiImpossibleAction(vars['moveBtn3'])
        return
    end

    local uid = g_userData:get('uid')
    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '드래곤 진화')
        Analytics:firstTimeExperience('DragonEvolution')
        if (ret['dragon']) and (ret['dragon']['evolution'] == 3) then
            Analytics:trackEvent(CUS_CATEGORY.GROWTH, CUS_EVENT.DRA_EV, 1, '성룡 진화')
        end

        -- 진화 재료 갱신
        if ret['evolution_stones'] then
            g_serverData:applyServerData(ret['evolution_stones'], 'user', 'evolution_stones')
        end

        -- 승급된 드래곤 갱신
        if ret['dragon'] then
            ret['dragon']['updated_at'] = Timer:getServerTime()
            g_dragonsData:applyDragonData(ret['dragon'])
        end

        -- 갱신
        g_serverData:networkCommonRespone(ret)

        self.m_bChangeDragonList = true

        -- 팝업 연출
        local ui = UI_DragonEvolutionResult(StructDragonObject(ret['dragon']))
		ui:setCloseCB(function()
			-- UI 종료한다. 진화후 남아있을 이유가 없음
			self:close()
		end)

        -- @ master road
        g_masterRoadData:addRawData('d_evup')
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/evolution')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function click_evolutionStone
-------------------------------------
function UI_DragonEvolution:click_evolutionStone(i)
    local item_id = self['m_itemID' .. i]
    UI_ItemInfoPopup(item_id)
end

-------------------------------------
-- function click_combineBtn
-------------------------------------
function UI_DragonEvolution:click_combineBtn(i)
    local function update_cb()
        self:refresh()
    end

    local ui = UI_EvolutionStoneCombine()
    ui:setCloseCB(update_cb)

end

--@CHECK
UI:checkCompileError(UI_DragonEvolution)
