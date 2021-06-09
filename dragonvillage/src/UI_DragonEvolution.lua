local PARENT = UI_DragonManage_Base

local T_EVOLUTION_PACKAGE_ID_TABLE = {
	['legend'] = {
		['earth'] = 90070,
		['water'] = 90071,
		['fire'] = 90072,
		['light'] = 90073,
		['dark'] = 90074,
	},
	['hero'] = {
		['earth'] = 90065,
		['water'] = 90066,
		['fire'] = 90067,
		['light'] = 90068,
		['dark'] = 90069,
	},
	['rare'] = {
		['earth'] = 90065,
		['water'] = 90066,
		['fire'] = 90067,
		['light'] = 90068,
		['dark'] = 90069,
	},
}

-------------------------------------
-- class UI_DragonEvolution
-------------------------------------
UI_DragonEvolution = class(PARENT,{
        m_bEnoughSvolutionStones = 'boolean',
		m_evolutionPackageStruct = 'StructProduct',

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

    -- 선택한 드래곤에 포커싱
    self:focusSelectedDragon(doid)
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


	vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
	cca.pickMePickMe(vars['buyBtn'], 10)


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

	-- 패키지 구매 유도
    -- 210609 : 해당 상품 삭제로 인해 안보이도록 임시 처리
    vars['buyBtn']:setVisible(false)
	--vars['buyBtn']:setVisible(self:isPackageBuyable())
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
    
    local attr = t_dragon_data:getAttr()
    local role_type = t_dragon_data:getRole()
    local rarity_type = nil
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)
    
    do -- 드래곤 속성
        local attr = t_dragon_data:getAttr()
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    end

    do -- 드래곤 역할(role)
        local role_type = t_dragon_data:getRole()
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
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
        vars['skillInfoLabel']:setString(Str('스킬이 지정되지 않았습니다.'))
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
        local str = getSkillTypeStr(skill_type)
        vars['skillTypeLabel']:setString(str)

        -- 스킬 설명
        local str = skill_individual_info:getSkillDesc()
        vars['skillInfoLabel']:setString(str)
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

        -- @adjust
        Adjust:trackEvent(Adjust.EVENT.DRAGON_ENVOLVE)

        -- 드래곤 성장일지 : 드래곤 진화 체크
        local start_dragon_data = g_dragonDiaryData:getStartDragonData(ret['dragon'])
        if (start_dragon_data) then
            -- @ DRAGON DIARY
            local t_data = {clear_key = 'd_evup_s', sub_data = start_dragon_data}
            g_dragonDiaryData:updateDragonDiary(t_data)
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

    local item_id = nil
    local dragon_data = self.m_selectDragonData

    local ui = UI_EvolutionStoneCombine(item_id, dragon_data)
    ui:setCloseCB(update_cb)
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_DragonEvolution:click_buyBtn()
	local struct_product = self.m_evolutionPackageStruct
	local ui = UI_Package(struct_product, true) -- is_popup

	-- @mskim 익명 함수를 사용하여 가독성을 높이는 경우라고 생각..!
	-- 구매 후 간이 우편함 출력
	-- 간이 우편함 닫을 때 패키지UI 닫고 진화UI 갱신
	ui:setBuyCB(function() 
		UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.EVOLUTION_PACK, function()
			ui:close()
			self:refresh()
		end)
	end)
end

-------------------------------------
-- function isPackageBuyable
-------------------------------------
function UI_DragonEvolution:isPackageBuyable()
	-- 진화석이 부족하지 않다면 패스
	if (self.m_bEnoughSvolutionStones) then
		return false
	end

    -- 드래곤 정보
	local struct_dragon_object = self.m_selectDragonData
    if (not struct_dragon_object) then
        return false
    end

	-- 2성 진화 가능한 드래곤 예외 처리..!
	local rarity = struct_dragon_object:getRarity()
	if (T_EVOLUTION_PACKAGE_ID_TABLE[rarity] == nil) then
		return false
	end
	
	-- pid 찾아서 StructProduct 찾아서 구매 가능 여부 확인
	local attr = struct_dragon_object:getAttr()
	local pid = T_EVOLUTION_PACKAGE_ID_TABLE[rarity][attr]
	local struct_product = g_shopDataNew:getProduct('package', pid)

	-- 구매할때 쓰기 위해서 따로 저장
	self.m_evolutionPackageStruct = struct_product

	return struct_product:checkMaxBuyCount()
end

-------------------------------------
-- function checkSelectedDragonCondition
-------------------------------------
function UI_DragonEvolution:checkSelectedDragonCondition(dragon_object)
    if (not dragon_object) then
        return false
    end
    -- StructSlimeObject는 soid (== id)
    -- StructDragonObject는 doid (== id)
    -- 두 클래스 모두 id에 값을 저장하고 있다
    local doid = dragon_object['id']
    local object_type = dragon_object:getObjectType()
    local upgradeable, msg = g_dragonsData:impossibleEvolutionForever(doid)
    if (upgradeable) then
        UIManager:toastNotificationRed(msg)
        return false
    end
    return true
end

--@CHECK
UI:checkCompileError(UI_DragonEvolution)
