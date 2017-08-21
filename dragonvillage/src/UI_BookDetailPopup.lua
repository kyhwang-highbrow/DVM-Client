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
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BookDetailPopup:init(t_dragon)
    local vars = self:load('book_detail_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BookDetailPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:sceneFadeInAction()

	-- initialize
	self:setDragon(t_dragon)

    self.m_bookLastChangeTime = g_bookData:getLastChangeTimeStamp()
	self.m_pressTimer = 0

    self:initUI()
    self:initTab()
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
-- function initTab
-------------------------------------
function UI_BookDetailPopup:initTab()
    local vars = self.vars
	for i = 1, 3 do 
        self:addTabWithLabel(i, vars['evolutionTabBtn' .. i], vars['evolutionTabLabel' .. i], nil)
	end
    self:setTab(self.m_evolution)
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

	-- 진화 버튼
	for i = 1, 3 do
		self.vars['evolutionTabBtn' .. i]:setVisible(not (underling or is_slime))
	end
end

-------------------------------------
-- function refresh_rate
-------------------------------------
function UI_BookDetailPopup:refresh_rate()
    local did = self.m_tDragon['did']
    local function cb_func(ret)
        local rate = ret['rate']
	    self.vars['recommandLabel']:setString(string.format('%.1f', rate))
    end
    g_boardData:request_dragonRate(did, cb_func)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_BookDetailPopup:onChangeTab(tab, first)
	local t_dragon = self.m_tDragon
	if (not t_dragon) then
		return
	end

	-- evolution 세팅
	self.m_evolution = tab

    -- grade를 초기화 시킨다.
    self.m_grade = self.m_tDragon['birthgrade']

	-- refresh
	self:onChangeEvolution()
	self:onChangeGrade()
    self:onChangeLV()
	self:calculateStat()
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
        vars['typeNode']:removeAllChildren()
        local icon = IconHelper:getRoleIcon(role_type)
        vars['typeNode']:addChild(icon)

        vars['typeLabel']:setString(dragonRoleTypeName(role_type))
    end    

    do -- 드래곤 스토리
        local story_str = t_dragon['t_desc']
        vars['storyLabel']:setString(story_str)
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
					UI_SkillDetailPopup(t_dragon_data, i)
				end)

			-- 비어있는 스킬 아이콘 생성
			else
				local empty_skill_icon = IconHelper:getEmptySkillIcon()
				skill_node:addChild(empty_skill_icon)

			end
		end

	end

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
		if (self.m_grade < t_dragon['birthgrade'] + 1) then
			self.m_grade = t_dragon['birthgrade'] + 1
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

	-- stats
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

	-- 전투력
	vars['cp_label']:setString(comma_value(t_dragon_data:getCombatPower()))
end














-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_BookDetailPopup:click_nextBtn(is_next)
	local t_dragon = self.m_tDragon
	local did = t_dragon['did']
	local evolution = self.m_evolution
    
	-- 현재의 인덱스 탐색
	local book_data
	for i, t_item in pairs(self.m_lBookList) do
		book_data = t_item['data']
		if (did == book_data['did']) and (evolution == book_data['evolution']) then
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
		self:setDragon(new_t_dragon)
		self:refresh()
		self.m_bookIdx = new_idx

        -- 인덱스 이동간에 진화도가 바뀐다면 탭도 변경해준다
        if (new_t_dragon['evolution'] ~= evolution) then
            self:setTab(new_t_dragon['evolution'])
        end
	end
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
		if (not self.m_pressBtn:isSelected()) then
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

	-- evolution 세팅
	self.m_evolution = evolution

	-- refresh
	self:onChangeEvolution()
	self:onChangeGrade()
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
-- function setDragon
-------------------------------------
function UI_BookDetailPopup:setDragon(t_dragon)
	self.m_tDragon = t_dragon
	self.m_evolution = t_dragon['evolution']
	self.m_grade = t_dragon['grade']
	self.m_lv = 1
end

-------------------------------------
-- function makeDragonData
-------------------------------------
function UI_BookDetailPopup:makeDragonData()
    local t_dragon = self.m_tDragon
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
-- function open
-- @brief 외부에서 did 혹은 추가 정보만을 가지고 도감 상세페이지를 열어야할때 사용
-------------------------------------
function UI_BookDetailPopup.open(did, grade, evolution)
	local table_dragon = TableDragon()
	local t_dragon = table_dragon:get(did)
	t_dragon['grade'] = grade or t_dragon['birthgrade']
	t_dragon['evolution'] = evolution or 1
	UI_BookDetailPopup(t_dragon)
end


--@CHECK
UI:checkCompileError(UI_BookDetailPopup)
