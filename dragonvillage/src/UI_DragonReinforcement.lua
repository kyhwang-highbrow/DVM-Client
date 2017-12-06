local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonReinforcement
-------------------------------------
UI_DragonReinforcement = class(PARENT,{
		m_isDragon = 'bool', -- true / false
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
    local vars = self:load('dragon_reinforce.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonReinforcement')

    self:sceneFadeInAction()
    self:initUI()
    self:initButton()
    --self:refresh()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    -- 정렬 도우미
    self:init_dragonSortMgr()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonReinforcement:initUI()
    local vars = self.vars
	vars['expGauge']:setPercentage(0)
    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonReinforcement:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonReinforcement:refresh()
    self:refresh_dragonInfo()
	self:refresh_reinforceInfo()
	self:refresh_stats()
	self:refresh_relation()
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
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)
    end

    do -- 드래곤 역할(role)
        local role_type = t_dragon_data:getRole()
        vars['typeLabel']:setString(dragonRoleName(role_type))
    end
    
    do -- 드래곤 현재 정보 카드
        vars['dragonIconNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(t_dragon_data)
        vars['dragonIconNode']:addChild(dragon_card.root)
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
-- function refresh_dragonInfo
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
	local rlv = t_dragon_data:getRlv()
	vars['reinfoceLabel']:setString(Str('강화 +{1}', rlv))
		
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
	local curr_cost = TableDragonReinforce:getCurrCost(did, rlv)
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

	-- 최대 레벨 조건의 능력치 계산기
	local t_max_data = clone(t_dragon_data)
	t_max_data['lv'] = 60
	t_max_data['grade'] = MAX_DRAGON_GRADE
	t_max_data['evolution'] = MAX_DRAGON_EVOLUTION
	t_max_data['reinforce']['lv'] = MAX_DRAGON_REINFORCE
	local max_status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_max_data)

	-- 강화 증가량 게이지 / 현재 스탯 / 맥스 스탯
	do
		local did = t_dragon_data:getDid()
		local t_curr_reinforce = t_dragon_data:getReinforceMulti()
		local t_max_reinforce = TableDragonReinforce:getTotalRateTable(did)
		for i, key in pairs({'atk', 'def', 'hp'}) do
			-- 현재 수치
			local curr_stat = status_calc:getFinalStatDisplay(key)
			local curr_rate = t_curr_reinforce[key]

			-- 최대 수치
			local max_stat = max_status_calc:getFinalStatDisplay(key)
			local max_rate = t_max_reinforce[key]

			vars[key .. 'Gauge']:runAction(cc.ProgressTo:create(0.2, (curr_rate / max_rate * 100)))
			vars[key .. 'Label']:setString(string.format('{@W}%s / {@G}%s', curr_stat, max_stat))
		end
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
	local list = TableDragon:getSameTypeDragonList(did)
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

			-- 카드 생성
			local t_data = {
				['did'] = rid,
				['grade'] = t_dragon['birthgrade']
			}
			local struct_dragon = StructDragonObject(t_data)
			local ui = UI_HatcheryRelationItem(struct_dragon)
			vars['relationNode' .. i]:addChild(ui.root)

			local click_btn = ui.vars['clickBtn']

			-- 버튼 클릭 등록
			click_btn:registerScriptTapHandler(function()
				self.m_isDragon = true
				self:click_reinforce(rid, ui)
			end)

			-- 버튼 프레스 등록
			click_btn:registerScriptPressHandler(function()
				self.m_isDragon = true
				self:press_reinforce(rid, ui, click_btn)
			end)

			-- 연출
			ui.m_characterCard.root:setScale(0)
			ui.m_characterCard.root:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.025), cc.EaseElasticOut:create(cc.ScaleTo:create(1, 1, 1), 0.3)))


		-- 없으면 빈아이콘 생성
		else
			local ui = UI()
			ui:load('hatchery_relation_item.ui')
			ui.vars['clickBtn']:setEnabled(false)
			ui.vars['relationLabel']:setString('')
			ui.vars['emptyNode']:setVisible(true)
			vars['relationNode' .. i]:addChild(ui.root)
			
		end
	end

	-- 강화 포인트 생성
	do 
		local grade = t_dragon_data:getBirthGrade()
		local item_id = 760000 + grade
		local t_item = TableItem():get(item_id)
		local ui = UI()
		ui:load('hatchery_relation_item.ui')
		vars['relationNode6']:addChild(ui.root)
		
		local card = UI_ReinforcePointCard(t_item)
		card.vars['clickBtn']:setEnabled(false)
		ui.vars['dragonNode']:addChild(card.root)
		ui.m_uiName = t_item

		function ui:refresh()
			local point = g_userData:getReinforcePoint(item_id)
			ui.vars['relationLabel']:setString(string.format('{@w}%d', point))
		end

		ui:refresh()

		local click_btn = ui.vars['clickBtn']

		-- 버튼 클릭 등록
		click_btn:registerScriptTapHandler(function()
			self.m_isDragon = false
			self:click_reinforce(item_id, ui)
		end)

		-- 버튼 프레스 등록
		click_btn:registerScriptPressHandler(function()
			self.m_isDragon = false
			self:press_reinforce(item_id, ui, click_btn)
		end)

		-- 연출
		card.root:setScale(0)
		card.root:runAction(cc.Sequence:create(cc.DelayTime:create((6-1) * 0.025), cc.EaseElasticOut:create(cc.ScaleTo:create(1, 1, 1), 0.3)))
	end

end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonReinforcement:getDragonList()
    local dragon_dic = g_dragonsData:getDragonsList()
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
	local curr_cost = TableDragonReinforce:getCurrCost(did, rlv)
	local gold = g_userData:get('gold')
	if ((gold/curr_cost) < relation) then
		relation = math_floor(gold/curr_cost)
	end
	
	return relation
