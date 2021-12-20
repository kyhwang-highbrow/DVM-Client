local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonReinforcement
-------------------------------------
UI_DragonReinforcement = class(PARENT,{
		m_isDragon = 'bool', -- true / false
		m_reinforceEffect = 'Animator',
        m_oriGold = 'number',

        m_selectedBtnId = 'number', -- item_id or rid

        m_EnhanceUI = 'UI_CustomEnhance()',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonReinforcement:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonReinforcement'
    self.m_bVisible = true or false
    self.m_titleStr = Str('드래곤 강화')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonReinforcement:init(doid)
    local vars = self:load_keepZOrder('dragon_reinforce.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonReinforcement')

    self.m_oriGold = g_userData:get('gold') -- 통신 실패할 경우 원복할 골드
    self:sceneFadeInAction()
    self:initUI()
    self:initButton()
    --self:refresh()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    -- 정렬 도우미
    self:init_dragonSortMgr()

    -- 선택한 드래곤에 포커싱
    self:focusSelectedDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonReinforcement:initUI()
    local vars = self.vars
	vars['expGauge']:setPercentage(0)

    self.m_EnhanceUI = UI_CustomEnhance(self)
    self.m_EnhanceUI:setVisible(false)
    self.root:addChild(self.m_EnhanceUI.root, 5)

    self:init_dragonTableView()
    self:initStatusUI()
	self:initReinforceEffect()
end

-------------------------------------
-- function initStatusUI
-------------------------------------
function UI_DragonReinforcement:initStatusUI()
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
-- function initReinforceEffect
-------------------------------------
function UI_DragonReinforcement:initReinforceEffect()
	if (self.m_reinforceEffect) then
		return
	end
	
	local animator = MakeAnimator('res/ui/a2d/dragon_reinforce/dragon_reinforce.vrp')
	animator:setVisible(false)

	local pos_x, pos_y = self.vars['dragonNode']:getPosition()
	animator:setPosition(pos_x, pos_y)

	self.root:addChild(animator.m_node, 99)
	self.m_reinforceEffect = animator
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonReinforcement:initButton()
    local vars = self.vars
    
    -- 드래곤 강화 안내 (네이버 sdk 링크)
    NaverCafeManager:setPluginInfoBtn(vars['plugInfoBtn'], 'd_reinforce_help')
	vars['reinforceShopBtn']:registerScriptTapHandler(function() 
		local ui = UI_Shop_Popup_Reinforce(self.m_selectDragonData) 
		ui:setCloseCB(function() self:refresh_relation() end)
	end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonReinforcement:refresh()

    self.m_EnhanceUI:setActive(false)

    local vars = self.vars

    self:refresh_dragonInfo()
	self:refresh_reinforceInfo()
	self:refresh_stats()
	self:refresh_relation()

	-- 강화 포인트 상점 버튼 갱신
    local shop_visible = (self.m_selectDragonData:getRarity() == 'legend')
	vars['reinforceShopBtn']:setVisible(shop_visible)
    vars['reinforceShopBtn']:setAutoShake(shop_visible) -- 버튼 흔들기효과 (눈에 더 띄게)

    -- 할인 이벤트
    local only_value = true
	g_hotTimeData:setDiscountEventNode(HOTTIME_SALE_EVENT.DRAGON_REINFORCE, vars, 'reinforceEventSprite', only_value)
end

-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonReinforcement:refresh_dragonInfo()
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
    local attr = TableDragon:getDragonAttr(did)
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
        local attr = t_dragon_data:getAttr()
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    end

    do -- 드래곤 역할(role)
        local role_type = t_dragon_data:getRole()
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    end
	
	do -- 드래곤 등급
        vars['starNode']:removeAllChildren()
        local star_icon = IconHelper:getDragonGradeIcon(t_dragon_data, 2)
        vars['starNode']:addChild(star_icon)
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
-- function refresh_reinforceInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonReinforcement:refresh_reinforceInfo()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    local did = t_dragon_data['did']

	-- 드래곤 강화 레벨
	vars['reinforceNode']:removeAllChildren()
	local rlv = t_dragon_data:getRlv()
    local icon = IconHelper:getDragonReinforceIcon(rlv)
    vars['reinforceNode']:addChild(icon)

	-- 풀강화시 예외처리
	if (t_dragon_data:isMaxRlv()) then
		vars['expGauge']:setPercentage(100)
		vars['expLabel']:setString('MAX')
		vars['priceLabel']:setString('-')
		return
	end

	-- 현재 경험치 / 총 경험치
	local rexp = t_dragon_data:getRexp()
	local max_rexp = TableDragonReinforce:getCurrMaxExp(did, rlv)
	vars['expLabel']:setString(string.format('%d / %d exp', rexp, max_rexp))
	
	-- 경험치 게이지
	vars['expGauge']:runAction(cc.ProgressTo:create(0.2, (rexp / max_rexp * 100)))

	-- 강화 비용
	local curr_cost = t_dragon_data:getReinforceGoldCost()
	vars['priceLabel']:setString(comma_value(curr_cost))
end

-------------------------------------
-- function refresh_stats
-- @brief 능력치
-------------------------------------
function UI_DragonReinforcement:refresh_stats()
    local vars = self.vars

    -- 현재 레벨의 능력치 계산기
    local t_dragon_data = self.m_selectDragonData
    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data)

	-- 다음 강화 레벨의 능력치 계산기
	local t_next_data = clone(t_dragon_data)
	t_next_data['reinforce']['lv'] = t_dragon_data:getRlv() + 1
	local next_status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_next_data)

	-- 현재 스탯 / 다음렙 스탯
	for i, key in pairs({'atk', 'def', 'hp'}) do
		local curr_stat = status_calc:getFinalStat(key)
		vars[key .. 'Stats']:setBeforeStats(curr_stat)

		local next_stat = next_status_calc:getFinalStat(key)
		vars[key .. 'Stats']:setAfterStats(next_stat)
	end
end

-------------------------------------
-- function refresh_relation
-------------------------------------
function UI_DragonReinforcement:refresh_relation()
	local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end
	
	-- 인연포인트 표시하기 위한 t_dragon 리스트 생성
    local vars = self.vars
    local did = t_dragon_data['did']
	local list = TableDragon:getSameTypeDragonList(did, g_dragonsData.m_mReleasedDragonsByDid)
	local t_ret = {}
	for i, v in ipairs(list) do
		local did = v['did']
		local idx = did % 10
		t_ret[idx] = v
	end

	-- 순서대로 찍어준다.
	for i = 1, 5 do
		vars['relationNode' .. i]:removeAllChildren(true)

		local t_dragon = t_ret[i]

		-- 인연포인트 카드 생성
		if (t_dragon) then
			local rid = t_dragon['did']

			-- 데이터
			local t_data = {
				['did'] = rid,
				['grade'] = t_dragon['birthgrade']
			}
			local struct_dragon = StructDragonObject(t_data)

			-- 카드 생성
			local ui = UI_DragonReinforceItem('dragon', struct_dragon)
			vars['relationNode' .. i]:addChild(ui.root)

			-- 버튼 처리
			local click_btn = ui.vars['clickBtn']
			do
				-- 버튼 클릭 등록
				click_btn:registerScriptTapHandler(function()
					self:click_reinforce(rid, ui, true)
				end)

				-- 버튼 프레스 등록
				click_btn:registerScriptPressHandler(function()
					self:press_reinforce(rid, ui, click_btn, true)
				end)
			end

			-- 연출
			cca.fruitReact(ui.m_card.root, i)

		-- 없으면 빈아이콘 생성
		else
			local ui = UI_DragonReinforceItem('empty')
			vars['relationNode' .. i]:addChild(ui.root)
			
		end
	end

	-- 강화 포인트 생성
	do 
		vars['relationNode6']:removeAllChildren(true)

		-- 데이터
		local grade = t_dragon_data:getBirthGrade()
		local item_id = 760000 + grade
		local t_item = TableItem():get(item_id)

		-- 카드 생성
		local ui = UI_DragonReinforceItem('item', t_item)
		vars['relationNode6']:addChild(ui.root)
		
		-- 버튼 처리
		local click_btn = ui.vars['clickBtn']
		do
			-- 버튼 클릭 등록
			click_btn:registerScriptTapHandler(function()
				self:click_reinforce(item_id, ui, false)
			end)

			-- 버튼 프레스 등록
			click_btn:registerScriptPressHandler(function()
				self:press_reinforce(item_id, ui, click_btn, false)
			end)
		end

		-- 연출
		cca.fruitReact(ui.m_card.root, 6)
	end

end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonReinforcement:getDragonList()
    local dragon_dic = g_dragonsData:getDragonsList()

	-- 절대 레벨업 불가능한 드래곤 제외
    for oid, v in pairs(dragon_dic) do
        if (g_dragonsData:impossibleReinforcementForever(oid)) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function getMaxReinforceCount
-- @brief 현재 최대로 강화 가능한 수를 구한다
-------------------------------------
function UI_DragonReinforcement:getMaxReinforceCount(rid)
	local t_dragon_data = self.m_selectDragonData
	local did = t_dragon_data:getDid()
	local rlv = t_dragon_data:getRlv()

	-- 1. 보유 인연 포인트
	local relation
	if (self.m_isDragon) then
		relation = g_bookData:getBookData(rid):getRelation()
	else
		relation = g_userData:getReinforcePoint(rid)
	end

	-- 2. 레벨업 선 비교
	local rexp = t_dragon_data:getRexp()
	local max_rexp = TableDragonReinforce:getCurrMaxExp(did, rlv)
	if ((max_rexp - rexp) < relation) then
		relation = max_rexp - rexp
	end

	-- 3. 골드 비교
	local curr_cost = t_dragon_data:getReinforceGoldCost()
	local gold = g_userData:get('gold')
	if ((gold/curr_cost) < relation) then
		relation = math_floor(gold/curr_cost)
	end
	
	return relation
end

-------------------------------------
-- function exceptionReinforce
-- @brief 통합 예외 처리
-------------------------------------
function UI_DragonReinforcement:exceptionReinforce(rid, is_dragon)
	local t_dragon_data = self.m_selectDragonData
	local did = t_dragon_data:getDid()
	local rlv = t_dragon_data:getRlv()

	-- 현재의 등급에 대한 처리
	local grade = t_dragon_data:getGrade()
	if (grade <= rlv) then
		UIManager:toastNotificationRed(Str('현재의 등급 이상 강화할 수 없습니다.'))
		return true
	end

	-- 최대 강화 예외처리
	if (t_dragon_data:isMaxRlv()) then
		UIManager:toastNotificationRed(Str('최대 강화 레벨인 드래곤입니다.'))
		return true
	end
	
	-- 인연 포인트 부족
	local relation = 0
	if (is_dragon) then
		relation = g_bookData:getRelationPoint(rid)
	else
		relation = g_userData:getReinforcePoint(rid)
	end
	if (relation <= 0) then
		UIManager:toastNotificationRed(Str('인연 포인트가 부족합니다.'))
		return true
	end

	-- 골드 비교
	local curr_cost = t_dragon_data:getReinforceGoldCost()
	local gold = g_userData:get('gold')
	if (curr_cost > gold) then
		MakeSimplePopup(POPUP_TYPE.YES_NO, Str('골드가 부족합니다.\n상점으로 이동하시겠습니까?'), function() g_shopDataNew:openShopPopup('gold') end)
		return true
	end

	return false
end

-------------------------------------
-- function click_reinforce
-- @brief
-------------------------------------
function UI_DragonReinforcement:click_reinforce(rid, ui, is_dragon)
    self.m_EnhanceUI:setActive(false)

    if (self.m_selectedBtnId == rid) then self.m_selectedBtnId = nil return end

    -- 통합 예외처리
	if (self:exceptionReinforce(rid, is_dragon)) then
		return
	end    
    
    local vars = self.vars

    -- UI클래스의 root상 위치를 얻어옴
    
    self.m_EnhanceUI.root:setPosition(ZERO_POINT)
    local local_pos = convertToAnoterParentSpace(ui.root, self.m_EnhanceUI.root)
    local pos_x = local_pos['x']
    local pos_y = local_pos['y']

    do -- X축 위치 지정
        local width = 305 + 50
        local scr_size = cc.Director:getInstance():getWinSize()
        if (pos_x < 0) then
            local min_x = -(scr_size['width'] / 2)
            local left_pos = pos_x - (width/2)
            if (left_pos < min_x) then
                pos_x = min_x + (width/2)
            end
        else
            local max_x = (scr_size['width'] / 2)
            local right_pos = pos_x + (width/2)
            if (max_x < right_pos) then
                pos_x = max_x - (width/2)
            end
        end
    end

    pos_y = pos_y + 120

    -- 위치 설정
    self.m_EnhanceUI.root:setPosition(pos_x, pos_y)

    local arrow_pos_x = local_pos['x'] - pos_x--arrow_pos['x']
    self.m_EnhanceUI.vars['arrowSprite']:setPositionX(arrow_pos_x)
    

    -- 강화
    self.m_isDragon = is_dragon
    self.m_selectedBtnId = rid

	local t_dragon_data = self.m_selectDragonData
	local did = t_dragon_data:getDid()
	local rlv = t_dragon_data:getRlv()
    local grade = t_dragon_data:getGrade()
    local relation = g_bookData:getRelationPoint(rid)
    local data_table = {}

    if (not is_dragon) then
        relation = g_userData:getReinforcePoint(rid)
    end

    data_table['exp'] = t_dragon_data:getReinforceObject()['exp']
    data_table['lv'] = t_dragon_data:getReinforceObject()['lv']

    -- 구간별 경험치
    data_table['exp_list'] = TableDragonReinforce:getAllMaxExp(did, rlv)

    -- 강포 수량
    data_table['relation'] = relation

    data_table['grade'] = grade

    -- 강화
    -- 숫자 + Str('강화')
    
    if (IS_DEV_SERVER()) then
        ccdump(data_table)
    end

    self.m_EnhanceUI:setActive(true, data_table, ui)



    -- 이미 선택된 버튼이 있다면 return
    --[[
    if (self.m_selectedBtnId) then
        return
    end

	-- 통합 예외처리
	if (self:exceptionReinforce(rid, is_dragon)) then
		return
	end
    
    -- 선택된 버튼 저장
    self.m_selectedBtnId = rid
    self.m_isDragon = is_dragon

	local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        -- 코루틴이 종료되는 어떠한 상황에서도 호출될 함수
        local function coroutine_finidh_cb()
	        -- 선택된 버튼 초기화
            self.m_selectedBtnId = nil
        end
        co:setCloseCB(coroutine_finidh_cb)

		-- 연출 시작
		self.m_reinforceEffect:setVisible(true)
		self.m_reinforceEffect:changeAni('idle', false)
		self.m_reinforceEffect:addAniHandler(function()
			self.m_reinforceEffect:setVisible(false)
		end)

        -- 강화 연출
        co:work()

        -- 경험치, 인연포인트 깍음
        do
            local t_dragon_data = self.m_selectDragonData
            local rcnt = 1
            local before_reinforce_exp = t_dragon_data:getReinforceObject()['exp']
            local before_relation_point
		    if (self.m_isDragon) then
		    	before_relation_point = g_bookData:getBookData(rid):getRelation()
		    else
		    	before_relation_point = g_userData:getReinforcePoint(rid)
		    end

		    -- 강화 경험치 수정
		    t_dragon_data:getReinforceObject()['exp'] = before_reinforce_exp + rcnt

		    -- 인연 포인트 수정
		    local relation = before_relation_point - rcnt
		    if (self.m_isDragon) then
		    	local struct_book = g_bookData:getBookData(rid)
		    	struct_book:setRelation(relation)
		    else
		    	g_userData:applyServerData(relation, 'reinforce_point', tostring(rid))
            end
		end


        self:reinforceDirecting(ui, co.NEXT)
        if co:waitWork() then return end

        -- 서버와 통신
        co:work()
        self:request_reinforce(rid, 1, co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        -- 필요한것들 갱신
		self:response_reinforce()
		ui:refresh()

        co:close()
    end

    Coroutine(coroutine_function)]]
end

-------------------------------------
-- function press_reinforce
-- @brief
-------------------------------------
function UI_DragonReinforcement:press_reinforce(rid, ui, btn, is_dragon)
    if (self.m_EnhanceUI.m_isActive) then
        self.m_EnhanceUI:setActive(false)
        self.m_selectedBtnId = nil
    end

    -- 이미 선택된 버튼이 있다면 return
    if (self.m_selectedBtnId) then
        return
    end

	-- 통합 예외처리
	if (self:exceptionReinforce(rid, is_dragon)) then
		return
	end

    -- 선택된 버튼(열매id) 저장
    self.m_selectedBtnId = rid
    self.m_isDragon = is_dragon

	-- 코루틴 함수
	local function coroutine_function(dt)
        local co = CoroutineHelper()
		local t_dragon_data = self.m_selectDragonData

        -- 코루틴이 종료되는 어떠한 상황에서도 호출될 함수
        local function coroutine_finidh_cb()
	        -- 선택된 버튼(열매id) 초기화
            self.m_selectedBtnId = nil
            
            -- 연출 종료
		    self.m_reinforceEffect:addAniHandler(function()
			self.m_reinforceEffect:setVisible(false)
            end)
		    -- 백키 블럭 해제
            UIManager:blockBackKey(false)
        end
        co:setCloseCB(coroutine_finidh_cb)

		-- 백키 블럭 해제
        UIManager:blockBackKey(true)

		-- 연출 시작 
		self.m_reinforceEffect:setVisible(true)
		self.m_reinforceEffect:changeAni('idle', true)

		-- 인위적 통신을 위한 변수 뭉치
		local before_reinforce_exp = t_dragon_data:getReinforceObject()['exp']
		local before_relation_point
		if (self.m_isDragon) then
			before_relation_point = g_bookData:getBookData(rid):getRelation()
		else
			before_relation_point = g_userData:getReinforcePoint(rid)
		end
--		local did = t_dragon_data:getDid()
--		local rlv = t_dragon_data:getRlv()
		local cost = t_dragon_data:getReinforceGoldCost()
		local curr_gold = g_userData:get('gold')

		-- 변수
		local rcnt = 0
		local max_rcnt = self:getMaxReinforceCount(rid)
		local timer = 0
		local node = cc.Node:create()
		self.root:addChild(node)

		-- 업데이트
		local function update(dt)
			if (not btn:isSelected()) or (rcnt > max_rcnt) then
				node:unscheduleUpdate()
				co.NEXT()
			end

			timer = timer + dt
			if (timer > dt * 5) then
				co.NEXT()	
				timer = 0
			end
		end
		node:scheduleUpdateWithPriorityLua(update, 0)

        -- 강화 연속 연출
		while (btn:isSelected()) do
			co:work()

			-- 탈출 조건
			if (rcnt >= max_rcnt) then
				break
			end

			rcnt = rcnt + 1

			-- 실제 통신하기 전에 클라에서 인위적으로 조정해주어 한땀한땀 들어가는 것으로 보여줌
			do
				-- 강화 경험치 수정
				t_dragon_data:getReinforceObject()['exp'] = before_reinforce_exp + rcnt
				self:refresh_reinforceInfo()

				-- 인연 포인트 수정
				local relation = before_relation_point - rcnt
				if (self.m_isDragon) then
					local struct_book = g_bookData:getBookData(rid)
					struct_book:setRelation(relation)
				else
					g_userData:applyServerData(relation, 'reinforce_point', tostring(rid))
				end
				ui:refresh()

				-- 골드 수정
				g_userData:applyServerData(curr_gold - (cost * rcnt), 'gold')
			end

			-- 연출
			self:reinforceDirecting(ui, function() end)

			if co:waitWork() then return end
		end

		-- 서버와 통신
        co:work()
        self:request_reinforce(rid, rcnt, co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        -- 필요한것들 갱신
		self:refresh_reinforceInfo()
		self:refresh_stats()
		ui:refresh()

		-- 연출 종료
		self.m_reinforceEffect:addAniHandler(function()
			self.m_reinforceEffect:setVisible(false)
		end)

		-- 백키 블럭 해제
        UIManager:blockBackKey(false)

        co:close()
    end

    Coroutine(coroutine_function)
end

-------------------------------------
-- function refresh_fail
-- @brief 통신 실패하거나 에러코드 뱉은 경우 기존 데이터로 갱신
-------------------------------------
function UI_DragonReinforcement:refresh_fail(rid, rcnt)
    local t_dragon_data = self.m_selectDragonData

    local error_msg = Str('일시적인 오류입니다.\n잠시 후에 다시 시도 해주세요.')
    MakeSimplePopup(POPUP_TYPE.OK, error_msg)

    -- 강화된 드래곤 데이터 갱신
    local curr_exp = t_dragon_data:getReinforceObject()['exp']
    t_dragon_data:getReinforceObject()['exp'] = curr_exp - rcnt

    local curr_relation_point
    local relation

    -- 사용된 인연포인트 갱신
	if (self.m_isDragon) then
		curr_relation_point = g_bookData:getBookData(rid):getRelation()
        relation = curr_relation_point + rcnt

        local struct_book = g_bookData:getBookData(rid)
		struct_book:setRelation(relation)
	else
		curr_relation_point = g_userData:getReinforcePoint(rid)
        relation = curr_relation_point + rcnt

        g_userData:applyServerData(relation, 'reinforce_point', tostring(rid))
	end

    -- 사용된 골드 갱신
    g_userData:applyServerData(self.m_oriGold , 'gold')

    self:refresh()
end

-------------------------------------
-- function request_reinforce
-- @brief
-------------------------------------
function UI_DragonReinforcement:request_reinforce(rid, rcnt, cb_func, fail_cb)
    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID

    -- 에러코드 처리
    local function response_status_cb(ret)
        self:refresh_fail(rid, rcnt)
        if (fail_cb) then
            fail_cb()
        end
        return true
    end

    -- 통신실패 처리
    local function response_fail_cb(ret)
        self:refresh_fail(rid, rcnt)
        if (fail_cb) then
            fail_cb()
        end
    end

    local function success_cb(ret)
		-- @analytics
        Analytics:firstTimeExperience('dragon reinforcement')

		-- 드래곤 갱신
		g_dragonsData:applyDragonData(ret['dragon'])

		-- 골드 갱신
		g_serverData:networkCommonRespone(ret)
		
        -- 통신 실패할 경우 원복할 골드
        self.m_oriGold = g_userData:get('gold') 

		-- 인연포인트 (전체 갱신)
		if (ret['relation']) then
			g_bookData:applyRelationPoints(ret['relation'])
		end

		-- 드래곤 관리 UI 갱신
		self.m_bChangeDragonList = true

		-- 강화 레벨업 시 결과화면
		if (ret['is_rlevelup']) then
			local ui = UI_DragonReinforceResult(ret['dragon'])
			ui:setCloseCB(function()
				self:refresh_dragonIndivisual(doid)
			end)
		end

		if (cb_func) then
			cb_func()
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/reinforce')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('rcnt', rcnt)
    ui_network:setParam('rid', rid)
	ui_network:hideLoading()
    ui_network:setRevocable(true)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:setFailCB(response_fail_cb)
    ui_network:request()
end

-------------------------------------
-- function response_reinforce
-- @brief
-------------------------------------
function UI_DragonReinforcement:response_reinforce()
	self:setSelectDragonDataRefresh()
    self:refresh_reinforceInfo()
	self:refresh_stats()
end

-------------------------------------
-- function reinforceDirecting
-- @brief
-------------------------------------
function UI_DragonReinforcement:reinforceDirecting(item_ui, finish_cb)
	if (not item_ui) then
        return
    end
    
    local vars = self.vars
    local pos_x = 0
    local pos_y = 0

    local dest_pos_x = 0
    local dest_pos_y = 0

	local item_node = item_ui.root

    do -- 시작 위치
        local x, y = item_node:getPosition()
        local parent = item_node:getParent()
        local world_pos = parent:convertToWorldSpaceAR(cc.p(x, y))
        local local_pos = self.root:convertToNodeSpaceAR(world_pos)
        pos_x = local_pos['x']
        pos_y = local_pos['y']
    end

    do -- 도착 위치
        local x, y = vars['dragonNode']:getPosition()
        local parent = vars['dragonNode']:getParent()
        local world_pos = parent:convertToWorldSpaceAR(cc.p(x, y))
        local local_pos = self.root:convertToNodeSpaceAR(world_pos)
        dest_pos_x = local_pos['x'] + math_random(-20, 20)
        dest_pos_y = local_pos['y'] + 50 + math_random(-20, 20)
    end

    -- 아이콘 생성
	local icon
	local t_data = item_ui.m_tData
	if (self.m_isDragon) then
		icon = UI_RelationCard(t_data).root
	else
		icon = UI_ReinforcePointCard(t_data).root
	end
	icon:setScale(0.4)
    icon:setPosition(pos_x, pos_y)
    self.root:addChild(icon, 128)

    do -- 액션 실행
        local distance = getDistance(pos_x, pos_y, dest_pos_x, dest_pos_y)
        local duration = 0.5 + math_max(0, ((distance - 450) * 0.0001))
        local jump_height = math_random(100, 250)
        local action = cc.JumpTo:create(duration, cc.p(dest_pos_x, dest_pos_y), jump_height, 1)
		local action2 = cc.RotateTo:create(duration, -720)
        local spawn = cc.Spawn:create(cc.EaseIn:create(action, 1), action2)
        local scale_action = cc.ScaleTo:create(0.05, 0)
		local fx_sound = cc.CallFunc:create(function() SoundMgr:playEffect('UI', 'ui_eat') end)
		local cb_func = cc.CallFunc:create(finish_cb)
		icon:runAction(cc.Sequence:create(spawn, scale_action, fx_sound, cb_func, cc.RemoveSelf:create()))
    end

end

-------------------------------------
-- function checkSelectedDragonCondition
-------------------------------------
function UI_DragonReinforcement:checkSelectedDragonCondition(dragon_object)
    if (not dragon_object) then
        return false
    end
    -- StructSlimeObject는 soid (== id)
    -- StructDragonObject는 doid (== id)
    -- 두 클래스 모두 id에 값을 저장하고 있다
    local doid = dragon_object['id']
    local object_type = dragon_object:getObjectType()
    local upgradeable, msg = g_dragonsData:impossibleReinforcementForever(doid)
    if (upgradeable) then
        UIManager:toastNotificationRed(msg)
        return false
    end
    return true
end




-------------------------------------
-- function request_upgrade
-------------------------------------
function UI_DragonReinforcement:request_upgrade(count, ui)
    local t_dragon_data = self.m_selectDragonData
	-- 골드 비교
	local curr_cost = t_dragon_data:getReinforceGoldCost() * count
	local gold = g_userData:get('gold')
	if (curr_cost > gold) then
        self.m_EnhanceUI:setActive(false)
        self.m_selectedBtnId = nil
		MakeSimplePopup(POPUP_TYPE.YES_NO, Str('골드가 부족합니다.\n상점으로 이동하시겠습니까?'), function() g_shopDataNew:openShopPopup('gold') end)
		return true
	end


    local rid = self.m_selectedBtnId
    local rcnt = count
    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        -- 코루틴이 종료되는 어떠한 상황에서도 호출될 함수
        local function coroutine_finidh_cb()
	        -- 선택된 버튼 초기화
            self.m_selectedBtnId = nil
        end
        co:setCloseCB(coroutine_finidh_cb)

		-- 연출 시작
		self.m_reinforceEffect:setVisible(true)
		self.m_reinforceEffect:changeAni('idle', false)
		self.m_reinforceEffect:addAniHandler(function()
			self.m_reinforceEffect:setVisible(false)
		end)

        -- 강화 연출
        co:work()

        -- 경험치, 인연포인트 깍음
        do
            local t_dragon_data = self.m_selectDragonData
            --local rcnt = 1
            local before_reinforce_exp = t_dragon_data:getReinforceObject()['exp']
            local before_relation_point
		    if (self.m_isDragon) then
		    	before_relation_point = g_bookData:getBookData(rid):getRelation()
		    else
		    	before_relation_point = g_userData:getReinforcePoint(rid)
		    end

		    -- 강화 경험치 수정
		    t_dragon_data:getReinforceObject()['exp'] = before_reinforce_exp + rcnt

		    -- 인연 포인트 수정
		    local relation = before_relation_point - rcnt
		    if (self.m_isDragon) then
		    	local struct_book = g_bookData:getBookData(rid)
		    	struct_book:setRelation(relation)
		    else
		    	g_userData:applyServerData(relation, 'reinforce_point', tostring(rid))
            end
		end

        -- 서버와 통신
        co:work()
        self:request_reinforce(rid, rcnt, co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        -- 필요한것들 갱신
		self:response_reinforce()
		ui:refresh()

        co:close()
    end

    Coroutine(coroutine_function)

end








--@CHECK
UI:checkCompileError(UI_DragonReinforcement)
