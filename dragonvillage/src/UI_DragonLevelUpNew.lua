local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonLevelUpNew
-------------------------------------
UI_DragonLevelUpNew = class(PARENT,{
        m_dragonLevelUpBtnPress = 'UI_DragonLevelUpBtnPress', -- 드래곤 레벨업 버튼을 꾹 눌러 연속으로 레벨업을 처리하는 핼퍼 클래스
        m_dragonAnimator = 'animator',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonLevelUpNew:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonLevelUpNew'
    self.m_bVisible = true or false
    self.m_titleStr = Str('드래곤 레벨업')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLevelUpNew:init(doid)
    local vars = self:load('dragon_levelup_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonLevelUpNew')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()

    -- 드래곤 레벨업 버튼을 꾹 눌러 연속으로 레벨업을 처리하는 핼퍼 클래스 
    require('UI_DragonLevelUpBtnPress')
    self.m_dragonLevelUpBtnPress = UI_DragonLevelUpBtnPress(self)

    -- 첫 선택 드래곤 지정 & refresh
    self:setDefaultSelectDragon(doid)

    -- 정렬 도우미
    self:init_dragonSortMgr() -- 하단 드래곤 리스트 정렬

    -- 선택한 드래곤에 포커싱
    self:focusSelectedDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLevelUpNew:initUI()
    local vars = self.vars
    self:init_dragonTableView() -- 하단 드래곤 리스트 생성
    self:initStatusUI() -- 드래곤 스탯 관련 UI 생성

	-- 레벨업 이펙트
	 vars['levelupVisual']:setVisible(false) -- 일단 꺼놓고, 나중에 이펙트 그릴 때 킴
	 vars['levelupVisual']:setIgnoreLowEndMode(true) -- 저사양 모드에서도 표현되어야 함
end

-------------------------------------
-- function initStatusUI
-- @brief 드래곤 스탯 관련 UI 생성
-------------------------------------
function UI_DragonLevelUpNew:initStatusUI()
    local vars = self.vars
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
function UI_DragonLevelUpNew:initButton()
    local vars = self.vars
    vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)
    vars['levelupBtn']:registerScriptPressHandler(function() self.m_dragonLevelUpBtnPress:dragonLevelUpBtnPressHandler(vars['levelupBtn']) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLevelUpNew:refresh()
    -- 선택된 드래곤 정보 갱신
    self:refresh_dragonInfo()
    self:refresh_dragonStat()
    self:refresh_levelUpBtnState()
end

-------------------------------------
-- function refresh_dragonInfo
-- @brief 선택된 드래곤 정보 갱신
-------------------------------------
function UI_DragonLevelUpNew:refresh_dragonInfo()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    local did = t_dragon_data['did']

    local attr = t_dragon_data:getAttr()
    local role_type = t_dragon_data:getRole()
    local rarity_type = nil
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    -- 배경
    if self:checkVarsKey('bgNode', attr) then    
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    do -- 드래곤 현재 정보 카드
        vars['dragonIconNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(t_dragon_data)
        vars['dragonIconNode']:addChild(dragon_card.root)
        vars['dragonIcon'] = dragon_card
    end

    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(t_dragon_data:getDragonNameWithEclv())
    end

    do -- 드래곤 속성
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'])
    end

    do -- 드래곤 역할(role)
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'])
    end

	do -- 드래곤 리소스
        local evolution = t_dragon_data['evolution']
        vars['dragonNode']:removeAllChildren()

        local dragon_res = t_dragon['res']
        local dragon_attr = t_dragon['attr']

        if t_dragon_data['dragon_skin'] ~= nil and t_dragon_data['dragon_skin'] ~= 0 then
            local skin_id = t_dragon_data['dragon_skin']
            dragon_res = TableDragonSkin:getDragonSkinValue('res', skin_id)
            dragon_attr = TableDragonSkin:getDragonSkinValue('attribute', skin_id)
        end
        
        
        local animator = AnimatorHelper:makeDragonAnimator(dragon_res, evolution, dragon_attr)
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:changeAni('idle', true)
		animator:setMix('idle', 'pose_1', 0) -- 레벨업 모션이 좀 더 눈에 띄도록 
		animator:setMix('pose_1', 'idle', 0)
		self.m_dragonAnimator = animator

        vars['dragonNode']:addChild(animator.m_node)
    end
end

-------------------------------------
-- function refresh_levelUpBtnState
-- @brief 레벨업 버튼 상태 갱신
-------------------------------------
function UI_DragonLevelUpNew:refresh_levelUpBtnState(curr_lv, curr_exp, dragon_exp)
    local vars = self.vars
    
    local t_dragon_data = self.m_selectDragonData
    local curr_lv = (curr_lv or t_dragon_data['lv'])
    local curr_exp = (curr_exp or t_dragon_data['exp'])
    local grade = t_dragon_data['grade']
    local max_level = TableGradeInfo():getValue(grade, 'max_lv')
    local dragon_exp = (dragon_exp or g_userData:get('dragon_exp'))


    vars['levelupBtn']:setVisible(false)
    vars['dragonExpNode']:setVisible(false)
    vars['lockSprite']:setVisible(false)

    -- 최대레벨이 아닐 경우
    if (curr_lv < max_level) then
        vars['dragonExpNode']:setVisible(true)
        vars['levelupBtn']:setVisible(true)

        -- 필요 골드, 경험치 계산
        local table_dragon_exp = TableDragonExp()
        local is_myth_dragon = t_dragon_data:getRarity() == 'myth'
        local total_gold, total_dragon_exp = table_dragon_exp:getGoldAndDragonEXPForDragonLevelUp(grade, curr_lv, curr_lv + 1, is_myth_dragon)

        -- 필요 골드
        local need_gold = total_gold
        vars['priceLabel']:setString(comma_value(need_gold))

        -- 필요 경험치
        local need_dragon_exp = (total_dragon_exp - curr_exp)
        local str = ''
        if (need_dragon_exp <= dragon_exp) then
            str = Str('{1}/{2}', comma_value(dragon_exp), comma_value(need_dragon_exp))
        else
            str = Str('{@impossible}{1}{@}/{2}', comma_value(dragon_exp), comma_value(need_dragon_exp))
        end
		vars['dragonExpLabel']:setString(str)
        
        local l_ui_list = {vars['dragonExpIcon'], vars['dragonExpLabel']}
        AlignUIPos(l_ui_list, 'HORIZONTAL', 'CENTER', 0) -- ui list, direction, align, offset
        --self:alignDragonExpLabel() -- 드래곤 경험치 아이콘과 라벨 정렬
        

    -- 최대레벨이고 승급이 가능할 경우
    elseif (grade < MAX_DRAGON_GRADE) then
        vars['lockSprite']:setVisible(true)
        vars['infoLabel2']:setString(Str('{1}성 승급시 레벨업 할 수 있어요', grade + 1))

    -- 최대레벨이고 승급이 불가능할 경우
    else

    end
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 드래곤 정보 (우상단 아이콘에 레벨 변경)
-------------------------------------
function UI_DragonLevelUpNew:refresh_dragonCard(dragon_level)
    local vars = self.vars

    -- UI_CharacterCard, UI_Card
    if vars['dragonIcon'] then
	    vars['dragonIcon']:setNumberText(dragon_level, false) -- num, use_plus
    end

    -- 하단에 드래곤 아이콘에 레벨 숫자 갱신
    local ui_character_card = self:getDragonListItem() -- UI_CharacterCard(UI_Card)
    if ui_character_card then
        ui_character_card:setNumberText(dragon_level, false) -- num, use_plus
    end
end

-------------------------------------
-- function refresh_dragonStat
-- @brief 드래곤 레벨업에 따른 스탯
-------------------------------------
function UI_DragonLevelUpNew:refresh_dragonStat(dragon_level)
	local vars = self.vars

    local t_dragon_data = self.m_selectDragonData
    local dragon_level = (dragon_level or t_dragon_data['lv'])
    local grade = t_dragon_data['grade']
    local max_level = TableGradeInfo():getValue(grade, 'max_lv')
	local next_level = math_min(dragon_level + 1, max_level)
    

    -- 능력치 정보 갱신
    self:refresh_stats(t_dragon_data, dragon_level, next_level)
    self:refresh_dragonCard(dragon_level)
end

-------------------------------------
-- function alignDragonExpLabel
-- @brief 드래곤 경험치 아이템아이콘, 필요 수량 라벨 정렬
-------------------------------------
function UI_DragonLevelUpNew:alignDragonExpLabel()
    local vars = self.vars

    if (vars['dragonExpIcon'] == nil) then
        return
    end

    if (vars['dragonExpLabel'] == nil) then
        return
    end

    local interval_x = 0
    
    -- 드래곤 경험치 아이콘 넓이 계산
    local dragon_exp_icon_width = 0
    do
        local content_size = vars['dragonExpIcon']:getContentSize()
        local scale_x = vars['dragonExpIcon']:getScaleX()
        dragon_exp_icon_width = (content_size['width'] * scale_x)
    end

    -- 드래곤 경험치 라벨 넓이 계산
    local dragon_exp_label_width = 0
    do
        local string_width = vars['dragonExpLabel']:getStringWidth()
        local scale_x = vars['dragonExpLabel']:getScaleX()
        dragon_exp_label_width = (string_width * scale_x)
    end

    -- 총 넓이, 시작 x위치 계산
    local total_width = dragon_exp_icon_width + interval_x + dragon_exp_label_width
    local left_x = -(total_width / 2)

    -- node 위치 조정
    vars['dragonExpIcon']:setPositionX(left_x + (dragon_exp_icon_width/2))
    vars['dragonExpLabel']:setPositionX(left_x + dragon_exp_icon_width + interval_x + (dragon_exp_label_width/2))
end


-------------------------------------
-- function refresh_stats
-- @brief 능력치 전, 후 보여줌
-------------------------------------
function UI_DragonLevelUpNew:refresh_stats(t_dragon_data, curr_level, next_level)
    local vars = self.vars
    local doid = t_dragon_data['id']
    
	-- 현재 레벨의 능력치 계산기
	local curr_dragon_data = {}
	curr_dragon_data['lv'] = curr_level
    local status_calc = MakeOwnDragonStatusCalculator(doid, curr_dragon_data)

    -- 현재 레벨의 능력치
    local curr_atk = status_calc:getFinalStat('atk')
    local curr_def = status_calc:getFinalStat('def')
    local curr_hp = status_calc:getFinalStat('hp')
    -- local curr_cp = status_calc:getCombatPower()

    vars['atkStats']:setBeforeStats(curr_atk)
    vars['defStats']:setBeforeStats(curr_def)
    vars['hpStats']:setBeforeStats(curr_hp)

    -- 변경된 레벨의 능력치 계산기
    local chaged_dragon_data = {}
    chaged_dragon_data['lv'] = next_level
    local changed_status_calc = MakeOwnDragonStatusCalculator(doid, chaged_dragon_data)

    -- 변경된 레벨의 능력치
    local changed_atk = changed_status_calc:getFinalStat('atk')
    local changed_def = changed_status_calc:getFinalStat('def')
    local changed_hp = changed_status_calc:getFinalStat('hp')
    -- local changed_cp = changed_status_calc:getCombatPower()

    vars['atkStats']:setAfterStats(changed_atk)
    vars['defStats']:setAfterStats(changed_def)
    vars['hpStats']:setAfterStats(changed_hp)
end

-------------------------------------
-- function setDefaultSelectDragon
-- @brief 지정된 드래곤이 없을 경우 기본 드래곤을 설정
-------------------------------------
function UI_DragonLevelUpNew:setDefaultSelectDragon(doid)
	-- 레벨업 마스터의 길 ... 불속성 슬라임이니 불속성 공격형 드래곤을 선택하도록 한다
	if (g_masterRoadData:getFocusRoad() == 10010) then
		local profer_doid = nil

		for i, t_item in pairs(self.m_tableViewExt.m_itemList) do
			local data = t_item['data']
			-- 불속성 공격형
			if (data:getAttr() == T_ATTR_LIST[ATTR_FIRE]) and (data:getRole() == 'dealer') then
				profer_doid = data['id']
				self.m_selectDragonOID = profer_doid
				local b_force = true
				self:setSelectDragonData(profer_doid, b_force)
				break
			end
		end

		-- 불속성 드래곤이 없을린 없지만 없다면 기존 로직을 태움
		if (profer_doid) then
			return
		end
	end

    PARENT.setDefaultSelectDragon(self, doid)
end

-------------------------------------
-- function checkSelectedDragonCondition
-- @brief 선택된 드래곤이 조건이 가능한지 체크
-- @return boolean true면 선택이 가능
-------------------------------------
function UI_DragonLevelUpNew:checkSelectedDragonCondition(dragon_object)
    if (not dragon_object) then
        return false
    end

    if (dragon_object:getObjectType() ~= 'dragon') then
        local msg = Str('슬라임은 선택할 수 없습니다.')
        UIManager:toastNotificationRed(msg)
        return false
    end

     -- 최대 등급, 최대 레벨이 아닌 경우
     if (dragon_object:isMaxGradeAndLv()) then
        local msg = Str('최대 레벨에 도달한 드래곤입니다.')
        UIManager:toastNotificationRed(msg)
        return false
    end


    return true
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonLevelUpNew:getDragonList()
    local dragon_dic = g_dragonsData:getDragonListWithSlime()

    -- 절대 레벨업 불가능한 드래곤 제외
    for oid, v in pairs(dragon_dic) do
        if (g_dragonsData:impossibleLevelupForever(oid)) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function click_levelupBtn
-- @brief 1레벨씩 레벨업 시도
-------------------------------------
function UI_DragonLevelUpNew:click_levelupBtn()
    local doid = self.m_selectDragonOID
	local vars = self.vars

    -- 현재 레벨업 가능한 드래곤인지 검증
    local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)
    if (not possible) then
        UIManager:toastNotificationRed(msg)
        return
    end

    -- 필요 골드, 드래곤 경험치 계산
    local table_dragon_exp = TableDragonExp()
    local t_dragon_data = self.m_selectDragonData
    local grade = t_dragon_data['grade']
    local lv = t_dragon_data['lv']
    local target_lv = lv + 1
    local is_myth_dragon = t_dragon_data:getRarity() == 'myth'
    local total_gold, total_dragon_exp = table_dragon_exp:getGoldAndDragonEXPForDragonLevelUp(grade, lv, target_lv, is_myth_dragon)

    -- 골드가 충분히 있는지 확인
    local need_gold = total_gold
    if (not ConfirmPrice('gold', need_gold)) then -- 골드가 부족한경우 상점이동 유도 팝업이 뜬다. (ConfirmPrice함수 안에서)
		--UIManager:toastNotificationRed(Str('골드가 부족합니다'))
	    return
    end

	-- 경험치가 충분히 있는지 확인
    local exp = t_dragon_data['exp']
    local need_dragon_exp = (total_dragon_exp - exp)
    local dragon_exp = g_userData:get('dragon_exp')
	if (dragon_exp < need_dragon_exp) then
		UIManager:toastNotificationRed(Str('드래곤 경험치가 부족합니다'))
		return
	end

    self:request_levelUp(target_lv, need_gold, need_dragon_exp)
end

-------------------------------------
-- function request_levelUp
-- @brief 레벨업을 서버에 요청
-------------------------------------
function UI_DragonLevelUpNew:request_levelUp(target_lv, need_gold, need_dragon_exp, finish_cb)
	local uid = g_userData:get('uid')
	local doid = self.m_selectDragonData['id']
	local gold = g_userData:get('gold')
    local dragon_exp = g_userData:get('dragon_exp')
    local t_dragon_data = self.m_selectDragonData
    local lv = t_dragon_data['lv']
    local target_dragon_exp = (dragon_exp - need_dragon_exp)
    local target_gold = (gold - need_gold)

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/levelup_new')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
	ui_network:setParam('lv', lv)
	ui_network:setParam('dragon_exp', dragon_exp)
	ui_network:setParam('gold', gold)
	ui_network:setParam('target_lv', target_lv)
	ui_network:setParam('target_dragon_exp', target_dragon_exp)
	ui_network:setParam('target_gold', target_gold)
	--ui_network:hideLoading()
    ui_network:setRevocable(false) -- 데이터가 꼬이는 것을 방지하기 위해 다시 통신
    ui_network:setSuccessCB(function(ret) self:response_levelup(ret, finish_cb) end)
	ui_network:request()
end

-------------------------------------
-- function response_levelup
-- @brief
-------------------------------------
function UI_DragonLevelUpNew:response_levelup(ret, finish_cb)
    -- @analytics
    Analytics:trackUseGoodsWithRet(ret, '드래곤 레벨업')

    ---[[
    do -- 드래곤 성장일지
        local prev_lv = lv
		local curr_lv = ret['modified_dragon']['lv']

        if (prev_lv ~= curr_lv) then
            -- 드래곤 성장일지 : 드래곤 등급, 레벨 체크
            local start_dragon_data = g_dragonDiaryData:getStartDragonData(ret['modified_dragon'])
            if (start_dragon_data) then
                -- @ DRAGON DIARY
                local t_data = {clear_key = 'd_lv', sub_data = start_dragon_data}
                g_dragonDiaryData:updateDragonDiary(t_data)
            end
        end
    end
    --]]

    -- 골드, 드래곤 경험치 갱신
    g_serverData:networkCommonRespone(ret)

    -- 드래곤 정보 갱신
    g_dragonsData:applyDragonData(ret['modified_dragon'])
    self.m_bChangeDragonList = true
    self:setSelectDragonDataRefresh() -- 선택된 드래곤의 데이터를 최신으로 갱신

    -- 이펙트 재생
	self:playLevelUpEffect()

	self:refresh_dragonStat()
    self:refresh_levelUpBtnState()

    -- @ MASTER ROAD
    local t_data = {clear_key = 'd_lvup'}
    g_masterRoadData:updateMasterRoad(t_data)

    ---[[
    -- @ DRAGON DIARY
    local t_data = {clear_key = 'd_lvup', ret = ret}
    g_dragonDiaryData:updateDragonDiary(t_data)
    --]]

    if finish_cb then
        finish_cb()
    end
end

-------------------------------------
-- function playLevelUpEffect
-- @brief 레벨업 이펙트 및 사운드 재생
-- @param dragon_level number nill일 경우 선택된 드래곤의 레벨을 사용
-------------------------------------
function UI_DragonLevelUpNew:playLevelUpEffect(dragon_level, skip_ani)
	local vars = self.vars

    local t_dragon_data = self.m_selectDragonData
	local doid = t_dragon_data['id']
    local grade = t_dragon_data['grade']
	local dragon_level = (dragon_level or t_dragon_data['lv']) -- 파라미터 사용 (nil일 경우 선택된 드래곤의 레벨을 사용)
    local max_level = TableGradeInfo():getValue(grade, 'max_lv')
	local next_level = math_min(dragon_level, max_level)

	-- 현재 레벨의 능력치 계산기
	local curr_dragon_data = {}
	curr_dragon_data['lv'] = dragon_level - 1
    local status_calc = MakeOwnDragonStatusCalculator(doid, curr_dragon_data)

    -- 현재 레벨의 능력치 (모든 능력치는 유저에게 소수점 내림 상태로 보임)
    local curr_atk = math_floor(status_calc:getFinalStat('atk'))
    local curr_def = math_floor(status_calc:getFinalStat('def'))
    local curr_hp = math_floor(status_calc:getFinalStat('hp'))

    -- 변경된 레벨의 능력치 계산기
    local chaged_dragon_data = {}
    chaged_dragon_data['lv'] = next_level
    local changed_status_calc = MakeOwnDragonStatusCalculator(doid, chaged_dragon_data)

    -- 변경된 레벨의 능력치
    local changed_atk = math_floor(changed_status_calc:getFinalStat('atk'))
    local changed_def = math_floor(changed_status_calc:getFinalStat('def'))
    local changed_hp = math_floor(changed_status_calc:getFinalStat('hp'))

	local hp_changed = changed_hp - curr_hp
	local def_changed = changed_def - curr_def
	local atk_changed = changed_atk - curr_atk

	-- 실질적인 이펙트 호출
	self:playLevelUpEffect_(hp_changed, def_changed, atk_changed, skip_ani)
end

-------------------------------------
-- function playLevelUpEffect_
-- @brief 실질적으로 레벨업 이펙트 및 사운드 재생
-------------------------------------
function UI_DragonLevelUpNew:playLevelUpEffect_(hp_changed, def_changed, atk_changed, skip_ani)
	local vars = self.vars

	do -- 1. 드래곤 모션 재생
		local dragon_animator = self.m_dragonAnimator
		local visual_list = dragon_animator:getVisualList()
		local exist_pose_1 = table.find(visual_list, 'pose_1')
		local ani = 'pose_1'
		-- pose_1이 없으면 attack을 사용 (드래곤이 아닌 몬스터의 경우 pose_q이 없을 수 있다)
		if (exist_pose_1 == false) then
			ani = 'attack'
		end

        if (not skip_ani) then
		    dragon_animator:changeAni(ani, false)
        end

		 -- 모션 변화 느낌을 좀 더 주기 위해 배속
		local animation_time_scale = 1.6
		dragon_animator:setTimeScale(animation_time_scale)

		-- 애니메이션 끝나면 다시 속도 원상태로
		local function anihandler()
			dragon_animator:changeAni('idle', true) 
			dragon_animator:setTimeScale(1)
		end
		dragon_animator:addAniHandler(anihandler)
	end

	do -- 2. 레벨업 이펙트 연출
		local levelup_effect = vars['levelupVisual']
		levelup_effect:setVisible(true)
		levelup_effect:changeAni('levelup', false)
		levelup_effect:addAniHandler(function() levelup_effect:setVisible(false) end)
	end

	do -- 3. 레벨업에 따른 능력치 상승 텍스트 이펙트 연출 
		-- ex: 생명력 + 5
		local text_ui = UI()
		text_ui:load('dragon_levelup_stats.ui')
		text_ui.vars['statsLabel1']:setString(Str('생명력') .. '+' .. comma_value(hp_changed))
		text_ui.vars['statsLabel2']:setString(Str('방어력') .. '+' .. comma_value(def_changed))
		text_ui.vars['statsLabel3']:setString(Str('공격력') .. '+' .. comma_value(atk_changed))
		-- local delay = cc.DelayTime:create(0.05)
		local duration = 1
		local spawn = cc.EaseIn:create(cc.Spawn:create(cc.MoveBy:create(duration, cc.p(0, 150)), cc.FadeTo:create(duration, 0)), 1)
		local action = cc.Sequence:create(spawn, cc.RemoveSelf:create())
		text_ui.root:runAction(action)
		vars['textEffectNode']:addChild(text_ui.root)
	end

	do -- 4. 레벨업 사운드
		SoundMgr:playEffect('UI', 'ui_dragon_level_up')
	end
end

--@CHECK
UI:checkCompileError(UI_DragonLevelUpNew)