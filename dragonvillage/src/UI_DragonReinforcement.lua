local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonReinforcement
-------------------------------------
UI_DragonReinforcement = class(PARENT,{
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
    self:init_dragonTableView()
    self:initStatusUI()
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
	uic_stats:showOnlyCurrStat(false)
    vars['atkStats'] = uic_stats

    local uic_stats = UIC_IndivisualStats()
    uic_stats:initUIComponent()
    uic_stats:setPositionY(l_pos[2])
    uic_stats:setParentNode(vars['statsNode'])
    uic_stats:setStatsName(Str('방어력'))
	uic_stats:showOnlyCurrStat(false)
    vars['defStats'] = uic_stats

    local uic_stats = UIC_IndivisualStats()
    uic_stats:initUIComponent()
    uic_stats:setPositionY(l_pos[3])
    uic_stats:setParentNode(vars['statsNode'])
    uic_stats:setStatsName(Str('생명력'))
	uic_stats:showOnlyCurrStat(false)
    vars['hpStats'] = uic_stats
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
		
	-- 현재 경험치 / 총 경험치
	local rexp = t_dragon_data:getRexp()
	local max_rexp = TableDragonReinforce:getCurrMaxExp(did, rlv)
	vars['expLabel']:setString(string.format('%d / %d exp', rexp, max_rexp))
	
	-- 경험치 게이지
	vars['expGauge']:setPercentage(rexp / max_rexp * 100)

	-- 강화 비용
end

-------------------------------------
-- function refresh_stats
-- @brief 능력치
-------------------------------------
function UI_DragonReinforcement:refresh_stats(t_dragon_data)
    local vars = self.vars
    local doid = self.m_selectDragonOID

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

    ---- 변경된 레벨의 능력치 계산기
    --local chaged_dragon_data = {}
    --local changed_status_calc = MakeOwnDragonStatusCalculator(doid, chaged_dragon_data)
--
    ---- 변경된 레벨의 능력치
    --local changed_atk = changed_status_calc:getFinalStat('atk')
    --local changed_def = changed_status_calc:getFinalStat('def')
    --local changed_hp = changed_status_calc:getFinalStat('hp')
    --local changed_cp = changed_status_calc:getCombatPower()
--
    --vars['atkStats']:setAfterStats(changed_atk)
    --vars['defStats']:setAfterStats(changed_def)
    --vars['hpStats']:setAfterStats(changed_hp)
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
				self:click_reinforce(rid, ui)
			end)

			-- 버튼 프레스 등록
			click_btn:registerScriptPressHandler(function()
				self:press_reinforce(rid, ui, click_btn)
			end)

		-- 없으면 빈아이콘 생성
		else
			local ui = UI()
			ui:load('hatchery_relation_item.ui')
			ui.vars['clickBtn']:setEnabled(false)
			ui.vars['relationLabel']:setString('')
			vars['relationNode' .. i]:addChild(ui.root)
			
		end
	end

end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonReinforcement:getDragonList()
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
-- function getMaxReinforceCount
-- @brief 현재 최대로 강화 가능한 수를 구한다
-------------------------------------
function UI_DragonReinforcement:getMaxReinforceCount(rid)

end

-------------------------------------
-- function click_reinforce
-- @brief
-------------------------------------
function UI_DragonReinforcement:click_reinforce(rid, ui)
	local t_dragon_data = self.m_selectDragonData

	-- 최대 강화 예외처리

	-- 인연 포인트 부족
	if (g_bookData:getRelationPoint(rid) <= 0) then
		UIManager:toastNotificationRed(Str('인연 포인트가 부족합니다.'))
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
        local ret_cache
        local function request_finish(ret)
            ret_cache = ret
            co.NEXT()
        end
        self:request_reinforce(rid, 1, request_finish)
        if co:waitWork() then return end

        -- 필요한것들 갱신
		self:response_reinforce(ret_cache)
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
	local t_dragon_data = self.m_selectDragonData

	if (g_bookData:getRelationPoint(rid) <= 0) then
		UIManager:toastNotificationRed(Str('인연 포인트가 부족합니다.'))
		return
	end

	local function coroutine_function(dt)
        local co = CoroutineHelper()
        --co:setBlockPopup()

		local rcnt = 0

		local timer = 0
		local node = cc.Node:create()
		self.root:addChild(node)
		local function update(dt)
			timer = timer + dt
			if (timer > dt * 30) then
				co.NEXT()	
				timer = 0
			end
		end
		node:scheduleUpdateWithPriorityLua(update, 0)

        -- 강화 연속 연출
		while (btn:isSelected()) do
			co:work()

			cclog(rcnt)
			rcnt = rcnt + 1
			self:reinforceDirecting(ui, function()
				local rexp = t_dragon_data:getReinforceObject()['exp']
				t_dragon_data:getReinforceObject()['exp'] = rexp + 1
				self:response_reinforce(ret_cache)
				ui:refresh()
				co.NEXT()
			end)

			if co:waitWork() then return end
		end
		
		node:removeFromParent()

        -- 서버와 통신
        co:work()
        local ret_cache
        local function request_finish(ret)
            ret_cache = ret
            co.NEXT()
        end
        self:request_reinforce(rid, rcnt, request_finish)
        if co:waitWork() then return end

        -- 필요한것들 갱신
		self:response_reinforce(ret_cache)
		ui:refresh()

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
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function response_reinforce
-- @brief
-------------------------------------
function UI_DragonReinforcement:response_reinforce(ret)
	self:setSelectDragonDataRefresh()
    self:refresh_reinforceInfo()
	self:refresh_stats()
end

-------------------------------------
-- function reinforceDirecting
-- @brief
-------------------------------------
function UI_DragonReinforcement:reinforceDirecting(item_ui, finish_cb)
	--local vars = self.vars
--
    ---- base node
    --local ui_node = self.root
--
    ---- 연출 생성
    --local heart_move_ani = MakeAnimator('res/ui/a2d/dragon_forest/dragon_forest.vrp')
    --heart_move_ani:changeAni('heart_move', false)
    --ui_node:addChild(heart_move_ani.m_node, 99)
--
    --local dock_point = heart_move_ani.m_node:getDockPoint()
    --local anchor_point = heart_move_ani.m_node:getAnchorPoint()
--
    ---- 시작 위치
    --local start_node = item_ui.root
    --local start_pos = TutorialHelper:convertToWorldSpace(ui_node, start_node, dock_point, anchor_point)
--
    ---- 도착 위치
    --local tar_node = vars['dragonIconNode']
    --local tar_pos = TutorialHelper:convertToWorldSpace(ui_node, tar_node, dock_point, anchor_point)
--
    ---- pos, scale, rotate
    --local start_x = start_pos['x'] 
    --local start_y = start_pos['y']
    --local tar_x = tar_pos['x']
    --local tar_y = tar_pos['y']
    --local distance = getDistance(start_x, start_y, tar_x, tar_y)
    --local scale = (distance / 500)
    --local angle = getAdjustDegree(getDegree(start_x, start_y, tar_x, tar_y))
    --heart_move_ani:setPosition(start_x, start_y)
    --heart_move_ani:setScaleX(scale)
    --heart_move_ani:setRotation(angle + 90)
--
    ---- 종료 콜백
    --heart_move_ani:addAniHandler(function() 
		--if (cb_func) then
			--cb_func()
		--end
    --end)

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
        dest_pos_y = local_pos['y'] + 50 + math_random(-20, 20)
    end

    -- 아이콘 생성
	local struct_dragon = item_ui.m_tData
    local icon = UI_RelationCard(struct_dragon).root
	icon:setScale(0.5)
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
