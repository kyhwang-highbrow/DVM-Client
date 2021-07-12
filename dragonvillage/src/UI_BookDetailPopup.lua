local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_BookDetailPopup
-------------------------------------
UI_BookDetailPopup = class(PARENT,{
		-- m_tDragon은 레퍼런스이므로 가변데이터는 별도로 관리한다.
		m_tDragon = 'TableDragon data + evol, grade',
		m_lv = 'number',
		m_evolution = 'number',
		m_grade = 'number',
		
		-- idx 이동시 사용할 전체 도감리스트
		m_lBookList = 'list',
		m_bookIdx = 'num',

        -- refresh 체크 용도
        m_bookLastChangeTime = 'timestamp',
		
		m_pressTimer = 'timer',
		m_pressBtn = 'UIC_Button',

        m_dragonAnimator = 'UIC_DragonAnimator',
        m_originDid = 'number',

        m_showTeamBonus = 'boolean',
        m_mapAttrBtnUI = 'map',
        m_mapEvolutionBtnUI = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BookDetailPopup:init(t_dragon, is_popup, no_open)
    self.m_uiName = 'UI_BookDetailPopup'
    local vars = self:load('book_detail_popup.ui')
    local is_popup = is_popup or false
    -- 디폴트 값은 false UIMaker 여는 것
    if (not no_open) then
        local mode = is_popup and UIManager.POPUP or UIManager.SCENE
        UIManager:open(self, mode)

        -- backkey 지정
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BookDetailPopup')
    end
    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:sceneFadeInAction()

    self.m_showTeamBonus = true

	-- initialize
	self:setDragon(t_dragon, true)

    self.m_bookLastChangeTime = g_bookData:getLastChangeTimeStamp()
	self.m_pressTimer = 0

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BookDetailPopup:initUI()
    self.m_dragonAnimator = UIC_DragonAnimator()
    self.vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BookDetailPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

	-- 인덱스 이동
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn(true) end)
    vars['prevBtn']:registerScriptTapHandler(function() self:click_nextBtn(false) end)

	-- 등급 증감
	vars['gradePlusBtn']:registerScriptTapHandler(function() self:click_gradeBtn(true) end)
	vars['gradeMinusBtn']:registerScriptTapHandler(function() self:click_gradeBtn(false) end)

	-- 레벨 증감
	vars['lvPlusBtn']:registerScriptTapHandler(function() self:click_lvBtn(true) end)
	vars['lvPlusBtn']:registerScriptPressHandler(function() self:press_lvBtn(true) end)
	vars['lvMinusBtn']:registerScriptTapHandler(function() self:click_lvBtn(false) end)
	vars['lvMinusBtn']:registerScriptPressHandler(function() self:press_lvBtn(false) end)

    -- 능력치 상세보기
    vars['detailBtn']:registerScriptTapHandler(function() self:click_detailBtn() end)
	
	-- 평가 게시판
	vars['recommandBtn']:registerScriptTapHandler(function() self:click_recommandBtn() end)

	-- 획득 방법
	vars['getBtn']:registerScriptTapHandler(function() self:click_getBtn() end)

    -- 팀보너스
	vars['teamBonusBtn']:registerScriptTapHandler(function() self:click_teamBonusBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BookDetailPopup:refresh()
	-- 예외처리 용
	self:refresh_exception()

	self:onChangeDragon()
	self:onChangeEvolution()
	self:onChangeGrade()
	self:onChangeLV()
	self:calculateStat()
	
	-- 평점
	self:refresh_rate()
end

-------------------------------------
-- function refresh_exception
-- @brief 자코/슬라임 예외처리
-------------------------------------
function UI_BookDetailPopup:refresh_exception()
	local vars = self.vars

	local underling = (self.m_tDragon['underling'] == 1)
	local is_slime = (self.m_tDragon['bookType'] == 'slime')
    
    -- 진화 단계 선택 메뉴
    vars['evolutionMenu']:setVisible(not (underling or is_slime)) 

    -- 팀 보너스 버튼
    self.vars['teamBonusBtn']:setVisible(not is_slime and self.m_showTeamBonus)
end

-------------------------------------
-- function refresh_rate
-------------------------------------
function UI_BookDetailPopup:refresh_rate()
    local did = self.m_tDragon['did']
    local function cb_func(ret)
		-- ui 닫은 후 콜백 동작하는 경우 예외처리
		if (self:isClosed()) then
			return
		end
        local rate = ret['rate']
	    self.vars['recommandLabel']:setString(string.format('%.1f', rate))
    end
    g_boardData:request_dragonRate(did, cb_func)
end

-------------------------------------
-- function refresh_gradeBtnState
-------------------------------------
function UI_BookDetailPopup:refresh_gradeBtnState()
	local t_dragon = self.m_tDragon
	if (not t_dragon) then
		return
	end

    local vars = self.vars

    vars['gradePlusBtn']:setEnabled(true)
    vars['gradeMinusBtn']:setEnabled(true)
    
	local factor = (self.m_evolution == 3) and 1 or 0
	if (self.m_grade <= t_dragon['birthgrade'] + factor) then
        vars['gradeMinusBtn']:setEnabled(false)
    end

	if (self.m_grade >= MAX_DRAGON_GRADE) then
        vars['gradePlusBtn']:setEnabled(false)
        
	end
end

-------------------------------------
-- function refresh_lvBtnState
-------------------------------------
function UI_BookDetailPopup:refresh_lvBtnState()
	local t_dragon = self.m_tDragon
	if (not t_dragon) then
		return
	end

    local vars = self.vars

    vars['lvPlusBtn']:setEnabled(true)
    vars['lvMinusBtn']:setEnabled(true)
    
    local max_lv = TableGradeInfo:getMaxLv(self.m_grade)

    if (self.m_lv <= 1) then
        vars['lvMinusBtn']:setEnabled(false)
    end

	if (self.m_lv >= max_lv) then
        vars['lvPlusBtn']:setEnabled(false)
        
	end
end

-------------------------------------
-- function refresh_collectionState
-- @brief 도감작. 드래곤 최초 획득 보상 관련 UI 갱신
-------------------------------------
function UI_BookDetailPopup:refresh_collectionState()
    local vars = self.vars

    -- node 정리
    for i=1, MAX_DRAGON_EVOLUTION do
        vars['rewardNode' .. i]:removeAllChildren()
    end

	local t_dragon = self.m_tDragon
	if (not t_dragon) then
		return
	end

    local did = self.m_tDragon['did']
    local evolution = self.m_evolution
    local target_evolution = nil

    -- 몬스터는 표기 제외 (진화가 가능한지)
    if TableDragon:isUnderling(did) then
        return
    end

    -- 현재 선택된 진화단계가 획득이 되지 않았을 경우
    if (not g_bookData:isExist_byDidAndEvolution(did, evolution)) then
        target_evolution = evolution
    end

    -- 낮은 진화 단계부터 획득 가능한 단계를 검색
    if (not target_evolution) then
        for i=1, MAX_DRAGON_EVOLUTION do
            if (not g_bookData:isExist_byDidAndEvolution(did, i)) then
                target_evolution = i
                break
            end
        end
    end

    -- 모든 진화 단계를 획득하였을 경우 함수 종료
    if (not target_evolution) then
        return
    end

    -- 슬라임일 경우 함수 종료
    local is_slime = (self.m_tDragon['bookType'] == 'slime')
    if (is_slime) then
        return
    end
    
    -- UI 생성
    -- langLabel : 획득보상 
    -- rewardLabel : 드래곤의 희귀도와 진화 단계에 따른 획득 가능한 다이아의 개수.
    local ui = UI()
    ui:load('book_detail_popup_reward.ui')
    vars['rewardNode' .. target_evolution]:addChild(ui.root)
    local birthgrade = self.m_tDragon['birthgrade']
    local reward_dia = TableCollectionReward:getCollectionReward(birthgrade, target_evolution) or 0
    ui.vars['rewardLabel']:setString(comma_value(reward_dia))
    ui:doActionReset()
    ui:doAction()
end

-------------------------------------
-- function onChangeDragon
-------------------------------------
function UI_BookDetailPopup:onChangeDragon()
    local t_dragon = self.m_tDragon
    if (not t_dragon) then
        return
    end

    local vars = self.vars

    -- 드래곤 이름
    vars['nameLabel']:setString(Str(t_dragon['t_name']))

    local attr = t_dragon['attr']
    local role_type = t_dragon['role']
    local rarity_type = t_dragon['rarity']
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    -- 배경
    if self:checkVarsKey('bgNode', attr) then    
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end   

    do -- 희귀도
        vars['rarityNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRarityBtn(rarity_type, vars['rarityNode'], vars['rarityLabel'], t_info)
    end

    do -- 드래곤 속성
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    end

    do -- 드래곤 역할(role)
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    end    

    do -- 드래곤 스토리
        local story_str = t_dragon['t_desc']
        vars['storyLabel']:setString(Str(story_str))
    end

        for i = 1, 3 do 
        local node = vars['dragonCardNode'..i]
        if (node) then
            node:removeAllChildren()
        end
	end

    self:addSameEvolutionDragon(t_dragon) -- 드래곤 진화 단계 선택 (evolution)
    self:addSameTypeDragon(t_dragon)
end

-------------------------------------
-- function addSameEvolutionDragon
-- @brief 해치, 해츨링, 성룡 드래곤 표시
-------------------------------------
function UI_BookDetailPopup:addSameEvolutionDragon()
    local vars = self.vars
    self.m_mapEvolutionBtnUI = {}

    local underling = (self.m_tDragon['underling'] == 1)
	local is_slime = (self.m_tDragon['bookType'] == 'slime')
    local is_dragon = not (underling or is_slime)

    if (is_dragon) then
        for i = 1, 3 do 
            local node = vars['dragonCardNode'..i]
            if (node) then
                local data = clone(self.m_tDragon)
                data['evolution'] = i

                local card = UI_BookDragonCard(data)
                card.root:setSwallowTouch(false)
                node:addChild(card.root)

                -- 수집 여부에 따른 음영 처리
	            if (not g_bookData:isExist(data)) then
		            card:setShadowSpriteVisible(true)
	            end

                -- 등급 표시 안함
                card.vars['starNode']:setVisible(false)
                -- 선택한 카드 표시
                card:setHighlightSpriteVisibleWithNoAction(i == self.m_evolution)
                -- 진화 단계 선택 
                card.vars['clickBtn']:registerScriptTapHandler(function()
                    self:click_evolutionBtn(i)
                end)
                self.m_mapEvolutionBtnUI[i] = card
            end
	    end
    end
end

-------------------------------------
-- function addSameTypeDragon
-- @brief 같은 타입 드래곤 리스트
-------------------------------------
function UI_BookDetailPopup:addSameTypeDragon(t_dragon)
    local vars = self.vars

    local l_attr = getAttrTextList()
    self.m_mapAttrBtnUI = {}

    for _, attr in ipairs(l_attr) do
        local node = vars[attr..'Node']
        node:removeAllChildren()

        local ui = UI()
        ui:load('book_detail_popup_attr_btn.ui')
        node:addChild(ui.root)
        ui.vars[attr..'Sprite']:setVisible(true)
        ui.vars['disableSprite']:setVisible(true)
        self.m_mapAttrBtnUI[attr] = ui
    end

    local type = t_dragon['type']
    local target_list 

    if (self.m_tDragon['bookType'] == 'slime') then
        target_list = g_bookData:getSameTypeSlimeList(t_dragon['did'])
    else
        target_list = TableDragon():filterList('type', type)
    end

    -- test 값 확인
    if target_list then
        local _target_list = target_list
        target_list = {}
        for i,v in pairs(_target_list) do
            if (g_dragonsData:isReleasedDragon(v['did'])) then
                table.insert(target_list, v)
            end
        end
    end

    if (not target_list) then return end

    for _, v in pairs(target_list) do
        
        local t_data = v
        local attr = t_data['attr']
            
        if (t_data) then
            local ui = self.m_mapAttrBtnUI[attr]
            ui.vars[attr..'Sprite']:setVisible(true)
            ui.vars['disableSprite']:setVisible(false)

            if (self.m_tDragon['attr'] == attr) then
                ui.vars['selectSprite']:setVisible(true)
            end

            -- 존재하는 속성만 클릭 핸들러 등록
            ui.vars['attrBtn']:registerScriptTapHandler(function()
                self:click_sameTypeCard(t_data)
            end)
        end
    end
end

-------------------------------------
-- function onChangeEvolution
-------------------------------------
function UI_BookDetailPopup:onChangeEvolution()
    local t_dragon = self.m_tDragon
    if (not t_dragon) then
        return
    end

    local vars = self.vars
    local t_dragon_data = self:makeDragonData()
	local evolution = self.m_evolution

    do -- 드래곤 리소스
        self.m_dragonAnimator:setDragonAnimator(t_dragon_data['did'], evolution)
    end

	-- 스킬 아이콘 생성
	-- 슬라임일 경우
	if (t_dragon['bookType'] == 'slime') then
			
		-- 전부 비어있는 아이콘을 박아버린다 
		for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
			local skill_node = vars['skillNode' .. i]
			skill_node:removeAllChildren()
			local empty_skill_icon = IconHelper:getEmptySkillIcon()
			skill_node:addChild(empty_skill_icon)
		end

	-- 드래곤의 경우
	else

		local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
		local l_skill_icon = skill_mgr:getDragonSkillIconList()

		for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
			local skill_node = vars['skillNode' .. i]
			skill_node:removeAllChildren()
            
			-- 스킬 아이콘 생성
			if l_skill_icon[i] then
				skill_node:addChild(l_skill_icon[i].root)
                l_skill_icon[i]:setSimple()

				l_skill_icon[i].vars['clickBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
				l_skill_icon[i].vars['clickBtn']:registerScriptTapHandler(function()
					local new_dragon_data = self:makeDragonData()
                    UI_SkillDetailPopup(new_dragon_data, i)
				end)

			-- 비어있는 스킬 아이콘 생성
			else
				local empty_skill_icon = IconHelper:getEmptySkillIcon()
				skill_node:addChild(empty_skill_icon)

			end
		end

	end

    -- 도감작. 드래곤 최초 획득 보상 관련 UI 갱신
    self:refresh_collectionState()
end

-------------------------------------
-- function onChangeGrade
-------------------------------------
function UI_BookDetailPopup:onChangeGrade()
	local t_dragon = self.m_tDragon
    if (not t_dragon) then
        return nil
    end

	-- 진화도에 따른 등급 보정
	if (self.m_evolution == 3) then
        local max_birth_grade = math.min(t_dragon['birthgrade'] + 1, 6)
		if (self.m_grade < max_birth_grade) then
			self.m_grade = max_birth_grade
		end
	end

	t_dragon = {
		did = t_dragon['did'],
		evolution = self.m_evolution,
		grade = self.m_grade
	}
	local vars = self.vars
	local icon = IconHelper:getDragonGradeIcon(t_dragon, 3)
	vars['starNode']:removeAllChildren(true)
	vars['starNode']:addChild(icon)

    -- 버튼 상태 갱신
    self:refresh_gradeBtnState()
end

-------------------------------------
-- function onChangeLV
-------------------------------------
function UI_BookDetailPopup:onChangeLV()
	local vars = self.vars

	local max_lv = TableGradeInfo:getMaxLv(self.m_grade)
	if (self.m_lv > max_lv) then
		self.m_lv = max_lv
	end

	local str = string.format('%d / %d', self.m_lv, max_lv)
	vars['lvLabel']:setString(str)

    -- 버튼 상태 갱신
    self:refresh_lvBtnState()
end

-------------------------------------
-- function calculateStat
-------------------------------------
function UI_BookDetailPopup:calculateStat()
    local vars = self.vars
	
	-- 슬라임일 경우
	if (self.m_tDragon['bookType'] == 'slime') then
		vars['cp_label']:setString(0)
		return
	end

	local t_dragon_data = self:makeDragonData()

    -- 능력치 계산기
    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data)

    -- 모든 스탯 계산
    local hp = status_calc:getFinalStatDisplay('hp')
    local atk = status_calc:getFinalStatDisplay('atk')
    local def = status_calc:getFinalStatDisplay('def')
    local aspd = status_calc:getFinalStatDisplay('aspd')
    local cri_chance = status_calc:getFinalStatDisplay('cri_chance')
    local cri_dmg = status_calc:getFinalStatDisplay('cri_dmg')
    local hit_rate = status_calc:getFinalStatDisplay('hit_rate')
    local avoid = status_calc:getFinalStatDisplay('avoid')
    local cri_avoid = status_calc:getFinalStatDisplay('cri_avoid')
    local accuracy = status_calc:getFinalStatDisplay('accuracy')
    local resistance = status_calc:getFinalStatDisplay('resistance')

    -- detail node : final stat
    do
        vars['hp_label']:setString(hp)
        vars['atk_label']:setString(atk)
        vars['def_label']:setString(def)
        vars['aspd_label']:setString(aspd)
        vars['cri_chance_label']:setString(cri_chance)
        vars['cri_dmg_label']:setString(cri_dmg)
        vars['hit_rate_label']:setString(hit_rate)
        vars['avoid_label']:setString(avoid)
        vars['cri_avoid_label']:setString(cri_avoid)
        vars['accuracy_label']:setString(accuracy)
        vars['resistance_label']:setString(resistance)
        
        self:refresh_gauge(status_calc)
    end

	-- 전투력
	vars['cp_label']:setString(comma_value(t_dragon_data:getCombatPower()))
end

-------------------------------------
-- function refresh_gauge
-- @brief 능력치 게이지 액션
-------------------------------------
function UI_BookDetailPopup:refresh_gauge(status_calc)
    local vars = self.vars
    local status_calc = status_calc

	-- stat gauge refresh
	local l_stat = {'hp', 'atk', 'def', 'aspd', 'cri_chance', 'cri_dmg'}
	for _, stat_key in ipairs(l_stat) do
		local percent = status_calc:makePrettyPercentage(stat_key)
		vars[stat_key .. '_gauge']:runAction(cc.ProgressTo:create(0.2, percent * 100))
	end
end













-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_BookDetailPopup:click_nextBtn(is_next)
	local t_dragon = self.m_tDragon
    -- 다음, 이전 버튼에서는 origin did 사용, (같은 타입 드래곤 선택 추가되면서 did 변경될 수 있음)
	local did = self.m_originDid
	local evolution = self.m_evolution
    
	-- 현재의 인덱스 탐색
	local book_data
	for i, t_item in pairs(self.m_lBookList) do
		book_data = t_item['data']
		if (did == book_data['did']) then
			self.m_bookIdx = i
			break
		end
	end

	-- number loop를 만든다.
	local total_cnt = #self.m_lBookList
	local number_loop = NumberLoop(total_cnt)
	number_loop:setCurr(self.m_bookIdx)

	-- 새 인덱스를 구하고 그 드래곤의 데이타로 refresh
	local new_idx = is_next and number_loop:next() or number_loop:prev()
	local new_t_dragon = self.m_lBookList[new_idx]['data']
	if (new_t_dragon) then
		self:setDragon(new_t_dragon, true)
		self:refresh()
		self.m_bookIdx = new_idx

        -- 인덱스 이동간에 진화도가 바뀐다면 탭도 변경해준다
        if (new_t_dragon['evolution'] ~= evolution) then
            self.m_evolution = new_t_dragon['evolution']
        end
	end

    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData_checkNumber()
end

-------------------------------------
-- function click_gradeBtn
-------------------------------------
function UI_BookDetailPopup:click_gradeBtn(is_plus)
	local t_dragon = self.m_tDragon
	if (not t_dragon) then
		return
	end
	if (self.m_tDragon['bookType'] == 'slime') then
		UIManager:toastNotificationRed(Str('슬라임은 등급 조정을 할 수 없습니다.'))
		return	
	end

	-- grade 증감 후 필터링
	do
		self.m_grade = self.m_grade + (is_plus and 1 or -1)

		local factor = (self.m_evolution == 3) and 1 or 0
		if (self.m_grade < t_dragon['birthgrade'] + factor) then
			self.m_grade = t_dragon['birthgrade'] + factor

		elseif (self.m_grade > MAX_DRAGON_GRADE) then
			self.m_grade = MAX_DRAGON_GRADE

		end
	end

	-- refresh
	self:onChangeGrade()
	self:onChangeLV()
	self:calculateStat()
end

-------------------------------------
-- function click_lvBtn
-------------------------------------
function UI_BookDetailPopup:click_lvBtn(is_plus)
	local t_dragon = self.m_tDragon
	if (not t_dragon) then
		return
	end
	if (self.m_tDragon['bookType'] == 'slime') then
		UIManager:toastNotificationRed(Str('슬라임은 레벨 조정을 할 수 없습니다.'))
		return	
	end

	-- lv 증감 후 필터링
	do
		self.m_lv = self.m_lv + (is_plus and 1 or -1)
		if (self.m_lv < 1) then
			self.m_lv = 1

		elseif (self.m_lv > TableGradeInfo:getMaxLv(self.m_grade)) then
			self.m_lv = TableGradeInfo:getMaxLv(self.m_grade)

		end
	end

	-- refresh
	self:onChangeLV()
	self:calculateStat()
end

-------------------------------------
-- function press_lvBtn
-------------------------------------
function UI_BookDetailPopup:press_lvBtn(is_plus)
	local t_dragon = self.m_tDragon
	if (not t_dragon) then
		return
	end

	local vars = self.vars
	self.m_pressBtn = is_plus and vars['lvPlusBtn'] or vars['lvMinusBtn']

	-- 꾹누르기 업데이트 / 매프레임 click_lvBtn 호출
	local function update_lv(dt)
		if (not self.m_pressBtn:isSelected()) or (not self.m_pressBtn:isEnabled()) then
			self.m_pressTimer = 0
			self.m_pressBtn = nil
			vars['starNode']:unscheduleUpdate()
		end

		self.m_pressTimer = self.m_pressTimer + dt
		if (self.m_pressTimer > 0.03) then
			self:click_lvBtn(is_plus)
			self.m_pressTimer = self.m_pressTimer - 0.03
		end
	end

	vars['starNode']:scheduleUpdateWithPriorityLua(function(dt) return update_lv(dt) end, 1)
end

-------------------------------------
-- function click_evolutionBtn
-------------------------------------
function UI_BookDetailPopup:click_evolutionBtn(evolution)
	local t_dragon = self.m_tDragon
	if (not t_dragon) then
		return
	end

    for k, card in pairs(self.m_mapEvolutionBtnUI) do
        card:setHighlightSpriteVisibleWithNoAction(k == evolution)
    end

	-- evolution 세팅
	self.m_evolution = evolution

	-- refresh
	self:onChangeEvolution()
	self:onChangeGrade()
    self:onChangeLV()
	self:calculateStat()
end

-------------------------------------
-- function click_detailBtn
-- @brief 드래곤 상세 보기 팝업
-------------------------------------
function UI_BookDetailPopup:click_detailBtn()
	if (self.m_tDragon['bookType'] == 'slime') then
		UIManager:toastNotificationRed(Str('슬라임은 상세 보기를 할 수 없습니다.'))
		return	
	end

    self.vars['detailNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_recommandBtn
-- @brief 획득방법
-------------------------------------
function UI_BookDetailPopup:click_recommandBtn()
    local ui = UI_DragonBoardPopup(self.m_tDragon)
	ui:setCloseCB(function()
		self:refresh_rate()
	end)
end

-------------------------------------
-- function click_getBtn
-- @brief 획득방법
-------------------------------------
function UI_BookDetailPopup:click_getBtn()
	local did = self.m_tDragon['did']
	local evolution = self.m_evolution
	local item_id = TableItem:getItemIDByDid(did, evolution)
    UI_AcquisitionRegionInformation:create(item_id)
end

-------------------------------------
-- function click_sameTypeCard
-- @brief 같은 타입 드래곤 클릭시
-------------------------------------
function UI_BookDetailPopup:click_sameTypeCard(t_dragon)
    if (not t_dragon) then return end

    -- 기존 값 그대로 유지
    t_dragon['bookType'] = self.m_tDragon['bookType'] 
    t_dragon['grade'] = self.m_grade
	t_dragon['evolution'] = self.m_evolution
    t_dragon['lv'] = self.m_lv

	self:setDragon(t_dragon)

    -- refresh
    self:refresh()
end

-------------------------------------
-- function click_teamBonusBtn
-- @brief 팀 보너스
-------------------------------------
function UI_BookDetailPopup:click_teamBonusBtn()
    local sel_did = self.m_tDragon['did']
	UI_TeamBonus(TEAM_BONUS_MODE.DRAGON, nil, sel_did)
end

-------------------------------------
-- function setDragon
-------------------------------------
function UI_BookDetailPopup:setDragon(t_dragon, is_origin)
	self.m_tDragon = t_dragon
	self.m_evolution = t_dragon['evolution']
	self.m_grade = t_dragon['grade']
	self.m_lv = t_dragon['lv'] or 1
    if (is_origin) then
        self.m_originDid = t_dragon['did']
    end
end

-------------------------------------
-- function makeDragonData
-------------------------------------
function UI_BookDetailPopup:makeDragonData(data)
    local t_dragon = (data) and data or self.m_tDragon
    if (not t_dragon) then
        return nil
    end

    local t_dragon_data = {}
    t_dragon_data['did'] = t_dragon['did']
    t_dragon_data['lv'] = self.m_lv
    t_dragon_data['evolution'] = self.m_evolution
    t_dragon_data['grade'] = self.m_grade
    t_dragon_data['exp'] = 0
    t_dragon_data['skill_0'] = 1
    t_dragon_data['skill_1'] = 1
    t_dragon_data['skill_2'] = (t_dragon_data['evolution'] >= 2) and 1 or 0
    t_dragon_data['skill_3'] = (t_dragon_data['evolution'] >= 3) and 1 or 0
    
    return StructDragonObject(t_dragon_data)
end

-------------------------------------
-- function setBookList
-------------------------------------
function UI_BookDetailPopup:setBookList(l_book)
	self.m_lBookList = l_book
end

-------------------------------------
-- function checkRefresh
-- @brief
-------------------------------------
function UI_BookDetailPopup:checkRefresh()
    local is_changed = g_bookData:checkChange(self.m_bookLastChangeTime)

    if is_changed then
        self.m_bookLastChangeTime = g_bookData:getLastChangeTimeStamp()
        self:onChangeDragon()
    end
end

-------------------------------------
-- function setUnableIndex
-------------------------------------
function UI_BookDetailPopup:setUnableIndex()
    local vars = self.vars
    vars['nextBtn']:setVisible(false)
    vars['prevBtn']:setVisible(false)
end

-------------------------------------
-- function setShowTemaBonus
-- @brief 팀보너스 UI에서 카드 클릭하여 들어온 경우 팀보너스 버튼 보여주지 않음
-------------------------------------
function UI_BookDetailPopup:setShowTemaBonus(boolean)
    self.m_showTeamBonus = boolean
end





-------------------------------------
-- function open
-- @brief 외부에서 did 혹은 추가 정보만을 가지고 도감 상세페이지를 열어야할때 사용
-- @brief 좌우 인덱스 이동은 불가하도록 함
-- @comment 다시보니 코드가 많이 지져분해져서 정리할 필요가 있다.
-------------------------------------
function UI_BookDetailPopup.open(did, grade, evolution, is_pick, pick_cb)
    local t_dragon
    if TableSlime:isSlimeID(did) then
        local table_slime = TableSlime()
        t_dragon = clone(table_slime:get(did))
        t_dragon['did'] = did
        t_dragon['bookType'] = 'slime'
    else
        local table_dragon = TableDragon()
        t_dragon = clone(table_dragon:get(did))
        t_dragon['bookType'] = 'dragon'
    end
	t_dragon['grade'] = grade or t_dragon['birthgrade']
	t_dragon['evolution'] = evolution or 1

	local ui = UI_BookDetailPopup(t_dragon)
    ui:setUnableIndex()

	-- 선택권에서 진입한 경우... 굳이 여기서 뽑아야하나..!
	if (is_pick) then
		ui.vars['attrMenu']:setVisible(false)
		ui.vars['rewardMenu']:setPositionX(-175)
		ui.vars['evolutionMenu']:setPositionX(-175)
		ui.vars['summonBtn']:setVisible(true)
		ui.vars['summonBtn']:registerScriptTapHandler(function()
			pick_cb()
			ui:close()
		end)
	end
end

-------------------------------------
-- function openWithCostume
-- @brief 드래곤 레벨, 등급, 진화 커스텀 가능
-------------------------------------
function UI_BookDetailPopup.openWithCostume(did, t_data, is_pick, pick_cb)
    local t_dragon
    if TableSlime:isSlimeID(did) then
        local table_slime = TableSlime()
        t_dragon = clone(table_slime:get(did))
        t_dragon['did'] = did
        t_dragon['bookType'] = 'slime'
    else
        local table_dragon = TableDragon()
        t_dragon = clone(table_dragon:get(did))
        t_dragon['bookType'] = 'dragon'
    end
	t_dragon['grade'] = t_data['grade'] or t_dragon['birthgrade']
	t_dragon['evolution'] = t_data['evolution'] or 1
    t_dragon['lv'] = t_data['lv'] or 1

	local ui = UI_BookDetailPopup(t_dragon)
    ui:setUnableIndex()

	-- 선택권에서 진입한 경우... 굳이 여기서 뽑아야하나..!
	if (is_pick) then
		ui.vars['attrMenu']:setVisible(false)
		ui.vars['rewardMenu']:setPositionX(-175)
		ui.vars['evolutionMenu']:setPositionX(-175)
		ui.vars['summonBtn']:setVisible(true)
		ui.vars['summonBtn']:registerScriptTapHandler(function()
			pick_cb()
			ui:close()
		end)
	end
end

-------------------------------------
-- function openWithFrame
-- @brief 도감 외부에서 독립 팝업 형태로 출력  
-------------------------------------
function UI_BookDetailPopup.openWithFrame(did, grade, evolution, scale, is_popup)
    local t_dragon
    if TableSlime:isSlimeID(did) then
        local table_slime = TableSlime()
        t_dragon = clone(table_slime:get(did))
        t_dragon['did'] = did
        t_dragon['bookType'] = 'slime'
    else
        local table_dragon = TableDragon()
        t_dragon = clone(table_dragon:get(did))
        t_dragon['bookType'] = 'dragon'
    end
	t_dragon['grade'] = grade or t_dragon['birthgrade']
	t_dragon['evolution'] = evolution or 1

    local frame_ui = UI()
    frame_ui:load('capsule_box_dragon_info_pop_up.ui')
    UIManager:open(frame_ui, UIManager.POPUP)
    -- backkey 지정
    g_currScene:pushBackKeyListener(frame_ui, function() frame_ui:close() end, 'UI_BookDetailPopup')


	local ui = UI_BookDetailPopup(t_dragon, is_popup, true)
    ui:setUnableIndex()
    ui.vars['rootMenu']:setScale(0.8)
    ui.vars['rewardNode1']:setVisible(false)
    ui.vars['rewardNode2']:setVisible(false)
    ui.vars['rewardNode3']:setVisible(false)
    
    -- 도감 UI를 프레임 UI에 맞추어 축소시키면 스토리 라벨이 아래로 처짐
    -- 임의로 위치를 올림 원래 위치는 (-10, -189)
    ui.vars['storyLabel']:setPosition(-10, -169)

    -- UI_BookDetailPopup을 프레임 UI에 붙임
    frame_ui.vars['clippingNode']:addChild(ui.vars['rootMenu'])
    frame_ui.vars['closeBtn']:registerScriptTapHandler(function() frame_ui:close() end)
    frame_ui.vars['closeBtn']:setVisible(true)

    -- 해당 팝업에서는 화살표 뒤로가기 버튼과 속성별 드래곤 선택 비활성화
    do
        -- close 버튼 비활성화
        ui.vars['closeBtn']:setVisible(false)
        
        -- 속성별 드래곤 선택 불가
        local l_attr = getAttrTextList()
        for _, attr in ipairs(l_attr) do
            -- 아예 안 만드는 쪽으로 수정해야함
            ui.vars[attr..'Node']:setVisible(false)
        end
    end
    return ui
end

--@CHECK
UI:checkCompileError(UI_BookDetailPopup)
