local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonLevelUpNew
-------------------------------------
UI_DragonLevelUpNew = class(PARENT,{
		m_oriGold = 'number', -- 레벨업 시작 전 플레이어의 골드
		m_oriExp = 'number', -- 레벨업 시작 전 플레이어의 경험치

		m_currDragonLevel = 'number', -- 현재 선택되어있는 드래곤의 현재 레벨
		m_targetDragonLevel = 'number', -- 현재 선택되어있는 드래곤의 목표 레벨

		m_needGoldSum = 'number', -- 필요한 골드 총합
		m_needExpSum = 'number', -- 필요한 드래곤 경험치 아이템 총합

		m_needGoldNext = 'number', -- 이번 단계에 필요한 골드
		m_needExpNext = 'number' -- 이번 단계에 필요한 경험치
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
	self:initLevelUpEffect() -- TODO : 레벨업 이펙트 
end

-------------------------------------
-- function initStatusUI
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
-- function initLevelUpEffect
-------------------------------------
function UI_DragonLevelUpNew:initLevelUpEffect()
	
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonLevelUpNew:initButton()
    local vars = self.vars
    vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)
	vars['levelupBtn']:registerScriptPressHandler(function() self:press_levelupBtn(vars['levelupBtn']) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLevelUpNew:refresh()
    self.m_currDragonLevel = self.m_selectDragonData['lv']
    self.m_targetDragonLevel = self.m_currDragonLevel
    self.m_needGoldSum = 0
    self.m_needExpSum = 0
	self.m_oriGold = g_userData:get('gold')
	self.m_oriExp = g_userData:get('dragon_exp')

	self:refresh_dragonInfo()
	self:refresh_dragonCard(self.m_currDragonLevel)
	self:refresh_dragonStat(self.m_currDragonLevel)
end


-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보
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
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:changeAni('idle', true)

        vars['dragonNode']:addChild(animator.m_node)
    end
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonLevelUpNew:refresh_dragonCard(dragon_level)
    local vars = self.vars
	local t_dragon_data = self.m_selectDragonData
	t_dragon_data['lv'] = dragon_level -- press의 경우 데이터와 보여줘야 하는 레벨이 다를 수 있음
    
	do -- 드래곤 현재 정보 카드
        vars['dragonIconNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(t_dragon_data)
        vars['dragonIconNode']:addChild(dragon_card.root)
    end
end

-------------------------------------
-- function refresh_dragonStat
-- @brief 드래곤 레벨업에 따른 스탯
-------------------------------------
function UI_DragonLevelUpNew:refresh_dragonStat(dragon_level)
	local vars = self.vars
    
    local t_dragon_data = self.m_selectDragonData
    local doid = t_dragon_data['id']
	local grade = t_dragon_data['grade']
    local curr_level = dragon_level
    local curr_exp = t_dragon_data['exp']
	local max_level = TableGradeInfo():getValue(grade, 'max_lv')
	local next_level = math_min(curr_level + 1, max_level)

	if (curr_level < max_level) then -- 만렙이 아닐 때
		local table_dragon_exp = TableDragonExp()
		local max_level_table = {}
		for i=1, max_level do
			local lv = i
			max_level_table[i] = table_dragon_exp:getDragonMaxExp(grade, lv)
		end
		local max_exp = max_level_table[curr_level] 

		-- 이번 레벨업에 소비되는 돈과 경험치 정보
		self.m_needGoldNext = table_dragon_exp:getGoldPerLevelUp(grade, curr_level)
		self.m_needExpNext = max_exp - curr_exp

		local curr_gold = g_userData:get('gold')
		local curr_exp = g_userData:get('dragon_exp')

        vars['priceLabel']:setString(comma_value(self.m_needGoldNext))
        do -- 드래곤 경험치
            local str = Str('{1} / {2}', comma_value(curr_exp), comma_value(self.m_needExpNext))
            if (self.m_needExpNext <= curr_exp) then
                str = '{@possible}' .. str
            else
                str = '{@impossible}' .. str
            end
		    vars['dragonExpLabel']:setString(str)
        end
        self:alignDragonExpLabel()

        vars['dragonExpNode']:setVisible(true)
        vars['levelupBtn']:setVisible(true)
        vars['lockSprite']:setVisible(false)
	else
        vars['dragonExpNode']:setVisible(false)
        vars['levelupBtn']:setVisible(false)

        -- 레벨업 가능 여부 처리
	    local possible = g_dragonsData:possibleDragonLevelUp(self.m_selectDragonOID)
	    vars['lockSprite']:setVisible(not possible)
        if (not possible) then
            local next_grade = t_dragon_data['grade'] + 1
            vars['infoLabel2']:setString(Str('{1}성 승급시 레벨업 할 수 있어요', next_grade))
        end
    end

    --vars['levelLabel']:setString(Str('레벨{1}/{2}', curr_level, max_level))

    -- 능력치 정보 갱신
    self:refresh_stats(t_dragon_data, curr_level, next_level)
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
-- function confirmExp
-- @brief 드래곤 경험치가 충분한지 체크
-- @return 경험치가 충분할 때 true 반환
-------------------------------------
function UI_DragonLevelUpNew:confirmExp()
	return self.m_oriExp >= self.m_needExpSum
end

-------------------------------------
-- function	buyExp
-- @brief 드래곤 경험치 구매 팝업을 띄움
-------------------------------------
function UI_DragonLevelUpNew:buyExp()
	-- 드래곤 경험치 product_struct
    local product_struct = g_shopDataNew:getProduct('amethyst', 220027)
    product_struct:buy(function(ret)
        ItemObtainResult_Shop(ret) 
        self:refresh()
    end)
end

-------------------------------------
-- function click_levelupBtn
-- @brief 레벨업 버튼을 한번 누른 경우
-- 바로바로 서버에 요청을 보냄
-------------------------------------
function UI_DragonLevelUpNew:click_levelupBtn()
    local doid = self.m_selectDragonOID
	local vars = self.vars

	local function initField() -- 레벨업이 조건에 의해 취소된 경우 관련된 값 초기화
		self.m_needGoldSum = 0
		self.m_needExpSum = 0
	end

	self.m_needGoldSum = self.m_needGoldNext
	self.m_needExpSum = self.m_needExpNext

    -- 현재 레벨업 가능한 드래곤인지 검증
    local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)
    if (not possible) then
        UIManager:toastNotificationRed(msg)
		initField()
        return
    end

    -- 골드가 충분히 있는지 확인
	local need_gold = self.m_needGoldSum
    if (not ConfirmPrice('gold', need_gold)) then
		UIManager:toastNotificationRed(Str('골드가 부족합니다'))
		initField()
	    return
    end

	-- 경험치가 충분히 있는지 확인
	if (not self:confirmExp()) then
		UIManager:toastNotificationRed(Str('드래곤 경험치가 부족합니다'))
		self:buyExp()
		initField()
		return
	end

	-- 클릭의 경우 1 레벨업
	self.m_targetDragonLevel = self.m_currDragonLevel + 1
    self:request_levelUp()
end

-------------------------------------
-- function press_levelupBtn
-- @brief 레벨업 버튼을 지속적으로 누를 때
-- 버튼을 뗄 떼까지 값 저장했다가 서버에 요청
-------------------------------------
function UI_DragonLevelUpNew:press_levelupBtn(btn)
	local function coroutine_function(dt)
        local co = CoroutineHelper()
		local t_dragon_data = self.m_selectDragonData

        -- 코루틴이 종료되는 어떠한 상황에서도 호출될 함수
        local function coroutine_finidh_cb()
            -- 연출 종료
		    --self.m_reinforceEffect:addAniHandler(function()
			--self.m_reinforceEffect:setVisible(false)
            --end)
		    -- 백키 블럭 해제
            UIManager:blockBackKey(false)
        end
        co:setCloseCB(coroutine_finidh_cb)

		-- 백키 블럭 설정
        UIManager:blockBackKey(true)

		-- 연출 시작 
		--self.m_reinforceEffect:setVisible(true)
		--self.m_reinforceEffect:changeAni('idle', true)

		-- 인위적 통신을 위한 변수 뭉치
		--local before_reinforce_exp = t_dragon_data:getReinforceObject()['exp']
		--local before_relation_point
		--if (self.m_isDragon) then
			--before_relation_point = g_bookData:getBookData(rid):getRelation()
		--else
			--before_relation_point = g_userData:getReinforcePoint(rid)
		--end

		-- 변수
		local curr_level = self.m_currDragonLevel
		local grade = t_dragon_data['grade']
		local max_level = TableGradeInfo():getValue(grade, 'max_lv')
		local timer = 0
		local node = cc.Node:create()
		local b_less_exp = false
		self.root:addChild(node)

		-- 업데이트
		local function update(dt)
			if (not btn:isSelected()) or (curr_level >= max_level) or (self.m_oriGold < (self.m_needGoldSum + self.m_needGoldNext)) then
				node:unscheduleUpdate()
				co.NEXT()
			end

			if  (self.m_oriExp < (self.m_needExpSum + self.m_needExpNext)) then -- 경험치가 모자란 경우엔 추가 처리
				b_less_exp = true
				node:unscheduleUpdate()
				co.NEXT()
			end

			timer = timer + dt
			if (timer > dt * 10) then -- 레벨업 사이사이 딜레이 조정
				co.NEXT()	
				timer = 0
			end
		end
		node:scheduleUpdateWithPriorityLua(update, 0)

        -- 레벨업 연속 연출
		while (btn:isSelected()) do
			co:work()

			-- 탈출 조건
			-- 레벨이 가득 찼을 때
			if (curr_level >= max_level) then
				break
			end

			-- 돈이 부족할 때
			if (self.m_oriExp < (self.m_needExpSum + self.m_needExpNext)) then
				break
			end
			
			-- 경험치가 부족할 때
			if (self.m_oriGold < (self.m_needGoldSum + self.m_needGoldNext)) then
				b_less_exp = true
				break
			end

			curr_level = curr_level + 1
			-- 실제 통신하기 전에 클라에서 인위적으로 조정해주어 한땀한땀 들어가는 것으로 보여줌
			do
				-- 강화 경험치 수정
				t_dragon_data['lv'] = next_level
				t_dragon_data['exp'] = 0
				self.m_needExpSum = self.m_needExpSum + self.m_needExpNext
				self.m_needGoldSum = self.m_needGoldSum + self.m_needGoldNext
				self.m_targetDragonLevel = curr_level

				-- 골드 수정
				g_userData:applyServerData(self.m_oriGold - self.m_needGoldSum, 'gold')
				-- 드래곤 경험치 수정
				g_userData:applyServerData(self.m_oriExp - self.m_needExpSum, 'dragon_exp')
				-- 드래곤 스탯과 카드 변경
				self:refresh_dragonStat(curr_level)
				self:refresh_dragonCard(curr_level)
			end

			-- 연출
			--self:reinforceDirecting(ui, function() end)

			if co:waitWork() then return end
		end

		-- 서버와 통신
        co:work()
        self:request_levelUp()
        if co:waitWork() then return end

        -- 드래곤 스탯과 카드 변경
		self:refresh_dragonStat(curr_level)
		self:refresh_dragonCard(curr_level)

		-- 연출 종료
		--self.m_reinforceEffect:addAniHandler(function()
			--self.m_reinforceEffect:setVisible(false)
		--end)
--
		-- 백키 블럭 해제
        UIManager:blockBackKey(false)

		if b_less_exp then -- 경험치가 모자라 그만둔 경우 경험치 구입 팝업
			UIManager:toastNotificationRed(Str('드래곤 경험치가 부족합니다'))
			self:buyExp()
		end

        co:close()
    end

    Coroutine(coroutine_function)
end

-------------------------------------
-- function request_levelUp
-- @brief 레벨업을 서버에 요청
-------------------------------------
function UI_DragonLevelUpNew:request_levelUp()
	local uid = g_userData:get('uid')
	local doid = self.m_selectDragonData['id']
	local curr_level = self.m_currDragonLevel
	local curr_dragon_exp = self.m_oriExp
	local gold = self.m_oriGold
	local target_level = self.m_targetDragonLevel
	local target_dragon_exp = curr_dragon_exp - self.m_needExpSum
	local target_gold = gold - self.m_needGoldSum

	local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '드래곤 레벨업')

        local prev_lv = self.m_currDragonLevel
        local prev_exp = self.m_selectDragonData['exp']
        
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
				
		self:response_levelup(ret)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/levelup_new')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
	ui_network:setParam('lv', curr_level)
	ui_network:setParam('dragon_exp', curr_dragon_exp)
	ui_network:setParam('gold', gold)
	ui_network:setParam('target_lv', target_level)
	ui_network:setParam('target_dragon_exp', target_dragon_exp)
	ui_network:setParam('target_gold', target_gold)
	--ui_network:hideLoading()
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
	ui_network:request()
end

-------------------------------------
-- function response_levelup
-- @brief
-------------------------------------
function UI_DragonLevelUpNew:response_levelup(ret)
    -- 드래곤 정보 갱신
    g_dragonsData:applyDragonData(ret['modified_dragon'])

    -- 골드, 드래곤 경험치 갱신
    g_serverData:networkCommonRespone(ret)

    self.m_bChangeDragonList = true

    self:setSelectDragonDataRefresh()

    local doid = self.m_selectDragonOID
    self:refresh_dragonIndivisual(doid)

    -- @ MASTER ROAD
    local t_data = {clear_key = 'd_lvup'}
    g_masterRoadData:updateMasterRoad(t_data)

    -- @ DRAGON DIARY
    local t_data = {clear_key = 'd_lvup', ret = ret}
    g_dragonDiaryData:updateDragonDiary(t_data)
end

--@CHECK
UI:checkCompileError(UI_DragonLevelUpNew)