end

-------------------------------------
-- function click_reinforce
-- @brief
-------------------------------------
function UI_DragonReinforcement:exceptionReinforce(rid)
	local t_dragon_data = self.m_selectDragonData
	local did = t_dragon_data:getDid()

	-- 최대 강화 예외처리
	if (t_dragon_data:isMaxRlv()) then
		UIManager:toastNotificationRed(Str('최대 강화 레벨인 드래곤입니다.'))
		return true
	end

	-- 골드 비교
	local rlv = t_dragon_data:getRlv()
	local curr_cost = TableDragonReinforce:getCurrCost(did, rlv)
	local gold = g_userData:get('gold')
	if (curr_cost > gold) then
		UIManager:toastNotificationRed(Str('골드가 부족합니다.'))
		return true
	end

	-- 인연 포인트 부족
	local relation = 0
	if (self.m_isDragon) then
		relation = g_bookData:getRelationPoint(rid)
	else
		relation = g_userData:getReinforcePoint(rid)
	end
	if (relation <= 0) then
		UIManager:toastNotificationRed(Str('인연 포인트가 부족합니다.'))
		return true
	end

	return false
end

-------------------------------------
-- function click_reinforce
-- @brief
-------------------------------------
function UI_DragonReinforcement:click_reinforce(rid, ui)

	-- 통합 예외처리
	if (self:exceptionReinforce(rid)) then
		return
	end

	local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        -- 강화 연출
        co:work()
        self:reinforceDirecting(ui, co.NEXT)
        if co:waitWork() then return end

        -- 서버와 통신
        co:work()
        local function request_finish()
			ccdisplay('NETWORK')
            co.NEXT()
        end
        self:request_reinforce(rid, 1, request_finish)
        if co:waitWork() then return end

        -- 필요한것들 갱신
		self:response_reinforce()
		ui:refresh()

        co:close()
    end

    Coroutine(coroutine_function)
end

-------------------------------------
-- function press_reinforce
-- @brief
-------------------------------------
function UI_DragonReinforcement:press_reinforce(rid, ui, btn)

	-- 통합 예외처리
	if (self:exceptionReinforce(rid)) then
		return
	end

	-- 코루틴 함수
	local function coroutine_function(dt)
        local co = CoroutineHelper()
		local t_dragon_data = self.m_selectDragonData

		-- 백키 블럭 해제
        UIManager:blockBackKey(true)

		-- 참조용
		local before_reinforce_exp = t_dragon_data:getReinforceObject()['exp']
		local before_relation_point
		if (self.m_isDragon) then
			before_relation_point = g_bookData:getBookData(rid):getRelation()
		else
			before_relation_point = g_userData:getReinforcePoint(rid)
		end

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
			if (timer > dt * 8) then
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

			-- 강화 경험치 수정
			t_dragon_data:getReinforceObject()['exp'] = before_reinforce_exp + rcnt
			self:refresh_reinforceInfo()
			self:refresh_stats()

			-- 인연 포인트 수정
			local relation = before_relation_point - rcnt
			if (self.m_isDragon) then
				local struct_book = g_bookData:getBookData(rid)
				struct_book:setRelation(relation)
			else
				g_userData:applyServerData(relation, 'reinforce_point', tostring(rid))
			end
			ui:refresh()

			-- 연출
			self:reinforceDirecting(ui, function() end)

			if co:waitWork() then return end
		end

		-- 서버와 통신
        co:work()
        local function request_finish()
			ccdisplay('NETWORK')
            co.NEXT()
        end
        self:request_reinforce(rid, rcnt, request_finish)
        if co:waitWork() then return end

        -- 필요한것들 갱신
		self:refresh_reinforceInfo()
		self:refresh_stats()
		ui:refresh()

		-- 백키 블럭 해제
        UIManager:blockBackKey(false)

        co:close()
    end

    Coroutine(coroutine_function)
end

-------------------------------------
-- function request_reinforce
-- @brief
-------------------------------------
function UI_DragonReinforcement:request_reinforce(rid, rcnt, cb_func)
    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID

    local function success_cb(ret)
		-- @analytics
        Analytics:firstTimeExperience('dragon reinforcement')

		-- 드래곤 갱신
		g_dragonsData:applyDragonData(ret['dragon'])

		-- 골드 갱신
		g_serverData:networkCommonRespone(ret)
		
		-- 인연포인트 (전체 갱신)
		if (ret['relation']) then
			g_bookData:applyRelationPoints(ret['relation'])
		end

		-- 드래곤 관리 UI 갱신
		self.m_bChangeDragonList = true

		-- 강화 레벨업 시 결과화면
		if (ret['is_rlevelup']) then
			local ui = UI_DragonReinforceResult(ret['dragon'])
			ui:setCloseCB(function() self:close() end)
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
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
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
        local x, y = vars['dragonIconNode']:getPosition()
        local parent = vars['dragonIconNode']:getParent()
        local world_pos = parent:convertToWorldSpaceAR(cc.p(x, y))
        local local_pos = self.root:convertToNodeSpaceAR(world_pos)
        dest_pos_x = local_pos['x'] + math_random(-20, 20)
        dest_pos_y = local_pos['y'] + 30 + math_random(-20, 20)
    end

    -- 아이콘 생성
	local icon
	if (self.m_isDragon) then
		local struct_dragon = item_ui.m_tData
		icon = UI_RelationCard(struct_dragon).root
	else
		local t_item = item_ui.m_uiName
		icon = UI_ReinforcePointCard(t_item).root
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


--@CHECK
UI:checkCompileError(UI_DragonReinforcement)
